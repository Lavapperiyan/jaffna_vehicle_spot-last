import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/api_config.dart';

enum InvoiceStatus { paid, pending, overdue }

class Invoice {
  final String id;
  final String customerName;
  final String customerAddress;
  final String customerContact;
  final String customerNic;
  final String vehicleName;
  final String chassisNo;
  final String engineNo;
  final String registrationNo;
  final String vehicleType;
  final String fuelType;
  final String color;
  final String year;
  final String amount;
  final String leaseAmount;
  final String date;
  final InvoiceStatus status;
  final String salesPersonId;
  final String? commissionId;
  final String branch;

  Invoice({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    required this.customerContact,
    required this.customerNic,
    required this.vehicleName,
    required this.chassisNo,
    required this.engineNo,
    required this.registrationNo,
    required this.vehicleType,
    required this.fuelType,
    required this.color,
    required this.year,
    required this.amount,
    required this.leaseAmount,
    required this.date,
    required this.status,
    this.salesPersonId = '',
    this.commissionId,
    this.branch = '',
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      customerName: json['customer_name'] ?? '',
      customerAddress: json['customer_address'] ?? '',
      customerContact: json['customer_contact'] ?? '',
      customerNic: json['customer_nic'] ?? '',
      vehicleName: json['vehicle_name'] ?? '',
      chassisNo: json['chassis_no'] ?? '',
      engineNo: json['engine_no'] ?? '',
      registrationNo: json['registration_no'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      fuelType: json['fuel_type'] ?? '',
      color: json['color'] ?? '',
      year: json['year'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      leaseAmount: json['lease_amount']?.toString() ?? '0',
      date: json['date'] ?? '',
      status: json['status'] == 'Paid' ? InvoiceStatus.paid : (json['status'] == 'Pending' ? InvoiceStatus.pending : InvoiceStatus.overdue),
      salesPersonId: json['sales_person_id'] ?? '',
      commissionId: json['commission_id'],
      branch: json['branch'] ?? '',
    );
  }

  Map<String, dynamic> toJson({bool isNew = false}) => {
    if (!isNew && id.isNotEmpty) 'id': id,
    'customer_name': customerName,
    'customer_address': customerAddress,
    'customer_contact': customerContact,
    'customer_nic': customerNic,
    'vehicle_name': vehicleName,
    'chassis_no': chassisNo,
    'engine_no': engineNo,
    'registration_no': registrationNo,
    'vehicle_type': vehicleType,
    'fuel_type': fuelType,
    'color': color,
    'year': year,
    'amount': amount,
    'lease_amount': leaseAmount,
    'date': date,
    'status': status == InvoiceStatus.paid ? 'Paid' : (status == InvoiceStatus.pending ? 'Pending' : 'Overdue'),
    'sales_person_id': salesPersonId,
    'commission_id': commissionId,
    'branch': branch,
  };
}

class InvoiceService {
  static final InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;
  InvoiceService._internal() {
    fetchInvoices();
  }

  final _supabase = Supabase.instance.client;
  final ValueNotifier<List<Invoice>> invoicesNotifier = ValueNotifier<List<Invoice>>([]);

  Future<void> fetchInvoices() async {
    try {
      final response = await _supabase
          .from(ApiConfig.tableInvoices)
          .select();

      final List<dynamic> data = response as List;
      invoicesNotifier.value = data.map((i) => Invoice.fromJson(i)).toList();
    } catch (e) {
      debugPrint('Fetch invoices error: $e');
      rethrow;
    }
  }

  Future<bool> addInvoice(Invoice invoice) async {
    try {
      await _supabase
          .from(ApiConfig.tableInvoices)
          .insert(invoice.toJson(isNew: true));

      await fetchInvoices();
      return true;
    } catch (e) {
      debugPrint('Add invoice error: $e');
      return false;
    }
  }

  Future<bool> updateInvoiceSalesPerson(String invoiceId, String staffId) async {
    try {
      await _supabase
          .from('invoices')
          .update({'sales_person_id': staffId})
          .eq('id', invoiceId);
      
      await fetchInvoices();
      return true;
    } catch (e) {
      debugPrint('Update invoice salesperson error: $e');
      return false;
    }
  }
}

