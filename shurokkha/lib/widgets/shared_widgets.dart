import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Gradient background wrapper
/// Gradient background wrapper
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({super.key, required this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,   // 🔥 Forces full width
      height: double.infinity,  // 🔥 Forces full height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors ??
              const [
                Color(0xFFEDD9FF),
                Color(0xFFF5E6FF),
                Color(0xFFFFE6F5),
                Color(0xFFE8D5FF),
              ],
        ),
      ),
      child: child,
    );
  }
}

/// Purple gradient button
class PurpleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const PurpleButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: Colors.white, size: 20),
            ]
          ],
        ),
      ),
    );
  }
}

/// Privacy footer
class PrivacyFooter extends StatelessWidget {
  const PrivacyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline, size: 14, color: AppColors.textGrey),
        const SizedBox(width: 5),
        Text(
          '100% Private & ',
          style: TextStyle(fontSize: 13, color: AppColors.textGrey),
        ),
        Text(
          'Offline',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Bottom nav bar
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: Colors.grey.shade400,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.home_outlined, 0 == currentIndex),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.calendar_today_outlined, 1 == currentIndex),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.chat_outlined, 2 == currentIndex),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.shopping_bag_outlined, 3 == currentIndex),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.people_outline, 4 == currentIndex),
            label: 'Community',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: isSelected
          ? BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Icon(
        icon,
        size: isSelected ? 26 : 24,
      ),
    );
  }
}

/// App bar with avatar
class ShurokkhaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final List<Widget>? actions;
  final Widget? leading;
  final String? title;

  const ShurokkhaAppBar({
    super.key,
    required this.name,
    this.actions,
    this.leading,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading ??
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: AppColors.mediumPink,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            )
          : RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const TextSpan(
                    text: '\nShurokkha',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

/// Glassy card widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;

  const GlassCard({super.key, required this.child, this.padding, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}