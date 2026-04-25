
class Attendance {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String branch;
  final DateTime checkIn;
  final DateTime? checkOut;
  final double totalHours;
  final double overtimeHours;
  final String status; // 'Active', 'Completed', 'Invalid'
  final String? loginLocation;
  final String? logoutLocation;
  final String date;

  Attendance({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.branch,
    required this.checkIn,
    this.checkOut,
    this.totalHours = 0.0,
    this.overtimeHours = 0.0,
    this.status = 'Active',
    this.loginLocation,
    this.logoutLocation,
    String? date,
  }) : date = date ?? "${checkIn.year}-${checkIn.month.toString().padLeft(2, '0')}-${checkIn.day.toString().padLeft(2, '0')}";

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'branch': branch,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'total_hours': totalHours,
      'overtime_hours': overtimeHours,
      'status': status,
      'login_location': loginLocation,
      'logout_location': logoutLocation,
      'date': date,
    };
  }

  double get currentTotalHours {
    if (status == 'Active') {
      final now = DateTime.now();
      final diffInHours = now.difference(checkIn).inHours;
      // If session has been active for more than 16 hours, it's likely a forgotten logout
      if (diffInHours > 16) {
        return 0.0; 
      }
      return now.difference(checkIn).inMinutes / 60.0;
    }
    return totalHours;
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'Unknown',
      userRole: json['user_role'] ?? 'Staff',
      branch: json['branch'] ?? 'Jaffna',
      checkIn: json['check_in'] != null ? DateTime.parse(json['check_in']) : DateTime.now(),
      checkOut: json['check_out'] != null ? DateTime.parse(json['check_out']) : null,
      totalHours: (json['total_hours'] is num) ? (json['total_hours'] as num).toDouble() : 0.0,
      overtimeHours: (json['overtime_hours'] is num) ? (json['overtime_hours'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'Active',
      loginLocation: json['login_location'],
      logoutLocation: json['logout_location'],
      date: json['date'] ?? '',
    );
  }
}
