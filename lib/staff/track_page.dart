import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_psm/pages/login_page.dart';
import 'package:fyp_psm/staff/car_rental_page.dart';
import 'package:fyp_psm/staff/cust_booking_page.dart';
import 'package:fyp_psm/staff/report_page.dart';
import 'package:fyp_psm/staff/custdetails_page.dart';
import 'package:permission_handler/permission_handler.dart';

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
        automaticallyImplyLeading: false,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('booking')
            .where('status', isEqualTo: 'Ongoing')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var ongoingBookings = snapshot.data!.docs;

          // Filter out bookings where isTrackingEnabled is false
          ongoingBookings = ongoingBookings.where((booking) => booking['isTrackingEnabled'] == true).toList();

          if (ongoingBookings.isEmpty) {
            return Center(
              child: Text(
                'No Ongoing Bookings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: ongoingBookings.length,
            itemBuilder: (context, index) {
              var booking = ongoingBookings[index];
              return BookingCard(booking: booking);
            },
          );
        },
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
            label: 'Generate Report',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CustDetailsPage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StaffCarRentalPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CustomerBookingPage()),
              );
              break;
            case 3:
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ReportPage()),
              );
              break;
          }
        },
      ),
      backgroundColor: Color.fromARGB(255, 255, 217, 195),
    );
  }
}

class BookingCard extends StatelessWidget {
  final DocumentSnapshot booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  void _showLiveTrackModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          child: LiveTrackPage(bookingId: booking.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDateTime = booking['startDateTime'].toDate();
    String brand = booking['brand'];
    String carModel = booking['carModel'];
    String plateNumber = booking['plateNumber'];
    String status = booking['status'];
    Color statusColor = status == 'Ongoing' ? Colors.blue : Colors.purple;

    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          'Start Date & Time: ${DateFormat('dd-MM-yyyy hh:mm a').format(startDateTime)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Brand: $brand'),
            Text('Model: $carModel'),
            Text('Plate Number: $plateNumber'),
            Text(
              'Status: $status',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showLiveTrackModal(context);
              },
              child: Text('Track'),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveTrackPage extends StatefulWidget {
  final String bookingId;

  const LiveTrackPage({Key? key, required this.bookingId}) : super(key: key);

  @override
  State<LiveTrackPage> createState() => _LiveTrackPageState();
}

class _LiveTrackPageState extends State<LiveTrackPage> {
  LatLng? _currentPosition;
  final MapController _mapController = MapController();
  String? _latitude;
  String? _longitude;
  bool _isTrackingEnabled = true;
  StreamSubscription<DocumentSnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _fetchInitialLocation();
  }

  Future<void> _fetchInitialLocation() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      _subscription = FirebaseFirestore.instance
          .collection('booking')
          .doc(widget.bookingId)
          .snapshots()
          .listen((bookingDoc) {
        if (bookingDoc.exists && mounted) {
          setState(() {
            _isTrackingEnabled = bookingDoc['isTrackingEnabled'];
            if (_isTrackingEnabled) {
              double initialLatitude = bookingDoc['currentLatitude'];
              double initialLongitude = bookingDoc['currentLongitude'];

              _currentPosition = LatLng(initialLatitude, initialLongitude);
              _latitude = initialLatitude.toString();
              _longitude = initialLongitude.toString();

              _mapController.move(_currentPosition!, 15.0);
            }
          });
        }
      });
    } else if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: _isTrackingEnabled
          ? (_currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: _currentPosition,
                          zoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: _currentPosition!,
                                child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Latitude: ${_latitude ?? 'Loading...'}",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Longitude: ${_longitude ?? 'Loading...'}",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ))
          : Center(
              child: Text(
                'Customer Has Ended the Session',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
