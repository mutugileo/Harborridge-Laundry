import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
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

  String? _feedbackMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _currentPinController = TextEditingController();
    _newPinController = TextEditingController();
    _confirmPinController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _submitPinChange() {
    final currentPin = _currentPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin != confirmPin) {
      setState(() {
        _isSuccess = false;
        _feedbackMessage =
            'New PIN and confirmation PIN do not match. Re-enter both fields.';
      });
      return;
    }

    final (ok, message) = ref
        .read(authSessionNotifierProvider.notifier)
        .changeCurrentWorkerPin(currentPin: currentPin, newPin: newPin);

    setState(() {
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
                      Icons.pin_outlined,
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
                          'Change My Security PIN',
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
              const SizedBox(height: 16.0),
              _PinDialogField(
                key: const ValueKey('change_pin_current_input'),
                label: 'Current Security PIN',
                hintText: 'Enter your current 4-digit PIN',
                controller: _currentPinController,
              ),
              const SizedBox(height: 12.0),
              _PinDialogField(
                key: const ValueKey('change_pin_new_input'),
                label: 'New Security PIN',
                hintText: 'At least 4 digits for your new PIN',
                controller: _newPinController,
              ),
              const SizedBox(height: 12.0),
              _PinDialogField(
                key: const ValueKey('change_pin_confirm_input'),
                label: 'Confirm New Security PIN',
                hintText: 'Re-enter your new security PIN',
                controller: _confirmPinController,
              ),
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
                      onTap: _submitPinChange,
                      child: Container(
                        key: const ValueKey('submit_change_pin_button'),
                        padding: const EdgeInsets.symmetric(vertical: 11.0),
                        decoration: BoxDecoration(
                          color: colors.harborNavy,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Update Security PIN',
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
            keyboardType: TextInputType.number,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
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
