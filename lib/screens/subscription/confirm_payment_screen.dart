import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants.dart';

class ConfirmPaymentScreen extends StatefulWidget {
  final String planType;
  const ConfirmPaymentScreen({required this.planType, super.key});

  @override
  State<ConfirmPaymentScreen> createState() => _ConfirmPaymentScreenState();
}

class _ConfirmPaymentScreenState extends State<ConfirmPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cardNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  Future<void> _confirmPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
      final paymentRef = userRef.collection("payments").doc();

      final cardNumber = _cardNumberController.text.trim();
      final maskedCard = cardNumber.length >= 4
          ? '************${cardNumber.substring(cardNumber.length - 4)}'
          : '************';

      // Store payment data
      await paymentRef.set({
        'cardNumber': maskedCard,
        'expiryDate': _expiryDateController.text.trim(),
        'name': _cardNameController.text.trim(),
        'plan': widget.planType,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update user subscription status
      await userRef.set({
        'isProUser': true,
        'planType': widget.planType,
        'subscriptionStarted': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Show toast
      Fluttertoast.showToast(
        msg: "Payment successful. Welcome to Pro plan!",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.green.shade600,
        textColor: Colors.white,
      );

      // Navigate to congrats screen
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/premium_congrats',
        arguments: {
          'isDarkMode': Theme.of(context).brightness == Brightness.dark,
          'onDismiss': () {
            Navigator.pushReplacementNamed(context, '/pro-dashboard');
          },
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? backgroundDark : backgroundLight;
    final cardColor = isDark ? cardDark : cardLight;

    final maxWidth = MediaQuery.of(context).size.width < 600
        ? MediaQuery.of(context).size.width * 0.9
        : 500.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Confirm Payment"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Container(
            width: maxWidth,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("Upgrade to Pro",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      )),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _cardNameController,
                    hintText: "Cardholder Name",
                    icon: Icons.person,
                    inputType: TextInputType.name,
                    validatorMsg: "Enter name",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cardNumberController,
                    hintText: "Card Number",
                    icon: Icons.credit_card,
                    inputType: TextInputType.number,
                    maxLength: 19,
                    validatorMsg: "Enter card number",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _expiryDateController,
                    hintText: "MM/YYYY",
                    icon: Icons.date_range,
                    inputType: TextInputType.datetime,
                    maxLength: 7,
                    validator: (value) {
                      final pattern = RegExp(r"^(0[1-9]|1[0-2])\/\d{4}$");
                      if (value == null || !pattern.hasMatch(value)) {
                        return "Enter valid MM/YYYY";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                      onPressed: _confirmPayment,
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text("Confirm & Subscribe"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    String? validatorMsg,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      validator: validator ??
              (value) {
            if (value == null || value.trim().isEmpty) {
              return validatorMsg ?? "Required";
            }
            return null;
          },
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Icon(icon, color: primaryColor),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
