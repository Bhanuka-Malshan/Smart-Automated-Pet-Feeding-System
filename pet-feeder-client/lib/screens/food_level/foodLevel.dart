import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pet_feeder/screens/appBar.dart';
import 'package:pet_feeder/services/firebaseDatabaseService.dart';

class FoodLevel extends StatefulWidget {
  const FoodLevel({super.key});
  @override
  State<StatefulWidget> createState() => _FoodLevelState();
}

class _FoodLevelState extends State<FoodLevel> {
  final FirebasedatabaseService _databaseService = FirebasedatabaseService();

  double foodLevelPercentage = 0;

  @override
  void initState() {
    super.initState();
    _listenToFoodLevelUpdates();
  }

  void _listenToFoodLevelUpdates() {
    _databaseService.listenToData('mobile/level').listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          foodLevelPercentage = double.tryParse(data.toString()) ?? 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Vertical Bar
            Container(
              width: 200, // Wider bar
              height: 550, // Taller bar
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Filled portion of the bar
                  Container(
                    width: 200,
                    height: 550 * foodLevelPercentage,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  // Percentage text
                  Positioned(
                    bottom: 20,
                    child: Text(
                      '${(foodLevelPercentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
