import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final String userId;
  final DatabaseReference _dbRef;
  List<TransactionModel> _transactions = [];

  TransactionProvider(this.userId)
      : _dbRef = FirebaseDatabase.instance.ref().child('users/$userId/transactions') {
    _listenToTransactions();
  }

  List<TransactionModel> get transactions => _transactions;

  // Stream transactions in real-time
  void _listenToTransactions() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _transactions = data.entries.map((e) => TransactionModel.fromMap(e.value)).toList();
        // Sort by date (newest first)
        _transactions.sort((a, b) => b.date.compareTo(a.date));
      } else {
        _transactions = [];
      }
      notifyListeners();
    });
  }

  // Add a new transaction
  Future<void> addTransaction(TransactionModel tx) async {
    await _dbRef.child(tx.id).set(tx.toMap());
  }

  // For the "Insight" layer: Calculate Total Balance
  double get totalBalance {
    double balance = 0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) balance += tx.amount;
      else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  double get totalExpenses => _transactions
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get dailyBurnRate {
    if (_transactions.isEmpty) return 0.0;

    // Find the date of the first transaction
    final firstDate = _transactions.last.date;
    final daysActive = DateTime.now().difference(firstDate).inDays + 1;

    return totalExpenses / daysActive;
  }

  // Predicts how many days of "Runway" are left based on current balance
  int get daysOfRunwayRemaining {
    if (dailyBurnRate <= 0) return 30; // Default if no expenses
    final remaining = (totalBalance / dailyBurnRate).floor();
    return remaining < 0 ? 0 : remaining;
  }

  // Extension #2: Category Spending Caps
  String? checkCategoryCapWarning(TransactionModel newTx) {
    if (newTx.type == TransactionType.income) return null;

    // Hardcoded for demo, but could easily be user-defined in a real app
    final Map<String, double> categoryCaps = {
      'Food': 5000.0,
      'Entertainment': 3000.0,
      'Shopping': 4000.0,
    };

    if (!categoryCaps.containsKey(newTx.category)) return null;

    // Calculate how much has already been spent in this category
    final currentSpent = _transactions
        .where((t) => t.type == TransactionType.expense && t.category == newTx.category)
        .fold(0.0, (sum, item) => sum + item.amount);

    if (currentSpent + newTx.amount > categoryCaps[newTx.category]!) {
      return "Hold up! This pushes you over your ${newTx.category} cap of ₹${categoryCaps[newTx.category]}!";
    }
    return null; // All good, under budget
  }

  Future<void> deleteTransaction(String txId) async {
    // Delete from RTDB
    await _dbRef.child(txId).remove();
    // note: _listenToTransactions() will automatically update the local list
  }

}