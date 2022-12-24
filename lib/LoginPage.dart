import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/HomePage.dart';
import 'package:smart_home/utils/request.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();

  @override
  void initState() {
    _ipAddressController.text = Request.domain;
    super.initState();
  }

  String? _invalid;
  bool _loading = false;


  void _login() async {
    setState(() {
      _invalid = null;
      _loading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    Request.domain = _ipAddressController.value.text;
    prefs.setString("ip", Request.domain);

    String password = _passwordController.value.text;

    if(password.isEmpty) {
      setState(() {
        _invalid = "Password cannot be empty!";
        _loading = false;
      });

      return;
    }

    var response = await Request.get("login", {"password": password});

    String res = jsonDecode(response.body)["response"];
    
    if(res == "Wrong password") {
      setState(() {
        _invalid = "Wrong Password";
        _loading = false;
      });

      return;
    }

    if(res == "Logged In") {
      if (!mounted) return;

      setState(() => _loading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage(title: "Smart Home",)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _ipAddressController,
                decoration: const InputDecoration(
                  hintText: "IP Address",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo),
                  ),
                ),
              ),
            ),

            TextField(
              controller: _passwordController,
              obscureText: true,
              onEditingComplete: _login,
              decoration: InputDecoration(
                hintText: "Password",
                errorText: _invalid,
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
                ),
                onPressed: _login,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: _loading,
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.indigo.shade900,
                          strokeWidth: 3,
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
