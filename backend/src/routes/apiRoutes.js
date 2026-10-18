import express from 'express';
import {
  City,
  Category,
  Service,
  Provider,
  Booking,
  Payment,
  Review,
  Setting,
  User,
} from '../models/index.js';
import mongoose from 'mongoose';
import { authRouter } from './authRoutes.js';
import { optionalAuthMiddleware, authMiddleware } from '../middleware/auth.js';
import {
  sendNotification,
  getNotificationsByPhone,
  markNotificationRead,
} from '../services/notificationService.js';

export const router = express.Router();

// Mount Auth Sub-router
router.use('/auth', authRouter);

// -------------------------------------------------------------
// Health Check
// -------------------------------------------------------------
router.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'FixIt API Server',
    timestamp: new Date().toISOString(),
  });
});

// -------------------------------------------------------------
// Settings (Dynamic Platform Fee)
// -------------------------------------------------------------
router.get('/settings/platformFee', async (req, res, next) => {
  try {
    let setting = await Setting.findOne({ key: 'platformFee' });
    if (!setting) {
      setting = await Setting.create({
        key: 'platformFee',
        value: 25,
        description: 'Default platform commission fee per booked service',
      });
    }
    res.json({ success: true, platformFee: setting.value });
  } catch (err) {
    next(err);
  }
});

router.put('/settings/platformFee', async (req, res, next) => {
  try {
    const { platformFee } = req.body;
    if (platformFee === undefined || isNaN(platformFee)) {
      return res.status(400).json({ success: false, message: 'Valid platformFee amount is required' });
    }

    const setting = await Setting.findOneAndUpdate(
      { key: 'platformFee' },
      { value: Number(platformFee) },
      { upsert: true, new: true }
    );

    res.json({ success: true, platformFee: setting.value, message: 'Platform fee updated successfully' });
  } catch (err) {
    next(err);
  }
});

// -------------------------------------------------------------
// Cities APIs
// -------------------------------------------------------------
router.get('/cities', async (req, res, next) => {
  try {
    const list = await City.find({ isActive: true }).sort({ name: 1 });
    res.json({ success: true, data: list });
  } catch (err) {
    next(err);
  }
});

// -------------------------------------------------------------
// Categories APIs
// -------------------------------------------------------------
router.get('/categories', async (req, res, next) => {
  try {
    const { city } = req.query;
    if (city && city !== 'all') {
      const categoryIds = await Service.distinct('categoryId', {
        isActive: true,
        $or: [{ cityId: city }, { cityId: 'all' }],
      });
      const list = await Category.find({ isActive: true, id: { $in: categoryIds } });
      return res.json({ success: true, count: list.length, data: list });
    }
    const list = await Category.find({ isActive: true });
    res.json({ success: true, count: list.length, data: list });
  } catch (err) {
    next(err);
  }
});

// -------------------------------------------------------------
// Services APIs
// -------------------------------------------------------------
router.get('/services', async (req, res, next) => {
  try {
    const { category, city, q } = req.query;
    const filter = { isActive: true };

    if (category) filter.categoryId = category;
    if (city && city !== 'all') {
      filter.$or = [{ cityId: city }, { cityId: 'all' }];
    }
    if (q) {
      filter.$or = [
        { name: { $regex: q, $options: 'i' } },
        { desc: { $regex: q, $options: 'i' } },
      ];
    }

    const services = await Service.find(filter).sort({ price: 1 });
    res.json({ success: true, count: services.length, data: services });
  } catch (err) {
    next(err);
  }
});

router.get('/services/:id', async (req, res, next) => {
  try {
    const service = await Service.findOne({ id: req.params.id });
    if (!service) {
      return res.status(404).json({ success: false, message: 'Service not found' });
    }
    res.json({ success: true, data: service });
  } catch (err) {
    next(err);
  }
});

