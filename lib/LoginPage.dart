import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Invoices/InvoicesList.dart';
import 'User.dart';
import 'Utils/db.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  bool _rememberMe = false;

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getInfo();
    syncLogin();
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

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    if (savedEmail != null) {
      setState(() {
        _email = savedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<User?> _saveData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Welcome Back",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                initialValue: _email,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your username address';
                  }
                  return null;
                },
                onSaved: (value) => _email = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) => _password = value,
              ),
              SizedBox(height: 16),
              Visibility(
                visible: false,
                child: Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    Text('Remember me'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Perform login operation using _email and _password
                    // For this example, we'll just navigate to the HomePage
                    // await _saveData();
                    await syncLogin();

                    SharedPreferences sp =
                        await SharedPreferences.getInstance();

                    Map<String, dynamic> jsonMap =
                        json.decode(sp.getString("users") ?? '');
                    print(jsonMap);

                    List<User> userList = [];

                    jsonMap.forEach((key, value) {
                      User user = User.fromJson(value);
                      userList.add(user);
                    });
                    print(userList);
                    int flag = -1;
                    User? selectedUser;
                    for (final user in userList) {
                      if (user.userName == emailController.text &&
                          user.password == passwordController.text) {
                        // Login successful
                        flag++;
                        selectedUser = user;
                        break;
                      }
                    }

                    if (flag >= 0 && selectedUser != null) {
                      sp.setString("id", "${selectedUser.userId}");
                      sp.setString("name", "${selectedUser.userName}");
                      print("SELECTED: ${sp.getString("name")}");
                      sp.commit();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InvoiceList()));
                    } else {
                      Fluttertoast.showToast(
                          msg: "Username or Password wrong",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey[600],
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  }
                },
                child: Text('Login'),
              ),
              ElevatedButton(
                  onPressed: () {
                    syncLogin();
                  },
                  child: Text("Sync Login Data"))
            ],
          ),
        ),
      ),
    );
  }
}

Future<User?> login(String email, String password, _userBox) async {
  final user = _userBox.values.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => null);

  return user;
}
