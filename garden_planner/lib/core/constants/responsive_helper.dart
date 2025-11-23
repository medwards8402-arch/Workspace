import 'package:flutter/material.dart';
import 'breakpoints.dart';

/// Responsive layout builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType, double width) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = getDeviceType(width);
        return builder(context, deviceType, width);
      },
    );
  }
}

/// Screen size extension methods
extension ScreenSizeHelper on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Get device type
  DeviceType get deviceType => getDeviceType(screenWidth);
  
  /// Check if mobile
  bool get isMobile => deviceType == DeviceType.mobile;
  
  /// Check if tablet
  bool get isTablet => deviceType == DeviceType.tablet;
  
  /// Check if desktop
  bool get isDesktop => deviceType == DeviceType.desktop;
  
  /// Get responsive value
  T responsive<T>(ResponsiveValue<T> value) {
    return value.getValue(deviceType);
  }
}
