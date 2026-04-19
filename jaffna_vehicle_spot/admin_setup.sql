-- Admin Profile Setup Script
-- Run this in the Supabase SQL Editor AFTER manually creating the user in Auth > Users.

DO $$ 
DECLARE 
  v_user_id UUID;
BEGIN 
  -- 1. Find the UUID of the newly created Auth user
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'lavapperiyan@gmail.com' LIMIT 1;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'USER NOT FOUND: Please create "lavapperiyan@gmail.com" in Supabase Dashboard > Authentication > Users first.';
  END IF;

  -- 2. Link the Auth user to the staff profile
  -- First, delete any existing record for this email
  DELETE FROM staff WHERE email = 'lavapperiyan@gmail.com'; 
  
  INSERT INTO staff (
    id, 
    staff_code,
    name, 
    full_name, 
    email, 
    role, 
    branch, 
    created_at
  ) VALUES (
    v_user_id, 
    'JAFFNA VEHICLE SPOT', -- Use this to login as "Jaffna vehicle spot"
    'Jaffna vehicle spot', 
    'Jaffna vehicle spot', 
    'lavapperiyan@gmail.com', 
    'Admin', 
    'Jaffna', 
    NOW()
  );

  RAISE NOTICE 'SUCCESS: Admin profile successfully linked for user: %', v_user_id;

END $$;
