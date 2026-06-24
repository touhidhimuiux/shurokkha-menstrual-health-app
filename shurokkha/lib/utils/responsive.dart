import 'package:flutter/material.dart';

/// Responsive utilities for handling different screen sizes
class ResponsiveUtil {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileMaxWidth) {
      return DeviceType.mobile;
    } else if (width < tabletMaxWidth) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get scaling factor based on screen width (1.0 = 375 width baseline)
  static double getScaleFactor(BuildContext context) {
    final width = screenWidth(context);
    return width / 375.0; // iPhone 12/13 baseline width
  }

  /// Get responsive font size
  static double responsiveFontSize({
    required BuildContext context,
    double mobileSize = 14,
    double tabletSize = 16,
    double desktopSize = 18,
  }) {
    final deviceType = getDeviceType(context);
    final scaleFactor = getScaleFactor(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileSize * scaleFactor;
      case DeviceType.tablet:
        return tabletSize * scaleFactor;
      case DeviceType.desktop:
        return desktopSize * scaleFactor;
    }
  }

  /// Get responsive padding
  static double responsivePadding({
    required BuildContext context,
    double mobilePadding = 12,
    double tabletPadding = 16,
    double desktopPadding = 20,
  }) {
    final deviceType = getDeviceType(context);
    final scaleFactor = getScaleFactor(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobilePadding * scaleFactor;
      case DeviceType.tablet:
        return tabletPadding * scaleFactor;
      case DeviceType.desktop:
        return desktopPadding * scaleFactor;
    }
  }

  /// Get responsive height
  static double responsiveHeight({
    required BuildContext context,
    double mobileHeight = 200,
    double tabletHeight = 250,
    double desktopHeight = 300,
  }) {
    final deviceType = getDeviceType(context);
    final scaleFactor = getScaleFactor(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileHeight * scaleFactor;
      case DeviceType.tablet:
        return tabletHeight * scaleFactor;
      case DeviceType.desktop:
        return desktopHeight * scaleFactor;
    }
  }

  /// Get responsive width
  static double responsiveWidth({
    required BuildContext context,
    double mobileWidth = 160,
    double tabletWidth = 200,
    double desktopWidth = 250,
  }) {
    final deviceType = getDeviceType(context);
    final scaleFactor = getScaleFactor(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileWidth * scaleFactor;
      case DeviceType.tablet:
        return tabletWidth * scaleFactor;
      case DeviceType.desktop:
        return desktopWidth * scaleFactor;
    }
  }

  /// Get GridView cross axis count based on screen size
  static int getGridCrossAxisCount(BuildContext context) {
    final width = screenWidth(context);
    
    if (width < 400) {
      return 2; // Small phones
    } else if (width < 600) {
      return 2; // Regular phones
    } else if (width < 900) {
      return 3; // Tablets
    } else {
      return 4; // Large tablets/desktops
    }
  }

  /// Get responsive border radius
  static double responsiveBorderRadius({
    required BuildContext context,
    double mobileRadius = 12,
    double tabletRadius = 16,
    double desktopRadius = 20,
  }) {
    final deviceType = getDeviceType(context);
    final scaleFactor = getScaleFactor(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileRadius * scaleFactor;
      case DeviceType.tablet:
        return tabletRadius * scaleFactor;
      case DeviceType.desktop:
        return desktopRadius * scaleFactor;
    }
  }

  /// Get responsive icon size
  static double responsiveIconSize({
    required BuildContext context,
    double mobileSize = 20,
    double tabletSize = 24,
    double desktopSize = 28,
  }) {
    final deviceType = getDeviceType(context);
    final scaleFactor = getScaleFactor(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileSize * scaleFactor;
      case DeviceType.tablet:
        return tabletSize * scaleFactor;
      case DeviceType.desktop:
        return desktopSize * scaleFactor;
    }
  }

  /// Get responsive spacer height
  static double responsiveSpacing({
    required BuildContext context,
    double mobileSpacing = 8,
    double tabletSpacing = 12,
    double desktopSpacing = 16,
  }) {
    final deviceType = getDeviceType(context);
    final scaleFactor = getScaleFactor(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileSpacing * scaleFactor;
      case DeviceType.tablet:
        return tabletSpacing * scaleFactor;
      case DeviceType.desktop:
        return desktopSpacing * scaleFactor;
    }
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get responsive layout padding (horizontal)
  static EdgeInsets responsiveLayoutPadding(BuildContext context) {
    final width = screenWidth(context);
    
    if (width < 400) {
      return const EdgeInsets.symmetric(horizontal: 12);
    } else if (width < 600) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (width < 900) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  /// Get max content width for tablets/desktops
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 600;
      case DeviceType.desktop:
        return 900;
    }
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Extension for easier access in widgets
extension ResponsiveExtension on BuildContext {
  double get screenWidth => ResponsiveUtil.screenWidth(this);
  double get screenHeight => ResponsiveUtil.screenHeight(this);
  double get scaleFactor => ResponsiveUtil.getScaleFactor(this);
  DeviceType get deviceType => ResponsiveUtil.getDeviceType(this);
  bool get isLandscape => ResponsiveUtil.isLandscape(this);

  /// Responsive font size shortcut
  double responsiveFontSize({
    double mobileSize = 14,
    double tabletSize = 16,
    double desktopSize = 18,
  }) {
    return ResponsiveUtil.responsiveFontSize(
      context: this,
      mobileSize: mobileSize,
      tabletSize: tabletSize,
      desktopSize: desktopSize,
    );
  }

  /// Responsive padding shortcut
  double responsivePadding({
    double mobilePadding = 12,
    double tabletPadding = 16,
    double desktopPadding = 20,
  }) {
    return ResponsiveUtil.responsivePadding(
      context: this,
      mobilePadding: mobilePadding,
      tabletPadding: tabletPadding,
      desktopPadding: desktopPadding,
    );
  }

  /// Responsive spacing shortcut
  double responsiveSpacing({
    double mobileSpacing = 8,
    double tabletSpacing = 12,
    double desktopSpacing = 16,
  }) {
    return ResponsiveUtil.responsiveSpacing(
      context: this,
      mobileSpacing: mobileSpacing,
      tabletSpacing: tabletSpacing,
      desktopSpacing: desktopSpacing,
    );
  }

  /// Responsive width shortcut
  double responsiveWidth({
    double mobileWidth = 160,
    double tabletWidth = 200,
    double desktopWidth = 250,
  }) {
    return ResponsiveUtil.responsiveWidth(
      context: this,
      mobileWidth: mobileWidth,
      tabletWidth: tabletWidth,
      desktopWidth: desktopWidth,
    );
  }

  /// Responsive height shortcut
  double responsiveHeight({
    double mobileHeight = 200,
    double tabletHeight = 250,
    double desktopHeight = 300,
  }) {
    return ResponsiveUtil.responsiveHeight(
      context: this,
      mobileHeight: mobileHeight,
      tabletHeight: tabletHeight,
      desktopHeight: desktopHeight,
    );
  }

  /// Responsive icon size shortcut
  double responsiveIconSize({
    double mobileSize = 20,
    double tabletSize = 24,
    double desktopSize = 28,
  }) {
    return ResponsiveUtil.responsiveIconSize(
      context: this,
      mobileSize: mobileSize,
      tabletSize: tabletSize,
      desktopSize: desktopSize,
    );
  }

  /// Responsive size (for both width and height - typically for square elements)
  double responsiveSize({
    double mobileSize = 100,
    double tabletSize = 120,
    double desktopSize = 140,
  }) {
    return ResponsiveUtil.responsiveWidth(
      context: this,
      mobileWidth: mobileSize,
      tabletWidth: tabletSize,
      desktopWidth: desktopSize,
    );
  }

  /// Responsive border radius shortcut
  double responsiveBorderRadius({
    double mobileRadius = 12,
    double tabletRadius = 16,
    double desktopRadius = 20,
  }) {
    return ResponsiveUtil.responsiveBorderRadius(
      context: this,
      mobileRadius: mobileRadius,
      tabletRadius: tabletRadius,
      desktopRadius: desktopRadius,
    );
  }
}
