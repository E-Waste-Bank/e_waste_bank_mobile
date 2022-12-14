import 'package:about_us/about_us.dart';
import 'package:e_waste_bank_mobile/authentication/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:keuangan/providers/user_keuanganadmin_provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:e_waste_bank_mobile/drawer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginPageFormKey = GlobalKey<FormState>();

  String username = "";
  String password = "";
  var _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = true;
  }

  @override
  Widget build(BuildContext context) {
    CookieRequest requester =
        Provider.of<CookieRequest>(context, listen: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    UserKeuanganAdminProvider userKeuanganAdminProvider =
        Provider.of<UserKeuanganAdminProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      drawer: const MyDrawer(),
      body: Form(
        key: _loginPageFormKey,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: "Username anda",
                        labelText: "Username",
                        icon: const Icon(Icons.people),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    onChanged: (String? value) {
                      setState(() {
                        username = value!;
                      });
                    },
                    onSaved: (String? value) {
                      setState(() {
                        username = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Username harus diisi!';
                      }

                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: "Password anda",
                        labelText: "Password",
                        icon: const Icon(Icons.password),
                        suffixIcon: IconButton(
                          padding: const EdgeInsetsDirectional.only(end: 12.0),
                          icon: _isObscured
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    obscureText: _isObscured,
                    onChanged: (String? value) {
                      setState(() {
                        password = value!;
                      });
                    },
                    onSaved: (String? value) {
                      setState(() {
                        password = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Password harus diisi!';
                      }

                      return null;
                    },
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (_loginPageFormKey.currentState!.validate()) {
                      final response = await requester.login(
                          "https://e-waste-bank.up.railway.app/auth/login/", {
                        'username': username,
                        'password': password,
                      });

                      if (requester.loggedIn) {
                        userProvider.login(username, response['role']);
                        userKeuanganAdminProvider.login(
                            username, response['role']);
                        // ignore: use_build_context_synchronously
                        if (response['role'] == "user") {
                          // ignore: use_build_context_synchronously
                          userKeuanganAdminProvider.fetchBalance(context);
                        }
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 15,
                                child: ListView(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 20),
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    const Center(
                                      child: Text(
                                        "Login berhasil!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    TextButton(
                                      onPressed: () {
                                        // pop untuk menutup dialog box
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AboutUsPage()));
                                      },
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }));
                      } else {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 15,
                                child: ListView(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 20),
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        "Login gagal! ${response['message']}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    TextButton(
                                      onPressed: () {
                                        // pop untuk menutup dialog box
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }));
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
