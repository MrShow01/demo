import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_app/controllers/home_controller.dart';
import 'package:flutter_expense_tracker_app/views/widgets/input_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);
  final _themeController = Get.find<ThemeController>();
  final _homeController = Get.find<HomeController>();
  final TextEditingController oldPinController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _appBar(),
        body: ListView(children: [
          SizedBox(
            height: 15.w,
          ),
          ListTile(
            trailing: Icon(Icons.lock),
            leading: Text(
              'Change Password',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            onTap: () {
              _homeController.isChangePass.value = true;
            },
          ),
          /*  ListTile(
            trailing: Icon(
              (_themeController.isDark.value)
                  ? Icons.nightlight
                  : Icons.wb_sunny,
            ),
            onTap: () async {
              await _themeController.switchTheme();
            },
            leading: Text(
              'Change Theme',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ), */
          Visibility(
            visible: _homeController.isChangePass.value &&
                !_homeController.firstTimeSetPass.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: InputField(
                  hint: 'Enter Old Pin',
                  label: '',
                  isAmount: true,
                  isSecure: true,
                  controller: oldPinController),
            ),
          ),
          Visibility(
            visible: _homeController.isChangePass.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: InputField(
                  hint: 'Enter Your Pin',
                  label: '',
                  isAmount: true,
                  isSecure: true,
                  controller: newPinController),
            ),
          ),
          Visibility(
            visible: _homeController.isChangePass.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: InputField(
                hint: 'Confirm Your Pin',
                label: '',
                isAmount: true,
                controller: confirmPinController,
                isSecure: true,
              ),
            ),
          ),
          Visibility(
            visible: _homeController.isChangePass.value,
            child: SizedBox(
              width: Get.width * 0.5,
              child: ElevatedButton(
                  onPressed: () {
                    if (_homeController.firstTimeSetPass.value) {
                      if (newPinController.value.text ==
                          confirmPinController.value.text) {
                        _homeController
                            .setPassWord(newPinController.value.text);
                        Get.snackbar('Success', 'Pin set successfully');
                        Navigator.pop(context);
                      } else {
                        Get.snackbar('Error', "Pin didn't match");
                      }
                    } else {
                      if (oldPinController.value.text ==
                          _homeController.passPin.value) {
                        if (newPinController.value.text ==
                            confirmPinController.value.text) {
                          _homeController
                              .setPassWord(newPinController.value.text);

                          Get.snackbar('Success', 'Pin set successfully');
                          Navigator.pop(context);
                        } else {
                          Get.snackbar('Error', "Pin didn't match");
                        }
                      } else {
                        Get.snackbar('Error', "Old Pin didn't match");
                      }
                    }
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ),
        ]),
      );
    });
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Settings',
      ),
      leading: IconButton(
          onPressed: () {
            _homeController.isChangePass.value = false;
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
          )),
    );
  }
}
