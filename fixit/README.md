# FixIt – Home & On-Demand Services Marketplace

FixIt is a full-stack, hyper-local on-demand home repair and roadside assistance marketplace with transparent pricing (service charge + flat ₹25 platform fee), instant Blinkit-style emergency dispatch, and flexible multi-mode scheduling.

---

## 📚 Master Documentation
- **[System Architecture & Technical Specification](../SYSTEM_ARCHITECTURE.md)**: Full architecture breakdown, backend links, 19 categories, instant dispatch mechanism, MongoDB schemas, and REST API directory.
- **[Phase-wise Workflow Roadmap](./WORKFLOW.md)**: Progress tracking from Phase 1 to Phase 7.

---

## 🚀 Quick Start

### 1. Start Node.js / MongoDB Backend
```bash
cd backend
npm install
npm run dev      # Server starts on http://localhost:5000 (Health: /api/health)
npm run seed     # Seeds 12 cities, 19 categories, 85+ services, providers & settings
npm test         # Runs 18-test automated test suite
```

### 2. Start Flutter App
```bash
cd fixit
flutter pub get
flutter run -d chrome    # Or target android / windows / ios
```

---

## 🌐 Backend Connectivity
- **Web / Chrome / Windows**: `http://localhost:5000/api`
- **Android Emulator**: `http://10.0.2.2:5000/api`
- **Physical Phone over Wi-Fi**: `http://<YOUR_LAN_IP>:5000/api`
