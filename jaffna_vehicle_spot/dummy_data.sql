-- Dummy Data for Jaffna Vehicle Spot

-- 1. Insert Branches
INSERT INTO branches (id, name, location, manager_name, contact_no) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Jaffna Main', 'Kandy Road, Jaffna', 'S. Tharshan', '0212221234'),
('550e8400-e29b-41d4-a716-446655440002', 'Chunnakam Branch', 'Station Road, Chunnakam', 'K. Vithu', '0212241234');

-- 2. Insert Vehicles
-- Note: Replace imageUrls with actual valid URLs if available, or keep placeholders.
INSERT INTO vehicles (id, name, brand, model, year, registration_no, chassis_no, engine_no, color, fuel_type, transmission, status, type, image_url, selling_price) VALUES
('550e8400-e29b-41d4-a716-446655440003', 'TOYOTA C-HR', 'Toyota', 'C-HR', '2025', 'NP CBR-3153', 'MH95S-285447', 'R06D-WA04C-K419941', 'PEARL WHITE', 'Petrol', 'Automatic', 'Available', 'Car', 'assets/toyota_chr.png', 12500000),
('550e8400-e29b-41d4-a716-446655440004', 'SUZUKI WAGON R', 'Suzuki', 'Wagon R', '2024', 'NP CAD-1234', 'MH55S-123456', 'R06A-123456', 'Blue', 'Hybrid', 'Automatic', 'Available', 'Car', 'assets/suzuki_wagon_r.png', 8500000),
('550e8400-e29b-41d4-a716-446655440005', 'NISSAN NV200', 'Nissan', 'NV200', '2023', 'NP CAR-5678', 'VM20-123456', 'HR16-123456', 'Silver', 'Petrol', 'Manual', 'Available', 'Van', 'assets/nissan_nv200.png', 9200000);

-- 3. Insert Customers
INSERT INTO customers (id, name, nic, phone, address, email, branch) VALUES
('550e8400-e29b-41d4-a716-446655440006', 'A. Krishan', '199512345678', '0771234567', 'No 45, Main St, Jaffna', 'krishan@email.com', 'Jaffna Main'),
('550e8400-e29b-41d4-a716-446655440007', 'M. Rahav', '199887654321', '0777654321', 'No 12, Temple Rd, Nallur', 'rahav@email.com', 'Jaffna Main');

-- 4. Insert Invoices (Sample sales)
INSERT INTO invoices (id, customer_name, customer_nic, vehicle_name, registration_no, amount, date, status, branch) VALUES
('550e8400-e29b-41d4-a716-446655440008', 'A. Krishan', '199512345678', 'Toyota Aqua', 'WP CAD-4455', 7850000, '2026-03-15', 'Paid', 'Jaffna Main');
