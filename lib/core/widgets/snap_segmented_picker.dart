import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SnapSegmentedPicker extends StatelessWidget {
  final bool isIncome;
  final Function(bool) onChanged;

  const SnapSegmentedPicker({super.key, required this.isIncome, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegment(context, "Expense", !isIncome, AppColors.expense),
          _buildSegment(context, "Income", isIncome, AppColors.income),
        ],
      ),
    );
  }

  Widget _buildSegment(BuildContext context, String label, bool selected, Color activeColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(label == "Income"),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}