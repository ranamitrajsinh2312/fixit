# FixIt – Home Services App: Phase-wise Workflow

Home repair marketplace: user selects a **city**, picks a service (Electrician, Gas Repair, Furniture/Carpenter, Plumber), books a slot and pays **service charge + ₹25 platform fee**.

**Stack:** Flutter (app) • Node.js/Express (API) • MongoDB Atlas (DB) • Firebase Auth/FCM • Razorpay (payments)

## Phase 1 – UI Only ✅ (Completed & Verified)
- Screens: Splash → Select City → Home (categories) → Category services → Service detail → Schedule → Checkout (₹25 fee) → Success; Bookings tab; Profile tab.
- All data is mock, in `lib/data.dart` (`platformFee = 25`).
- Verified with `flutter analyze` (0 issues) and `flutter test` (all tests passing).
- Bonus screens included: Technician portal (`servicer_screen.dart`) and Admin analytics panel (`admin_panel_screen.dart`).

## Phase 2 – Backend & MongoDB ✅ (Implemented & Tested)
- Set up Express + MongoDB Atlas + Mongoose in `backend/`.
- Collections: `users`, `cities`, `categories`, `services` (cityId, categoryId, price), `providers`, `bookings`, `payments`, `reviews`, and `settings` (`backend/src/models/index.js`).
- APIs:
  - `GET /api/cities`
  - `GET /api/categories?city=`
  - `GET /api/services?category=&city=&q=`
  - `GET /api/services/:id`
  - `POST /api/bookings` (auto-assign technician, dynamic platform fee calculation)
  - `GET /api/bookings/me?phone=`
  - `GET /api/bookings/:id`
  - `PATCH /api/bookings/:id/status`
  - `GET /api/settings/platformFee` & `PUT /api/settings/platformFee` (dynamic platform fee in DB)
  - `GET /api/providers` & `PATCH /api/providers/:id/status`
  - `GET /api/reviews` & `POST /api/reviews`
  - `GET /api/users/profile` & `PUT /api/users/profile`
  - `GET /api/admin/analytics`
- Database seeder (`backend/src/scripts/seed.js`) with 12 cities, 16 categories, 70+ services, providers, bookings, reviews, and dynamic settings.
- Automated API test suite (`backend/test/api.test.js`) executed with `npm test` (12/12 tests passing).

## Phase 3 – Auth & Flutter integration ✅ (Completed & Verified)
- Phone OTP login with JWT token issuance (`backend/src/routes/authRoutes.js`, `backend/src/middleware/auth.js`).
- Flutter `LoginScreen` (`lib/screens/login_screen.dart`) with Phone OTP verification, state updates, and test code (`123456`) support.
- API service layer (`lib/services/api_service.dart`) connecting Flutter directly to the Express backend with graceful offline fallback.
- Reactive state management with `Provider` (`AuthProvider` and `AppServicesProvider`).
- Local persistence with `SharedPreferences` (`lib/services/storage_service.dart`):
  - Persists and auto-routes to selected city across app restarts (`splash_screen.dart`).
  - Persists JWT authentication tokens and customer phone numbers.
  - Saved addresses CRUD management in `profile_screen.dart`.
- Full-stack verification: `flutter analyze` (0 issues), `flutter test` (100% passed), `npm test` (100% passed).

## Phase 4 – Booking & Provider assignment ✅ (Completed & Verified)
- Comprehensive Lifecycle Transitions: `pending → assigned → on_the_way → in_progress → completed / cancelled`.
- Provider App / Servicer Panel (`lib/screens/servicer_screen.dart`):
  - Online/Offline toggle with real-time status update to backend (`PATCH /api/providers/:id/status`).
  - Interactive KYC verification dialog with Aadhaar number update and verified badge (`PATCH /api/providers/:id/kyc`).
  - Live broadcast job pool with "⚡ Accept Job Order" button (`POST /api/bookings/:id/accept`).
  - Step-by-step job progress stepper advancing orders (`Upcoming/assigned → On the way → In progress → Completed`).
  - Dynamic earnings calculations and instant bank withdrawal trigger.
