import 'package:expense_tracker_app/data/box/expense_box.dart';
import 'package:expense_tracker_app/data/models/expense_model.dart';
import 'package:expense_tracker_app/domain/entities/expense.dart';
import 'package:expense_tracker_app/presentation/pages/add_expense_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';

import '../../core/snackbar/custom_snackbar.dart';
import '../../enum/filter_type.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box box;
  late List<dynamic> expenses;
  FilterType _selectedFilter = FilterType.all;
  double _selectedPeriodSum = 0;

  @override
  void initState()  {
    super.initState();
    box = expensesBox;
    expenses = expensesBox.values.toList();
    countSum(expenses);
  }

  List<dynamic> getFilteredExpenses(Box box) {
    final now = DateTime.now();
    final all = box.values.cast<ExpenseModel>().toList();

    return all.where((expense) {
      final date = expense.date;

      switch (_selectedFilter) {
        case FilterType.all:
          return true;

        case FilterType.today:
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

        case FilterType.week:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(Duration(days: 6));
          return date.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
              date.isBefore(endOfWeek.add(Duration(days: 1)));

        case FilterType.month:
          return date.year == now.year && date.month == now.month;
      }
    }).toList();
  }

  void countSum(List<dynamic> expenses) {
    for (int i = 0; i < expenses.length; i++) {
      final expense = expenses[i] as ExpenseModel;
      _selectedPeriodSum += double.parse(expense.amount);
    }
  }

  String filterLabel(FilterType type) {
    switch (type) {
      case FilterType.all: return "All";
      case FilterType.today: return "Today";
      case FilterType.week: return "This Week";
      case FilterType.month: return "This Month";
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        surfaceTintColor: Colors.transparent,
        title: Text(
          'My expenses',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w500
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DropdownButton<FilterType>(
                    dropdownColor: Colors.white,
                    value: _selectedFilter,
                    items: FilterType.values.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(
                          filterLabel(filter)
                        ), // more user-friendly label
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFilter = value;
                          expenses = getFilteredExpenses(box);
                          _selectedPeriodSum = 0;
                          countSum(expenses);
                        });
                      }
                    },
                  ),
                  Spacer(),
                  Text(
                    '${_selectedPeriodSum.toString()} KZT',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500
                    ),
                  )
                ],
              ),
              SizedBox(height: 10.h,),
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    if (box.isEmpty || expenses == []) {
                      return Center(
                        child: Text(
                          'No expenses yet',
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54
                          ),
                        )
                      );
                    }

                    final expense = expenses[index] as ExpenseModel;
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r)
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        leading: GestureDetector(
                          onTap: () {
                            setState(() {
                              box.deleteAt(index);
                              expenses.removeAt(index);
                              _selectedPeriodSum = 0;
                              countSum(expenses);
                            });
                          },
                          child: Icon(
                            Icons.remove_circle_outline_rounded,
                            color: Colors.red,
                            size: 18.w,
                          )
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                Text(
                                  'Category: ',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54
                                  ),
                                ),
                                Text(
                                  expense.category,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black54
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              children: [
                                Text(
                                  'Amount: ',
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54
                                  ),
                                ),
                                Text(
                                  '${expense.amount} KZT',
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black54
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: expense.comment != null && expense.comment!.isNotEmpty
                            ? Wrap(
                          children: [
                            Text(
                              'Comment: ',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54
                              ),
                            ),
                            Text(
                              expense.comment!,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black54
                              ),
                            ),
                          ],
                        )
                            : null,
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        )
      ),
      bottomNavigationBar: Container(
        color: Colors.green,
        height: 65.h,
        child: Padding(
          padding: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 25.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final delete = await showAlert(context) ?? false;
                    if(delete) {
                      setState(() {
                        box.clear();
                        expenses = [];
                        _selectedPeriodSum = 0;
                        countSum(expenses);
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5.w,),
                      Text(
                        'Clear all',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final success = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddExpensePage())) ?? false;
                    if (success) {
                      CustomSnackBar().showSnackBar(context, text: 'Expense added successfully!', type: 'success');
                      setState(() {
                        box = expensesBox;
                        expenses = expensesBox.values.toList();
                        _selectedPeriodSum = 0;
                        countSum(expenses);
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5.w,),
                      Text(
                        'Add expenses',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> showAlert(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog.adaptive(
          backgroundColor: Colors.white,
          title: Text(
            'Warning',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            'Do you really want to delete all expenses from memory?',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.red
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
                },
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.blue
                  ),
                ),
            ),
          ],
        );
      }
    );
  }
}
