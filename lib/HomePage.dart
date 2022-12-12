import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_home/LoginPage.dart';
import 'package:smart_home/utils/request.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? temperature;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if(!mounted) return;

      var response = await Request.get("/getTemperature");
      String res = jsonDecode(response.body)["response"];

      if(res == "You are not logged In!") {
        return;
      }

      setState(() {
        temperature = res;
      });
    });
  }


  Map<String, bool> leds = {
    "red": false,
    "yellow": false,
  };

  void _toggleLEDs(String led) async{
    var response = await Request.get("led/$led");

    var res = jsonDecode(response.body)["response"];

    setState(() {
      leds[led] = res == "1" ? true : false;
    });
  }


  void _logout() {
    Request.get("logout");

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage(title: "Login Page",)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.power_settings_new_outlined)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Temperature",
                    style: TextStyle(
                      color: Colors.indigo.shade400,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temperature ?? "-",
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo.shade800
                        ),
                      ),

                      Text(
                        "°C",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.indigo.shade600.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _toggleLEDs("red"),
                  child: const Text("Red Led"),
                ),

                ElevatedButton(
                  onPressed: () => _toggleLEDs("yellow"),
                  child: const Text("Yellow Led"),
                ),

              ],
            ),
          ),

          ],
        ),
      ),
    );
  }
}
