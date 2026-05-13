// ignore_for_file: avoid_print
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://uhczvfobofjosodsaicq.supabase.co',
    'sb_publishable_GlH52YJEuONAGrkxiYWJjQ_mL8SbJET'
  );

  try {
    final response = await supabase.from('invoices').select().limit(1);
    print('Invoice Data: $response');
  } catch (e) {
    print('Error: $e');
  }
}
