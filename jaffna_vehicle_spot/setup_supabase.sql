-- SQL Script to set up Superior Vehicle Spot database in Supabase

-- 1. Attendance Table
CREATE TABLE attendance (
  id BIGSERIAL PRIMARY KEY,
  local_id TEXT UNIQUE,
  user_id UUID REFERENCES auth.users(id),
  user_name TEXT,
  user_role TEXT,
  branch TEXT,
  check_in TIMESTAMPTZ DEFAULT NOW(),
  check_out TIMESTAMPTZ,
  total_hours DECIMAL,
  overtime_hours DECIMAL,
  status TEXT DEFAULT 'Active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Branches Table
CREATE TABLE branches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  location TEXT,
  manager_name TEXT,
  contact_no TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Vehicles Table
CREATE TABLE vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  brand TEXT,
  model TEXT,
  year TEXT,
  registration_no TEXT UNIQUE,
  chassis_no TEXT UNIQUE,
  engine_no TEXT UNIQUE,
  color TEXT,
  fuel_type TEXT,
  transmission TEXT,
  seating_capacity TEXT,
  status TEXT DEFAULT 'Available',
  type TEXT,
  image_url TEXT,
  owner_name TEXT,
  owner_nic TEXT,
  owner_phone TEXT,
  cost_price DECIMAL,
  selling_price DECIMAL,
  features TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Customers Table
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  nic TEXT UNIQUE,
  phone TEXT,
  address TEXT,
  email TEXT,
  purchased_vehicles TEXT[], -- Array of vehicle IDs or names
  branch TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Invoices Table
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name TEXT,
  customer_address TEXT,
  customer_contact TEXT,
  customer_nic TEXT,
  vehicle_name TEXT,
  chassis_no TEXT,
  engine_no TEXT,
  registration_no TEXT,
  vehicle_type TEXT,
  fuel_type TEXT,
  color TEXT,
  year TEXT,
  amount DECIMAL,
  lease_amount DECIMAL,
  date DATE DEFAULT CURRENT_DATE,
  status TEXT DEFAULT 'Pending',
  sales_person_id UUID,
  commission_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Commissions Table
CREATE TABLE commissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID REFERENCES invoices(id),
  agent_name TEXT,
  contact TEXT,
  commission_type TEXT, -- 'Fixed' or 'Percentage'
  amount DECIMAL,
  reason TEXT,
  date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Staff Table (Extra details for users)
CREATE TABLE staff (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT,
  full_name TEXT,
  email TEXT UNIQUE,
  phone TEXT,
  role TEXT,
  mobile_no TEXT,
  home_no TEXT,
  application_post TEXT,
  branch TEXT,
  postal_address TEXT,
  permanent_address TEXT,
  gender TEXT,
  civil_status TEXT,
  dob DATE,
  nic_no TEXT UNIQUE,
  spouse_name TEXT,
  spouse_contact TEXT,
  spouse_nic TEXT,
  spouse_address TEXT,
  spouse_relationship TEXT,
  ol_results TEXT,
  al_results TEXT,
  other_qualifications TEXT,
  has_offense BOOLEAN DEFAULT FALSE,
  offense_nature TEXT,
  salary_amount DECIMAL,
  salary_allowance DECIMAL,
  bank_name TEXT,
  bank_branch TEXT,
  account_no TEXT,
  epf_no TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Garage Records Table
CREATE TABLE garage_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id UUID REFERENCES vehicles(id),
  garage_name TEXT,
  owner_name TEXT,
  contact_number TEXT,
  address TEXT,
  problem_description TEXT,
  date DATE DEFAULT CURRENT_DATE,
  driver_name TEXT,
  total_amount DECIMAL,
  advance_amount DECIMAL,
  status TEXT DEFAULT 'In Garage',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (Initial setup: Allow authenticated users to do everything)
-- In a production app, you would want more specific policies.
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE garage_records ENABLE ROW LEVEL SECURITY;

-- Simple policies for authenticated users
CREATE POLICY "Allow all to authenticated" ON attendance FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all to authenticated" ON branches FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all to authenticated" ON vehicles FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all to authenticated" ON customers FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all to authenticated" ON invoices FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all to authenticated" ON commissions FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all to authenticated" ON staff FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow all to authenticated" ON garage_records FOR ALL TO authenticated USING (true) WITH CHECK (true);
