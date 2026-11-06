import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';

class WorkspaceRecordRow {
  const WorkspaceRecordRow({
    required this.code,
    required this.primaryTitle,
    required this.secondarySubtitle,
    required this.metricValue,
    required this.statusLabel,
    this.isHighlighted = false,
  });

  final String code;
  final String primaryTitle;
  final String secondarySubtitle;
  final String metricValue;
  final String statusLabel;
  final bool isHighlighted;
}

class FeatureWorkspaceCard extends StatelessWidget {
  const FeatureWorkspaceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.records,
    this.primaryColumnLabel = 'ITEM / PARTNER',
    this.metricColumnLabel = 'AMOUNT / METRIC',
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<WorkspaceRecordRow> records;
  final String primaryColumnLabel;
  final String metricColumnLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(14.0),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(26.0, 24.0, 26.0, 18.0),
              child: Row(
                children: [
                  Container(
                    width: 42.0,
                    height: 42.0,
                    decoration: BoxDecoration(
                      color: colors.brandPrimary.withAlpha(24),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: colors.brandPrimary, size: 22.0),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3.0),
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
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 26.0,
                vertical: 12.0,
              ),
              color: const Color(0xFFECEFF3),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'CODE',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10.0,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      primaryColumnLabel,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10.0,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      metricColumnLabel,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10.0,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'STATUS',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10.0,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            for (final row in records)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26.0,
                  vertical: 13.0,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.code,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: colors.brandPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.primaryTitle,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            row.secondarySubtitle,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11.0,
                              color: colors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.metricValue,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 4.5,
                          ),
                          decoration: BoxDecoration(
                            color: row.isHighlighted
                                ? colors.accentGreen
                                : const Color(0xFF8392A5),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            row.statusLabel,
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
