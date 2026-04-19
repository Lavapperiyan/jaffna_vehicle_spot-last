import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/api_config.dart';

class Vehicle {
  final String id;
  final String name;
  final String make;
  final String model;
  final String category;
  final String price;
  final String status;
  final String imageUrl;
  final String consumption;
  final String power;
  final String speed;
  final String speedUp;
  final String fuelType;
  final List<String> configurations;
  final String branch;
  final String buyPrice;

  // Identification Fields
  final String chassisNo;
  final String engineNo;
  final String registrationNo;
  final String color;
  final String yearOfManufacture;
  final String stockUpdateDate;
  final GarageDetails? garageDetails;

  Vehicle({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.status,
    required this.imageUrl,
    this.buyPrice = '',
    this.make = 'Unknown',
    this.model = 'Unknown',
    this.consumption = '4.2 liters',
    this.power = '184 hp',
    this.speed = '180 km',
    this.speedUp = '11.1 sec',
    this.fuelType = 'Petrol',
    this.branch = 'Jaffna',
    this.configurations = const [
      'Active mirror side folding + shady fin',
      'Happier leather steering wheel...',
      'Finishing the seats with black...'
    ],
    this.chassisNo = 'Not specified',
    this.engineNo = 'Not specified',
    this.registrationNo = 'Unregistered',
    this.color = 'Not specified',
    this.yearOfManufacture = 'Not specified',
    this.stockUpdateDate = 'Recently',
    this.garageDetails,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      make: json['brand'] ?? json['make'] ?? 'Unknown',
      model: json['model'] ?? 'Unknown',
      category: json['type'] ?? json['category'] ?? '',
      price: (json['selling_price'] ?? json['price'])?.toString() ?? '',
      status: json['status'] ?? 'Available',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? json['imagePath'] ?? 'assets/toyota_chr.png',
      buyPrice: (json['cost_price'] ?? json['buy_price'])?.toString() ?? '',
      yearOfManufacture: json['year']?.toString() ?? json['year_of_manufacture']?.toString() ?? json['yearOfManufacture']?.toString() ?? 'Not specified',
      branch: json['branch'] ?? 'Jaffna',
      chassisNo: json['chassis_no'] ?? json['chassisNo'] ?? 'Not specified',
      engineNo: json['engine_no'] ?? json['engineNo'] ?? 'Not specified',
      registrationNo: json['registration_no'] ?? json['registrationNo'] ?? 'Unregistered',
      color: json['color'] ?? 'Not specified',
      consumption: json['consumption'] ?? '4.2 liters',
      power: json['power'] ?? '184 hp',
      speed: json['speed'] ?? '180 km',
      speedUp: json['speed_up'] ?? json['speedUp'] ?? '11.1 sec',
      fuelType: json['fuel_type'] ?? json['fuelType'] ?? 'Petrol',
      stockUpdateDate: json['updated_at'] ?? json['updatedAt'] ?? '',
      garageDetails: (json['status'] == 'In Garage' && json['garage_records'] != null && (json['garage_records'] as List).isNotEmpty)
          ? GarageDetails.fromJson((json['garage_records'] as List).first)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'brand': make,
    'model': model,
    'type': category,
    'selling_price': price,
    'cost_price': buyPrice,
    'status': status,
    'image_url': imageUrl,
    'branch': branch,
    'chassis_no': chassisNo,
    'engine_no': engineNo,
    'registration_no': registrationNo,
    'color': color,
    'year': yearOfManufacture,
  };

  Vehicle copyWith({
    String? status,
    GarageDetails? garageDetails,
    String? price,
    String? buyPrice,
    String? imageUrl,
  }) {
    return Vehicle(
      id: id,
      name: name,
      make: make,
      model: model,
      category: category,
      price: price ?? this.price,
      buyPrice: buyPrice ?? this.buyPrice,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      consumption: consumption,
      power: power,
      speed: speed,
      speedUp: speedUp,
      fuelType: fuelType,
      configurations: configurations,
      branch: branch,
      chassisNo: chassisNo,
      engineNo: engineNo,
      registrationNo: registrationNo,
      color: color,
      yearOfManufacture: yearOfManufacture,
      stockUpdateDate: stockUpdateDate,
      garageDetails: garageDetails ?? this.garageDetails,
    );
  }
}

class GarageDetails {
  final String garageName;
  final String ownerName;
  final String contactNumber;
  final String address;
  final String reason;
  final String date;
  final String driverName;
  final String driverDetails;
  final double totalAmount;
  final double advanceAmount;

  GarageDetails({
    required this.garageName,
    required this.ownerName,
    required this.contactNumber,
    required this.address,
    required this.reason,
    required this.date,
    required this.driverName,
    required this.driverDetails,
    required this.totalAmount,
    required this.advanceAmount,
  });

