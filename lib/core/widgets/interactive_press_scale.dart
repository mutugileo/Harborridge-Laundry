import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';

class InteractivePressScale extends StatefulWidget {
  const InteractivePressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDownTarget = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleDownTarget;

  @override
  State<InteractivePressScale> createState() => _InteractivePressScaleState();
}

class _InteractivePressScaleState extends State<InteractivePressScale> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDownTarget : 1.0,
        duration: motion.shortDuration,
        curve: motion.standardCurve,
        child: widget.child,
      ),
    );
  }
}
