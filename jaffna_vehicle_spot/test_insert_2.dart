// ignore_for_file: avoid_print
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://uhczvfobofjosodsaicq.supabase.co',
    'sb_publishable_GlH52YJEuONAGrkxiYWJjQ_mL8SbJET'
  );

  try {
    // We can't query RLS policies using the anon key.
    // Let's just try to insert a row using a fake UUID for sales_person_id
    final response = await supabase.from('invoices').insert({
      'id': 'INV-TEST-123',
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
      'sales_person_id': '11111111-1111-1111-1111-111111111111',
      'branch': ''
    });
    
    print('Inserted: $response');
  } catch (e) {
    print('Error: $e');
  }
}