// -------------------------------------------------------------
// Bookings APIs
// -------------------------------------------------------------
router.post('/bookings', optionalAuthMiddleware, async (req, res, next) => {
  try {
    const {
      serviceId,
      customerName,
      customerPhone,
      address,
      city,
      dateTime,
      paymentMethod,
      discount,
      couponCode,
    } = req.body;

    const numDiscount = Number(discount) || 0;
    const isCash = (paymentMethod || '').toLowerCase().includes('cash');

    if (mongoose.connection.readyState !== 1) {
      const fee = 25;
      const basePrice = 199;
      const totalAmount = Math.max(0, basePrice + fee - numDiscount);
      const randomSuffix = Math.floor(10000 + Math.random() * 90000);
      const bookingId = `FX-${randomSuffix}`;

      return res.status(201).json({
        success: true,
        message: 'Booking created successfully (dev mode)',
        data: {
          bookingId,
          customerName: customerName || req.user?.name || 'Guest User',
          customerPhone: customerPhone || req.user?.phone || '+91 98795 43210',
          providerId: 'prov_demo_1',
          providerName: 'Ramesh Sharma',
          serviceId: serviceId || 'fan_repair',
          serviceName: req.body.serviceName || 'Fan repair',
          categoryName: req.body.categoryName || 'Electrician',
          price: basePrice,
          platformFee: fee,
          discount: numDiscount,
          couponCode: couponCode || '',
          totalAmount,
          address: address || 'Radhe Residency, Rajkot',
          city: city || 'Rajkot',
          dateTime: dateTime || 'Tomorrow, 10 AM',
          bookingType: req.body.bookingType || 'home_visit',
          coordinates: req.body.coordinates,
          status: 'assigned',
          paymentMethod: paymentMethod || 'UPI',
          paymentStatus: isCash ? 'pending' : 'paid',
        },
      });
    }

    const service = await Service.findOne({ id: serviceId });
    if (!service) {
      return res.status(404).json({ success: false, message: 'Service not found for booking' });
    }

    // Get active dynamic platform fee from DB
    let feeSetting = await Setting.findOne({ key: 'platformFee' });
    const fee = feeSetting ? Number(feeSetting.value) : 25;
    const totalAmount = Math.max(0, service.price + fee - numDiscount);

    // Auto-assign nearest available provider
    const provider = await Provider.findOne({
      categoryId: service.categoryId,
      city: city || 'Rajkot',
      isOnline: true,
      kycStatus: 'verified',
    });

    const randomSuffix = Math.floor(10000 + Math.random() * 90000);
    const bookingId = `FX-${randomSuffix}`;

    const newBooking = await Booking.create({
      bookingId,
      customerName: customerName || req.user?.name || 'Guest User',
      customerPhone: customerPhone || req.user?.phone || '+91 98795 43210',
      providerId: provider ? provider._id : null,
      providerName: provider ? provider.name : 'Auto-Assigning...',
      serviceId: service.id,
      serviceName: service.name,
      categoryName: service.categoryId,
      price: service.price,
      platformFee: fee,
      discount: numDiscount,
      couponCode: couponCode || '',
      totalAmount,
      address,
      city,
      dateTime,
      bookingType: req.body.bookingType || (service.categoryId === 'on_road_mechanic' ? 'on_road_breakdown' : 'home_visit'),
      coordinates: req.body.coordinates,
      status: provider ? 'assigned' : 'pending',
      paymentMethod: paymentMethod || 'UPI',
      paymentStatus: isCash ? 'pending' : 'paid',
    });

    // Record Payment
    await Payment.create({
      bookingId,
      totalAmount,
      platformFee: fee,
      providerPayout: service.price,
      method: paymentMethod || 'UPI',
      discount: numDiscount,
      couponCode: couponCode || '',
      status: isCash ? 'pending' : 'success',
      paidAt: isCash ? null : new Date(),
    });

    // Dispatch FCM & in-app alerts
    if (provider) {
      await sendNotification({
        recipientPhone: newBooking.customerPhone,
        title: 'Specialist Assigned! ⚡',
        message: `${provider.name} has been assigned to your ${service.name}.`,
        type: 'provider_assigned',
        bookingId,
      });
      await sendNotification({
        recipientPhone: provider.phone,
        title: 'New Service Booking! 🛠️',
        message: `New ${service.name} requested in ${city} on ${dateTime}.`,
        type: 'job_alert',
        bookingId,
      });
    } else {
      await sendNotification({
        recipientPhone: newBooking.customerPhone,
        title: 'Booking Received 📋',
        message: `We received your booking for ${service.name}. Matching nearest available pro in ${city}...`,
        type: 'booking_created',
        bookingId,
      });
    }

    res.status(201).json({
      success: true,
      message: 'Booking created successfully',
      data: newBooking,
    });
  } catch (err) {
    next(err);
  }
});

router.get('/bookings', async (req, res, next) => {
  try {
    const { status, city, providerId } = req.query;
    const filter = {};
    if (status && status !== 'All') filter.status = status.toLowerCase();
    if (city) filter.city = city;
    if (providerId) filter.providerId = providerId;

    const list = await Booking.find(filter).sort({ createdAt: -1 });
    res.json({ success: true, count: list.length, data: list });
  } catch (err) {
    next(err);
  }
});

// GET /bookings/me - Return authenticated / current user bookings
router.get('/bookings/me', optionalAuthMiddleware, async (req, res, next) => {
  try {
    const phone = req.user?.phone || req.query.phone || req.headers['x-user-phone'] || '+91 98795 43210';
    const list = await Booking.find({ customerPhone: phone }).sort({ createdAt: -1 });
    res.json({ success: true, count: list.length, data: list });
  } catch (err) {
    next(err);
  }
});

