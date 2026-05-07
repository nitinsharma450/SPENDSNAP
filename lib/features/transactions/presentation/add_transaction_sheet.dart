// lib/features/transactions/presentation/add_transaction_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/categories.dart'; // Import Categories
import '../../../core/widgets/snap_text_field.dart';
import '../../../core/widgets/snap_segmented_picker.dart';
import '../../budget/providers/goal_provider.dart'; // Import GoalProvider
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  bool isIncome = false;

  // --- New State Management Variables ---
  late String selectedCategory;
  String? selectedGoalId; // Only used if category is 'Goal Contribution'

  @override
  void initState() {
    super.initState();
    // Default selected category based on current type
    selectedCategory = isIncome ? incomeCategories[0] : expenseCategories[0];
  }

  // --- Crucial Interconnected State Logic ---
  void _submitData() {
    final title = titleController.text;
    final amount = double.tryParse(amountController.text) ?? 0.0;

    // Validate generic inputs
    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter valid details")));
      return;
    }

    // Validate special Goal Contribution inputs
    final contributionNeeded = !isIncome && selectedCategory == 'Goal Contribution';
    if (contributionNeeded && selectedGoalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a Goal to fund")));
      return;
    }

    final newTx = TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: selectedCategory,
      type: isIncome ? TransactionType.income : TransactionType.expense,
    );

    // Get access to both providers simultaneously
    final txProvider = context.read<TransactionProvider>();
    final goalProvider = context.read<GoalProvider>();

    // 1. Check for Category Spending Cap Extension (already built)
    final warningMsg = txProvider?.checkCategoryCapWarning(newTx);
    if (warningMsg != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(warningMsg), backgroundColor: AppColors.warning));
    }

    // 2. Add the basic transaction to RTDB (Updates Balance, Chart, List)
    txProvider?.addTransaction(newTx);

    // 3. --- The Interconnectivity Action! (DoD Polish) ---
    // If it's a goal contribution, also update the Goal Provider
    if (contributionNeeded && selectedGoalId != null && goalProvider != null) {
      goalProvider.fundGoal(selectedGoalId!, amount);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Watch goals to populate dropdown
    final goals = context.watch<GoalProvider?>()?.goals ?? [];

    // Categorization logic
    final currentCategories = isIncome ? incomeCategories : expenseCategories;
    // Show Goal dropdown only for goal contribution expenses
    final showGoalSelection = !isIncome && selectedCategory == 'Goal Contribution';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("New Transaction", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          SnapSegmentedPicker(
            isIncome: isIncome,
            onChanged: (val) {
              setState(() {
                isIncome = val;
                // Update default category when type toggles
                selectedCategory = isIncome ? incomeCategories[0] : expenseCategories[0];
                selectedGoalId = null; // Reset goal selection
              });
            },
          ),
          const SizedBox(height: 24),
          SnapTextField(hint: "What's this for?", icon: Icons.title, controller: titleController),
          const SizedBox(height: 16),
          SnapTextField(hint: "How much?", icon: Icons.currency_rupee, controller: amountController),
          const SizedBox(height: 24),

          // --- Custom Dropdown Widget #4 (Interconnectivity Dropdowns) ---

          // 1. Category Selection Dropdown
          Text("Select Category", style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              underline: const SizedBox(),
              items: currentCategories.map((String category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) setState(() => selectedCategory = newValue);
              },
            ),
          ),

          // 2. Conditional Goal Selection Dropdown (Interconnectivity UI)
          if (showGoalSelection) ...[
            const SizedBox(height: 24),
            Text("Link to Goal", style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            goals.isEmpty
                ? const Text("Create a Goal first to contribute", style: TextStyle(color: Colors.grey, fontSize: 12))
                : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
              child: DropdownButton<String>(
                value: selectedGoalId,
                hint: const Text("Select a SnapGoal"),
                isExpanded: true,
                underline: const SizedBox(),
                items: goals.map((goal) {
                  return DropdownMenuItem(value: goal.id, child: Text("${goal.title} (${(goal.progressPercentage * 100).toStringAsFixed(0)}% funded)"));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => selectedGoalId = newValue);
                },
              ),
            ),
          ],

          const SizedBox(height: 32),
          ElevatedButton(onPressed: _submitData, child: const Text("Save Transaction")),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}