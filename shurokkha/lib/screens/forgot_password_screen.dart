import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/localization_extension.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _showDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(
            color: isSuccess ? Colors.green.shade700 : Colors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFF1A1A1A)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              if (isSuccess) {
                Navigator.pop(context); // Go back to login screen if successful
              }
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: isSuccess ? Colors.green.shade700 : AppColors.primaryPurple, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendResetLink() async {
    String email = emailController.text.trim();

    // 1. Empty validation
    if (email.isEmpty) {
      _showDialog(
        context.translate('error') ?? 'Error',
        'Please enter your email address',
      );
      return;
    }

    // 2. Email format validation
    bool emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!emailValid) {
      _showDialog(
        context.translate('error') ?? 'Error',
        'Please enter a valid email address',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 3. Send Firebase Password Reset Email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // 4. Show success message
      if (mounted) {
        _showDialog(
          'Link Sent!',
          'A password reset link has been sent to $email. Please check your inbox and spam folders.',
          isSuccess: true,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors gracefully
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email address.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is badly formatted.';
      }

      if (mounted) {
        _showDialog(context.translate('error') ?? 'Error', errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showDialog(context.translate('error') ?? 'Error', e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Back Button Custom Positioning
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A1A)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.08),

                      // Image
                      Center(
                        child: Image.asset(
                          'assets/resetpassword.png', 
                          height: size.height * 0.22, 
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.04),

                      // Title Text
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Subtitle Text
                      Text(
                        'Enter the email address associated with your account and we will send you a link to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.05),

                      // Email Field
                      _buildWhiteTextField(
                        controller: emailController,
                        hintText: 'Enter your Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      SizedBox(height: size.height * 0.05),

                      // Send Link Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : sendResetLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: AppColors.primaryPurple.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Send Reset Link',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
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
    );
  }

  // Professional White Text Field Builder (Matching Login Screen)
  Widget _buildWhiteTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5), 
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.08), 
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.primaryPurple.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}