import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/staff.dart';
import '../models/auth_service.dart';
import 'add_staff_screen.dart';
import 'staff_details_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StaffService staffService = StaffService();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Staff Management',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(LucideIcons.search, size: 20, color: Color(0xFF6B7280)),
                  hintText: 'Search by Name or Role...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => staffService.fetchStaffs(),
              child: ValueListenableBuilder<List<Staff>>(
                valueListenable: staffService.staffsNotifier,
                builder: (context, staffs, child) {
                  final String role = AuthService().userPost.toLowerCase();
                  final String uName = AuthService().userName.toLowerCase();
                  final bool isAdmin = role.contains('admin');
                  final bool isManager = role.contains('manager') || uName.contains('manager');
                  final String currentBranch = AuthService().branch.trim().toLowerCase();

                  final filteredStaffs = staffs.where((staff) {
                    final matchesSearch = staff.name.toLowerCase().contains(_searchQuery) ||
                                          staff.roleDisplay.toLowerCase().contains(_searchQuery);
                    
                    // Robust branch check
                    final String staffBranch = staff.branch.trim().toLowerCase();
                    final bool isBranchMatch = currentBranch == 'all branches' || 
                                             staffBranch == currentBranch || 
                                             staffBranch.isEmpty;

                    if (isAdmin) {
                      return matchesSearch;
                    } else if (isManager) {
                      // Managers only see subordinate staff within their own branch
                      final bool isSubordinate = staff.role != StaffRole.admin && 
                                               staff.role != StaffRole.manager;
                      return matchesSearch && isBranchMatch && isSubordinate;
                    }
                    
                    return false; // Regular staff cannot see the management list
                  }).toList();

                  if (filteredStaffs.isEmpty) {
                    return ListView( // Wrap in ListView to enable RefreshIndicator on empty state
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.users, size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty 
                                  ? 'No subordinate staff found in your branch.' 
                                  : 'No matching staff members found.',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: filteredStaffs.length,
                    itemBuilder: (context, index) {
                      final staff = filteredStaffs[index];
                      return _buildStaffCard(context, staff);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AuthService().userPost.toLowerCase().contains('admin')
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddStaffScreen()),
                );
              },
              backgroundColor: const Color(0xFFE8BC44),
              child: const Icon(LucideIcons.plus, color: Color(0xFF2C3545)),
            )
          : null,
    );
  }

  Widget _buildStaffCard(BuildContext context, Staff staff) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffDetailsScreen(staff: staff),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: staff.roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: staff.profileImage != null
                    ? Image.network(staff.profileImage!)
                    : Icon(LucideIcons.user, color: staff.roleColor, size: 30),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      _buildRoleBadge(staff),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    staff.id,
                    style: const TextStyle(
                      color: Color(0xFF2C3545),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.phone, size: 14, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Text(
                        staff.phone,
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.mail, size: 14, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Text(
                        staff.email,
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(Staff staff) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: staff.roleColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        staff.roleDisplay,
        style: TextStyle(
          color: staff.roleColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

