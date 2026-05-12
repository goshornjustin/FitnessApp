/// Device and screen information utilities.
///
/// `DeviceInfo` is a static helper class for reading platform, screen size,
/// orientation, and device type at runtime. `DeviceScreenInfo` is the data
/// object returned by `DeviceInfo.getDeviceInfo()`.
///
/// Device type is determined by shortest-side breakpoint:
/// - Mobile: `< 600dp` → phone, `≥ 600dp` → tablet.
/// - Desktop platforms (macOS, Windows, Linux) are always `DeviceType.desktop`.
///
/// Use these helpers when building responsive layouts that need to behave
/// differently on phone vs tablet vs desktop.
library;

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

enum DeviceType {
  phone,
  tablet,
  desktop,
  unknown,
}

enum DevicePlatform {
  android,
  ios,
  macOS,
  windows,
  linux,
  web,
  unknown,
}

class DeviceScreenInfo {
  final Size screenSize;
  final double devicePixelRatio;
  final DeviceType deviceType;
  final DevicePlatform platform;
  final String deviceModel;
  final String osVersion;

  const DeviceScreenInfo({
    required this.screenSize,
    required this.devicePixelRatio,
    required this.deviceType,
    required this.platform,
    required this.deviceModel,
    required this.osVersion,
  });

  bool get isPhone => deviceType == DeviceType.phone;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
  bool get isMobile => isPhone || isTablet;
  
  bool get isAndroid => platform == DevicePlatform.android;
  bool get isIOS => platform == DevicePlatform.ios;
  bool get isMacOS => platform == DevicePlatform.macOS;
}

class DeviceInfo {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Get comprehensive device and screen information
  static Future<DeviceScreenInfo> getDeviceInfo(BuildContext context) async {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;
    final double devicePixelRatio = mediaQuery.devicePixelRatio;
    
    final DevicePlatform platform = _getCurrentPlatform();
    final DeviceType deviceType = _determineDeviceType(screenSize, platform);
    
    String deviceModel = 'Unknown';
    String osVersion = 'Unknown';

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceModel = '${androidInfo.brand} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceModel = iosInfo.model;
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      } else if (Platform.isMacOS) {
        final MacOsDeviceInfo macInfo = await _deviceInfoPlugin.macOsInfo;
        deviceModel = macInfo.model;
        osVersion = 'macOS ${macInfo.osRelease}';
      }
    } catch (e) {
      // Handle any errors in getting device info
      debugPrint('Error getting device info: $e');
    }

    return DeviceScreenInfo(
      screenSize: screenSize,
      devicePixelRatio: devicePixelRatio,
      deviceType: deviceType,
      platform: platform,
      deviceModel: deviceModel,
      osVersion: osVersion,
    );
  }

  /// Get current screen size from MediaQuery
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get device pixel ratio
  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get current platform
  static DevicePlatform _getCurrentPlatform() {
    if (Platform.isAndroid) {
      return DevicePlatform.android;
    } else if (Platform.isIOS) {
      return DevicePlatform.ios;
    } else if (Platform.isMacOS) {
      return DevicePlatform.macOS;
    } else if (Platform.isWindows) {
      return DevicePlatform.windows;
    } else if (Platform.isLinux) {
      return DevicePlatform.linux;
    } else {
      return DevicePlatform.unknown;
    }
  }

  /// Determine device type based on screen size and platform
  static DeviceType _determineDeviceType(Size screenSize, DevicePlatform platform) {
    final double width = screenSize.width;
    final double height = screenSize.height;
    final double shortestSide = width < height ? width : height;

    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.ios:
        // Mobile platforms
        if (shortestSide < 600) {
          return DeviceType.phone;
        } else {
          return DeviceType.tablet;
        }
      
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
      case DevicePlatform.linux:
        // Desktop platforms
        return DeviceType.desktop;
      
      default:
        return DeviceType.unknown;
    }
  }

  /// Check if current device is a phone
  static bool isPhone(BuildContext context) {
    final Size screenSize = getScreenSize(context);
    final DevicePlatform platform = _getCurrentPlatform();
    return _determineDeviceType(screenSize, platform) == DeviceType.phone;
  }

  /// Check if current device is a tablet
  static bool isTablet(BuildContext context) {
    final Size screenSize = getScreenSize(context);
    final DevicePlatform platform = _getCurrentPlatform();
    return _determineDeviceType(screenSize, platform) == DeviceType.tablet;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    final Size screenSize = getScreenSize(context);
    final DevicePlatform platform = _getCurrentPlatform();
    return _determineDeviceType(screenSize, platform) == DeviceType.desktop;
  }

  /// Check if current device is mobile (phone or tablet)
  static bool isMobile(BuildContext context) {
    return isPhone(context) || isTablet(context);
  }

  /// Get responsive breakpoints
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context).width < 600;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = getScreenSize(context).width;
    return width >= 600 && width < 1024;
  }

  static bool isLargeScreen(BuildContext context) {
    return getScreenSize(context).width >= 1024;
  }

  /// Platform-specific checks
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isMacOS => Platform.isMacOS;
  static bool get isWindows => Platform.isWindows;
  static bool get isLinux => Platform.isLinux;

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get system UI overlays (status bar, navigation bar)
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  /// Check if device has physical navigation buttons (Android)
  static bool hasPhysicalNavigationButtons(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return padding.bottom == 0 && Platform.isAndroid;
  }

  /// Get device orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check for specific iOS devices based on screen size
  static bool isIPhoneSE(BuildContext context) {
    if (!Platform.isIOS) return false;
    final Size screenSize = getScreenSize(context);
    return screenSize.width == 320 && screenSize.height == 568;
  }

  static bool isIPhone8(BuildContext context) {
    if (!Platform.isIOS) return false;
    final Size screenSize = getScreenSize(context);
    return screenSize.width == 375 && screenSize.height == 667;
  }

  static bool isIPhoneX(BuildContext context) {
    if (!Platform.isIOS) return false;
    final Size screenSize = getScreenSize(context);
    return screenSize.width == 375 && screenSize.height == 812;
  }

  static bool isIPad(BuildContext context) {
    if (!Platform.isIOS) return false;
    return isTablet(context);
  }
}
