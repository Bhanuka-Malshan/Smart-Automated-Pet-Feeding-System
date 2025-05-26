import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:pet_feeder/screens/appBar.dart';
import 'package:pet_feeder/services/firebaseDatabaseService.dart';
import 'package:http/http.dart' as http;

class FoodControl extends StatefulWidget {
  const FoodControl({super.key});
  @override
  State<StatefulWidget> createState() => _FoodControlState();
}

class _FoodControlState extends State<FoodControl> {
  final FirebasedatabaseService _databaseService = FirebasedatabaseService();
  bool _isPlay = false;
  String url = "";
  bool isDoor = false;
  Future<void> _handleStart() async {}
  Future<void> _handleOpenDoor() async {
    // Add logic to open the door
    print('Opening door...');
    Map<String, dynamic> newData = {'door': 1};
    _databaseService.updateData("mobile", newData);
  }

  Future<void> _handleCloseDoor() async {
    // Add logic to close the door
    print('Closing door...');
    Map<String, dynamic> newData = {'door': 0};
    _databaseService.updateData("mobile", newData);
  }

  @override
  void initState() {
    super.initState();
    _getUrl(); // Call _getUrl when the page is loaded
    _getDoor();
  }

  Future<void> _getUrl() async {
    _databaseService.listenToData("stream/url").listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          url = data.toString();
          print(url + ":url");
        });
      }
    });
  }

  Future<void> _getDoor() async {
    _databaseService.listenToData("mobile/door").listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          isDoor = data == 1 ? true : false;
        });
      }
    });
  }

  Future<void> _startStream() async {
    final response = await http.get(Uri.parse(url + '/start_stream'));
    if (response.statusCode == 200) {
      setState(() {
        _isPlay = true;
      });
    } else {
      print('Failed to start stream');
    }
  }

  Future<void> _stopStream() async {
    final response = await http.get(Uri.parse(url + '/stop_stream'));
    if (response.statusCode == 200) {
      setState(() {
        _isPlay = false;
      });
    } else {
      print('Failed to stop stream');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity, // Replace with desired width
              height: 260, // Replace with desired height
              child: Card(
                color: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: _isPlay
                      ? Mjpeg(
                          isLive: true,
                          stream: url + '/video',
                          timeout: const Duration(seconds: 10),
                        )
                      : Container(), // Empty container when not playing
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _isPlay
                    ? null
                    : _startStream, // Disable onTap when _isPlay is true
                child: Center(
                  child: Container(
                    width: 130, // Width of the button
                    height: 40, // Height of the button
                    decoration: BoxDecoration(
                      color:
                          _isPlay ? Colors.grey : Colors.teal, // Button color
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center, // Center content
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center the row
                      children: const [
                        Icon(
                          Icons.play_arrow, // Play icon for "Start"
                          color: Colors.white,
                          size: 30, // Icon size
                        ),
                        SizedBox(width: 8), // Space between icon and text
                        Text(
                          'Start', // Button label
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20, // Font size
                            fontWeight: FontWeight.bold, // Bold font
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: !_isPlay ? null : _stopStream,
                child: Center(
                  child: Container(
                    width: 130, // Width of the button
                    height: 40, // Height of the button
                    decoration: BoxDecoration(
                      color:
                          !_isPlay ? Colors.grey : Colors.red, // Button color
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center, // Center content
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center the row
                      children: const [
                        Icon(
                          Icons.stop, // Stop icon for "Stop"
                          color: Colors.white,
                          size: 30, // Icon size
                        ),
                        SizedBox(width: 8), // Space between icon and text
                        Text(
                          'Stop', // Button label
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20, // Font size
                            fontWeight: FontWeight.bold, // Bold font
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60), // Add spacing between rows
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the content vertically
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Distribute the buttons across the row
                  children: [
                    GestureDetector(
                      onTap: _handleOpenDoor, // Call _handleOpenDoor on tap
                      child: Center(
                        child: Container(
                          width: 170, // Set a fixed width for the button
                          height: 100, // Height of the button
                          decoration: BoxDecoration(
                            color: !isDoor
                                ? Colors.grey
                                : Colors.blue, // Button color for "Open Door"
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2), // Shadow color
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          alignment: Alignment.center, // Center content
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center the content
                            children: const [
                              Icon(
                                Icons.lock_open, // Icon for "Open Door"
                                color: Colors.white,
                                size: 30, // Icon size
                              ),
                              SizedBox(width: 8), // Space between icon and text
                              Text(
                                'Open Door', // Button label
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20, // Font size
                                  fontWeight: FontWeight.bold, // Bold font
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleCloseDoor, // Call _handleCloseDoor on tap
                      child: Center(
                        child: Container(
                          width: 170, // Set a fixed width for the button
                          height: 100, // Height of the button
                          decoration: BoxDecoration(
                            color: isDoor
                                ? Colors.grey
                                : Colors.blue, // Button color for "Close Door"
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2), // Shadow color
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          alignment: Alignment.center, // Center content
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center the content
                            children: const [
                              Icon(
                                Icons.lock, // Icon for "Close Door"
                                color: Colors.white,
                                size: 30, // Icon size
                              ),
                              SizedBox(width: 8), // Space between icon and text
                              Text(
                                'Close Door', // Button label
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20, // Font size
                                  fontWeight: FontWeight.bold, // Bold font
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
