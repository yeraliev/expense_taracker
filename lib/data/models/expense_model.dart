import 'package:expense_tracker_app/domain/entities/expense.dart';
import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject{

  ExpenseModel({required this.category, required this.amount, this.comment, required this.date});

  @HiveField(0)
  String category;

  @HiveField(1)
  String amount;

  @HiveField(2)
  String? comment;

  @HiveField(3)
  DateTime date;

  Expense toEntity() => Expense(amount: amount, category: category, date: date, comment: comment);
}