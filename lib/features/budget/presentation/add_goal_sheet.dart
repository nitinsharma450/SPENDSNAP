// lib/features/budget/presentation/add_goal_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/widgets/snap_text_field.dart';
import '../models/goal_modals.dart';
import '../providers/goal_provider.dart';

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  void _submitGoal() {
    final title = titleController.text;
    final amount = double.tryParse(amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter valid goal details")));
      return;
    }

    final newGoal = GoalModel(
      id: const Uuid().v4(),
      title: title,
      targetAmount: amount,
      createdAt: DateTime.now(),
    );

    context.read<GoalProvider>()?.addGoal(newGoal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("New SnapGoal", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          SnapTextField(hint: "Goal Title (e.g., 'Vacation')", icon: Icons.flag, controller: titleController),
          const SizedBox(height: 16),
          SnapTextField(hint: "Target Amount", icon: Icons.currency_rupee, controller: amountController),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _submitGoal, child: const Text("Create Goal")),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}