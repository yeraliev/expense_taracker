
import 'package:expense_tracker_app/data/box/expense_box.dart';
import 'package:expense_tracker_app/data/models/expense_model.dart';
import 'package:expense_tracker_app/domain/entities/expense.dart';

class ExpenseService {
  final box = expensesBox;

  Future<void> addExpense(ExpenseModel expense) async {
    await box.add(expense);
  }

  Future<void> clearBox() async {
    await box.clear();
  }
}