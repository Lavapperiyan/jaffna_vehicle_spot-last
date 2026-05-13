// ignore_for_file: avoid_print
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://uhczvfobofjosodsaicq.supabase.co',
    'sb_publishable_GlH52YJEuONAGrkxiYWJjQ_mL8SbJET'
  );

  try {
    final response = await supabase.from('invoices').insert({
      'customer_name': 'test',
      'customer_address': 'test',
      'customer_contact': '123',
      'customer_nic': '123',
      'vehicle_name': 'test',
      'chassis_no': 'test',
      'engine_no': 'test',
      'registration_no': 'test',
      'vehicle_type': 'test',
      'fuel_type': 'test',
      'color': 'test',
      'year': '2025',
      'amount': '0',
      'lease_amount': '0',
      'date': '2025-01-01',
      'status': 'Paid',
      'sales_person_id': '',
      'branch': ''
    }).select().single();
    
    print('Inserted: $response');
  } catch (e) {
    print('Error: $e');
  }
}
