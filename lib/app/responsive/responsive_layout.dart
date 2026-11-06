import 'package:flutter/widgets.dart';
import 'package:laundry_ridge/app/responsive/responsive_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveBreakpoints.isDesktop(constraints.maxWidth)) {
          return desktop;
        }
        if (ResponsiveBreakpoints.isTablet(constraints.maxWidth)) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
