import 'package:flutter/material.dart';
import 'package:fyp_psm/pages/fuel_page.dart';
import 'package:fyp_psm/pages/home_page.dart';
import 'package:fyp_psm/pages/mybooking_page.dart';

class SessionPage extends StatefulWidget {
  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSessionStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Session Management",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isSessionStarted ? null : startSession,
              child: Text("Start Session"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSessionStarted ? endSession : null,
              child: Text("End Session"),
            ),
          ],
        ),
      ),
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
        currentIndex: 2, // Set the current index to 2 for "Session" tab
        onTap: (int index) {
          // Handle bottom navigation item taps here
          switch (index) {
            case 0:
              // Navigate to home page
              navigateToPage(HomePage());
              break;
            case 1:
              // Navigate to MyBooking page
              navigateToPage(MyBookingPage());
              break;
            case 2:
              // Do nothing if already on Session page
              break;
          }
        },
      ),
    );
  }

  void startSession() {
    setState(() {
      isSessionStarted = true;
    });
  }

  void endSession() {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text("End Session"),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
          content: Text("Did you already refill the fuel?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                navigateToFuelPage(); // Navigate to FuelPage
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                navigateToFuelPage(); // Navigate to FuelPage
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void navigateToFuelPage() {
    // Navigate to FuelPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FuelPage()),
    );
  }

  void navigateToPage(Widget page) {
    // Navigate to the specified page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
