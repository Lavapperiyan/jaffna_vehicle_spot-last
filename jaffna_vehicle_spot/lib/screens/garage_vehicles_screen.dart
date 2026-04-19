import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/vehicle.dart';
import 'vehicle_details_screen.dart';

class GarageVehiclesScreen extends StatelessWidget {
  const GarageVehiclesScreen({super.key});

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
        title: const Text('Vehicles in Garage', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: ValueListenableBuilder<List<Vehicle>>(
        valueListenable: VehicleService().vehiclesNotifier,
        builder: (context, vehicles, child) {
          final inGarage = vehicles.where((v) => v.status == 'In Garage').toList();
          
          if (inGarage.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.warehouse, size: 64, color: Colors.white.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  const Text('No vehicles in garage', style: TextStyle(color: Colors.white38, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: inGarage.length,
            itemBuilder: (context, index) {
              final vehicle = inGarage[index];
              return _buildGarageCard(context, vehicle);
            },
          );
        },
      ),
    );
  }

  Widget _buildGarageCard(BuildContext context, Vehicle vehicle) {
    final details = vehicle.garageDetails;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VehicleDetailsScreen(vehicle: vehicle)),
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: vehicle.imageUrl.startsWith('http')
                        ? Image.network(vehicle.imageUrl, width: 60, height: 40, fit: BoxFit.cover)
                        : Image.asset(vehicle.imageUrl, width: 60, height: 40, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vehicle.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(vehicle.registrationNo, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8BC44).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            details?.garageName ?? 'Direct Work',
                            style: const TextStyle(color: Color(0xFFE8BC44), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _infoRow(LucideIcons.calendar, 'Sent Date', details?.date ?? 'N/A'),
                  const SizedBox(height: 12),
                  _infoRow(LucideIcons.wrench, 'Reason', details?.reason ?? 'Maintenance'),
                  const SizedBox(height: 12),
                  _infoRow(LucideIcons.banknote, 'Total Cost', details != null ? 'Rs. ${details.totalAmount}' : 'Pending'),
                  const SizedBox(height: 12),
                  _infoRow(LucideIcons.userCheck, 'Driver', details?.driverName ?? 'Assigned'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
