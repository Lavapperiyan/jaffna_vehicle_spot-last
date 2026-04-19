class ApiConfig {
  // Supabase Configuration - REPLACE WITH YOUR PROJECT DETAILS
  static const String supabaseUrl = 'https://uhczvfobofjosodsaicq.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_GlH52YJEuONAGrkxiYWJjQ_mL8SbJET';

  // Table Names (previously API endpoints)
  static const String tableVehicles = 'vehicles';
  static const String tableBranches = 'branches';
  static const String tableAttendance = 'attendance';
  static const String tableCommissions = 'commissions';
  static const String tableInvoices = 'invoices';
  static const String tableSales = 'sales';
  static const String tableCustomers = 'customers';
  static const String tableStaff = 'staff';
  static const String functionStaffAuth = 'staff-auth';
}
