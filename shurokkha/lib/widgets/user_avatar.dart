import 'dart:convert'; // Required for base64
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final String? overrideUrl;
  final String? overrideName;

  const UserAvatar({super.key, this.radius = 20, this.overrideUrl, this.overrideName});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final String? imageSource = overrideUrl ?? auth.profileImageUrl;
        final String name = (overrideName ?? auth.userName ?? "User").trim();
        final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "U";

        return CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
          child: ClipOval(
            child: _buildImage(imageSource, firstLetter),
          ),
        );
      },
    );
  }

  Widget _buildImage(String? source, String letter) {
    if (source == null || source.isEmpty) {
      return _buildFallback(letter);
    }

    // Logic: Check if it's a Base64 string or a Web URL
    if (source.startsWith('/') || !source.startsWith('http')) {
      // It's likely a Base64 string (starts with /9j/ or similar)
      try {
        return Image.memory(
          base64Decode(source),
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(letter),
        );
      } catch (e) {
        return _buildFallback(letter);
      }
    } else {
      // It's a standard Web URL
      return Image.network(
        source,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(letter),
      );
    }
  }

  Widget _buildFallback(String letter) {
    return Center(
      child: Text(
        letter,
        style: TextStyle(
          color: AppColors.primaryPurple,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}