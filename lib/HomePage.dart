import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_home/LoginPage.dart';
import 'package:smart_home/utils/request.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? temperature;
  String words = "";

  final TextEditingController _lcdTextController = TextEditingController();

  final SpeechToText _speechToText = SpeechToText();

  @override
  void initState() {
    super.initState();

    _initSpeech();

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) return;

      var response = await Request.get("/getTemperature");
      String res = jsonDecode(response.body)["response"];

      if (res == "You are not logged In!") {
        return;
      }

      setState(() {
        temperature = res;
      });
    });
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  Map<String, bool> leds = {
    "1": false,
    "2": false,
    "3": false,
    "4": false,
  };

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    words = result.recognizedWords.toLowerCase();

    _stopListening();

    if(! result.finalResult) {
      return;
    }

    if(words.contains("door")) {
      Request.get("door");

      return;
    }

    if(words.contains("garage")) {
      Request.get("garage");

      return;
    }

    if(words.contains("room")) {
      _toggleLEDs("3");

      return;
    }

    if(words.contains("toilet")) {
      _toggleLEDs("1");

      return;
    }
  }


  void _toggleLEDs(String led) async {
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
      MaterialPageRoute(
          builder: (context) => const LoginPage(
                title: "Login Page",
              )),
    );
  }

  void _openBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: TextField(
                      onEditingComplete: _sendLineToLCD,
                      maxLength: 14,
                      decoration: const InputDecoration(
                        hintText: 'Todo list',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      controller: _lcdTextController,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ));
  }

  void _sendLineToLCD() {
    String line = _lcdTextController.value.text;

    if (line.isEmpty) {
      Request.get("text", {
        "line": " ",
      });

      return;
    }
    Request.get("text", {
      "line": line,
    });
  }

  void _ringBell() {
    Request.get("buzz");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.power_settings_new_outlined)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
      body: Center(
        child: ListView(
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
                            color: Colors.indigo.shade800),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  ElevatedButton(
                    onPressed: () => _toggleLEDs("3"),
                    style: ButtonStyle(
                      padding:
                      MaterialStateProperty.all(const EdgeInsets.all(15)),
                      backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.lightbulb,
                          size: 45,
                          color: Colors.orange,
                        ),
                        Text(
                          "Main Room",
                          style: TextStyle(
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () => _toggleLEDs("1"),
                    style: ButtonStyle(
                      padding:
                      MaterialStateProperty.all(const EdgeInsets.all(15)),
                      backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.lightbulb,
                          size: 45,
                          color: Colors.orange,
                        ),
                        Text(
                          "Toilet",
                          style: TextStyle(
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
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
                    onPressed: _ringBell,
                    style: ButtonStyle(
                      padding:
                      MaterialStateProperty.all(const EdgeInsets.all(15)),
                      backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.surround_sound,
                          size: 45,
                          color: Colors.black,
                        ),
                      ],
                    ),
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
                    onPressed: () => Request.get("door"),
                    style: ButtonStyle(
                      padding:
                      MaterialStateProperty.all(const EdgeInsets.all(15)),
                      backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.door_back_door,
                          size: 45,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () => Request.get("garage"),
                    style: ButtonStyle(
                      padding:
                      MaterialStateProperty.all(const EdgeInsets.all(15)),
                      backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.door_front_door,
                          size: 45,
                          color: Colors.black,
                        ),
                      ],
                    ),
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
              child: Text(words),
            ),


            ElevatedButton(
              onPressed: _openBottomSheet,
              child: const Text("Set LCD Text"),
            ),
          ],
        ),
      ),
    );
  }
}
