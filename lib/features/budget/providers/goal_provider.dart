// lib/features/budget/providers/goal_provider.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/goal_modals.dart';

class GoalProvider extends ChangeNotifier {
  final String userId;
  final DatabaseReference _dbRef;
  List<GoalModel> _goals = [];

  GoalProvider(this.userId)
      : _dbRef = FirebaseDatabase.instance.ref().child('users/$userId/goals') {
    _listenToGoals();
  }

  List<GoalModel> get goals => _goals;

  // Stream goals in real-time
  void _listenToGoals() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _goals = data.entries.map((e) => GoalModel.fromMap(e.value)).toList();
        _goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _goals = [];
      }
      notifyListeners();
    });
  }

  // Add a new SnapGoal
  Future<void> addGoal(GoalModel goal) async {
    await _dbRef.child(goal.id).set(goal.toMap());
  }

  // --- Crucial Interconnectivity Logic (DoD #1) ---
  // When a 'Goal Contribution' transaction is added, this method updates the goal balance.
  Future<void> fundGoal(String goalId, double contributionAmount) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) return;

    final goal = _goals[goalIndex];
    final updatedCurrentAmount = goal.currentAmount + contributionAmount;

    // Auto-achieve if amount met
    final achieved = updatedCurrentAmount >= goal.targetAmount;

    await _dbRef.child(goalId).update({
      'currentAmount': updatedCurrentAmount,
      'isAchieved': achieved,
    });
  }
}