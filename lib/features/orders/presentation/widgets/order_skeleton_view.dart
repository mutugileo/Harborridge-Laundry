import 'package:flutter/material.dart';
import 'package:laundry_ridge/app/theme/app_colors.dart';
import 'package:laundry_ridge/app/theme/app_spacing.dart';
import 'package:laundry_ridge/core/widgets/app_skeleton.dart';

class OrderSkeletonView extends StatelessWidget {
  const OrderSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMultiColumn = constraints.maxWidth >= 900.0;

          final centerCardSkeleton = Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(spacing.cardRadius),
              border: Border.all(color: colors.borderSubtle),
            ),
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppSkeleton(width: 140.0, height: 22.0),
                        SizedBox(height: spacing.xs),
                        const AppSkeleton(width: 180.0, height: 14.0),
                        SizedBox(height: spacing.xs),
                        const AppSkeleton(width: 160.0, height: 14.0),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const AppSkeleton(width: 160.0, height: 20.0),
                        SizedBox(height: spacing.xs),
                        const AppSkeleton(width: 120.0, height: 14.0),
                        SizedBox(height: spacing.sm),
                        const AppSkeleton(width: 100.0, height: 28.0),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: spacing.xl),
                const AppSkeleton(width: double.infinity, height: 38.0),
                SizedBox(height: spacing.md),
                ...List.generate(
                  4,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: spacing.md),
                    child: Row(
                      children: [
                        const AppSkeleton(width: 36.0, height: 36.0),
                        SizedBox(width: spacing.sm),
                        const Expanded(
                          child: AppSkeleton(width: 160.0, height: 18.0),
                        ),
                        SizedBox(width: spacing.sm),
                        const AppSkeleton(width: 70.0, height: 18.0),
                        SizedBox(width: spacing.sm),
                        const AppSkeleton(width: 40.0, height: 18.0),
                        SizedBox(width: spacing.sm),
                        const AppSkeleton(width: 70.0, height: 18.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          final rightCardSkeleton = Container(
            width: isMultiColumn ? 280.0 : double.infinity,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(spacing.cardRadius),
              border: Border.all(color: colors.borderSubtle),
            ),
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton(width: 120.0, height: 20.0),
                SizedBox(height: spacing.md),
                const AppSkeleton(width: double.infinity, height: 38.0),
                SizedBox(height: spacing.sm),
                const AppSkeleton(width: double.infinity, height: 38.0),
                SizedBox(height: spacing.xl),
                const AppSkeleton(width: 100.0, height: 20.0),
                SizedBox(height: spacing.md),
                const AppSkeleton(width: double.infinity, height: 44.0),
                SizedBox(height: spacing.md),
                const AppSkeleton(width: double.infinity, height: 44.0),
              ],
            ),
          );

          if (!isMultiColumn) {
            return Column(
              children: [
                centerCardSkeleton,
                SizedBox(height: spacing.lg),
                rightCardSkeleton,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: centerCardSkeleton),
              SizedBox(width: spacing.lg),
              rightCardSkeleton,
            ],
          );
        },
      ),
    );
  }
}
