# FixIt – Backend API & MongoDB (Phase 2)

Node.js / Express REST API and MongoDB Mongoose layer powering the FixIt Home Services platform.

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment (`.env`)
Create or edit `.env` in the `backend` folder:
```env
PORT=5000
NODE_ENV=development
# For MongoDB Atlas:
MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.mongodb.net/fixit_db?retryWrites=true&w=majority
# Or for local MongoDB:
# MONGODB_URI=mongodb://127.0.0.1:27017/fixit_db
DEFAULT_PLATFORM_FEE=25
CORS_ORIGIN=*
```

### 3. Seed Database
Seeds 12 cities, 16 service categories, 70+ repair services, verified technicians, sample bookings, and the dynamic ₹25 platform fee:
```bash
npm run seed
```

### 4. Run Server
- **Development (auto-reload on save):**
  ```bash
  npm run dev
  ```
- **Production:**
  ```bash
  npm start
  ```
- **Run Tests:**
  ```bash
  npm test
  ```

---

## 🗄️ Database Collections (`models/index.js`)

| Collection | Model | Description |
|---|---|---|
| `cities` | `City` | Operational cities (Rajkot, Ahmedabad, Surat, Mumbai, etc.) |
| `categories` | `Category` | Service categories (Electrician, Plumber, Gas, Carpenter, AC, etc.) |
| `services` | `Service` | Services with `cityId`, `categoryId`, `price`, descriptions, inclusions |
| `users` | `User` | Customers & admins with phone number, role, saved addresses |
| `providers` | `Provider` | Verified service technicians with KYC status, ratings, online state |
| `bookings` | `Booking` | Service bookings, schedule slot, customer info, technician, ₹25 fee, total |
| `payments` | `Payment` | Payment records, gateway info, platform fee cut, provider payout |
| `reviews` | `Review` | Customer feedback, 1-5 star ratings, comments |
| `settings` | `Setting` | Dynamic configuration (e.g., `platformFee = 25`) editable without app release |

---

## 🌐 API Reference

### Health & Metadata
- `GET /` — API overview and endpoint directory
- `GET /api/health` — Service health status check

### Cities & Categories
- `GET /api/cities` — List all active operating cities
- `GET /api/categories?city={city}` — List categories, optionally filtered to those active in `{city}`

### Services
- `GET /api/services?category={cat}&city={city}&q={search}` — Filter services by category, city, or search term
- `GET /api/services/:id` — Details of an individual service

### Bookings
- `POST /api/bookings` — Create a new booking (auto-fetches dynamic platform fee, auto-assigns technician, records payment)
- `GET /api/bookings?status={status}&city={city}` — List bookings (with status and city filters)
- `GET /api/bookings/me?phone={phone}` — List bookings for current customer
- `GET /api/bookings/:id` — Fetch booking details by ID (e.g. `FX-91204`)
- `PATCH /api/bookings/:id/status` — Update booking status (`pending`, `assigned`, `on_the_way`, `in_progress`, `completed`, `cancelled`)

### Settings (Dynamic Platform Fee)
- `GET /api/settings/platformFee` — Fetch current platform commission fee (default: ₹25)
- `PUT /api/settings/platformFee` — Update platform fee without needing an app release

### Providers & Reviews
- `GET /api/providers?city={city}&categoryId={cat}` — List technicians
- `PATCH /api/providers/:id/status` — Toggle technician online status / KYC
- `GET /api/reviews?serviceName={name}&bookingId={id}` — Get reviews
- `POST /api/reviews` — Submit review and rating

### Users
- `GET /api/users/profile?phone={phone}` — Fetch or create user profile with saved addresses
- `PUT /api/users/profile` — Update customer name, city, and saved addresses

### Admin
- `GET /api/admin/analytics` — Dashboard metrics: booking counts, revenues, platform commissions, payouts
