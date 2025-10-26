import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_expense_tracker_app/constants/colors.dart';
import 'package:flutter_expense_tracker_app/controllers/home_controller.dart';
import 'package:flutter_expense_tracker_app/controllers/theme_controller.dart';
import 'package:flutter_expense_tracker_app/models/currency.dart';
import 'package:flutter_expense_tracker_app/views/screens/add_transaction_screen.dart';
import 'package:flutter_expense_tracker_app/views/screens/all_transactions_screen.dart';
import 'package:flutter_expense_tracker_app/views/screens/chart_screen.dart';
import 'package:flutter_expense_tracker_app/views/screens/settings_screen.dart';
import 'package:flutter_expense_tracker_app/views/widgets/income_expense.dart';
import 'package:flutter_expense_tracker_app/views/widgets/placeholder_info.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _homeController = Get.put(HomeController());

  final _themeController = Get.find<ThemeController>();
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_homeController.isPassSet.value &&
          _homeController.firstTimeOpenApp.value) {
        _homeController.openPinLock(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        // appBar: _appBar(),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 12.h,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Get.to(() => SettingsScreen()),
                      icon: Icon(
                        Icons.settings,
                        size: 27.sp,
                        //  color: _themeController.color,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.to(() => ChartScreen()),
                      icon: Icon(
                        Icons.bar_chart,
                        size: 27.sp,
                        //   color: _themeController.color,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _homeController.selectedCurrency.currency,
                          style: TextStyle(
                            fontSize: 14.sp,
                            //   color: _themeController.color,
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              customItemsHeight: 10,
                              customButton: Icon(
                                Icons.keyboard_arrow_down,
                                //    color: _themeController.color,
                              ),
                              items: Currency.currencies
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item.currency,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                _homeController
                                    .updateSelectedCurrency((val as Currency));
                              },
                              itemHeight: 30.h,
                              dropdownPadding: EdgeInsets.all(4),
                              dropdownWidth: 105.w,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 8.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your Balance',
                      style: TextStyle(
                        fontSize: 23.sp,
                        fontWeight: FontWeight.w400,
                        //   color: _themeController.color,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _homeController.toggleBalanceShowHide();
                        },
                        icon: _homeController.showBalance.value
                            ? SvgPicture.asset('assets/unlocked.svg',
                                semanticsLabel: 'unlocked')
                            : SvgPicture.asset('assets/locked.svg',
                                semanticsLabel: 'locked'))
                  ],
                ),
                SizedBox(
                  height: 15.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (_homeController.showBalance.value)
                          ? '${_homeController.selectedCurrency.symbol}${_homeController.totalBalance.value.toStringAsFixed(2)}'
                          : '**********',
                      style: TextStyle(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: _homeController.showBalance.value,
                      child: IncomeExpence(
                        isIncome: true,
                        symbol: _homeController.selectedCurrency.symbol,
                        amount: _homeController.totalIncome.value,
                      ),
                    ),
                    Visibility(
                      visible: _homeController.showBalance.value,
                      child: IncomeExpence(
                        isIncome: false,
                        symbol: _homeController.selectedCurrency.symbol,
                        amount: _homeController.totalExpense.value,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .04.h,
                ),
                _homeController.myTransactions.value.isEmpty
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                        ),
                        child: Visibility(
                          visible: _homeController.showBalance.value,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Center(
                                  child: IconButton(
                                      onPressed: () => _showDatePicker(context),
                                      icon: Icon(
                                        Icons.calendar_month,
                                        color: Colors.grey,
                                      ))),
                            ),
                            title: Text(
                              _homeController.selectedDate.day ==
                                      DateTime.now().day
                                  ? 'Today'
                                  : DateFormat.yMd()
                                      .format(_homeController.selectedDate),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 7.h,
                                ),
                                Text(
                                  _homeController.totalForSelectedDate < 0
                                      ? 'You spent'
                                      : 'You earned',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: 3.h,
                                ),
                                Text(
                                  '${_homeController.selectedCurrency.symbol}${_homeController.totalForSelectedDate.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                (_homeController.showBalance.value)
                    ? PlaceholderInfo()
                    : Expanded(
                        child: Center(
                          child: SizedBox(
                            child: SvgPicture.asset('assets/suspect.svg',
                                semanticsLabel: 'unlocked'),
                          ),
                        ),
                      ),
                _homeController.myTransactions.value.isNotEmpty
                    ? Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 10.h),
                        child: GestureDetector(
                          onTap: () => Get.to(() => AllTransactionsScreen()),
                          child: Text('Show all transactions,'),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () async {
            await Get.to(() => AddTransactionScreen());
            _homeController.getTransactions();
          },
          child: Icon(
            Icons.add,
          ),
        ),
      );
    });
  }

  _showDatePicker(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2012),
        initialDate: DateTime.now(),
        lastDate: DateTime(2122));
    if (pickerDate != null) {
      _homeController.updateSelectedDate(pickerDate);
    }
  }

  AppBar _appBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () async {
          await _themeController.switchTheme();
        },
        icon: Icon((_themeController.isDark.value)
            ? Icons.nightlight
            : Icons.wb_sunny),
        //color: _themeController.color,
      ),
      actions: [
        IconButton(
          onPressed: () => Get.to(() => ChartScreen()),
          icon: Icon(
            Icons.bar_chart,
            size: 27.sp,
            // color: _themeController.color,
          ),
        ),
        Row(
          children: [
            Text(
              _homeController.selectedCurrency.currency,
              style: TextStyle(
                fontSize: 14.sp,
                // color: _themeController.color,
              ),
            ),
            SizedBox(
              width: 40,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  customItemsHeight: 10,
                  customButton: Icon(
                    Icons.keyboard_arrow_down,
                    // color: _themeController.color,
                  ),
                  items: Currency.currencies
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.currency,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    _homeController.updateSelectedCurrency((val as Currency));
                  },
                  itemHeight: 30.h,
                  dropdownPadding: EdgeInsets.all(4),
                  dropdownWidth: 105.w,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
