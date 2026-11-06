import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/core/auth/auth_session.dart';
import 'package:laundry_ridge/core/auth/change_pin_dialog.dart';
import 'package:laundry_ridge/core/widgets/interactive_press_scale.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key, this.onSignOutRequested});

  final VoidCallback? onSignOutRequested;

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _smsOrderAlerts = true;
  bool _expressPrioritySurcharge = true;
  bool _autoAssignNearestRider = true;
  bool _autoPrintThermalTag = false;
  String? _savedMessage;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionNotifierProvider);
    final currentWorker = authState.currentWorker;
    final colors = context.colors;
    final motion = context.motion;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 24.0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Configuration & Store Preferences',
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Configure Harborridge Laundry Service tax rules, SMS pickup alerts, and thermal tag printing.',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.0,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InteractivePressScale(
                      onTap: () => setState(() {
                        _savedMessage = 'Saved Harborridge Laundry Service configuration changes';
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 9.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accentGreen,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                        child: Text(
                          'Save Changes',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (widget.onSignOutRequested != null) ...[
                      const SizedBox(width: 10.0),
                      InteractivePressScale(
                        onTap: widget.onSignOutRequested,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 9.0,
                          ),
                          decoration: BoxDecoration(
                            color: colors.harborNavy,
                            borderRadius: BorderRadius.circular(99.0),
                          ),
                          child: Text(
                            'Open Login / Switch Worker',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: motion.shortDuration,
              child: _savedMessage == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F8EF),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _savedMessage!,
                          style: textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF15803D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 18.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colors.freshSkyBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: colors.freshSkyBlue.withValues(alpha: 0.35),
                ),
              ),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 10.0,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Security PIN & Account Credentials',
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Signed in as ${currentWorker.fullName} (${currentWorker.email}) • Active PIN: ${currentWorker.pin}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.0,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  InteractivePressScale(
                    onTap: () => showChangeWorkerPinDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 9.0,
                      ),
                      decoration: BoxDecoration(
                        color: colors.harborNavy,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pin_outlined,
                            size: 14.0,
                            color: colors.harborGold,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            'Change My PIN',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            _SettingToggleCard(
              title: 'Automated SMS & WhatsApp Ready-for-Pickup Alerts',
              subtitle: 'Send instant notifications when an order moves to Fold / Ready on the Kanban board.',
              value: _smsOrderAlerts,
              onChanged: (val) => setState(() => _smsOrderAlerts = val),
            ),
            const SizedBox(height: 12.0),
            _SettingToggleCard(
              title: 'Express Same-Day Turnaround Surcharge (+25%)',
              subtitle: 'Automatically apply express pricing when Express Iron or Same-Day SLA is selected in POS.',
              value: _expressPrioritySurcharge,
              onChanged: (val) =>
                  setState(() => _expressPrioritySurcharge = val),
            ),
            const SizedBox(height: 12.0),
            _SettingToggleCard(
              title: 'Smart Dispatch Rider Auto-Assignment',
              subtitle: 'Route new pickup requests to the active rider with the lowest bag load in that zone.',
              value: _autoAssignNearestRider,
              onChanged: (val) => setState(() => _autoAssignNearestRider = val),
            ),
            const SizedBox(height: 12.0),
            _SettingToggleCard(
              title: 'Auto-Print Waterproof Garment Barcode Tags on POS Submit',
              subtitle: 'Trigger thermal tag printer immediately when Create Order & View Invoice is clicked.',
              value: _autoPrintThermalTag,
              onChanged: (val) => setState(() => _autoPrintThermalTag = val),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingToggleCard extends StatelessWidget {
  const _SettingToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: colors.freshSkyBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
