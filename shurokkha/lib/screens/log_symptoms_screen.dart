import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/localization_extension.dart';

class LogSymptomsScreen extends StatefulWidget {
  const LogSymptomsScreen({super.key});

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> {
  int _navIndex = 2;
  
  String? _selectedFlowIntensity;
  String? _selectedPainLevel;
  String? _selectedMood;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [Color(0xFFEDD9FF), Color(0xFFF0E0FF), Color(0xFFFFE6F5), Color(0xFFE8D5FF)],
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.translate('log_symptoms'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: AppColors.textDark),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Flow Intensity Section
                      Text(
                        context.translate('flow_intensity'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SymptomButton(
                            icon: Icons.water_drop,
                            label: context.translate('low'),
                            isSelected: _selectedFlowIntensity == 'Low',
                            onTap: () => setState(() => _selectedFlowIntensity = 'Low'),
                          ),
                          _SymptomButton(
                            icon: Icons.water_drop,
                            label: context.translate('medium'),
                            isSelected: _selectedFlowIntensity == 'Medium',
                            onTap: () => setState(() => _selectedFlowIntensity = 'Medium'),
                          ),
                          _SymptomButton(
                            icon: Icons.water_drop,
                            label: context.translate('high'),
                            isSelected: _selectedFlowIntensity == 'High',
                            onTap: () => setState(() => _selectedFlowIntensity = 'High'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Pain Levels Section
                      Text(
                        context.translate('pain_levels'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SymptomButton(
                            icon: Icons.sentiment_satisfied,
                            label: context.translate('no_pain'),
                            isSelected: _selectedPainLevel == 'No Pain',
                            onTap: () => setState(() => _selectedPainLevel = 'No Pain'),
                          ),
                          _SymptomButton(
                            icon: Icons.sentiment_neutral,
                            label: context.translate('moderate'),
                            isSelected: _selectedPainLevel == 'Moderate',
                            onTap: () => setState(() => _selectedPainLevel = 'Moderate'),
                          ),
                          _SymptomButton(
                            icon: Icons.sentiment_dissatisfied,
                            label: context.translate('severe'),
                            isSelected: _selectedPainLevel == 'Severe',
                            onTap: () => setState(() => _selectedPainLevel = 'Severe'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Mood Section
                      Text(
                        context.translate('mood'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _SymptomButton(
                            icon: Icons.favorite,
                            label: context.translate('good'),
                            isSelected: _selectedMood == 'Good',
                            onTap: () => setState(() => _selectedMood = 'Good'),
                          ),
                          _SymptomButton(
                            icon: Icons.face,
                            label: context.translate('neutral'),
                            isSelected: _selectedMood == 'Neutral',
                            onTap: () => setState(() => _selectedMood = 'Neutral'),
                          ),
                          _SymptomButton(
                            icon: Icons.sentiment_very_dissatisfied,
                            label: context.translate('sad'),
                            isSelected: _selectedMood == 'Sad',
                            onTap: () => setState(() => _selectedMood = 'Sad'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Save Button
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.translate('symptoms_logged')),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Text(
                            context.translate('save_symptoms'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 0) Navigator.pop(context);
        },
      ),
    );
  }
}

class _SymptomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SymptomButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mediumPink : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.mediumPink : AppColors.softLavender,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
