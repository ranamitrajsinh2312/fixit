import 'package:flutter/material.dart';

const int platformFee = 25; // Rs per service

const List<String> cities = [
  'Rajkot',
  'Ahmedabad',
  'Gandhinagar',
  'Vadodara',
  'Surat',
  'Jamnagar',
  'Bhavnagar',
  'Junagadh',
  'Mumbai',
  'Pune',
  'Delhi',
  'Bengaluru',
];

const List<String> timeSlots = [
  '9 AM - 11 AM',
  '11 AM - 1 PM',
  '2 PM - 4 PM',
  '4 PM - 6 PM',
  '6 PM - 8 PM',
];

class Service {
  final String id;
  final String name;
  final String desc;
  final int price;
  final List<String> included;
  final double rating;
  final int reviewsCount;

  const Service({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    this.included = const [
      'Inspection & diagnosis',
      'Repair by verified professional',
      '30-day service warranty',
      'Spare parts charged extra if needed',
    ],
    this.rating = 4.8,
    this.reviewsCount = 1240,
  });
}

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<Service> services;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.services,
  });
}

const List<Category> categories = [
  // 1. Electrician
  Category(
    id: 'electrician',
    name: 'Electrician',
    icon: Icons.electrical_services,
    color: Color(0xFFF59E0B),
    services: [
      Service(
        id: 'fan_repair',
        name: 'Fan repair',
        desc: 'Motor, capacitor, bearing or speed regulator fix',
        price: 199,
        rating: 4.9,
        reviewsCount: 2310,
      ),
      Service(
        id: 'switch_socket',
        name: 'Switch & socket',
        desc: 'Replace, repair or install new power sockets & switches',
        price: 149,
        rating: 4.8,
        reviewsCount: 1420,
      ),
      Service(
        id: 'wiring_mcb',
        name: 'Wiring & MCB',
        desc: 'Short circuit detection, MCB trip fix and circuit check',
        price: 299,
        rating: 4.7,
        reviewsCount: 890,
      ),
      Service(
        id: 'light_fitting',
        name: 'Light fitting',
        desc: 'Install LED batten, ceiling light, chandelier or bulb holder',
        price: 179,
        rating: 4.8,
        reviewsCount: 1650,
      ),
      Service(
        id: 'inverter_battery',
        name: 'Inverter & battery',
        desc: 'Backup testing, acid top-up, wiring and terminal cleanup',
        price: 399,
        rating: 4.8,
        reviewsCount: 710,
      ),
    ],
  ),

  // 2. Plumber
  Category(
    id: 'plumber',
    name: 'Plumber',
    icon: Icons.plumbing,
    color: Color(0xFF0EA5E9),
    services: [
      Service(
        id: 'tap_mixer',
        name: 'Tap & mixer',
        desc: 'Dripping tap repair, cartridge replacement or mixer fitting',
        price: 149,
        rating: 4.8,
        reviewsCount: 2150,
      ),
      Service(
        id: 'pipe_leakage',
        name: 'Pipe leakage',
        desc: 'Detect and seal concealed or exposed leaking CPVC/GI pipes',
        price: 249,
        rating: 4.7,
        reviewsCount: 1430,
      ),
      Service(
        id: 'blockage_clearing',
        name: 'Blockage clearing',
        desc: 'Sink, toilet trap, shower drain and sewer line unclogging',
        price: 299,
        rating: 4.9,
        reviewsCount: 1980,
      ),
      Service(
        id: 'tank_cleaning',
        name: 'Tank cleaning',
        desc: 'Overhead PVC/RCC tank mechanized sludge removal & sanitation',
        price: 599,
        rating: 4.9,
        reviewsCount: 820,
      ),
      Service(
        id: 'bathroom_fittings',
        name: 'Bathroom fittings',
        desc: 'Install shower, towel rod, health faucet, soap dispenser',
        price: 349,
        rating: 4.8,
        reviewsCount: 1190,
      ),
    ],
  ),

  // 3. Gas Repair
  Category(
    id: 'gas_repair',
    name: 'Gas Repair',
    icon: Icons.local_fire_department,
    color: Color(0xFFEF4444),
    services: [
      Service(
        id: 'stove_repair',
        name: 'Stove repair',
        desc: 'Burner deep cleaning, auto-ignition and low flame fix',
        price: 249,
        rating: 4.8,
        reviewsCount: 1120,
      ),
      Service(
        id: 'gas_leak_check',
        name: 'Gas leak check',
        desc: 'High-precision pipe, valve and regulator safety inspection',
        price: 299,
        rating: 4.9,
        reviewsCount: 1870,
      ),
      Service(
        id: 'pipe_installation',
        name: 'Pipe installation',
        desc: 'New steel braided or rubber gas line fitting & pressure test',
        price: 499,
        rating: 4.8,
        reviewsCount: 740,
      ),
      Service(
        id: 'gas_geyser_repair',
        name: 'Gas geyser repair',
        desc: 'Pilot flame, diaphragm, water pressure sensor & burner service',
        price: 399,
        rating: 4.7,
        reviewsCount: 560,
      ),
    ],
  ),

  // 4. Carpenter / Furniture
  Category(
    id: 'furniture',
    name: 'Carpenter / Furniture',
    icon: Icons.chair,
    color: Color(0xFF92400E),
    services: [
      Service(
        id: 'door_lock_repair',
        name: 'Door & lock repair',
        desc: 'Hinges alignment, magnetic latch, mortise & smart lock fix',
        price: 249,
        rating: 4.7,
        reviewsCount: 950,
      ),
      Service(
        id: 'bed_sofa_repair',
        name: 'Bed / sofa repair',
        desc: 'Hydraulic lift, broken slats, leg tightening & frame joints',
        price: 399,
        rating: 4.8,
        reviewsCount: 680,
      ),
      Service(
        id: 'furniture_assembly',
        name: 'Furniture assembly',
        desc: 'Assemble IKEA/engineered wardrobe, study table, bed or shelf',
        price: 349,
        rating: 4.9,
        reviewsCount: 1340,
      ),
      Service(
        id: 'modular_kitchen_fix',
        name: 'Modular kitchen fix',
        desc: 'Telescopic channel, soft-close hinge replacement & drawer align',
        price: 599,
        rating: 4.8,
        reviewsCount: 430,
      ),
      Service(
        id: 'curtain_rod_fitting',
        name: 'Curtain rod fitting',
        desc: 'Drilling, anchor installation and bracket alignment per window',
        price: 199,
        rating: 4.9,
        reviewsCount: 820,
      ),
    ],
  ),

  // 5. AC Repair
  Category(
    id: 'ac_repair',
    name: 'AC Repair',
    icon: Icons.ac_unit,
    color: Color(0xFF06B6D4),
    services: [
      Service(
        id: 'ac_service',
        name: 'AC service',
        desc: 'Jet-pump indoor filter wash, cooling coil flush and outdoor check',
        price: 499,
        rating: 4.9,
        reviewsCount: 3410,
      ),
      Service(
        id: 'gas_refill',
        name: 'Gas refill',
        desc: 'Leak detection, vacuuming and complete R32/R410A refrigerant charge',
        price: 1499,
        rating: 4.8,
        reviewsCount: 1890,
      ),
      Service(
        id: 'ac_installation',
        name: 'Installation',
        desc: 'Split/window AC indoor and outdoor mounting with pipe check',
        price: 999,
        rating: 4.7,
        reviewsCount: 1120,
      ),
      Service(
        id: 'ac_uninstall',
        name: 'Uninstall',
        desc: 'Safe refrigerant pump-down, bracket dismantling and packing',
        price: 499,
        rating: 4.8,
        reviewsCount: 670,
      ),
    ],
  ),

  // 6. Appliance Repair
  Category(
    id: 'appliance_repair',
    name: 'Appliance Repair',
    icon: Icons.kitchen,
    color: Color(0xFF6366F1),
    services: [
      Service(
        id: 'washing_machine',
        name: 'Washing machine',
        desc: 'Drum spin, drain pump, inlet valve, motor or PCB diagnosis',
        price: 399,
        rating: 4.8,
        reviewsCount: 1740,
      ),
      Service(
        id: 'refrigerator',
        name: 'Refrigerator',
        desc: 'Cooling coil, thermostat, compressor relay, defrost sensor fix',
        price: 399,
        rating: 4.7,
        reviewsCount: 1530,
      ),
      Service(
        id: 'microwave_oven',
        name: 'Microwave / oven',
        desc: 'Magnetron, heating element, touch panel or turntable motor fix',
        price: 299,
        rating: 4.8,
        reviewsCount: 890,
      ),
      Service(
        id: 'electric_geyser',
        name: 'Electric geyser',
        desc: 'Heating coil replacement, thermostat reset, tank descaling',
        price: 349,
        rating: 4.9,
        reviewsCount: 1260,
      ),
      Service(
        id: 'tv_repair',
        name: 'TV',
        desc: 'Backlight repair, sound output, power supply or wall installation',
        price: 399,
        rating: 4.7,
        reviewsCount: 940,
      ),
    ],
  ),

  // 7. RO / Water Purifier
  Category(
    id: 'ro_purifier',
    name: 'RO / Water Purifier',
    icon: Icons.water_drop,
    color: Color(0xFF3B82F6),
    services: [
      Service(
        id: 'ro_service',
        name: 'RO service',
        desc: 'TDS testing, membrane flushing, pre-filter wash and UV check',
        price: 299,
        rating: 4.9,
        reviewsCount: 2010,
      ),
      Service(
        id: 'filter_change',
        name: 'Filter change',
        desc: 'Sediment, carbon block and post-carbon filter cartridge replacement',
        price: 599,
        rating: 4.8,
        reviewsCount: 1650,
      ),
      Service(
        id: 'ro_installation',
        name: 'RO installation',
        desc: 'Wall mount, inlet diverter valve fitting and waste-water routing',
        price: 499,
        rating: 4.8,
        reviewsCount: 780,
      ),
    ],
  ),

  // 8. Home Cleaning
  Category(
    id: 'home_cleaning',
    name: 'Home Cleaning',
    icon: Icons.cleaning_services,
    color: Color(0xFF10B981),
    services: [
      Service(
        id: 'full_home_deep_clean',
        name: 'Full home deep clean',
        desc: 'Complete floor scrubbing, window rails, doors, cobweb removal',
        price: 1499,
        rating: 4.9,
        reviewsCount: 1820,
      ),
      Service(
        id: 'kitchen_clean',
        name: 'Kitchen',
        desc: 'Oil degreasing, chimney exterior, exhaust fan & tile descaling',
        price: 799,
        rating: 4.8,
        reviewsCount: 1140,
      ),
      Service(
        id: 'bathroom_clean',
        name: 'Bathroom',
        desc: 'Acid-free tile stain removal, toilet pot sanitation & tap shine',
        price: 499,
        rating: 4.8,
        reviewsCount: 2280,
      ),
      Service(
        id: 'sofa_carpet_clean',
        name: 'Sofa & carpet',
        desc: 'Shampoo extraction machine wash, allergen & dust mite removal',
        price: 699,
        rating: 4.7,
        reviewsCount: 870,
      ),
      Service(
        id: 'water_tank_clean',
        name: 'Water tank',
        desc: 'Sludge extraction, high-pressure jet wash and UV disinfection',
        price: 699,
        rating: 4.9,
        reviewsCount: 650,
      ),
    ],
  ),

  // 9. Pest Control
  Category(
    id: 'pest_control',
    name: 'Pest Control',
    icon: Icons.bug_report,
    color: Color(0xFF84CC16),
    services: [
      Service(
        id: 'cockroach_ants',
        name: 'Cockroach / ants',
        desc: 'Odorless gel baiting in kitchen cabinets and crack spray',
        price: 599,
        rating: 4.8,
        reviewsCount: 1420,
      ),
      Service(
        id: 'termite_treatment',
        name: 'Termite',
        desc: 'Drill-fill-seal chemical barrier protection with 1-year warranty',
        price: 1199,
        rating: 4.9,
        reviewsCount: 690,
      ),
      Service(
        id: 'mosquito_control',
        name: 'Mosquito',
        desc: 'Indoor residual thermal fogging and wall perimeter spray',
        price: 499,
        rating: 4.7,
        reviewsCount: 510,
      ),
      Service(
        id: 'bed_bugs',
        name: 'Bed bugs',
        desc: '2-visit intensive steam and contact spray on mattresses & frames',
        price: 899,
        rating: 4.8,
        reviewsCount: 840,
      ),
    ],
  ),

  // 10. Painting
  Category(
    id: 'painting',
    name: 'Painting',
    icon: Icons.format_paint,
    color: Color(0xFFEC4899),
    services: [
      Service(
        id: 'room_painting',
        name: 'Room painting',
        desc: '2 coats premium interior emulsion with floor masking and touch-up',
        price: 1999,
        rating: 4.8,
        reviewsCount: 780,
      ),
      Service(
        id: 'full_home_painting',
        name: 'Full home',
        desc: 'Putty, primer, sanding and dual coat emulsion for entire house',
        price: 6999,
        rating: 4.9,
        reviewsCount: 540,
      ),
      Service(
        id: 'waterproofing',
        name: 'Waterproofing',
        desc: 'Terrace or wall seepage chemical injection and membrane coating',
        price: 2499,
        rating: 4.7,
        reviewsCount: 420,
      ),
      Service(
        id: 'wall_touchup',
        name: 'Wall touch-up',
        desc: 'Patch plaster, minor nail hole filling and spot shade matching',
        price: 899,
        rating: 4.8,
        reviewsCount: 630,
      ),
    ],
  ),

  // 11. Mason / Civil
  Category(
    id: 'mason_civil',
    name: 'Mason / Civil',
    icon: Icons.construction,
    color: Color(0xFFF97316),
    services: [
      Service(
        id: 'tile_fitting',
        name: 'Tile fitting',
        desc: 'Hollow tile replacement, epoxy grouting or new flooring laying',
        price: 799,
        rating: 4.7,
        reviewsCount: 590,
      ),
      Service(
        id: 'wall_repair',
        name: 'Wall repair',
        desc: 'Cement plaster crack fixing, brickwork alteration and patching',
        price: 499,
        rating: 4.8,
        reviewsCount: 470,
      ),
      Service(
        id: 'bathroom_renovation',
        name: 'Bathroom renovation',
        desc: 'Plumbing line relocation, slope correction and tile revamping',
        price: 3499,
        rating: 4.9,
        reviewsCount: 310,
      ),
      Service(
        id: 'false_ceiling',
        name: 'False ceiling',
        desc: 'Gypsum board grid framing, cove lighting slot and POP repair',
        price: 1899,
        rating: 4.8,
        reviewsCount: 290,
      ),
    ],
  ),

  // 12. CCTV & Security
  Category(
    id: 'cctv_security',
    name: 'CCTV & Security',
    icon: Icons.videocam,
    color: Color(0xFF14B8A6),
    services: [
      Service(
        id: 'cctv_installation',
        name: 'CCTV installation',
        desc: 'Bullet/dome camera mounting, BNC crimping, DVR setup & wiring',
        price: 699,
        rating: 4.9,
        reviewsCount: 1120,
      ),
      Service(
        id: 'cctv_repair',
        name: 'CCTV repair',
        desc: 'No video signal, HDD recording error, power supply replacement',
        price: 399,
        rating: 4.8,
        reviewsCount: 680,
      ),
      Service(
        id: 'video_door_phone',
        name: 'Video door phone',
        desc: 'Outdoor bell camera and indoor monitor screen installation',
        price: 899,
        rating: 4.8,
        reviewsCount: 430,
      ),
      Service(
        id: 'smart_lock',
        name: 'Smart lock',
        desc: 'Digital fingerprint, keypad and RFID lock wooden door mortising',
        price: 999,
        rating: 4.9,
        reviewsCount: 510,
      ),
    ],
  ),

  // 13. Mobile & Laptop
  Category(
    id: 'mobile_laptop',
    name: 'Mobile & Laptop',
    icon: Icons.devices,
    color: Color(0xFF8B5CF6),
    services: [
      Service(
        id: 'screen_repair',
        name: 'Screen repair',
        desc: 'OEM display glass and touch digitizer replacement at home',
        price: 1299,
        rating: 4.8,
        reviewsCount: 1460,
      ),
      Service(
        id: 'mobile_battery',
        name: 'Mobile battery',
        desc: 'Original battery replacement with 6-month performance warranty',
        price: 699,
        rating: 4.9,
        reviewsCount: 890,
      ),
      Service(
        id: 'laptop_repair',
        name: 'Laptop repair',
        desc: 'RAM/SSD upgrade, OS installation, overheating thermal paste',
        price: 799,
        rating: 4.8,
        reviewsCount: 1170,
      ),
      Service(
        id: 'wifi_router_setup',
        name: 'Wi-Fi / router setup',
        desc: 'Router configuration, range extender setup and LAN cabling',
        price: 299,
        rating: 4.9,
        reviewsCount: 920,
      ),
    ],
  ),

  // 14. Packers & Movers
  Category(
    id: 'packers_movers',
    name: 'Packers & Movers',
    icon: Icons.local_shipping,
    color: Color(0xFF64748B),
    services: [
      Service(
        id: 'bhk_1',
        name: '1 BHK',
        desc: 'Dedicated packing team, bubble wrapping and local relocation',
        price: 3999,
        rating: 4.9,
        reviewsCount: 810,
      ),
      Service(
        id: 'bhk_2_3',
        name: '2-3 BHK',
        desc: 'Multi-layer packing, dismantling, loading, transit and assembly',
        price: 6999,
        rating: 4.8,
        reviewsCount: 640,
      ),
      Service(
        id: 'bike_car_transport',
        name: 'Bike / car transport',
        desc: 'Enclosed carrier vehicle shipping with transit insurance',
        price: 2499,
        rating: 4.7,
        reviewsCount: 420,
      ),
      Service(
        id: 'mini_truck',
        name: 'Mini truck',
        desc: 'Tata Ace/Bolero pickup hire with driver for local room shifting',
        price: 1199,
        rating: 4.8,
        reviewsCount: 980,
      ),
    ],
  ),

  // 15. Vehicle Care
  Category(
    id: 'vehicle_care',
    name: 'Vehicle Care',
    icon: Icons.directions_car,
    color: Color(0xFFD97706),
    services: [
      Service(
        id: 'bike_service',
        name: 'Bike service',
        desc: 'Engine oil change, carburetor/spark plug clean & brake tune',
        price: 499,
        rating: 4.9,
        reviewsCount: 1950,
      ),
      Service(
        id: 'car_wash',
        name: 'Car wash',
        desc: 'Foam exterior wash, interior vacuuming and dashboard polish',
        price: 399,
        rating: 4.8,
        reviewsCount: 2410,
      ),
      Service(
        id: 'battery_jump_start',
        name: 'Battery jump-start',
        desc: 'Rapid on-spot breakdown assistance with jumper cables & booster',
        price: 249,
        rating: 4.9,
        reviewsCount: 1330,
      ),
      Service(
        id: 'puncture_repair',
        name: 'Puncture repair',
        desc: 'Tubeless tyre puncture repair and emergency air inflation',
        price: 149,
        rating: 4.8,
        reviewsCount: 1680,
      ),
    ],
  ),

  // 16. Salon & Wellness
  Category(
    id: 'salon_wellness',
    name: 'Salon & Wellness',
    icon: Icons.spa,
    color: Color(0xFFF43F5E),
    services: [
      Service(
        id: 'mens_haircut',
        name: 'Men’s haircut',
        desc: 'Haircut, beard styling and refreshing neck massage at home',
        price: 199,
        rating: 4.9,
        reviewsCount: 3120,
      ),
      Service(
        id: 'womens_salon',
        name: 'Women’s salon',
        desc: 'Waxing, facial, clean-up, threading & manicure/pedicure pack',
        price: 599,
        rating: 4.8,
        reviewsCount: 2840,
      ),
      Service(
        id: 'massage',
        name: 'Massage',
        desc: 'Full body Swedish or deep tissue relaxation therapy with oils',
        price: 899,
        rating: 4.9,
        reviewsCount: 1540,
      ),
      Service(
        id: 'mehendi_artist',
        name: 'Mehendi artist',
        desc: 'Arabic or traditional bridal cone art for hands by expert artist',
        price: 499,
        rating: 4.8,
        reviewsCount: 790,
      ),
    ],
  ),

  // 17. On-Road Mechanic (Roadside Assistance)
  Category(
    id: 'on_road_mechanic',
    name: 'On-Road Mechanic (RSA)',
    icon: Icons.car_repair_rounded,
    color: Color(0xFFDC2626),
    services: [
      Service(
        id: 'bike_onroad_breakdown',
        name: 'Bike on-road breakdown',
        desc: 'Clutch cable, chain loose/off, spark plug, minor engine stalling fix on-spot',
        price: 199,
        rating: 4.9,
        reviewsCount: 2120,
      ),
      Service(
        id: 'car_onroad_breakdown',
        name: 'Car on-road breakdown',
        desc: 'Radiator overheating, alternator, fan belt slip, fuse check & on-spot diagnosis',
        price: 399,
        rating: 4.8,
        reviewsCount: 1840,
      ),
      Service(
        id: 'battery_jumpstart_rsa',
        name: 'Battery jump-start',
        desc: '12V/24V heavy-duty booster cables, terminal cleaning & alternator check',
        price: 249,
        rating: 4.9,
        reviewsCount: 3150,
      ),
      Service(
        id: 'puncture_air_rsa',
        name: 'On-spot tyre puncture',
        desc: 'Tubeless strip repair, spare wheel (stepney) change & portable air fill',
        price: 179,
        rating: 4.8,
        reviewsCount: 2780,
      ),
      Service(
        id: 'emergency_fuel_rsa',
        name: 'Emergency fuel delivery',
        desc: '3L to 5L Petrol/Diesel canister delivered to stranded spot (Fuel at actuals)',
        price: 199,
        rating: 4.8,
        reviewsCount: 1420,
      ),
      Service(
        id: 'towing_service_rsa',
        name: 'Vehicle towing service',
        desc: 'Flatbed or hydraulic wheel-lift towing to nearest authorized garage or home',
        price: 899,
        rating: 4.9,
        reviewsCount: 960,
      ),
      Service(
        id: 'car_lockout_rsa',
        name: 'Key lockout assistance',
        desc: 'Safe non-destructive air-wedge door unlocking when keys are locked inside',
        price: 449,
        rating: 4.7,
        reviewsCount: 880,
      ),
    ],
  ),

  // 18. General Mechanic & Tools
  Category(
    id: 'generic_mechanic',
    name: 'General Mechanic & Tools',
    icon: Icons.handyman_rounded,
    color: Color(0xFFEA580C),
    services: [
      Service(
        id: 'water_pump_repair',
        name: 'Water pump & motor repair',
        desc: 'Submersible, monoblock pump, capacitor, impeller & coil winding fix',
        price: 349,
        rating: 4.8,
        reviewsCount: 1290,
      ),
      Service(
        id: 'generator_inverter_engine',
        name: 'Portable generator repair',
        desc: 'Engine oil flush, carburetor clean, pull-starter cord & spark plug service',
        price: 499,
        rating: 4.9,
        reviewsCount: 640,
      ),
      Service(
        id: 'drill_cut_weld_job',
        name: 'Spot welding & metal repair',
        desc: 'Gate hinge welding, latch fixing, metal grill railing & shutter patch',
        price: 399,
        rating: 4.8,
        reviewsCount: 810,
      ),
      Service(
        id: 'shutter_rolling_fix',
        name: 'Rolling shutter repair',
        desc: 'Commercial shop shutter spring tensioning, channel gear & lock repair',
        price: 499,
        rating: 4.7,
        reviewsCount: 720,
      ),
      Service(
        id: 'sewing_machine_repair',
        name: 'Sewing machine repair',
        desc: 'Needle timing, motor belt replacement, tension adjuster & lubrication',
        price: 249,
        rating: 4.8,
        reviewsCount: 910,
      ),
      Service(
        id: 'pressure_washer_tool',
        name: 'Power tools service',
        desc: 'Drill machine, angle grinder, cutter & high-pressure car washer repair',
        price: 299,
        rating: 4.8,
        reviewsCount: 540,
      ),
    ],
  ),

  // 19. Emergency Locksmith
  Category(
    id: 'emergency_locksmith',
    name: 'Emergency Locksmith',
    icon: Icons.lock_open_rounded,
    color: Color(0xFF4F46E5),
    services: [
      Service(
        id: 'door_lock_emergency',
        name: 'Emergency door unlock',
        desc: 'Jammed latch opening, deadbolt unlock & broken key extraction without door damage',
        price: 299,
        rating: 4.9,
        reviewsCount: 1670,
      ),
      Service(
        id: 'cupboard_safe_lock',
        name: 'Cupboard & safe locker fix',
        desc: 'Godrej cupboard lever repair, locker key fitting & dial safe combination reset',
        price: 399,
        rating: 4.8,
        reviewsCount: 820,
      ),
      Service(
        id: 'smart_door_lock_reset',
        name: 'Smart digital lock reset',
        desc: 'Biometric fingerprint, PIN pad reprogram & RFID master card configuration',
        price: 499,
        rating: 4.9,
        reviewsCount: 690,
      ),
      Service(
        id: 'key_cutting_doorstep',
        name: 'Duplicate key cutting',
        desc: 'Laser-cut brass computerized duplicate keys cut directly at your doorstep',
        price: 199,
        rating: 4.8,
        reviewsCount: 1430,
      ),
    ],
  ),
];