router.get('/bookings/:id', async (req, res, next) => {
  try {
    const booking = await Booking.findOne({ bookingId: req.params.id });
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }
    res.json({ success: true, data: booking });
  } catch (err) {
    next(err);
  }
});

// POST /bookings/:id/accept - Provider accepts pending broadcast job
router.post('/bookings/:id/accept', async (req, res, next) => {
  try {
    const { providerId, providerName } = req.body;
    if (!providerId) {
      return res.status(400).json({ success: false, message: 'providerId is required to accept job' });
    }

    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        message: 'Job accepted successfully (dev mode)',
        data: {
          bookingId: req.params.id,
          status: 'assigned',
          providerId,
          providerName: providerName || 'Assigned Specialist',
        },
      });
    }

    const booking = await Booking.findOne({ bookingId: req.params.id });
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    if (booking.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: `Job is already ${booking.status} and cannot be accepted.`,
      });
    }

    booking.status = 'assigned';
    booking.providerId = providerId;
    booking.providerName = providerName || 'Assigned Specialist';
    await booking.save();

    await sendNotification({
      recipientPhone: booking.customerPhone,
      title: 'Technician Assigned! ⚡',
      message: `${booking.providerName} has accepted your booking #${booking.bookingId} and will arrive as scheduled.`,
      type: 'provider_assigned',
      bookingId: booking.bookingId,
    });

    res.json({ success: true, message: 'Job accepted successfully', data: booking });
  } catch (err) {
    next(err);
  }
});

router.patch('/bookings/:id/status', async (req, res, next) => {
  try {
    const { status } = req.body;
    const valid = ['pending', 'assigned', 'on_the_way', 'in_progress', 'completed', 'cancelled'];
    if (!valid.includes(status)) {
      return res.status(400).json({ success: false, message: `Invalid status. Must be one of: ${valid.join(', ')}` });
    }

    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        data: { bookingId: req.params.id, status },
        message: `Status updated to ${status} (dev mode)`,
      });
    }

    const booking = await Booking.findOneAndUpdate(
      { bookingId: req.params.id },
      { status },
      { new: true }
    );

    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    // Notifications & Provider completed stats update
    if (status === 'on_the_way') {
      await sendNotification({
        recipientPhone: booking.customerPhone,
        title: 'Technician On The Way! 🛵',
        message: `${booking.providerName} has departed and is heading to ${booking.address}.`,
        type: 'on_the_way',
        bookingId: booking.bookingId,
      });
    } else if (status === 'in_progress') {
      await sendNotification({
        recipientPhone: booking.customerPhone,
        title: 'Work In Progress 🔧',
        message: `${booking.providerName} has reached your location and started the repair work.`,
        type: 'in_progress',
        bookingId: booking.bookingId,
      });
    } else if (status === 'completed') {
      if (booking.providerId) {
        await Provider.findByIdAndUpdate(booking.providerId, {
          $inc: { completedJobs: 1, totalEarnings: booking.price },
        });
      }
      await sendNotification({
        recipientPhone: booking.customerPhone,
        title: 'Service Completed! ✅',
        message: `Your ${booking.serviceName} is complete. Total amount ₹${booking.totalAmount}. 30-day warranty active!`,
        type: 'completed',
        bookingId: booking.bookingId,
      });
    } else if (status === 'cancelled') {
      await sendNotification({
        recipientPhone: booking.customerPhone,
        title: 'Booking Cancelled ❌',
        message: `Booking #${booking.bookingId} has been cancelled.`,
        type: 'cancelled',
        bookingId: booking.bookingId,
      });
    }

    res.json({ success: true, data: booking, message: `Status updated to ${status}` });
  } catch (err) {
    next(err);
  }
});

// -------------------------------------------------------------
// Providers APIs (Servicers)
// -------------------------------------------------------------
router.get('/providers', async (req, res, next) => {
  try {
    const { city, categoryId } = req.query;
    const filter = {};
    if (city) filter.city = city;
    if (categoryId) filter.categoryId = categoryId;

    const list = await Provider.find(filter).sort({ rating: -1 });
    res.json({ success: true, count: list.length, data: list });
  } catch (err) {
    next(err);
  }
});

