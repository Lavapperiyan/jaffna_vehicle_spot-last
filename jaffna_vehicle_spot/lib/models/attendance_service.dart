import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'attendance.dart';
import 'auth_service.dart';
import '../utils/notification_service.dart';
import '../utils/api_config.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal() {
    _loadAttendances();
  }

  final _supabase = Supabase.instance.client;
  Attendance? _currentAttendance;
  Attendance? get currentAttendance => _currentAttendance;

  final ValueNotifier<List<Attendance>> allAttendancesNotifier = ValueNotifier<List<Attendance>>([]);

  final int startHour = 8;
  final int endHour = 18;
  final int forceLogoutHour = 22;

  Future<void> checkIn(String userId, String userName, String userRole, String branch) async {
    // 1. Close any existing active sessions for this user to prevent multiple active sessions
    try {
      final activeResponse = await _supabase
          .from(ApiConfig.tableAttendance)
          .select('id, check_in')
          .eq('user_id', userId)
          .eq('status', 'Active');
      
      final List<dynamic> activeData = activeResponse as List;
      for (var item in activeData) {
        final recordId = item['id'];
        final checkInStr = item['check_in'];
        if (checkInStr != null) {
          final oldCheckIn = DateTime.parse(checkInStr);
          final now = DateTime.now();
          
          // If the old session is from a previous day, set checkout to 8 hours after check-in
          // Otherwise, use current time
          DateTime checkoutTime = now;
          if (oldCheckIn.year != now.year || oldCheckIn.month != now.month || oldCheckIn.day != now.day) {
            checkoutTime = oldCheckIn.add(const Duration(hours: 8));
          }
          
          final duration = checkoutTime.difference(oldCheckIn);
          final hours = duration.inMinutes / 60.0;
          
          await _supabase.from(ApiConfig.tableAttendance).update({
            'check_out': checkoutTime.toIso8601String(),
            'total_hours': hours,
            'status': 'Completed',
          }).eq('id', recordId);
        }
      }
    } catch (e) {
      debugPrint('Error auto-closing old sessions: $e');
    }

    final now = DateTime.now();
    
    _currentAttendance = Attendance(
      id: DateFormat('yyyyMMdd_HHmmss').format(now),
      userId: userId,
      userName: userName,
      userRole: userRole,
      branch: branch,
      checkIn: now,
      status: 'Active',
    );

    // Sync with Supabase
    try {
      await _supabase.from(ApiConfig.tableAttendance).insert({
        'user_id': userId,
        'user_name': userName,
        'user_role': userRole,
        'branch': branch,
        'check_in': now.toIso8601String(),
        'status': 'Active',
        'local_id': _currentAttendance!.id,
      });
    } catch (e) {
      debugPrint('Supabase checkIn error: $e');
    }
    
    if (!kIsWeb) {
      NotificationService().showNotification(
        id: 1,
        title: 'Check-In Successful',
        body: 'Welcome $userName! Your attendance has been marked at ${DateFormat('hh:mm a').format(now)}.',
      );
    }
    
    _updateAllAttendances(_currentAttendance!);
    await refreshFromSupabase(); // Ensure we have the latest state
  }

  Future<void> checkOut({DateTime? customTime}) async {
    if (_currentAttendance == null) return;

    final now = customTime ?? DateTime.now();
    final checkIn = _currentAttendance!.checkIn;
    
    // Calculate total hours
    final duration = now.difference(checkIn);
    final totalHours = duration.inMinutes / 60.0;

    // Calculate overtime
    double overtime = 0.0;
    final workEndTime = DateTime(now.year, now.month, now.day, endHour);
    
    if (now.isAfter(workEndTime)) {
      final overtimeDuration = now.difference(workEndTime.isAfter(checkIn) ? workEndTime : checkIn);
      if (overtimeDuration.inMinutes > 0) {
        overtime = overtimeDuration.inMinutes / 60.0;
      }
    }

    final completedAttendance = Attendance(
      id: _currentAttendance!.id,
      userId: _currentAttendance!.userId,
      userName: _currentAttendance!.userName,
      userRole: _currentAttendance!.userRole,
      branch: _currentAttendance!.branch,
      checkIn: _currentAttendance!.checkIn,
      checkOut: now,
      totalHours: totalHours,
      overtimeHours: overtime,
      status: 'Completed',
    );

    // Sync with Supabase
    try {
      await _supabase
          .from(ApiConfig.tableAttendance)
          .update({
            'check_out': now.toIso8601String(),
            'total_hours': totalHours,
            'overtime_hours': overtime,
            'status': 'Completed',
          })
          .eq('local_id', _currentAttendance!.id);
    } catch (e) {
      debugPrint('Supabase checkOut error: $e');
    }

    _updateAllAttendances(completedAttendance);
    _currentAttendance = null; 
  }

  Future<void> _saveAttendances() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = allAttendancesNotifier.value.map((a) => a.toJson()).toList();
      await prefs.setString('attendances_data', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving attendance: $e');
    }
  }

  Future<void> _loadAttendances() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('attendances_data');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        allAttendancesNotifier.value = jsonList.map((j) => Attendance.fromJson(j)).toList();
      }
      
      // Also try to load fresh data from Supabase
      await refreshFromSupabase();
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    }
  }

  Future<void> refreshFromSupabase() async {
    try {
      final role = AuthService().userPost.toLowerCase();
      final userId = AuthService().userId;
      final isAdmin = role.contains('admin') || role.contains('manager') || role.contains('owner') || role.contains('director');

      var query = _supabase.from(ApiConfig.tableAttendance).select();
      
      // If NOT admin/manager, only fetch current user's attendance
      if (!isAdmin && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }
      
      final response = await query.order('check_in', ascending: false);

      final List<dynamic> data = response as List;
      final List<Attendance> fetched = data.map((json) => Attendance.fromJson(json)).toList();

      allAttendancesNotifier.value = fetched;
      _saveAttendances();
      
      // Find if there's an active session
      try {
        final active = fetched.firstWhere((a) => a.userId == userId && a.status == 'Active');
        _currentAttendance = active;
      } catch (e) {
        _currentAttendance = null;
      }
    } catch (e) {
      debugPrint('Error refreshing attendance from Supabase: $e');
    }
  }

  Future<void> fetchAllAttendances() async {
    // This is essentially what refreshFromSupabase now does if the user is an admin.
    // We can just call refreshFromSupabase() to sync everything.
    await refreshFromSupabase();
  }

  void _updateAllAttendances(Attendance attendance) {
    final list = List<Attendance>.from(allAttendancesNotifier.value);
    final index = list.indexWhere((a) => a.id == attendance.id);
    if (index != -1) {
      list[index] = attendance;
    } else {
      list.insert(0, attendance);
    }
    allAttendancesNotifier.value = list;
    _saveAttendances();
  }

  bool isOvertimeStarted() {
    final now = DateTime.now();
    return now.hour >= endHour;
  }

  Future<void> forceLogoutAtNight() async {
    if (_currentAttendance != null) {
      await checkOut();
      if (!kIsWeb) {
        NotificationService().showNotification(
          id: 3,
          title: 'Night Auto-Logout',
          body: 'Your work session has been automatically closed for the day.',
        );
      }
    }
  }
}