class BookingItem {
  final String id;
  final String serviceName;
  final String categoryName;
  final int price;
  final int platformFee;
  final int totalAmount;
  final String address;
  final String city;
  final String dateTime;
  final String status; // 'Upcoming', 'Completed', 'Cancelled'
  final String paymentMethod;
  final String paymentStatus; // 'paid', 'pending', 'refunded'
  final String transactionId;
  final int discount;
  final String couponCode;
  final String? refundId;
  final int? refundAmount;
  final DateTime createdAt;

  BookingItem({
    required this.id,
    required this.serviceName,
    required this.categoryName,
    required this.price,
    this.platformFee = 25,
    required this.totalAmount,
    required this.address,
    required this.city,
    required this.dateTime,
    this.status = 'Upcoming',
    required this.paymentMethod,
    String? paymentStatus,
    this.transactionId = '',
    this.discount = 0,
    this.couponCode = '',
    this.refundId,
    this.refundAmount,
    DateTime? createdAt,
  })  : paymentStatus = paymentStatus ?? (paymentMethod.toLowerCase().contains('cash') ? 'pending' : 'paid'),
        createdAt = createdAt ?? DateTime.now();
}

class BookingStore extends ChangeNotifier {
  static final BookingStore instance = BookingStore._internal();
  BookingStore._internal();

