import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'main_layout.dart';
import '../models/auth_service.dart';
import '../models/attendance_service.dart';
import '../models/branch_service.dart';

// Brand Colors derived from the logo
const Color kBrandDark = Color(0xFF2C3545); // Deep Slate / Charcoal
const Color kBrandGold = Color(0xFFE8BC44); // Warm Gold / Yellow
const Color kBrandLight = Color(0xFFF8FAFC); // Very Light Slate
const Color kTextDark = Color(0xFF1E293B);
const Color kTextMuted = Color(0xFF64748B);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'Admin';
  String _selectedBranch = 'Jaffna';
  List<String> _branchNames = ['Jaffna', 'Poonakari'];
  bool _isLoadingBranches = true;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    try {
      await BranchService().fetchBranches();
      if (mounted) {
        setState(() {
          final all = BranchService().allBranches;
          _branchNames = all.map((b) => b.name).toList();
          
          if (_branchNames.isNotEmpty) {
            // Set first branch if current selection is not in list
            if (!_branchNames.contains(_selectedBranch)) {
              _selectedBranch = _branchNames.first;
            }
          } else {
            // Fallback if database is empty
            _branchNames = ['Jaffna'];
          }
          _isLoadingBranches = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBranches = false);
      }
    }
  }


  final Map<String, IconData> _roleIcons = {
    'Admin':   LucideIcons.shieldCheck,
    'Manager': LucideIcons.briefcase,
    'Staff':   LucideIcons.user,
  };

  void _handleLogin() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await AuthService().login(email, password);
      
      if (success) {
        // Ensure Admin role is explicitly set if logging in via the Admin tab. 
        if (_selectedRole == 'Admin') {
          AuthService().setUser(AuthService().userName, 'Admin', 'All Branches', userId: AuthService().userId);
        }

        // Mark attendance (Only for non-Admin roles)
        if (AuthService().userPost != 'Admin') {
          await AttendanceService().checkIn(
            AuthService().userId,
            AuthService().userName,
            AuthService().userPost,
            _selectedBranch,
          );
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invalid email or password. Please try again.'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    }
  }

  void _handleForgotPassword() async {
    final identifier = _usernameController.text.trim();

    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Email or Staff ID to reset password.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Send a password reset link to the email associated with "$identifier"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kTextMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrandDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await AuthService().resetPassword(identifier);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Please check your inbox.'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: 450, // Standard readable width for forms
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    // Logo
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kBrandDark.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/logo.jpg',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(LucideIcons.car, size: 40, color: kBrandDark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: kTextDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your role to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: kTextMuted),
                    ),
                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kBrandLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kBrandDark.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        children: ['Admin', 'Manager', 'Staff'].map((role) {
                          final isSelected = _selectedRole == role;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = role;
                                  _usernameController.clear();
                                  _passwordController.clear();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? kBrandDark : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: kBrandDark.withValues(alpha: 0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      _roleIcons[role],
                                      size: 20,
                                      color: isSelected ? kBrandGold : kTextMuted,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      role,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                        color: isSelected ? Colors.white : kTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    if (_selectedRole != 'Admin') ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Select Branch',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kTextDark),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: kBrandLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kBrandDark.withValues(alpha: 0.05), width: 1.5),
                        ),
                        child: _isLoadingBranches 
                          ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2, color: kBrandGold)))
                          : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBranch,
                            isExpanded: true,
                            icon: const Icon(LucideIcons.chevronDown, color: kTextMuted),
                            items: _branchNames.map((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val, style: const TextStyle(fontWeight: FontWeight.w600, color: kTextDark)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedBranch = val;
                                  _usernameController.clear();
                                  _passwordController.clear();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Email or Staff ID',
                      controller: _usernameController,
                      icon: LucideIcons.user,
                      hintText: 'e.g. BM-JA-001',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Password',
                      controller: _passwordController,
                      icon: LucideIcons.lock,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: kBrandGold,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),

                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kBrandLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.info, size: 16, color: kTextMuted),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Use your registered email or Staff ID to login.',
                              style: TextStyle(fontSize: 12, color: kTextMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w500, color: kTextDark),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: kTextMuted),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 20,
                      color: kTextMuted,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: kBrandLight,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: kBrandDark.withValues(alpha: 0.05), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kBrandDark, width: 2),
            ),
            hintText: hintText ?? 'Enter your $label',
            hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

