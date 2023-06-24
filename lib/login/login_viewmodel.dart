import 'package:Mini_Bill/Invoices/InvoicesList.dart';
import 'package:Mini_Bill/Products/ShowPro.dart';
import 'package:Mini_Bill/Utils/dialogs.dart';
import 'package:Mini_Bill/models/user_model.dart';
import 'package:Mini_Bill/services/firebase_users_services.dart';
import 'package:Mini_Bill/services/local_db_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewModel extends BaseViewModel {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  LocalDbServices localDbServices = LocalDbServices();
  FirebaseUsersServices firebaseUsersServices = FirebaseUsersServices();
  Future<void> login(context) async {
    Dialogs.showCustomDialog(
      context: context,
      title: "Logging in",
      description: "Please wait while we log you in",
      barrierDismissible: true,
    );
    await localDbServices.init();
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    if (username.isNotEmpty && password.isNotEmpty) {
      User? user = await localDbServices.queryUser(username, password);
      Navigator.pop(context);
      if (user != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => InvoiceList()),
            (route) => false);
      } else {
        Fluttertoast.showToast(msg: "Invalid email or password");
      }
    } else {
      Fluttertoast.showToast(msg: "Please enter email or password");
    }
  }

  Future<void> sync(context) async {
    Dialogs.showCustomDialog(
      context: context,
      title: "Syncing",
      description: "Please wait while we sync your data",
      barrierDismissible: true,
    );
    await localDbServices.init();
    List<User> users = await firebaseUsersServices.getUsers();
    await localDbServices.saveUsers(users);
    Navigator.pop(context);
  }
}

