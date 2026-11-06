import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_motion.dart';
import 'package:laundry_ridge/app/theme/app_typography.dart';
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
  bool _driverGeofencePings = true;
  bool _expressPrioritySurcharge = true;
  bool _autoCommissionSplit = true;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Toolbar with Title & Action Controls
          _buildHeaderToolbar(context, textTheme, colors, motion),

          const SizedBox(height: 14.0),

          // 2. Feedback Notification Banner
          AnimatedSwitcher(
            duration: motion.shortDuration,
            child: _savedMessage == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey(_savedMessage),
                    margin: const EdgeInsets.only(bottom: 14.0),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16.0,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _savedMessage!,
                            style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF065F46),
                              fontSize: AppTypography.captionSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 14.0,
                            color: Color(0xFF059669),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(() => _savedMessage = null),
                        ),
                      ],
                    ),
                  ),
          ),

          // 3. System Configuration Telemetry Strip (No Cardview Overuse)
          _buildSystemTelemetryStrip(context, textTheme, colors),

          const SizedBox(height: 14.0),

          // 4. Current Worker Credentials & PIN Security Section
          _buildSecurityCredentialsSection(
            context,
            textTheme,
            colors,
            currentWorker,
          ),

          const SizedBox(height: 14.0),

          // 5. Operational Toggle Categories (Structured Manifest)
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Customer Communications
                _buildSectionSubHeader(
                  textTheme,
                  colors,
                  icon: Icons.notifications_active_outlined,
                  title: 'CUSTOMER COMMUNICATIONS & READY ALERTS',
                ),
                _buildSettingRow(
                  colors: colors,
                  textTheme: textTheme,
                  icon: Icons.sms_outlined,
                  title: 'Automated SMS & WhatsApp Ready-for-Pickup Alerts',
                  subtitle: 'Send instant notifications when an order moves to Fold / Ready on the Kanban board.',
                  value: _smsOrderAlerts,
                  onChanged: (val) => setState(() => _smsOrderAlerts = val),
                ),
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: colors.borderSubtle,
                ),
                _buildSettingRow(
                  colors: colors,
                  textTheme: textTheme,
                  icon: Icons.near_me_outlined,
                  title: 'Driver Real-Time Geofence Arrival Pings',
                  subtitle: 'Send customer tracking alert when delivery courier enters within 500m of drop-off destination.',
                  value: _driverGeofencePings,
                  onChanged: (val) =>
                      setState(() => _driverGeofencePings = val),
                ),

                // Section 2: Pricing & Commissions
                _buildSectionSubHeader(
                  textTheme,
                  colors,
                  icon: Icons.payments_outlined,
                  title: 'PRICING, COMMISSIONS & ESCROW SPLITS',
                ),
                _buildSettingRow(
                  colors: colors,
                  textTheme: textTheme,
                  icon: Icons.speed_rounded,
                  title: 'Express Same-Day Turnaround Surcharge (+25%)',
                  subtitle: 'Automatically apply express tier pricing when Same-Day SLA or Express Iron is chosen.',
                  value: _expressPrioritySurcharge,
                  onChanged: (val) =>
                      setState(() => _expressPrioritySurcharge = val),
                ),
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: colors.borderSubtle,
                ),
                _buildSettingRow(
                  colors: colors,
                  textTheme: textTheme,
                  icon: Icons.account_balance_outlined,
                  title: 'Automated M-Pesa B2B Platform Split Deductions (15%)',
                  subtitle: 'Retain centralized platform split and allocate partner vendor balance to settlement escrow automatically.',
                  value: _autoCommissionSplit,
                  onChanged: (val) =>
                      setState(() => _autoCommissionSplit = val),
                ),

                // Section 3: Hardware & Automation
                _buildSectionSubHeader(
                  textTheme,
                  colors,
                  icon: Icons.settings_suggest_outlined,
                  title: 'POS HARDWARE & DISPATCH AUTOMATION',
                ),
                _buildSettingRow(
                  colors: colors,
                  textTheme: textTheme,
                  icon: Icons.alt_route_rounded,
                  title: 'Smart Dispatch Rider Auto-Assignment',
                  subtitle: 'Route new pickup requests automatically to the active rider with the lowest bag load in that delivery zone.',
                  value: _autoAssignNearestRider,
                  onChanged: (val) =>
                      setState(() => _autoAssignNearestRider = val),
                ),
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: colors.borderSubtle,
                ),
                _buildSettingRow(
                  colors: colors,
                  textTheme: textTheme,
                  icon: Icons.print_outlined,
                  title: 'Auto-Print Waterproof Garment Barcode Tags on POS Submit',
                  subtitle: 'Trigger thermal tag printer immediately when Create Order & View Invoice is confirmed.',
                  value: _autoPrintThermalTag,
                  onChanged: (val) =>
                      setState(() => _autoPrintThermalTag = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14.0),

          // 6. Store Master System Specifications
          _buildStoreMasterSpecs(context, textTheme, colors),
        ],
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildHeaderToolbar(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    AppMotion motion,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: colors.harborNavy.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 20.0,
                  color: colors.harborNavy,
                ),
              ),
              const SizedBox(width: 12.0),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'System Configuration & Store Preferences',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Configure Harborridge Laundry Service tax rules, SMS pickup alerts, and thermal tag printing.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.0,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InteractivePressScale(
                onTap: () => setState(() {
                  _savedMessage = 'Configuration saved successfully • All store rules synchronized';
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accentGreen,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 15.0,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'Save Changes',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: AppTypography.captionSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.onSignOutRequested != null)
                InteractivePressScale(
                  onTap: widget.onSignOutRequested,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: colors.harborNavy,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 15.0,
                          color: colors.harborGold,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          'Switch Operator',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: AppTypography.captionSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemTelemetryStrip(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
  ) {
    final metrics = [
      (
        icon: Icons.payments_outlined,
        color: const Color(0xFF059669),
        title: 'STORE CURRENCY',
        value: 'KES (Shilling)',
        sub: 'Central Bank of Kenya (CBK)',
      ),
      (
        icon: Icons.receipt_long_outlined,
        color: colors.freshSkyBlue,
        title: 'TAX COMPLIANCE',
        value: '16.0% VAT Rate',
        sub: 'Automated KRA ETR integration',
      ),
      (
        icon: Icons.mark_chat_read_outlined,
        color: const Color(0xFF4F46E5),
        title: 'SMS & WHATSAPP GATEWAY',
        value: 'Online • Connected',
        sub: 'Twilio & WhatsApp Business API',
      ),
      (
        icon: Icons.precision_manufacturing_outlined,
        color: colors.harborGold,
        title: 'DISPATCH & PRINTING',
        value: 'Smart Automation',
        sub: 'Geofenced routing & thermal tags',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760.0;
          if (isWide) {
            return IntrinsicHeight(
              child: Row(
                children: [
                  for (var i = 0; i < metrics.length; i++) ...[
                    if (i > 0)
                      VerticalDivider(
                        width: 1.0,
                        thickness: 1.0,
                        color: colors.borderSubtle,
                      ),
                    Expanded(
                      child: _buildTelemetryCell(
                        context,
                        textTheme,
                        colors,
                        metrics[i],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
          return Wrap(
            children: [
              for (var i = 0; i < metrics.length; i++)
                SizedBox(
                  width: constraints.maxWidth / 2,
                  child: _buildTelemetryCell(
                    context,
                    textTheme,
                    colors,
                    metrics[i],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTelemetryCell(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    ({IconData icon, Color color, String title, String value, String sub}) item,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Icon(item.icon, size: 17.0, color: item.color),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  item.sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.captionSize,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCredentialsSection(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
    WorkerAccount worker,
  ) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 10.0,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: colors.harborNavy,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    worker.initials,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.harborGold,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        worker.fullName,
                        style: textTheme.labelMedium?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: colors.freshSkyBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          worker.roleTitle,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                            color: colors.freshSkyBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '${worker.email} • Branch: ${worker.branch}',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.0,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 13.0,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      'PIN: ${worker.pin}',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              InteractivePressScale(
                onTap: () => showChangeWorkerPinDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 7.0,
                  ),
                  decoration: BoxDecoration(
                    color: colors.freshSkyBlue,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pin_outlined,
                        size: 13.0,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5.0),
                      Text(
                        'Change My PIN',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSubHeader(
    TextTheme textTheme,
    AppColors colors, {
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.65),
        border: Border(
          top: BorderSide(color: colors.borderSubtle),
          bottom: BorderSide(color: colors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15.0, color: colors.harborNavy),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required AppColors colors,
    required TextTheme textTheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Icon(icon, size: 16.0, color: colors.harborNavy),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.0,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Switch(
            value: value,
            activeThumbColor: colors.freshSkyBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStoreMasterSpecs(
    BuildContext context,
    TextTheme textTheme,
    AppColors colors,
  ) {
    final specs = [
      (
        'Primary Facility Branch',
        'Harborridge Central Plant • Industrial Area HQ',
      ),
      (
        'Store Currency & Symbol',
        'KES (Kenyan Shilling • Official Central Bank Standard)',
      ),
      (
        'Taxation Compliance',
        '16.0% Value Added Tax (KRA ETR Automated Invoicing)',
      ),
      (
        'Default Payment Gateways',
        'M-Pesa Express STK Push, KCB B2B, Stanbic EFT, Cash',
      ),
      (
        'Operational SLA Tiers',
        'Standard: 48 Hours • Express Iron: 12 Hours • Same-Day: 6 Hours',
      ),
      ('Platform Timezone', 'Africa/Nairobi (EAT • UTC+03:00)'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: colors.background.withValues(alpha: 0.65),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(9.0),
              ),
              border: Border(bottom: BorderSide(color: colors.borderSubtle)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 15.0,
                  color: colors.harborNavy,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'MASTER SYSTEM SPECIFICATIONS & STORE PROFILE',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < specs.length; i++) ...[
            if (i > 0)
              Divider(height: 1.0, thickness: 1.0, color: colors.borderSubtle),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 11.0,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 200.0,
                    child: Text(
                      specs[i].$1,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      specs[i].$2,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
