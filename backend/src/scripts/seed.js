import dotenv from 'dotenv';
import mongoose from 'mongoose';
import { connectDB } from '../config/db.js';
import {
  City,
  Category,
  Service,
  Provider,
  Booking,
  Payment,
  Setting,
  User,
  Review,
} from '../models/index.js';

dotenv.config();

const seedData = async () => {
  try {
    await connectDB();
    console.log('[Seed] Connected to database. Clearing existing collections...');

    await City.deleteMany({});
    await Category.deleteMany({});
    await Service.deleteMany({});
    await Provider.deleteMany({});
    await Booking.deleteMany({});
    await Payment.deleteMany({});
    await Setting.deleteMany({});
    await User.deleteMany({});
    await Review.deleteMany({});

    // 1. Seed Cities
    const cityNames = [
      'Rajkot', 'Ahmedabad', 'Gandhinagar', 'Vadodara', 'Surat',
      'Jamnagar', 'Bhavnagar', 'Junagadh', 'Mumbai', 'Pune', 'Delhi', 'Bengaluru'
    ];
    await City.insertMany(cityNames.map(name => ({ name })));
    console.log(`[Seed] Seeded ${cityNames.length} operational cities.`);

    // 2. Seed Settings
    await Setting.create({
      key: 'platformFee',
      value: 25,
      description: 'Default platform commission fee in INR per service booking',
    });
    console.log('[Seed] Seeded platformFee setting (₹25).');

    // 3. Seed Categories & Services
    const categoriesData = [
      {
        id: 'electrician',
        name: 'Electrician',
        iconName: 'electrical_services',
        colorHex: '#F59E0B',
        services: [
          { id: 'fan_repair', name: 'Fan repair', desc: 'Motor, capacitor, bearing or speed regulator fix', price: 199 },
          { id: 'switch_socket', name: 'Switch & socket', desc: 'Replace or repair switches and power plugs', price: 149 },
          { id: 'wiring_mcb', name: 'Wiring & MCB', desc: 'Short circuit check, breaker and wiring maintenance', price: 299 },
          { id: 'light_fitting', name: 'Light fitting', desc: 'Chandelier, LED tube, fancy light mounting', price: 179 },
          { id: 'inverter_battery', name: 'Inverter & battery', desc: 'Backup check, terminal cleaning and acid top-up', price: 399 },
        ],
      },
      {
        id: 'plumber',
        name: 'Plumber',
        iconName: 'plumbing',
        colorHex: '#0EA5E9',
        services: [
          { id: 'tap_mixer', name: 'Tap & mixer', desc: 'Dripping tap, mixer cartridge or valve replacement', price: 149 },
          { id: 'pipe_leakage', name: 'Pipe leakage', desc: 'Concealed or open pipe leak detection and sealing', price: 249 },
          { id: 'blockage_clearing', name: 'Blockage clearing', desc: 'Drain, sink, toilet and pipe clearing', price: 299 },
          { id: 'tank_cleaning', name: 'Tank cleaning', desc: 'Overhead PVC/RCC tank deep desludge and UV clean', price: 599 },
          { id: 'bathroom_fittings', name: 'Bathroom fittings', desc: 'Shower, towel rod, health faucet installation', price: 349 },
        ],
      },
      {
        id: 'gas_repair',
        name: 'Gas Repair',
        iconName: 'local_fire_department',
        colorHex: '#EF4444',
        services: [
          { id: 'stove_repair', name: 'Stove repair', desc: 'Burner clean, low flame fix and auto-ignition fix', price: 249 },
          { id: 'gas_leak_check', name: 'Gas leak check', desc: 'High-precision pipe, valve and regulator inspection', price: 299 },
          { id: 'pipe_installation', name: 'Pipe installation', desc: 'Steel braided or rubber pipe fitting and testing', price: 499 },
          { id: 'gas_geyser_repair', name: 'Gas geyser repair', desc: 'Pilot light, burner and sensor service', price: 399 },
        ],
      },
      {
        id: 'furniture',
        name: 'Carpenter / Furniture',
        iconName: 'chair',
        colorHex: '#92400E',
        services: [
          { id: 'door_lock_repair', name: 'Door & lock repair', desc: 'Hinges, mortise lock and latch fixing', price: 249 },
          { id: 'bed_sofa_repair', name: 'Bed / sofa repair', desc: 'Joint tightening, hydraulic lift and frame repair', price: 399 },
          { id: 'furniture_assembly', name: 'Furniture assembly', desc: 'Wardrobe, desk, table, TV unit assembly', price: 349 },
          { id: 'modular_kitchen_fix', name: 'Modular kitchen fix', desc: 'Telescopic drawer channel and soft-close hinges', price: 599 },
          { id: 'curtain_rod_fitting', name: 'Curtain rod fitting', desc: 'Drilling and rod mounting per window', price: 199 },
        ],
      },
      {
        id: 'ac_repair',
        name: 'AC Repair',
        iconName: 'ac_unit',
        colorHex: '#06B6D4',
        services: [
          { id: 'ac_service', name: 'AC service', desc: 'Jet-pump indoor filter wash and cooling coil flush', price: 499 },
          { id: 'gas_refill', name: 'Gas refill', desc: 'Leak detection, vacuum and complete gas recharge', price: 1499 },
          { id: 'ac_installation', name: 'Installation', desc: 'Split/window indoor and outdoor unit mounting', price: 999 },
          { id: 'ac_uninstall', name: 'Uninstall', desc: 'Refrigerant lock, bracket dismantle and packing', price: 499 },
        ],
      },
      {
        id: 'appliance_repair',
        name: 'Appliance Repair',
        iconName: 'kitchen',
        colorHex: '#6366F1',
        services: [
          { id: 'washing_machine', name: 'Washing machine', desc: 'Drum spin, water intake, drain pump or PCB fix', price: 399 },
          { id: 'refrigerator', name: 'Refrigerator', desc: 'Cooling coil, thermostat, defrost sensor fix', price: 399 },
          { id: 'microwave_oven', name: 'Microwave / oven', desc: 'Magnetron, heating element, touch panel repair', price: 299 },
          { id: 'electric_geyser', name: 'Electric geyser', desc: 'Heating coil replacement and thermostat reset', price: 349 },
          { id: 'tv_repair', name: 'TV', desc: 'Display backlight, power supply and audio repair', price: 399 },
        ],
      },
      {
        id: 'ro_purifier',
        name: 'RO / Water Purifier',
        iconName: 'water_drop',
        colorHex: '#3B82F6',
        services: [
          { id: 'ro_service', name: 'RO service', desc: 'TDS test, membrane flush and UV check', price: 299 },
          { id: 'filter_change', name: 'Filter change', desc: 'Sediment, pre-carbon, post-carbon cartridge change', price: 599 },
          { id: 'ro_installation', name: 'RO installation', desc: 'Wall mounting and diverter pipe routing', price: 499 },
        ],
      },
      {
        id: 'home_cleaning',
        name: 'Home Cleaning',
        iconName: 'cleaning_services',
        colorHex: '#10B981',
        services: [
          { id: 'full_home_deep_clean', name: 'Full home deep clean', desc: 'Complete floor scrubbing, window rails and dusting', price: 1499 },
          { id: 'kitchen_clean', name: 'Kitchen', desc: 'Degreasing, chimney exterior, exhaust fan and tile wash', price: 799 },
          { id: 'bathroom_clean', name: 'Bathroom', desc: 'Tile stain removal, pot sanitation and tap buffing', price: 499 },
          { id: 'sofa_carpet_clean', name: 'Sofa & carpet', desc: 'Shampoo extraction machine wash', price: 699 },
          { id: 'water_tank_clean', name: 'Water tank', desc: 'Sludge extraction and mechanized jet wash', price: 699 },
        ],
      },
      {
        id: 'pest_control',
        name: 'Pest Control',
        iconName: 'bug_report',
        colorHex: '#84CC16',
        services: [
          { id: 'cockroach_ants', name: 'Cockroach / ants', desc: 'Odorless gel baiting in kitchen and spray', price: 599 },
          { id: 'termite_treatment', name: 'Termite', desc: 'Drill-fill-seal chemical barrier protection', price: 1199 },
          { id: 'mosquito_control', name: 'Mosquito', desc: 'Indoor residual thermal fogging and wall perimeter spray', price: 499 },
          { id: 'bed_bugs', name: 'Bed bugs', desc: '2-visit intensive steam and contact spray', price: 899 },
        ],
      },
      {
        id: 'painting',
        name: 'Painting',
        iconName: 'format_paint',
        colorHex: '#EC4899',
        services: [
          { id: 'room_painting', name: 'Room painting', desc: '2 coats premium interior emulsion with masking', price: 1999 },
          { id: 'full_home_painting', name: 'Full home', desc: 'Putty, primer, sanding and dual coat emulsion', price: 6999 },
          { id: 'waterproofing', name: 'Waterproofing', desc: 'Seepage chemical injection and elastomeric coat', price: 2499 },
          { id: 'wall_touchup', name: 'Wall touch-up', desc: 'Minor patch plaster and spot paint matching', price: 899 },
        ],
      },
      {
        id: 'mason_civil',
        name: 'Mason / Civil',
        iconName: 'construction',
        colorHex: '#F97316',
        services: [
          { id: 'tile_fitting', name: 'Tile fitting', desc: 'Hollow tile replacement and epoxy grouting', price: 799 },
          { id: 'wall_repair', name: 'Wall repair', desc: 'Plaster crack fixing and brickwork patching', price: 499 },
          { id: 'bathroom_renovation', name: 'Bathroom renovation', desc: 'Line relocation, slope correction and tile revamping', price: 3499 },
          { id: 'false_ceiling', name: 'False ceiling', desc: 'Gypsum framing and cove lighting repair', price: 1899 },
        ],
      },
      {
        id: 'cctv_security',
        name: 'CCTV & Security',
        iconName: 'videocam',
        colorHex: '#14B8A6',
        services: [
          { id: 'cctv_installation', name: 'CCTV installation', desc: 'Bullet/dome camera mounting, DVR setup and wiring', price: 699 },
          { id: 'cctv_repair', name: 'CCTV repair', desc: 'No signal, HDD error or power supply fix', price: 399 },
          { id: 'video_door_phone', name: 'Video door phone', desc: 'Outdoor camera and indoor screen setup', price: 899 },
          { id: 'smart_lock', name: 'Smart lock', desc: 'Biometric fingerprint lock mortising and setup', price: 999 },
        ],
      },
      {
        id: 'mobile_laptop',
        name: 'Mobile & Laptop',
        iconName: 'devices',
        colorHex: '#8B5CF6',
        services: [
          { id: 'screen_repair', name: 'Screen repair', desc: 'OEM glass and touch display replacement', price: 1299 },
          { id: 'mobile_battery', name: 'Mobile battery', desc: 'Original battery replacement with warranty', price: 699 },
          { id: 'laptop_repair', name: 'Laptop repair', desc: 'RAM/SSD upgrade, OS and thermal paste service', price: 799 },
          { id: 'wifi_router_setup', name: 'Wi-Fi / router setup', desc: 'Router config, range extender and LAN cabling', price: 299 },
        ],
      },
      {
        id: 'packers_movers',
        name: 'Packers & Movers',
        iconName: 'local_shipping',
        colorHex: '#64748B',
        services: [
          { id: 'bhk_1', name: '1 BHK', desc: 'Packing team, bubble wrapping and relocation', price: 3999 },
          { id: 'bhk_2_3', name: '2-3 BHK', desc: 'Dismantle, pack, transit and reassemble', price: 6999 },
          { id: 'bike_car_transport', name: 'Bike / car transport', desc: 'Enclosed carrier transit with insurance', price: 2499 },
          { id: 'mini_truck', name: 'Mini truck', desc: 'Pickup truck with driver for local room shifting', price: 1199 },
        ],
      },
      {
        id: 'vehicle_care',
        name: 'Vehicle Care',
        iconName: 'directions_car',
        colorHex: '#D97706',
        services: [
          { id: 'bike_service', name: 'Bike service', desc: 'Engine oil, spark plug and brake tuning', price: 499 },
          { id: 'car_wash', name: 'Car wash', desc: 'Foam exterior wash, vacuum and interior polish', price: 399 },
          { id: 'battery_jump_start', name: 'Battery jump-start', desc: 'Rapid on-spot breakdown cable assistance', price: 249 },
          { id: 'puncture_repair', name: 'Puncture repair', desc: 'Tubeless tyre puncture repair and air top-up', price: 149 },
        ],
      },
      {
        id: 'salon_wellness',
        name: 'Salon & Wellness',
        iconName: 'spa',
        colorHex: '#F43F5E',
        services: [
          { id: 'mens_haircut', name: 'Men’s haircut', desc: 'Haircut, beard trim and neck massage at home', price: 199 },
          { id: 'womens_salon', name: 'Women’s salon', desc: 'Waxing, facial, clean-up, threading pack', price: 599 },
          { id: 'massage', name: 'Massage', desc: 'Full body Swedish or deep tissue therapy', price: 899 },
          { id: 'mehendi_artist', name: 'Mehendi artist', desc: 'Arabic or bridal cone art for hands', price: 499 },
        ],
      },
      {
        id: 'on_road_mechanic',
        name: 'On-Road Mechanic (RSA)',
        iconName: 'car_repair',
        colorHex: '#DC2626',
        services: [
          { id: 'bike_onroad_breakdown', name: 'Bike on-road breakdown', desc: 'Clutch cable, chain, spark plug, minor stalling fix', price: 199 },
          { id: 'car_onroad_breakdown', name: 'Car on-road breakdown', desc: 'Overheating, starter, alternator, on-spot fix', price: 399 },
          { id: 'battery_jumpstart_rsa', name: 'Battery jump-start', desc: '12V/24V heavy-duty booster cables, terminal clean', price: 249 },
          { id: 'puncture_air_rsa', name: 'On-spot tyre puncture', desc: 'Tubeless strip repair, wheel change, air top-up', price: 179 },
          { id: 'emergency_fuel_rsa', name: 'Emergency fuel delivery', desc: '3L-5L petrol or diesel canister delivered on-spot', price: 199 },
          { id: 'towing_service_rsa', name: 'Vehicle towing service', desc: 'Flatbed or hydraulic wheel-lift towing to garage', price: 899 },
          { id: 'car_lockout_rsa', name: 'Key lockout assistance', desc: 'Safe non-destructive vehicle door unlocking', price: 449 },
        ],
      },
      {
        id: 'generic_mechanic',
        name: 'General Mechanic & Tools',
        iconName: 'handyman',
        colorHex: '#EA580C',
        services: [
          { id: 'water_pump_repair', name: 'Water pump & motor repair', desc: 'Submersible, monoblock, capacitor & winding fix', price: 349 },
          { id: 'generator_inverter_engine', name: 'Portable generator repair', desc: 'Engine oil, carburetor, pull starter & spark plug', price: 499 },
          { id: 'drill_cut_weld_job', name: 'Spot welding & metal repair', desc: 'Gate latch, hinge welding, metal railing repair', price: 399 },
          { id: 'shutter_rolling_fix', name: 'Rolling shutter repair', desc: 'Spring tensioning, gear lubrication, lock repair', price: 499 },
          { id: 'sewing_machine_repair', name: 'Sewing machine repair', desc: 'Needle timing, motor belt, tensioner, lubrication', price: 249 },
          { id: 'pressure_washer_tool', name: 'Power tools service', desc: 'Drill machine, angle grinder, cutter & washer repair', price: 299 },
        ],
      },
      {
        id: 'emergency_locksmith',
        name: 'Emergency Locksmith',
        iconName: 'lock_open',
        colorHex: '#4F46E5',
        services: [
          { id: 'door_lock_emergency', name: 'Emergency door unlock', desc: 'Jammed latch, deadbolt unlock, broken key extraction', price: 299 },
          { id: 'cupboard_safe_lock', name: 'Cupboard & safe locker fix', desc: 'Godrej lever repair, locker key, safe combination reset', price: 399 },
          { id: 'smart_door_lock_reset', name: 'Smart digital lock reset', desc: 'Biometric, PIN pad reprogram & RFID card configuration', price: 499 },
          { id: 'key_cutting_doorstep', name: 'Duplicate key cutting', desc: 'Computerized laser-cut duplicate keys on-spot', price: 199 },
        ],
      },
    ];

    let totalServicesCount = 0;
    for (const cat of categoriesData) {
      await Category.create({
        id: cat.id,
        name: cat.name,
        iconName: cat.iconName,
        colorHex: cat.colorHex,
      });

      for (const s of cat.services) {
        await Service.create({
          id: s.id,
          categoryId: cat.id,
          name: s.name,
          desc: s.desc,
          price: s.price,
          included: [
            'Inspection & diagnosis',
            'Repair by verified professional',
            '30-day service warranty',
            'Spare parts charged extra if needed',
          ],
          rating: 4.8,
          reviewsCount: 1100 + Math.floor(Math.random() * 800),
        });
        totalServicesCount++;
      }
    }
    console.log(`[Seed] Seeded ${categoriesData.length} categories with ${totalServicesCount} services.`);

    // 4. Seed Verified Providers
    const providersData = [
      { name: 'Ramesh Sharma', phone: '+91 98250 11223', categoryId: 'electrician', categoryName: 'Electrician', city: 'Rajkot', rating: 4.9, completedJobs: 142, totalEarnings: 28400 },
      { name: 'Haresh Solanki', phone: '+91 98250 22334', categoryId: 'plumber', categoryName: 'Plumber', city: 'Rajkot', rating: 4.8, completedJobs: 98, totalEarnings: 19600 },
      { name: 'Kanti Mistry', phone: '+91 98250 33445', categoryId: 'furniture', categoryName: 'Carpenter / Furniture', city: 'Rajkot', rating: 4.9, completedJobs: 76, totalEarnings: 22800 },
      { name: 'Jignesh Makwana', phone: '+91 98250 44556', categoryId: 'gas_repair', categoryName: 'Gas Repair', city: 'Rajkot', rating: 4.7, completedJobs: 64, totalEarnings: 16000 },
      { name: 'Deepak Vaghela', phone: '+91 98250 55667', categoryId: 'ac_repair', categoryName: 'AC Repair', city: 'Rajkot', rating: 4.9, completedJobs: 210, totalEarnings: 84000 },
      { name: 'Vikram Chauhan', phone: '+91 98250 66778', categoryId: 'on_road_mechanic', categoryName: 'On-Road Mechanic (RSA)', city: 'Rajkot', rating: 4.9, completedJobs: 185, totalEarnings: 46250 },
      { name: 'Mansukhbhai Panchal', phone: '+91 98250 77889', categoryId: 'generic_mechanic', categoryName: 'General Mechanic & Tools', city: 'Rajkot', rating: 4.8, completedJobs: 112, totalEarnings: 33600 },
      { name: 'Sanjay Rathod', phone: '+91 98250 88990', categoryId: 'emergency_locksmith', categoryName: 'Emergency Locksmith', city: 'Rajkot', rating: 4.9, completedJobs: 94, totalEarnings: 28200 },
    ];
    await Provider.insertMany(providersData);
    console.log(`[Seed] Seeded ${providersData.length} verified service providers.`);

    // 5. Seed Initial Sample Bookings
    const bookingsData = [
      {
        bookingId: 'FX-91204',
        customerName: 'Devang Patel',
        customerPhone: '+91 98795 43210',
        providerName: 'Ramesh Sharma',
        serviceId: 'fan_repair',
        serviceName: 'Fan repair',
        categoryName: 'Electrician',
        price: 199,
        platformFee: 25,
        totalAmount: 224,
        address: 'Flat 402, Radhe Residency, 150ft Ring Road',
        city: 'Rajkot',
        dateTime: '16/10/2026, 11 AM - 1 PM',
        status: 'assigned',
        paymentMethod: 'UPI',
      },
      {
        bookingId: 'FX-87341',
        customerName: 'Devang Patel',
        customerPhone: '+91 98795 43210',
        providerName: 'Haresh Solanki',
        serviceId: 'tap_mixer',
        serviceName: 'Tap & mixer',
        categoryName: 'Plumber',
        price: 149,
        platformFee: 25,
        totalAmount: 174,
        address: 'B-12, Sunrise Greens, Race Course Road',
        city: 'Rajkot',
        dateTime: '02/10/2026, 2 PM - 4 PM',
        status: 'completed',
        paymentMethod: 'Credit / Debit Card',
      },
      {
        bookingId: 'FX-78119',
        customerName: 'Devang Patel',
        customerPhone: '+91 98795 43210',
        providerName: 'Jignesh Makwana',
        serviceId: 'stove_repair',
        serviceName: 'Stove repair',
        categoryName: 'Gas Repair',
        price: 249,
        platformFee: 25,
        totalAmount: 274,
        address: 'Shop 4, Kalawad Road',
        city: 'Rajkot',
        dateTime: '20/09/2026, 9 AM - 11 AM',
        status: 'cancelled',
        paymentMethod: 'Cash after service',
      },
    ];
    await Booking.insertMany(bookingsData);
    console.log(`[Seed] Seeded sample bookings.`);

    // 6. Seed Demo User
    await User.create({
      name: 'Devang Patel',
      phone: '+91 98795 43210',
      role: 'customer',
      city: 'Rajkot',
      savedAddresses: [
        { tag: 'Home', address: 'Flat 402, Radhe Residency, 150ft Ring Road', isDefault: true },
        { tag: 'Office', address: 'Shop 12, Crystal Mall, Kalawad Road', isDefault: false },
      ],
    });
    console.log('[Seed] Seeded demo user with saved addresses.');

    // 7. Seed Sample Reviews
    const reviewsData = [
      {
        bookingId: 'FX-87341',
        rating: 5,
        comment: 'Haresh arrived within 25 minutes, fixed the tap mixer quickly. Highly recommend!',
        userName: 'Devang Patel',
        serviceName: 'Tap & mixer',
      },
      {
        bookingId: 'FX-91204',
        rating: 5,
        comment: 'Ramesh is an expert electrician. Very polite and tidy work.',
        userName: 'Priya Shah',
        serviceName: 'Fan repair',
      },
    ];
    await Review.insertMany(reviewsData);
    console.log(`[Seed] Seeded ${reviewsData.length} reviews.`);

    console.log('✅ [Seed] Database seeding completed successfully!');
    process.exit(0);
  } catch (err) {
    console.error('❌ [Seed] Seeding failed:', err);
    process.exit(1);
  }
};

seedData();
