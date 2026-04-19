import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';

class GarageFormScreen extends StatefulWidget {
  final Vehicle vehicle;

  const GarageFormScreen({super.key, required this.vehicle});

  @override
  State<GarageFormScreen> createState() => _GarageFormScreenState();
}

class _GarageFormScreenState extends State<GarageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _garageNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverDetailsController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    const Color kBg = Color(0xFF1E1E2C);
    
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Move to Garage', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Info Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Image.network(widget.vehicle.imageUrl, width: 60, height: 60, fit: BoxFit.contain),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.vehicle.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(widget.vehicle.registrationNo, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _sectionTitle('Garage Details'),
              _buildTextField('Garage Name', _garageNameController, LucideIcons.warehouse),
              _buildTextField('Owner Name', _ownerNameController, LucideIcons.user),
              _buildTextField('Contact Number', _contactController, LucideIcons.phone, keyboardType: TextInputType.phone),
              _buildTextField('Address', _addressController, LucideIcons.mapPin),

              const SizedBox(height: 24),
              _sectionTitle('Service Details'),
              _buildTextField('Problem / Reason', _reasonController, LucideIcons.wrench),
              _buildDatePicker(),

              const SizedBox(height: 24),
              _sectionTitle('Driver Details'),
              _buildTextField('Driver Name', _driverNameController, LucideIcons.userCheck),
              _buildTextField('Contact / Identification', _driverDetailsController, LucideIcons.contact),

              const SizedBox(height: 24),
              _sectionTitle('Payment Details'),
              Row(
                children: [
                  Expanded(child: _buildTextField('Total Amount', _totalAmountController, LucideIcons.banknote, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Advance Amount', _advanceAmountController, LucideIcons.dollarSign, keyboardType: TextInputType.number)),
                ],
              ),

              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF76FF03),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                    : const Text('Save & Move to Garage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(color: Color(0xFF76FF03), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.03),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF76FF03), width: 1)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (date != null) setState(() => _selectedDate = date);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.calendar, color: Colors.white38, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  Text(DateFormat('MMM d, yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final details = GarageDetails(
        garageName: _garageNameController.text,
        ownerName: _ownerNameController.text,
        contactNumber: _contactController.text,
        address: _addressController.text,
        reason: _reasonController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        driverName: _driverNameController.text,
        driverDetails: _driverDetailsController.text,
        totalAmount: double.tryParse(_totalAmountController.text) ?? 0,
        advanceAmount: double.tryParse(_advanceAmountController.text) ?? 0,
      );

      final success = await VehicleService().moveToGarage(widget.vehicle.id, details);
      
      if (mounted) {
        if (success) {
          Navigator.pop(context);
          Navigator.pop(context); // Go back from Details too to refresh stock list
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.vehicle.name} moved to Garage!')),
          );
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to move vehicle to garage. Please try again.')),
          );
        }
      }
    }
  }

  bool _isLoading = false;
}
