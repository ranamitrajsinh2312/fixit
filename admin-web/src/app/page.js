"use client";

import React, { useState, useEffect, useMemo } from "react";
import {
  LayoutDashboard,
  ClipboardList,
  Flame,
  CreditCard,
  Wallet,
  RotateCcw,
  Tag,
  UserCheck,
  CalendarCheck,
  Package,
  Boxes,
  Sliders,
  MapPin,
  FileText,
  Search,
  RefreshCw,
  Download,
  PlusCircle,
  CheckCircle2,
  XCircle,
  AlertTriangle,
  Star,
  ExternalLink,
  ShieldCheck,
  TrendingUp,
  BadgeIndianRupee,
  Clock,
  Sparkles,
  ChevronRight,
  X,
  FileSpreadsheet,
  ArrowUpRight,
} from "lucide-react";

const API_BASE = "http://localhost:5000/api";

export default function AdminERPConsole() {
  const [activeTab, setActiveTab] = useState("overview");
  const [selectedCity, setSelectedCity] = useState("All Hubs");
  const [searchQuery, setSearchQuery] = useState("");
  const [isSyncing, setIsSyncing] = useState(false);
  const [toastMessage, setToastMessage] = useState(null);

  // Active Modals
  const [showCouponModal, setShowCouponModal] = useState(false);
  const [showCityModal, setShowCityModal] = useState(false);
  const [showInvoiceModal, setShowInvoiceModal] = useState(null); // booking object

  // 1. Executive Analytics
  const [analytics, setAnalytics] = useState({
    totalBookings: 142,
    completedBookings: 118,
    cancelledBookings: 6,
    totalProviders: 32,
    activeProviders: 24,
    totalGrossRevenue: 48950,
    totalPlatformEarnings: 3550,
    totalProviderPayouts: 45400,
    averageRating: 4.88,
  });

  // 2. Global Platform Fee Policy
  const [platformFee, setPlatformFee] = useState(25);
  const [newFeeInput, setNewFeeInput] = useState("25");
  const [autoDispatchRadius, setAutoDispatchRadius] = useState(8);
  const [gstRate, setGstRate] = useState(18);

  // 3. Operational Bookings
  const [bookings, setBookings] = useState([
    {
      id: "FX-91204",
      customerName: "Devang Patel",
      phone: "+91 98795 43210",
      serviceName: "Ceiling Fan Repair",
      categoryName: "Electrician",
      city: "Rajkot",
      address: "Flat 402, Radhe Residency, 150ft Ring Road",
      dateTime: "Today, 11 AM - 1 PM",
      price: 199,
      platformFee: 25,
      totalAmount: 224,
      status: "Upcoming",
      paymentMethod: "UPI (Google Pay)",
      paymentStatus: "paid",
      txnId: "txn_upi_91204_live",
      date: "19/10/2026",
    },
    {
      id: "FX-87341",
      customerName: "Kavita Mehta",
      phone: "+91 98251 98765",
      serviceName: "Tap & mixer replacement",
      categoryName: "Plumber",
      city: "Rajkot",
      address: "B-12, Sunrise Greens, Race Course Road",
      dateTime: "Yesterday, 2 PM - 4 PM",
      price: 149,
      platformFee: 25,
      totalAmount: 174,
      status: "Completed",
      paymentMethod: "Credit Card (HDFC)",
      paymentStatus: "paid",
      txnId: "txn_card_87341_live",
      date: "18/10/2026",
    },
    {
      id: "FX-84992",
      customerName: "Ankit Shah",
      phone: "+91 99090 12345",
      serviceName: "Car Battery Jump-Start (RSA)",
      categoryName: "On-Road Breakdown",
      city: "Ahmedabad",
      address: "Near Iscon Cross Road, SG Highway",
      dateTime: "18/10/2026, Instant Dispatch",
      price: 249,
      platformFee: 25,
      totalAmount: 274,
      status: "Completed",
      paymentMethod: "UPI (PhonePe)",
      paymentStatus: "paid",
      txnId: "txn_upi_84992_live",
      date: "18/10/2026",
    },
    {
      id: "FX-81203",
      customerName: "Sneha Dave",
      phone: "+91 98980 55443",
      serviceName: "On-Spot Bike Tyre Puncture",
      categoryName: "On-Road Breakdown",
      city: "Rajkot",
      address: "Aji Dam Overbridge, National Highway 27",
      dateTime: "Today, Instant Dispatch",
      price: 179,
      platformFee: 25,
      totalAmount: 204,
      status: "On the way",
      paymentMethod: "UPI (Paytm)",
      paymentStatus: "paid",
      txnId: "txn_upi_81203_live",
      date: "19/10/2026",
    },
    {
      id: "FX-78119",
      customerName: "Bhavik Parekh",
      phone: "+91 98791 22334",
      serviceName: "Gas Stove Burner Clean",
      categoryName: "Gas Repair",
      city: "Rajkot",
      address: "Shop 4, Kalawad Road",
      dateTime: "15/10/2026, 9 AM - 11 AM",
      price: 249,
      platformFee: 25,
      totalAmount: 274,
      status: "Cancelled",
      paymentMethod: "Cash after service",
      paymentStatus: "refunded",
      txnId: "txn_cash_78119",
      date: "15/10/2026",
    },
  ]);
  const [bookingFilter, setBookingFilter] = useState("All");

  // 4. Financial Transactions & Ledger
  const [payouts, setPayouts] = useState([
    {
      payoutId: "PO-2026-081",
      providerName: "Ramesh Sharma",
      trade: "Electrician",
      jobsCount: 14,
      amount: 4180,
      bankName: "State Bank of India (SBIN0001234)",
      accountNo: "•••• •••• 4412",
      status: "Pending Disbursement",
      date: "19/10/2026",
    },
    {
      payoutId: "PO-2026-080",
      providerName: "Haresh Solanki",
      trade: "Plumber",
      jobsCount: 9,
      amount: 2390,
      bankName: "HDFC Bank (HDFC0000987)",
      accountNo: "•••• •••• 8891",
      status: "Disbursed",
      date: "18/10/2026",
    },
    {
      payoutId: "PO-2026-079",
      providerName: "Mahesh Chudasama",
      trade: "On-Road Towing & RSA",
      jobsCount: 6,
      amount: 3290,
      bankName: "Bank of Baroda (BARB0RAJKOT)",
      accountNo: "•••• •••• 5510",
      status: "Disbursed",
      date: "17/10/2026",
    },
  ]);

  // 5. Refunds & Reversals Queue
  const [refunds, setRefunds] = useState([
    {
      refundId: "rfnd_88392019",
      bookingId: "FX-78119",
      customerName: "Bhavik Parekh",
      amount: 274,
      reason: "Technician delayed due to heavy rain; customer self-resolved.",
      method: "Original Payment (Card)",
      status: "Processed",
      date: "15/10/2026",
    },
    {
      refundId: "rfnd_91823401",
      bookingId: "FX-73201",
      customerName: "Jayesh Vaghani",
      amount: 224,
      reason: "Duplicate booking by user mistake.",
      method: "UPI (Google Pay)",
      status: "Pending Gateway Settlement",
      date: "18/10/2026",
    },
  ]);

  // 6. Promotional Coupons & Campaigns
  const [coupons, setCoupons] = useState([
    {
      code: "FIXIT50",
      type: "Flat Discount",
      value: "₹50 OFF",
      minOrder: 149,
      uses: 184,
      status: "Active",
      expires: "31/12/2026",
    },
    {
      code: "WAIVEFEE",
      type: "Fee Waiver",
      value: "₹25 Fee 100% OFF",
      minOrder: 199,
      uses: 92,
      status: "Active",
      expires: "30/11/2026",
    },
    {
      code: "FIRST100",
      type: "Welcome Bonus",
      value: "₹100 OFF",
      minOrder: 399,
      uses: 310,
      status: "Active",
      expires: "31/12/2026",
    },
    {
      code: "DIWALI200",
      type: "Festive Promo",
      value: "₹200 OFF",
      minOrder: 999,
      uses: 0,
      status: "Scheduled",
      expires: "15/11/2026",
    },
  ]);
  const [newCouponForm, setNewCouponForm] = useState({
    code: "",
    type: "Flat Discount",
    value: "50",
    minOrder: "199",
  });

  // 7. Technicians (HRM & KYC)
  const [providers, setProviders] = useState([
    {
      id: "p1",
      name: "Ramesh Sharma",
      skill: "Electrician",
      city: "Rajkot",
      phone: "+91 98250 11223",
      status: "Verified",
      online: true,
      jobs: 142,
      rating: 4.9,
      aadhaar: "•••• •••• 9812",
      onJob: false,
    },
    {
      id: "p2",
      name: "Haresh Solanki",
      skill: "Plumber",
      city: "Rajkot",
      phone: "+91 98250 22334",
      status: "Verified",
      online: true,
      jobs: 98,
      rating: 4.8,
      aadhaar: "•••• •••• 3411",
      onJob: false,
    },
    {
      id: "p3",
      name: "Kanti Mistry",
      skill: "Carpenter",
      city: "Rajkot",
      phone: "+91 98250 33445",
      status: "Verified",
      online: false,
      jobs: 76,
      rating: 4.9,
      aadhaar: "•••• •••• 1289",
      onJob: false,
    },
    {
      id: "p4",
      name: "Jignesh Makwana",
      skill: "Gas Repair",
      city: "Rajkot",
      phone: "+91 98250 44556",
      status: "Verified",
      online: true,
      jobs: 64,
      rating: 4.7,
      aadhaar: "•••• •••• 5567",
      onJob: false,
    },
    {
      id: "p5",
      name: "Deepak Vaghela",
      skill: "AC Repair",
      city: "Rajkot",
      phone: "+91 98250 55667",
      status: "Pending Approval",
      online: false,
      jobs: 0,
      rating: 5.0,
      aadhaar: "•••• •••• 7712",
      onJob: false,
    },
    {
      id: "p6",
      name: "Mahesh Chudasama",
      skill: "On-Road Towing & RSA",
      city: "Ahmedabad",
      phone: "+91 98250 66778",
      status: "Pending Approval",
      online: true,
      jobs: 12,
      rating: 4.6,
      aadhaar: "•••• •••• 9014",
      onJob: true,
    },
  ]);

  // 8. Fleet Attendance & Shifts
  const [attendance, setAttendance] = useState([
    {
      name: "Ramesh Sharma",
      trade: "Electrician",
      clockIn: "08:30 AM",
      clockOut: "— (Active)",
      status: "On Shift",
      hours: "5.5h",
      jobsToday: 3,
    },
    {
      name: "Haresh Solanki",
      trade: "Plumber",
      clockIn: "09:00 AM",
      clockOut: "— (Active)",
      status: "On Shift",
      hours: "5.0h",
      jobsToday: 2,
    },
    {
      name: "Mahesh Chudasama",
      trade: "On-Road RSA",
      clockIn: "07:45 AM",
      clockOut: "— (Active)",
      status: "On Emergency Run",
      hours: "6.2h",
      jobsToday: 4,
    },
    {
      name: "Jignesh Makwana",
      trade: "Gas Repair",
      clockIn: "09:15 AM",
      clockOut: "— (Active)",
      status: "On Shift",
      hours: "4.8h",
      jobsToday: 1,
    },
    {
      name: "Kanti Mistry",
      trade: "Carpenter",
      clockIn: "—",
      clockOut: "—",
      status: "Off Duty",
      hours: "0h",
      jobsToday: 0,
    },
  ]);

  // 9. Standard Spare Parts Price Ceiling List (ERP Inventory)
  const [spareParts, setSpareParts] = useState([
    { id: "sp_1", name: "Heavy Duty Fan Capacitor (2.5mfd)", category: "Electrician", maxCeilingRate: 80, gst: "18%" },
    { id: "sp_2", name: "Brass Ball Valve (1/2 inch)", category: "Plumber", maxCeilingRate: 180, gst: "18%" },
    { id: "sp_3", name: "High-Pressure Gas Hose Pipe (1.5m)", category: "Gas Repair", maxCeilingRate: 290, gst: "18%" },
    { id: "sp_4", name: "Tubeless Tyre Puncture Strip & Sealant", category: "On-Road RSA", maxCeilingRate: 60, gst: "18%" },
    { id: "sp_5", name: "Door Mortise Handle Lock Set (Godrej)", category: "Carpenter", maxCeilingRate: 750, gst: "18%" },
  ]);

  // 10. Operational Cities / Hubs
  const [cities, setCities] = useState([
    { name: "Rajkot", state: "Gujarat", hubLead: "Vipul Jadeja", status: "Active HQ", partners: 18 },
    { name: "Ahmedabad", state: "Gujarat", hubLead: "Pooja Trivedi", status: "Active Hub", partners: 14 },
    { name: "Gandhinagar", state: "Gujarat", hubLead: "Hardik Patel", status: "Active Hub", partners: 8 },
    { name: "Vadodara", state: "Gujarat", hubLead: "Bhavesh Rana", status: "Active Hub", partners: 9 },
    { name: "Surat", state: "Gujarat", hubLead: "Ketan Shah", status: "Active Hub", partners: 11 },
    { name: "Jamnagar", state: "Gujarat", hubLead: "Deepak Joshi", status: "Active Hub", partners: 6 },
    { name: "Bhavnagar", state: "Gujarat", hubLead: "Jaydeep Gohil", status: "Active Hub", partners: 5 },
    { name: "Junagadh", state: "Gujarat", hubLead: "Mahesh Solanki", status: "Active Hub", partners: 4 },
  ]);
  const [newCityName, setNewCityName] = useState("");
  const [newCityLead, setNewCityLead] = useState("");

  // 11. Audit Logs & System Health
  const [auditLogs, setAuditLogs] = useState([
    { time: "09:18 AM", user: "Admin (HQ)", action: "Platform Fee updated to ₹25", ip: "192.168.1.10" },
    { time: "09:05 AM", user: "System", action: "Auto-dispatched order FX-81203 to Mahesh Chudasama", ip: "Server Worker 1" },
    { time: "08:44 AM", user: "Admin (HQ)", action: "Verified KYC for Ramesh Sharma (Aadhaar Checked)", ip: "192.168.1.10" },
    { time: "Yesterday", user: "System", action: "Razorpay batch payout PO-2026-080 completed", ip: "Gateway Webhook" },
  ]);

  // 12. Service Catalog
  const [services, setServices] = useState([
    { id: "elec_fan", name: "Ceiling Fan Repair & Install", category: "Electrician", price: 199, warrantyDays: 30 },
    { id: "plumb_tap", name: "Tap & Mixer Repair", category: "Plumber", price: 149, warrantyDays: 30 },
    { id: "gas_stove", name: "Gas Stove Repair & Clean", category: "Gas Repair", price: 249, warrantyDays: 30 },
    { id: "rsa_puncture", name: "On-Road Tyre Puncture", category: "On-Road RSA", price: 179, warrantyDays: 7 },
    { id: "rsa_jumpstart", name: "Battery Jump-Start (12V)", category: "On-Road RSA", price: 249, warrantyDays: 7 },
    { id: "ac_jetwash", name: "AC Deep Jet Foam Wash", category: "AC Repair", price: 499, warrantyDays: 60 },
  ]);
  const [selectedServiceId, setSelectedServiceId] = useState("elec_fan");
  const [newPriceInput, setNewPriceInput] = useState("199");

  // Notifications Toast Trigger
  const triggerToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  // Sync from Live Backend
  const syncWithBackend = async () => {
    setIsSyncing(true);
    try {
      const resA = await fetch(`${API_BASE}/admin/analytics`).catch(() => null);
      if (resA && resA.ok) {
        const bodyA = await resA.json();
        if (bodyA.success && bodyA.data) setAnalytics(bodyA.data);
      }

      const resF = await fetch(`${API_BASE}/settings/platformFee`).catch(() => null);
      if (resF && resF.ok) {
        const bodyF = await resF.json();
        if (bodyF.platformFee) {
          setPlatformFee(bodyF.platformFee);
          setNewFeeInput(bodyF.platformFee.toString());
        }
      }

      triggerToast("✅ ERP state synchronized with FixIt live backend!");
    } catch {
      triggerToast("Notice: Running in self-healing offline simulation mode.");
    } finally {
      setIsSyncing(false);
    }
  };

  useEffect(() => {
    syncWithBackend();
  }, []);

  // Filtered Bookings
  const filteredBookings = useMemo(() => {
    return bookings.filter((b) => {
      const matchStatus = bookingFilter === "All" || b.status === bookingFilter;
      const matchCity = selectedCity === "All Hubs" || b.city === selectedCity;
      const matchQuery =
        !searchQuery ||
        b.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
        b.customerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
        b.serviceName.toLowerCase().includes(searchQuery.toLowerCase()) ||
        b.phone.includes(searchQuery);
      return matchStatus && matchCity && matchQuery;
    });
  }, [bookings, bookingFilter, selectedCity, searchQuery]);

  // Handlers
  const handleMarkCompleted = (bookingId) => {
    setBookings((prev) =>
      prev.map((b) => (b.id === bookingId ? { ...b, status: "Completed" } : b))
    );
    fetch(`${API_BASE}/bookings/${bookingId}/status`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status: "completed" }),
    }).catch(() => null);

    setAuditLogs((prev) => [
      { time: "Just now", user: "Admin (HQ)", action: `Order ${bookingId} marked as Completed`, ip: "Local Session" },
      ...prev,
    ]);
    triggerToast(`Order ${bookingId} marked as Completed.`);
  };

  const handleToggleKyc = async (providerId, approve) => {
    setProviders((prev) =>
      prev.map((p) =>
        p.id === providerId ? { ...p, status: approve ? "Verified" : "Rejected" } : p
      )
    );

    await fetch(`${API_BASE}/admin/providers/${providerId}/approve-kyc`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ approve }),
    }).catch(() => null);

    setAuditLogs((prev) => [
      {
        time: "Just now",
        user: "Admin (HQ)",
        action: `${approve ? "Approved" : "Rejected"} KYC for provider ${providerId}`,
        ip: "Local Session",
      },
      ...prev,
    ]);

    triggerToast(
      approve ? "✅ Partner KYC verified and granted dispatch privileges!" : "⚠️ Partner KYC rejected."
    );
  };

  const handleDisbursePayout = (payoutId) => {
    setPayouts((prev) =>
      prev.map((p) => (p.payoutId === payoutId ? { ...p, status: "Disbursed" } : p))
    );
    triggerToast(`💰 Payout ${payoutId} successfully queued to Razorpay Route!`);
    setAuditLogs((prev) => [
      { time: "Just now", user: "Admin (HQ)", action: `Disbursed payout ${payoutId}`, ip: "192.168.1.10" },
      ...prev,
    ]);
  };

  const handleCreateCoupon = (e) => {
    e.preventDefault();
    if (!newCouponForm.code) return;

    setCoupons((prev) => [
      {
        code: newCouponForm.code.toUpperCase().trim(),
        type: newCouponForm.type,
        value: `₹${newCouponForm.value} OFF`,
        minOrder: parseInt(newCouponForm.minOrder, 10) || 199,
        uses: 0,
        status: "Active",
        expires: "31/12/2026",
      },
      ...prev,
    ]);

    setShowCouponModal(false);
    triggerToast(`🎉 Coupon ${newCouponForm.code.toUpperCase()} is now live!`);
    setNewCouponForm({ code: "", type: "Flat Discount", value: "50", minOrder: "199" });
  };

  const handleAddCityHub = (e) => {
    e.preventDefault();
    if (!newCityName) return;

    setCities((prev) => [
      ...prev,
      {
        name: newCityName.trim(),
        state: "Gujarat",
        hubLead: newCityLead.trim() || "Operations Lead",
        status: "Active Hub",
        partners: 0,
      },
    ]);

    fetch(`${API_BASE}/admin/cities`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name: newCityName.trim(), state: "Gujarat" }),
    }).catch(() => null);

    setShowCityModal(false);
    triggerToast(`🎉 ${newCityName} added to FixIt operational cities!`);
    setNewCityName("");
    setNewCityLead("");
  };

  // CSV Exporter
  const exportCsv = (filename, data) => {
    if (!data || !data.length) return;
    const headers = Object.keys(data[0]).join(",");
    const rows = data.map((obj) => Object.values(obj).map((v) => `"${v}"`).join(","));
    const csvContent = "data:text/csv;charset=utf-8," + [headers, ...rows].join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `${filename}_${Date.now()}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    triggerToast(`📥 Exported ${filename}.csv successfully!`);
  };

  return (
    <div className="admin-shell">
      <div className="bg-ambient-glow" />

      {/* ========================================================= */}
      {/* SIDEBAR NAVIGATION (ERP GROUPED)                          */}
      {/* ========================================================= */}
      <aside className="sidebar">
        <div className="brand-section">
          <div className="brand-logo-badge">
            <ShieldCheck size={22} color="#ffffff" />
          </div>
          <div>
            <div className="brand-title">FixIt ERP</div>
            <div className="brand-subtitle">Operations & Financial HQ</div>
          </div>
        </div>

        <nav style={{ flex: 1, paddingBottom: "20px" }}>
          {/* GROUP 1: OPERATIONS */}
          <div className="nav-group">
            <div className="nav-group-title">Operations & Dispatch</div>
            <button
              onClick={() => setActiveTab("overview")}
              className={`nav-item ${activeTab === "overview" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <LayoutDashboard size={16} />
                <span>Executive Cockpit</span>
              </div>
            </button>

            <button
              onClick={() => setActiveTab("orders")}
              className={`nav-item ${activeTab === "orders" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <ClipboardList size={16} />
                <span>Orders & Dispatch</span>
              </div>
              <span className="nav-badge active-badge">{bookings.length}</span>
            </button>

            <button
              onClick={() => setActiveTab("rsa-radar")}
              className={`nav-item ${activeTab === "rsa-radar" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <Flame size={16} />
                <span>24x7 Roadside RSA</span>
              </div>
              <span className="nav-badge alert-badge">⚡ SLA &lt;25m</span>
            </button>
          </div>

          {/* GROUP 2: FINANCE & PAYMENTS */}
          <div className="nav-group">
            <div className="nav-group-title">Finance & Payments ERP</div>
            <button
              onClick={() => setActiveTab("payments")}
              className={`nav-item ${activeTab === "payments" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <CreditCard size={16} />
                <span>Transactions Ledger</span>
              </div>
            </button>

            <button
              onClick={() => setActiveTab("payouts")}
              className={`nav-item ${activeTab === "payouts" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <Wallet size={16} />
                <span>Partner Payouts Escrow</span>
              </div>
              <span className="nav-badge alert-badge">1 Pending</span>
            </button>

            <button
              onClick={() => setActiveTab("refunds")}
              className={`nav-item ${activeTab === "refunds" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <RotateCcw size={16} />
                <span>Refunds & Disputes</span>
              </div>
            </button>

            <button
              onClick={() => setActiveTab("coupons")}
              className={`nav-item ${activeTab === "coupons" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <Tag size={16} />
                <span>Marketing Coupons</span>
              </div>
              <span className="nav-badge">{coupons.length}</span>
            </button>
          </div>

          {/* GROUP 3: WORKFORCE & HRM */}
          <div className="nav-group">
            <div className="nav-group-title">Fleet & Workforce (HRM)</div>
            <button
              onClick={() => setActiveTab("providers")}
              className={`nav-item ${activeTab === "providers" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <UserCheck size={16} />
                <span>Technician Roster & KYC</span>
              </div>
              <span className="nav-badge alert-badge">2 KYC</span>
            </button>

            <button
              onClick={() => setActiveTab("attendance")}
              className={`nav-item ${activeTab === "attendance" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <CalendarCheck size={16} />
                <span>Daily Shifts & Attendance</span>
              </div>
            </button>
          </div>

          {/* GROUP 4: CATALOG & INVENTORY */}
          <div className="nav-group">
            <div className="nav-group-title">Catalog & Inventory</div>
            <button
              onClick={() => setActiveTab("catalog")}
              className={`nav-item ${activeTab === "catalog" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <Package size={16} />
                <span>Service Price Modifier</span>
              </div>
            </button>

            <button
              onClick={() => setActiveTab("inventory")}
              className={`nav-item ${activeTab === "inventory" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <Boxes size={16} />
                <span>Spare Parts Price Ceiling</span>
              </div>
            </button>
          </div>

          {/* GROUP 5: SYSTEM CONFIGURATION */}
          <div className="nav-group">
            <div className="nav-group-title">ERP Master Data & Config</div>
            <button
              onClick={() => setActiveTab("system-config")}
              className={`nav-item ${activeTab === "system-config" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <Sliders size={16} />
                <span>Platform Fee & Policies</span>
              </div>
            </button>

            <button
              onClick={() => setActiveTab("cities-hubs")}
              className={`nav-item ${activeTab === "cities-hubs" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <MapPin size={16} />
                <span>Operational Cities Hubs</span>
              </div>
              <span className="nav-badge">{cities.length}</span>
            </button>

            <button
              onClick={() => setActiveTab("audit-logs")}
              className={`nav-item ${activeTab === "audit-logs" ? "active" : ""}`}
            >
              <div className="nav-item-left">
                <FileText size={16} />
                <span>Audit Logs & Exports</span>
              </div>
            </button>
          </div>
        </nav>

        <div className="sidebar-footer">
          <div className="api-status-pill">
            <div className="pulse-dot" />
            <span>Node / Express API: 5000</span>
          </div>
          <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>
            FixIt ERP v2.4 • Gujarat Cluster
          </div>
        </div>
      </aside>

      {/* ========================================================= */}
      {/* MAIN VIEWPORT WRAPPER                                     */}
      {/* ========================================================= */}
      <div className="main-wrapper">
        {/* Sticky Header */}
        <header className="top-header">
          <div className="header-left">
            <div className="page-title">
              {activeTab === "overview" && "Executive Performance Command Center"}
              {activeTab === "orders" && "Dispatch Moderation & Order Lifecycle"}
              {activeTab === "rsa-radar" && "Emergency Breakdown Radar & Roadside Dispatch"}
              {activeTab === "payments" && "Financial Ledger & Payment Gateway Records"}
              {activeTab === "payouts" && "Specialist Labor Escrow & Payout Reconciliation"}
              {activeTab === "refunds" && "Refund Reversals & Dispute Settlement"}
              {activeTab === "coupons" && "Promotional Campaigns & Coupon Codes"}
              {activeTab === "providers" && "Technician Network & KYC Validation"}
              {activeTab === "attendance" && "Daily Shifts, Clock-in & Active Radar"}
              {activeTab === "catalog" && "Standardized Services & Base Pricing"}
              {activeTab === "inventory" && "Spare Parts Ceiling Price List"}
              {activeTab === "system-config" && "Platform Policies & Global Controls"}
              {activeTab === "cities-hubs" && "Operational City Hubs Network"}
              {activeTab === "audit-logs" && "System Audit Trail & Master Data Export"}
            </div>

            <select
              className="city-filter-select"
              value={selectedCity}
              onChange={(e) => setSelectedCity(e.target.value)}
            >
              <option value="All Hubs">All Operational Hubs ({cities.length})</option>
              {cities.map((c) => (
                <option key={c.name} value={c.name}>
                  📍 {c.name} Hub
                </option>
              ))}
            </select>
          </div>

          <div className="header-right">
            <div className="fee-badge">
              <BadgeIndianRupee size={14} />
              <span>Platform Fee: ₹{platformFee}</span>
            </div>

            <button
              onClick={syncWithBackend}
              className={`btn-secondary ${isSyncing ? "spinning" : ""}`}
              title="Refresh live data from backend"
            >
              <RefreshCw size={14} />
              <span>{isSyncing ? "Syncing..." : "Live Sync"}</span>
            </button>
          </div>
        </header>

        {/* Content Body */}
        <main className="page-container">
          {/* ========================================================= */}
          {/* 1. OVERVIEW COCKPIT                                       */}
          {/* ========================================================= */}
          {activeTab === "overview" && (
            <div>
              <div className="metrics-grid">
                <div className="metric-card">
                  <div className="metric-card-header">
                    <span className="metric-label">Gross Merchandise Value</span>
                    <div className="metric-icon-wrap" style={{ background: "rgba(2, 132, 199, 0.15)" }}>
                      <TrendingUp size={18} color="#38bdf8" />
                    </div>
                  </div>
                  <div className="metric-value" style={{ color: "#38bdf8" }}>
                    ₹{analytics.totalGrossRevenue.toLocaleString()}
                  </div>
                  <div className="metric-subtext">Across {analytics.totalBookings} orders in Gujarat</div>
                </div>

                <div className="metric-card">
                  <div className="metric-card-header">
                    <span className="metric-label">Platform Net Earnings</span>
                    <div className="metric-icon-wrap" style={{ background: "rgba(16, 185, 129, 0.15)" }}>
                      <BadgeIndianRupee size={18} color="#34d399" />
                    </div>
                  </div>
                  <div className="metric-value" style={{ color: "#34d399" }}>
                    ₹{analytics.totalPlatformEarnings.toLocaleString()}
                  </div>
                  <div className="metric-subtext">100% Retained (₹{platformFee} booking fee)</div>
                </div>

                <div className="metric-card">
                  <div className="metric-card-header">
                    <span className="metric-label">Partner Payouts Pool</span>
                    <div className="metric-icon-wrap" style={{ background: "rgba(99, 102, 241, 0.15)" }}>
                      <Wallet size={18} color="#818cf8" />
                    </div>
                  </div>
                  <div className="metric-value" style={{ color: "#818cf8" }}>
                    ₹{analytics.totalProviderPayouts.toLocaleString()}
                  </div>
                  <div className="metric-subtext">100% Labor quote direct to technicians</div>
                </div>

                <div className="metric-card">
                  <div className="metric-card-header">
                    <span className="metric-label">Customer Satisfaction</span>
                    <div className="metric-icon-wrap" style={{ background: "rgba(245, 158, 11, 0.15)" }}>
                      <Star size={18} color="#fbbf24" fill="#fbbf24" />
                    </div>
                  </div>
                  <div className="metric-value" style={{ color: "#fbbf24" }}>
                    ★ {analytics.averageRating}
                  </div>
                  <div className="metric-subtext">340+ verified customer ratings</div>
                </div>
              </div>

              {/* Operations Health */}
              <div className="glass-panel">
                <div className="panel-header">
                  <div className="panel-title">Operations Network Health & Live Fleet</div>
                  <span className="status-tag status-verified">● Live Real-Time Operations</span>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))", gap: "16px" }}>
                  <div style={{ padding: "16px", borderRadius: "12px", background: "rgba(255,255,255,0.02)", border: "1px solid var(--border-subtle)" }}>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginBottom: "4px" }}>OPERATIONAL HUBS</div>
                    <div style={{ fontSize: "18px", fontWeight: "800" }}>{cities.length} Operational Cities</div>
                    <div style={{ fontSize: "11px", color: "var(--accent-green)", marginTop: "4px" }}>
                      Rajkot HQ, Ahmedabad, Surat, Vadodara + 4 more
                    </div>
                  </div>

                  <div style={{ padding: "16px", borderRadius: "12px", background: "rgba(255,255,255,0.02)", border: "1px solid var(--border-subtle)" }}>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginBottom: "4px" }}>ACTIVE FIELD SPECIALISTS</div>
                    <div style={{ fontSize: "18px", fontWeight: "800", color: "#38bdf8" }}>{analytics.activeProviders} Online</div>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "4px" }}>
                      {analytics.totalProviders} Total registered verified specialists
                    </div>
                  </div>

                  <div style={{ padding: "16px", borderRadius: "12px", background: "rgba(255,255,255,0.02)", border: "1px solid var(--border-subtle)" }}>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginBottom: "4px" }}>EMERGENCY SLA TARGET</div>
                    <div style={{ fontSize: "18px", fontWeight: "800", color: "#fbbf24" }}>⚡ &lt; 25 Minutes</div>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "4px" }}>
                      On-road puncture, jumpstart, towing response
                    </div>
                  </div>

                  <div style={{ padding: "16px", borderRadius: "12px", background: "rgba(255,255,255,0.02)", border: "1px solid var(--border-subtle)" }}>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginBottom: "4px" }}>TAX & GST RECONCILIATION</div>
                    <div style={{ fontSize: "18px", fontWeight: "800", color: "#34d399" }}>18% GST Compliant</div>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "4px" }}>
                      Tax invoices generated automatically for all bookings
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* 2. ORDERS & DISPATCH MASTER                               */}
          {/* ========================================================= */}
          {activeTab === "orders" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Dispatch & Bookings Master</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Showing {filteredBookings.length} matching orders
                  </div>
                </div>

                <div style={{ display: "flex", gap: "10px" }}>
                  <div style={{ position: "relative" }}>
                    <input
                      type="text"
                      className="form-input"
                      placeholder="Search ID, customer, phone..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      style={{ paddingLeft: "32px", width: "230px", margin: 0 }}
                    />
                    <Search size={14} style={{ position: "absolute", left: "10px", top: "11px", color: "var(--text-muted)" }} />
                  </div>
                  <button onClick={() => exportCsv("fixit_orders", bookings)} className="btn-secondary">
                    <Download size={14} />
                    <span>Export CSV</span>
                  </button>
                </div>
              </div>

              {/* Status Filter Pills */}
              <div className="filter-pills-row">
                {["All", "Upcoming", "On the way", "Completed", "Cancelled"].map((f) => (
                  <button
                    key={f}
                    onClick={() => setBookingFilter(f)}
                    className={`filter-pill ${bookingFilter === f ? "active" : ""}`}
                  >
                    {f}
                  </button>
                ))}
              </div>

              {/* Table */}
              <div style={{ overflowX: "auto" }}>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Order ID</th>
                      <th>Customer & City</th>
                      <th>Service & Trade</th>
                      <th>Schedule / Type</th>
                      <th>Amount & Split</th>
                      <th>Status</th>
                      <th style={{ textAlign: "right" }}>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredBookings.map((b) => (
                      <tr key={b.id}>
                        <td>
                          <strong style={{ color: "var(--accent-cyan)", fontFamily: "monospace" }}>{b.id}</strong>
                        </td>
                        <td>
                          <div style={{ fontWeight: "700" }}>{b.customerName}</div>
                          <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>
                            {b.phone} • {b.city}
                          </div>
                        </td>
                        <td>
                          <div style={{ fontWeight: "600" }}>{b.serviceName}</div>
                          <span style={{ fontSize: "11px", color: "var(--accent-blue)" }}>{b.categoryName}</span>
                        </td>
                        <td>
                          <div style={{ fontSize: "12px" }}>{b.dateTime}</div>
                        </td>
                        <td>
                          <div style={{ fontWeight: "800", color: "#34d399" }}>₹{b.totalAmount}</div>
                          <div style={{ fontSize: "10px", color: "var(--text-muted)" }}>
                            (Labor: ₹{b.price} + Fee: ₹{b.platformFee})
                          </div>
                        </td>
                        <td>
                          <span
                            className={`status-tag ${
                              b.status === "Completed"
                                ? "status-completed"
                                : b.status === "Cancelled"
                                ? "status-cancelled"
                                : b.status === "On the way"
                                ? "status-ontheway"
                                : "status-upcoming"
                            }`}
                          >
                            {b.status}
                          </span>
                        </td>
                        <td style={{ textAlign: "right" }}>
                          <div style={{ display: "inline-flex", gap: "6px" }}>
                            <button
                              onClick={() => setShowInvoiceModal(b)}
                              className="btn-action"
                              style={{ background: "rgba(255,255,255,0.06)", color: "#fff" }}
                              title="View Tax Invoice"
                            >
                              Invoice
                            </button>
                            {b.status !== "Completed" && b.status !== "Cancelled" && (
                              <button
                                onClick={() => handleMarkCompleted(b.id)}
                                className="btn-action btn-approve"
                              >
                                Mark Done
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* 3. ROADSIDE ASSISTANCE (RSA) RADAR                        */}
          {/* ========================================================= */}
          {activeTab === "rsa-radar" && (
            <div>
              <div className="glass-panel">
                <div className="panel-header">
                  <div>
                    <div className="panel-title">24x7 On-Road Breakdown & Emergency Fleet</div>
                    <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                      Live incident response radar for tyre punctures, towing, battery jumpstarts, and key lockouts
                    </div>
                  </div>
                  <span className="status-tag status-ontheway">⚡ High Priority Queue</span>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))", gap: "16px", marginBottom: "20px" }}>
                  <div style={{ background: "rgba(239, 68, 68, 0.08)", border: "1px solid rgba(239, 68, 68, 0.3)", padding: "16px", borderRadius: "12px" }}>
                    <div style={{ fontSize: "11px", fontWeight: "700", color: "#f87171" }}>ACTIVE ROADSIDE INCIDENTS</div>
                    <div style={{ fontSize: "24px", fontWeight: "800", color: "#f87171", marginTop: "4px" }}>2 Active Calls</div>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "4px" }}>National Highway 27 & SG Highway</div>
                  </div>

                  <div style={{ background: "rgba(16, 185, 129, 0.08)", border: "1px solid rgba(16, 185, 129, 0.3)", padding: "16px", borderRadius: "12px" }}>
                    <div style={{ fontSize: "11px", fontWeight: "700", color: "#34d399" }}>AVERAGE DISPATCH TIME</div>
                    <div style={{ fontSize: "24px", fontWeight: "800", color: "#34d399", marginTop: "4px" }}>16.4 Minutes</div>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "4px" }}>SLA: &lt; 25 mins guarantee met 98.4%</div>
                  </div>

                  <div style={{ background: "rgba(2, 132, 199, 0.08)", border: "1px solid rgba(2, 132, 199, 0.3)", padding: "16px", borderRadius: "12px" }}>
                    <div style={{ fontSize: "11px", fontWeight: "700", color: "#38bdf8" }}>TOWING & RECOVERY TRUCKS</div>
                    <div style={{ fontSize: "24px", fontWeight: "800", color: "#38bdf8", marginTop: "4px" }}>6 Trucks On Standby</div>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "4px" }}>Hydraulic wheel-lift & flatbed carriers</div>
                  </div>
                </div>

                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Emergency ID</th>
                      <th>Motorist</th>
                      <th>Breakdown Type</th>
                      <th>Location / GPS Pin</th>
                      <th>Assigned Recovery Unit</th>
                      <th>SLA Clock</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td><strong style={{ color: "var(--accent-red)", fontFamily: "monospace" }}>EMG-81203</strong></td>
                      <td>
                        <div style={{ fontWeight: "700" }}>Sneha Dave</div>
                        <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>+91 98980 55443 (Honda Activa)</div>
                      </td>
                      <td>
                        <span style={{ fontWeight: "700", color: "var(--accent-amber)" }}>Tyre Puncture (Tubeless)</span>
                      </td>
                      <td>
                        <div>Aji Dam Overbridge, NH 27</div>
                        <div style={{ fontSize: "10px", color: "var(--accent-blue)" }}>GPS: 22.2741° N, 70.8322° E</div>
                      </td>
                      <td>
                        <div style={{ fontWeight: "700" }}>Mahesh Chudasama (RSA Unit 2)</div>
                        <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>On Way (ETA: 8 mins)</div>
                      </td>
                      <td>
                        <span className="status-tag status-ontheway">⏱ 14m elapsed</span>
                      </td>
                      <td>
                        <button onClick={() => triggerToast("Direct emergency radio call initiated to Mahesh Chudasama")} className="btn-action btn-approve">
                          Radio Call
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* 4. FINANCIAL LEDGER & PAYMENTS                            */}
          {/* ========================================================= */}
          {activeTab === "payments" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Financial Ledger & Gateway Reconciliation</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Razorpay order IDs, UPI VPA references, and platform fee splits
                  </div>
                </div>
                <button onClick={() => exportCsv("fixit_financial_ledger", bookings)} className="btn-secondary">
                  <Download size={14} />
                  <span>Download Ledger CSV</span>
                </button>
              </div>

              <div style={{ overflowX: "auto" }}>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Transaction Ref</th>
                      <th>Order ID</th>
                      <th>Customer</th>
                      <th>Method</th>
                      <th>Labor Quote (100% Pro)</th>
                      <th>Platform Fee</th>
                      <th>Total Paid</th>
                      <th>Gateway Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {bookings.map((b) => (
                      <tr key={b.id}>
                        <td><code style={{ color: "var(--accent-cyan)", fontSize: "11px" }}>{b.txnId || "txn_rzp_mock"}</code></td>
                        <td><strong style={{ fontFamily: "monospace" }}>{b.id}</strong></td>
                        <td>{b.customerName}</td>
                        <td>
                          <span style={{ fontSize: "12px", fontWeight: "600" }}>{b.paymentMethod}</span>
                        </td>
                        <td>₹{b.price}</td>
                        <td style={{ color: "#34d399", fontWeight: "700" }}>₹{b.platformFee}</td>
                        <td><strong>₹{b.totalAmount}</strong></td>
                        <td>
                          <span className={`status-tag ${b.paymentStatus === "paid" ? "status-paid" : "status-refunded"}`}>
                            {b.paymentStatus === "paid" ? "Captured (Success)" : "Refunded"}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* 5. TECHNICIAN PAYOUTS ESCROW                              */}
          {/* ========================================================= */}
          {activeTab === "payouts" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Specialist Labor Escrow & Payout Reconciliation</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    100% labor earnings transfers via Razorpay Route marketplace split
                  </div>
                </div>
                <button onClick={() => exportCsv("fixit_payouts_ledger", payouts)} className="btn-secondary">
                  <Download size={14} />
                  <span>Export Payouts</span>
                </button>
              </div>

              <div style={{ overflowX: "auto" }}>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Payout Batch ID</th>
                      <th>Technician & Trade</th>
                      <th>Jobs Completed</th>
                      <th>Bank & Account</th>
                      <th>Payout Amount</th>
                      <th>Status</th>
                      <th style={{ textAlign: "right" }}>Disbursement</th>
                    </tr>
                  </thead>
                  <tbody>
                    {payouts.map((p) => (
                      <tr key={p.payoutId}>
                        <td><code style={{ color: "var(--accent-cyan)", fontWeight: "700" }}>{p.payoutId}</code></td>
                        <td>
                          <div style={{ fontWeight: "700" }}>{p.providerName}</div>
                          <div style={{ fontSize: "11px", color: "var(--accent-blue)" }}>{p.trade}</div>
                        </td>
                        <td>{p.jobsCount} verified orders</td>
                        <td>
                          <div style={{ fontSize: "12px" }}>{p.bankName}</div>
                          <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>A/C: {p.accountNo}</div>
                        </td>
                        <td>
                          <div style={{ fontSize: "15px", fontWeight: "800", color: "#34d399" }}>₹{p.amount}</div>
                          <div style={{ fontSize: "10px", color: "var(--text-muted)" }}>0% commission deducted</div>
                        </td>
                        <td>
                          <span className={`status-tag ${p.status === "Disbursed" ? "status-completed" : "status-pending"}`}>
                            {p.status}
                          </span>
                        </td>
                        <td style={{ textAlign: "right" }}>
                          {p.status !== "Disbursed" ? (
                            <button onClick={() => handleDisbursePayout(p.payoutId)} className="btn-action btn-approve">
                              Release ₹{p.amount}
                            </button>
                          ) : (
                            <span style={{ fontSize: "11px", color: "var(--accent-green)", fontWeight: "700" }}>✓ Settled</span>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* 6. REFUNDS & DISPUTES                                     */}
          {/* ========================================================= */}
          {activeTab === "refunds" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Refund Reversals & Dispute Settlement</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Instant 100% reversals for pre-arrival cancellations and quality disputes
                  </div>
                </div>
              </div>

              <div style={{ overflowX: "auto" }}>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Refund Ref</th>
                      <th>Order ID</th>
                      <th>Customer</th>
                      <th>Amount</th>
                      <th>Reason & Justification</th>
                      <th>Method</th>
                      <th>Reversal Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {refunds.map((r) => (
                      <tr key={r.refundId}>
                        <td><code style={{ color: "var(--accent-amber)" }}>{r.refundId}</code></td>
                        <td><strong>{r.bookingId}</strong></td>
                        <td>{r.customerName}</td>
                        <td style={{ fontWeight: "800", color: "#f87171" }}>₹{r.amount}</td>
                        <td style={{ maxWidth: "280px", fontSize: "12px", color: "var(--text-muted)" }}>{r.reason}</td>
                        <td>{r.method}</td>
                        <td>
                          <span className={`status-tag ${r.status === "Processed" ? "status-completed" : "status-pending"}`}>
                            {r.status}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* 7. MARKETING COUPONS & CAMPAIGNS                          */}
          {/* ========================================================= */}
          {activeTab === "coupons" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Marketing Coupons & Discount Campaigns</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Manage promo codes, platform fee waivers, and customer acquisition campaigns
                  </div>
                </div>
                <button onClick={() => setShowCouponModal(true)} className="btn-primary">
                  <PlusCircle size={15} />
                  <span>Create Promo Coupon</span>
                </button>
              </div>

              <div style={{ overflowX: "auto" }}>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Promo Code</th>
                      <th>Discount Offer</th>
                      <th>Campaign Type</th>
                      <th>Min Order Value</th>
                      <th>Total Redemptions</th>
                      <th>Status</th>
                      <th>Expiry</th>
                    </tr>
                  </thead>
                  <tbody>
                    {coupons.map((c) => (
                      <tr key={c.code}>
                        <td>
                          <code style={{ background: "rgba(2, 132, 199, 0.15)", padding: "4px 8px", borderRadius: "6px", color: "var(--accent-cyan)", fontWeight: "800" }}>
                            {c.code}
                          </code>
                        </td>
                        <td style={{ fontWeight: "700", color: "#34d399" }}>{c.value}</td>
                        <td>{c.type}</td>
                        <td>₹{c.minOrder}</td>
                        <td><strong>{c.uses} times</strong></td>
                        <td>
                          <span className={`status-tag ${c.status === "Active" ? "status-active" : "status-pending"}`}>
                            {c.status}
                          </span>
                        </td>
                        <td style={{ fontSize: "12px", color: "var(--text-muted)" }}>{c.expires}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* 8. TECHNICIAN ROSTER & KYC APPROVALS                     */}
          {/* ========================================================= */}
          {activeTab === "providers" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Technician Partner Network & KYC Approval</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Aadhaar verification, skill vetting, and field dispatch authorization
                  </div>
                </div>
              </div>

              <div style={{ overflowX: "auto" }}>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Technician</th>
                      <th>Trade Category</th>
                      <th>City & Phone</th>
                      <th>Aadhaar Card</th>
                      <th>Rating & Jobs</th>
                      <th>Live Radar</th>
                      <th>KYC Status</th>
                      <th style={{ textAlign: "right" }}>KYC Moderation</th>
                    </tr>
                  </thead>
                  <tbody>
                    {providers.map((p) => (
                      <tr key={p.id}>
                        <td>
                          <div style={{ fontWeight: "700" }}>{p.name}</div>
                        </td>
                        <td>
                          <span style={{ fontWeight: "600", color: "var(--accent-cyan)" }}>{p.skill}</span>
                        </td>
                        <td>
                          <div>{p.city}</div>
                          <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>{p.phone}</div>
                        </td>
                        <td>
                          <code style={{ fontSize: "11px" }}>{p.aadhaar}</code>
                        </td>
                        <td>
                          <div style={{ display: "flex", alignItems: "center", gap: "4px" }}>
                            <Star size={13} color="#fbbf24" fill="#fbbf24" />
                            <strong>{p.rating}</strong>
                            <span style={{ color: "var(--text-muted)", fontSize: "11px" }}>({p.jobs} jobs)</span>
                          </div>
                        </td>
                        <td>
                          {p.online ? (
                            <span style={{ color: "var(--accent-green)", fontSize: "12px", fontWeight: "700" }}>
                              ● Online {p.onJob ? "(On Job)" : "(Idle)"}
                            </span>
                          ) : (
                            <span style={{ color: "var(--text-muted)", fontSize: "12px" }}>○ Offline</span>
                          )}
                        </td>
                        <td>
                          <span
                            className={`status-tag ${
                              p.status === "Verified"
                                ? "status-verified"
                                : p.status === "Rejected"
                                ? "status-rejected"
                                : "status-pending"
                            }`}
                          >
                            {p.status}
                          </span>
                        </td>
                        <td style={{ textAlign: "right" }}>
                          <div style={{ display: "inline-flex", gap: "6px" }}>
                            {p.status !== "Verified" ? (
                              <>
                                <button onClick={() => handleToggleKyc(p.id, true)} className="btn-action btn-approve">
                                  Approve KYC
                                </button>
                                <button onClick={() => handleToggleKyc(p.id, false)} className="btn-action btn-reject">
                                  Reject
                                </button>
                              </>
                            ) : (
                              <button onClick={() => handleToggleKyc(p.id, false)} className="btn-action btn-reject">
                                Revoke
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* 9. ATTENDANCE & SHIFTS                                    */}
          {/* ========================================================= */}
          {activeTab === "attendance" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Daily Field Attendance & Shifts Monitoring</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Real-time check-in logs, hours online, and jobs completed today
                  </div>
                </div>
              </div>

              <table className="data-table">
                <thead>
                  <tr>
                    <th>Specialist Name</th>
                    <th>Trade Category</th>
                    <th>Clock In</th>
                    <th>Clock Out</th>
                    <th>Hours Logged</th>
                    <th>Jobs Today</th>
                    <th>Shift Status</th>
                  </tr>
                </thead>
                <tbody>
                  {attendance.map((a, i) => (
                    <tr key={i}>
                      <td><strong>{a.name}</strong></td>
                      <td>{a.trade}</td>
                      <td>{a.clockIn}</td>
                      <td>{a.clockOut}</td>
                      <td><strong>{a.hours}</strong></td>
                      <td>{a.jobsToday} completed</td>
                      <td>
                        <span className={`status-tag ${a.status === "Off Duty" ? "status-cancelled" : "status-completed"}`}>
                          {a.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {/* ========================================================= */}
          {/* 10. CATALOG & SERVICE PRICING                             */}
          {activeTab === "catalog" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Standardized Services & Base Pricing</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    100% of these base service prices are credited directly to the attending specialist
                  </div>
                </div>
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(320px, 1fr))", gap: "16px", marginBottom: "20px" }}>
                <div style={{ background: "rgba(255,255,255,0.03)", padding: "18px", borderRadius: "12px", border: "1px solid var(--border-subtle)" }}>
                  <div style={{ fontSize: "13px", fontWeight: "700", marginBottom: "8px" }}>Update Service Base Price</div>
                  <select
                    className="form-input"
                    style={{ width: "100%", marginBottom: "12px" }}
                    value={selectedServiceId}
                    onChange={(e) => {
                      setSelectedServiceId(e.target.value);
                      const s = services.find((x) => x.id === e.target.value);
                      if (s) setNewPriceInput(s.price.toString());
                    }}
                  >
                    {services.map((s) => (
                      <option key={s.id} value={s.id}>
                        {s.name} ({s.category}) — Current: ₹{s.price}
                      </option>
                    ))}
                  </select>

                  <div className="form-input-row" style={{ marginTop: 0 }}>
                    <input
                      type="number"
                      className="form-input"
                      placeholder="New base price (₹)"
                      value={newPriceInput}
                      onChange={(e) => setNewPriceInput(e.target.value)}
                    />
                    <button
                      onClick={() => {
                        const price = parseInt(newPriceInput, 10);
                        if (!price) return;
                        setServices((prev) => prev.map((s) => (s.id === selectedServiceId ? { ...s, price } : s)));
                        triggerToast(`Catalog base price updated to ₹${price}!`);
                      }}
                      className="btn-primary"
                    >
                      Save Price
                    </button>
                  </div>
                </div>
              </div>

              <table className="data-table">
                <thead>
                  <tr>
                    <th>Service Offering</th>
                    <th>Category</th>
                    <th>Standard Labor Base Price</th>
                    <th>Warranty Guarantee</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {services.map((s) => (
                    <tr key={s.id}>
                      <td><strong>{s.name}</strong></td>
                      <td><span style={{ color: "var(--accent-cyan)" }}>{s.category}</span></td>
                      <td><span style={{ fontSize: "14px", fontWeight: "800", color: "#34d399" }}>₹{s.price}</span></td>
                      <td>{s.warrantyDays} Days Free Rework Warranty</td>
                      <td><span className="status-tag status-active">Active in Catalog</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {/* ========================================================= */}
          {/* 11. SPARE PARTS INVENTORY CEILING                         */}
          {/* ========================================================= */}
          {activeTab === "inventory" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Official Spare Parts Price Ceiling Rate Card</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Prevents technician overcharging by enforcing transparent ceiling prices on common replacement parts
                  </div>
                </div>
              </div>

              <table className="data-table">
                <thead>
                  <tr>
                    <th>Spare Part Item</th>
                    <th>Associated Trade</th>
                    <th>Maximum Permissible Price Ceiling</th>
                    <th>GST Bracket</th>
                    <th>Compliance</th>
                  </tr>
                </thead>
                <tbody>
                  {spareParts.map((sp) => (
                    <tr key={sp.id}>
                      <td><strong>{sp.name}</strong></td>
                      <td>{sp.category}</td>
                      <td><strong style={{ color: "#38bdf8", fontSize: "14px" }}>₹{sp.maxCeilingRate}</strong></td>
                      <td>{sp.gst}</td>
                      <td><span className="status-tag status-verified">FixIt Standardized</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {/* ========================================================= */}
          {/* 12. SYSTEM CONFIGURATION & MASTER POLICIES                */}
          {/* ========================================================= */}
          {activeTab === "system-config" && (
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(360px, 1fr))", gap: "20px" }}>
              {/* Dynamic Platform Fee */}
              <div className="glass-panel">
                <div className="panel-title">Dynamic Platform Fee Settings</div>
                <p style={{ fontSize: "12px", color: "var(--text-muted)", marginTop: "6px", lineHeight: "1.5" }}>
                  This flat booking fee is billed to the customer on every order. 100% of this fee goes directly to FixIt operational revenue without taking any cut from the technician's labor price.
                </p>

                <div
                  style={{
                    background: "rgba(2, 132, 199, 0.08)",
                    border: "1px solid rgba(2, 132, 199, 0.25)",
                    borderRadius: "12px",
                    padding: "16px",
                    margin: "16px 0",
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                  }}
                >
                  <div>
                    <div style={{ fontSize: "11px", fontWeight: "700", color: "var(--text-muted)" }}>CURRENT LIVE FEE</div>
                    <div style={{ fontSize: "12px", fontWeight: "600" }}>Active across all operational cities</div>
                  </div>
                  <div style={{ fontSize: "32px", fontWeight: "800", color: "var(--accent-cyan)" }}>₹{platformFee}</div>
                </div>

                <div className="form-input-row">
                  <input
                    type="number"
                    className="form-input"
                    value={newFeeInput}
                    onChange={(e) => setNewFeeInput(e.target.value)}
                    placeholder="Enter fee amount"
                  />
                  <button
                    onClick={() => {
                      const val = parseInt(newFeeInput, 10);
                      if (isNaN(val)) return;
                      setPlatformFee(val);
                      triggerToast(`Platform Fee updated to ₹${val}!`);
                    }}
                    className="btn-primary"
                  >
                    Update Fee
                  </button>
                </div>
              </div>

              {/* Auto-Dispatch Rules */}
              <div className="glass-panel">
                <div className="panel-title">Auto-Assignment & Radar Radius</div>
                <p style={{ fontSize: "12px", color: "var(--text-muted)", marginTop: "6px", lineHeight: "1.5" }}>
                  Defines the maximum search perimeter for automatically matching nearest online verified specialists.
                </p>

                <div style={{ marginTop: "16px" }}>
                  <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "8px" }}>
                    <span style={{ fontSize: "13px", fontWeight: "600" }}>Search Perimeter:</span>
                    <strong style={{ color: "var(--accent-cyan)" }}>{autoDispatchRadius} Kilometers</strong>
                  </div>
                  <input
                    type="range"
                    min="3"
                    max="25"
                    value={autoDispatchRadius}
                    onChange={(e) => setAutoDispatchRadius(parseInt(e.target.value, 10))}
                    style={{ width: "100%", accentColor: "var(--accent-cyan)" }}
                  />
                </div>

                <div style={{ marginTop: "24px" }}>
                  <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "8px" }}>
                    <span style={{ fontSize: "13px", fontWeight: "600" }}>Standard GST Tax Rate:</span>
                    <strong style={{ color: "#34d399" }}>{gstRate}%</strong>
                  </div>
                  <input
                    type="number"
                    className="form-input"
                    value={gstRate}
                    onChange={(e) => setGstRate(parseInt(e.target.value, 10) || 18)}
                    style={{ width: "100%" }}
                  />
                </div>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* 13. OPERATIONAL CITIES & HUBS                             */}
          {/* ========================================================= */}
          {activeTab === "cities-hubs" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Operational City Hubs Network ({cities.length} Cities)</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Regional hubs, cluster operations leads, and active partner coverage
                  </div>
                </div>
                <button onClick={() => setShowCityModal(true)} className="btn-primary">
                  <PlusCircle size={15} />
                  <span>Onboard New City</span>
                </button>
              </div>

              <div style={{ overflowX: "auto" }}>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>City Hub</th>
                      <th>State</th>
                      <th>Cluster Operations Lead</th>
                      <th>Verified Technicians</th>
                      <th>Hub Status</th>
                      <th style={{ textAlign: "right" }}>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {cities.map((c) => (
                      <tr key={c.name}>
                        <td>
                          <strong>📍 {c.name}</strong>
                        </td>
                        <td>{c.state}</td>
                        <td>{c.hubLead}</td>
                        <td>{c.partners} specialists</td>
                        <td>
                          <span className="status-tag status-verified">{c.status}</span>
                        </td>
                        <td style={{ textAlign: "right" }}>
                          <button
                            onClick={() => triggerToast(`Viewing detailed operational radar for ${c.name} Hub`)}
                            className="btn-action"
                            style={{ background: "rgba(255,255,255,0.06)", color: "#fff" }}
                          >
                            Manage Hub
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ========================================================= */}
          {/* 14. AUDIT LOGS & MASTER EXPORTS                           */}
          {/* ========================================================= */}
          {activeTab === "audit-logs" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">System Audit Trail & Master Data Backup</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Immutable action logs, gateway webhook receipts, and full system backup
                  </div>
                </div>
                <button
                  onClick={() => {
                    const fullBackup = { analytics, platformFee, cities, services, bookings, payouts, coupons };
                    const jsonStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(fullBackup, null, 2));
                    const link = document.createElement("a");
                    link.setAttribute("href", jsonStr);
                    link.setAttribute("download", `fixit_master_backup_${Date.now()}.json`);
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                    triggerToast("📥 Master JSON backup downloaded successfully!");
                  }}
                  className="btn-primary"
                >
                  <FileSpreadsheet size={15} />
                  <span>Download Master Backup JSON</span>
                </button>
              </div>

              <div style={{ overflowX: "auto" }}>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Timestamp</th>
                      <th>Operator / Actor</th>
                      <th>Audit Event / Action</th>
                      <th>Source IP / Host</th>
                    </tr>
                  </thead>
                  <tbody>
                    {auditLogs.map((log, idx) => (
                      <tr key={idx}>
                        <td><code style={{ fontSize: "11px", color: "var(--text-muted)" }}>{log.time}</code></td>
                        <td><strong>{log.user}</strong></td>
                        <td>{log.action}</td>
                        <td><code style={{ color: "var(--accent-cyan)", fontSize: "11px" }}>{log.ip}</code></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </main>
      </div>

      {/* ========================================================= */}
      {/* MODAL 1: CREATE COUPON                                    */}
      {/* ========================================================= */}
      {showCouponModal && (
        <div className="modal-backdrop">
          <div className="modal-card">
            <div className="modal-header">
              <div style={{ fontWeight: "800", fontSize: "16px" }}>Create Promotional Campaign</div>
              <button onClick={() => setShowCouponModal(false)} style={{ background: "none", border: "none", color: "#fff", cursor: "pointer" }}>
                <X size={18} />
              </button>
            </div>
            <form onSubmit={handleCreateCoupon}>
              <div className="modal-body">
                <div style={{ marginBottom: "14px" }}>
                  <label style={{ fontSize: "11px", fontWeight: "700", color: "var(--text-muted)" }}>PROMO CODE (e.g. SUMMER50)</label>
                  <input
                    type="text"
                    required
                    className="form-input"
                    style={{ width: "100%", marginTop: "6px", textTransform: "uppercase" }}
                    placeholder="e.g. FIXIT2026"
                    value={newCouponForm.code}
                    onChange={(e) => setNewCouponForm({ ...newCouponForm, code: e.target.value })}
                  />
                </div>

                <div style={{ marginBottom: "14px" }}>
                  <label style={{ fontSize: "11px", fontWeight: "700", color: "var(--text-muted)" }}>CAMPAIGN TYPE</label>
                  <select
                    className="form-input"
                    style={{ width: "100%", marginTop: "6px" }}
                    value={newCouponForm.type}
                    onChange={(e) => setNewCouponForm({ ...newCouponForm, type: e.target.value })}
                  >
                    <option value="Flat Discount">Flat Discount (₹)</option>
                    <option value="Fee Waiver">Platform Fee Waiver (100% OFF Fee)</option>
                    <option value="First Time User">Welcome Offer</option>
                  </select>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "12px" }}>
                  <div>
                    <label style={{ fontSize: "11px", fontWeight: "700", color: "var(--text-muted)" }}>DISCOUNT VALUE (₹)</label>
                    <input
                      type="number"
                      required
                      className="form-input"
                      style={{ width: "100%", marginTop: "6px" }}
                      value={newCouponForm.value}
                      onChange={(e) => setNewCouponForm({ ...newCouponForm, value: e.target.value })}
                    />
                  </div>
                  <div>
                    <label style={{ fontSize: "11px", fontWeight: "700", color: "var(--text-muted)" }}>MIN ORDER VALUE (₹)</label>
                    <input
                      type="number"
                      required
                      className="form-input"
                      style={{ width: "100%", marginTop: "6px" }}
                      value={newCouponForm.minOrder}
                      onChange={(e) => setNewCouponForm({ ...newCouponForm, minOrder: e.target.value })}
                    />
                  </div>
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" onClick={() => setShowCouponModal(false)} className="btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn-primary">
                  Launch Promo
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* MODAL 2: ADD CITY HUB                                     */}
      {/* ========================================================= */}
      {showCityModal && (
        <div className="modal-backdrop">
          <div className="modal-card">
            <div className="modal-header">
              <div style={{ fontWeight: "800", fontSize: "16px" }}>Onboard Operational City Hub</div>
              <button onClick={() => setShowCityModal(false)} style={{ background: "none", border: "none", color: "#fff", cursor: "pointer" }}>
                <X size={18} />
              </button>
            </div>
            <form onSubmit={handleAddCityHub}>
              <div className="modal-body">
                <div style={{ marginBottom: "14px" }}>
                  <label style={{ fontSize: "11px", fontWeight: "700", color: "var(--text-muted)" }}>CITY NAME</label>
                  <input
                    type="text"
                    required
                    className="form-input"
                    style={{ width: "100%", marginTop: "6px" }}
                    placeholder="e.g. Navsari, Anand, Morbi, Bharuch"
                    value={newCityName}
                    onChange={(e) => setNewCityName(e.target.value)}
                  />
                </div>

                <div style={{ marginBottom: "14px" }}>
                  <label style={{ fontSize: "11px", fontWeight: "700", color: "var(--text-muted)" }}>CLUSTER OPERATIONS LEAD</label>
                  <input
                    type="text"
                    className="form-input"
                    style={{ width: "100%", marginTop: "6px" }}
                    placeholder="Lead Officer Name"
                    value={newCityLead}
                    onChange={(e) => setNewCityLead(e.target.value)}
                  />
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" onClick={() => setShowCityModal(false)} className="btn-secondary">
                  Cancel
                </button>
                <button type="submit" className="btn-primary">
                  Add Operational Hub
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* MODAL 3: TAX INVOICE & RECEIPT PREVIEW                    */}
      {/* ========================================================= */}
      {showInvoiceModal && (
        <div className="modal-backdrop">
          <div className="modal-card" style={{ maxWidth: "480px" }}>
            <div className="modal-header">
              <div>
                <div style={{ fontWeight: "800", fontSize: "16px" }}>Official Tax Invoice</div>
                <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>Order: {showInvoiceModal.id}</div>
              </div>
              <button onClick={() => setShowInvoiceModal(null)} style={{ background: "none", border: "none", color: "#fff", cursor: "pointer" }}>
                <X size={18} />
              </button>
            </div>
            <div className="modal-body">
              <div style={{ borderBottom: "1px dashed var(--border-subtle)", paddingBottom: "12px", marginBottom: "12px" }}>
                <div style={{ fontSize: "13px", fontWeight: "700" }}>FixIt Home & RSA Services Ltd.</div>
                <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>GSTIN: 24AAACF1234F1Z5 • Gujarat Operations HQ</div>
              </div>

              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "12px", marginBottom: "8px" }}>
                <span style={{ color: "var(--text-muted)" }}>Billed To:</span>
                <strong>{showInvoiceModal.customerName} ({showInvoiceModal.phone})</strong>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "12px", marginBottom: "14px" }}>
                <span style={{ color: "var(--text-muted)" }}>Service Address:</span>
                <span style={{ textAlign: "right", maxWidth: "240px", fontSize: "11px" }}>{showInvoiceModal.address}</span>
              </div>

              <div style={{ background: "rgba(255,255,255,0.03)", padding: "12px", borderRadius: "8px", marginBottom: "14px" }}>
                <div style={{ display: "flex", justifyContent: "space-between", fontSize: "12px", marginBottom: "6px" }}>
                  <span>{showInvoiceModal.serviceName} (Labor)</span>
                  <strong>₹{showInvoiceModal.price}</strong>
                </div>
                <div style={{ display: "flex", justifyContent: "space-between", fontSize: "12px", marginBottom: "6px" }}>
                  <span>FixIt Platform Access Fee</span>
                  <strong>₹{showInvoiceModal.platformFee}</strong>
                </div>
                <div style={{ display: "flex", justifyContent: "space-between", fontSize: "12px", borderTop: "1px solid var(--border-subtle)", paddingTop: "8px" }}>
                  <strong style={{ fontSize: "14px" }}>Total Amount Billed</strong>
                  <strong style={{ fontSize: "16px", color: "#34d399" }}>₹{showInvoiceModal.totalAmount}</strong>
                </div>
              </div>

              <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>
                Paid via {showInvoiceModal.paymentMethod} • Txn ID: {showInvoiceModal.txnId || "txn_live_ok"}
              </div>
            </div>
            <div className="modal-footer">
              <button
                onClick={() => {
                  triggerToast(`📥 Tax Invoice for ${showInvoiceModal.id} downloaded!`);
                  setShowInvoiceModal(null);
                }}
                className="btn-primary"
              >
                <Download size={14} />
                <span>Download PDF Invoice</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* TOAST NOTIFICATION                                        */}
      {/* ========================================================= */}
      {toastMessage && (
        <div className="toast-notice">
          <Sparkles size={16} color="var(--accent-cyan)" />
          <span>{toastMessage}</span>
        </div>
      )}
    </div>
  );
}