- Customer Booking Experience (`lib/screens/bookings_screen.dart`):
  - Material 3 live status stepper tracking all 4 stages (`Assigned` → `On Way` → `In Progress` → `Done`).
  - Dynamic contextual alerts ("Specialist assigned", "Specialist on the way", "Work in progress").
  - Seamless cancellation synchronized with backend API (`ApiService.instance.updateBookingStatus`).
- Backend Auto-Assignment & Notification Engine:
  - `POST /api/bookings`: Auto-assigns nearest verified online provider matching city & service category.
  - Notification dispatch service (`backend/src/services/notificationService.js`) for push and in-app alerts.
  - Job feeds (`GET /api/providers/:id/jobs`) segmented by assigned, available broadcast, and completed.
- Full-stack Verification: Automated test suite in `backend/test/api.test.js` executed with `npm test` (18/18 tests passing).

### Extension: On-Road Breakdown, Generic Mechanic & Emergency Locksmith ✅
- **On-Road Mechanic & RSA (`on_road_mechanic`)**: Bike/Car breakdowns, on-spot puncture, jump-start, emergency fuel delivery, towing, key lockout.
- **General Mechanic & Tools (`generic_mechanic`)**: Water pump/motor fix, generator/engine service, spot welding/grill repair, rolling shutter repair, sewing machine fix, power tools.
- **Emergency Locksmith (`emergency_locksmith`)**: Jammed door unlock, safe/cupboard locker fix, smart digital lock reset, doorstep duplicate key cutting.
- **Location-Based Breakdown Pinning**: In `booking_screen.dart`, added `On-Road (GPS)` address selector with automated road pinpointing and rapid dispatch notice.
- **Home Screen & Category Filtering**: Added dedicated **"24x7 Emergency RSA"** hero carousel banner and quick category filter tab.

## Phase 5 – Payments & Fees ✅ (Completed & Verified)
- **Fee Model & Pricing Architecture**:
  - Total = Service Labor Quote + Dynamic Platform Fee (₹25 from DB/fallback) − Coupon Discount.
  - Transparent Split: Technician keeps 100% of the service charge for their labor; platform retains the ₹25 booking fee.
- **Backend Razorpay Gateway APIs (`backend/src/routes/apiRoutes.js`)**:
  - `POST /api/payments/create-order`: Computes service price, fee, coupon deductions (`FIXIT50`, `WAIVEFEE`, `FIRST100`), generates unique `orderId`.
  - `POST /api/payments/verify`: Validates signature/txn, upserts `Payment` record, links with `Booking`, updates `paymentStatus: 'paid'`.
  - `POST /api/payments/refund`: Validates refund eligibility, processes 100% online payment refund, generates `refundId`, marks `Booking` and `Payment` as `refunded`.
  - `GET /api/payments/:bookingId`: Returns complete itemized receipt and payout summary.
  - `POST /api/coupons/validate`: Real-time coupon validity checker.
- **Mongoose Data Models (`backend/src/models/index.js`)**:
  - Enriched `Payment` and `Booking` schemas with `orderId`, `discount`, `couponCode`, `refundId`, `refundAmount`, `refundReason`, `refundedAt`, `paidAt`.
- **Flutter Checkout Experience (`lib/screens/checkout_screen.dart`)**:
  - Interactive payment selector:
    - **UPI**: Google Pay, PhonePe, Paytm, BHIM, or custom UPI ID (VPA) with sheet selector.
    - **Cards**: Interactive Credit/Debit Card modal with virtual gradient card visualizer, number masking, expiry and CVV.
    - **Net Banking**: HDFC, SBI, ICICI, Axis, Kotak.
    - **Cash after service**: Clear breakdown with ₹0 advance payment notice.
  - Coupon Engine: Real-time validation for `FIXIT50` (₹50 discount) & `WAIVEFEE` (zero platform fee) with quick-action chips.
  - Interactive simulated payment gateway progress dialog ("Securing Transaction...", "Verifying Razorpay...").
