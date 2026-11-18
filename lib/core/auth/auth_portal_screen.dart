import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/auth/quick_pin_service.dart';
import 'package:laundry_ridge/core/widgets/harborridge_logo.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class AuthPortalScreen extends ConsumerStatefulWidget {
  const AuthPortalScreen({super.key, this.onSignedInNavigate});

  final VoidCallback? onSignedInNavigate;

  @override
  ConsumerState<AuthPortalScreen> createState() => _AuthPortalScreenState();
}

class _AuthPortalScreenState extends ConsumerState<AuthPortalScreen> {
  RememberedWorkerProfile? _rememberedWorker;
  bool _isLoadingRemembered = true;

  @override
  void initState() {
    super.initState();
    _checkRememberedWorker();
  }

  Future<void> _checkRememberedWorker() async {
    final quickPinService = ref.read(quickPinServiceProvider);
    final worker = await quickPinService.getRememberedWorker();
    if (mounted) {
      setState(() {
        _rememberedWorker = worker;
        _isLoadingRemembered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionNotifierProvider);
    final authNotifier = ref.read(authSessionNotifierProvider.notifier);
    final colors = context.colors;
    final motion = context.motion;

    Future<void> signInWithCredentials({
      required String email,
      required String password,
      required String pin,
    }) async {
      final ok = await authNotifier.signIn(
        email: email,
        password: password,
        pin: pin,
      );
      if (ok) {
        widget.onSignedInNavigate?.call();
      } else {
        await _checkRememberedWorker();
      }
    }

    Future<void> signInWithPin(String pin) async {
      final ok = await authNotifier.signInWithQuickPin(pin);
      if (ok) {
        widget.onSignedInNavigate?.call();
      }
    }

    Future<void> switchWorkerAccount() async {
      final quickPinService = ref.read(quickPinServiceProvider);
      await quickPinService.clearRememberedWorker();
      await _checkRememberedWorker();
    }

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
                            rememberedWorker: _rememberedWorker,
                            isLoadingRemembered: _isLoadingRemembered,
                            onSignInWithCredentials: signInWithCredentials,
                            onSignInWithPin: signInWithPin,
                            onSwitchWorkerAccount: switchWorkerAccount,
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
                        rememberedWorker: _rememberedWorker,
                        isLoadingRemembered: _isLoadingRemembered,
                        onSignInWithCredentials: signInWithCredentials,
                        onSignInWithPin: signInWithPin,
                        onSwitchWorkerAccount: switchWorkerAccount,
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
    required this.rememberedWorker,
    required this.isLoadingRemembered,
    required this.onSignInWithCredentials,
    required this.onSignInWithPin,
    required this.onSwitchWorkerAccount,
  });

  final AuthPortalState authState;
  final AppMotion motion;
  final RememberedWorkerProfile? rememberedWorker;
  final bool isLoadingRemembered;
  final Future<void> Function({
    required String email,
    required String password,
    required String pin,
  })
  onSignInWithCredentials;
  final Future<void> Function(String pin) onSignInWithPin;
  final Future<void> Function() onSwitchWorkerAccount;

  @override
  State<_RightLoginFormCard> createState() => _RightLoginFormCardState();
}

class _RightLoginFormCardState extends State<_RightLoginFormCard> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _setupPinController = TextEditingController(
    text: '1234',
  );
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _forceEmailMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _setupPinController.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  bool get _isPinMode => widget.rememberedWorker != null && !_forceEmailMode;

  Future<void> _submitCredentials() async {
    if (widget.authState.isBusy || widget.authState.isRestoring) return;
    await widget.onSignInWithCredentials(
      email: _emailController.text,
      password: _passwordController.text,
      pin: _setupPinController.text.trim().isEmpty
          ? '1234'
          : _setupPinController.text.trim(),
    );
    if (mounted) _passwordController.clear();
  }

