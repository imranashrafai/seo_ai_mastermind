import 'package:flutter/material.dart';

const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);

class GoPremiumScreen extends StatelessWidget {
  final bool isDarkMode;

  const GoPremiumScreen({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? backgroundDark : backgroundLight;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? cardDark : cardLight;

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Go Premium',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: isLargeScreen ? 24 : 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 48 : 24,
          vertical: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(textColor, isLargeScreen),
            const SizedBox(height: 30),
            _buildBenefitsSection(cardColor, textColor, isLargeScreen),
            const SizedBox(height: 40),
            _buildPricingSection(context, cardColor, textColor, isLargeScreen),
            const SizedBox(height: 40),
            _buildCallToAction(context, isLargeScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Color textColor, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unlock the full potential of SEO AI Mastermind',
          style: TextStyle(
            fontSize: isLargeScreen ? 26 : 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Upgrade to Premium and gain access to exclusive tools, unlimited usage, and priority support.',
          style: TextStyle(
            fontSize: isLargeScreen ? 18 : 14,
            color: textColor.withOpacity(0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection(Color cardColor, Color textColor, bool isLargeScreen) {
    final benefits = [
      'Unlimited access to all AI tools',
      'Priority customer support',
      'Advanced SEO analytics',
      'Exclusive content writing features',
      'Regular updates and new tools',
    ];

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 30 : 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: benefits.map((benefit) {
          return Padding(
            padding: EdgeInsets.only(bottom: isLargeScreen ? 18 : 12),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: isLargeScreen ? 28 : 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      color: textColor,
                      fontSize: isLargeScreen ? 18 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context, Color cardColor, Color textColor, bool isLargeScreen) {
    return Column(
      children: [
        _buildPlanCard(context, 'Monthly Plan', '\$9.99 / month', cardColor, textColor, isLargeScreen, '/confirm_payment_monthly'),
        const SizedBox(height: 20),
        _buildPlanCard(context, 'Yearly Plan', '\$99.99 / year', cardColor, textColor, isLargeScreen, '/confirm_payment_yearly'),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, String title, String price, Color cardColor, Color textColor, bool isLargeScreen, String route) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 30 : 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: TextStyle(
              fontSize: isLargeScreen ? 26 : 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, route);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(
                vertical: isLargeScreen ? 14 : 12,
                horizontal: 32,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: Text(
              'Choose',
              style: TextStyle(
                fontSize: isLargeScreen ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction(BuildContext context, bool isLargeScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/confirm_payment');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 18 : 14,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 5,
          shadowColor: primaryColor.withOpacity(0.4),
        ),
        child: Text(
          'Upgrade Now',
          style: TextStyle(
            fontSize: isLargeScreen ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
