import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_service.dart';
import '../utils/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _supabase = Supabase.instance.client;

  String _userName = 'Guest';
  String _userPost = 'Visitor';
  String _branch = 'All Branches';
  String _userId = '';

  String get userName => _userName;
  String get userPost => _userPost;
  String get branch => _branch;
  String get userId => _userId;
  String? get token => _supabase.auth.currentSession?.accessToken;

  Future<bool> login(String identifier, String password) async {
    try {
      String email = identifier.trim();

      // 1. If identifier is NOT an email (e.g. BM-JA-001), find the associated email first
      if (!email.contains('@')) {
        final staffLookup = await _supabase
            .from(ApiConfig.tableStaff)
            .select('email')
            .eq('staff_code', identifier.toUpperCase().trim())
            .maybeSingle();
        
        if (staffLookup != null && staffLookup['email'] != null) {
          email = staffLookup['email'];
        } else {
          debugPrint('Staff code not found: $identifier');
          return false;
        }
      }

      // 2. Standard login with found/provided email
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _userId = response.user!.id;
        
        // Fetch details from staff table as the source of truth
        try {
          final staffData = await _supabase
              .from(ApiConfig.tableStaff)
              .select()
              .eq('id', _userId)
              .maybeSingle();

          if (staffData != null) {
            _userName = staffData['name'] ?? staffData['full_name'] ?? 'User';
            _userPost = staffData['role'] ?? 'Staff';
            _branch = staffData['branch'] ?? 'All Branches';
          } else {
            // Fallback to metadata if staff record doesn't exist
            final metadata = response.user!.userMetadata;
            _userName = metadata?['name'] ?? response.user!.email?.split('@')[0] ?? 'User';
            _userPost = metadata?['role'] ?? 'Staff';
            _branch = metadata?['branch'] ?? 'All Branches';
          }
        } catch (e) {
          debugPrint('Error fetching staff data: $e');
        }

        // Save login timestamp for 11h auto-logout
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_login_time', DateTime.now().millisecondsSinceEpoch);
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<String?> registerStaff(String name, String email, String password, String role, String branch) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role, 'branch': branch},
      );

      return response.user?.id;
    } catch (e) {
      debugPrint('Registration auth error: $e');
      rethrow;
    }
  }

  void setUser(String name, String post, String branchName, {String userId = ''}) {
    _userName = name;
    _userPost = post;
    _branch = branchName;
    _userId = userId;
  }

  Future<void> logout({DateTime? customTime}) async {
    await AttendanceService().checkOut(customTime: customTime);
    await _supabase.auth.signOut();
    _userName = 'Guest';
    _userPost = 'Visitor';
    _branch = 'All Branches';
    _userId = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_login_time');
  }

  // Get current user status on app start
  Future<void> initializeUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _userId = user.id;
      
      try {
        final staffData = await _supabase
            .from(ApiConfig.tableStaff)
            .select()
            .eq('id', _userId)
            .maybeSingle();

        if (staffData != null) {
          _userName = staffData['name'] ?? staffData['full_name'] ?? 'User';
          _userPost = staffData['role'] ?? 'Staff';
          _branch = staffData['branch'] ?? 'All Branches';
        } else {
          final metadata = user.userMetadata;
          _userName = metadata?['name'] ?? user.email?.split('@')[0] ?? 'User';
          _userPost = metadata?['role'] ?? 'Staff';
          _branch = metadata?['branch'] ?? 'All Branches';
        }
      } catch (e) {
        debugPrint('Error initializing staff data: $e');
      }

      // Check 11-hour session expiration
      try {
        final prefs = await SharedPreferences.getInstance();
        final lastLoginAt = prefs.getInt('last_login_time');
        
        if (lastLoginAt != null) {
          final loginDate = DateTime.fromMillisecondsSinceEpoch(lastLoginAt);
          final hoursPassed = DateTime.now().difference(loginDate).inHours;
          
          if (hoursPassed >= 11) {
            debugPrint('Session expired (11h). Logging out.');
            // Record checkout as exactly 11 hours after login to avoid massive durations
            final expiryTime = loginDate.add(const Duration(hours: 11));
            await logout(customTime: expiryTime);
            return;
          }
        } else {
          // If no timestamp but user is logged in, set it now (from older versions)
          await prefs.setInt('last_login_time', DateTime.now().millisecondsSinceEpoch);
        }
      } catch (e) {
        debugPrint('Error checking session expiration: $e');
      }
    }
  }
  Future<void> resetPassword(String identifier) async {
    try {
      String email = identifier.trim();

      // 1. Resolve Staff ID to email if needed
      if (!email.contains('@')) {
        final staffLookup = await _supabase
            .from(ApiConfig.tableStaff)
            .select('email')
            .eq('staff_code', identifier.toUpperCase().trim())
            .maybeSingle();

        if (staffLookup != null && staffLookup['email'] != null) {
          email = staffLookup['email'];
        } else {
          throw 'Staff ID not found. Please enter a valid Email or Staff ID.';
        }
      }

      // 2. Call the staff-auth Edge Function
      await _supabase.functions.invoke(
        ApiConfig.functionStaffAuth,
        body: {'email': email, 'type': 'recovery'},
      );
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    }
  }
}

