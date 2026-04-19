import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/commission.dart';
import '../models/auth_service.dart';
import '../models/invoice.dart';

class CommissionReportsScreen extends StatefulWidget {
  const CommissionReportsScreen({super.key});

  @override
  State<CommissionReportsScreen> createState() => _CommissionReportsScreenState();
}

class _CommissionReportsScreenState extends State<CommissionReportsScreen> {
  final CommissionService _commissionService = CommissionService();
  
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    const Color kBg = Color(0xFFF3F4F6);
    const Color kDark = Color(0xFF2C3545);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kDark,
        elevation: 0,
        title: const Text('Commission Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => _commissionService.fetchCommissions(),
          ),
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () {
              // PDF Export Placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting Report...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ValueListenableBuilder<List<Commission>>(
              valueListenable: _commissionService.commissionsNotifier,
              builder: (context, commissions, child) {
                final String userRole = AuthService().userPost.toLowerCase();
                final bool isAdmin = userRole.contains('admin');
                final String currentBranch = AuthService().branch.trim().toLowerCase();

                final filtered = commissions.where((c) {
                  final matchesSearch = c.agentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                      c.reference.toLowerCase().contains(_searchQuery.toLowerCase());
                  
                  bool matchesDate = true;
                  if (_startDate != null && _endDate != null) {
                    DateTime? date = DateTime.tryParse(c.date);
                    if (date != null) {
                      matchesDate = date.isAfter(_startDate!.subtract(const Duration(days: 1))) && 
                                   date.isBefore(_endDate!.add(const Duration(days: 1)));
                    }
                  }

                  // Branch Filtering (Join with invoices)
                  bool matchesBranch = true;
                  if (!isAdmin) {
                    final relatedInvoice = InvoiceService().invoicesNotifier.value.firstWhere(
                      (inv) => inv.id == c.invoiceId,
                      orElse: () => Invoice(id: '', customerName: '', customerAddress: '', customerContact: '', customerNic: '', vehicleName: '', chassisNo: '', engineNo: '', registrationNo: '', vehicleType: '', fuelType: '', color: '', year: '', amount: '', leaseAmount: '', date: '', status: InvoiceStatus.paid, branch: 'unknown'),
                    );
                    
                    final String invBranch = relatedInvoice.branch.trim().toLowerCase();
                    matchesBranch = currentBranch == 'all branches' || invBranch == currentBranch || invBranch == 'unknown';
                  }
                  
                  return matchesSearch && matchesDate && matchesBranch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.percent, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _startDate == null
                            ? 'No commission records found' 
                            : 'No matching commission records found',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final commission = filtered[index];
                    return _buildCommissionCard(commission);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search Agent...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(LucideIcons.calendar, size: 16),
                  label: Text(_startDate == null ? 'Select Date' : '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'),
                ),
              ),
              if (_startDate != null)
                IconButton(
                  onPressed: () => setState(() { _startDate = null; _endDate = null; }),
                  icon: const Icon(LucideIcons.xCircle, size: 20, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(Commission commission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(commission.agentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3545))),
              Text(
                'Rs. ${commission.amount}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFE8BC44)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.phone, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(commission.agentContact, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Spacer(),
              const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(commission.date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(LucideIcons.fileText, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text(commission.reason.isEmpty ? 'Commisson for sale' : commission.reason, style: const TextStyle(fontSize: 13))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2C3545)),
          ),
          child: child!,
        );
      },
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }
}
