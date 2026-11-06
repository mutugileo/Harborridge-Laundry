import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';

enum SharedAxisMotionKind { peerFeature, verticalSubflow, portalBoundary }

class SharedAxisPageTransition extends StatelessWidget {
  const SharedAxisPageTransition({
    super.key,
    required this.child,
    this.kind = SharedAxisMotionKind.peerFeature,
    this.direction = 1,
  });

  factory SharedAxisPageTransition.peerFeature({
    Key? key,
    required Widget child,
    int direction = 1,
  }) {
    return SharedAxisPageTransition(
      key: key,
      kind: SharedAxisMotionKind.peerFeature,
      direction: direction,
      child: child,
    );
  }

  factory SharedAxisPageTransition.verticalSubflow({
    Key? key,
    required Widget child,
    required bool isDrillingIn,
  }) {
    return SharedAxisPageTransition(
      key: key,
      kind: SharedAxisMotionKind.verticalSubflow,
      direction: isDrillingIn ? 1 : -1,
      child: child,
    );
  }

  factory SharedAxisPageTransition.portal({Key? key, required Widget child}) {
    return SharedAxisPageTransition(
      key: key,
      kind: SharedAxisMotionKind.portalBoundary,
      child: child,
    );
  }

  final Widget child;
  final SharedAxisMotionKind kind;
  final int direction;

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;

    if (kind == SharedAxisMotionKind.portalBoundary) {
      return TweenAnimationBuilder<double>(
        key: child.key,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: motion.mediumDuration,
        curve: motion.emphasizedCurve,
        builder: (context, value, currentChild) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0.0, (1.0 - value) * 10.0),
              child: currentChild,
            ),
          );
        },
        child: child,
      );
    }

    final duration = motion.mediumDuration;

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: motion.emphasizedCurve,
      switchOutCurve: motion.standardCurve,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (widget, animation) {
        final isIncoming = widget.key == child.key;
        final sign = direction >= 0 ? 1.0 : -1.0;

        switch (kind) {
          case SharedAxisMotionKind.peerFeature:
            final beginOffset = isIncoming
                ? Offset(0.024 * sign, 0.010 * sign)
                : Offset(-0.016 * sign, -0.006 * sign);
            final slide = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: widget),
            );

          case SharedAxisMotionKind.verticalSubflow:
            final beginOffset = isIncoming
                ? Offset(0.0, 0.042 * sign)
                : Offset(0.0, -0.025 * sign);
            final slide = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: widget),
            );

          case SharedAxisMotionKind.portalBoundary:
            return FadeTransition(opacity: animation, child: widget);
        }
      },
      child: child,
    );
  }
}

class StateFeedbackTransition extends StatelessWidget {
  const StateFeedbackTransition({
    super.key,
    required this.child,
    required this.isErrorState,
    required this.isLoadingState,
  });

  final Widget child;
  final bool isErrorState;
  final bool isLoadingState;

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;

    return AnimatedSwitcher(
      duration: isErrorState
          ? motion.emphasizedDuration
          : motion.mediumDuration,
      switchInCurve: isErrorState ? Curves.easeOutBack : motion.emphasizedCurve,
      switchOutCurve: motion.standardCurve,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (widget, animation) {
        if (isErrorState) {
          final slide = Tween<Offset>(
            begin: const Offset(0.0, -0.035),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: widget),
          );
        }
        if (isLoadingState) {
          return FadeTransition(opacity: animation, child: widget);
        }
        final slide = Tween<Offset>(
          begin: const Offset(0.0, 0.025),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: widget),
        );
      },
      child: child,
    );
  }
}
