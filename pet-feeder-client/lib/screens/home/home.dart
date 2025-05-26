import 'package:flutter/material.dart';
import 'package:pet_feeder/screens/appBar.dart';
import 'package:pet_feeder/screens/bottomNavBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // Get the screen height
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Pet Feeder'),
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.teal,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       tooltip: 'Logout',
      //       onPressed: () {
      //         // Implement your logout functionality here
      //         Navigator.pushReplacementNamed(context, '/login');
      //       },
      //     ),
      //   ],
      // ),
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/dashboard.jpg', // Replace with your image path
              fit: BoxFit.cover, // Adjust how the image should fit
            ),
          ),
          // Content on top of the image
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Use a Column to stack the cards
                // Total height for the cards will be 2/3 of screen height
                Expanded(
                  child: Column(
                    children: [
                      // Each card will take 1/4 of the 2/3 screen height (for 4 cards)
                      Flexible(
                        child: _buildCard(
                          context,
                          title: 'Device Control',
                          icon: Icons.devices,
                          index: 1,
                          screenHeight: screenHeight,
                        ),
                      ),
                      Flexible(
                        child: _buildCard(
                          context,
                          title: 'Food Control',
                          icon: Icons.fastfood,
                          index: 2,
                          screenHeight: screenHeight,
                        ),
                      ),
                      Flexible(
                        child: _buildCard(
                          context,
                          title: 'Food Level',
                          icon: Icons.local_dining,
                          index: 3,
                          screenHeight: screenHeight,
                        ),
                      ),
                      Flexible(
                        child: _buildCard(
                          context,
                          title: 'Food Schedule',
                          icon: Icons.schedule,
                          index: 4,
                          screenHeight: screenHeight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required int index,
      required double screenHeight}) {
    return GestureDetector(
      onTap: () {
        // Navigate to the BottomNavBar and show the correct tab
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavBar(initialIndex: index),
          ),
        );
      },
      child: Card(
        elevation: 4,
        color: Colors.white.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: double.infinity,
          height:
              screenHeight * 0.20, // Each card takes up 1/4 of the 2/3 height
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.teal,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
