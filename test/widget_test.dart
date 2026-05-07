import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsnap/core/widgets/snap_text_field.dart';
import 'package:spendsnap/core/widgets/snap_segmented_picker.dart';
import 'package:spendsnap/core/widgets/transaction_widget.dart';
import 'package:spendsnap/features/transactions/models/transaction_model.dart';

void main() {
  group('SpendSnap Custom Widget Tests', () {

    testWidgets('SnapTextField renders hint text and icon', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SnapTextField(hint: 'Enter Amount', icon: Icons.money, controller: controller),
        ),
      ));

      expect(find.text('Enter Amount'), findsOneWidget);
      expect(find.byIcon(Icons.money), findsOneWidget);
    });

    testWidgets('SnapSegmentedPicker displays Income and Expense labels', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SnapSegmentedPicker(isIncome: false, onChanged: (val) {}),
        ),
      ));

      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('TransactionCard formats currency correctly', (WidgetTester tester) async {
      final dummyTx = TransactionModel(
        id: '1',
        title: 'Biryani',
        amount: 350.0,
        date: DateTime.now(),
        category: 'Food',
        type: TransactionType.expense,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TransactionCard(transaction: dummyTx),
        ),
      ));

      expect(find.text('Biryani'), findsOneWidget);
      expect(find.text('-₹350'), findsOneWidget);
    });
  });
}