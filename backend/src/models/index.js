import mongoose from 'mongoose';

// 1. City Schema
const citySchema = new mongoose.Schema(
  {
    name: { type: String, required: true, unique: true, trim: true },
    state: { type: String, default: 'Gujarat' },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);
export const City = mongoose.model('City', citySchema);

// 2. Category Schema
const categorySchema = new mongoose.Schema(
  {
    id: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    iconName: { type: String, required: true },
    colorHex: { type: String, default: '#2563EB' },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);
export const Category = mongoose.model('Category', categorySchema);

// 3. Service Schema
const serviceSchema = new mongoose.Schema(
  {
    id: { type: String, required: true, unique: true },
    categoryId: { type: String, required: true },
    cityId: { type: String, default: 'all' },
    name: { type: String, required: true },
    desc: { type: String, required: true },
    price: { type: Number, required: true },
    included: [{ type: String }],
    rating: { type: Number, default: 4.8 },
    reviewsCount: { type: Number, default: 1200 },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);
export const Service = mongoose.model('Service', serviceSchema);

// 4. User Schema
const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    phone: { type: String, required: true, unique: true },
    role: { type: String, enum: ['customer', 'provider', 'admin'], default: 'customer' },
    city: { type: String, default: 'Rajkot' },
    savedAddresses: [
      {
        tag: { type: String, default: 'Home' },
        address: { type: String, required: true },
        isDefault: { type: Boolean, default: false },
      },
    ],
  },
  { timestamps: true }
);
export const User = mongoose.model('User', userSchema);

// 5. Provider / Servicer Schema
const providerSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    phone: { type: String, required: true, unique: true },
    categoryId: { type: String, required: true },
    categoryName: { type: String, required: true },
    city: { type: String, required: true },
    kycStatus: { type: String, enum: ['pending', 'verified', 'rejected'], default: 'verified' },
    isOnline: { type: Boolean, default: true },
    rating: { type: Number, default: 4.9 },
    completedJobs: { type: Number, default: 0 },
    totalEarnings: { type: Number, default: 0 },
    aadhaarNo: { type: String },
    experienceYears: { type: Number, default: 3 },
    fcmToken: { type: String },
  },
  { timestamps: true }
);
export const Provider = mongoose.model('Provider', providerSchema);

// 6. Booking Schema
const bookingSchema = new mongoose.Schema(
  {
    bookingId: { type: String, required: true, unique: true },
    customerName: { type: String, default: 'Guest User' },
    customerPhone: { type: String, default: '+91 98795 43210' },
    providerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Provider' },
    providerName: { type: String, default: 'Unassigned' },
    serviceId: { type: String, required: true },
    serviceName: { type: String, required: true },
    categoryName: { type: String, required: true },
    price: { type: Number, required: true },
    platformFee: { type: Number, default: 25 },
    totalAmount: { type: Number, required: true },
    address: { type: String, required: true },
    city: { type: String, required: true },
    dateTime: { type: String, required: true },
    bookingType: { type: String, enum: ['home_visit', 'on_road_breakdown'], default: 'home_visit' },
    coordinates: {
      lat: { type: Number },
      lng: { type: Number },
    },
    status: {
      type: String,
      enum: ['pending', 'assigned', 'on_the_way', 'in_progress', 'completed', 'cancelled'],
      default: 'assigned',
    },
    paymentMethod: { type: String, default: 'UPI' },
    paymentStatus: { type: String, enum: ['pending', 'paid', 'refunded'], default: 'paid' },
    discount: { type: Number, default: 0 },
    couponCode: { type: String, default: '' },
  },
  { timestamps: true }
);
export const Booking = mongoose.model('Booking', bookingSchema);

// 7. Payment Schema
const paymentSchema = new mongoose.Schema(
  {
    orderId: { type: String },
    bookingId: { type: String, required: true },
    totalAmount: { type: Number, required: true },
    platformFee: { type: Number, default: 25 },
    providerPayout: { type: Number, required: true },
    method: { type: String, default: 'UPI' },
    transactionId: { type: String },
    discount: { type: Number, default: 0 },
    couponCode: { type: String, default: '' },
    status: { type: String, enum: ['success', 'pending', 'refunded', 'failed'], default: 'success' },
    refundId: { type: String },
    refundAmount: { type: Number },
    refundReason: { type: String },
    refundedAt: { type: Date },
    paidAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);
export const Payment = mongoose.model('Payment', paymentSchema);

// 8. Review Schema
const reviewSchema = new mongoose.Schema(
  {
    bookingId: { type: String, required: true },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String },
    userName: { type: String, default: 'Verified Customer' },
    serviceName: { type: String },
  },
  { timestamps: true }
);
export const Review = mongoose.model('Review', reviewSchema);

// 9. Setting Schema (Dynamic Platform Fee)
const settingSchema = new mongoose.Schema(
  {
    key: { type: String, required: true, unique: true },
    value: { type: mongoose.Schema.Types.Mixed, required: true },
    description: { type: String },
  },
  { timestamps: true }
);
export const Setting = mongoose.model('Setting', settingSchema);

// 10. Notification Schema (FCM & In-app alerts)
const notificationSchema = new mongoose.Schema(
  {
    recipientPhone: { type: String, required: true },
    title: { type: String, required: true },
    message: { type: String, required: true },
    type: {
      type: String,
      enum: ['booking_created', 'provider_assigned', 'on_the_way', 'in_progress', 'completed', 'cancelled', 'job_alert'],
      default: 'job_alert',
    },
    bookingId: { type: String },
    isRead: { type: Boolean, default: false },
  },
  { timestamps: true }
);
export const Notification = mongoose.model('Notification', notificationSchema);

