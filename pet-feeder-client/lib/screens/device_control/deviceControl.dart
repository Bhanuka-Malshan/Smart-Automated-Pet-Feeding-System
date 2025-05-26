import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pet_feeder/screens/appBar.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:pet_feeder/services/firebaseDatabaseService.dart';
import 'package:http/http.dart' as http;

class DeviceControl extends StatefulWidget {
  const DeviceControl({super.key});
  @override
  State<StatefulWidget> createState() => _DeviceControlState();
}

// class _DeviceControlState extends State<DeviceControl> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(),
//       body: Center(
//         child: Mjpeg(
//           isLive: true,
//           stream:
//               'https://71b4-43-252-15-33.ngrok-free.app/video', // Replace with Flask server URL
//           timeout: const Duration(seconds: 10),
//         ),
//       ),
//     );
//   }
// }

class _DeviceControlState extends State<DeviceControl> {
  final FirebasedatabaseService _databaseService = FirebasedatabaseService();
  bool _isPlay = false;
  bool _isRight = false;
  bool _isLeft = false;
  bool _isUp = false;
  bool _isDown = false;
  Future<void> _handleStart() async {}
  String url = "";

  @override
  void initState() {
    super.initState();
    _getUrl(); // Call _getUrl when the page is loaded
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

  Future<void> _stop() async {
    Map<String, dynamic> newData = {
      'left': 0,
      'down': 0,
      'right': 0,
      'up': 0,
    };
    _databaseService.updateData("mobile/device", newData);
  }

  Future<void> _left() async {
    Map<String, dynamic> newData = {
      'left': 1,
      'down': 0,
      'right': 0,
      'up': 0,
    };
    _databaseService.updateData("mobile/device", newData);
  }

  Future<void> _right() async {
    Map<String, dynamic> newData = {
      'left': 0,
      'down': 0,
      'right': 1,
      'up': 0,
    };
    _databaseService.updateData("mobile/device", newData);
  }

  Future<void> _up() async {
    Map<String, dynamic> newData = {
      'left': 0,
      'down': 0,
      'right': 0,
      'up': 1,
    };
    _databaseService.updateData("mobile/device", newData);
  }

  Future<void> _down() async {
    Map<String, dynamic> newData = {'left': 0, 'down': 1, 'right': 0, 'up': 0};
    _databaseService.updateData("mobile/device", newData);
  }

  Future<void> _go() async {
    Map<String, dynamic> newData = {'go': 1};
    _databaseService.updateData("mobile/device", newData);
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
                  // child: Mjpeg(
                  //   isLive: true,
                  //   stream: url + '/video', // Replace with Flask server URL
                  //   timeout: const Duration(seconds: 10),
                  // ),
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
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 0), // Increased vertical padding
            child: Column(
              children: [
                GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      print("Tap Down");
                      _up();
                      _isUp = true;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      print("Tap UP");
                      _stop();
                      _isUp = false;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      print("Tap Cancel");
                      _stop();
                      _isUp = false;
                    });
                  },
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.keyboard_arrow_up,
                      size: 70,
                      color: _isUp ? Colors.blue : Colors.black,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          print("Tap Down");
                          _left();
                          _isLeft = true;
                        });
                      },
                      onTapUp: (details) {
                        setState(() {
                          print("Tap UP");
                          _stop();
                          _isLeft = false;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          print("Tap Cancel");
                          _stop();
                          _isLeft = false;
                        });
                      },
                      child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.keyboard_arrow_left,
                          size: 70,
                          color: _isLeft ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                    ),
                    GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          print("Tap Down");
                          _right();
                          _isRight = true;
                        });
                      },
                      onTapUp: (details) {
                        setState(() {
                          print("Tap UP");
                          _stop();
                          _isRight = false;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          print("Tap Cancel");
                          _stop();
                          _isRight = false;
                        });
                      },
                      child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.keyboard_arrow_right,
                          size: 70,
                          color: _isRight ? Colors.blue : Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
                GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      print("Tap Down");
                      _down();
                      _isDown = true;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      print("Tap UP");
                      _stop();
                      _isDown = false;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      print("Tap Cancel");
                      _stop();
                      _isDown = false;
                    });
                  },
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 70,
                      color: _isDown ? Colors.blue : Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