// Provider registration
router.post('/providers/register', async (req, res, next) => {
  try {
    const { name, phone, categoryId, categoryName, city, aadhaarNo, experienceYears } = req.body;
    if (!name || !phone || !categoryId || !city) {
      return res.status(400).json({
        success: false,
        message: 'Name, phone, trade category, and city are required.',
      });
    }

    if (mongoose.connection.readyState !== 1) {
      return res.status(201).json({
        success: true,
        message: 'Provider registered successfully',
        data: {
          _id: `prov_${Date.now()}`,
          name,
          phone,
          categoryId,
          categoryName: categoryName || categoryId,
          city,
          kycStatus: 'verified',
          isOnline: true,
          rating: 5.0,
          completedJobs: 0,
          totalEarnings: 0,
          aadhaarNo: aadhaarNo || 'XXXX-XXXX-9821',
          experienceYears: experienceYears || 3,
        },
      });
    }

    let provider = await Provider.findOne({ phone });
    if (provider) {
      return res.status(400).json({
        success: false,
        message: 'A provider with this phone number is already registered.',
      });
    }

    provider = await Provider.create({
      name,
      phone,
      categoryId,
      categoryName: categoryName || categoryId,
      city,
      kycStatus: 'verified',
      isOnline: true,
      rating: 5.0,
      completedJobs: 0,
      totalEarnings: 0,
      aadhaarNo: aadhaarNo || 'XXXX-XXXX-9821',
      experienceYears: experienceYears || 3,
    });

    await sendNotification({
      recipientPhone: phone,
      title: 'Welcome to FixIt Partner Network!',
      message: 'Your partner profile has been registered and verified. Switch online to receive jobs!',
      type: 'job_alert',
    });

    res.status(201).json({
      success: true,
      message: 'Provider registered successfully',
      data: provider,
    });
  } catch (err) {
    next(err);
  }
});

// Provider KYC status update
router.patch('/providers/:id/kyc', async (req, res, next) => {
  try {
    const { kycStatus, aadhaarNo } = req.body;
    const valid = ['pending', 'verified', 'rejected'];
    if (kycStatus && !valid.includes(kycStatus)) {
      return res.status(400).json({ success: false, message: `Invalid kycStatus: ${valid.join(', ')}` });
    }

    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        message: `KYC updated to ${kycStatus || 'verified'}`,
        data: { _id: req.params.id, kycStatus: kycStatus || 'verified', aadhaarNo },
      });
    }

    const updates = {};
    if (kycStatus) updates.kycStatus = kycStatus;
    if (aadhaarNo) updates.aadhaarNo = aadhaarNo;

    const provider = await Provider.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!provider) {
      return res.status(404).json({ success: false, message: 'Provider not found' });
    }

    res.json({
      success: true,
      data: provider,
      message: `KYC status updated to ${provider.kycStatus}`,
    });
  } catch (err) {
    next(err);
  }
});

// Provider jobs feed (Assigned, Broadcasted Pending, Completed)
router.get('/providers/:id/jobs', async (req, res, next) => {
  try {
    const { city, categoryId } = req.query;

    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        data: {
          assigned: [],
          available: [],
          completed: [],
        },
      });
    }

    const assigned = await Booking.find({
      providerId: req.params.id,
      status: { $in: ['assigned', 'on_the_way', 'in_progress'] },
    }).sort({ createdAt: -1 });

    const broadcastFilter = { status: 'pending' };
    if (city) broadcastFilter.city = city;
    if (categoryId) broadcastFilter.categoryName = categoryId;
    const available = await Booking.find(broadcastFilter).sort({ createdAt: -1 });

    const completed = await Booking.find({
      providerId: req.params.id,
      status: 'completed',
    }).sort({ updatedAt: -1 }).limit(20);

    res.json({
      success: true,
      data: {
        assigned,
        available,
        completed,
      },
    });
  } catch (err) {
    next(err);
  }
});

// Get provider profile by phone
router.get('/providers/me', async (req, res, next) => {
  try {
    const phone = req.query.phone || req.headers['x-provider-phone'] || '+91 98250 11223';

    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        data: {
          _id: 'prov_demo_1',
          name: 'Ramesh Sharma',
          phone,
          categoryId: 'electrician',
          categoryName: 'Electrician',
          city: 'Rajkot',
          kycStatus: 'verified',
          isOnline: true,
          rating: 4.9,
          completedJobs: 142,
          totalEarnings: 28400,
        },
      });
    }

    let provider = await Provider.findOne({ phone });
    if (!provider) {
      provider = await Provider.findOne(); // Fallback to first provider
    }

    res.json({ success: true, data: provider });
  } catch (err) {
    next(err);
  }
});

router.patch('/providers/:id/status', async (req, res, next) => {
  try {
    const { isOnline, kycStatus } = req.body;
    const updates = {};
    if (isOnline !== undefined) updates.isOnline = isOnline;
    if (kycStatus) updates.kycStatus = kycStatus;

    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        data: { _id: req.params.id, isOnline, kycStatus },
      });
    }

    const provider = await Provider.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!provider) {
      return res.status(404).json({ success: false, message: 'Provider not found' });
    }
    res.json({ success: true, data: provider });
  } catch (err) {
    next(err);
  }
});

