import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'home_screen.dart';
import 'staff_home_screen.dart';
import 'manager_home_screen.dart';
import '../models/auth_service.dart';
import 'inventory_screen.dart';
import 'billing_screen.dart';
import 'sales_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _LayoutState();
}

class _LayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  late List<Widget> _cachedScreens;

  bool get _isStaff => AuthService().userPost.toLowerCase().contains('staff');
  bool get _isManager => AuthService().userPost.toLowerCase().contains('manager') 
      || AuthService().userPost.toLowerCase().contains('admin')
      || AuthService().userName.toLowerCase().contains('manager');

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    _cachedScreens = [
      _isManager
          ? ManagerHomeScreen(onTabChange: _handleTabChange)
          : _isStaff
              ? StaffHomeScreen(onTabChange: _handleTabChange)
              : HomeScreen(onTabChange: _handleTabChange),
      const InventoryScreen(),
      const BillingScreen(),
    ];
    _cachedScreens.addAll([
      const SalesScreen(),
    ]);
  }

  void _handleTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> get _navItems {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(LucideIcons.car), label: 'Inventory'),
      const BottomNavigationBarItem(icon: Icon(LucideIcons.fileText), label: 'Billing'),
    ];
    items.addAll([
      const BottomNavigationBarItem(icon: Icon(LucideIcons.trendingUp), label: 'Sales'),
    ]);
    return items;
  }

  @override
  Widget build(BuildContext context) {
    // Ensure selectedIndex doesn't go completely out of bounds if role changes
    final validIndex = _selectedIndex < _cachedScreens.length ? _selectedIndex : 0;

    return Scaffold(
      body: IndexedStack(
        index: validIndex,
        children: _cachedScreens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: validIndex,
          onTap: _handleTabChange,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2C3545), // Primary Blue
          unselectedItemColor: const Color(0xFF6B7280), // Gray 500
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          elevation: 0,
          items: _navItems,
        ),
      ),
    );
  }
}