  factory GarageDetails.fromJson(Map<String, dynamic> json) {
    return GarageDetails(
      garageName: json['garage_name'] ?? '',
      ownerName: json['owner_name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      address: json['address'] ?? '',
      reason: json['problem_description'] ?? json['reason'] ?? '',
      date: json['date'] ?? '',
      driverName: json['driver_name'] ?? '',
      driverDetails: json['driver_details'] ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      advanceAmount: double.tryParse(json['advance_amount']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'garage_name': garageName,
    'owner_name': ownerName,
    'contact_number': contactNumber,
    'address': address,
    'problem_description': reason,
    'date': date,
    'driver_name': driverName,
    'total_amount': totalAmount,
    'advance_amount': advanceAmount,
  };
}

class VehicleService {
  static final VehicleService _instance = VehicleService._internal();
  factory VehicleService() => _instance;
  VehicleService._internal() {
    fetchVehicles();
  }

  final _supabase = Supabase.instance.client;
  final ValueNotifier<List<Vehicle>> vehiclesNotifier = ValueNotifier<List<Vehicle>>([]);

  Future<void> fetchVehicles() async {
    try {
      // Fetch vehicles and garage records separately to avoid schema relation errors
      final vResponse = await _supabase.from(ApiConfig.tableVehicles).select();
      final gResponse = await _supabase.from('garage_records').select();

      if (vResponse.isNotEmpty) {
        final List<dynamic> vData = vResponse as List;
        final List<dynamic> gData = gResponse as List;
        
        vehiclesNotifier.value = vData.map((v) {
          // Manually join garage record if it exists
          final String vId = (v['id'] ?? v['_id'] ?? '').toString();
          
          final matches = gData.where((g) => 
            (g['vehicle_id']?.toString() == vId) && (g['status'] == 'In Garage')
          ).toList();
          
          final garageRecord = matches.isNotEmpty ? matches.first : null;
          
          if (garageRecord != null) {
            v['garage_records'] = [garageRecord]; // Inject for fromJson
          }
          
          return Vehicle.fromJson(v);
        }).toList();
      }
    } catch (e) {
      debugPrint('Fetch vehicles error: $e');
    }
  }

  Future<String?> uploadImage(Uint8List bytes, String fileName) async {
    try {
      final path = 'vehicle-images/$fileName';

      await _supabase.storage.from('vehicle-images').uploadBinary(path, bytes);
      final String imageUrl = _supabase.storage.from('vehicle-images').getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      debugPrint('Upload image error: $e');
      rethrow;
    }
  }

  Future<bool> addVehicle(Vehicle vehicle) async {
    try {
      await _supabase
          .from(ApiConfig.tableVehicles)
          .insert(vehicle.toJson());

      await fetchVehicles();
      return true;
    } catch (e) {
      debugPrint('Add vehicle error: $e');
      rethrow; // Throw error to be caught by UI
    }
  }

  Future<bool> updateVehiclePrice(String id, String newPrice) async {
    try {
      await _supabase
          .from(ApiConfig.tableVehicles)
          .update({'selling_price': newPrice})
          .eq('id', id);

      await fetchVehicles();
      return true;
    } catch (e) {
      debugPrint('Update price error: $e');
      return false;
    }
  }

  Future<bool> updateVehicleStatus(String id, String status) async {
    try {
      await _supabase
          .from(ApiConfig.tableVehicles)
          .update({'status': status})
          .eq('id', id);

      await fetchVehicles();
      return true;
    } catch (e) {
      debugPrint('Update status error: $e');
      return false;
    }
  }

  Future<bool> moveToGarage(String vehicleId, GarageDetails details) async {
    try {
      // 1. Add to garage records
      await _supabase
          .from('garage_records')
          .insert({
            'vehicle_id': vehicleId,
            ...details.toJson(),
          });

      // 2. Update vehicle status
      await _supabase
          .from(ApiConfig.tableVehicles)
          .update({'status': 'In Garage'})
          .eq('id', vehicleId);

      await fetchVehicles();
      return true;
    } catch (e) {
      debugPrint('Move to garage error: $e');
      return false;
    }
  }

  Future<bool> returnFromGarage(String vehicleId) async {
    try {
      // 1. Update vehicle status to Available
      await _supabase
          .from(ApiConfig.tableVehicles)
          .update({'status': 'Available'})
          .eq('id', vehicleId);

      // 2. Update the active garage record status to Returned
      await _supabase
          .from('garage_records')
          .update({'status': 'Returned'})
          .eq('vehicle_id', vehicleId)
          .eq('status', 'In Garage');

      await fetchVehicles();
      return true;
    } catch (e) {
      debugPrint('Return from garage error: $e');
      return false;
    }
  }

  Future<bool> removeVehicle(String id) async {
    try {
      await _supabase
          .from(ApiConfig.tableVehicles)
          .delete()
          .eq('id', id);

      await fetchVehicles();
      return true;
    } catch (e) {
      debugPrint('Remove vehicle error: $e');
      return false;
    }
  }
}
