import 'package:Mini_Bill/Utils/extensions.dart';
import 'package:Mini_Bill/Widgets/custom_button.dart';
import 'package:Mini_Bill/Widgets/custom_textfield.dart';
import 'package:Mini_Bill/login/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

import '../Invoices/InvoicesList.dart';
import '../Utils/db.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isLoading = false;

  getData() async {
    setState(() {
      isLoading = true;
    });
    showLoaderDialog(context, "Syncing data", "Please wait");
    bool val = await sync();
    if (val == true) {
      isLoading = false;
    }
    Navigator.pop(context);
    setState(() {});
  }
  static showLoaderDialog(BuildContext context, title, subtitle) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      contentPadding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24),
      content: WillPopScope(
        onWillPop: () => Future.value(true),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator()),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 7), child: Text(subtitle)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  getInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("id");
    if (userId != null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => InvoiceList()),
              (route) => false);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInfo();
  }



  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
        viewModelBuilder: () => LoginViewModel(),
        builder: (context, viewModel, child) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                  title: Text('Login'),
              centerTitle: true,
                leading: IconButton( onPressed: () async {
                  FocusScope.of(context).unfocus();
                  await viewModel.sync(context);
                  getData();
                }, icon: Icon(Icons.sync)),
              ),
              body: Center(
                child: ListView(
                  padding: EdgeInsets.all(24),
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 180),
                    Center(
                      child: const Text(
                        "Welcome to eOrderBook",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 42),
                    CustomTextField(
                      controller: viewModel.usernameController,
                      prefixIcon: Icon(Icons.alternate_email_sharp),
                      hintText: "Username",
                      width: context.width * 0.8,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: viewModel.passwordController,
                      prefixIcon: Icon(Icons.lock_outline_sharp),
                      obscureText: true,
                      hintText: "Password",
                      width: context.width * 0.8,
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        CustomButton(
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              await viewModel.login(context);
                            },
                            width: context.width * 0.6,
                            height: 45,
                            child: const Text("Login")),
                        const SizedBox(height: 10),
                        // CustomButton(
                        //   onPressed: () async {
                        //     FocusScope.of(context).unfocus();
                        //     await viewModel.sync(context);
                        //   },
                        //   width: context.width * 0.3,
                        //   height: 30,
                        //   child: const Text("Sync"),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
