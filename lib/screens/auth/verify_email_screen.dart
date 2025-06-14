import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  final User user;

  const VerifyEmailScreen({super.key, required this.user});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();

    // Check email verification status every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  Future<void> _checkEmailVerified() async {
    await widget.user.reload();
    final isVerified = widget.user.emailVerified;

    if (isVerified) {
      setState(() => _isEmailVerified = true);
      _timer?.cancel();
      // Navigate to home screen after verification
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      await widget.user.sendEmailVerification();

      setState(() => _canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() => _canResendEmail = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _cancelVerification() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Verify Your Email',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'We’ve sent a verification email to your address. Please check your inbox and click the link to verify.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _canResendEmail ? _sendVerificationEmail : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5EFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(280, 56),
                  ),
                  child: const Text('Resend Verification Email'),

                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _cancelVerification,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF2D5EFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
