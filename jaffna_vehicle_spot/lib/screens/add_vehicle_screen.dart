import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import '../models/vehicle.dart';
import 'package:intl/intl.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _chassisController = TextEditingController();
  final _engineController = TextEditingController();
  final _regController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _amountController = TextEditingController();
  
  List<Uint8List> _imagesBytes = [];
  List<String> _imagesNames = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  String _selectedCategory = 'Car';
  final List<String> _categories = ['Car', 'Van', 'Load Vehicle', 'Electric'];

  @override
  void dispose() {
    _nameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _chassisController.dispose();
    _engineController.dispose();
    _regController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _buyPriceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_imagesBytes.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 images allowed')),
      );
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        if (_imagesBytes.length < 10) {
          final bytes = await file.readAsBytes();
          setState(() {
            _imagesBytes.add(bytes);
            _imagesNames.add(file.name);
          });
        }
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagesBytes.removeAt(index);
      _imagesNames.removeAt(index);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        List<String> imageUrls = [];
        
        if (_imagesBytes.isNotEmpty) {
          for (int i = 0; i < _imagesBytes.length; i++) {
            final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_imagesNames[i]}';
            final uploadedUrl = await VehicleService().uploadImage(_imagesBytes[i], fileName);
            if (uploadedUrl != null) {
              imageUrls.add(uploadedUrl);
            }
          }
        }

        final now = DateTime.now();
        final formattedDate = DateFormat('yyyy-MM-dd').format(now);
        
        final newVehicle = Vehicle(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          make: _makeController.text,
          model: _modelController.text,
          category: _selectedCategory,
          price: _amountController.text,
          buyPrice: _buyPriceController.text,
          status: 'Available',
          imageUrl: imageUrls.isNotEmpty ? imageUrls.first : 'assets/toyota_chr.png',
          imageUrls: imageUrls,
          chassisNo: _chassisController.text,
          engineNo: _engineController.text,
          registrationNo: _regController.text,
          color: _colorController.text,
          yearOfManufacture: _yearController.text,
          stockUpdateDate: formattedDate,
        );

        final success = await VehicleService().addVehicle(newVehicle);
        
        if (mounted) {
          setState(() => _isSubmitting = false);
          if (success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vehicle added successfully!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to add vehicle. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Add New Vehicle',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Vehicle Images (Up to 10)'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imagesBytes.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _imagesBytes.length) {
                          return GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB), style: BorderStyle.solid),
                              ),
                              child: const Icon(LucideIcons.plus, color: Color(0xFF9CA3AF)),
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: MemoryImage(_imagesBytes[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(LucideIcons.x, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                      const SizedBox(height: 16),
                  _buildDropdownField('Vehicle Type', _selectedCategory, _categories, (val) {
                    setState(() => _selectedCategory = val!);
                  }),
                  const SizedBox(height: 16),
                  _buildTextField('Vehicle Name', _nameController, 'e.g. TOYOTA C-HR'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Make', _makeController, 'e.g. Toyota')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Model', _modelController, 'e.g. C-HR')),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Technical Details'),
                  const SizedBox(height: 16),
                  _buildTextField('Chassis Number', _chassisController, 'e.g. MH95S-285447'),
                  const SizedBox(height: 16),
                  _buildTextField('Engine Number', _engineController, 'e.g. R06D-WA04C'),
                  const SizedBox(height: 16),
                  _buildTextField('Registration Number', _regController, 'e.g. NP CBR-3153'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Colour', _colorController, 'e.g. PEARL WHITE')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField('Year', _yearController, 'e.g. 2025', keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Pricing'),
                  const SizedBox(height: 16),
                  _buildTextField('Buy Price (e.g. 10.5M or 600,000)', _buyPriceController, 'Enter buying price', prefix: 'Rs. '),
                  const SizedBox(height: 16),
                  _buildTextField('Selling Amount (e.g. 12.5M or 778,970)', _amountController, 'Enter selling price', prefix: 'Rs. '),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3545),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Add Vehicle to Stocks',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF2C3545)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2C3545), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 20),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF111827)),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

