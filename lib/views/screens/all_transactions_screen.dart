import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/controllers/add_transaction_controller.dart';
import 'package:flutter_expense_tracker_app/controllers/home_controller.dart';
import 'package:flutter_expense_tracker_app/controllers/theme_controller.dart';
import 'package:flutter_expense_tracker_app/views/screens/edit_transaction_screen.dart';
import 'package:flutter_expense_tracker_app/views/widgets/transaction_tile.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllTransactionsScreen extends StatelessWidget {
  AllTransactionsScreen({Key? key}) : super(key: key);
  final HomeController _homeController = Get.find();
  final AddTransactionController _addTransactionController =
      Get.put(AddTransactionController());
  final ThemeController _themeController = Get.find();

  final List<String> _transactionTypes = ['Income', 'Expense'];
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _appBar(),
        body: ListView.builder(
          itemCount: _homeController.myTransactions.value.length,
          itemBuilder: (context, i) {
            final transaction = _homeController.myTransactions.value[i];
            final text =
                '${_homeController.selectedCurrency.symbol}${transaction.amount}';

            if (transaction.type ==
                    _addTransactionController.transactionType.value &&
                transaction.type == 'Income') {
              log('income');
              final formatAmount = '+ $text';
              return GestureDetector(
                onTap: () async {
                  await Get.to(() => EditTransactionScreen(tm: transaction));
                  _homeController.getTransactions();
                },
                child: TransactionTile(
                    transaction: transaction,
                    formatAmount: formatAmount,
                    isIncome: true),
              );
            } else if (transaction.type ==
                    _addTransactionController.transactionType.value &&
                transaction.type == 'Expense') {
              log('Expense');

              final formatAmount = '- $text';
              return GestureDetector(
                onTap: () async {
                  await Get.to(() => EditTransactionScreen(tm: transaction));
                  _homeController.getTransactions();
                },
                child: TransactionTile(
                    transaction: transaction,
                    formatAmount: formatAmount,
                    isIncome: false),
              );
            } else {
              log('no value ${_addTransactionController.transactionType}');

              return SizedBox.shrink();
            }
          },
        ),
      );
    });
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'All Transactions',
        style: TextStyle(/* color: _themeController.color */),
      ),
      leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back, /* color: _themeController.color */
          )),
      actions: [
        Row(
          children: [
            Text(
              _addTransactionController.transactionType.isEmpty
                  ? _transactionTypes[0]
                  : _addTransactionController.transactionType.value,
              style: TextStyle(
                fontSize: 14.sp,
                /*   color: _themeController.color, */
              ),
            ),
            SizedBox(
              width: 40,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  customItemsHeight: 10,
                  customButton: Icon(
                    Icons.keyboard_arrow_down,
                    /*   color: _themeController.color, */
                  ),
                  items: _transactionTypes
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    _addTransactionController
                        .changeTransactionType((val as String));
                  },
                  itemHeight: 30.h,
                  dropdownPadding: EdgeInsets.all(4),
                  dropdownWidth: 105.w,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
