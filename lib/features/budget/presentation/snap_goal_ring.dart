// lib/features/budget/presentation/widgets/snap_goal_ring.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SnapGoalRing extends StatelessWidget {
  final double progressPercentage; // 0.0 to 1.0
  final String label;

  const SnapGoalRing({super.key, required this.progressPercentage, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 60, height: 60,
          child: Stack(
            children: [
              // Background track
              const Positioned.fill(
                child: CircularProgressIndicator(
                  value: 1.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE2E8F0)), // Light Grey
                  strokeWidth: 6,
                ),
              ),
              // The animated progress ring
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progressPercentage),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        value >= 1.0 ? AppColors.income : AppColors.primary,
                      ),
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              Center(
                child: Text(
                  "${(progressPercentage * 100).toStringAsFixed(0)}%",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(width: 70, child: Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}