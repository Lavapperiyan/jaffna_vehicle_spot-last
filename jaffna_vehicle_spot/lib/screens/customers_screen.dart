import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/auth_service.dart';
import 'add_customer_screen.dart';
import 'customer_details_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CustomerService customerService = CustomerService();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Customer Management',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF2C3545)),
            onPressed: () => customerService.fetchCustomers(),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => customerService.fetchCustomers(),
        color: const Color(0xFFE8BC44),
        child: Column(
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
                    hintText: 'Search by Name or NIC...',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Customer>>(
                valueListenable: customerService.customersNotifier,
                builder: (context, tableCustomers, child) {
                  return ValueListenableBuilder<List<Invoice>>(
                    valueListenable: InvoiceService().invoicesNotifier,
                    builder: (context, invoices, _) {
                      // 1. Create a map to ensure uniqueness by NIC (preferring table data over invoice data)
                      final Map<String, Customer> combinedMap = {};

                      // Add customers from invoices first (as secondary source)
                      for (var inv in invoices) {
                        final key = inv.customerNic.isNotEmpty ? inv.customerNic : inv.customerName.toLowerCase();
                        if (key.isNotEmpty) {
                          combinedMap[key] = Customer(
                            id: 'INV-${inv.id.substring(0, 4)}',
                            name: inv.customerName,
                            nic: inv.customerNic,
                            phone: inv.customerContact,
                            address: inv.customerAddress,
                            email: '',
                            purchasedVehicles: [inv.vehicleName],
                            joinDate: inv.date,
                            branch: AuthService().branch,
                          );
                        }
                      }

                      // Overwrite with formal customer table data (primary source)
                      for (var cust in tableCustomers) {
                        final key = cust.nic.isNotEmpty ? cust.nic : cust.name.toLowerCase();
                        combinedMap[key] = cust;
                      }

                      final allCustomers = combinedMap.values.toList();

                      // 2. Apply filtering
                      final filteredCustomers = allCustomers.where((customer) {
                        return customer.name.toLowerCase().contains(_searchQuery) ||
                               customer.nic.toLowerCase().contains(_searchQuery);
                      }).toList();
  
                      if (filteredCustomers.isEmpty) {
                        return ListView( 
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.userPlus, size: 48, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isEmpty 
                                      ? 'No customers found.' 
                                      : 'No matching customers found.',
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
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return _buildCustomerCard(context, customer);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
          );
        },
        backgroundColor: const Color(0xFFE8BC44),
        child: const Icon(LucideIcons.plus, color: Color(0xFF2C3545)),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailsScreen(customer: customer),
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
                color: const Color(0xFF2C3545).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(LucideIcons.user, color: Color(0xFF2C3545), size: 30),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.id,
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
                        customer.phone,
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.creditCard, size: 14, color: Color(0xFF6B7280)),
                      const SizedBox(width: 6),
                      Text(
                        'NIC: ${customer.nic}',
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }
}

