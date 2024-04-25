import 'package:flutter/material.dart';
import 'package:fyp_psm/pages/home_page.dart';
import 'package:fyp_psm/pages/session_page.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({Key? key}) : super(key: key);

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My Booking",
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
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Session',
          ),
        ],
        selectedItemColor: Colors.black,
        currentIndex: 1, // Set the current index to 1 for "My Booking" tab
        onTap: (int index) {
          // Handle bottom navigation item taps here
          switch (index) {
            case 0:
              // Navigate to home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 1:
              
              break;
            case 2:
              // Navigate to Session page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SessionPage()),
              );
              break;
          }
        },
      ),
    );
  }
}
