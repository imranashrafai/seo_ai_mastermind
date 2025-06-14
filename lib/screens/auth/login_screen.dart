import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';

const primaryColor = Color(0xFF2D5EFF);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;
  String? _generalError;

  bool _hoverForgotPassword = false;
  bool _hoverRegister = false;
  bool _hoverGoogle = false;
  bool _hoverApple = false;
  bool _hoverFacebook = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    final authService = ref.read(authServiceProvider);

    try {
      final user = await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && !user.emailVerified) {
        Navigator.pushReplacementNamed(
          context,
          '/verify-email',
          arguments: {'user': user},
        );
      } else if (user != null) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _emailError = 'No user found for that email.';
            break;
          case 'wrong-password':
            _passwordError = 'Incorrect password.';
            break;
          case 'invalid-email':
            _emailError = 'Invalid email address.';
            break;
          default:
            _generalError = e.message ?? 'Login failed';
        }
      });
    } catch (e) {
      setState(() => _generalError = 'Login failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildRoundedInputField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    textInputAction: TextInputAction.next,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordInput(
                    errorText: _passwordError,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 10),
                  _buildForgotPasswordLink(),
                  if (_generalError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _generalError!,
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                  ],
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
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
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 25),
                  _buildSocialIconsRow(authService),
                  const SizedBox(height: 25),
                  _buildRegisterLink(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedInputField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? errorText,
    TextInputAction? textInputAction,
    required bool isDarkMode,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        errorText: errorText,
      ),
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label == 'Email' && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
    );
  }

  Widget _buildPasswordInput({String? errorText, required bool isDarkMode}) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        errorText: errorText,
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
        ),
      ),
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
      validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
      onFieldSubmitted: (_) => _submitLogin(),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoverForgotPassword = true),
        onExit: (_) => setState(() => _hoverForgotPassword = false),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/forgot-password'),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              decoration: _hoverForgotPassword ? TextDecoration.underline : TextDecoration.none,
            ),
            child: const Text('Forgot Password?'),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoverRegister = true),
        onExit: (_) => setState(() => _hoverRegister = false),
        child: GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/register'),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              decoration: _hoverRegister ? TextDecoration.underline : TextDecoration.none,
            ),
            child: const Text("Don't have an account? Register"),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIconsRow(AuthService authService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialCircleIcon(
          icon: FontAwesomeIcons.google,
          onTap: _isLoading
              ? null
              : () async {
            setState(() {
              _generalError = null;
              _isLoading = true;
            });
            try {
              final user = await authService.signInWithGoogle();
              if (user != null && !user.emailVerified) {
                Navigator.pushReplacementNamed(context, '/verify-email', arguments: {'user': user});
              } else if (user != null) {
                Navigator.pushReplacementNamed(context, '/');
              }
            } catch (e) {
              setState(() {
                _generalError = 'Google sign-in failed: $e';
              });
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          hover: _hoverGoogle,
          onHover: (hover) => setState(() => _hoverGoogle = hover),
          isEnabled: !_isLoading,
        ),
        const SizedBox(width: 20),
        _buildSocialCircleIcon(
          icon: FontAwesomeIcons.apple,
          onTap: () {},
          hover: _hoverApple,
          onHover: (hover) => setState(() => _hoverApple = hover),
          isEnabled: !_isLoading,
        ),
        const SizedBox(width: 20),
        _buildSocialCircleIcon(
          icon: FontAwesomeIcons.facebookF,
          onTap: () {},
          hover: _hoverFacebook,
          onHover: (hover) => setState(() => _hoverFacebook = hover),
          isEnabled: !_isLoading,
        ),
      ],
    );
  }

  Widget _buildSocialCircleIcon({
    required IconData icon,
    required VoidCallback? onTap,
    required bool hover,
    required void Function(bool) onHover,
    bool isEnabled = true,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hover ? primaryColor.withOpacity(0.15) : Colors.transparent,
            border: Border.all(color: primaryColor, width: 1.5),
            boxShadow: hover
                ? [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ]
                : [],
          ),
          child: Icon(icon, color: primaryColor, size: 24),
        ),
      ),
    );
  }
}
