import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hoverLogin = false;
  bool _hoverGoogle = false;
  bool _hoverApple = false;
  bool _hoverFacebook = false;

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign up to get started with SEO AI Mastermind.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildRoundedInputField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  obscure: _obscurePassword,
                  toggle: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscure: _obscureConfirmPassword,
                  toggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5EFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Register', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 25),
                _buildSocialIconsRow(authService),
                const SizedBox(height: 25),
                _buildLoginLink(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Create user root document
        await userDocRef.set({
          'email': user.email ?? '',
          'fullName': '',
          'birthDate': null,
          'isProUser': false,
          'joiningDate': FieldValue.serverTimestamp(),
          'keywordsCount': 0,
          'articlesCount': 0,
          'savedProjectsCount': 0,
          'planType': 'free',
          'profileImageUrl': '',
          'subscriptionExpiry': null,
          'updatedAt': FieldValue.serverTimestamp(),
          'phone': '',
        });

        // Initialize aiSuggestions subcollection with a dummy document
        await userDocRef.collection('aiSuggestions').add({
          'title': 'Welcome Suggestion',
          'description': 'This is your first AI suggestion.',
          'tag': 'welcome',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Initialize payments subcollection with a dummy document
        await userDocRef.collection('payments').add({
          'cardNumber': '**** **** **** 1234',
          'expiryDate': '01/2099',
          'name': 'Dummy Card',
          'plan': 'free',
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (!user.emailVerified) {
          await user.sendEmailVerification();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyEmailScreen(user: user),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration failed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildRoundedInputField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
    );
  }

  Widget _buildSocialIconsRow(authService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialCircleIcon(
          icon: FontAwesomeIcons.google,
          onTap: () async {
            try {
              await authService.signInWithGoogle();
              Navigator.pushReplacementNamed(context, '/home');
            } catch (e) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
          hover: _hoverGoogle,
          onHover: (hover) => setState(() => _hoverGoogle = hover),
        ),
        const SizedBox(width: 20),
        _buildSocialCircleIcon(
          icon: FontAwesomeIcons.apple,
          onTap: () => print('Apple login tapped'),
          hover: _hoverApple,
          onHover: (hover) => setState(() => _hoverApple = hover),
        ),
        const SizedBox(width: 20),
        _buildSocialCircleIcon(
          icon: FontAwesomeIcons.facebookF,
          onTap: () => print('Facebook login tapped'),
          hover: _hoverFacebook,
          onHover: (hover) => setState(() => _hoverFacebook = hover),
        ),
      ],
    );
  }

  Widget _buildSocialCircleIcon({
    required IconData icon,
    required VoidCallback onTap,
    required bool hover,
    required ValueChanged<bool> onHover,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hover ? const Color(0xFF2D5EFF) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: hover ? Colors.white : const Color(0xFF2D5EFF), size: 20),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hoverLogin = true),
          onExit: (_) => setState(() => _hoverLogin = false),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Login',
              style: TextStyle(
                color: const Color(0xFF2D5EFF),
                fontWeight: FontWeight.w600,
                decoration: _hoverLogin ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
