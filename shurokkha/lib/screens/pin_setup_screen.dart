import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/pin_provider.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  late TextEditingController _pinController;
  late TextEditingController _confirmController;
  bool _showPin = false;
  bool _showConfirmPin = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _setupPin() async {
    setState(() => _errorMessage = '');

    if (_pinController.text.length != 4) {
      setState(() => _errorMessage = 'PIN must be 4 digits');
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(_pinController.text)) {
      setState(() => _errorMessage = 'PIN must contain only numbers');
      return;
    }

    if (_pinController.text != _confirmController.text) {
      setState(() => _errorMessage = 'PINs do not match');
      return;
    }

    final pinProvider = context.read<PinProvider>();
    final success = await pinProvider.setPin(_pinController.text);

    if (success && mounted) {
      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home', arguments: {'userName': 'User'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [Color(0xFFEDD9FF), Color(0xFFF0E0FF), Color(0xFFFFE6F5), Color(0xFFE8D5FF)],
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.lock_outline, size: 80, color: AppColors.primaryPurple),
                  const SizedBox(height: 24),
                  const Text(
                    'Set Your PIN',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Set a 4-digit PIN to secure your app',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // PIN Input
                  TextField(
                    controller: _pinController,
                    obscureText: !_showPin,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 12,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: '____',
                      hintStyle: const TextStyle(
                        color: AppColors.textGrey,
                        letterSpacing: 12,
                      ),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryPurple),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_showPin ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _showPin = !_showPin),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Confirm PIN Input
                  TextField(
                    controller: _confirmController,
                    obscureText: !_showConfirmPin,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 12,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: '____',
                      hintStyle: const TextStyle(
                        color: AppColors.textGrey,
                        letterSpacing: 12,
                      ),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryPurple),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_showConfirmPin ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _showConfirmPin = !_showConfirmPin),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Setup Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _setupPin,
                      child: const Text(
                        'Set PIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
