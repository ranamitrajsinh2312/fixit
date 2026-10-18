# FixIt – Complete Home & On-Demand Services Marketplace
## System Architecture, Technical Specification & System Improvements

---

## 1. Executive Overview

**FixIt** is a full-stack, hyper-local on-demand services marketplace and roadside assistance ecosystem built to connect urban households, vehicle owners, and commercial properties with verified local specialists.

### Core Value Proposition
- **Transparent Pricing Model:** Customers pay the transparent service quote + a flat **₹25 platform fee**. Technicians retain **100%** of their quoted labor payout with **0% hidden commission cuts**.
- **Dual Fulfillment Models:**
  1. **⚡ Blinkit-Style Instant Dispatch (15–30 Mins):** Rapid on-demand emergency response for vehicle breakdowns, lockouts, gas leaks, electrical short-circuits, and pipe bursts.
  2. **📅 Flexible Custom Scheduling:** Advanced multi-mode calendar booking with exact-minute selection, 2-hour slots, or broad half-day flexible windows.
- **Location-Based Roadside Assistance (RSA):** Precision GPS and landmark pinning for stranded motorists on city ring roads and highway bypasses.
- **Dedicated Technician Operating Portal:** In-app servicer portal with live job radar, broadcast job acceptance, KYC validation, order lifecycle stepper, and instant bank payout withdrawal.

---

## 2. Backend Link & Network Configuration

The FixIt API server is powered by **Node.js, Express, and Mongoose (MongoDB)**. It features cross-origin support (CORS), JWT authentication, dynamic platform fee configuration, and graceful offline fallback handling.

### Base URLs by Target Environment

| Environment | Backend Base URL | Purpose / Device Target |
| :--- | :--- | :--- |
| **Web Browser / Chrome** | `http://localhost:5000/api` | Flutter Web, Chrome debug session, Swagger / Postman |
| **Android Emulator** | `http://10.0.2.2:5000/api` | Standard Android Studio Emulator loopback address |
| **Physical Phone (Wi-Fi)** | `http://<YOUR_LAN_IP>:5000/api` | Real Android / iOS device over local Wi-Fi (e.g. `192.168.1.15:5000`) |
| **Production Cloud** | `https://api.fixit-services.com/api` | Deployed backend (Render, AWS, DigitalOcean, Railway) |

