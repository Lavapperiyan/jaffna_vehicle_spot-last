import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice.dart';
import '../models/auth_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  bool _showFixButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Sales Analytics',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => setState(() => _showFixButton = !_showFixButton),
            icon: Icon(
              _showFixButton ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 20,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Invoice>>(
        valueListenable: InvoiceService().invoicesNotifier,
        builder: (context, allInvoices, _) {
          final authService = AuthService();
          final currentBranch = authService.branch;
          final invoices = allInvoices.where((inv) {
            final String userBranchLower = currentBranch.trim().toLowerCase();
            final String invBranchLower = inv.branch.trim().toLowerCase();

            bool branchMatch = userBranchLower == 'all_branches' || 
                userBranchLower == 'all branches' ||
                invBranchLower == userBranchLower || 
                invBranchLower.isEmpty;

            // Strict personal sales filtering for the logged-in user
            bool userMatch = inv.salesPersonId == authService.userId && authService.userId.isNotEmpty;
            
            return branchMatch && userMatch;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showFixButton) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uid = authService.userId;
                        if (uid.isEmpty) return;
                        
                        final messenger = ScaffoldMessenger.of(context);
                        final supabase = Supabase.instance.client;
                        
                        try {
                          // 1. Fetch ALL invoices and filter in Dart for absolute compatibility
                          final allResponse = await supabase
                              .from('invoices')
                              .select('id, customer_name');
                          
                          final List<dynamic> allData = allResponse as List;
                          final List<String> targets = ['Nimal Silva', 'Priya Fernando', 'Kumar Perera'];
                          
                          final List<dynamic> targetInvoices = allData.where((inv) {
                            final String name = (inv['customer_name'] ?? '').toString();
                            return targets.contains(name);
                          }).toList();
                          
                          if (targetInvoices.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('No matching records found to fix!')),
                            );
                            return;
                          }

                          // 2. Update each of them
                          int updatedCount = 0;
                          for (var inv in targetInvoices) {
                            final success = await InvoiceService().updateInvoiceSalesPerson(inv['id'], uid);
                            if (success) updatedCount++;
                          }
                          
                          messenger.showSnackBar(
                            SnackBar(content: Text('Succesfully claimed $updatedCount vehicle(s) for your analytics!')),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Error fixing data: $e')),
                          );
                        }
                      },
                      icon: const Icon(LucideIcons.hammer, size: 14),
                      label: const Text('FIX MY DATA: Claim INV-001, 002, 003', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[900],
                        side: BorderSide(color: Colors.blue[900]!),
                      ),
                    ),
                  ),
                ],
                _buildSummaryGrid(invoices),
                const SizedBox(height: 24),
                _buildChartSection('Sales Trend (Volume)', _buildBarChart(invoices)),
                const SizedBox(height: 24),
                _buildChartSection('Category Breakdown', _buildPieChart(invoices)),
                const SizedBox(height: 24),
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 16),
                _buildRecentSalesList(invoices),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryGrid(List<Invoice> invoices) {
    double totalRevenue = 0;
    for (var inv in invoices) {
      // Robust double parsing: remove currency symbols, letters, and commas
      String cleanedAmount = inv.amount.replaceAll(RegExp(r'[^0-9.]'), '');
      double val = double.tryParse(cleanedAmount) ?? 0;
      
      // Handle M and K suffixes specifically if they exist in the original string
      if (inv.amount.toUpperCase().contains('M')) {
        val *= 1000000;
      } else if (inv.amount.toUpperCase().contains('K')) {
        val *= 1000;
      }
      
      totalRevenue += val;
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          label: 'Total Revenue',
          value: 'Rs. ${(totalRevenue / 1000000).toStringAsFixed(1)}M',
          icon: LucideIcons.dollarSign,
          color: const Color(0xFF059669),
        ),
        _buildMetricCard(
          label: 'Vehicles Sold',
          value: '${invoices.length}',
          icon: LucideIcons.car,
          color: const Color(0xFF2C3545),
        ),
      ],
    );
  }

  Widget _buildMetricCard({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _buildChartSection(String title, Widget chart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return const Center(child: Text('No data available', style: TextStyle(color: Colors.grey)));
    }

    // Pivot the chart on the LATEST invoice date instead of strictly DateTime.now()
    // This handles scenarios where the user is looking at historical data (e.g., 2024 invoices)
    DateTime pivotDate = DateTime.now();
    
    if (invoices.isNotEmpty) {
      DateTime latestInvoiceDate = DateTime(1900);
      bool foundValidDate = false;
      
      for (var inv in invoices) {
        final d = DateTime.tryParse(inv.date);
        if (d != null) {
          foundValidDate = true;
          if (d.isAfter(latestInvoiceDate)) {
            latestInvoiceDate = d;
          }
        }
      }
      
      // If the latest invoice is in the past compared to NOW, pivot to it
      // so the chart isn't empty.
      if (foundValidDate && latestInvoiceDate.isBefore(DateTime.now())) {
        pivotDate = latestInvoiceDate;
      }
    }

    final Map<int, int> monthlyCounts = {};
    
    // Get 6 months start date relative to pivotDate
    final sixMonthsAgo = DateTime(pivotDate.year, pivotDate.month - 5, 1);

    for (var inv in invoices) {
      // Try multiple parsing strategies for the date
      DateTime? date;
      if (inv.date.isNotEmpty) {
        date = DateTime.tryParse(inv.date);
        if (date == null && inv.date.contains('/')) {
          // Handle DD/MM/YYYY or MM/DD/YYYY if found
          final parts = inv.date.split('/');
          if (parts.length == 3) {
            date = DateTime.tryParse('${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}');
          }
        }
      }

      if (date != null && date.isAfter(sixMonthsAgo.subtract(const Duration(seconds: 1)))) {
        final monthsDiff = ((date.year - sixMonthsAgo.year) * 12) + (date.month - sixMonthsAgo.month);
        if (monthsDiff >= 0 && monthsDiff < 6) {
          monthlyCounts[monthsDiff] = (monthlyCounts[monthsDiff] ?? 0) + 1;
        }
      }
    }

    // Prepare month labels for display
    final List<String> monthLabels = [];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    for (int i = 0; i < 6; i++) {
      final d = DateTime(sixMonthsAgo.year, sixMonthsAgo.month + i, 1);
      monthLabels.add(monthNames[d.month - 1]);
    }

    final double maxVal = monthlyCounts.values.isEmpty 
        ? 5 
        : (monthlyCounts.values.reduce((a, b) => a > b ? a : b).toDouble() + 1);

    // If maxVal is 1 (e.g. only 1 sale), make it at least 2 for better scaling
    final displayMax = maxVal < 2 ? 4.0 : maxVal;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: displayMax,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= monthLabels.length) return const SizedBox();
                return Text(monthLabels[idx], style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(monthLabels.length, (index) {
          final count = (monthlyCounts[index] ?? 0).toDouble();
          return _generateGroup(index, count);
        }),
      ),
    );
  }

  BarChartGroupData _generateGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF2C3545),
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildPieChart(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return const Center(child: Text('No data available', style: TextStyle(color: Colors.grey)));
    }

    final Map<String, int> categories = {};
    for (var inv in invoices) {
      String cat = inv.vehicleType.trim();
      if (cat.isEmpty) cat = 'Other';
      categories[cat] = (categories[cat] ?? 0) + 1;
    }

    final List<Color> colors = [
      const Color(0xFF2C3545),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
    ];

    int colorIndex = 0;
    final List<PieChartSectionData> sections = categories.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      final percentage = (entry.value / invoices.length * 100).toStringAsFixed(0);
      
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.key}\n$percentage%',
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 45,
        sections: sections,
      ),
    );
  }

  Widget _buildRecentSalesList(List<Invoice> invoices) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: invoices.length > 5 ? 5 : invoices.length,
      itemBuilder: (context, index) {
        final inv = invoices[invoices.length - 1 - index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.fileText, color: Color(0xFF2C3545)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inv.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(inv.vehicleName, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rs. ${inv.amount}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2C3545))),
                  Text(inv.date, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

