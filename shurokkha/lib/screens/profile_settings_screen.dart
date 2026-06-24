import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

import '../services/auth_provider.dart';
import '../services/firestore_user_service.dart';
import '../widgets/snackbar.dart';
import '../theme/app_theme.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;

  File? _image;
  bool _loading = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    
    _nameController = TextEditingController(text: auth.userName ?? '');
    _emailController = TextEditingController(text: auth.userEmail ?? '');
    _ageController = TextEditingController(text: auth.userAge ?? '');
    _currentImageUrl = auth.profileImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: source,
      imageQuality: 30, // Compressed for Base64 efficiency
      maxWidth: 300, 
      maxHeight: 300,
    );

    if (img != null) {
      setState(() => _image = File(img.path));
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Wrap(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Update Profile Picture",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.photo_library, color: AppColors.primaryPurple),
                  ),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pick(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.photo_camera, color: AppColors.primaryPurple),
                  ),
                  title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pick(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    
    try {
      final auth = context.read<AuthProvider>();
      String? imageToSave = _currentImageUrl;

      // 1. Convert Image to Base64 String
      if (_image != null) {
        List<int> imageBytes = await _image!.readAsBytes();
        imageToSave = base64Encode(imageBytes);
      }

      // 2. Update Firestore Database
      final firestoreService = FirestoreUserService();
      await firestoreService.updateUserProfile(
        name: _nameController.text,
        age: _ageController.text,
        lastPeriod: auth.lastPeriodDate ?? '',
        cycleLength: auth.cycleLength ?? 28,
        profileImageUrl: imageToSave,
      );

      // 3. Update AuthProvider locally
      await auth.setProfileData(
        name: _nameController.text,
        email: _emailController.text,
        age: _ageController.text,
        profileImageUrl: imageToSave,
      );

      if (mounted) {
        showSuccessSnackBar(context, "Profile updated successfully");
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, "Failed to update profile. Try again.");
      debugPrint("Save Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  ImageProvider? _getAvatarProvider() {
    if (_image != null) return FileImage(_image!);
    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      if (_currentImageUrl!.startsWith('http')) {
        return NetworkImage(_currentImageUrl!);
      } else {
        try {
          return MemoryImage(base64Decode(_currentImageUrl!));
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Section
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerModal,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2), width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: const Color(0xFFedf0f8),
                          backgroundImage: _getAvatarProvider(),
                          child: (_image == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                              ? const Icon(Icons.person, size: 65, color: Color(0xFFC8B0E8))
                              : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPurple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Tap to change profile picture",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              
              const SizedBox(height: 40),

              // Input Fields
              _buildModernTextField("Full Name", _nameController, Icons.person_outline),
              const SizedBox(height: 20),
              _buildModernTextField("Email Address", _emailController, Icons.email_outlined, readOnly: true),
              const SizedBox(height: 20),
              _buildModernTextField("Age", _ageController, Icons.cake_outlined, keyboardType: TextInputType.number),
              
              const SizedBox(height: 50),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: AppColors.primaryPurple.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField(String label, TextEditingController controller, IconData icon, {bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFedf0f8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: TextStyle(
              color: readOnly ? Colors.grey.shade600 : Colors.black87,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: readOnly ? Colors.grey : AppColors.primaryPurple),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}