  final List<BookingItem> _bookings = [
    BookingItem(
      id: 'FX-91204',
      serviceName: 'Fan repair',
      categoryName: 'Electrician',
      price: 199,
      platformFee: 25,
      totalAmount: 224,
      address: 'Flat 402, Radhe Residency, 150ft Ring Road',
      city: 'Rajkot',
      dateTime: '16/10/2026, 11 AM - 1 PM',
      status: 'Upcoming',
      paymentMethod: 'UPI',
      paymentStatus: 'paid',
      transactionId: 'pay_rzp_91204_live',
    ),
    BookingItem(
      id: 'FX-87341',
      serviceName: 'Tap & mixer',
      categoryName: 'Plumber',
      price: 149,
      platformFee: 25,
      totalAmount: 174,
      address: 'B-12, Sunrise Greens, Race Course Road',
      city: 'Rajkot',
      dateTime: '02/10/2026, 2 PM - 4 PM',
      status: 'Completed',
      paymentMethod: 'Card',
      paymentStatus: 'paid',
      transactionId: 'pay_card_87341_live',
    ),
    BookingItem(
      id: 'FX-78119',
      serviceName: 'Stove repair',
      categoryName: 'Gas Repair',
      price: 249,
      platformFee: 25,
      totalAmount: 274,
      address: 'Shop 4, Kalawad Road',
      city: 'Rajkot',
      dateTime: '20/09/2026, 9 AM - 11 AM',
      status: 'Cancelled',
      paymentMethod: 'Cash after service',
      paymentStatus: 'pending',
    ),
  ];

