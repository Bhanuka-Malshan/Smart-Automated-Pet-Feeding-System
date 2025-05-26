import 'package:flutter/material.dart';
import 'package:pet_feeder/models/UserModel.dart';
import 'package:pet_feeder/screens/auth/login.dart';
import 'package:pet_feeder/screens/bottomNavBar.dart';
import 'package:pet_feeder/screens/home/home.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    if (user == null) {
      return Login();
    } else {
      return Home();
    }
  }
}