  Future<void> _submitPin([String? explicitPin]) async {
    if (widget.authState.isBusy || widget.authState.isRestoring) return;
    final pin = (explicitPin ?? _pinController.text).trim();
    if (pin.length != 4) return;
    await widget.onSignInWithPin(pin);
    if (mounted) {
      _pinController.clear();
      _pinFocusNode.requestFocus();
    }
  }

  void _onKeypadTap(String value) {
    if (widget.authState.isBusy) return;
    final current = _pinController.text;
    if (value == 'C') {
      _pinController.clear();
      setState(() {});
      return;
    }
    if (value == 'BACK') {
      if (current.isNotEmpty) {
        _pinController.text = current.substring(0, current.length - 1);
        setState(() {});
      }
      return;
    }
    if (current.length < 4) {
      final updated = current + value;
      _pinController.text = updated;
      setState(() {});
      if (updated.length == 4) {
        _submitPin(updated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final authState = widget.authState;
    final isPinMode = _isPinMode;
    final worker = widget.rememberedWorker;

    return Container(
      padding: const EdgeInsets.all(26.0),
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
      child: AnimatedSwitcher(
        duration: widget.motion.shortDuration,
        child: isPinMode && worker != null
            ? _buildSubsequentPinForm(colors, textTheme, authState, worker)
            : _buildCredentialsForm(colors, textTheme, authState),
      ),
    );
  }

  Widget _buildSubsequentPinForm(
    AppColors colors,
    TextTheme textTheme,
    AuthPortalState authState,
    RememberedWorkerProfile worker,
  ) {
    final pinLength = _pinController.text.length;

    return Column(
      key: const ValueKey('subsequent_pin_form_view'),
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
                'QUICK STAFF UNLOCK',
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
                  Icons.lock_clock_outlined,
                  size: 15.0,
                  color: colors.accentGreen,
                ),
                const SizedBox(width: 4.0),
                Text(
                  'Terminal Locked',
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

        // Staff profile card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.freshSkyBlue, colors.harborNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  worker.initials,
                  style: textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.0,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.fullName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.0,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '${worker.roleTitle} • ${worker.branch}',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),

        Text(
          'Enter 4-Digit Security PIN',
          style: textTheme.labelSmall?.copyWith(
            fontSize: 12.0,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Fast unlock for current terminal station.',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11.0,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 14.0),

        // 4 PIN visual boxes
        GestureDetector(
          onTap: () => _pinFocusNode.requestFocus(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isEntered = index < pinLength;
              final isCurrent = index == pinLength;

              return Container(
                width: 52.0,
                height: 54.0,
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isCurrent
                        ? colors.freshSkyBlue
                        : (isEntered ? colors.harborNavy : colors.borderSubtle),
                    width: isCurrent ? 2.0 : 1.2,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: colors.freshSkyBlue.withValues(alpha: 0.2),
                            blurRadius: 8.0,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: isEntered
                    ? Container(
                        width: 14.0,
                        height: 14.0,
                        decoration: BoxDecoration(
                          color: colors.harborNavy,
                          shape: BoxShape.circle,
                        ),
                      )
                    : (isCurrent
                          ? Container(
                              width: 2.0,
                              height: 18.0,
                              color: colors.freshSkyBlue,
                            )
                          : null),
              );
            }),
          ),
        ),

        // Hidden input for keyboard typing
        Opacity(
          opacity: 0.0,
          child: SizedBox(
            height: 0.0,
            child: TextField(
              key: const ValueKey('login_pin_input'),
              controller: _pinController,
              focusNode: _pinFocusNode,
              keyboardType: TextInputType.number,
              maxLength: 4,
              autofocus: true,
              onChanged: (val) {
                setState(() {});
                if (val.length == 4) _submitPin(val);
              },
            ),
          ),
        ),

        // Touch keypad
        const SizedBox(height: 12.0),
        _buildTouchKeypad(colors, textTheme),

        // Error message banner
        AnimatedSwitcher(
          duration: widget.motion.shortDuration,
          child: authState.errorMessage == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
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
        const SizedBox(height: 14.0),

        // Unlock Button
        SizedBox(
          width: double.infinity,
          child: InteractivePressScale(
            onTap: () => _submitPin(),
            child: Container(
              key: const ValueKey('login_pin_submit_button'),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: colors.harborNavy,
                borderRadius: BorderRadius.circular(10.0),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_open_rounded,
                    size: 16.0,
                    color: colors.harborGold,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    authState.isBusy || authState.isRestoring
                        ? 'Verifying PIN…'
                        : 'Unlock Terminal',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),

        // Switch to Email Login
        Center(
          child: TextButton(
            key: const ValueKey('switch_to_email_login_button'),
            onPressed: () {
              setState(() {
                _forceEmailMode = true;
              });
            },
            child: Text(
              'Switch Staff Member • Use Email & Password',
              style: textTheme.labelSmall?.copyWith(
                color: colors.freshSkyBlue,
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTouchKeypad(AppColors colors, TextTheme textTheme) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', 'BACK'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              final isSpecial = key == 'C' || key == 'BACK';

              return Container(
                width: 68.0,
                height: 40.0,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: InteractivePressScale(
                  onTap: () => _onKeypadTap(key),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSpecial
                          ? colors.background
                          : colors.cardBackground,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    alignment: Alignment.center,
                    child: key == 'BACK'
                        ? Icon(
                            Icons.backspace_outlined,
                            size: 16.0,
                            color: colors.textPrimary,
                          )
                        : Text(
                            key,
                            style: textTheme.titleSmall?.copyWith(
                              fontSize: isSpecial ? 13.0 : 16.0,
                              fontWeight: FontWeight.w700,
                              color: isSpecial
                                  ? colors.textSecondary
                                  : colors.textPrimary,
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCredentialsForm(
    AppColors colors,
    TextTheme textTheme,
    AuthPortalState authState,
  ) {
    return Column(
      key: const ValueKey('credentials_login_form_view'),
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
                'STAFF SIGN IN',
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
                  Icons.verified_user_outlined,
                  size: 16.0,
                  color: colors.accentGreen,
                ),
                const SizedBox(width: 4.0),
                Text(
                  'Staff accounts only',
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
          'Enter your work email and password to sign in.',
          style: textTheme.bodySmall?.copyWith(
            fontSize: 12.0,
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          'Work Email',
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
            autocorrect: false,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            style: textTheme.bodySmall?.copyWith(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'you@harborridge.co.ke',
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
                borderSide: BorderSide(color: colors.freshSkyBlue, width: 1.4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          'Password',
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
            key: const ValueKey('login_password_input'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _submitCredentials(),
            style: textTheme.bodySmall?.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
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
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
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
                borderSide: BorderSide(color: colors.freshSkyBlue, width: 1.4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12.0),

        // 4-Digit Quick PIN Setup Field
        Text(
          'Quick Unlock PIN (4 digits)',
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
            key: const ValueKey('login_setup_pin_input'),
            controller: _setupPinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '1234 (Used for subsequent 4-digit PIN logins)',
              hintStyle: textTheme.bodySmall?.copyWith(
                fontSize: 11.0,
                letterSpacing: 0.0,
                color: colors.textTertiary,
              ),
              prefixIcon: Icon(
                Icons.pin_outlined,
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
                borderSide: BorderSide(color: colors.freshSkyBlue, width: 1.4),
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
        const SizedBox(height: 16.0),

        SizedBox(
          width: double.infinity,
          child: InteractivePressScale(
            onTap: _submitCredentials,
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
                      authState.isBusy || authState.isRestoring
                          ? 'Signing in…'
                          : 'Sign in',
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

        if (widget.rememberedWorker != null) ...[
          const SizedBox(height: 8.0),
          Center(
            child: TextButton(
              key: const ValueKey('switch_to_pin_login_button'),
              onPressed: () => setState(() => _forceEmailMode = false),
              child: Text(
                'Back to 4-Digit Quick PIN Unlock',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.freshSkyBlue,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
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