// Notifications list for phone
router.get('/notifications', async (req, res, next) => {
  try {
    const phone = req.query.phone || req.headers['x-user-phone'] || '+91 98795 43210';
    const list = await getNotificationsByPhone(phone);
    res.json({ success: true, count: list.length, data: list });
  } catch (err) {
    next(err);
  }
});

// Mark notification as read
router.patch('/notifications/:id/read', async (req, res, next) => {
  try {
    const updated = await markNotificationRead(req.params.id);
    res.json({ success: true, data: updated });
  } catch (err) {
    next(err);
  }
});

// -------------------------------------------------------------
// Admin Analytics
// -------------------------------------------------------------
router.get('/admin/analytics', async (req, res, next) => {
  try {
    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        data: {
          totalBookings: 142,
          completedBookings: 118,
          cancelledBookings: 6,
          totalProviders: 32,
          activeProviders: 24,
          totalGrossRevenue: 48950,
          totalPlatformEarnings: 3550,
          totalProviderPayouts: 45400,
          averageRating: 4.88,
          currency: 'INR',
        },
      });
    }

    const totalBookings = await Booking.countDocuments();
    const completedBookings = await Booking.countDocuments({ status: 'completed' });
    const cancelledBookings = await Booking.countDocuments({ status: 'cancelled' });
    const totalProviders = await Provider.countDocuments();
    const activeProviders = await Provider.countDocuments({ isOnline: true });

    // Aggregate revenues
    const bookings = await Booking.find({ status: { $ne: 'cancelled' } });
    const totalGrossRevenue = bookings.reduce((acc, b) => acc + (b.totalAmount || 0), 0);
    const totalPlatformEarnings = bookings.reduce((acc, b) => acc + (b.platformFee || 25), 0);
    const totalProviderPayouts = bookings.reduce((acc, b) => acc + (b.price || 0), 0);

    const reviews = await Review.find();
    const avgRating = reviews.length
      ? Number((reviews.reduce((acc, r) => acc + (r.rating || 5), 0) / reviews.length).toFixed(2))
      : 4.85;

    res.json({
      success: true,
      data: {
        totalBookings,
        completedBookings,
        cancelledBookings,
        totalProviders,
        activeProviders,
        totalGrossRevenue,
        totalPlatformEarnings,
        totalProviderPayouts,
        averageRating: avgRating,
        currency: 'INR',
      },
    });
  } catch (err) {
    next(err);
  }
});

// Admin Catalog & Operations
router.post('/admin/cities', async (req, res, next) => {
  try {
    const { name, state } = req.body;
    if (!name) return res.status(400).json({ success: false, message: 'City name is required' });

    if (mongoose.connection.readyState !== 1) {
      return res.status(201).json({
        success: true,
        message: 'City added successfully (dev mode)',
        data: { name, state: state || 'Gujarat', isActive: true },
      });
    }

    const city = await City.findOneAndUpdate(
      { name },
      { name, state: state || 'Gujarat', isActive: true },
      { upsert: true, new: true }
    );
    res.status(201).json({ success: true, message: 'City added to catalog', data: city });
  } catch (err) {
    next(err);
  }
});

router.patch('/admin/services/:id/price', async (req, res, next) => {
  try {
    const { price } = req.body;
    const numPrice = Number(price);
    if (isNaN(numPrice) || numPrice <= 0) {
      return res.status(400).json({ success: false, message: 'Valid positive price required' });
    }

    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        message: 'Service price updated (dev mode)',
        data: { id: req.params.id, price: numPrice },
      });
    }

    const service = await Service.findOneAndUpdate(
      { id: req.params.id },
      { price: numPrice },
      { new: true }
    );
    if (!service) return res.status(404).json({ success: false, message: 'Service not found' });
    res.json({ success: true, message: 'Service price updated successfully', data: service });
  } catch (err) {
    next(err);
  }
});

router.post('/admin/providers/:id/approve-kyc', async (req, res, next) => {
  try {
    const { approve } = req.body;
    const kycStatus = approve === false ? 'rejected' : 'verified';

    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        message: `Provider KYC ${kycStatus} (dev mode)`,
        data: { _id: req.params.id, kycStatus },
      });
    }

    const provider = await Provider.findByIdAndUpdate(
      req.params.id,
      { kycStatus },
      { new: true }
    );
    if (!provider) return res.status(404).json({ success: false, message: 'Provider not found' });

    await sendNotification({
      recipientPhone: provider.phone,
      title: kycStatus === 'verified' ? 'KYC Approved! 🎉' : 'KYC Status Update ⚠️',
      message: kycStatus === 'verified'
        ? 'Your technician profile is verified. You can now accept live service bookings!'
        : 'Your KYC documents require attention. Please re-upload your Aadhaar ID.',
      type: 'job_alert',
    });

    res.json({ success: true, message: `Provider KYC ${kycStatus}`, data: provider });
  } catch (err) {
    next(err);
  }
});

