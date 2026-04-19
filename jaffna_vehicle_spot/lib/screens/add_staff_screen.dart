import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/staff.dart';
import '../models/email_service.dart';
import '../utils/api_config.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/branch_service.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _branchController = TextEditingController();
  final _postalAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _homeNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  bool _isSendingEmail = false;
  final _nicNoController = TextEditingController();
  final _spouseNameController = TextEditingController();
  final _spouseContactController = TextEditingController();
  final _spouseNicController = TextEditingController();
  final _spouseAddressController = TextEditingController();
  final _spouseRelationshipController = TextEditingController();
  final _olResultsController = TextEditingController();
  final _alResultsController = TextEditingController();
  final _otherQualificationsController = TextEditingController();
  final _offenseNatureController = TextEditingController();
  final _salaryAmountController = TextEditingController();
  final _salaryAllowanceController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _epfNoController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedCivilStatus = 'Single';
  StaffRole _selectedRole = StaffRole.salesPerson;
  bool _hasOffense = false;
  String _olStatus = 'Pass';
  String _alStatus = 'Pass';
  List<String> _branchNames = [];
  bool _isLoadingBranches = true;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    try {
      await BranchService().fetchBranches();
      if (mounted) {
        setState(() {
          _branchNames = BranchService().allBranches.map((b) => b.name).toList();
          if (_branchNames.isNotEmpty) {
            _branchController.text = _branchNames.first;
          }
          _isLoadingBranches = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingBranches = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _branchController.dispose();
    _postalAddressController.dispose();
    _permanentAddressController.dispose();
    _mobileNoController.dispose();
    _homeNoController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _nicNoController.dispose();
    _spouseNameController.dispose();
    _spouseContactController.dispose();
    _spouseNicController.dispose();
    _spouseAddressController.dispose();
    _spouseRelationshipController.dispose();
    _olResultsController.dispose();
    _alResultsController.dispose();
    _otherQualificationsController.dispose();
    _offenseNatureController.dispose();
    _salaryAmountController.dispose();
    _salaryAllowanceController.dispose();
    _bankNameController.dispose();
    _bankBranchController.dispose();
    _accountNoController.dispose();
    _epfNoController.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), 
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C3545),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSendingEmail = true);
      
      try {
        final now = DateTime.now();
        final String generatedPassword = _generatePassword();
        
        final newStaff = Staff(
          id: '', // Will be updated by service
          staffCode: '', // Will be generated by service
          name: _fullNameController.text.split(' ').first,
          fullName: _fullNameController.text,
          role: _selectedRole,
          phone: _mobileNoController.text,
          mobileNo: _mobileNoController.text,
          homeNo: _homeNoController.text,
          email: _emailController.text,
          joinDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
          branch: _branchController.text,
          postalAddress: _postalAddressController.text,
          permanentAddress: _permanentAddressController.text,
          gender: _selectedGender,
          civilStatus: _selectedCivilStatus,
          dob: _dobController.text,
          nicNo: _nicNoController.text,
          spouseName: _spouseNameController.text,
          spouseContact: _spouseContactController.text,
          spouseNic: _spouseNicController.text,
          spouseAddress: _spouseAddressController.text,
          spouseRelationship: _spouseRelationshipController.text,
          olResults: _olStatus,
          alResults: _alStatus,
          otherQualifications: _otherQualificationsController.text,
          hasOffense: _hasOffense,
          offenseNature: _offenseNatureController.text,
          salaryAmount: _salaryAmountController.text,
          salaryAllowance: _salaryAllowanceController.text,
          bankName: _bankNameController.text,
          bankBranch: _bankBranchController.text,
          accountNo: _accountNoController.text,
          epfNo: _epfNoController.text,
          username: _fullNameController.text.toLowerCase().replaceAll(' ', '_'),
          password: generatedPassword,
        );

        final String? realStaffId = await StaffService().addStaff(newStaff);

        if (realStaffId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to register staff in database.'), backgroundColor: Colors.red),
            );
          }
          return;
        }

        final bool emailSent = await EmailService.sendCredentialsEmail(
          recipientEmail: _emailController.text,
          staffName: _fullNameController.text,
          staffId: realStaffId,
          password: generatedPassword,
        );

        if (mounted) {
          // Show credentials in a dialog as backup
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(LucideIcons.checkCircle, color: Color(0xFF10B981)),
                  SizedBox(width: 12),
                  Text('Registration Success'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Staff member has been registered successfully!'),
                  const SizedBox(height: 20),
                  const Text('LOGIN CREDENTIALS (Share with staff):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildCredentialRow('Login Email', _emailController.text),
                        const Divider(),
                        FutureBuilder<String?>(
                          future: _getGeneratedCode(realStaffId),
                          builder: (context, snapshot) {
                            return _buildCredentialRow('Staff ID', snapshot.data ?? 'Generating...');
                          },
                        ),
                        const Divider(),
                        _buildCredentialRow('Initial Password', generatedPassword),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Note: An email with these details has also been sent (check Spam folder if not found).', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to staff list
                  },
                  child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3545))),
                ),
              ],
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(emailSent 
                ? 'Email sent successfully!' 
                : 'Registration successful, but email failed. Please note the credentials above.'),
              backgroundColor: emailSent ? const Color(0xFF10B981) : Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSendingEmail = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'Staff Registration',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF111827), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: const Text(
                'Complete all the required information to register a new staff member to the system.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildApplicationSummarySection(),
                    _buildPersonalDetailsSection(),
                    _buildContactInformationSection(),
                    _buildFamilyEmergencySection(),
                    _buildEducationalQualificationsSection(),
                    _buildLegalDeclarationsSection(),
                    _buildFinancialBankingSection(),
                    _buildSubmitButton(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationSummarySection() {
    return _buildSectionCard(
      title: 'Application Summary',
      icon: LucideIcons.fileText,
      children: [
        _isLoadingBranches 
          ? const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ))
          : _buildDropdownField(
              'Branch', 
              (_branchNames.contains(_branchController.text)) ? _branchController.text : (_branchNames.isNotEmpty ? _branchNames.first : 'No branches found'), 
              _branchNames.isEmpty ? ['No branches found'] : _branchNames, 
              (val) {
                setState(() => _branchController.text = val!);
              }, 
              icon: LucideIcons.mapPin
            ),
        const SizedBox(height: 20),
        _buildDropdownField('System Role', _selectedRole.name, StaffRole.values.map((e) => e.name).toList(), (val) {
          setState(() => _selectedRole = StaffRole.values.firstWhere((e) => e.name == val));
        }, icon: LucideIcons.shieldCheck),
      ],
    );
  }

  Widget _buildPersonalDetailsSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Personal Details',
          icon: LucideIcons.user,
          children: [
            _buildTextField('Name in Full', _fullNameController, 'Enter full name', icon: LucideIcons.userCircle),
            const SizedBox(height: 20),
            _buildTextField('NIC No.', _nicNoController, 'Enter NIC number', icon: LucideIcons.contact, maxLength: 12),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField('Date of Birth', _dobController, 'YYYY-MM-DD', icon: LucideIcons.calendar),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField('Gender', _selectedGender, ['Male', 'Female', 'Other'], (val) {
                    setState(() => _selectedGender = val!);
                  }, icon: LucideIcons.users),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdownField('Civil Status', _selectedCivilStatus, ['Single', 'Married', 'Other'], (val) {
              setState(() => _selectedCivilStatus = val!);
            }, icon: LucideIcons.heart),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInformationSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Contact Information',
          icon: LucideIcons.phone,
          children: [
            _buildTextField('Postal Address', _postalAddressController, 'Enter postal address', icon: LucideIcons.home, maxLines: 2),
            const SizedBox(height: 20),
            _buildTextField('Permanent Address', _permanentAddressController, 'Enter permanent address', icon: LucideIcons.map, maxLines: 2),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Mobile No.', 
                    _mobileNoController, 
                    '077 123 4567', 
                    icon: LucideIcons.smartphone,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'Home No.', 
                    _homeNoController, 
                    '021 123 4567', 
                    icon: LucideIcons.phoneCall,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                  )
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField('E-Mail Address', _emailController, 'name@example.com', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
          ],
        ),
      ],
    );
  }

  Widget _buildFamilyEmergencySection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Family / Emergency Contact',
          icon: LucideIcons.users,
          children: [
            _buildTextField('Spouse Name', _spouseNameController, 'Enter name', icon: LucideIcons.user),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildTextField('NIC No.', _spouseNicController, 'Enter NIC', icon: LucideIcons.contact)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Contact No.', _spouseContactController, 'Enter phone', icon: LucideIcons.phone, keyboardType: TextInputType.phone)),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField('Address', _spouseAddressController, 'Enter address', icon: LucideIcons.mapPin),
            const SizedBox(height: 20),
            _buildTextField('Relationship', _spouseRelationshipController, 'e.g. Wife, Husband', icon: LucideIcons.heart),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationalQualificationsSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Educational Qualifications',
          icon: LucideIcons.graduationCap,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField('G.C.E. O/Level', _olStatus, ['Pass', 'Fail', 'Pending'], (val) {
                    setState(() => _olStatus = val!);
                  }, icon: LucideIcons.checkSquare),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField('G.C.E. A/Level', _alStatus, ['Pass', 'Fail', 'Pending', 'N/A'], (val) {
                    setState(() => _alStatus = val!);
                  }, icon: LucideIcons.award),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField('Other qualifications', _otherQualificationsController, 'Diplomas, Degrees etc.', icon: LucideIcons.scrollText, maxLines: 2),
          ],
        ),
      ],
    );
  }

  Widget _buildLegalDeclarationsSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Legal Declarations',
          icon: LucideIcons.alertCircle,
          children: [
            SwitchListTile(
              title: const Text('Conflict for any offence?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              value: _hasOffense,
              onChanged: (val) => setState(() => _hasOffense = val),
              activeThumbColor: const Color(0xFF2C3545),
              contentPadding: EdgeInsets.zero,
            ),
            if (_hasOffense) ...[
              const SizedBox(height: 16),
              _buildTextField('Nature of the offense', _offenseNatureController, 'Please describe...', icon: LucideIcons.info, maxLines: 2),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialBankingSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSectionCard(
          title: 'Financial & Banking',
          icon: LucideIcons.building,
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField('Salary', _salaryAmountController, 'Base', icon: LucideIcons.wallet, prefix: 'Rs. ')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Allowance', _salaryAllowanceController, 'Total', icon: LucideIcons.plusCircle, prefix: 'Rs. ')),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField('Bank Name', _bankNameController, 'e.g. BOC', icon: LucideIcons.landmark),
            const SizedBox(height: 20),
            _buildTextField('Bank Branch', _bankBranchController, 'Branch name', icon: LucideIcons.mapPin),
            const SizedBox(height: 20),
            _buildTextField('Account No', _accountNoController, 'Account number', icon: LucideIcons.creditCard),
            const SizedBox(height: 20),
            _buildTextField('EPF No', _epfNoController, 'EPF number', icon: LucideIcons.hash),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF2C3545), Color(0xFF4A5568)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ElevatedButton(
            onPressed: _isSendingEmail ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: _isSendingEmail
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.userPlus, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Register Staff Member',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ],
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3545).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2C3545), size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827), letterSpacing: -0.5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    String hint, {
    required IconData icon,
    TextInputType keyboardType = TextInputType.text, 
    String? prefix, 
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.2),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
            counterText: "",
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2C3545), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              if (label.contains('if applicable')) return null;
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged, {required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280), letterSpacing: 0.2),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (items.contains(value)) ? value : (items.isNotEmpty ? items.first : null),
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 20, color: Color(0xFF9CA3AF)),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
                      const SizedBox(width: 12),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _getGeneratedCode(String id) async {
    try {
      final response = await Supabase.instance.client
          .from(ApiConfig.tableStaff)
          .select('staff_code')
          .eq('id', id)
          .maybeSingle();
      return response?['staff_code']?.toString();
    } catch (e) {
      return null;
    }
  }

  Widget _buildCredentialRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value, 
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C3545)),
            ),
          ),
        ],
      ),
    );
  }
}
