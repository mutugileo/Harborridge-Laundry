import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/widgets/harborridge_logo.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class AuthPortalScreen extends ConsumerWidget {
  const AuthPortalScreen({super.key, this.onSignedInNavigate});

  final VoidCallback? onSignedInNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authSessionNotifierProvider);
    final authNotifier = ref.read(authSessionNotifierProvider.notifier);
    final colors = context.colors;
    final motion = context.motion;

    return Scaffold(
      backgroundColor: colors.harborNavy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _CatchyLaundryScenePainter()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900.0;

                if (isWide) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42.0,
                      vertical: 28.0,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 56,
                          child: _LeftBrandShowcasePanel(),
                        ),
                        const SizedBox(width: 32.0),
                        SizedBox(
                          width: 455.0,
                          child: _RightLoginFormCard(
                            authState: authState,
                            motion: motion,
                            onSelectWorker: authNotifier.selectPreviewWorker,
                            onSignInWithCredentials: (email, pin) {
                              final ok = authNotifier.signInWithEmailAndPin(
                                email: email,
                                pin: pin,
                              );
                              if (ok) {
                                onSignedInNavigate?.call();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const _LeftBrandShowcasePanel(isCompact: true),
                      const SizedBox(height: 24.0),
                      _RightLoginFormCard(
                        authState: authState,
                        motion: motion,
                        onSelectWorker: authNotifier.selectPreviewWorker,
                        onSignInWithCredentials: (email, pin) {
                          final ok = authNotifier.signInWithEmailAndPin(
                            email: email,
                            pin: pin,
                          );
                          if (ok) {
                            onSignedInNavigate?.call();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftBrandShowcasePanel extends StatelessWidget {
  const _LeftBrandShowcasePanel({this.isCompact = false});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCompact ? Alignment.centerLeft : Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x28070D1F),
              blurRadius: 24.0,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const HarborridgeLogo(isCompact: false),
      ),
    );
  }
}

class _RightLoginFormCard extends StatefulWidget {
  const _RightLoginFormCard({
    required this.authState,
    required this.motion,
    required this.onSelectWorker,
    required this.onSignInWithCredentials,
  });

  final AuthPortalState authState;
  final AppMotion motion;
  final ValueChanged<String> onSelectWorker;
  final void Function(String email, String pin) onSignInWithCredentials;

  @override
  State<_RightLoginFormCard> createState() => _RightLoginFormCardState();
}

class _RightLoginFormCardState extends State<_RightLoginFormCard> {
  late final TextEditingController _emailController;
  late final TextEditingController _pinController;
  bool _obscurePin = false;

  @override
  void initState() {
    super.initState();
    final preview = widget.authState.previewWorker;
    _emailController = TextEditingController(text: preview.email);
    _pinController = TextEditingController(text: preview.pin);
  }

  @override
  void didUpdateWidget(covariant _RightLoginFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPreview = widget.authState.previewWorker;
    final oldPreview = oldWidget.authState.previewWorker;
    if (newPreview.id != oldPreview.id || newPreview.pin != oldPreview.pin) {
      _emailController.text = newPreview.email;
      _pinController.text = newPreview.pin;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final authState = widget.authState;

    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40070D1F),
            blurRadius: 36.0,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: colors.freshSkyBlue.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(99.0),
                ),
                child: Text(
                  'EMAIL & PIN SIGN IN',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.harborNavy,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pin_outlined,
                    size: 16.0,
                    color: colors.accentGreen,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '4-Digit Security PIN',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.accentGreen,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Text(
            'Welcome to Harborridge Portal',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Enter your username or work email and 4-digit security PIN to sign in.',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12.0,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18.0),
          Text(
            'Username or Work Email',
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          SizedBox(
            height: 42.0,
            child: TextField(
              key: const ValueKey('login_email_input'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your staff username or work email',
                hintStyle: textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  color: colors.textTertiary,
                ),
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  size: 17.0,
                  color: colors.textSecondary,
                ),
                filled: true,
                fillColor: colors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: colors.freshSkyBlue,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          Text(
            'Security PIN',
            style: textTheme.labelSmall?.copyWith(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          SizedBox(
            height: 42.0,
            child: TextField(
              key: const ValueKey('login_pin_input'),
              controller: _pinController,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.0,
                color: colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your 4-digit security PIN',
                hintStyle: textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                  color: colors.textTertiary,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  size: 17.0,
                  color: colors.textSecondary,
                ),
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                  icon: Icon(
                    _obscurePin
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 16.0,
                    color: colors.textSecondary,
                  ),
                ),
                filled: true,
                fillColor: colors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: colors.freshSkyBlue,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: widget.motion.shortDuration,
            child: authState.errorMessage == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 9.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFFB91C1C),
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 18.0),
          SizedBox(
            width: double.infinity,
            child: InteractivePressScale(
              onTap: () => widget.onSignInWithCredentials(
                _emailController.text,
                _pinController.text,
              ),
              child: Container(
                key: const ValueKey('login_submit_button'),
                padding: const EdgeInsets.symmetric(vertical: 13.0),
                decoration: BoxDecoration(
                  color: colors.harborNavy,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 16.0,
                      color: colors.harborGold,
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        'Sign in with Email & PIN',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatchyLaundryScenePainter extends CustomPainter {
  const _CatchyLaundryScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bgRect = Offset.zero & size;
    canvas.drawRect(
      bgRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101B38), Color(0xFF152954), Color(0xFF124E8C)],
        ).createShader(bgRect),
    );

    final drumCenter = Offset(size.width * 0.34, size.height * 0.58);
    final drumRadius = (size.shortestSide * 0.28).clamp(110.0, 220.0);

    canvas.drawCircle(
      drumCenter,
      drumRadius * 1.35,
      Paint()..color = const Color(0x142DA1E7),
    );
    canvas.drawCircle(
      drumCenter,
      drumRadius,
      Paint()..color = const Color(0x24FFFFFF),
    );
    canvas.drawCircle(
      drumCenter,
      drumRadius * 0.82,
      Paint()
        ..color = const Color(0xFF0E2244)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      drumCenter,
      drumRadius * 0.82,
      Paint()
        ..color = const Color(0x662DA1E7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0,
    );

    final wavePath = Path()
      ..moveTo(drumCenter.dx - drumRadius * 0.75, drumCenter.dy + 10.0)
      ..quadraticBezierTo(
        drumCenter.dx - drumRadius * 0.35,
        drumCenter.dy - 28.0,
        drumCenter.dx,
        drumCenter.dy + 8.0,
      )
      ..quadraticBezierTo(
        drumCenter.dx + drumRadius * 0.35,
        drumCenter.dy + 42.0,
        drumCenter.dx + drumRadius * 0.75,
        drumCenter.dy - 4.0,
      );
    canvas.drawPath(
      wavePath,
      Paint()
        ..color = const Color(0x882DA1E7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round,
    );

    final bubbleRingPaint = Paint()
      ..color = const Color(0x382DA1E7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final bubbleFillPaint = Paint()
      ..color = const Color(0x142DA1E7)
      ..style = PaintingStyle.fill;

    final bubbles = <(Offset, double)>[
      (Offset(size.width * 0.14, size.height * 0.20), 34.0),
      (Offset(size.width * 0.22, size.height * 0.30), 18.0),
      (Offset(size.width * 0.48, size.height * 0.18), 42.0),
      (Offset(size.width * 0.54, size.height * 0.32), 22.0),
      (Offset(size.width * 0.44, size.height * 0.82), 29.0),
      (Offset(size.width * 0.88, size.height * 0.16), 36.0),
      (Offset(size.width * 0.92, size.height * 0.84), 26.0),
    ];
    for (final (center, r) in bubbles) {
      canvas.drawCircle(center, r, bubbleFillPaint);
      canvas.drawCircle(center, r, bubbleRingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
