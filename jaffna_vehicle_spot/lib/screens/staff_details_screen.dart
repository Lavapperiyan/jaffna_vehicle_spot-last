import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/staff.dart';
import '../utils/pdf_helper.dart';

class StaffDetailsScreen extends StatelessWidget {
  final Staff staff;

  const StaffDetailsScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Staff Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download, color: Color(0xFF2C3545)),
            onPressed: () => PdfHelper.viewStaffPdf(staff),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoSection(
                    title: 'Personal Information',
                    icon: LucideIcons.user,
                    items: [
                      _buildInfoRow('Full Name', staff.fullName),
                      _buildInfoRow('NIC No', staff.nicNo),
                      _buildInfoRow('Date of Birth', staff.dob),
                      _buildInfoRow('Gender', staff.gender),
                      _buildInfoRow('Civil Status', staff.civilStatus),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: 'Contact Details',
                    icon: LucideIcons.phone,
                    items: [
                      _buildInfoRow('Mobile No', staff.mobileNo),
                      _buildInfoRow('Home No', staff.homeNo),
                      _buildInfoRow('Email', staff.email),
                      _buildInfoRow('Postal Address', staff.postalAddress),
                      _buildInfoRow('Permanent Address', staff.permanentAddress),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: 'Employment Details',
                    icon: LucideIcons.briefcase,
                    items: [
                      _buildInfoRow('Branch', staff.branch),
                      _buildInfoRow('Joined Date', staff.joinDate),
                      _buildInfoRow('Salary', 'Rs. ${staff.salaryAmount}'),
                      _buildInfoRow('Allowance', 'Rs. ${staff.salaryAllowance}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: 'Banking & EPF',
                    icon: LucideIcons.building,
                    items: [
                      _buildInfoRow('Bank Name', staff.bankName),
                      _buildInfoRow('Bank Branch', staff.bankBranch),
                      _buildInfoRow('Account No', staff.accountNo),
                      _buildInfoRow('EPF No', staff.epfNo),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => PdfHelper.downloadStaffPdf(staff),
                      icon: const Icon(LucideIcons.fileText),
                      label: const Text('Share Staff PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3545),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: staff.roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Center(
              child: staff.profileImage != null
                  ? Image.network(staff.profileImage!)
                  : Icon(LucideIcons.user, color: staff.roleColor, size: 50),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            staff.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: staff.roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              staff.roleDisplay,
              style: TextStyle(
                color: staff.roleColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            staff.id,
            style: const TextStyle(
              color: Color(0xFF2C3545),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2C3545)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(':', style: TextStyle(color: Color(0xFFD1D5DB))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

