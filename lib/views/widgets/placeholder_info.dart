import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/controllers/home_controller.dart';
import 'package:flutter_expense_tracker_app/views/widgets/show_transaction_list.dart';
import 'package:get/get.dart';

class PlaceholderInfo extends StatelessWidget {
  const PlaceholderInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Get.find<HomeController>().myTransactions.value.isEmpty
          ? Center(
              child: SizedBox(
                child: SizedBox(
                    height: Get.height * 0.3,
                    child: Image.asset('assets/wallet.png')),
              ),
            )
          : ShowTransactions(),
    );
  }
}
