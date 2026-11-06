import 'package:flutter/widgets.dart';

class ResponsiveBreakpoints {
  const ResponsiveBreakpoints._();

  static const double mobileMax = 599.0;
  static const double tabletMax = 899.0;
  static const double desktopMin = 900.0;
  static const double wideDesktopMin = 1200.0;

  static bool isMobile(double width) => width <= mobileMax;
  static bool isTablet(double width) => width > mobileMax && width <= tabletMax;
  static bool isDesktop(double width) => width >= desktopMin;

  static bool isDesktopContext(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopMin;
}
