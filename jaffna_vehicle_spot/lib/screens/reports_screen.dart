import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice.dart';
import '../models/staff.dart';
import '../models/auth_service.dart';
import '../utils/pdf_helper.dart';
import '../models/attendance_service.dart';
import '../models/attendance.dart';

enum FilterType { date, week, month, year }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedYear = DateTime.now().year; 
  int _selectedMonth = DateTime.now().month;
  FilterType _filterType = FilterType.month;
  String? _selectedCustomerName;
  String? _selectedStaffId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _showRawData = false;
  bool _hasDetectedInitialPeriod = false;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _refreshAllData();
  }

  void _refreshAllData() {
    InvoiceService().fetchInvoices();
    StaffService().fetchStaffs();
    AttendanceService().fetchAllAttendances();
  }

  DateTime? _tryParseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    final isoPart = dateStr.split('T')[0].trim();
    final parsed = DateTime.tryParse(isoPart);
    if (parsed != null) return parsed;
    try {
      final parts = dateStr.split(RegExp(r'[/ \-]'));
      if (parts.length >= 3) {
        int d = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        int y = int.parse(parts[2]);
        if (d > 1000) { final t = d; d = y; y = t; }
        if (m > 12) { final t = m; m = d; d = t; }
        return DateTime(y, m, d);
      }
    } catch (_) {}
    return null;
  }

  String _normalize(String input) {
    String normalized = input.toLowerCase();
    if (normalized.contains('all')) return 'all'; // Special case for global access
    return normalized
        .replaceAll('branch', '')
        .replaceAll('main', '')
        .replaceAll('shop', '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final String userPost = AuthService().userPost.toLowerCase();
    final String userBranch = AuthService().branch.toLowerCase();
    
    // SuperAdmin: Global access if branch is 'All Branches' or 'Main'
    final bool isSuperAdmin = userBranch.contains('all') || userBranch.contains('main') || userPost.contains('owner') || userPost.contains('director');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(isSuperAdmin),
            SliverToBoxAdapter(child: _buildHeaderSummary(isSuperAdmin)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _buildFilterSection(),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                child: Container(
                  color: const Color(0xFFF8FAFC),
                  child: Column(
                    children: [
                      _buildTabToggle(),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: TabBarView(
              children: [
                _buildSalesTab(isSuperAdmin),
                _buildUsageTab(isSuperAdmin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isSuperAdmin) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0F172A),
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isSuperAdmin ? 'Global Reports' : 'Branch Reports', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            Text(AuthService().branch.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1.0)),
          ],
        ),
        background: Container(color: const Color(0xFF0F172A)),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.refreshCcw, color: Colors.white70, size: 18),
          onPressed: () {
            _refreshAllData();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing with database...'), duration: Duration(seconds: 1)));
          },
        ),
        IconButton(
          icon: Icon(_showRawData ? LucideIcons.eye : LucideIcons.eyeOff, color: Colors.white70, size: 18),
          onPressed: () => setState(() => _showRawData = !_showRawData),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderSummary(bool isSuperAdmin) {
    return ValueListenableBuilder<List<Invoice>>(
      valueListenable: InvoiceService().invoicesNotifier,
      builder: (context, invoices, child) {
        final filteredInvoices = _getFilteredInvoices(invoices, isSuperAdmin);
        double totalSales = 0;
        for (var inv in filteredInvoices) {
          totalSales += double.tryParse(inv.amount.replaceAll(',', '')) ?? 0;
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Revenue',
                  'Rs. ${NumberFormat('#,###').format(totalSales)}',
                  LucideIcons.banknote,
                  [const Color(0xFF6366F1), const Color(0xFF4338CA)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Reports',
                  filteredInvoices.length.toString(),
                  LucideIcons.barChart4,
                  [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 4),
          FittedBox(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: FilterType.values.map((type) {
                bool selected = _filterType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filterType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          type.name.toUpperCase(),
                          style: TextStyle(
                            color: selected ? const Color(0xFF0F172A) : Colors.grey,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _buildPicker(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStaffFilter()),
              const SizedBox(width: 8),
              Expanded(child: _buildCustomerFilter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Financials'),
          Tab(text: 'Operations'),
        ],
      ),
    );
  }

  Widget _buildPicker() {
    if (_filterType == FilterType.date || _filterType == FilterType.week) {
      return InkWell(
        onTap: () async {
          if (_filterType == FilterType.date) {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
            );
            if (range != null) setState(() { _startDate = range.start; _endDate = range.end; });
          } else {
            final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
            if (date != null) setState(() { _startDate = date.subtract(Duration(days: date.weekday - 1)); _endDate = _startDate.add(const Duration(days: 6)); });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            children: [
              Icon(LucideIcons.calendar, size: 16, color: const Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Text(
                _filterType == FilterType.date 
                  ? '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('d, yyyy').format(_endDate)}'
                  : 'Week of ${DateFormat('MMM d, yyyy').format(_startDate)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              const Icon(LucideIcons.chevronDown, size: 14, color: Colors.grey),
            ],
          ),
        ),
      );
    } else if (_filterType == FilterType.month) {
      return Row(
        children: [
          Expanded(
            child: _buildDropDownContainer(
              child: DropdownButton<int>(
                value: _selectedMonth,
                isExpanded: true,
                underline: const SizedBox(),
                items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_months[i], style: const TextStyle(fontSize: 12)))),
                onChanged: (val) => setState(() => _selectedMonth = val!),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildDropDownContainer(
              child: DropdownButton<int>(
                value: _selectedYear,
                isExpanded: true,
                underline: const SizedBox(),
                items: List.generate(5, (i) => DropdownMenuItem(value: 2024 + i, child: Text((2024 + i).toString(), style: const TextStyle(fontSize: 12)))),
                onChanged: (val) => setState(() => _selectedYear = val!),
              ),
            ),
          ),
        ],
      );
    } else {
      return _buildDropDownContainer(
        child: DropdownButton<int>(
          value: _selectedYear,
          isExpanded: true,
          underline: const SizedBox(),
          items: List.generate(5, (i) => DropdownMenuItem(value: 2024 + i, child: Text((2024 + i).toString(), style: const TextStyle(fontSize: 12)))),
          onChanged: (val) => setState(() => _selectedYear = val!),
        ),
      );
    }
  }

  Widget _buildDropDownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: child,
    );
  }

  Widget _buildSalesTab(bool isSuperAdmin) {
    return ValueListenableBuilder<List<Invoice>>(
      valueListenable: InvoiceService().invoicesNotifier,
      builder: (context, invoices, child) {
        if (!_hasDetectedInitialPeriod && invoices.isNotEmpty) {
          _jumpToMostRecentActivity(invoices);
        }
        final filtered = _getFilteredInvoices(invoices, isSuperAdmin);
        if (filtered.isEmpty) return SingleChildScrollView(child: _buildNoDataWithActivityCheck(invoices, isSuperAdmin));

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: filtered.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDownloadCard(
                  'Financial Statement',
                  'PDF for ${filtered.length} transactions.',
                  LucideIcons.fileDown,
                  const Color(0xFF6366F1),
                  () => PdfHelper.downloadSalesReportPdf(filtered, _getFilterTitle()),
                ),
              );
            }
            return _buildInvoiceTile(filtered[index - 1]);
          },
        );
      },
    );
  }

  Widget _buildUsageTab(bool isSuperAdmin) {
    return ValueListenableBuilder<List<Attendance>>(
      valueListenable: AttendanceService().allAttendancesNotifier,
      builder: (context, attendances, child) {
        if (!_hasDetectedInitialPeriod && attendances.isNotEmpty) {
          _jumpToMostRecentActivity(attendances);
        }
        final filtered = _getFilteredAttendances(attendances, isSuperAdmin);
        if (filtered.isEmpty) return SingleChildScrollView(child: _buildNoDataWithActivityCheck(attendances, isSuperAdmin, isAttendance: true));

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: filtered.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDownloadCard(
                  'Ops Audit Report',
                  'Staff login/logout efficiency logs.',
                  LucideIcons.fileCheck2,
                  const Color(0xFF10B981),
                  () => PdfHelper.downloadStaffUsageAuditPdf(filtered, _getFilterTitle()),
                ),
              );
            }
            return _buildUsageTile(filtered[index - 1]);
          },
        );
      },
    );
  }

  Widget _buildInvoiceTile(Invoice inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.car, color: Color(0xFF475569), size: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inv.customerName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                Text('${inv.vehicleName} • ${inv.date.split('T')[0]}', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
              ],
            ),
          ),
          Text('Rs.${inv.amount.split('.')[0]}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildUsageTile(Attendance att) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: const Color(0xFFF1F5F9), child: Text(att.userName[0].toUpperCase(), style: const TextStyle(color: Color(0xFF0F172A), fontSize: 10))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(att.userName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                Text('${DateFormat('hh:mm a').format(att.checkIn)} - ${att.checkOut != null ? DateFormat('hh:mm a').format(att.checkOut!) : 'Active'}', style: TextStyle(color: Colors.grey[500], fontSize: 9)),
              ],
            ),
          ),
          Text('${att.currentTotalHours.toStringAsFixed(1)}h', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDownloadCard(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.1))),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13)),
                Text(sub, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
              ]),
            ),
            Icon(LucideIcons.arrowRight, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWithActivityCheck(List<dynamic> allRecords, bool isSuperAdmin, {bool isAttendance = false}) {
    DateTime? mostRecent;
    for (var rec in allRecords) {
      DateTime? date;
      if (rec is Invoice) date = _tryParseDate(rec.date);
      if (rec is Attendance) date = rec.checkIn;
      if (date != null && (mostRecent == null || date.isAfter(mostRecent))) mostRecent = date;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: Icon(isAttendance ? LucideIcons.userX : LucideIcons.database, size: 40, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 24),
            Text(isAttendance ? 'No Staff Activity' : 'Empty Ledger', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Text(isAttendance ? 'No login/logout records found for this period.' : 'No active records found for the selected filters.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            if (mostRecent != null) ...[
               const SizedBox(height: 32),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                     setState(() {
                       _selectedYear = mostRecent!.year;
                       _selectedMonth = mostRecent.month;
                       _filterType = FilterType.month;
                       _hasDetectedInitialPeriod = true; // Mark as handled
                       _selectedStaffId = null;
                       _selectedCustomerName = null;
                     });
                     // Force re-fetch just in case
                     _refreshAllData();
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF0F172A),
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     elevation: 0,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                   ),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(LucideIcons.zap, size: 16),
                       const SizedBox(width: 8),
                       Text('Jump and View ${DateFormat('MMMM yyyy').format(mostRecent)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                     ],
                   ),
                 ),
               ),
            ],
            if (_showRawData) _buildRawDataDiagnostic(allRecords, isSuperAdmin, isAttendance: isAttendance),
          ],
        ),
      ),
    );
  }

  Widget _buildRawDataDiagnostic(List<dynamic> all, bool isSuperAdmin, {bool isAttendance = false}) {
    final String myB = _normalize(AuthService().branch);
    final String role = AuthService().userPost;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red[100]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(LucideIcons.bug, size: 14, color: Colors.red[900]), const SizedBox(width: 8), Text('DIAGNOSTIC TRACE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.red[900], letterSpacing: 1.0))]),
          const SizedBox(height: 12),
          Text('• App Context: Branch: "$myB", Role: "$role", SuperAdmin: $isSuperAdmin', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          Text('• UI Selection: $_selectedMonth/$_selectedYear (Type: ${_filterType.name})', style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
          Text('• Supabase Data: ${all.length} ${isAttendance ? "Attendance" : "Invoice"} records.', style: const TextStyle(fontSize: 10)),
          if (!isAttendance) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final supabase = Supabase.instance.client;
                  
                  // 1. Find the UUID for ST-JA-001
                  final staffResult = await supabase
                      .from('staff')
                      .select('id')
                      .eq('staff_code', 'ST-JA-001')
                      .maybeSingle();
                  
                  if (staffResult != null && staffResult['id'] != null) {
                    final targetUid = staffResult['id'];
                    
                    // 2. Assign the 3 invoices to that ID
                    for (var id in ['INV-001', 'INV-002', 'INV-003']) {
                      await InvoiceService().updateInvoiceSalesPerson(id, targetUid);
                    }
                    
                    _refreshAllData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Succesfully assigned INV-001, 002, 003 to ST-JA-001!')),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ERROR: Staff ID for ST-JA-001 not found!')),
                      );
                    }
                  }
                },
                icon: const Icon(LucideIcons.userPlus, size: 12),
                label: const Text('DEBUG: Assign to ST-JA-001', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[900],
                  side: BorderSide(color: Colors.blue[900]!),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
          ],
          const Divider(),
          if (all.isEmpty) Text('• ALERT: No data returned from Supabase!', style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold, fontSize: 9)),
          ...all.take(5).map((rec) {
            final String branch = rec is Invoice ? rec.branch : (rec as Attendance).branch;
            final DateTime? date = rec is Invoice ? _tryParseDate(rec.date) : (rec as Attendance).checkIn;
            final String normBranch = _normalize(branch);
            final bool branchMatch = isSuperAdmin || normBranch == myB || myB.contains(normBranch) || normBranch.contains(myB);
            
            bool dateMatch = false;
            if (date != null) {
              if (_filterType == FilterType.month) dateMatch = date.year == _selectedYear && date.month == _selectedMonth;
              if (_filterType == FilterType.year) dateMatch = date.year == _selectedYear;
            }
            
            return Text(' - [${date?.year}-${date?.month}-${date?.day}] Branch: "$normBranch" | DateMatch: $dateMatch | BranchMatch: $branchMatch', 
                style: TextStyle(fontSize: 9, color: (dateMatch && branchMatch) ? Colors.green[800] : Colors.red[800]));
          }),
          if (all.length > 5) const Text('...', style: TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  void _jumpToMostRecentActivity(List<dynamic> records) {
    if (_hasDetectedInitialPeriod) return; // Don't jump again if already detected
    DateTime? mostRecent;
    for (var rec in records) {
      DateTime? d;
      if (rec is Invoice) d = _tryParseDate(rec.date);
      if (rec is Attendance) d = rec.checkIn;
      if (d != null && (mostRecent == null || d.isAfter(mostRecent))) mostRecent = d;
    }
    if (mostRecent != null) {
      _hasDetectedInitialPeriod = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedYear = mostRecent!.year;
            _selectedMonth = mostRecent.month;
            _filterType = FilterType.month;
          });
        }
      });
    }
  }


  Widget _buildStaffFilter() {
    final String userBranch = _normalize(AuthService().branch);
    final String userPost = AuthService().userPost.toLowerCase();
    final bool isSuperAdmin = (userPost.contains('admin') || userPost.contains('owner')) && AuthService().branch.toLowerCase().contains('all');

    return ValueListenableBuilder<List<Staff>>(
      valueListenable: StaffService().staffsNotifier,
      builder: (context, staffs, _) {
        final displayStaffs = isSuperAdmin ? staffs : staffs.where((s) => _normalize(s.branch) == userBranch).toList();
        return _buildDropDownContainer(
          child: DropdownButton<String>(
            value: _selectedStaffId, isExpanded: true, underline: const SizedBox(), hint: const Text('All Staff', style: TextStyle(fontSize: 11)),
            items: [const DropdownMenuItem(value: null, child: Text('All Staff', style: TextStyle(fontSize: 11))), ...displayStaffs.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, style: const TextStyle(fontSize: 11))))],
            onChanged: (val) => setState(() => _selectedStaffId = val),
          ),
        );
      },
    );
  }

  Widget _buildCustomerFilter() {
    return ValueListenableBuilder<List<Invoice>>(
      valueListenable: InvoiceService().invoicesNotifier,
      builder: (context, invoices, _) {
        final names = invoices.map((e) => e.customerName).toSet().toList();
        return _buildDropDownContainer(
          child: DropdownButton<String>(
            value: _selectedCustomerName, isExpanded: true, underline: const SizedBox(), hint: const Text('All Clients', style: TextStyle(fontSize: 11)),
            items: [const DropdownMenuItem(value: null, child: Text('All Clients', style: TextStyle(fontSize: 11))), ...names.map((n) => DropdownMenuItem(value: n, child: Text(n, style: const TextStyle(fontSize: 11))))],
            onChanged: (val) => setState(() => _selectedCustomerName = val),
          ),
        );
      },
    );
  }

  List<Invoice> _getFilteredInvoices(List<Invoice> invoices, bool isSuperAdmin) {
    final String myB = _normalize(AuthService().branch);
    return invoices.where((inv) {
      if (!isSuperAdmin) {
        final invB = _normalize(inv.branch);
        // Match if matches exactly, or contains, or is empty
        bool branchMatch = invB == myB || invB.contains(myB) || myB.contains(invB);
        if (!branchMatch && invB.isNotEmpty) return false;
      }
      final date = _tryParseDate(inv.date);
      if (date == null) return false;
      if (_filterType == FilterType.date || _filterType == FilterType.week) {
        if (date.isBefore(DateTime(_startDate.year, _startDate.month, _startDate.day)) || date.isAfter(DateTime(_endDate.year, _endDate.month, _endDate.day))) return false;
      } else if (_filterType == FilterType.month) {
        if (date.year != _selectedYear || date.month != _selectedMonth) return false;
      } else {
        if (date.year != _selectedYear) return false;
      }
      if (_selectedCustomerName != null && inv.customerName != _selectedCustomerName) return false;
      if (_selectedStaffId != null && inv.salesPersonId != _selectedStaffId) return false;
      return true;
    }).toList();
  }

  List<Attendance> _getFilteredAttendances(List<Attendance> attendances, bool isSuperAdmin) {
    final String myB = _normalize(AuthService().branch);

    return attendances.where((att) {
      if (!isSuperAdmin) {
        final attB = _normalize(att.branch);
        bool branchMatch = attB == myB || attB.contains(myB) || myB.contains(attB);
        if (!branchMatch) return false;
      }
      if (_filterType == FilterType.date || _filterType == FilterType.week) {
        if (att.checkIn.isBefore(DateTime(_startDate.year, _startDate.month, _startDate.day)) || att.checkIn.isAfter(DateTime(_endDate.year, _endDate.month, _endDate.day))) return false;
      } else if (_filterType == FilterType.month) {
        if (att.checkIn.year != _selectedYear || att.checkIn.month != _selectedMonth) return false;
      } else {
        if (att.checkIn.year != _selectedYear) return false;
      }
      if (_selectedStaffId != null && att.userId != _selectedStaffId) return false;
      return true;
    }).toList();
  }

  String _getFilterTitle() {
    if (_filterType == FilterType.date) return '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('d, yyyy').format(_endDate)}';
    if (_filterType == FilterType.week) return 'Week of ${DateFormat('MMM d').format(_startDate)}';
    if (_filterType == FilterType.month) return '${_months[_selectedMonth - 1]} $_selectedYear';
    return 'Year $_selectedYear';
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.child});
  final Widget child;
  @override
  double get minExtent => 64.0;
  @override
  double get maxExtent => 64.0;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
