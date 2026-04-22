import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/vehicle.dart';
import 'invoice_generation_screen.dart';
import 'garage_form_screen.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  late String _currentPrice;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.vehicle.price;
  }

  void _showEditPriceDialog() {
    final controller = TextEditingController(text: _currentPrice);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text('Edit Price', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'New Price',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2C3545))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPrice = controller.text.trim();
                if (newPrice.isNotEmpty) {
                  final success = await VehicleService().updateVehiclePrice(widget.vehicle.id, newPrice);
                  if (success) {
                    setState(() {
                      _currentPrice = newPrice;
                    });
                    if (context.mounted) Navigator.pop(context);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update price.')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3545)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Dark Charcoal/Navy Background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.bookmark, color: Colors.white70),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vehicle.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      widget.vehicle.category,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Car Image Section (Multiple Images)
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative circular glow/ring beneath car
                    Container(
                      width: 300,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            blurRadius: 100,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    if (widget.vehicle.imageUrls.isEmpty)
                      InteractiveViewer(
                        child: widget.vehicle.imageUrl.startsWith('http')
                            ? Image.network(widget.vehicle.imageUrl, fit: BoxFit.contain, width: double.infinity)
                            : Image.asset(widget.vehicle.imageUrl, fit: BoxFit.contain, width: double.infinity),
                      )
                    else
                      PageView.builder(
                        itemCount: widget.vehicle.imageUrls.length,
                        itemBuilder: (context, index) {
                          final img = widget.vehicle.imageUrls[index];
                          return InteractiveViewer(
                            child: img.startsWith('http')
                                ? Image.network(img, fit: BoxFit.contain, width: double.infinity)
                                : Image.asset(img, fit: BoxFit.contain, width: double.infinity),
                          );
                        },
                      ),
                    
                    // Small indicator dots for multiple images
                    if (widget.vehicle.imageUrls.length > 1)
                      Positioned(
                        bottom: 10,
                        child: Row(
                          children: List.generate(
                            widget.vehicle.imageUrls.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Small red indicator dot from design
                    Positioned(
                      bottom: 20,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Configurations / Specs Grid
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildSpecRow(LucideIcons.droplets, 'Consumption', widget.vehicle.consumption),
                          const SizedBox(height: 20),
                          _buildSpecRow(LucideIcons.gauge, 'Speed', widget.vehicle.speed),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildSpecRow(LucideIcons.zap, 'Power', widget.vehicle.power),
                          const SizedBox(height: 20),
                          _buildSpecRow(LucideIcons.timer, 'Speed-up', widget.vehicle.speedUp),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Vehicle Identification Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Chassis No', widget.vehicle.chassisNo),
                      _buildInfoRow('Engine No', widget.vehicle.engineNo),
                      _buildInfoRow('Registration No', widget.vehicle.registrationNo),
                      _buildInfoRow('Colour', widget.vehicle.color),
                      _buildInfoRow('Year', widget.vehicle.yearOfManufacture),
                      _buildInfoRow('Amount', 'Rs. $_currentPrice', isBold: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // All Possible Configurations Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All possible configurations',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        _buildFilterBadge('On-sale', false),
                        _buildFilterBadge('Pre-order', true),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Configuration Detailed Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildConfigCard(
                            context,
                            'Active',
                            ['Mirror side folding + shady fin', 'Happier leather steering wheel'],
                            isSelected: true,
                          ),
                          _buildConfigCard(context, 'Minimal', ['Luggage compartment light'], isSelected: false),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildPriceStateSection(_currentPrice),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white54, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBadge(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConfigCard(BuildContext context, String title, List<String> checks, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2C2C3E) : const Color(0xFF252535),
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              if (isSelected)
                const Text('Best for you',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...checks.map((check) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.white38, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(check,
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
              )),
          if (isSelected) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.vehicle.status != 'Sold')
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoiceGenerationScreen(vehicle: widget.vehicle),
                          ),
                        );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C3545),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text('Billing',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                if (widget.vehicle.status != 'Sold') const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (widget.vehicle.status == 'In Garage') {
                        // Return from garage logic
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E2C),
                            title: const Text('Return to Showroom?', style: TextStyle(color: Colors.white)),
                            content: const Text('Are you sure you want to move this vehicle back to the showroom?', style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final success = await VehicleService().returnFromGarage(widget.vehicle.id);
                                  if (context.mounted) {
                                    if (success) {
                                      Navigator.pop(context);
                                      Navigator.pop(context); // Go back to inventory
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Vehicle returned to showroom!')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Failed to return vehicle.')),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF76FF03)),
                                child: const Text('Confirm', style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GarageFormScreen(vehicle: widget.vehicle),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.vehicle.status == 'In Garage' ? const Color(0xFFE8BC44) : const Color(0xFF76FF03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.vehicle.status == 'In Garage' ? 'Return' : 'Garage',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceStateSection(String price) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEB5757), // Muted Red from design
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active state of the price',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
              GestureDetector(
                onTap: _showEditPriceDialog,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.edit3, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(price,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
              const Padding(
                padding: EdgeInsets.only(top: 4, left: 2),
                child: Text('Rs.', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                barGroups: [
                  _makeBar(0, 5),
                  _makeBar(1, 8),
                  _makeBar(2, 4),
                  _makeBar(3, 7),
                  _makeBar(4, 3),
                  _makeBar(5, 6),
                ],
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                minY: 0,
                maxY: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isBold ? const Color(0xFF76FF03) : Colors.white,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.white.withValues(alpha: 0.3),
          width: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

