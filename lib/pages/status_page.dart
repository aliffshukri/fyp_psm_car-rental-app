import 'package:flutter/material.dart';
import 'package:fyp_psm/pages/login_page.dart';

class TrackStatus extends StatefulWidget {
  const TrackStatus({super.key});

  @override
  State<TrackStatus> createState() => _TrackStatusState();
}

class _TrackStatusState extends State<TrackStatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Track your Account Status",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
        
      ),
      body: const Placeholder(), // Placeholder content, replace with your actual content
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {  },)),
            );
          },
          child: Text("Return to Login"),
        ),
      ),
    );
  }
}
