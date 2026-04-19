import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/api_config.dart';

enum CommissionType { fixed, percentage }

class Commission {
  final String id;
  final String invoiceId;
  final String agentName;
  final String agentContact;
  final String reference;
  final CommissionType type;
  final double amount;
  final String reason;
  final String date;

  Commission({
    required this.id,
    required this.invoiceId,
    required this.agentName,
    required this.agentContact,
    this.reference = '',
    required this.type,
    required this.amount,
    required this.reason,
    required this.date,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      invoiceId: json['sale_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      agentContact: json['contact'] ?? '',
      type: json['commission_type'] == 'Percentage' ? CommissionType.percentage : CommissionType.fixed,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sale_id': invoiceId,
      'agent_name': agentName,
      'contact': agentContact,
      'commission_type': type == CommissionType.percentage ? 'Percentage' : 'Fixed',
      'amount': amount,
      'reason': reason,
      'date': date,
    };
  }
}

class CommissionService {
  static final CommissionService _instance = CommissionService._internal();
  factory CommissionService() => _instance;
  CommissionService._internal() {
    fetchCommissions();
  }

  final _supabase = Supabase.instance.client;
  final ValueNotifier<List<Commission>> commissionsNotifier = ValueNotifier<List<Commission>>([]);

  Future<void> fetchCommissions() async {
    try {
      final response = await _supabase
          .from(ApiConfig.tableCommissions)
          .select();

      if (response.isNotEmpty) {
        final List<dynamic> data = response as List;
        commissionsNotifier.value = data.map((c) => Commission.fromJson(c)).toList();
      }
    } catch (e) {
      debugPrint('Fetch commissions error: $e');
    }
  }

  Future<bool> addCommission(Commission commission) async {
    try {
      await _supabase
          .from(ApiConfig.tableCommissions)
          .insert(commission.toJson());

      await fetchCommissions();
      return true;
    } catch (e) {
      debugPrint('Add commission error: $e');
      return false;
    }
  }

  List<Commission> getCommissionsByAgent(String agentName) {
    return commissionsNotifier.value.where((c) => c.agentName == agentName).toList();
  }

  List<Commission> getCommissionsByDateRange(DateTime start, DateTime end) {
    return commissionsNotifier.value.where((c) {
      DateTime? date = DateTime.tryParse(c.date);
      if (date == null) return false;
      return date.isAfter(start.subtract(const Duration(days: 1))) && 
             date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
}
