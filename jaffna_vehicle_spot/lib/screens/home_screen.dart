import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/auth_service.dart';
import '../models/vehicle.dart';
import '../models/staff.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import 'settings_screen.dart';
import 'customers_screen.dart';
import 'staff_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';
import 'garage_vehicles_screen.dart';
import 'commission_reports_screen.dart';
import 'staff_attendance_screen.dart';
import 'branch_management_screen.dart';

const Color kBrandDark = Color(0xFF2C3545);
const Color kBrandGold = Color(0xFFE8BC44);

class HomeScreen extends StatelessWidget {
  final Function(int)? onTabChange;
  const HomeScreen({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                          } else if (value == 'customers') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomersScreen()));
                          } else if (value == 'staff') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffScreen()));
                          } else if (value == 'reports') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen()));
                          } else if (value == 'garage') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const GarageVehiclesScreen()));
                          } else if (value == 'commissions') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CommissionReportsScreen()));
                          } else if (value == 'attendance') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffAttendanceScreen()));
                          } else if (value == 'branch_management') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BranchManagementScreen()));
                          } else if (value == 'logout') {
                            AuthService().logout();
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'settings', child: _MenuRow(icon: LucideIcons.settings, label: 'Settings')),
                          const PopupMenuItem(value: 'customers', child: _MenuRow(icon: LucideIcons.users, label: 'Customers')),
                          const PopupMenuItem(value: 'staff', child: _MenuRow(icon: LucideIcons.userCheck, label: 'Staffs')),
                          const PopupMenuItem(value: 'reports', child: _MenuRow(icon: LucideIcons.barChart3, label: 'Reports')),
                          const PopupMenuItem(value: 'garage', child: _MenuRow(icon: LucideIcons.warehouse, label: 'Vehicles in Garage')),
                          const PopupMenuItem(value: 'commissions', child: _MenuRow(icon: LucideIcons.percent, label: 'Commission Reports')),
                          const PopupMenuItem(value: 'attendance', child: _MenuRow(icon: LucideIcons.calendarCheck, label: 'Staff Attendance')),
                          const PopupMenuItem(value: 'branch_management', child: _MenuRow(icon: LucideIcons.building, label: 'Branch Management')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 2. Quick Operations
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _QuickAction(icon: LucideIcons.car, label: 'Inventory', color: kBrandDark, onTap: () => onTabChange?.call(1)),
                      _QuickAction(icon: LucideIcons.fileText, label: 'Billing', color: const Color(0xFF0EA5E9), onTap: () => onTabChange?.call(2)),
                      _QuickAction(icon: LucideIcons.users, label: 'Staffs', color: kBrandGold, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffScreen()))),
                      _QuickAction(icon: LucideIcons.barChart3, label: 'Reports', color: const Color(0xFF10B981), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen()))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // 3. Key Metrics (Live Database Data)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Business Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RepaintBoundary(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        
                        final metricWidgets = [
                          // TOTAL VEHICLES
                          ValueListenableBuilder<List<Vehicle>>(
                            valueListenable: VehicleService().vehiclesNotifier,
                            builder: (context, vehicles, _) => _MetricCard(
                              icon: LucideIcons.car, 
                              color: kBrandDark, 
                              label: 'Total Vehicles', 
                              value: vehicles.length.toString(), 
                              trend: 'Now'
                            ),
                          ),
                          // TOTAL REVENUE (Across all time to match analytics)
                          ValueListenableBuilder<List<Invoice>>(
                            valueListenable: InvoiceService().invoicesNotifier,
                            builder: (context, invoices, _) {
                              double total = 0;
                              for (var inv in invoices) {
                                total += double.tryParse(inv.amount.replaceAll(',', '')) ?? 0;
                              }
                              String valStr = total >= 1000000 
                                  ? '${(total / 1000000).toStringAsFixed(1)}M'
                                  : (total >= 1000 ? '${(total / 1000).toStringAsFixed(1)}K' : total.toStringAsFixed(0));
                              
                              return _MetricCard(
                                icon: LucideIcons.trendingUp, 
                                color: const Color(0xFF10B981), 
                                label: 'Total Revenue', 
                                value: 'Rs. $valStr', 
                                trend: 'Total'
                              );
                            },
                          ),
                          // VEHICLES SOLD
                          ValueListenableBuilder<List<Invoice>>(
                            valueListenable: InvoiceService().invoicesNotifier,
                            builder: (context, invoices, _) => _MetricCard(
                              icon: LucideIcons.shoppingCart, 
                              color: const Color(0xFF0EA5E9), 
                              label: 'Vehicles Sold', 
                              value: invoices.length.toString(), 
                              trend: 'Sold'
                            ),
                          ),
                          // ACTIVE STAFF
                          ValueListenableBuilder<List<Staff>>(
                            valueListenable: StaffService().staffsNotifier,
                            builder: (context, staffs, _) => _MetricCard(
                              icon: LucideIcons.users, 
                              color: kBrandGold, 
                              label: 'Active Staff', 
                              value: staffs.length.toString(), 
                              trend: 'Active'
                            ),
                          ),
                          // CUSTOMERS (Combined count)
                          ValueListenableBuilder<List<Customer>>(
                            valueListenable: CustomerService().customersNotifier,
                            builder: (context, customers, _) {
                              return ValueListenableBuilder<List<Invoice>>(
                                valueListenable: InvoiceService().invoicesNotifier,
                                builder: (context, invoices, _) {
                                  final uniqueInvoicedCustomers = invoices.map((i) => i.customerName.toLowerCase()).toSet();
                                  final uniqueTableCustomers = customers.map((c) => c.name.toLowerCase()).toSet();
                                  final allUniqueCustomers = {...uniqueInvoicedCustomers, ...uniqueTableCustomers};
                                  
                                  return _MetricCard(
                                    icon: LucideIcons.userCheck, 
                                    color: const Color(0xFF8B5CF6), 
                                    label: 'Customers', 
                                    value: allUniqueCustomers.length.toString(), 
                                    trend: 'Total'
                                  );
                                },
                              );
                            },
                          ),
                        ];

                        if (isWide) {
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: metricWidgets.map((w) => SizedBox(width: 160, height: 130, child: w)).toList(),
                          );
                        }

                        return SizedBox(
                          height: 130,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: metricWidgets,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 4. Recent Sales
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                  TextButton(
                    onPressed: () => onTabChange?.call(3),
                    child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700, color: kBrandGold)),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            sliver: ValueListenableBuilder<List<Invoice>>(
              valueListenable: InvoiceService().invoicesNotifier,
              builder: (context, invoices, _) {
                if (invoices.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: const Column(
                        children: [
                          Icon(LucideIcons.receipt, color: Color(0xFFCBD5E1), size: 48),
                          SizedBox(height: 12),
                          Text(
                            'No Transactions Found',
                            style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Your recent sales will appear here.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final recentInvoices = invoices.take(5).toList();
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final invoice = recentInvoices[index];
                      return _StreamlinedSaleTile(
                        customer: invoice.customerName, 
                        vehicle: invoice.vehicleName, 
                        amount: 'Rs. ${invoice.amount}', 
                        timeAgo: invoice.date
                      );
                    },
                    childCount: recentInvoices.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kBrandDark, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: kBrandDark)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
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
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String trend;
  const _MetricCard({required this.icon, required this.color, required this.label, required this.value, required this.trend});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trend.contains('+') || trend == 'Now' || trend == 'Active' ? const Color(0xFF10B981).withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(trend, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: trend.contains('+') || trend == 'Now' || trend == 'Active' ? const Color(0xFF059669) : color)),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1)),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StreamlinedSaleTile extends StatelessWidget {
  final String customer;
  final String vehicle;
  final String amount;
  final String timeAgo;
  const _StreamlinedSaleTile({required this.customer, required this.vehicle, required this.amount, required this.timeAgo});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kBrandDark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
            child: const Icon(LucideIcons.receipt, color: kBrandDark, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text('$vehicle • $timeAgo', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 15)),
        ],
      ),
    );
  }
}
