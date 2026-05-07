import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/runway_chart.dart';
import '../../../core/widgets/transaction_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../budget/presentation/add_goal_sheet.dart';
import '../../budget/presentation/snap_goal_ring.dart';
import '../../budget/providers/goal_provider.dart';
import '../../transactions/presentation/add_transaction_sheet.dart';
import '../../transactions/providers/transaction_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: Consumer<TransactionProvider?>(
        builder: (context, provider, _) {
          if (provider == null)
            return const Center(child: CircularProgressIndicator());

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SafeArea(child: SizedBox(height: 0)),

                      Text(
                        "Total Balance",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        "₹${provider.totalBalance.toStringAsFixed(0)}",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 24),

                      // --- The Insight Card ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Runway Forecast",
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "You have ${provider.daysOfRunwayRemaining} days left",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 16),
                            // Simple placeholder data for now, we'll map actual daily totals later
                            const RunwayChart(
                              last7DaysSpending: [10, 25, 15, 40, 30, 60, 45],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- The "SnapGoals" Section (DoD MISS FIXED) ---
                      Consumer<GoalProvider?>(
                          builder: (context, goalProvider, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("SnapGoals", style: Theme.of(context).textTheme.titleLarge),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                  // We need to build this sheet next!
                                  onPressed: () => _openAddGoalSheet(context),
                                )
                              ],
                            );
                          }
                      ),
                      const SizedBox(height: 12),

                      // Horizontally scrolling goal list
                      SizedBox(
                        height: 100,
                        child: Consumer<GoalProvider?>(
                            builder: (context, goalProvider, _) {
                              if (goalProvider == null || goalProvider.goals.isEmpty) {
                                return const Center(child: Text("Track specific goals. Tap +", style: TextStyle(color: Colors.grey)));
                              }
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: goalProvider.goals.length,
                                separatorBuilder: (ctx, idx) => const SizedBox(width: 20),
                                itemBuilder: (ctx, idx) {
                                  final goal = goalProvider.goals[idx];
                                  return SnapGoalRing(
                                    progressPercentage: goal.progressPercentage,
                                    label: goal.title,
                                  );
                                },
                              );
                            }
                        ),
                      ),

                      const SizedBox(height: 32),
                      Text("Recent Transactions", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // The transaction list
              provider.transactions.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(child: Text("No data yet")),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tx = provider.transactions[index];

                        // --- New Micro-Interaction Layer (DoD Requirement) ---
                        return Dismissible(
                          key: Key(tx.id),
                          direction: DismissDirection.endToStart,
                          // Swipe left only

                          // The red background that appears when swiping
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(
                              bottom: 12,
                              left: 24,
                              right: 24,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.expense, // Our coral red
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          // Confirmation dialog before deleting (best practice)
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete Transaction?"),
                                content: const Text(
                                  "Are you sure you want to remove 'scrub' this?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },

                          // Perform the actual deletion
                          onDismissed: (direction) {
                            provider.deleteTransaction(tx.id);

                            // Show a temporary snackbar with an 'Undo' option would be next level, but let's keep it simple.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Transaction scrubbed."),
                              ),
                            );
                          },

                          // The actual card content
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: TransactionCard(transaction: tx),
                          ),
                        );
                      }, childCount: provider.transactions.length),
                    ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const AddTransactionSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _openAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddGoalSheet(),
    );
  }

}
