import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/api_config.dart';
import 'branch.dart';

class BranchService {
  // Singleton pattern
  static final BranchService _instance = BranchService._internal();
  factory BranchService() => _instance;
  BranchService._internal() {
    fetchBranches();
  }

  final _supabase = Supabase.instance.client;
  final ValueNotifier<List<Branch>> branchesNotifier = ValueNotifier<List<Branch>>([]);

  List<Branch> get allBranches => branchesNotifier.value;

  Future<void> fetchBranches() async {
    try {
      final response = await _supabase
          .from(ApiConfig.tableBranches)
          .select()
          .order('name');

      if (response.isNotEmpty) {
        final List<dynamic> data = response;
        branchesNotifier.value = data.map((b) => Branch.fromJson(b)).toList();
      }
    } catch (e) {
      debugPrint('Fetch branches error: $e');
    }
  }

  Future<bool> addBranch(Branch branch) async {
    try {
      await _supabase
          .from(ApiConfig.tableBranches)
          .insert(branch.toJson());

      await fetchBranches();
      return true;
    } catch (e) {
      debugPrint('Add branch error: $e');
      return false;
    }
  }

  Future<bool> updateBranch(Branch branch) async {
    try {
      await _supabase
          .from(ApiConfig.tableBranches)
          .update(branch.toJson())
          .eq('id', branch.id);

      await fetchBranches();
      return true;
    } catch (e) {
      debugPrint('Update branch error: $e');
      return false;
    }
  }

  Future<bool> deleteBranch(String branchId) async {
    try {
      await _supabase
          .from(ApiConfig.tableBranches)
          .delete()
          .eq('id', branchId);
      
      await fetchBranches();
      return true;
    } catch (e) {
      debugPrint('Delete branch error: $e');
      return false;
    }
  }

  bool isCodeUnique(String code, {String? excludeBranchId}) {
    return !branchesNotifier.value.any((b) => b.code.toLowerCase() == code.toLowerCase() && b.id != excludeBranchId);
  }
}
