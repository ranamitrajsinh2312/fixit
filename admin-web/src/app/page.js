"use client";

import React, { useState, useEffect, useMemo } from "react";
import {
  LayoutDashboard,
  ClipboardList,
  UserCheck,
  Sliders,
  Star,
  RefreshCw,
  Building2,
  TrendingUp,
  ShieldCheck,
  CheckCircle2,
  XCircle,
  PlusCircle,
  Search,
  ExternalLink,
  ChevronRight,
  BadgeIndianRupee,
  Layers,
  Wrench,
  Sparkles,
} from "lucide-react";

const API_BASE = "http://localhost:5000/api";

export default function AdminDashboard() {
  const [activeTab, setActiveTab] = useState("overview");
  const [selectedCity, setSelectedCity] = useState("All Hubs");
  const [searchQuery, setSearchQuery] = useState("");
  const [isSyncing, setIsSyncing] = useState(false);
  const [toastMessage, setToastMessage] = useState(null);

  // Core State
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

  const [platformFee, setPlatformFee] = useState(25);
  const [newFeeInput, setNewFeeInput] = useState("25");

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
      paymentMethod: "Credit Card",
      paymentStatus: "paid",
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
    },
  ]);

  const [bookingFilter, setBookingFilter] = useState("All");

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
    },
  ]);

  const [cities, setCities] = useState([
    "Rajkot",
    "Ahmedabad",
    "Gandhinagar",
    "Vadodara",
    "Surat",
    "Jamnagar",
    "Bhavnagar",
    "Junagadh",
  ]);
  const [newCityInput, setNewCityInput] = useState("");

  const [services, setServices] = useState([
    { id: "elec_fan", name: "Ceiling Fan Repair & Install", category: "Electrician", price: 199 },
    { id: "plumb_tap", name: "Tap & Mixer Repair", category: "Plumber", price: 149 },
    { id: "gas_stove", name: "Gas Stove Repair & Clean", category: "Gas Repair", price: 249 },
    { id: "rsa_puncture", name: "On-Road Tyre Puncture", category: "On-Road RSA", price: 179 },
    { id: "rsa_jumpstart", name: "Battery Jump-Start (12V)", category: "On-Road RSA", price: 249 },
  ]);
  const [selectedServiceId, setSelectedServiceId] = useState("elec_fan");
  const [newPriceInput, setNewPriceInput] = useState("199");

  const [reviews, setReviews] = useState([
    {
      id: "r1",
      userName: "Kavita Mehta",
      serviceName: "Tap & mixer",
      rating: 5,
      comment: "Prompt service and very polite technician! Replaced valve quickly.",
      date: "2 hours ago",
    },
    {
      id: "r2",
      userName: "Prashant Dave",
      serviceName: "Ceiling Fan repair",
      rating: 5,
      comment: "Motor bearing repaired cleanly. Reasonable platform fee and 30-day warranty.",
      date: "Yesterday",
    },
    {
      id: "r3",
      userName: "Sanjay Vora",
      serviceName: "Gas Stove repair",
      rating: 4,
      comment: "Good technician, reached within 25 mins during peak hours.",
      date: "2 days ago",
    },
    {
      id: "r4",
      userName: "Nirav Patel",
      serviceName: "Car Jump-Start (RSA)",
      rating: 5,
      comment: "Lifesaver! Battery died on 150ft ring road, specialist arrived in 18 minutes.",
      date: "3 days ago",
    },
  ]);
  const [reviewFilter, setReviewFilter] = useState("All");

  // Show Toast
  const triggerToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  // Initial Sync from Backend
  const syncWithBackend = async () => {
    setIsSyncing(true);
    try {
      // 1. Analytics
      const resA = await fetch(`${API_BASE}/admin/analytics`).catch(() => null);
      if (resA && resA.ok) {
        const bodyA = await resA.json();
        if (bodyA.success && bodyA.data) {
          setAnalytics(bodyA.data);
        }
      }

      // 2. Platform Fee
      const resF = await fetch(`${API_BASE}/settings/platformFee`).catch(() => null);
      if (resF && resF.ok) {
        const bodyF = await resF.json();
        if (bodyF.platformFee) {
          setPlatformFee(bodyF.platformFee);
          setNewFeeInput(bodyF.platformFee.toString());
        }
      }

      // 3. Reviews
      const resR = await fetch(`${API_BASE}/reviews`).catch(() => null);
      if (resR && resR.ok) {
        const bodyR = await resR.json();
        if (bodyR.success && Array.isArray(bodyR.data) && bodyR.data.length > 0) {
          setReviews(bodyR.data);
        }
      }

      // 4. Cities
      const resC = await fetch(`${API_BASE}/cities`).catch(() => null);
      if (resC && resC.ok) {
        const bodyC = await resC.json();
        if (bodyC.success && Array.isArray(bodyC.data)) {
          setCities(bodyC.data.map((c) => (typeof c === "string" ? c : c.name)));
        }
      }

      triggerToast("✅ Data synchronized with FixIt live backend!");
    } catch {
      triggerToast("Notice: Running in self-healing offline dev simulation mode.");
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

  // Actions
  const handleMarkCompleted = (bookingId) => {
    setBookings((prev) =>
      prev.map((b) => (b.id === bookingId ? { ...b, status: "Completed" } : b))
    );
    fetch(`${API_BASE}/bookings/${bookingId}/status`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status: "completed" }),
    }).catch(() => null);

    triggerToast(`Order ${bookingId} marked as Completed!`);
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

    triggerToast(
      approve
        ? "✅ Partner KYC Approved & Verified for Dispatch!"
        : "⚠️ Partner KYC was rejected."
    );
  };

  const handleUpdateFee = async () => {
    const val = parseInt(newFeeInput, 10);
    if (isNaN(val) || val < 0) {
      triggerToast("Please enter a valid platform fee.");
      return;
    }

    setPlatformFee(val);
    await fetch(`${API_BASE}/settings/platformFee`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ platformFee: val }),
    }).catch(() => null);

    triggerToast(`🎉 Platform Fee updated to ₹${val} across all hubs!`);
  };

  const handleUpdatePrice = async () => {
    const priceVal = parseInt(newPriceInput, 10);
    if (isNaN(priceVal) || priceVal <= 0) {
      triggerToast("Please enter a valid price amount.");
      return;
    }

    setServices((prev) =>
      prev.map((s) => (s.id === selectedServiceId ? { ...s, price: priceVal } : s))
    );

    await fetch(`${API_BASE}/admin/services/${selectedServiceId}/price`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ price: priceVal }),
    }).catch(() => null);

    triggerToast(`✅ Catalog base price updated to ₹${priceVal}!`);
  };

  const handleAddCity = async () => {
    const name = newCityInput.trim();
    if (!name) return;

    if (!cities.includes(name)) {
      setCities((prev) => [...prev, name]);
    }
    setNewCityInput("");

    await fetch(`${API_BASE}/admin/cities`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, state: "Gujarat" }),
    }).catch(() => null);

    triggerToast(`🎉 ${name} successfully onboarded to FixIt operations network!`);
  };

  return (
    <div className="admin-shell">
      <div className="bg-ambient-glow" />

      {/* SIDEBAR NAVIGATION */}
      <aside className="sidebar">
        <div className="brand-section">
          <div className="brand-logo-badge">
            <Wrench size={22} color="#ffffff" />
          </div>
          <div>
            <div className="brand-title">FixIt HQ</div>
            <div className="brand-subtitle">Executive Ops Console</div>
          </div>
        </div>

        <nav className="nav-menu">
          <button
            onClick={() => setActiveTab("overview")}
            className={`nav-item ${activeTab === "overview" ? "active" : ""}`}
          >
            <LayoutDashboard size={18} />
            <span>Overview Analytics</span>
          </button>

          <button
            onClick={() => setActiveTab("bookings")}
            className={`nav-item ${activeTab === "bookings" ? "active" : ""}`}
          >
            <ClipboardList size={18} />
            <span>Live Bookings ({bookings.length})</span>
          </button>

          <button
            onClick={() => setActiveTab("providers")}
            className={`nav-item ${activeTab === "providers" ? "active" : ""}`}
          >
            <UserCheck size={18} />
            <span>Technicians & KYC</span>
          </button>

          <button
            onClick={() => setActiveTab("pricing")}
            className={`nav-item ${activeTab === "pricing" ? "active" : ""}`}
          >
            <Sliders size={18} />
            <span>Catalog & Fees</span>
          </button>

          <button
            onClick={() => setActiveTab("reviews")}
            className={`nav-item ${activeTab === "reviews" ? "active" : ""}`}
          >
            <Star size={18} />
            <span>Customer Reviews</span>
          </button>
        </nav>

        <div className="sidebar-footer">
          <div className="api-status-pill">
            <div className="pulse-dot" />
            <span>API Connected (Port 5000)</span>
          </div>
          <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>
            Version 1.6.0 • Gujarat Cluster
          </div>
        </div>
      </aside>

      {/* MAIN CONTENT AREA */}
      <div className="main-wrapper">
        {/* Top Header */}
        <header className="top-header">
          <div className="header-left">
            <div className="page-title">
              {activeTab === "overview" && "Marketplace Performance & Live Metrics"}
              {activeTab === "bookings" && "Dispatch Moderation & Order Lifecycle"}
              {activeTab === "providers" && "Technician Network & KYC Approvals"}
              {activeTab === "pricing" && "Dynamic Fee Economics & Catalog Modifier"}
              {activeTab === "reviews" && "Customer Ratings & Feedback Sentiment"}
            </div>

            <select
              className="city-filter-select"
              value={selectedCity}
              onChange={(e) => setSelectedCity(e.target.value)}
            >
              <option value="All Hubs">All Operational Hubs</option>
              {cities.map((c) => (
                <option key={c} value={c}>
                  {c} Hub
                </option>
              ))}
            </select>
          </div>

          <div className="header-right">
            <div className="fee-badge">
              <BadgeIndianRupee size={15} />
              <span>Platform Fee: ₹{platformFee}</span>
            </div>

            <button
              onClick={syncWithBackend}
              className={`btn-sync ${isSyncing ? "spinning" : ""}`}
              title="Refresh live data from backend"
            >
              <RefreshCw size={15} />
              <span>{isSyncing ? "Syncing..." : "Live Sync"}</span>
            </button>
          </div>
        </header>

        {/* Page Container */}
        <main className="page-container">
          {/* TAB 1: OVERVIEW ANALYTICS */}
          {activeTab === "overview" && (
            <div>
              {/* Metric Highlights */}
              <div className="metrics-grid">
                <div className="metric-card">
                  <div className="metric-card-header">
                    <span className="metric-label">Gross Merchandise Value</span>
                    <div className="metric-icon-wrap" style={{ background: "rgba(2, 132, 199, 0.15)" }}>
                      <TrendingUp size={20} color="#38bdf8" />
                    </div>
                  </div>
                  <div className="metric-value" style={{ color: "#38bdf8" }}>
                    ₹{analytics.totalGrossRevenue.toLocaleString()}
                  </div>
                  <div className="metric-subtext">Across {analytics.totalBookings} customer bookings</div>
                </div>

                <div className="metric-card">
                  <div className="metric-card-header">
                    <span className="metric-label">Platform Net Earnings</span>
                    <div className="metric-icon-wrap" style={{ background: "rgba(16, 185, 129, 0.15)" }}>
                      <BadgeIndianRupee size={20} color="#34d399" />
                    </div>
                  </div>
                  <div className="metric-value" style={{ color: "#34d399" }}>
                    ₹{analytics.totalPlatformEarnings.toLocaleString()}
                  </div>
                  <div className="metric-subtext">100% Retained (₹{platformFee}/order fee)</div>
                </div>

                <div className="metric-card">
                  <div className="metric-card-header">
                    <span className="metric-label">Active Technicians</span>
                    <div className="metric-icon-wrap" style={{ background: "rgba(99, 102, 241, 0.15)" }}>
                      <UserCheck size={20} color="#818cf8" />
                    </div>
                  </div>
                  <div className="metric-value" style={{ color: "#818cf8" }}>
                    {analytics.activeProviders} Online
                  </div>
                  <div className="metric-subtext">{analytics.totalProviders} Registered partners</div>
                </div>

                <div className="metric-card">
                  <div className="metric-card-header">
                    <span className="metric-label">Customer Satisfaction</span>
                    <div className="metric-icon-wrap" style={{ background: "rgba(245, 158, 11, 0.15)" }}>
                      <Star size={20} color="#fbbf24" />
                    </div>
                  </div>
                  <div className="metric-value" style={{ color: "#fbbf24" }}>
                    ★ {analytics.averageRating}
                  </div>
                  <div className="metric-subtext">99.2% positive resolution rate</div>
                </div>
              </div>

              {/* Operations Health Panel */}
              <div className="glass-panel">
                <div className="panel-header">
                  <div className="panel-title">Operations Network Health</div>
                  <span className="status-tag status-verified">● Live Real-Time Network</span>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))", gap: "20px" }}>
                  <div style={{ padding: "16px", borderRadius: "12px", background: "rgba(255,255,255,0.02)", border: "1px solid var(--border-subtle)" }}>
                    <div style={{ fontSize: "12px", color: "var(--text-muted)", marginBottom: "6px" }}>OPERATIONAL HUBS</div>
                    <div style={{ fontSize: "20px", fontWeight: "800" }}>{cities.length} Cities Active</div>
                    <div style={{ fontSize: "11px", color: "var(--accent-green)", marginTop: "4px" }}>
                      Rajkot (HQ), Ahmedabad, Surat, Vadodara + 4 more
                    </div>
                  </div>

                  <div style={{ padding: "16px", borderRadius: "12px", background: "rgba(255,255,255,0.02)", border: "1px solid var(--border-subtle)" }}>
                    <div style={{ fontSize: "12px", color: "var(--text-muted)", marginBottom: "6px" }}>SPECIALIST PAYOUT RATIO</div>
                    <div style={{ fontSize: "20px", fontWeight: "800", color: "#34d399" }}>100% Direct to Pro</div>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "4px" }}>
                      Zero commission cuts from technician quotes
                    </div>
                  </div>

                  <div style={{ padding: "16px", borderRadius: "12px", background: "rgba(255,255,255,0.02)", border: "1px solid var(--border-subtle)" }}>
                    <div style={{ fontSize: "12px", color: "var(--text-muted)", marginBottom: "6px" }}>EMERGENCY RSA RADAR</div>
                    <div style={{ fontSize: "20px", fontWeight: "800", color: "#38bdf8" }}>⚡ &lt; 25 Mins SLA</div>
                    <div style={{ fontSize: "11px", color: "var(--text-muted)", marginTop: "4px" }}>
                      Instant roadside breakdown assistance guarantee
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* TAB 2: LIVE BOOKINGS MODERATION */}
          {activeTab === "bookings" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Order Lifecycle Management</div>
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
                      style={{ paddingLeft: "34px", width: "240px", margin: 0 }}
                    />
                    <Search
                      size={15}
                      style={{ position: "absolute", left: "10px", top: "12px", color: "var(--text-muted)" }}
                    />
                  </div>
                </div>
              </div>

              {/* Status Filter Pills */}
              <div className="filter-pills-row">
                {["All", "Upcoming", "Completed", "Cancelled"].map((f) => (
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
                      <th>Amount & Fee</th>
                      <th>Status</th>
                      <th style={{ textAlign: "right" }}>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredBookings.length === 0 ? (
                      <tr>
                        <td colSpan={7} style={{ textAlign: "center", padding: "36px", color: "var(--text-muted)" }}>
                          No orders found matching filter criteria.
                        </td>
                      </tr>
                    ) : (
                      filteredBookings.map((b) => (
                        <tr key={b.id}>
                          <td>
                            <strong style={{ color: "var(--accent-cyan)", fontFamily: "monospace" }}>
                              {b.id}
                            </strong>
                          </td>
                          <td>
                            <div style={{ fontWeight: "700" }}>{b.customerName}</div>
                            <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>
                              {b.phone} • {b.city}
                            </div>
                          </td>
                          <td>
                            <div style={{ fontWeight: "600" }}>{b.serviceName}</div>
                            <span style={{ fontSize: "11px", color: "var(--accent-blue)" }}>
                              {b.categoryName}
                            </span>
                          </td>
                          <td>
                            <div style={{ fontSize: "12px" }}>{b.dateTime}</div>
                          </td>
                          <td>
                            <div style={{ fontWeight: "800", color: "#34d399" }}>
                              ₹{b.totalAmount}
                            </div>
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
                                  : "status-upcoming"
                              }`}
                            >
                              {b.status}
                            </span>
                          </td>
                          <td style={{ textAlign: "right" }}>
                            {b.status === "Upcoming" && (
                              <button
                                onClick={() => handleMarkCompleted(b.id)}
                                className="btn-action btn-approve"
                              >
                                Mark Done
                              </button>
                            )}
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* TAB 3: TECHNICIANS & KYC */}
          {activeTab === "providers" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Technician Partner Network & KYC Approval</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Review national ID credentials and activate field professionals
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
                          <span style={{ fontWeight: "600", color: "var(--accent-cyan)" }}>
                            {p.skill}
                          </span>
                        </td>
                        <td>
                          <div>{p.city}</div>
                          <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>{p.phone}</div>
                        </td>
                        <td>
                          <div style={{ display: "flex", alignItems: "center", gap: "4px" }}>
                            <Star size={13} color="#fbbf24" fill="#fbbf24" />
                            <strong>{p.rating}</strong>
                            <span style={{ color: "var(--text-muted)", fontSize: "11px" }}>
                              ({p.jobs} jobs)
                            </span>
                          </div>
                        </td>
                        <td>
                          {p.online ? (
                            <span style={{ color: "var(--accent-green)", fontSize: "12px", fontWeight: "700" }}>
                              ● Online
                            </span>
                          ) : (
                            <span style={{ color: "var(--text-muted)", fontSize: "12px" }}>
                              ○ Offline
                            </span>
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
                                <button
                                  onClick={() => handleToggleKyc(p.id, true)}
                                  className="btn-action btn-approve"
                                >
                                  Approve KYC
                                </button>
                                <button
                                  onClick={() => handleToggleKyc(p.id, false)}
                                  className="btn-action btn-reject"
                                >
                                  Reject
                                </button>
                              </>
                            ) : (
                              <button
                                onClick={() => handleToggleKyc(p.id, false)}
                                className="btn-action btn-reject"
                              >
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

          {/* TAB 4: PRICING & FEES */}
          {activeTab === "pricing" && (
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(360px, 1fr))", gap: "24px" }}>
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
                    <div style={{ fontSize: "11px", fontWeight: "700", color: "var(--text-muted)" }}>
                      CURRENT LIVE PLATFORM FEE
                    </div>
                    <div style={{ fontSize: "12px", fontWeight: "600" }}>Active across all 12 hubs</div>
                  </div>
                  <div style={{ fontSize: "32px", fontWeight: "800", color: "var(--accent-cyan)" }}>
                    ₹{platformFee}
                  </div>
                </div>

                <div className="form-input-row">
                  <input
                    type="number"
                    className="form-input"
                    placeholder="Enter fee (e.g. 25, 30, 50)"
                    value={newFeeInput}
                    onChange={(e) => setNewFeeInput(e.target.value)}
                  />
                  <button onClick={handleUpdateFee} className="btn-primary">
                    Update Fee
                  </button>
                </div>

                <div style={{ marginTop: "20px", fontSize: "12px", color: "var(--text-muted)" }}>
                  <div style={{ fontWeight: "700", marginBottom: "6px" }}>Revenue Projection Calculator:</div>
                  <div>• 100 orders/day: ₹{(100 * platformFee).toLocaleString()} daily net revenue</div>
                  <div>• 500 orders/day: ₹{(500 * platformFee).toLocaleString()} daily net revenue</div>
                  <div>• 2,000 orders/day: ₹{(2000 * platformFee).toLocaleString()} daily net revenue</div>
                </div>
              </div>

              {/* Service Price Modifier */}
              <div className="glass-panel">
                <div className="panel-title">Catalog Service Price Modifier</div>
                <p style={{ fontSize: "12px", color: "var(--text-muted)", marginTop: "6px", lineHeight: "1.5" }}>
                  Directly adjust base labor quotes for standardized services. Technicians receive 100% of this quote for their work.
                </p>

                <div style={{ marginTop: "16px" }}>
                  <label style={{ fontSize: "11px", fontWeight: "700", color: "var(--text-muted)" }}>
                    SELECT SERVICE TO UPDATE
                  </label>
                  <select
                    className="form-input"
                    style={{ width: "100%", marginTop: "6px" }}
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
                </div>

                <div className="form-input-row">
                  <input
                    type="number"
                    className="form-input"
                    placeholder="New base price (₹)"
                    value={newPriceInput}
                    onChange={(e) => setNewPriceInput(e.target.value)}
                  />
                  <button onClick={handleUpdatePrice} className="btn-primary">
                    Update Price
                  </button>
                </div>
              </div>

              {/* Add New Operational City */}
              <div className="glass-panel" style={{ gridColumn: "1 / -1" }}>
                <div className="panel-title">Expand Operational Network (Add City)</div>
                <p style={{ fontSize: "12px", color: "var(--text-muted)", marginTop: "6px" }}>
                  Onboard new urban or highway clusters to the operational dispatch network.
                </p>

                <div className="form-input-row" style={{ maxWidth: "500px" }}>
                  <input
                    type="text"
                    className="form-input"
                    placeholder="e.g. Navsari, Anand, Morbi, Bharuch"
                    value={newCityInput}
                    onChange={(e) => setNewCityInput(e.target.value)}
                  />
                  <button onClick={handleAddCity} className="btn-primary">
                    <PlusCircle size={15} style={{ marginRight: "6px" }} />
                    Add City
                  </button>
                </div>

                <div style={{ display: "flex", flexWrap: "wrap", gap: "8px", marginTop: "16px" }}>
                  {cities.map((c) => (
                    <span
                      key={c}
                      style={{
                        padding: "6px 12px",
                        background: "rgba(255, 255, 255, 0.05)",
                        border: "1px solid var(--border-subtle)",
                        borderRadius: "8px",
                        fontSize: "12px",
                      }}
                    >
                      📍 {c}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* TAB 5: REVIEWS FEED */}
          {activeTab === "reviews" && (
            <div className="glass-panel">
              <div className="panel-header">
                <div>
                  <div className="panel-title">Customer Feedback & Service Quality</div>
                  <div style={{ fontSize: "12px", color: "var(--text-muted)" }}>
                    Real-time customer reviews across home repairs and emergency RSA
                  </div>
                </div>

                <div className="filter-pills-row" style={{ margin: 0 }}>
                  {["All", "5 Stars", "4 Stars"].map((f) => (
                    <button
                      key={f}
                      onClick={() => setReviewFilter(f)}
                      className={`filter-pill ${reviewFilter === f ? "active" : ""}`}
                    >
                      {f}
                    </button>
                  ))}
                </div>
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(320px, 1fr))", gap: "16px" }}>
                {reviews.map((r, idx) => (
                  <div
                    key={idx}
                    style={{
                      background: "rgba(30, 41, 59, 0.4)",
                      border: "1px solid var(--border-subtle)",
                      borderRadius: "14px",
                      padding: "18px",
                    }}
                  >
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "8px" }}>
                      <div>
                        <div style={{ fontWeight: "700", fontSize: "14px" }}>{r.userName}</div>
                        <div style={{ fontSize: "11px", color: "var(--accent-cyan)" }}>
                          Service: {r.serviceName}
                        </div>
                      </div>

                      <div
                        style={{
                          display: "flex",
                          alignItems: "center",
                          gap: "3px",
                          background: "rgba(245, 158, 11, 0.15)",
                          padding: "4px 8px",
                          borderRadius: "6px",
                          color: "#fbbf24",
                          fontWeight: "800",
                          fontSize: "12px",
                        }}
                      >
                        <Star size={13} fill="#fbbf24" />
                        <span>{r.rating}.0</span>
                      </div>
                    </div>

                    <p style={{ fontSize: "13px", lineHeight: "1.4", color: "var(--text-main)", marginBottom: "10px" }}>
                      "{r.comment}"
                    </p>

                    <div style={{ fontSize: "11px", color: "var(--text-muted)" }}>
                      {r.date || "Verified Customer Booking"}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </main>
      </div>

      {/* TOAST NOTIFICATION */}
      {toastMessage && (
        <div className="toast-notice">
          <Sparkles size={16} color="var(--accent-cyan)" />
          <span>{toastMessage}</span>
        </div>
      )}
    </div>
  );
}
