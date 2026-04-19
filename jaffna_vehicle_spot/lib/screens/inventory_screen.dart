import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/vehicle.dart';
import '../models/auth_service.dart';
import 'vehicle_details_screen.dart';
import 'add_vehicle_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<String> _categories = ['All', 'Car', 'Van', 'Load Vehicle', 'Electric'];
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VehicleService vehicleService = VehicleService();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: ValueListenableBuilder<List<Vehicle>>(
        valueListenable: vehicleService.vehiclesNotifier,
        builder: (context, vehicles, child) {
          final filteredVehicles = vehicles.where((v) {
            final matchesCategory = _selectedCategoryIndex == 0 || v.category == _categories[_selectedCategoryIndex];
            final matchesSearch = v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                 v.make.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                 v.model.toLowerCase().contains(_searchQuery.toLowerCase());
            
            // 24-hour auto-hide for Sold vehicles
            if (v.status == 'Sold' && v.stockUpdateDate.isNotEmpty) {
              try {
                final soldAt = DateTime.parse(v.stockUpdateDate);
                final now = DateTime.now();
                if (now.difference(soldAt).inHours >= 24) {
                  return false;
                }
              } catch (e) {
                debugPrint('Date parsing error for vehicle ${v.id}: $e');
              }
            }

            return matchesCategory && matchesSearch;
          }).toList();

          return CustomScrollView(
            slivers: [
              // Header & Search
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vehicle Inventory',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Jaffna Vehicle Spot • ${AuthService().branch}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/logo.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                    LucideIcons.image,
                                    color: Color(0xFF2C3545),
                                    size: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
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
                                    _searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: const Icon(LucideIcons.search, size: 20, color: Color(0xFF6B7280)),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = _searchController.text;
                                      });
                                    },
                                  ),
                                  hintText: 'Search vehicles...',
                                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Chips
              SliverToBoxAdapter(
                child: Container(
                  height: 70,
                  color: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategoryIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_categories[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          selectedColor: const Color(0xFF2C3545),
                          backgroundColor: const Color(0xFFF3F4F6),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF6B7280),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          elevation: 0,
                          pressElevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide.none,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Inventory List
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vehicle = filteredVehicles[index];
                      return _buildVehicleCard(vehicle);
                    },
                    childCount: filteredVehicles.length,
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
          );
        },
        backgroundColor: const Color(0xFFE8BC44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(LucideIcons.plus, color: Color(0xFF2C3545)),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Hero(
                    tag: 'vehicle-${vehicle.id}',
                    child: vehicle.imageUrl.startsWith('http')
                        ? Image.network(vehicle.imageUrl, fit: BoxFit.cover)
                        : Image.asset(vehicle.imageUrl, fit: BoxFit.cover),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: vehicle.status == 'In Garage' 
                                  ? const Color(0xFFE8BC44).withValues(alpha: 0.1)
                                  : vehicle.status == 'Sold'
                                      ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                                      : const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              vehicle.status,
                              style: TextStyle(
                                color: vehicle.status == 'In Garage' 
                                    ? const Color(0xFFE8BC44)
                                    : vehicle.status == 'Sold'
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            vehicle.category,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Vehicle'),
                                  content: Text('Are you sure you want to delete ${vehicle.name}? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final success = await VehicleService().removeVehicle(vehicle.id);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(success ? 'Vehicle deleted successfully' : 'Failed to delete vehicle'),
                                              backgroundColor: success ? Colors.green : Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vehicle.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.price.contains('M') ? 'Rs. ${vehicle.price}' : 'Rs. ${vehicle.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2C3545),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF3F4F6), height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(vehicle.yearOfManufacture, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(LucideIcons.palette, size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(vehicle.color, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(color: Color(0xFF2C3545), fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF2C3545)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.clock, size: 12, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(
                  'Updated: ${vehicle.stockUpdateDate}',
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

