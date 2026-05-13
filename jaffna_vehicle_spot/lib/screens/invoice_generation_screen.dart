import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/vehicle.dart';
import '../models/invoice.dart';
import '../models/customer.dart';
import '../models/auth_service.dart';
import '../models/commission.dart';
import '../utils/pdf_helper.dart';

class InvoiceGenerationScreen extends StatefulWidget {
  final Vehicle vehicle;

  const InvoiceGenerationScreen({super.key, required this.vehicle});

  @override
  State<InvoiceGenerationScreen> createState() => _InvoiceGenerationScreenState();
}

class _InvoiceGenerationScreenState extends State<InvoiceGenerationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
    text: DateTime.now().toString().split(' ')[0],
  );
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _leaseAmountController = TextEditingController(text: '0');
  final TextEditingController _downPaymentController = TextEditingController(text: '0');
  final TextEditingController _leaseCompanyController = TextEditingController();
  
  bool _isLease = false;
  
  Commission? _pendingCommission;

  final InvoiceService _invoiceService = InvoiceService();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.vehicle.price;
    _totalController.text = widget.vehicle.price;

    // Update total automatically when subtotal changes
    _amountController.addListener(() {
      if (_totalController.text != _amountController.text) {
        _totalController.text = _amountController.text;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _nicController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _totalController.dispose();
    _leaseAmountController.dispose();
    _downPaymentController.dispose();
    _leaseCompanyController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerateInvoice() async {
    if (AuthService().userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You must be logged in to generate an invoice.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer name')),
      );
      return;
    }

    // Create Invoice object
    final newInvoice = Invoice(
      id: 'INV-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}', // App generates UUID/ID

      customerName: _nameController.text,
      customerAddress: _addressController.text,
      customerContact: _contactController.text,
      customerNic: _nicController.text,
      vehicleName: widget.vehicle.name,
      vehicleType: widget.vehicle.category,
      fuelType: widget.vehicle.fuelType,
      chassisNo: widget.vehicle.chassisNo,
      engineNo: widget.vehicle.engineNo,
      registrationNo: widget.vehicle.registrationNo,
      color: widget.vehicle.color,
      year: widget.vehicle.yearOfManufacture,
      amount: _totalController.text.replaceAll(',', '').replaceAll('Rs. ', '').trim(),
      leaseAmount: _isLease ? _leaseAmountController.text.replaceAll(',', '').replaceAll('Rs. ', '').trim() : '0',
      downPayment: _isLease ? _downPaymentController.text.replaceAll(',', '').replaceAll('Rs. ', '').trim() : '0',
      leaseCompany: _isLease ? _leaseCompanyController.text.trim() : '',
      date: _dateController.text,
      status: InvoiceStatus.paid,
      salesPersonId: AuthService().userId,
      commissionId: _pendingCommission?.id,
      branch: AuthService().branch,
    );

    // Save to global list
    Invoice? insertedInvoice;
    try {
      insertedInvoice = await _invoiceService.addInvoice(newInvoice);
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Failed to generate invoice';
      if (e.toString().contains('row-level security policy') || e.toString().contains('42501')) {
        errorMessage = 'Security Error: Your login session has expired. Please log out and log in again.';
      } else {
        errorMessage = 'Failed to generate invoice: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }
    
    if (insertedInvoice == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate invoice')),
      );
      return;
    }

    // Save commission if exists
    if (_pendingCommission != null) {
      final commissionToSave = Commission(
        id: _pendingCommission!.id,
        invoiceId: insertedInvoice.id, // Link to actual invoice
        agentName: _pendingCommission!.agentName,
        agentContact: _pendingCommission!.agentContact,
        type: _pendingCommission!.type,
        amount: _pendingCommission!.amount,
        reason: _pendingCommission!.reason,
        date: _pendingCommission!.date,
      );
      CommissionService().addCommission(commissionToSave);
    }
    
    // Mark vehicle as Sold
    await VehicleService().updateVehicleStatus(widget.vehicle.id, 'Sold');

    // Automatically update/add customer to customer management
    final customer = Customer(
      id: '', // Supabase will generate UUID
      name: _nameController.text,
      nic: _nicController.text,
      phone: _contactController.text,
      address: _addressController.text,
      email: '', // Email not captured in this form
      purchasedVehicles: [widget.vehicle.name],
      joinDate: _dateController.text,
      branch: AuthService().branch,
    );
    CustomerService().addOrUpdateCustomer(customer);

    await PdfHelper.viewPdf(insertedInvoice);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(LucideIcons.image, color: Color(0xFF2C3545), size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Generate Invoice',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Text(
                  'Jaffna Vehicle Spot • ${AuthService().branch}',
                  style: const TextStyle(
                      fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.vehicle.imageUrl.startsWith('http')
                          ? Image.network(widget.vehicle.imageUrl, width: 60, height: 40, fit: BoxFit.cover)
                          : Image.asset(widget.vehicle.imageUrl, width: 60, height: 40, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.vehicle.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(widget.vehicle.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      'Rs. ${widget.vehicle.price}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2C3545)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text('Customer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildInputField('Full Name', 'Enter customer name', _nameController),
              const SizedBox(height: 16),
              _buildInputField('Address', 'Enter address', _addressController),
              const SizedBox(height: 16),
              _buildInputField('Contact', 'Enter phone number', _contactController),
              const SizedBox(height: 16),
              _buildInputField('NIC No', 'Enter NIC number', _nicController),
              const SizedBox(height: 16),
              _buildDatePickerField('Invoice Date', _dateController),

              const SizedBox(height: 32),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Billing Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('(Tap values to edit)', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
                ],
              ),
              const SizedBox(height: 16),
              _buildEditableBillingRow('Subtotal', _amountController),
              const Divider(height: 32),
              
              // Purchase Type Selector
              const Text('Purchase Type', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLease = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isLease ? const Color(0xFF2C3545) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2C3545)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Full Payment',
                          style: TextStyle(
                            color: !_isLease ? Colors.white : const Color(0xFF2C3545),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLease = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isLease ? const Color(0xFF2C3545) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2C3545)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Lease',
                          style: TextStyle(
                            color: _isLease ? Colors.white : const Color(0xFF2C3545),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              if (_isLease) ...[
                const SizedBox(height: 16),
                _buildInputField('Lease Company', 'Enter lease company name', _leaseCompanyController),
                const SizedBox(height: 16),
                _buildEditableBillingRow('Lease Amount', _leaseAmountController),
                _buildEditableBillingRow('Down Payment', _downPaymentController),
              ],

              const Divider(height: 32),
              _buildEditableBillingRow('Total Amount', _totalController, isTotal: true),

              const SizedBox(height: 16),
              _buildCommissionSection(),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleGenerateInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3545),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Generate Invoice PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableBillingRow(String label, TextEditingController controller, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 18 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                  color: isTotal ? Colors.black : Colors.grey)),
          SizedBox(
            width: 150,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: isTotal ? 20 : 14,
                  fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
                  color: isTotal ? const Color(0xFF2C3545) : Colors.black),
              decoration: const InputDecoration(
                prefixText: 'Rs. ',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2C3545))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF2C3545),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                controller.text = picked.toString().split(' ')[0];
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Select date',
            prefixIcon: const Icon(LucideIcons.calendar, size: 18),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _pendingCommission == null ? Colors.white : const Color(0xFF2C3545).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _pendingCommission == null ? Colors.transparent : const Color(0xFF2C3545), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.percent, size: 20, color: Color(0xFF2C3545)),
                  SizedBox(width: 12),
                  Text('Agent Commission', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              if (_pendingCommission == null)
                TextButton.icon(
                  onPressed: _showCommissionDialog,
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add Commission'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF2C3545)),
                )
              else
                IconButton(
                  onPressed: () => setState(() => _pendingCommission = null),
                  icon: const Icon(LucideIcons.x, size: 16, color: Colors.red),
                ),
            ],
          ),
          if (_pendingCommission != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_pendingCommission!.agentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Rs. ${_pendingCommission!.amount}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3545)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showCommissionDialog() {
    final agentNameController = TextEditingController();
    final agentContactController = TextEditingController();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    CommissionType type = CommissionType.fixed;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Commission', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: agentNameController, decoration: const InputDecoration(labelText: 'Agent Name')),
                TextField(controller: agentContactController, decoration: const InputDecoration(labelText: 'Contact Number')),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Type: '),
                    ChoiceChip(
                      label: const Text('Fixed'),
                      selected: type == CommissionType.fixed,
                      onSelected: (val) => setDialogState(() => type = CommissionType.fixed),
                    ),
                    ChoiceChip(
                      label: const Text('Percentage'),
                      selected: type == CommissionType.percentage,
                      onSelected: (val) => setDialogState(() => type = CommissionType.percentage),
                    ),
                  ],
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: type == CommissionType.fixed ? 'Amount (Rs)' : 'Percentage (%)'),
                ),
                TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Reason / Note')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final double baseAmount = double.tryParse(amountController.text) ?? 0;
                double finalAmount = baseAmount;
                if (type == CommissionType.percentage) {
                  // Calculate percentage of subtotal
                  final subtotal = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
                  finalAmount = (subtotal * baseAmount) / 100;
                }

                setState(() {
                  _pendingCommission = Commission(
                    id: 'COM-${DateTime.now().millisecondsSinceEpoch}',
                    invoiceId: 'PENDING', // Will be updated on generation
                    agentName: agentNameController.text,
                    agentContact: agentContactController.text,
                    type: type,
                    amount: finalAmount,
                    reason: reasonController.text,
                    date: DateTime.now().toString().split(' ')[0],
                  );
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3545)),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

