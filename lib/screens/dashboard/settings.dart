import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/theme_provider.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';

const primaryColor = Color(0xFF2D5EFF);
const backgroundLight = Color(0xFFF4F7FE);
const backgroundDark = Color(0xFF121212);
const cardLight = Color(0xFFE6EAF3);
const cardDark = Color(0xFF1E1E1E);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? cardDark : cardLight;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    return Scaffold(
      backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(isLargeScreen ? 20.0 : 12.0),
        children: [
          _buildSettingsSection(
            title: 'General',
            textColor: textColor,
            isLargeScreen: isLargeScreen,
            children: [
              _buildSettingsTile(
                title: 'Theme',
                subtitle: isDarkMode ? 'Dark Mode' : 'Light Mode',
                icon: isDarkMode ? Icons.brightness_7 : Icons.dark_mode,
                onTap: () => _showThemeDialog(context, ref, isDarkMode),
                cardColor: cardColor,
                textColor: textColor,
                isLargeScreen: isLargeScreen,
              ),
              _buildSettingsTile(
                title: 'Notifications',
                subtitle: 'Manage app notifications',
                icon: Icons.notifications,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications settings (coming soon)')),
                  );
                },
                cardColor: cardColor,
                textColor: textColor,
                isLargeScreen: isLargeScreen,
              ),
            ],
          ),
          _buildSettingsSection(
            title: 'Account',
            textColor: textColor,
            isLargeScreen: isLargeScreen,
            children: [
              _buildSettingsTile(
                title: 'Profile',
                subtitle: 'Edit your profile information',
                icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                cardColor: cardColor,
                textColor: textColor,
                isLargeScreen: isLargeScreen,
              ),
              _buildSettingsTile(
                title: 'Change Password',
                subtitle: 'Update your account password',
                icon: Icons.lock,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change Password (coming soon)')),
                  );
                },
                cardColor: cardColor,
                textColor: textColor,
                isLargeScreen: isLargeScreen,
              ),
              _buildSettingsTile(
                title: 'Logout',
                subtitle: 'Sign out of your account',
                icon: Icons.logout,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
                cardColor: cardColor,
                textColor: Colors.redAccent,
                isLargeScreen: isLargeScreen,
              ),
            ],
          ),
          _buildSettingsSection(
            title: 'About App',
            textColor: textColor,
            isLargeScreen: isLargeScreen,
            children: [
              _buildSettingsTile(
                title: 'Version',
                subtitle: '1.0.0',
                icon: Icons.info_outline,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('App Version: 1.0.0')),
                  );
                },
                cardColor: cardColor,
                textColor: textColor,
                isLargeScreen: isLargeScreen,
              ),
              _buildSettingsTile(
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                icon: Icons.privacy_tip,
                onTap: () => _showPrivacyPolicyDialog(context, isDarkMode),
                cardColor: cardColor,
                textColor: textColor,
                isLargeScreen: isLargeScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final themeNotifier = ref.read(themeProvider.notifier);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text('Light Mode'),
              value: false,
              groupValue: isDarkMode,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.state = value;
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<bool>(
              title: const Text('Dark Mode'),
              value: true,
              groupValue: isDarkMode,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.state = value;
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDarkMode ? backgroundDark : backgroundLight,
        title: const Text('Privacy Policy'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              '''
Privacy Policy – SEO AI Mastermind

This app values your privacy. Here’s what you need to know:

1. Information Collected
   - We may collect user info such as email, app usage data.
   - No sensitive or financial data is collected.

2. Use of Information
   - Data is used to improve features and user experience only.
   - We do not sell or share your personal data.

3. Third-party Services
   - The app integrates with trusted APIs like OpenAI and Firebase.
   - These may collect limited usage data under their policies.

4. Security
   - Data is stored securely using Firebase and encrypted protocols.

5. Your Consent
   - By using this app, you agree to the terms of this privacy policy.

For questions, contact: support@seoaimastermind.com
              ''',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
    required Color textColor,
    required bool isLargeScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 20.0 : 14.0,
            horizontal: isLargeScreen ? 0 : 4,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isLargeScreen ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.9),
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required bool isLargeScreen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 20 : 16,
          vertical: isLargeScreen ? 14 : 10,
        ),
        leading: Icon(icon, color: primaryColor, size: isLargeScreen ? 28 : 24),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isLargeScreen ? 18 : 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: isLargeScreen ? 14 : 12,
            color: textColor.withOpacity(0.7),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }
}
