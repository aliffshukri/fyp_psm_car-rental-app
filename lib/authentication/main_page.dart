import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_psm/pages/login_page.dart';
import '../pages/home_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(
              child: Text("Error occurred. Please try again."),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            return HomePage();
          } else {
            return LoginPage(
              showRegisterPage: () {
                // Handle the logic to show the register page
              },
            );
          }
        },
      ),
    );
  }
}