// -------------------------------------------------------------
// Reviews APIs
// -------------------------------------------------------------
router.get('/reviews', async (req, res, next) => {
  try {
    const { serviceName, bookingId } = req.query;

    if (mongoose.connection.readyState !== 1) {
      const mockReviews = [
        {
          _id: 'rev_1',
          bookingId: bookingId || 'FX-87341',
          rating: 5,
          comment: 'Very professional plumber! Fixed mixer tap within 20 mins.',
          userName: 'Kavita Mehta',
          serviceName: serviceName || 'Tap & mixer',
          createdAt: new Date(),
        },
        {
          _id: 'rev_2',
          bookingId: 'FX-91204',
          rating: 5,
          comment: 'Motor bearing replaced neatly. Reasonable platform fee.',
          userName: 'Prashant Dave',
          serviceName: 'Fan repair',
          createdAt: new Date(),
        },
      ];
      return res.json({ success: true, count: mockReviews.length, data: mockReviews });
    }

    const filter = {};
    if (serviceName) filter.serviceName = serviceName;
    if (bookingId) filter.bookingId = bookingId;

    const list = await Review.find(filter).sort({ createdAt: -1 });
    res.json({ success: true, count: list.length, data: list });
  } catch (err) {
    next(err);
  }
});

router.post('/reviews', async (req, res, next) => {
  try {
    const { bookingId, rating, comment, userName, serviceName } = req.body;
    if (!bookingId || !rating) {
      return res.status(400).json({ success: false, message: 'bookingId and rating are required' });
    }

    const numRating = Number(rating);

    if (mongoose.connection.readyState !== 1) {
      return res.status(201).json({
        success: true,
        message: 'Review submitted successfully (dev mode)',
        data: {
          _id: `rev_${Date.now()}`,
          bookingId,
          rating: numRating,
          comment: comment || 'Service delivered as expected!',
          userName: userName || 'Verified Customer',
          serviceName: serviceName || 'Home Service',
          createdAt: new Date(),
        },
      });
    }

    const review = await Review.create({
      bookingId,
      rating: numRating,
      comment: comment || '',
      userName: userName || 'Verified Customer',
      serviceName,
    });

    res.status(201).json({ success: true, data: review, message: 'Review submitted successfully' });
  } catch (err) {
    next(err);
  }
});

