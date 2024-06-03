import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_psm/pages/login_page.dart';
import 'package:fyp_psm/staff/car_rental_page.dart';
import 'package:fyp_psm/staff/cust_booking_page.dart';
import 'package:fyp_psm/staff/report_page.dart';
import 'package:fyp_psm/staff/custdetails_page.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Track Page", // Placeholder text for the main page
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showLiveTrackModal(context);
              },
              child: Text('Track'),
            ),
          ],
        ),
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
            label: 'Cust Booking',
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
        currentIndex: 3, // Set the default selected index to "Verification"
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StaffCarRentalPage()),
              );
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

  void _showLiveTrackModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          child: LiveTrackPage(),
        );
      },
    );
  }
}

class LiveTrackPage extends StatefulWidget {
  const LiveTrackPage({super.key});

  @override
  State<LiveTrackPage> createState() => _LiveTrackPageState();
}

class _LiveTrackPageState extends State<LiveTrackPage> {
  late Timer _timer;
  LatLng _currentPosition = LatLng(1.851751, 103.069315); // Initial position: House 115
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _startMockTracking();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startMockTracking() {
    Random random = Random();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _currentPosition = LatLng(
          _currentPosition.latitude + (random.nextDouble() - 0.5) * 0.001,
          _currentPosition.longitude + (random.nextDouble() - 0.5) * 0.001,
        );
      });

      _mapController.move(_currentPosition, 15.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        centerTitle: true,
        title: Text(
          "Live Track",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _currentPosition,
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: _currentPosition,
                child: Container(
                  child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
