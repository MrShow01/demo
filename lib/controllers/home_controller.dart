import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/models/currency.dart';
import 'package:flutter_expense_tracker_app/models/transaction.dart';
import 'package:flutter_expense_tracker_app/providers/database_provider.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

class HomeController extends GetxController {
  final Rx<double> totalIncome = 0.0.obs;
  final Rx<double> totalExpense = 0.0.obs;
  final Rx<double> totalBalance = 0.0.obs;
  final Rx<double> _totalForSelectedDate = 0.0.obs;
  final Rx<bool> isPassSet = false.obs;
  final Rx<bool> isChangePass = false.obs;
  final Rx<bool> firstTimeSetPass = false.obs;
  final Rx<bool> firstTimeOpenApp = true.obs;
  final Rx<bool> showBalance = false.obs;

  final _passkey = 'passKey';
  final _isPassSetKey = 'passSetKey';
  final Rx<String> passPin = ''.obs;

  final Rx<Currency> _selectedCurrency =
      Currency(currency: 'EGP', symbol: 'EGP').obs;
  final Rx<DateTime> _selectedDate = DateTime.now().obs;

  final Rx<List<TransactionModel>> myTransactions =
      Rx<List<TransactionModel>>([]);
  final _box = GetStorage();

  double get totalForSelectedDate => _totalForSelectedDate.value;
  DateTime get selectedDate => _selectedDate.value;
  Currency get selectedCurrency => _selectedCurrency.value;
  Currency get _loadCurrencyFromStorage {
    final result = _box.read('currency');
    if (result == null) {
      return Currency(currency: 'EGP', symbol: 'EGP');
    }
    final Currency formatCurrency = Currency(
        currency: result.toString().split('|')[0],
        symbol: result.toString().split('|')[1]);

    return formatCurrency;
  }

  @override
  void onInit() {
    super.onInit();
    _selectedCurrency.value = _loadCurrencyFromStorage;

    getTransactions();
    getPassWord();
  }

  updateSelectedCurrency(Currency currency) async {
    _selectedCurrency.value = currency;
    final String formatCurrency = '${currency.currency}|${currency.symbol}';
    await _box.write('currency', formatCurrency);
  }

  getTransactions() async {
    final List<TransactionModel> transactionsFromDB = [];
    List<Map<String, dynamic>> transactions =
        await DatabaseProvider.queryTransaction();
    transactionsFromDB.assignAll(transactions.reversed
        .map((data) => TransactionModel().fromJson(data))
        .toList());
    myTransactions.value = transactionsFromDB;
    getTotalAmountForPickedDate(transactionsFromDB);
    tracker(transactionsFromDB);
  }

  getPassWord() {
    passPin.value = _box.read(_passkey) ?? '';
    isPassSet.value = _box.read(_isPassSetKey) ?? false;
    if (passPin.value.isEmpty) {
      firstTimeSetPass.value = true;
    }
  }

  setPassWord(String passPin) async {
    await _box.write(_passkey, passPin);
    await _box.write(_isPassSetKey, true);
  }

  Future<int> deleteTransaction(String id) async {
    return await DatabaseProvider.deleteTransaction(id);
  }

  Future<int> updateTransaction(TransactionModel transactionModel) async {
    return await DatabaseProvider.updateTransaction(transactionModel);
  }

  updateSelectedDate(DateTime date) {
    _selectedDate.value = date;
    getTransactions();
  }

  toggleBalanceShowHide() {
    showBalance.value = !showBalance.value;
  }

  getTotalAmountForPickedDate(List<TransactionModel> tm) {
    if (tm.isEmpty) {
      return;
    }
    double total = 0;
    for (TransactionModel transactionModel in tm) {
      if (transactionModel.date == DateFormat.yMd().format(selectedDate)) {
        if (transactionModel.type == 'Income') {
          total += double.parse(transactionModel.amount!);
        } else {
          total -= double.parse(transactionModel.amount!);
        }
      }
    }
    _totalForSelectedDate.value = total;
  }

  tracker(List<TransactionModel> tm) {
    if (tm.isEmpty) {
      return;
    }
    double expense = 0;
    double income = 0;
    double balance = 0;

    for (TransactionModel transactionModel in tm) {
      if (transactionModel.type == 'Income') {
        income += double.parse(transactionModel.amount!);
      } else {
        expense += double.parse(transactionModel.amount!);
      }
    }
    balance = income - expense;
    totalIncome.value = income;
    totalExpense.value = expense;
    totalBalance.value = balance;
  }

  openPinLock(BuildContext context) {
    Future<void> localAuth(BuildContext context) async {
      final localAuth = LocalAuthentication();
      final didAuthenticate =
          await localAuth.authenticate(localizedReason: 'Please authenticate');
      if (didAuthenticate) {
        firstTimeOpenApp.value = false;
        Navigator.pop(context);
      }
    }

    screenLock(
      context: context,
      correctString: passPin.value,
      digits: passPin.value.length,
      canCancel: false,
      customizedButtonChild: Icon(
        Icons.fingerprint,
      ),
      customizedButtonTap: () async {
        await localAuth(context);
      },
      didOpened: () async {
        await localAuth(context);
      },
    );
  }
}
