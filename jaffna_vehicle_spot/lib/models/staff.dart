import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/api_config.dart';
import 'auth_service.dart';

enum StaffRole {
  admin,
  manager,
  salesPerson,
  technician,
}

class Staff {
  final String id;
  final String staffCode;
  final String name;
  final String fullName;
  final StaffRole role;
  final String phone;
  final String mobileNo;
  final String homeNo;
  final String email;
  final String joinDate;
  final String? profileImage;
  final String branch;
  final String postalAddress;
  final String permanentAddress;
  final String gender;
  final String civilStatus;
  final String dob;
  final String nicNo;
  final String spouseName;
  final String spouseContact;
  final String spouseNic;
  final String spouseAddress;
  final String spouseRelationship;
  final String olResults;
  final String alResults;
  final String otherQualifications;
  final bool hasOffense;
  final String offenseNature;
  final String salaryAmount;
  final String salaryAllowance;
  final String bankName;
  final String bankBranch;
  final String accountNo;
  final String epfNo;
  final String username;
  final String password;

  Staff({
    required this.id,
    required this.staffCode,
    required this.name,
    required this.fullName,
    required this.role,
    required this.phone,
    required this.mobileNo,
    required this.homeNo,
    required this.email,
    required this.joinDate,
    required this.branch,
    required this.postalAddress,
    required this.permanentAddress,
    required this.gender,
    required this.civilStatus,
    required this.dob,
    required this.nicNo,
    required this.spouseName,
    required this.spouseContact,
    required this.spouseNic,
    required this.spouseAddress,
    required this.spouseRelationship,
    required this.olResults,
    required this.alResults,
    required this.otherQualifications,
    required this.hasOffense,
    required this.offenseNature,
    required this.salaryAmount,
    required this.salaryAllowance,
    required this.bankName,
    required this.bankBranch,
    required this.accountNo,
    required this.epfNo,
    required this.username,
    required this.password,
    this.profileImage,
  });

  String get roleDisplay {
    switch (role) {
      case StaffRole.admin: return 'Admin';
      case StaffRole.manager: return 'Manager';
      case StaffRole.salesPerson: return 'Sales';
      case StaffRole.technician: return 'Technician';
    }
  }

  Color get roleColor {
    switch (role) {
      case StaffRole.admin: return const Color(0xFFEF4444);
      case StaffRole.manager: return const Color(0xFF8B5CF6);
      case StaffRole.salesPerson: return const Color(0xFF3B82F6);
      case StaffRole.technician: return const Color(0xFF10B981);
    }
  }

  Staff copyWith({
    String? name,
    String? fullName,
    StaffRole? role,
    String? phone,
    String? mobileNo,
    String? homeNo,
    String? email,
    String? postalAddress,
    String? permanentAddress,
    String? profileImage,
    String? password,
  }) {
    return Staff(
      id: id,
      staffCode: staffCode,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      mobileNo: mobileNo ?? this.mobileNo,
      homeNo: homeNo ?? this.homeNo,
      email: email ?? this.email,
      joinDate: joinDate,
      branch: branch,
      postalAddress: postalAddress ?? this.postalAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      gender: gender,
      civilStatus: civilStatus,
      dob: dob,
      nicNo: nicNo,
      spouseName: spouseName,
      spouseContact: spouseContact,
      spouseNic: spouseNic,
      spouseAddress: spouseAddress,
      spouseRelationship: spouseRelationship,
      olResults: olResults,
      alResults: alResults,
      otherQualifications: otherQualifications,
      hasOffense: hasOffense,
      offenseNature: offenseNature,
      salaryAmount: salaryAmount,
      salaryAllowance: salaryAllowance,
      bankName: bankName,
      bankBranch: bankBranch,
      accountNo: accountNo,
      epfNo: epfNo,
      username: username,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'staff_code': staffCode,
    'username': username,
    'password': password,
    'name': name,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'role': roleDisplay,
    'mobile_no': mobileNo,
    'home_no': homeNo,
    'branch': branch,
    'postal_address': postalAddress,
    'permanent_address': permanentAddress,
    'gender': gender,
    'civil_status': civilStatus,
    'dob': dob,
    'nic_no': nicNo,
    'spouse_name': spouseName,
    'spouse_contact': spouseContact,
    'spouse_nic': spouseNic,
    'spouse_address': spouseAddress,
    'spouse_relationship': spouseRelationship,
    'ol_results': olResults,
    'al_results': alResults,
    'other_qualifications': otherQualifications,
    'has_offense': hasOffense,
    'offense_nature': offenseNature,
    'salary_amount': salaryAmount,
    'salary_allowance': salaryAllowance,
    'bank_name': bankName,
    'bank_branch': bankBranch,
    'account_no': accountNo,
    'epf_no': epfNo,
    'profile_image': profileImage,
  };

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      staffCode: (json['staff_code'] ?? '').toString(),
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? json['name'] ?? '',
      role: json['role'] == 'Admin' ? StaffRole.admin : (json['role'] == 'Manager' ? StaffRole.manager : StaffRole.salesPerson),
      phone: json['phone'] ?? '',
      mobileNo: json['mobile_no'] ?? json['mobileNo'] ?? '',
      homeNo: json['home_no'] ?? json['homeNo'] ?? '',
      email: json['email'] ?? '',
      joinDate: json['created_at'] ?? '',
      branch: json['branch'] ?? '',
      postalAddress: json['postal_address'] ?? json['postalAddress'] ?? '',
      permanentAddress: json['permanent_address'] ?? json['permanentAddress'] ?? '',
      gender: json['gender'] ?? '',
      civilStatus: json['civil_status'] ?? json['civilStatus'] ?? '',
      dob: json['dob'] ?? '',
      nicNo: json['nic_no'] ?? json['nicNo'] ?? '',
      spouseName: json['spouse_name'] ?? json['spouseName'] ?? '',
      spouseContact: json['spouse_contact'] ?? json['spouseContact'] ?? '',
      spouseNic: json['spouse_nic'] ?? json['spouseNic'] ?? '',
      spouseAddress: json['spouse_address'] ?? json['spouseAddress'] ?? '',
      spouseRelationship: json['spouse_relationship'] ?? json['spouseRelationship'] ?? '',
      olResults: json['ol_results'] ?? json['olResults'] ?? '',
      alResults: json['al_results'] ?? json['alResults'] ?? '',
      otherQualifications: json['other_qualifications'] ?? json['otherQualifications'] ?? '',
      hasOffense: json['has_offense'] ?? json['hasOffense'] ?? false,
      offenseNature: json['offense_nature'] ?? json['offenseNature'] ?? '',
      salaryAmount: (json['salary_amount'] ?? json['salaryAmount'] ?? '0').toString(),
      salaryAllowance: (json['salary_allowance'] ?? json['salaryAllowance'] ?? '0').toString(),
      bankName: json['bank_name'] ?? json['bankName'] ?? '',
      bankBranch: json['bank_branch'] ?? json['bankBranch'] ?? '',
      accountNo: json['account_no'] ?? json['accountNo'] ?? '',
      epfNo: json['epf_no'] ?? json['epfNo'] ?? '',
      username: json['username'] ?? json['email'] ?? '',
      password: (json['password'] ?? '').toString(),
    );
  }
}

