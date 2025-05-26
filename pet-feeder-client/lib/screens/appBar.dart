import 'package:flutter/material.dart';
import 'package:pet_feeder/services/auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({super.key});
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Pet Feeder'),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.teal,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () {
            // Implement your logout functionality here
            _auth.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
