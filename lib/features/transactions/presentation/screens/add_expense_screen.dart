import 'package:flutter/material.dart';
import '../../../../core/theme/entities.dart';
import 'multi_step_expense_flow.dart';

class AddExpenseScreen extends StatelessWidget {
  final TransactionEntity? editTransaction;

  const AddExpenseScreen({super.key, this.editTransaction});

  @override
  Widget build(BuildContext context) {
    return MultiStepExpenseFlow(
      editTransaction: editTransaction,
      defaultType: TransactionType.expense,
    );
  }
}
