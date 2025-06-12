class Expense {
  final String category;
  final String amount;
  final DateTime date;
  final String? comment;

  Expense({required this.amount, required this.category, this.comment, required this.date});
}