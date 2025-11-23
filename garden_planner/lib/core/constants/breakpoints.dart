/// Screen size breakpoints for responsive design
class Breakpoints {
  /// Extra small devices (phones, less than 600px)
  static const double xs = 0;
  
  /// Small devices (phones, 600px and up)
  static const double sm = 600;
  
  /// Medium devices (tablets, 840px and up)
  static const double md = 840;
  
  /// Large devices (desktop, 1024px and up)
  static const double lg = 1024;
  
  /// Extra large devices (large desktop, 1280px and up)
  static const double xl = 1280;
  
  /// XXL devices (very large desktop, 1440px and up)
  static const double xxl = 1440;
}

/// Device types based on screen size
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Helper to determine device type
DeviceType getDeviceType(double width) {
  if (width < Breakpoints.md) return DeviceType.mobile;
  if (width < Breakpoints.lg) return DeviceType.tablet;
  return DeviceType.desktop;
}

/// Responsive values helper
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}