> **Automated URL Resolver:** Defined in [`fixit/lib/core/constants/api_constants.dart`](file:///d:/projects/ServeHome/fixit/lib/core/constants/api_constants.dart):
> Automatically switches between `http://localhost:5000/api` and `http://10.0.2.2:5000/api` depending on runtime platform (`kIsWeb` vs `TargetPlatform.android`).

### Core Health & Root Endpoints
- **Root API Metadata:** `GET http://localhost:5000/`
- **Health Check:** `GET http://localhost:5000/api/health`
- **Dynamic Fee Config:** `GET http://localhost:5000/api/settings/platformFee`

### Running the Backend Locally
```bash
cd backend
npm install
npm run dev      # Runs with nodemon on port 5000
npm run seed     # Seeds 12 cities, 19 categories, 85+ services, providers & settings
npm test         # Runs automated 18-test suite (node --test test/api.test.js)
```

---

## 3. Complete 19-Category Service Catalog

The platform encompasses **19 diverse categories** and **85+ standardized services**, including home repairs, vehicle care, on-road mechanical assistance, and emergency access:

### 🚨 Emergency & On-Road Breakdown (Rapid Dispatch)
1. **On-Road Mechanic & RSA (`on_road_mechanic`)**:
   - *Bike on-road breakdown (₹199)*: Clutch cable, chain off, spark plug, minor stalling fix on-spot.
   - *Car on-road breakdown (₹399)*: Radiator overheating, fan belt slip, alternator, starter motor tap.
   - *Battery jump-start & boost (₹249)*: 12V/24V heavy-duty booster cables & voltage testing.
   - *On-spot tyre puncture (₹179)*: Tubeless strip seal, spare wheel (stepney) change, air top-up.
   - *Emergency fuel delivery (₹199)*: 3L–5L Petrol or Diesel canister delivered to stranded spot.
   - *Vehicle towing service (₹899)*: Flatbed or hydraulic wheel-lift towing to garage or residence.
   - *Key lockout assistance (₹449)*: Safe non-destructive air-wedge vehicle door unlocking.
2. **General Mechanic & Tools (`generic_mechanic`)**:
   - *Water pump & motor repair (₹349)*: Submersible/monoblock, capacitor, impeller, coil winding.
   - *Portable generator repair (₹499)*: Engine oil flush, carburetor clean, pull-starter cord fix.
   - *Spot welding & metal repair (₹399)*: Gate hinge welding, latch fixing, metal grill railing patch.
   - *Commercial rolling shutter repair (₹499)*: Spring tensioning, gear lubrication, lock repair.
   - *Sewing machine repair (₹249)*: Needle timing, motor belt replacement, tension adjuster.
   - *Power tools service (₹299)*: Drill machine, angle grinder, cutter & pressure washer repair.
3. **Emergency Locksmith (`emergency_locksmith`)**:
   - *Emergency door unlock (₹299)*: Jammed latch opening, deadbolt unlock, broken key extraction.
   - *Cupboard & safe locker fix (₹399)*: Godrej lever repair, locker key fitting, safe dial reset.
   - *Smart digital lock reset (₹499)*: Biometric, PIN pad reprogramming & RFID master card sync.
   - *Duplicate key cutting (₹199)*: Computerized laser-cut duplicate keys cut at doorstep.

### 🏠 Essential Home Infrastructure & Repairs
4. **Electrician (`electrician`)**: Fan repair (₹199), Switch & socket (₹149), Wiring & MCB (₹299), Light fitting (₹179), Inverter & battery (₹399).
5. **Plumber (`plumber`)**: Tap & mixer (₹149), Pipe leakage (₹249), Blockage clearing (₹299), Tank cleaning (₹599), Bathroom fittings (₹349).
6. **Gas Repair (`gas_repair`)**: Stove repair (₹249), Gas leak check (₹299), Pipe installation (₹499), Gas geyser repair (₹399).
7. **Carpenter / Furniture (`furniture`)**: Door & lock repair (₹249), Bed / sofa repair (₹399), Furniture assembly (₹349), Modular kitchen fix (₹599), Curtain rod fitting (₹199).
8. **AC Repair & HVAC (`ac_repair`)**: AC jet wash service (₹499), Refrigerant gas refill (₹1499), AC installation (₹999), AC uninstallation (₹499).
9. **Appliance Repair (`appliance_repair`)**: Washing machine (₹399), Refrigerator (₹399), Microwave/oven (₹299), Electric geyser (₹349), TV repair (₹399).
10. **RO / Water Purifier (`ro_purifier`)**: RO service & TDS check (₹299), Filter cartridge change (₹599), RO installation (₹499).
11. **Painting & Waterproofing (`painting`)**: Room painting (₹1999), Full home painting (₹6999), Waterproofing (₹2499), Wall touch-up (₹899).
12. **Mason & Civil Works (`mason_civil`)**: Tile fitting (₹799), Wall plaster crack fix (₹499), Bathroom renovation (₹3499), False ceiling repair (₹1899).
13. **CCTV & Smart Security (`cctv_security`)**: CCTV installation (₹699), CCTV repair (₹399), Video door phone (₹899), Smart lock installation (₹999).
14. **Mobile & Computer (`mobile_laptop`)**: Screen replacement (₹1299), Mobile battery (₹699), Laptop service & SSD upgrade (₹799), Wi-Fi router setup (₹299).

### 🧼 Hygiene, Logistics & Lifestyle
15. **Home Deep Cleaning (`home_cleaning`)**: Full home deep clean (₹1499), Kitchen degreasing (₹799), Bathroom sanitation (₹499), Sofa & carpet shampoo (₹699), Tank wash (₹699).
16. **Pest Control (`pest_control`)**: Cockroach odorless gel (₹599), Termite drill-fill-seal (₹1199), Mosquito fogging (₹499), Bed bug eradication (₹899).
17. **Packers & Movers (`packers_movers`)**: 1 BHK shifting (₹3999), 2-3 BHK relocation (₹6999), Bike/car enclosed carrier transport (₹2499), Mini truck hire (₹1199).
18. **Vehicle Care (`vehicle_care`)**: Bike doorstep tune-up (₹499), Car foam wash & polish (₹399), Battery jump-start (₹249), Puncture repair (₹149).
19. **Salon & Wellness (`salon_wellness`)**: Men's haircut & massage (₹199), Women's salon package (₹599), Full body therapy (₹899), Mehendi artist (₹499).

---

## 4. Key Architectural Improvements Built

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FIXIT CLIENT APPLICATION                          │
│                                                                             │
│  ┌───────────────────────┐  ┌──────────────────────┐  ┌──────────────────┐  │
│  │   Customer App        │  │   Technician Portal  │  │   Admin Console  │  │
│  │   - Instant & Schedule│  │   - Job Radar / Feed │  │   - Live Metrics │  │
│  │   - 19 Categories     │  │   - 4-Stage Stepper  │  │   - Fee Control  │  │
│  │   - Status Tracker    │  │   - KYC & Earnings   │  │   - Cities & DB  │  │
│  └───────────┬───────────┘  └──────────┬───────────┘  └────────┬─────────┘  │
└──────────────┼─────────────────────────┼───────────────────────┼────────────┘
               │                         │                       │
               ▼                         ▼                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           EXPRESS REST BACKEND                              │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ Routes: /auth, /cities, /categories, /services, /bookings, /providers │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │ Middlewares: JWT Auth, CORS, Centralized Error Handling, Fee Engine   │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │ Services: Notification Dispatch (FCM & In-App), Auto-Assignment       │  │
│  └───────────────────────────────────┬───────────────────────────────────┘  │
└──────────────────────────────────────┼──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MONGODB ATLAS DATABASE                              │
│                                                                             │
│   cities • categories • services • users • providers • bookings             │
│   payments • reviews • settings • notifications                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### A. ⚡ Blinkit-Style Instant Quick Commerce Dispatch
- **Immediate Response Window:** When a customer has an emergency breakdown or lockout, selecting `⚡ Instant (15-30 Mins)` skips scheduling.
- **Priority Broadcast:** Instantly broadcasts the request to all verified providers active in that city within a 5–10 km radius.
- **Estimated Arrival Clock:** Displays dynamic expected arrival windows (e.g., *Arrives within ~25 mins*).
- **Zero Surge Guarantee:** Instant dispatch retains the standard ₹25 platform fee with no surge pricing penalties.

### B. 📅 Flexible Multi-Mode Scheduling Engine
- **Calendar Date Picker (`showDatePicker`):** Allows selecting any date up to 60 days in advance.
- **3 Time Modes:**
  1. *2-Hour Fixed Window:* Standard brackets (`9 AM - 11 AM`, `11 AM - 1 PM`, etc.).
  2. *Exact Custom Minute (`showTimePicker`):* Pick exact arrival time (e.g., `11:45 AM` or `3:30 PM`).
  3. *Flexible Half-Day Windows:* `Morning (9 AM - 1 PM)`, `Afternoon (1 PM - 5 PM)`, `Evening (5 PM - 9 PM)`, `Anytime Today (9 AM - 8 PM)`.
- **Special Instruction Notes:** Allows customers to specify gate codes, landmarks, or special access instructions directly passed to the technician.

### C. 📍 Location-Based Breakdown Pinning
- **GPS / Roadside Option:** Dedicated `On-Road (GPS)` address tag for motorists stranded on highways, bypasses, or city intersections.
- **Roadside Landmark Input:** Supports pinpointing bypass junctions, highway mile markers, and fuel stations.

### D. 🛠️ Provider App & Lifecycle Management ([`servicer_screen.dart`](file:///d:/projects/ServeHome/fixit/lib/screens/servicer_screen.dart))
- **Live Job Broadcast Feed:** Technicians see unassigned open jobs in their trade category and can tap **"Accept Job Order"** (`POST /api/bookings/:id/accept`).
- **Interactive 4-Stage Stepper:**
  $$\text{Upcoming / Assigned} \longrightarrow \text{On the Way} \longrightarrow \text{In Progress} \longrightarrow \text{Completed}$$
- **Automatic Earnings Payout:** Completing a task immediately credits the labor price to the technician's balance and increments completed job metrics.
- **Aadhaar / National ID KYC Modal:** In-app verification submission and badge display (`PATCH /api/providers/:id/kyc`).
- **Online / Offline Toggle:** Switch technician radar visibility (`PATCH /api/providers/:id/status`).

### E. 📋 Customer Tracking Stepper ([`bookings_screen.dart`](file:///d:/projects/ServeHome/fixit/lib/screens/bookings_screen.dart))
- **Live Visual Progress Bar:** Material 3 stepper showing stages: `Assigned` $\rightarrow$ `On Way` $\rightarrow$ `In Progress` $\rightarrow$ `Done`.
- **Contextual Status Pills:** *"🛵 Specialist is on the way"*, *"🔧 Work currently in progress"*.
- **Integrated Remote Cancellation:** Cancels the order in local state and updates remote database (`PATCH /api/bookings/:id/status`).

### F. 💳 Phase 5: Payments, Razorpay Gateway & Cancellation Refund Flow
- **Transparent Pricing Formula:**
  $$\text{Total Payable} = \text{Service Quote (Labor)} + \text{Dynamic Platform Fee (₹25)} - \text{Discount}$$
  - **100% Labor Preservation:** Verified technicians retain 100% of the service charge quote; FixIt platform retains the ₹25 booking commission.
- **Razorpay Payment Engine (`POST /api/payments/create-order`, `POST /api/payments/verify`):**
  - UPI Apps & VPA: Google Pay, PhonePe, Paytm, BHIM, and custom Virtual Payment Address (`@okhdfcbank`).
  - Credit & Debit Cards: 16-digit card input with live card visualizer, Luhn check, expiry, and CVV.
  - Net Banking: Major Indian banks (HDFC, SBI, ICICI, Axis, Kotak).
  - Cash on Service: Technician collects cash or on-spot UPI upon satisfactory job completion.
- **Dynamic Coupon Discounts (`POST /api/coupons/validate`):**
  - `FIXIT50`: ₹50 instant deduction.
  - `WAIVEFEE`: 100% waiver of the platform fee (₹25 off).
  - `FIRST100`: ₹100 discount on orders $\ge$ ₹400.
- **Cancellation & Instant Refund Engine (`POST /api/payments/refund`):**
  - Online bookings cancelled prior to technician arrival trigger immediate 100% source-account reversal.
  - Tracks unique `refundId` (`rfnd_...`) and displays green refund confirmation badges across customer bookings.

---

## 5. MongoDB Database Schemas (10 Collections)

All models are defined in [`backend/src/models/index.js`](file:///d:/projects/ServeHome/backend/src/models/index.js):

1. **`cities`**: `name` (unique), `state`, `isActive`.
2. **`categories`**: `id` (slug), `name`, `iconName`, `colorHex`, `isActive`.
3. **`services`**: `id`, `categoryId`, `cityId`, `name`, `desc`, `price`, `included[]`, `rating`, `reviewsCount`.
4. **`users`**: `name`, `phone` (unique), `role` (`customer`/`provider`/`admin`), `city`, `savedAddresses[{ tag, address, isDefault }]`.
5. **`providers`**: `name`, `phone`, `categoryId`, `categoryName`, `city`, `kycStatus` (`pending`/`verified`/`rejected`), `isOnline`, `rating`, `completedJobs`, `totalEarnings`, `aadhaarNo`, `experienceYears`.
6. **`bookings`**: `bookingId`, `customerName`, `customerPhone`, `providerId`, `providerName`, `serviceId`, `serviceName`, `categoryName`, `price`, `platformFee` (default 25), `discount`, `couponCode`, `totalAmount`, `address`, `city`, `dateTime`, `bookingType` (`home_visit`/`on_road_breakdown`), `coordinates{ lat, lng }`, `status` (`pending`/`assigned`/`on_the_way`/`in_progress`/`completed`/`cancelled`), `paymentMethod`, `paymentStatus` (`pending`/`paid`/`refunded`).
7. **`payments`**: `orderId`, `bookingId`, `totalAmount`, `platformFee`, `providerPayout`, `discount`, `couponCode`, `method`, `transactionId`, `status` (`success`/`pending`/`refunded`/`failed`), `refundId`, `refundAmount`, `refundReason`, `refundedAt`, `paidAt`.
8. **`reviews`**: `bookingId`, `rating` (1–5), `comment`, `userName`, `serviceName`.
9. **`settings`**: `key` (e.g. `platformFee`), `value` (e.g. `25`), `description`.
10. **`notifications`**: `recipientPhone`, `title`, `message`, `type`, `bookingId`, `isRead`.

---

## 6. Complete REST API Reference

### Authentication & Users
- `POST /api/auth/send-otp`: Sends demo verification OTP (`123456`).
- `POST /api/auth/verify-otp`: Validates OTP, issues signed JWT token, returns user profile.
- `GET /api/users/profile?phone=`: Returns user details and saved address book.
- `PUT /api/users/profile`: Updates name, primary city, and adds/edits saved addresses.

### Catalog & Cities
- `GET /api/cities`: List of 12 operational cities.
- `GET /api/categories?city=`: Category roster filtered by city.
- `GET /api/services?category=&city=&q=`: Service search by trade, city, or query string.
- `GET /api/services/:id`: Detailed service specifications and inclusions.

### Bookings & Lifecycle
- `POST /api/bookings`: Creates booking, auto-assigns nearest online provider, records payment.
- `GET /api/bookings`: Filterable by status, city, or provider.
- `GET /api/bookings/me?phone=`: Authenticated customer's booking history.
- `GET /api/bookings/:id`: Single booking status lookup.
- `POST /api/bookings/:id/accept`: Technician accepts open broadcast job.
- `PATCH /api/bookings/:id/status`: Transitions lifecycle (`assigned → on_the_way → in_progress → completed → cancelled`), credits technician earnings on completion.

### Providers & Technicians
- `GET /api/providers?city=&categoryId=`: List verified providers.
- `POST /api/providers/register`: Onboard new partner with trade, city, experience, Aadhaar.
- `GET /api/providers/me?phone=`: Fetch technician profile and earnings balance.
- `GET /api/providers/:id/jobs`: Segmented feeds: `assigned`, `available` broadcast pool, `completed`.
- `PATCH /api/providers/:id/kyc`: Update KYC status (`verified`/`pending`).
- `PATCH /api/providers/:id/status`: Toggle `isOnline` radar.

### Admin, Settings & Alerts
- `GET /api/settings/platformFee`: Fetches active platform fee (₹25).
- `PUT /api/settings/platformFee`: Admin updates fee setting dynamically.
- `GET /api/admin/analytics`: Aggregate metrics (total bookings, gross GMV, platform revenue, payouts).
- `GET /api/notifications?phone=`: Returns in-app and push notification feed.
- `PATCH /api/notifications/:id/read`: Marks notification as read.

---

## 7. Upcoming Phase: Ready-to-Go Payment Gateway (Phase 5)

Once the core service roster and workflow are finalized, **Phase 5** will seamlessly plug into the payment pipeline:

### Payment Architecture Plan
1. **Razorpay Standard Checkout:**
   - Client creates Razorpay Order via `POST /api/payments/razorpay/order`.
   - Razorpay Checkout modal opens with UPI (GPay, PhonePe, Paytm, BHIM), Credit/Debit Cards, NetBanking.
   - Client sends `razorpay_payment_id`, `razorpay_order_id`, `razorpay_signature` to `POST /api/payments/razorpay/verify`.
2. **Transparent Fee Breakdown:**
   - Subtotal: Service Price (e.g. ₹199).
   - Platform Fee: ₹25.
   - Total Billed: ₹224.
   - Provider Payout: ₹199.
   - Platform Net Revenue: ₹25.
3. **Cash After Service / Pay on Completion:**
   - Supported option for customers preferring to pay post-completion.
4. **Automated Refund Pipeline:**
   - When a booking with `paymentStatus: 'paid'` is cancelled before technician dispatch, triggers Razorpay refund API and updates `payments` collection to `refunded`.

---

## 8. Test Verification & Code Quality

Both the Flutter client and the Node.js backend have been strictly validated with 0 warnings:

| Suite | Runner / Command | Status |
| :--- | :--- | :--- |
| **Backend Test Suite** | `npm test` (Node.js test runner) | **18 / 18 tests passed (100%)** |
| **Dart Static Analysis** | `dart-mcp-server` `analyze_files` / `flutter analyze` | **No errors, 0 warnings** |
| **Flutter Widget & Unit Tests** | `flutter test` | **All tests passed (100%)** |
