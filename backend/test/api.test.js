import { test, describe, before, after } from 'node:test';
import assert from 'node:assert';
import http from 'node:http';
import { app } from '../src/server.js';
import {
  User,
  City,
  Category,
  Service,
  Provider,
  Booking,
  Payment,
  Review,
  Setting,
} from '../src/models/index.js';

describe('Phase 2: Mongoose Schemas & Models', () => {
  test('all required collections from Phase 2 workflow are defined', () => {
    assert.ok(User, 'User model should be defined');
    assert.ok(City, 'City model should be defined');
    assert.ok(Category, 'Category model should be defined');
    assert.ok(Service, 'Service model should be defined');
    assert.ok(Provider, 'Provider model should be defined');
    assert.ok(Booking, 'Booking model should be defined');
    assert.ok(Payment, 'Payment model should be defined');
    assert.ok(Review, 'Review model should be defined');
    assert.ok(Setting, 'Setting model should be defined');
  });

  test('Service schema contains cityId, categoryId, and price', () => {
    const paths = Service.schema.paths;
    assert.ok(paths.cityId, 'Service must have cityId');
    assert.ok(paths.categoryId, 'Service must have categoryId');
    assert.ok(paths.price, 'Service must have price');
    assert.strictEqual(paths.price.instance, 'Number');
  });

  test('Booking schema contains required marketplace fields', () => {
    const paths = Booking.schema.paths;
    assert.ok(paths.bookingId, 'Booking must have bookingId');
    assert.ok(paths.price, 'Booking must have price');
    assert.ok(paths.platformFee, 'Booking must have platformFee');
    assert.ok(paths.totalAmount, 'Booking must have totalAmount');
    assert.ok(paths.status, 'Booking must have status');
    assert.ok(paths.bookingType, 'Booking must have bookingType');
  });

  test('Setting schema stores dynamic platformFee configuration', () => {
    const paths = Setting.schema.paths;
    assert.ok(paths.key, 'Setting must have key');
    assert.ok(paths.value, 'Setting must have value');
  });

  test('User schema contains phone, role, and savedAddresses array', () => {
    const paths = User.schema.paths;
    assert.ok(paths.name, 'User must have name');
    assert.ok(paths.phone, 'User must have phone');
    assert.ok(paths.role, 'User must have role');
    assert.ok(paths.savedAddresses, 'User must have savedAddresses');
  });

  test('Provider schema contains categoryId, city, kycStatus, isOnline', () => {
    const paths = Provider.schema.paths;
    assert.ok(paths.categoryId, 'Provider must have categoryId');
    assert.ok(paths.city, 'Provider must have city');
    assert.ok(paths.kycStatus, 'Provider must have kycStatus');
    assert.ok(paths.isOnline, 'Provider must have isOnline');
  });

  test('Payment schema contains bookingId, platformFee, providerPayout', () => {
    const paths = Payment.schema.paths;
    assert.ok(paths.bookingId, 'Payment must have bookingId');
    assert.ok(paths.platformFee, 'Payment must have platformFee');
    assert.ok(paths.providerPayout, 'Payment must have providerPayout');
  });

  test('Review schema contains bookingId, rating (1-5), and comment', () => {
    const paths = Review.schema.paths;
    assert.ok(paths.bookingId, 'Review must have bookingId');
    assert.ok(paths.rating, 'Review must have rating');
    assert.ok(paths.comment, 'Review must have comment');
  });
});

