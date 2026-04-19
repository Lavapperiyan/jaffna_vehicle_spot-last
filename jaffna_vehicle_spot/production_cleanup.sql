-- Production Cleanup Script for Jaffna Vehicle Spot
-- Run this in the Supabase SQL Editor.

BEGIN;

-- 1. Remove all dummy records from all tables
TRUNCATE TABLE attendance CASCADE;
TRUNCATE TABLE vehicles CASCADE;
TRUNCATE TABLE customers CASCADE;
TRUNCATE TABLE invoices CASCADE;
TRUNCATE TABLE commissions CASCADE;
TRUNCATE TABLE staff CASCADE;
TRUNCATE TABLE garage_records CASCADE;
TRUNCATE TABLE branches CASCADE;

-- 2. Insert initial real branch
-- Note: 'Jaffna' must exist for the first admin to be associated with it.
INSERT INTO branches (id, name, location, manager_name, contact_no) VALUES
(gen_random_uuid(), 'Jaffna', 'Jaffna Head Office', 'Jaffna vehicle spot', '077xxxxxxx');

COMMIT;

-- SUCCESS: Database cleared and initial branch created.
