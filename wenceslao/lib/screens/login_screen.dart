import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/app_state_provider.dart';
import '../models/student.dart';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _idController.dispose();
    _emailController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleLogin(String id, String email) async {
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    final success = await provider.login(
      id.trim().toUpperCase(),
      email: email.trim().toLowerCase(),
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text(
              provider.errorMessage ?? 'Login failed. Please check your credentials.',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Deep Slate Dark
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Icon Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Title
                  Text(
                    'ScoreRecord',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Access your syllabus grades & schedule study tasks',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF1E293B,
                      ).withValues(alpha: 0.6), // Glassmorphism container
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF334155).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Student Login',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Color(0xFF94A3B8),
                              ),
                              labelText: 'Enter Email Address',
                              labelStyle: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF334155),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6366F1),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEF4444),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email address';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Input Student ID
                          TextFormField(
                            controller: _idController,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.badge_outlined,
                                color: Color(0xFF94A3B8),
                              ),
                              labelText: 'Enter Student ID',
                              labelStyle: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF334155),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6366F1),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEF4444),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your Student ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Submit Button
                          ElevatedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _handleLogin(_idController.text, _emailController.text);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.5),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Access Portal',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status Info (Firebase vs Mock)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: provider.firebaseMode
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: provider.firebaseMode
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            provider.firebaseMode
                                ? 'Firebase Mode Active'
                                : 'Demo Mode (Mock DB) Active',
                            style: GoogleFonts.inter(
                              color: provider.firebaseMode
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
