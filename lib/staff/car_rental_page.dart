import 'package:flutter/material.dart';

class StaffCarRentalPage extends StatefulWidget {
  @override
  _StaffCarRentalPageState createState() => _StaffCarRentalPageState();
}

class _StaffCarRentalPageState extends State<StaffCarRentalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Rental Car Management",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            icon: Icon(Icons.person),
            label: 'Verification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: 'Car Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Customer Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Track Customer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Service Report',
          ),
        ],
        selectedItemColor: Colors.black,
        onTap: (int index) {
          // Handle bottom navigation item taps here
          switch (index) {
            case 0:
              // Navigate to customer verification page
              break;
            case 1:
              // Navigate to car details page (Main page)
              break;
            case 2:
              // Navigate to customer booking page
              break;
            case 3:
              // Navigate to map page
              break;
            case 4:
              // Navigate to service report page
              break;
          }
        },
      ),
    );
  }
}