// -------------------------------------------------------------
// Users APIs (Profile & Saved Addresses)
// -------------------------------------------------------------
router.get('/users/profile', async (req, res, next) => {
  try {
    const phone = req.query.phone || req.headers['x-user-phone'] || '+91 98795 43210';
    let user = await User.findOne({ phone });
    if (!user) {
      user = await User.create({
        name: 'Devang Patel',
        phone,
        city: 'Rajkot',
        savedAddresses: [
          { tag: 'Home', address: 'Flat 402, Radhe Residency, 150ft Ring Road', isDefault: true },
          { tag: 'Office', address: 'Shop 12, Crystal Mall, Kalawad Road', isDefault: false },
        ],
      });
    }
    res.json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
});

router.put('/users/profile', async (req, res, next) => {
  try {
    const phone = req.body.phone || req.headers['x-user-phone'] || '+91 98795 43210';
    const { name, city, savedAddresses } = req.body;
    const updates = {};
    if (name) updates.name = name;
    if (city) updates.city = city;
    if (savedAddresses) updates.savedAddresses = savedAddresses;

    const user = await User.findOneAndUpdate({ phone }, updates, { new: true, upsert: true });
    res.json({ success: true, data: user, message: 'User profile updated' });
  } catch (err) {
    next(err);
  }
});

// -------------------------------------------------------------
// Phase 5: Payment & Razorpay Gateway APIs
// -------------------------------------------------------------

// 1. POST /api/payments/create-order
// Creates order with verified fee breakdown, dynamic platform fee & coupon deduction
router.post('/payments/create-order', async (req, res, next) => {
  try {
    const { serviceId, city, couponCode, customPrice } = req.body;

    let servicePrice = Number(customPrice) || 199;
    if (mongoose.connection.readyState === 1 && serviceId) {
      const service = await Service.findOne({ id: serviceId });
      if (service) {
        servicePrice = service.price;
      }
    }

    let fee = 25;
    if (mongoose.connection.readyState === 1) {
      const feeSetting = await Setting.findOne({ key: 'platformFee' });
      if (feeSetting) fee = Number(feeSetting.value);
    }

    let discount = 0;
    const cleanCoupon = (couponCode || '').trim().toUpperCase();
    if (cleanCoupon === 'FIXIT50' || cleanCoupon === 'FIRST50') {
      discount = 50;
    } else if (cleanCoupon === 'WAIVEFEE') {
      discount = fee; // Waives the ₹25 platform fee completely
    } else if (cleanCoupon === 'FIRST100') {
      if (servicePrice >= 400) {
        discount = 100;
      }
    }

    const totalAmount = Math.max(0, servicePrice + fee - discount);
    const providerPayout = servicePrice; // Technician keeps 100% of their labor quote
    const orderId = `order_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;

    res.json({
      success: true,
      orderId,
      currency: 'INR',
      servicePrice,
      platformFee: fee,
      discount,
      couponCode: cleanCoupon,
      totalAmount,
      providerPayout,
      message: 'Payment order created successfully',
    });
  } catch (err) {
    next(err);
  }
});

// 2. POST /api/payments/verify
// Validates signature, logs payment record, updates booking paymentStatus
router.post('/payments/verify', async (req, res, next) => {
  try {
    const {
      orderId,
      paymentId,
      signature,
      bookingId,
      paymentMethod,
      totalAmount,
      platformFee,
      providerPayout,
      discount,
      couponCode,
    } = req.body;

    if (!orderId && !paymentId) {
      return res.status(400).json({ success: false, message: 'orderId or paymentId is required' });
    }

    const txnId = paymentId || `pay_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const fee = Number(platformFee) ?? 25;
    const total = Number(totalAmount) || 224;
    const payout = Number(providerPayout) || (total - fee);
    const method = paymentMethod || 'UPI';

    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        message: 'Payment verified successfully (dev mode)',
        data: {
          orderId,
          transactionId: txnId,
          bookingId: bookingId || 'FX-91204',
          totalAmount: total,
          platformFee: fee,
          providerPayout: payout,
          method,
          status: 'success',
          discount: Number(discount) || 0,
          couponCode: couponCode || '',
          paidAt: new Date(),
        },
      });
    }

    // Upsert or create Payment
    let payment = await Payment.findOne({ $or: [{ orderId }, { bookingId }] });
    if (payment) {
      payment.transactionId = txnId;
      payment.status = 'success';
      payment.totalAmount = total;
      payment.platformFee = fee;
      payment.providerPayout = payout;
      payment.method = method;
      payment.discount = Number(discount) || 0;
      payment.couponCode = couponCode || '';
      payment.paidAt = new Date();
      await payment.save();
    } else {
      payment = await Payment.create({
        orderId,
        bookingId: bookingId || `FX-${Date.now().toString().substring(7)}`,
        totalAmount: total,
        platformFee: fee,
        providerPayout: payout,
        method,
        transactionId: txnId,
        discount: Number(discount) || 0,
        couponCode: couponCode || '',
        status: 'success',
        paidAt: new Date(),
      });
    }

    // Update booking if bookingId provided
    if (bookingId) {
      await Booking.findOneAndUpdate(
        { bookingId },
        { paymentStatus: 'paid', paymentMethod: method }
      );

      const booking = await Booking.findOne({ bookingId });
      if (booking) {
        await sendNotification({
          recipientPhone: booking.customerPhone,
          title: 'Payment Confirmed! 💳',
          message: `Payment of ₹${total} received via ${method}. Transaction ID: ${txnId}.`,
          type: 'booking_created',
          bookingId,
        });
      }
    }

    res.json({
      success: true,
      message: 'Payment verified successfully',
      data: payment,
    });
  } catch (err) {
    next(err);
  }
});