- **Order Receipt & Tax Invoice (`lib/screens/success_screen.dart`)**:
  - Prominent verified payment status pill with payment method & transaction ref ID.
  - Itemized fee breakdown (labor quote, ₹25 platform fee, coupon savings, total paid).
  - "Download Official Tax Invoice" simulation action.
- **Cancellation & Instant Refund Workflow (`lib/screens/bookings_screen.dart`)**:
  - Automatically identifies online-paid bookings upon cancellation.
  - Displays instant 100% refund assurance banner.
  - Triggers `ApiService.instance.requestRefund` and updates local & remote booking state with refund ID.
  - Status tracker badge displays green refund confirmation with transaction reference.
- **Full-Stack Verification**:
  - Node.js backend: 26 / 26 tests passed (`npm test`).
  - Dart static analysis: 0 issues (`dart-mcp-server` `analyze_files`).
  - Flutter tests: All test suites passed (`flutter test`).

## Phase 6 – Ratings, Admin Web Panel & Polish ✅ (Completed & Verified)
- **Ratings & Reviews System**:
  - Interactive star rating modal (1–5 gold stars) on completed bookings in `bookings_screen.dart`.
  - Feedback chips ("⚡ Fast Arrival", "🔧 Flawless Repair", "😊 Polite Pro", "🧼 Cleaned Up Area", "💯 Honest Pricing") and custom commentary.
  - Submissions synchronized with backend `POST /api/reviews` and cached locally with a verified `Reviewed ★` status badge.
  - Instant **"🔁 Rebook"** 1-click scheduling action for completed services.
- **Admin Management Console (`admin_panel_screen.dart`)**:
  - 5-tab responsive management dashboard:
    1. **Overview & Live Sync**: Dynamic GMV, platform fees, completed orders count, active technician count, and overall average star rating synced with `GET /api/admin/analytics`.
    2. **Bookings Moderation**: Filter orders by status (`All`, `Upcoming`, `Completed`, `Cancelled`) with one-touch `Mark Done` completion.
    3. **Technicians & KYC**: View partner network and perform live KYC verification/rejection via `POST /api/admin/providers/:id/approve-kyc`.
    4. **Catalog & Fees**: Dynamic platform fee adjustment via `PUT /api/settings/platformFee`, service base price modifier via `PATCH /api/admin/services/:id/price`, and new city onboarding via `POST /api/admin/cities`.
    5. **Reviews Feed**: Customer feedback feed displaying ratings, verified customer badges, service tags, and dates.
- **Trilingual Localization Engine (`app_strings.dart`)**:
  - Full trilingual support for **English 🇬🇧**, **ગુજરાતી 🇮🇳**, and **हिंदी 🇮🇳**.
  - In-app language switcher modal accessible from `profile_screen.dart` with instant UI updates across the entire app.
- **Backend Analytics & Admin APIs (`backend/src/routes/apiRoutes.js`)**:
  - `GET /api/admin/analytics` (aggregates GMV, fees, provider payouts, dynamic average rating).
  - `POST /api/admin/cities` (upserts new operational hub into `City` collection).
  - `PATCH /api/admin/services/:id/price` (updates service catalog pricing).
  - `POST /api/admin/providers/:id/approve-kyc` (updates KYC status and fires push notification).
  - `GET /api/reviews` & `POST /api/reviews` (handles review moderation and creation).
- **Full-Stack Verification**:
  - Node.js backend: **31 / 31 tests passed (100%)** (`npm test`).
  - Dart static analysis: **0 issues / No issues found!** (`flutter analyze`).
  - Flutter tests: **All test suites passed (100%)** (`flutter test`).

## Phase 7 – Testing & Launch
- Unit/widget tests, API tests, beta with 1 city (e.g. Rajkot), crash reporting (Crashlytics).
- Play Store release → expand city by city.
