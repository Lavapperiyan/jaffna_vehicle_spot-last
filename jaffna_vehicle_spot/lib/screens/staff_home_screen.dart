import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/auth_service.dart';
import '../models/vehicle.dart';
import '../models/attendance_service.dart';
import '../models/invoice.dart';
import 'package:intl/intl.dart';
import 'staff_settings_screen.dart';
import 'customers_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';
import 'garage_vehicles_screen.dart';

const Color kBrandDark = Color(0xFF2C3545);
const Color kBrandGold = Color(0xFFE8BC44);

class StaffHomeScreen extends StatelessWidget {
  final Function(int)? onTabChange;
  const StaffHomeScreen({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => InvoiceService().fetchInvoices(),
        child: CustomScrollView(
        slivers: [
          // 1. Sleek Modern Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 24,
                right: 24,
                bottom: 36,
              ),
              decoration: const BoxDecoration(
                color: kBrandDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jaffna Vehicle Spot • ${AuthService().branch}',
                    style: const TextStyle(
                      color: kBrandGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(LucideIcons.image, color: kBrandDark, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              AuthService().userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kBrandGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBrandGold.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.shieldCheck, color: kBrandGold, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              AuthService().userPost.split(' ').first,
                              style: const TextStyle(
                                color: kBrandGold,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 3-Line Menu
                      PopupMenuButton<String>(
                        icon: const Icon(LucideIcons.menu, color: Colors.white, size: 28),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        offset: const Offset(0, 45),
                        color: Colors.white,
                        onSelected: (value) {
                          if (value == 'settings') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StaffSettingsScreen()),
                            );
                          } else if (value == 'customers') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomersScreen()),
                            );
                          } else if (value == 'reports') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ReportsScreen()),
                            );
                          } else if (value == 'garage') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const GarageVehiclesScreen()),
                            );
                          } else if (value == 'logout') {
                            AuthService().logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'settings',
                            child: Row(
                              children: [
                                const Icon(LucideIcons.settings, color: kBrandDark, size: 20),
                                const SizedBox(width: 12),
                                const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600, color: kBrandDark)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'customers',
                            child: Row(
                              children: [
                                const Icon(LucideIcons.users, color: kBrandDark, size: 20),
                                const SizedBox(width: 12),
                                const Text('Customers', style: TextStyle(fontWeight: FontWeight.w600, color: kBrandDark)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'reports',
                            child: Row(
                              children: [
                                const Icon(LucideIcons.barChart3, color: kBrandDark, size: 20),
                                const SizedBox(width: 12),
                                const Text('Reports', style: TextStyle(fontWeight: FontWeight.w600, color: kBrandDark)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'garage',
                            child: Row(
                              children: [
                                const Icon(LucideIcons.warehouse, color: kBrandDark, size: 20),
                                const SizedBox(width: 12),
                                const Text('Vehicles in Garage', style: TextStyle(fontWeight: FontWeight.w600, color: kBrandDark)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 2. Quick Operations Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Operations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAction(
                        icon: LucideIcons.filePlus,
                        label: 'New Bill',
                        color: const Color(0xFF0EA5E9),
                        onTap: () => onTabChange?.call(2),
                      ),
                      _buildQuickAction(
                        icon: LucideIcons.car,
                        label: 'Browse Stock',
                        color: kBrandDark,
                        onTap: () => onTabChange?.call(1),
                      ),
                      _buildQuickAction(
                        icon: LucideIcons.userPlus,
                        label: 'Add Customer',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // 2.5 Attendance & Location Status
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance & Tracking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: kBrandDark.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildAttendanceStatus(
                              icon: LucideIcons.clock,
                              label: 'Check-In Time',
                              value: AttendanceService().currentAttendance != null 
                                  ? DateFormat('hh:mm a').format(AttendanceService().currentAttendance!.checkIn)
                                  : '--:--',
                              color: const Color(0xFF0EA5E9),
                            ),
                          ],
                        ),
                        if (AttendanceService().isOvertimeStarted()) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                            ),
                            child: const Row(
                              children: [
                                Icon(LucideIcons.alertCircle, color: Colors.orange, size: 18),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Overtime tracking started (Since 6:00 PM)',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Sales Target',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<Invoice>>(
                    valueListenable: InvoiceService().invoicesNotifier,
                    builder: (context, invoices, _) {
                      final authService = AuthService();
                      final currentMonth = DateTime.now().month;
                      final currentBranch = authService.branch;
                      
                      // Filter for target: Branch-wide for Managers, Personal for Staff
                      final monthlySales = invoices.where((inv) {
                        final date = DateTime.tryParse(inv.date);
                        
                        // Smart filtering for legacy data (robust comparison)
                        final String userBranchLower = currentBranch.trim().toLowerCase();
                        final String invBranchLower = inv.branch.trim().toLowerCase();

                        bool branchMatch = userBranchLower == 'all branches' 
                            || invBranchLower == userBranchLower 
                            || invBranchLower.isEmpty;
                            
                        // For the dashboard, we now show all sales in the branch to everyone
                        bool userMatch = true; 
                            
                        return branchMatch && userMatch &&
                               date != null &&
                               date.month == currentMonth; // Ignore year for demo/legacy data
                      }).length;

                      const int target = 5;
                      final double progress = (monthlySales / target).clamp(0.0, 1.0);
                      final int percentage = (progress * 100).toInt();
                      final monthName = DateFormat('MMMM yyyy').format(DateTime.now());

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: kBrandDark.withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Target Progress',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kBrandDark.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    monthName,
                                    style: const TextStyle(
                                      color: kBrandDark,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$monthlySales',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: kBrandDark,
                                    height: 1,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 4, left: 4),
                                  child: Text(
                                    '/ 5 Vehicles Sold',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$percentage%',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 12,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    valueColor: const AlwaysStoppedAnimation<Color>(kBrandGold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 4. Highlighted Metrics (My Sales & Total Stock)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<List<Vehicle>>(
                      valueListenable: VehicleService().vehiclesNotifier,
                      builder: (context, vehicles, _) {
                        // Optional: Could filter vehicles by branch if we add branch to Vehicle model
                        return _buildCompactMetric(
                          icon: LucideIcons.car,
                          color: kBrandDark,
                          label: 'Total On-Stock',
                          value: '${vehicles.length}',
                          trend: 'Available',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetric({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trend.contains('+') || trend == 'Now' || trend == 'Available'
                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: trend.contains('+') || trend == 'Now' || trend == 'Available'
                        ? const Color(0xFF059669) 
                        : color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatus({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
