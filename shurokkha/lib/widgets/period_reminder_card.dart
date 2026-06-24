import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/period_data_provider.dart';
import '../services/localization_extension.dart';

class PeriodReminderCard extends StatelessWidget {
  const PeriodReminderCard({super.key});

  // Helper to determine phase details dynamically with localized text
  Map<String, dynamic> _getPhaseDetails(int cycleDay, int periodLength, int cycleLength, BuildContext context) {
    if (cycleDay <= periodLength) {
      return {
        'title': context.translate('phase_menstruation') ?? 'Menstruation',
        'subtitle': context.translate('active_period') ?? 'Take time to rest and recover.',
        'color': const Color(0xFFFF2A6D), // Ultra-bright neon coral pink
        'gradient': [const Color(0xFFFF2A6D), const Color(0xFFFF62A5)],
        'emoji': '🩸',
      };
    } else if (cycleDay <= 12) {
      return {
        'title': context.translate('phase_follicular') ?? 'Follicular Phase',
        'subtitle': 'Your energy levels are rising!',
        'color': const Color(0xFF00E5FF), // High-luminosity neon cyan
        'gradient': [const Color(0xFF00E5FF), const Color(0xFF00A2FF)],
        'emoji': '🌱',
      };
    } else if (cycleDay <= 16) {
      return {
        'title': context.translate('phase_ovulatory') ?? 'Ovulatory Phase',
        'subtitle': 'Peak fertility window open.',
        'color': const Color(0xFF7B1FA2), // Vibrant high-contrast magenta-purple
        'gradient': [const Color(0xFF9C27B0), const Color(0xFFE040FB)],
        'emoji': '✨',
      };
    } else {
      return {
        'title': context.translate('phase_luteal') ?? 'Luteal Phase',
        'subtitle': 'Practice gentle self-care routines.',
        'color': const Color(0xFFFF9100), // High-intensity electric amber orange
        'gradient': [const Color(0xFFFF9100), const Color(0xFFFFD600)],
        'emoji': '🧘🏽‍♀️',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PeriodDataProvider>(
      builder: (context, provider, child) {
        final currentCycleDay = provider.currentCycleDay;
        final periodLength = provider.periodLength;
        final cycleLength = provider.cycleLength;

        // Fetch visual configuration states based on mathematical phase state metrics
        final details = _getPhaseDetails(currentCycleDay, periodLength, cycleLength, context);
        final List<Color> activeGradient = details['gradient'];
        final Color themeAccentColor = details['color'];

        // Compute circular percentage fill indicators safely
        final double progressPercent = (currentCycleDay / math.max(1, cycleLength)).clamp(0.0, 1.0);
        final int daysRemaining = math.max(0, cycleLength - currentCycleDay);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36), // Slightly rounder premium edges
            border: Border.all(
              color: const Color(0xFF7B35B5).withOpacity(0.14),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B35B5).withOpacity(0.06),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(26), // Increased structural spatial padding for height/width volume expansion
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- TOP SECTION: APP-STYLE METRICS ROW WITH OVERFLOW SAFE PROTECTION ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Premium Upscaled Ring-Track Progress Wheel Engine (Increased Sizing Parameters)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Smooth outershadow glow ring matching current phase spectrums
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: themeAccentColor.withOpacity(0.18),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      // Background Track Orbit Track
                      const SizedBox(
                        width: 94,
                        height: 94,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 9.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFF2F2F7),
                          ),
                        ),
                      ),
                      // Vibrant Foreground Linear Custom Gradient Arc Layer
                      SizedBox(
                        width: 94,
                        height: 94,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationZ(-math.pi / 2),
                          child: CircularProgressIndicator(
                            value: progressPercent == 0.0 ? 0.04 : progressPercent,
                            strokeWidth: 9.5,
                            strokeCap: StrokeCap.round,
                            valueColor: AlwaysStoppedAnimation<Color>(themeAccentColor),
                          ),
                        ),
                      ),
                      // Absolute Interior Display Metrics Text Wrapper
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currentCycleDay',
                            style: const TextStyle(
                              fontSize: 28, // Upscaled big text font size
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1A1A),
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${context.translate('day_label') ?? 'DAY'}'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 22),
                  
                  // Text Title Header Labels Block - Protected securely with Flexible constraints against horizontal screen overflow
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ultra-Bright Colored Capsule Phase Token Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: activeGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                details['emoji'],
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  details['title'].toString().toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          details['subtitle'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14, // Enlarged body subtitle for web-premium alignment balance
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              // Clean Divider layout splitter line
              Container(
                width: double.infinity,
                height: 1.2,
                color: const Color(0xFF7B35B5).withOpacity(0.09),
              ),
              const SizedBox(height: 22),

              // --- BOTTOM SECTION: DATA METRIC ITEMS TILES WITH OVERFLOW SAFE BOUNDS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildStatItem(
                      title: context.translate('cycle_length') ?? 'Cycle Length',
                      value: '$cycleLength',
                      subtitle: context.translate('days_unit') ?? 'days',
                      icon: Icons.loop_rounded,
                      iconColor: const Color(0xFF7B35B5),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      title: context.translate('period_duration') ?? 'Period Length',
                      value: '$periodLength',
                      subtitle: context.translate('days_unit') ?? 'days',
                      icon: Icons.water_drop_rounded,
                      iconColor: const Color(0xFFFF2A6D),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      title: context.translate('next_cycle') ?? 'Next Cycle',
                      value: '$daysRemaining',
                      subtitle: context.translate('days_left') ?? 'days left',
                      icon: Icons.hourglass_top_rounded,
                      iconColor: const Color(0xFF00E5FF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper builder generating modular metrics with flexible sizing constraints and safe baseline definitions
  Widget _buildStatItem({
    required String title, 
    required String value, 
    required String subtitle,
    required IconData icon, 
    required Color iconColor
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rounded High-Luminosity Token Background Container Frame
        Container(
          padding: const EdgeInsets.all(8), // Enlarged micro-frames
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.09),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 8),
        
        // Error-free alignment configuration utilizing alphabetic metrics explicitly
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic, // Crucial baseline configuration rule avoiding layout exception boxes
          children: [
            Text(
              value, 
              maxLines: 1,
              style: const TextStyle(
                fontSize: 18, // Bigger value parameters
                fontWeight: FontWeight.w900, 
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 1),
            Text(
              subtitle, 
              maxLines: 1,
              style: TextStyle(
                fontSize: 9, 
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          title, 
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11, 
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}