class StaffService {
  static final StaffService _instance = StaffService._internal();
  factory StaffService() => _instance;
  StaffService._internal() {
    fetchStaffs();
  }

  final _supabase = Supabase.instance.client;
  final ValueNotifier<List<Staff>> staffsNotifier = ValueNotifier<List<Staff>>([]);

  Future<void> fetchStaffs() async {
    try {
      final response = await _supabase
          .from(ApiConfig.tableStaff)
          .select();

      if ((response as List).isNotEmpty) {
        final List<dynamic> data = response as List;
        staffsNotifier.value = data.map((s) => Staff.fromJson(s)).toList();
      }
    } catch (e) {
      debugPrint('Fetch staff error: $e');
    }
  }

  Future<void> updateStaff(Staff updatedStaff) async {
    try {
      await _supabase
          .from(ApiConfig.tableStaff)
          .update(updatedStaff.toJson())
          .eq('id', updatedStaff.id);
      
      await fetchStaffs();
    } catch (e) {
      debugPrint('Update staff error: $e');
    }
  }

  Future<String?> addStaff(Staff staff) async {
    try {
      // 0. Generate Unique Staff Code (e.g. BM-JA-001)
      final String generatedStaffCode = await _generateStaffCode(staff.role, staff.branch);
      
      // 1. Create Supabase Auth User & Add to Staff Table
      final String? authId = await AuthService().registerStaff(
        staff.name,
        staff.email,
        staff.password,
        staff.roleDisplay,
        staff.branch,
      );

      if (authId != null) {
        // 2. Add full profile to Staff Table, using the real authId from Supabase Auth
        final staffData = staff.toJson();
        staffData['id'] = authId; // MANDATORY: Lookup in login depends on this being the Auth UUID
        staffData['staff_code'] = generatedStaffCode; // Store our pretty ID
        
        await _supabase.from(ApiConfig.tableStaff).insert(staffData);
        
        await fetchStaffs();
        return authId;
      }
      return null;
    } catch (e) {
      debugPrint('Add staff error: $e');
      rethrow;
    }
  }

  Future<String> _generateStaffCode(StaffRole role, String branch) async {
    try {
      // 1. Prefix (BM or ST)
      String prefix = (role == StaffRole.manager) ? 'BM' : 'ST';
      
      // 2. Branch Code (First 2 letters of branch name, uppercase)
      String branchCode = (branch.length >= 2) ? branch.substring(0, 2).toUpperCase() : branch.toUpperCase();
      
      // 3. Sequential Number
      final String searchPattern = '$prefix-$branchCode-%';
      
      // Find the count of existing members in that branch with that role prefix
      final response = await _supabase
          .from(ApiConfig.tableStaff)
          .select('staff_code')
          .like('staff_code', searchPattern);
      
      int nextNumber = 1;
      if ((response as List).isNotEmpty) {
        nextNumber = (response as List).length + 1;
      }
      
      return '$prefix-$branchCode-${nextNumber.toString().padLeft(3, '0')}';
    } catch (e) {
      debugPrint('Error generating staff code: $e');
      return 'ST-XX-000'; // Fallback
    }
  }

  Future<bool> removeStaff(String id) async {
    try {
      await _supabase
          .from(ApiConfig.tableStaff)
          .delete()
          .eq('id', id);
      
      await fetchStaffs();
      return true;
    } catch (e) {
      debugPrint('Remove staff error: $e');
      return false;
    }
  }
}
