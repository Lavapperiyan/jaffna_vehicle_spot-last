import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/api_config.dart';

class Customer {
  final String id;
  final String name;
  final String nic;
  final String phone;
  final String address;
  final String email;
  final List<String> purchasedVehicles; // Vehicle IDs or Names
  final String joinDate;
  final String branch;

  Customer({
    required this.id,
    required this.name,
    required this.nic,
    required this.phone,
    required this.address,
    required this.email,
    required this.purchasedVehicles,
    required this.joinDate,
    this.branch = 'Jaffna',
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      nic: json['nic'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      purchasedVehicles: List<String>.from(json['purchased_vehicles'] ?? []),
      joinDate: json['created_at'] ?? '',
      branch: json['branch'] ?? 'Jaffna',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'nic': nic,
      'phone': phone,
      'address': address,
      'email': email,
      'branch': branch,
      'purchased_vehicles': purchasedVehicles,
    };
    if (id.isNotEmpty) {
      data['id'] = id;
    }
    return data;
  }
}

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal() {
    fetchCustomers();
  }

  final _supabase = Supabase.instance.client;
  final ValueNotifier<List<Customer>> customersNotifier = ValueNotifier<List<Customer>>([]);

  Future<void> fetchCustomers() async {
    try {
      final response = await _supabase
          .from(ApiConfig.tableCustomers)
          .select();

      if (response.isNotEmpty) {
        final List<dynamic> data = response as List;
        customersNotifier.value = data.map((c) => Customer.fromJson(c)).toList();
      }
    } catch (e) {
      debugPrint('Fetch customers error: $e');
    }
  }

  /// Returns null on success, or error message on failure
  Future<String?> addOrUpdateCustomer(Customer customer) async {
    try {
      await _supabase
          .from(ApiConfig.tableCustomers)
          .upsert(customer.toJson());

      await fetchCustomers();
      return null;
    } catch (e) {
      debugPrint('Add/Update customer error: $e');
      if (e.toString().contains('unique constraint') || e.toString().contains('already exists')) {
        return 'Customer with this NIC already exists.';
      }
      return e.toString();
    }
  }

  Future<bool> removeCustomer(String id) async {
    try {
      await _supabase
          .from(ApiConfig.tableCustomers)
          .delete()
          .eq('id', id);

      await fetchCustomers();
      return true;
    } catch (e) {
      debugPrint('Remove customer error: $e');
      return false;
    }
  }
}

