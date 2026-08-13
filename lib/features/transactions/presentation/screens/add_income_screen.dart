import 'package:flutter/material.dart';
import '../../../../core/theme/entities.dart';
import 'multi_step_expense_flow.dart';

class AddIncomeScreen extends StatelessWidget {
  final TransactionEntity? editTransaction;

  const AddIncomeScreen({super.key, this.editTransaction});

  @override
  Widget build(BuildContext context) {
    return MultiStepExpenseFlow(
      editTransaction: editTransaction,
      defaultType: TransactionType.income,
    );
  }
}
