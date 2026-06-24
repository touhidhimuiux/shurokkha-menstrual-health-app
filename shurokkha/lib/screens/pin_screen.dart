import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';

  void _onKey(String key) {
    if (key == 'del') {
      if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
    } else if (_pin.length < 4) {
      setState(() => _pin += key);
      if (_pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [Color(0xFFF0E0FF), Color(0xFFEDD9FF), Color(0xFFE0D0FF), Color(0xFFD0C0F0)],
        child: SafeArea(
          child: Column(
            children: [
              // Back
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios, size: 16,
                          color: AppColors.primaryPurple),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Set Your 4-Digit ',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark),
                            ),
                            TextSpan(
                              text: 'PIN',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryPurple),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Private & Offline Protection',
                        style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                      ),

                      const SizedBox(height: 24),

                      // Lock illustration
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(
                            colors: [Color(0xFFFFF8FF), Color(0xFFEDD9FF)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPurple.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.lock_rounded,
                                size: 60, color: AppColors.primaryPurple),
                            // Sparkles
                            Positioned(top: 20, left: 15,
                              child: Text('✦', style: TextStyle(
                                  fontSize: 14, color: Colors.amber.shade400))),
                            Positioned(top: 15, right: 15,
                              child: Text('✦', style: TextStyle(
                                  fontSize: 12, color: Colors.amber.shade400))),
                            Positioned(bottom: 20, right: 20,
                              child: Text('✦', style: TextStyle(
                                  fontSize: 10, color: Colors.amber.shade400))),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // PIN dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _pin.length
                                ? AppColors.primaryPurple
                                : Colors.white.withOpacity(0.7),
                            border: Border.all(
                              color: i < _pin.length
                                  ? AppColors.primaryPurple
                                  : AppColors.lightPurple.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        )),
                      ),

                      const SizedBox(height: 30),

                      // Number pad
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            _buildRow(['1', '2\nABC', '3\nDEF']),
                            _buildRow(['4\nGHI', '5\nJKL', '6\nMNO']),
                            _buildRow(['7\nPQRS', '8\nTUV', '9\nWXYZ']),
                            _buildRow(['', '0', 'del']),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: PurpleButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward,
                          onTap: () {
                            if (_pin.length == 4) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      const PrivacyFooter(),
                      const SizedBox(height: 20),
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

  Widget _buildRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((k) {
          if (k.isEmpty) return const SizedBox(width: 80);
          return GestureDetector(
            onTap: () => _onKey(k == 'del' ? 'del' : k[0]),
            child: Container(
              width: 80, height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: k == 'del'
                  ? const Icon(Icons.backspace_outlined,
                      color: AppColors.mediumPink, size: 24)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          k.split('\n')[0],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        if (k.contains('\n'))
                          Text(
                            k.split('\n')[1],
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textGrey,
                            ),
                          ),
                      ],
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}