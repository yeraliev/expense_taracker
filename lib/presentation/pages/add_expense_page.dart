import 'package:expense_tracker_app/core/snackbar/custom_snackbar.dart';
import 'package:expense_tracker_app/data/services/expense_service.dart';
import 'package:expense_tracker_app/domain/entities/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/expense_model.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final List<String> categories = ['Food', 'Transport', 'Entertainment', 'Other'];
  final service = ExpenseService();
  final amountController = TextEditingController();
  final commentController = TextEditingController();
  String? selectedCategory;

  Future<void> addExpense() async {
    try {
      await service.addExpense(
          ExpenseModel(
              amount: amountController.text.trim(),
              category: selectedCategory.toString(),
              date: DateTime.now(),
              comment: commentController.text.trim()
          )
      );

      Navigator.pop(context, true);
    } catch (e) {
      print(e.toString());
      CustomSnackBar().showSnackBar(context, text: 'Unknown error happened!', type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Add expense',
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAmountField(),
                  SizedBox(height: 20.h,),
                  _buildCategoryField(),
                  SizedBox(height: 20.h,),
                  _buildCommentField(),
                ],
              ),
            ),
          )
        ),
        bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              child: _buildSaveButton()
            )
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      keyboardType: TextInputType.number,
      controller: amountController,
      decoration: InputDecoration(
        label: Wrap(
          children: [
            Text(
              'Amount of expense',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.red
              ),
            ),
          ],
        ),
        prefixIcon: Icon(
          Icons.attach_money_rounded,
          color: Colors.green,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
              color: Colors.green,
              width: 2
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField(
        dropdownColor: Colors.white,
        value: selectedCategory,
        validator: (value) => value == null ? 'Choose the category' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.category_rounded,
            color: Colors.green,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
                color: Colors.green,
                width: 2
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
        ),
        items: categories.map((category) => DropdownMenuItem(
            value: category,
            child: Text(
              category,
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54
              ),
            )
        )).toList(),
        hint: Wrap(
          children: [
            Text(
              'Choose the category',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.red
              ),
            ),
          ],
        ),
        onChanged: (value) {
          setState(() {
            selectedCategory = value;
          });
        }
    );
  }

  Widget _buildCommentField() {
    return TextField(
      controller: commentController,
      maxLines: 5,
      minLines: 1,
      decoration: InputDecoration(
        labelText: 'Comment your expense',
        labelStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black54
        ),
        prefixIcon: Icon(
          Icons.comment,
          color: Colors.green,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
              color: Colors.green,
              width: 2
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
  
  Widget _buildSaveButton() {
    return SizedBox(
      height: 40.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r)
          )
        ),
        onPressed: () {
          if (amountController.text.isNotEmpty && selectedCategory != null){
            addExpense();
            print('${amountController.text}, ${selectedCategory.toString()}, ${DateTime.now()}, ${commentController.text}');
          }else {
            CustomSnackBar().showSnackBar(context, text: 'Fill the required fields!', type: 'error');
          }
        },
        child: Text(
          'Save',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white
          ),
        ),
      ),
    );
  }
}
