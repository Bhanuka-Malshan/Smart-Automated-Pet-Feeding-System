import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_feeder/api/firebaseAPI.dart';
import 'package:pet_feeder/models/UserModel.dart';
import 'package:pet_feeder/screens/auth/login.dart';
import 'package:pet_feeder/screens/wrapper.dart';
import 'package:pet_feeder/services/auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAPI().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
        value: AuthService().user,
        initialData: UserModel(uid: ""),
        child: MaterialApp(
          routes: {
            '/login': (context) => Login(),
            // Add other routes here
          },
          debugShowCheckedModeBanner: false,
          title: 'Pet Feeder',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Wrapper(),
        ));
  }
}
