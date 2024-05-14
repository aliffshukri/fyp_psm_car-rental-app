import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_psm/pages/login_page.dart';
import 'package:fyp_psm/staff/cust_booking_page.dart';
import 'package:fyp_psm/staff/report_page.dart';
import 'package:fyp_psm/staff/track_page.dart';
import 'package:fyp_psm/staff/custdetails_page.dart';

class StaffCarRentalPage extends StatefulWidget {
  @override
  _StaffCarRentalPageState createState() => _StaffCarRentalPageState();
}

class _StaffCarRentalPageState extends State<StaffCarRentalPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        centerTitle: true,
        title: Text(
          "Rental Car Management",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Navigate to the login page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {})),
              );
            },
            icon: Icon(
              Icons.logout,
              size: 40.0,
              color: const Color.fromARGB(255, 7, 7, 7),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: Center(
        child: Text(
          "Staff Car Rental Page", // Placeholder text for the main page
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the '+' button press (Add functionality)
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 173, 129, 80), // Change FAB background color
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Verification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental, size: 24),
            label: 'Car Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, size: 24),
            label: 'Customer Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 24),
            label: 'Track Customer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt, size: 24),
            label: 'Service Report',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey, // Set unselected item color
        currentIndex: 1,
        onTap: (int index) {
          // Handle bottom navigation item taps here
          switch (index) {
            case 0:
              // Navigate to verification page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CustDetailsPage()),
              );
              break;
            case 1:
              // Navigate to car details page (Main page)
              break;
            case 2:
              // Navigate to customer booking page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CustomerBookingPage()),
              );
              break;
            case 3:
              // Navigate to map page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TrackPage()),
              );
              break;
            case 4:
              // Navigate to service report page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ReportPage()),
              );
              break;
          }
        },
      ),
    );
  }
}