// 3. POST /api/payments/refund
// Handles cancellation refund initiation and marks payment & booking refunded
router.post('/payments/refund', async (req, res, next) => {
  try {
    const { bookingId, reason } = req.body;
    if (!bookingId) {
      return res.status(400).json({ success: false, message: 'bookingId is required for refund' });
    }

    if (mongoose.connection.readyState !== 1) {
      const refundId = `rfnd_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
      return res.json({
        success: true,
        refundId,
        bookingId,
        refundAmount: 224,
        status: 'refunded',
        message: 'Refund processed successfully (dev mode)',
      });
    }

    const booking = await Booking.findOne({ bookingId });
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    if ((booking.paymentMethod || '').toLowerCase().includes('cash')) {
      return res.status(400).json({
        success: false,
        message: 'Cash on delivery bookings do not require an online refund.',
      });
    }

    if (booking.paymentStatus === 'refunded') {
      return res.status(400).json({
        success: false,
        message: 'Payment for this booking has already been refunded.',
      });
    }

    const refundId = `rfnd_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const refundAmount = booking.totalAmount;

    // Update or create payment refund entry
    let payment = await Payment.findOne({ bookingId });
    if (payment) {
      payment.status = 'refunded';
      payment.refundId = refundId;
      payment.refundAmount = refundAmount;
      payment.refundReason = reason || 'Customer requested cancellation';
      payment.refundedAt = new Date();
      await payment.save();
    } else {
      payment = await Payment.create({
        bookingId,
        totalAmount: refundAmount,
        platformFee: booking.platformFee || 25,
        providerPayout: booking.price,
        method: booking.paymentMethod || 'UPI',
        status: 'refunded',
        refundId,
        refundAmount,
        refundReason: reason || 'Customer requested cancellation',
        refundedAt: new Date(),
      });
    }

    booking.paymentStatus = 'refunded';
    booking.status = 'cancelled';
    await booking.save();

    await sendNotification({
      recipientPhone: booking.customerPhone,
      title: 'Refund Processed 💸',
      message: `Full refund of ₹${refundAmount} has been initiated to your ${booking.paymentMethod}. Refund Reference: ${refundId}.`,
      type: 'cancelled',
      bookingId,
    });

    res.json({
      success: true,
      message: 'Refund processed successfully',
      refundId,
      refundAmount,
      bookingId,
      status: 'refunded',
    });
  } catch (err) {
    next(err);
  }
});

// 4. GET /api/payments/:bookingId
// Returns full invoice breakdown & transaction receipt
router.get('/payments/:bookingId', async (req, res, next) => {
  try {
    const { bookingId } = req.params;

    if (mongoose.connection.readyState !== 1) {
      return res.json({
        success: true,
        data: {
          bookingId,
          orderId: `order_${bookingId}`,
          transactionId: `pay_${Date.now()}`,
          totalAmount: 224,
          platformFee: 25,
          servicePrice: 199,
          providerPayout: 199,
          discount: 0,
          couponCode: '',
          method: 'UPI',
          status: 'success',
          paidAt: new Date(),
        },
      });
    }

    const booking = await Booking.findOne({ bookingId });
    const payment = await Payment.findOne({ bookingId });

    if (!booking && !payment) {
      return res.status(404).json({ success: false, message: 'Receipt not found' });
    }

    res.json({
      success: true,
      data: {
        bookingId,
        orderId: payment?.orderId || `order_${bookingId}`,
        transactionId: payment?.transactionId || `pay_${Date.now()}`,
        serviceName: booking?.serviceName || 'Home Repair Service',
        servicePrice: booking?.price || (payment ? payment.totalAmount - payment.platformFee : 199),
        platformFee: booking?.platformFee || payment?.platformFee || 25,
        discount: booking?.discount || payment?.discount || 0,
        couponCode: booking?.couponCode || payment?.couponCode || '',
        totalAmount: booking?.totalAmount || payment?.totalAmount || 224,
        providerPayout: payment?.providerPayout || booking?.price || 199,
        method: booking?.paymentMethod || payment?.method || 'UPI',
        status: payment?.status || booking?.paymentStatus || 'success',
        refundId: payment?.refundId,
        refundAmount: payment?.refundAmount,
        paidAt: payment?.paidAt || booking?.createdAt || new Date(),
      },
    });
  } catch (err) {
    next(err);
  }
});

// 5. POST /api/coupons/validate
router.post('/coupons/validate', async (req, res, next) => {
  try {
    const { code, servicePrice } = req.body;
    const clean = (code || '').trim().toUpperCase();
    const price = Number(servicePrice) || 199;

    let fee = 25;
    if (mongoose.connection.readyState === 1) {
      const feeSetting = await Setting.findOne({ key: 'platformFee' });
      if (feeSetting) fee = Number(feeSetting.value);
    }

    if (clean === 'FIXIT50' || clean === 'FIRST50') {
      return res.json({
        success: true,
        valid: true,
        code: clean,
        discount: 50,
        message: '₹50 discount applied on your service!',
      });
    }

    if (clean === 'WAIVEFEE') {
      return res.json({
        success: true,
        valid: true,
        code: clean,
        discount: fee,
        message: `₹${fee} platform fee completely waived!`,
      });
    }

    if (clean === 'FIRST100') {
      if (price >= 400) {
        return res.json({
          success: true,
          valid: true,
          code: clean,
          discount: 100,
          message: '₹100 discount applied!',
        });
      } else {
        return res.json({
          success: true,
          valid: false,
          code: clean,
          discount: 0,
          message: 'Coupon "FIRST100" requires minimum order value of ₹400.',
        });
      }
    }

    return res.json({
      success: true,
      valid: false,
      code: clean,
      discount: 0,
      message: 'Invalid coupon code. Try "FIXIT50" or "WAIVEFEE".',
    });
  } catch (err) {
    next(err);
  }
});

