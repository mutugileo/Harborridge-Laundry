import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/core/auth/auth_backend.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

Future<void> showChangeWorkerPinDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => const ChangeWorkerPinDialog(),
  );
}

class ChangeWorkerPinDialog extends ConsumerStatefulWidget {
  const ChangeWorkerPinDialog({super.key});

  @override
  ConsumerState<ChangeWorkerPinDialog> createState() =>
      _ChangeWorkerPinDialogState();
}

class _ChangeWorkerPinDialogState extends ConsumerState<ChangeWorkerPinDialog> {
  late final TextEditingController _currentPinController;
  late final TextEditingController _newPinController;
  late final TextEditingController _confirmPinController;

  late final TextEditingController _current4DigitPinController;
  late final TextEditingController _new4DigitPinController;

  int _selectedTab = 0; // 0 = Password, 1 = 4-Digit Quick PIN
  String? _feedbackMessage;
  bool _isSuccess = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentPinController = TextEditingController();
    _newPinController = TextEditingController();
    _confirmPinController = TextEditingController();
    _current4DigitPinController = TextEditingController();
    _new4DigitPinController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _current4DigitPinController.dispose();
    _new4DigitPinController.dispose();
    super.dispose();
  }

  Future<void> _submit4DigitPinChange() async {
    if (_isSubmitting) return;
    final current = _current4DigitPinController.text.trim();
    final next = _new4DigitPinController.text.trim();

    if (!RegExp(r'^\d{4}$').hasMatch(current)) {
      setState(() {
        _isSuccess = false;
        _feedbackMessage = 'Current PIN must be 4 digits.';
      });
      return;
    }
    if (!RegExp(r'^\d{4}$').hasMatch(next)) {
      setState(() {
        _isSuccess = false;
        _feedbackMessage = 'New PIN must be 4 digits.';
      });
      return;
    }

    setState(() => _isSubmitting = true);
    final (ok, message) = await ref
        .read(authSessionNotifierProvider.notifier)
        .changeOwnPin(currentPin: current, newPin: next);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _isSuccess = ok;
      _feedbackMessage = message;
    });

    if (ok) {
      _current4DigitPinController.clear();
      _new4DigitPinController.clear();
    }
  }

  Future<void> _submitPinChange() async {
    if (_isSubmitting) return;
    final currentPin = _currentPinController.text;
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;

    if (currentPin.isEmpty) {
      setState(() {
        _isSuccess = false;
        _feedbackMessage = 'Enter your current password.';
      });
      return;
    }
    if (newPin.length < kMinStaffPasswordLength) {
      setState(() {
        _isSuccess = false;
        _feedbackMessage =
            'New password must be at least $kMinStaffPasswordLength characters.';
      });
      return;
    }
    if (newPin != confirmPin) {
      setState(() {
        _isSuccess = false;
        _feedbackMessage =
            'New password and confirmation do not match. Re-enter both fields.';
      });
      return;
    }

    setState(() => _isSubmitting = true);
    final (ok, message) = await ref
        .read(authSessionNotifierProvider.notifier)
        .changeOwnPassword(currentPassword: currentPin, newPassword: newPin);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _isSuccess = ok;
      _feedbackMessage = message;
    });

    if (ok) {
      _currentPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionNotifierProvider);
    final worker = authState.currentWorker;
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: colors.freshSkyBlue.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: colors.harborNavy,
                      size: 20.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change My Password',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          '${worker.fullName} • ${worker.email}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11.0,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18.0,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
              Row(
                children: [
                  Expanded(
                    child: InteractivePressScale(
                      onTap: () => setState(() {
                        _selectedTab = 0;
                        _feedbackMessage = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? colors.harborNavy
                              : colors.background,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: _selectedTab == 0
                                ? colors.harborNavy
                                : colors.borderSubtle,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Account Password',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: _selectedTab == 0
                                ? Colors.white
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: InteractivePressScale(
                      onTap: () => setState(() {
                        _selectedTab = 1;
                        _feedbackMessage = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? colors.harborNavy
                              : colors.background,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: _selectedTab == 1
                                ? colors.harborNavy
                                : colors.borderSubtle,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '4-Digit Quick PIN',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: _selectedTab == 1
                                ? Colors.white
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
              if (_selectedTab == 0) ...[
                _PinDialogField(
                  key: const ValueKey('change_pin_current_input'),
                  label: 'Current Password',
                  hintText: 'Enter your current password',
                  controller: _currentPinController,
                ),
                const SizedBox(height: 12.0),
                _PinDialogField(
                  key: const ValueKey('change_pin_new_input'),
                  label: 'New Password',
                  hintText: 'At least $kMinStaffPasswordLength characters',
                  controller: _newPinController,
                ),
                const SizedBox(height: 12.0),
                _PinDialogField(
                  key: const ValueKey('change_pin_confirm_input'),
                  label: 'Confirm New Password',
                  hintText: 'Re-enter your new password',
                  controller: _confirmPinController,
                ),
              ] else ...[
                _PinDialogField(
                  key: const ValueKey('change_4digit_pin_current_input'),
                  label: 'Current 4-Digit PIN',
                  hintText: 'Enter current 4-digit PIN (default: 1234)',
                  controller: _current4DigitPinController,
                ),
                const SizedBox(height: 12.0),
                _PinDialogField(
                  key: const ValueKey('change_4digit_pin_new_input'),
                  label: 'New 4-Digit PIN',
                  hintText: 'Enter new 4-digit PIN for rapid unlock',
                  controller: _new4DigitPinController,
                ),
              ],
              AnimatedSwitcher(
                duration: motion.shortDuration,
                child: _feedbackMessage == null
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
                            color: _isSuccess
                                ? const Color(0xFFE6F8EF)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            _feedbackMessage!,
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: _isSuccess
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 18.0),
              Row(
                children: [
                  Expanded(
                    child: InteractivePressScale(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11.0),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: colors.borderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Close',
                          style: textTheme.labelMedium?.copyWith(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 2,
                    child: InteractivePressScale(
                      onTap: _selectedTab == 0
                          ? _submitPinChange
                          : _submit4DigitPinChange,
                      child: Container(
                        key: const ValueKey('submit_change_pin_button'),
                        padding: const EdgeInsets.symmetric(vertical: 11.0),
                        decoration: BoxDecoration(
                          color: colors.harborNavy,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isSubmitting
                              ? 'Updating…'
                              : (_selectedTab == 0
                                    ? 'Update Password'
                                    : 'Update 4-Digit PIN'),
                          style: textTheme.labelMedium?.copyWith(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDialogField extends StatelessWidget {
  const _PinDialogField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontSize: 11.0,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 5.0),
        SizedBox(
          height: 40.0,
          child: TextField(
            controller: controller,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: textTheme.bodySmall?.copyWith(
                fontSize: 11.0,
                letterSpacing: 0.0,
                color: colors.textTertiary,
              ),
              filled: true,
              fillColor: colors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: colors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: colors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: colors.freshSkyBlue, width: 1.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
