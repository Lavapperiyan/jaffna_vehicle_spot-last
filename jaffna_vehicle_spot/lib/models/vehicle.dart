import 'package:flutter/material.dart';

class Vehicle {
  final String id;
  final String name;
  final String make;
  final String model;
  final String category;
  final String price;
  final String status;
  final String imagePath;
  final String consumption;
  final String power;
  final String speed;
  final String speedUp;
  final String fuelType;
  final List<String> configurations;
  final String branch;

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
    required this.imagePath,
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

  Vehicle copyWith({
    String? status,
    GarageDetails? garageDetails,
    String? price,
  }) {
    return Vehicle(
      id: id,
      name: name,
      make: make,
      model: model,
      category: category,
      price: price ?? this.price,
      status: status ?? this.status,
      imagePath: imagePath,
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
}

final List<Vehicle> initialMockVehicles = [
  Vehicle(
    id: '1',
    name: 'TOYOTA C-HR',
    make: 'Toyota',
    model: 'C-HR',
    category: 'Car',
    price: '778,970',
    status: 'Available',
    imagePath: 'assets/toyota_chr.png',
  ),
  Vehicle(
    id: '2',
    name: 'BMW M5 Competition',
    make: 'BMW',
    model: 'M5',
    category: 'Car',
    price: '24.5M',
    status: 'Available',
    imagePath: 'assets/toyota_chr.png', // Placeholder
  ),
  Vehicle(
    id: '3',
    name: 'MITSUBISHI CANTER',
    make: 'Mitsubishi',
    model: 'Canter',
    category: 'Load Vehicle',
    price: '12.5M',
    status: 'Available',
    imagePath: 'assets/toyota_chr.png', // Placeholder
  ),
  Vehicle(
    id: '4',
    name: 'NISSAN CARAVAN',
    make: 'Nissan',
    model: 'Caravan',
    category: 'Van',
    price: '18.5M',
    status: 'Sold',
    imagePath: 'assets/toyota_chr.png', // Placeholder
  ),
  Vehicle(
    id: '5',
    name: 'BYD ATTO 3',
    make: 'BYD',
    model: 'Atto 3',
    category: 'Electric',
    price: '32.0M',
    status: 'Available',
    imagePath: 'assets/toyota_chr.png', // Placeholder
  ),
];

class VehicleService {
  static final VehicleService _instance = VehicleService._internal();
  factory VehicleService() => _instance;
  VehicleService._internal();

  final ValueNotifier<List<Vehicle>> vehiclesNotifier = ValueNotifier<List<Vehicle>>(initialMockVehicles);

  void addVehicle(Vehicle vehicle) {
    vehiclesNotifier.value = [...vehiclesNotifier.value, vehicle];
  }

  void removeVehicle(String id) {
    vehiclesNotifier.value = vehiclesNotifier.value.where((v) => v.id != id).toList();
  }

  void updateVehiclePrice(String id, String newPrice) {
    vehiclesNotifier.value = vehiclesNotifier.value.map((v) {
      if (v.id == id) {
        return Vehicle(
          id: v.id,
          name: v.name,
          make: v.make,
          model: v.model,
          category: v.category,
          price: newPrice,
          status: v.status,
          imagePath: v.imagePath,
          consumption: v.consumption,
          power: v.power,
          speed: v.speed,
          speedUp: v.speedUp,
          fuelType: v.fuelType,
          configurations: v.configurations,
          branch: v.branch,
          chassisNo: v.chassisNo,
          engineNo: v.engineNo,
          registrationNo: v.registrationNo,
          color: v.color,
          yearOfManufacture: v.yearOfManufacture,
          stockUpdateDate: v.stockUpdateDate,
        );
      }
      return v;
    }).toList();
  }

  void moveToGarage(String vehicleId, GarageDetails details) {
    vehiclesNotifier.value = vehiclesNotifier.value.map((v) {
      if (v.id == vehicleId) {
        return v.copyWith(
          status: 'In Garage',
          garageDetails: details,
        );
      }
      return v;
    }).toList();
  }

  void returnFromGarage(String vehicleId) {
    vehiclesNotifier.value = vehiclesNotifier.value.map((v) {
      if (v.id == vehicleId) {
        return v.copyWith(
          status: 'Available',
          garageDetails: null, // Clear details or keep them? Usually clear for current state.
        );
      }
      return v;
    }).toList();
  }
}

