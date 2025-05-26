import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pet_feeder/screens/appBar.dart';
import 'package:pet_feeder/services/firebaseDatabaseService.dart';

class FoodSchedule extends StatefulWidget {
  const FoodSchedule({super.key});
  @override
  State<StatefulWidget> createState() => _FoodScheduleState();
}

class _FoodScheduleState extends State<FoodSchedule> {
  final FirebasedatabaseService _databaseService = FirebasedatabaseService();
  List<TimeOfDay> _scheduledTimes =
      []; // List to store multiple scheduled times

  @override
  void initState() {
    super.initState();
    _listenToScheduledTimes(); // Listen for updates from Firebase
  }

  // Convert TimeOfDay to a 24-hour format String (e.g., "22:30")
  String _timeOfDayToString(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // Function to show the time picker and add the selected time to the list
  Future<void> _addScheduledTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: true), // Force 24-hour format
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _scheduledTimes.add(pickedTime); // Add the selected time to the list
      });

      // Convert the list of TimeOfDay objects to a list of Strings
      List<String> serializedTimes =
          _scheduledTimes.map((time) => _timeOfDayToString(time)).toList();

      // Update Firebase with the serialized list
      Map<String, dynamic> newData = {'schedule': serializedTimes};
      await _databaseService.updateData('mobile', newData);

      print("Scheduled times updated in Firebase: $serializedTimes");
    }
  }

  // Function to remove a scheduled time
  void _removeScheduledTime(int index) {
    setState(() {
      _scheduledTimes.removeAt(index); // Remove the time at the specified index
    });

    // Convert the list of TimeOfDay objects to a list of Strings
    List<String> serializedTimes =
        _scheduledTimes.map((time) => _timeOfDayToString(time)).toList();

    // Update Firebase with the serialized list
    Map<String, dynamic> newData = {'schedule': serializedTimes};
    _databaseService.updateData('mobile', newData);

    print("Scheduled times updated in Firebase: $serializedTimes");
  }

  // Listen for realtime updates from Firebase
  void _listenToScheduledTimes() {
    _databaseService
        .listenToData('mobile/schedule')
        .listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is List) {
        setState(() {
          // Convert the list of Strings back to TimeOfDay objects
          _scheduledTimes = data.map((timeString) {
            List<String> parts = timeString.split(':');
            return TimeOfDay(
                hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }).toList();
        });
        print("Scheduled times retrieved from Firebase: $_scheduledTimes");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Button to add a new scheduled time
            // ElevatedButton(
            //   onPressed: () => _addScheduledTime(context),
            //   style: ElevatedButton.styleFrom(
            //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            //     textStyle: TextStyle(fontSize: 18),
            //   ),
            //   child: Text('Add Scheduled Time'),
            // ),

            // SizedBox(height: 20),
            // Display the list of scheduled times
            Expanded(
              child: _scheduledTimes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center vertically
                        children: [
                          Icon(
                            Icons.schedule, // Clock icon for scheduling
                            size: 50, // Icon size
                            color: Colors.grey, // Icon color
                          ),
                          const SizedBox(
                              height: 10), // Space between icon and text
                          Text(
                            'No scheduled times added yet.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _scheduledTimes.length,
                      itemBuilder: (context, index) {
                        final time = _scheduledTimes[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              'Scheduled Time: ${time.format(context)}',
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeScheduledTime(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            GestureDetector(
              onTap: () =>
                  _addScheduledTime(context), // Call the function on tap
              child: Center(
                child: Container(
                  width: 200, // Width of the button
                  height: 40, // Height of the button
                  decoration: BoxDecoration(
                    color: Colors.teal, // Button color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
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
                    children: [
                      Icon(
                        Icons.timer, // Timer icon
                        color: Colors.white,
                        size: 20, // Icon size
                      ),
                      const SizedBox(width: 8), // Space between icon and text
                      Text(
                        'Add Scheduled', // Button label
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
      ),
    );
  }
}
