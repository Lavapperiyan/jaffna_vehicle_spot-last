import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/staff.dart';
import '../models/auth_service.dart';
import 'staff_profile_edit_screen.dart';
import 'login_screen.dart';

class StaffSettingsScreen extends StatelessWidget {
  const StaffSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final staffService = StaffService();

    return ValueListenableBuilder<List<Staff>>(
      valueListenable: staffService.staffsNotifier,
      builder: (context, staffs, child) {
        Staff currentStaff;
        try {
          currentStaff = staffs.firstWhere((s) => s.id == authService.userId);
        } catch (_) {
          // If not found, use synthesized data from authService to avoid showing wrong user
          currentStaff = Staff.fromJson({
            'id': authService.userId,
            'name': authService.userName,
            'role': authService.userPost,
            'branch': authService.branch,
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            title: const Text('My Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111827),
            elevation: 0,
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Header Profile Card
                _buildHeaderCard(context, currentStaff),
                const SizedBox(height: 32),
                
                // Account Info Group
                _buildSettingsGroup(context, 'Organization Details', [
                  _buildDetailTile('Staff ID', currentStaff.id, LucideIcons.contact, const Color(0xFF2C3545)),
                  _buildDetailTile('Username', currentStaff.username, LucideIcons.user, const Color(0xFF3B82F6)),
                  _buildDetailTile('Branch', currentStaff.branch, LucideIcons.mapPin, const Color(0xFF10B981)),
                  _buildDetailTile('Joining Date', currentStaff.joinDate, LucideIcons.calendar, const Color(0xFFF59E0B)),
                ]),

                const SizedBox(height: 24),

                _buildSettingsGroup(context, 'Personal Account', [
                  _buildSettingsTile(
                    context,
                    'Edit Account Details',
                    LucideIcons.edit3,
                    const Color(0xFF8B5CF6),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StaffProfileEditScreen(staff: currentStaff)),
                    ),
                  ),
                  _buildDetailTile('Mobile', currentStaff.mobileNo, LucideIcons.phone, Colors.grey),
                  _buildDetailTile('Email', currentStaff.email, LucideIcons.mail, Colors.grey),
                ]),

                const SizedBox(height: 32),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(LucideIcons.logOut, size: 20),
                      label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        backgroundColor: const Color(0xFFFee2e2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context, Staff staff) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: staff.roleColor.withValues(alpha: 0.1),
              backgroundImage: staff.profileImage != null ? NetworkImage(staff.profileImage!) : null,
              child: staff.profileImage == null 
                  ? Icon(LucideIcons.user, size: 40, color: staff.roleColor)
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.fullName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: staff.roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      staff.roleDisplay.toUpperCase(),
                      style: TextStyle(color: staff.roleColor, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Text(title.toUpperCase(), 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailTile(String title, String value, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF111827))),
      trailing: const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}
