// import 'package:flutter/material.dart';
// import 'package:pet_feeder/screens/device_control/deviceControl.dart';
// import 'package:pet_feeder/screens/food_control/foodControl.dart';
// import 'package:pet_feeder/screens/food_level/foodLevel.dart';
// import 'package:pet_feeder/screens/food_schedule/foodSchedule.dart';
// import 'package:pet_feeder/screens/home/home.dart';

// class BottomNavBar extends StatefulWidget {
//   const BottomNavBar({Key? key}) : super(key: key);
//   @override
//   State<BottomNavBar> createState() => _BottomNavBar();
// }

// class _BottomNavBar extends State<BottomNavBar> {
//   int _selectedIndex = 0;

//   static const List<Widget> _pages = <Widget>[
//     DeviceControl(),
//     FoodControl(),
//     FoodLevel(),
//     FoodSchedule(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.devices),
//             label: 'Device Control',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.fastfood),
//             label: 'Food Control',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.local_dining),
//             label: 'Food Level',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.schedule),
//             label: 'Food Schedule',
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pet_feeder/screens/device_control/deviceControl.dart';
import 'package:pet_feeder/screens/food_control/foodControl.dart';
import 'package:pet_feeder/screens/food_level/foodLevel.dart';
import 'package:pet_feeder/screens/food_schedule/foodSchedule.dart';
import 'package:pet_feeder/screens/home/home.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;

  const BottomNavBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  // Screens for each tab
  static const List<Widget> _pages = <Widget>[
    Home(),
    DeviceControl(),
    FoodControl(),
    FoodLevel(),
    FoodSchedule(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set the initial tab
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the selected page is Home
    if (_selectedIndex == 0) {
      return _pages[
          _selectedIndex]; // Display only the Home page without a navigation bar
    }
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Add Home tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Device',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining),
            label: 'Level',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