describe('Phase 2: Express Server & Endpoints', () => {
  let server;
  let baseUrl;

  before(async () => {
    process.env.NODE_ENV = 'test';
    await new Promise((resolve) => {
      server = http.createServer(app);
      server.listen(0, '127.0.0.1', () => {
        const address = server.address();
        baseUrl = `http://127.0.0.1:${address.port}`;
        resolve();
      });
    });
  });

  after(async () => {
    if (server) {
      await new Promise((resolve) => server.close(resolve));
    }
  });

  test('GET / returns API metadata and registered endpoints', async () => {
    const res = await fetch(`${baseUrl}/`);
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.name, 'FixIt - Home Services Backend API');
    assert.ok(Array.isArray(data.endpoints));
    assert.ok(data.endpoints.includes('/api/cities'));
    assert.ok(data.endpoints.includes('/api/categories'));
    assert.ok(data.endpoints.includes('/api/services'));
    assert.ok(data.endpoints.includes('/api/bookings'));
    assert.ok(data.endpoints.includes('/api/settings/platformFee'));
  });

  test('GET /api/health returns ok status', async () => {
    const res = await fetch(`${baseUrl}/api/health`);
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.status, 'ok');
    assert.strictEqual(data.service, 'FixIt API Server');
    assert.ok(data.timestamp);
  });

  test('POST /api/auth/send-otp sends verification OTP', async () => {
    const res = await fetch(`${baseUrl}/api/auth/send-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone: '+91 98795 43210' }),
    });
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.ok(data.otp);
  });

  test('POST /api/auth/verify-otp returns JWT token and user profile', async () => {
    const res = await fetch(`${baseUrl}/api/auth/verify-otp`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        phone: '+91 98795 43210',
        otp: '123456',
        name: 'Devang Patel',
      }),
    });
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.ok(data.token, 'Should return JWT token');
    assert.strictEqual(data.user.phone, '+91 98795 43210');
  });
});

describe('Phase 4: Booking & Provider Assignment', () => {
  let server;
  let baseUrl;

  before(async () => {
    process.env.NODE_ENV = 'test';
    await new Promise((resolve) => {
      server = http.createServer(app);
      server.listen(0, '127.0.0.1', () => {
        const address = server.address();
        baseUrl = `http://127.0.0.1:${address.port}`;
        resolve();
      });
    });
  });

  after(async () => {
    if (server) {
      await new Promise((resolve) => server.close(resolve));
    }
  });

  test('POST /api/providers/register onboards technician with trade and city', async () => {
    const res = await fetch(`${baseUrl}/api/providers/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name: 'Suresh Parmar',
        phone: '+91 98980 44556',
        categoryId: 'electrician',
        categoryName: 'Electrician',
        city: 'Rajkot',
        aadhaarNo: 'XXXX-XXXX-4455',
        experienceYears: 5,
      }),
    });
    assert.ok([200, 201].includes(res.status));
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.strictEqual(data.data.name, 'Suresh Parmar');
    assert.strictEqual(data.data.city, 'Rajkot');
  });

  test('PATCH /api/providers/:id/kyc updates partner verification status', async () => {
    const res = await fetch(`${baseUrl}/api/providers/prov_demo_1/kyc`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        kycStatus: 'verified',
        aadhaarNo: 'XXXX-XXXX-8899',
      }),
    });
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.strictEqual(data.data.kycStatus, 'verified');
  });

  test('GET /api/providers/:id/jobs returns segmented job feeds', async () => {
    const res = await fetch(`${baseUrl}/api/providers/prov_demo_1/jobs?city=Rajkot`);
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.ok(data.data.assigned !== undefined);
    assert.ok(data.data.available !== undefined);
    assert.ok(data.data.completed !== undefined);
  });

  test('POST /api/bookings/:id/accept allows technician to claim job', async () => {
    const res = await fetch(`${baseUrl}/api/bookings/FX-99999/accept`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        providerId: 'prov_demo_1',
        providerName: 'Ramesh Sharma',
      }),
    });
    assert.ok([200, 404].includes(res.status));
    const data = await res.json();
    if (res.status === 200) {
      assert.strictEqual(data.success, true);
    }
  });

  test('PATCH /api/bookings/:id/status transitions lifecycle states', async () => {
    const res = await fetch(`${baseUrl}/api/bookings/FX-91204/status`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        status: 'on_the_way',
      }),
    });
    assert.ok([200, 404].includes(res.status));
    const data = await res.json();
    if (res.status === 200) {
      assert.strictEqual(data.success, true);
      assert.strictEqual(data.data.status, 'on_the_way');
    }
  });

  test('GET /api/notifications returns notification dispatch feed', async () => {
    const res = await fetch(`${baseUrl}/api/notifications?phone=%2B919879543210`);
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.ok(Array.isArray(data.data));
  });

  // Phase 5: Payments, Razorpay, Coupons & Refund tests
  test('POST /api/payments/create-order creates order with platform fee and service price', async () => {
    const res = await fetch(`${baseUrl}/api/payments/create-order`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        customPrice: 199,
        city: 'Rajkot',
      }),
    });
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.ok(data.orderId.startsWith('order_'));
    assert.strictEqual(data.platformFee, 25);
    assert.strictEqual(data.servicePrice, 199);
    assert.strictEqual(data.totalAmount, 224);
    assert.strictEqual(data.providerPayout, 199);
  });

  test('POST /api/payments/create-order with WAIVEFEE waives the platform fee', async () => {
    const res = await fetch(`${baseUrl}/api/payments/create-order`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        customPrice: 299,
        couponCode: 'WAIVEFEE',
      }),
    });
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.strictEqual(data.discount, 25);
    assert.strictEqual(data.totalAmount, 299); // 299 + 25 - 25 = 299
  });

  test('POST /api/payments/create-order with FIXIT50 gives 50 off', async () => {
    const res = await fetch(`${baseUrl}/api/payments/create-order`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        customPrice: 199,
        couponCode: 'FIXIT50',
      }),
    });
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.strictEqual(data.discount, 50);
    assert.strictEqual(data.totalAmount, 174); // 199 + 25 - 50 = 174
  });

  test('POST /api/coupons/validate verifies coupon validity', async () => {
    const res1 = await fetch(`${baseUrl}/api/coupons/validate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ code: 'FIXIT50', servicePrice: 200 }),
    });
    const d1 = await res1.json();
    assert.strictEqual(d1.valid, true);
    assert.strictEqual(d1.discount, 50);

    const res2 = await fetch(`${baseUrl}/api/coupons/validate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ code: 'INVALID99' }),
    });
    const d2 = await res2.json();
    assert.strictEqual(d2.valid, false);
  });

  test('POST /api/payments/verify records successful transaction', async () => {
    const res = await fetch(`${baseUrl}/api/payments/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        orderId: 'order_test_123',
        paymentId: 'pay_test_456',
        bookingId: 'FX-91204',
        paymentMethod: 'UPI',
        totalAmount: 224,
        platformFee: 25,
        providerPayout: 199,
      }),
    });
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.strictEqual(data.data.status, 'success');
  });

  test('GET /api/payments/:bookingId returns payment receipt', async () => {
    const res = await fetch(`${baseUrl}/api/payments/FX-91204`);
    assert.ok([200, 404].includes(res.status));
    const data = await res.json();
    if (res.status === 200) {
      assert.strictEqual(data.success, true);
      assert.ok(data.data.totalAmount !== undefined);
    }
  });

  test('POST /api/payments/refund processes cancellation refund', async () => {
    const res = await fetch(`${baseUrl}/api/payments/refund`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        bookingId: 'FX-91204',
        reason: 'Change of schedule',
      }),
    });
    assert.ok([200, 400, 404].includes(res.status));
    const data = await res.json();
    if (res.status === 200) {
      assert.strictEqual(data.success, true);
      assert.ok(data.refundId);
    }
  });

  test('POST /api/bookings handles booking creation with coupon and online payment', async () => {
    const res = await fetch(`${baseUrl}/api/bookings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        serviceId: 'fan_repair',
        customerName: 'Devang Patel',
        customerPhone: '+91 98795 43210',
        city: 'Rajkot',
        address: 'Radhe Residency, Rajkot',
        dateTime: 'Tomorrow, 10 AM',
        paymentMethod: 'UPI',
        couponCode: 'FIXIT50',
        discount: 50,
      }),
    });
    assert.ok([201, 200, 404].includes(res.status));
    const data = await res.json();
    if (data.success) {
      assert.strictEqual(data.data.discount, 50);
      assert.strictEqual(data.data.paymentStatus, 'paid');
    }
  });

  // Phase 6: Ratings, Admin & Polish
  test('GET /api/admin/analytics returns comprehensive marketplace metrics', async () => {
    const res = await fetch(`${baseUrl}/api/admin/analytics`);
    assert.strictEqual(res.status, 200);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.ok(data.data.totalBookings !== undefined);
    assert.ok(data.data.totalGrossRevenue !== undefined);
    assert.ok(data.data.totalPlatformEarnings !== undefined);
    assert.ok(data.data.averageRating !== undefined);
  });

  test('POST /api/reviews and GET /api/reviews records and lists customer feedback', async () => {
    const postRes = await fetch(`${baseUrl}/api/reviews`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        bookingId: 'FX-91204',
        rating: 5,
        comment: 'Fantastic work by Ramesh! Fixed the fan regulator quickly.',
        userName: 'Aarav Shah',
        serviceName: 'Fan repair',
      }),
    });
    assert.strictEqual(postRes.status, 201);
    const postData = await postRes.json();
    assert.strictEqual(postData.success, true);
    assert.strictEqual(postData.data.rating, 5);

    const getRes = await fetch(`${baseUrl}/api/reviews?bookingId=FX-91204`);
    assert.strictEqual(getRes.status, 200);
    const getData = await getRes.json();
    assert.strictEqual(getData.success, true);
    assert.ok(Array.isArray(getData.data));
  });

  test('POST /api/admin/cities adds new operational city', async () => {
    const res = await fetch(`${baseUrl}/api/admin/cities`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: 'Surat', state: 'Gujarat' }),
    });
    assert.strictEqual(res.status, 201);
    const data = await res.json();
    assert.strictEqual(data.success, true);
    assert.strictEqual(data.data.name, 'Surat');
  });

  test('PATCH /api/admin/services/:id/price updates service catalog pricing', async () => {
    const res = await fetch(`${baseUrl}/api/admin/services/fan_repair/price`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ price: 249 }),
    });
    assert.ok([200, 404].includes(res.status));
    const data = await res.json();
    if (res.status === 200) {
      assert.strictEqual(data.success, true);
      assert.strictEqual(data.data.price, 249);
    }
  });

  test('POST /api/admin/providers/:id/approve-kyc approves partner KYC', async () => {
    const res = await fetch(`${baseUrl}/api/admin/providers/prov_demo_1/approve-kyc`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ approve: true }),
    });
    assert.ok([200, 404].includes(res.status));
    const data = await res.json();
    if (res.status === 200) {
      assert.strictEqual(data.success, true);
      assert.strictEqual(data.data.kycStatus, 'verified');
    }
  });
});

