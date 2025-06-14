import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';

const primaryColor = Color(0xFF2D5EFF);
const backgroundColor = Color(0xFFF4F7FE);
const darkBackground = Color(0xFF121212);
const cardColorLight = Color(0xFFF0F2F8);
const cardColorDark = Color(0xFF1F1F1F);

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();

  late final User? user;
  String? _profileImageUrl;
  DateTime? _birthDate;
  DateTime? _joiningDate;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user!.email ?? '';
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['fullName'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _profileImageUrl = (data['profileImageUrl'] ?? '').toString().trim();
        if (_profileImageUrl!.isEmpty) _profileImageUrl = null;

        if (data['birthDate'] != null) {
          _birthDate = (data['birthDate'] as Timestamp).toDate();
          _birthDateController.text = DateFormat('dd MMM yyyy').format(_birthDate!);
        }
        if (data['joiningDate'] != null) {
          _joiningDate = (data['joiningDate'] as Timestamp).toDate();
        }
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading profile: $e")));
    }
  }

  Future<void> _pickImage() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
        if (pickedFile != null) {
          final imageFile = File(pickedFile.path);
          final ref = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('profile_${user!.uid}.jpg');
          await ref.putFile(imageFile);
          final downloadUrl = await ref.getDownloadURL();
          setState(() {
            _profileImageUrl = downloadUrl;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Image picking is not supported on this platform."),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image upload error: $e")));
    }
  }

  Future<void> _selectBirthDate() async {
    DateTime initial = _birthDate ?? DateTime(2000);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'fullName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'birthDate': _birthDate,
          'profileImageUrl': _profileImageUrl,
          'joiningDate': _joiningDate ?? FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? darkBackground : backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                      ? NetworkImage(_profileImageUrl!)
                      : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      backgroundColor: primaryColor,
                      radius: 16,
                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(_nameController.text,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              Text(_emailController.text,
                  style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700])),
              if (_joiningDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  "Joined ${DateFormat('dd MMM yyyy').format(_joiningDate!)}",
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                ),
              ],
              const SizedBox(height: 30),
              _buildInputField(controller: _nameController, label: "Full Name", icon: Icons.person),
              const SizedBox(height: 20),
              _buildInputField(controller: _emailController, label: "Email", icon: Icons.email, readOnly: true),
              const SizedBox(height: 20),
              _buildInputField(controller: _phoneController, label: "Phone", icon: Icons.phone),
              const SizedBox(height: 20),
              _buildDateField(controller: _birthDateController, label: "Birth Date", icon: Icons.calendar_today),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                ),
                child: const Text("Update Profile", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              // Logout button removed as requested
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool readOnly = false,
  }) {
    final isDark = ref.watch(themeProvider);
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        filled: true,
        fillColor: isDark ? cardColorDark : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    final isDark = ref.watch(themeProvider);
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: _selectBirthDate,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        filled: true,
        fillColor: isDark ? cardColorDark : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