  List<BookingItem> get bookings => List.unmodifiable(_bookings);

  void setBookings(List<BookingItem> list) {
    _bookings.clear();
    _bookings.addAll(list);
    notifyListeners();
  }

  void addBooking(BookingItem booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  void cancelBooking(String id) {
    updateBookingStatus(id, 'Cancelled');
  }

  void refundBooking(String id, {String? refundId, int? refundAmount}) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final b = _bookings[idx];
      _bookings[idx] = BookingItem(
        id: b.id,
        serviceName: b.serviceName,
        categoryName: b.categoryName,
        price: b.price,
        platformFee: b.platformFee,
        totalAmount: b.totalAmount,
        address: b.address,
        city: b.city,
        dateTime: b.dateTime,
        status: 'Cancelled',
        paymentMethod: b.paymentMethod,
        paymentStatus: 'refunded',
        transactionId: b.transactionId,
        discount: b.discount,
        couponCode: b.couponCode,
        refundId: refundId ?? 'rfnd_${DateTime.now().millisecondsSinceEpoch}',
        refundAmount: refundAmount ?? b.totalAmount,
        createdAt: b.createdAt,
      );
      notifyListeners();
    }
  }

  void updateBookingStatus(String id, String newStatus) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final b = _bookings[idx];
      _bookings[idx] = BookingItem(
        id: b.id,
        serviceName: b.serviceName,
        categoryName: b.categoryName,
        price: b.price,
        platformFee: b.platformFee,
        totalAmount: b.totalAmount,
        address: b.address,
        city: b.city,
        dateTime: b.dateTime,
        status: newStatus,
        paymentMethod: b.paymentMethod,
        paymentStatus: b.paymentStatus,
        transactionId: b.transactionId,
        discount: b.discount,
        couponCode: b.couponCode,
        refundId: b.refundId,
        refundAmount: b.refundAmount,
        createdAt: b.createdAt,
      );
      notifyListeners();
    }
  }
}
