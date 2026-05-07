// lib/features/budget/models/goal_model.dart

class GoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;
  final bool isAchieved;

  GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.createdAt,
    this.isAchieved = false,
  });

  // Calculate percentage for progress ring
  double get progressPercentage => (currentAmount / targetAmount).clamp(0.0, 1.0);

  // Convert to Map for RTDB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': createdAt.toIso8601String(),
      'isAchieved': isAchieved,
    };
  }

  // Create from Map
  factory GoalModel.fromMap(Map<dynamic, dynamic> map) {
    return GoalModel(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'].toDouble(),
      currentAmount: map['currentAmount'].toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      isAchieved: map['isAchieved'] ?? false,
    );
  }
}