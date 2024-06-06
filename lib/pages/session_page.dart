import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_psm/pages/fuel_page.dart';
import 'package:fyp_psm/pages/home_page.dart';
import 'package:fyp_psm/pages/mybooking_page.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fyp_psm/pages/session_state.dart';
import 'dart:async';

class SessionPage extends StatefulWidget {
  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isPageLocked = true;
  DateTime? nearestBookingStart;
  String bookingId = "";
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    fetchNearestUpcomingBooking();
  }

  void fetchNearestUpcomingBooking() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('email', isEqualTo: user.email)
        .where('status', isEqualTo: 'Upcoming')
        .orderBy('startDateTime')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var booking = snapshot.docs.first;
      setState(() {
        nearestBookingStart = booking['startDateTime'].toDate();
        bookingId = booking.id;
        isPageLocked = nearestBookingStart!.isAfter(DateTime.now());
      });
    } else {
      setState(() {
        nearestBookingStart = null;
        isPageLocked = true; // No upcoming bookings
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = Provider.of<SessionState>(context);

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
            if (nearestBookingStart != null)
              Column(
                children: [
                  Text(
                    "COUNTDOWN",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  CountdownTimer(nearestBookingStart: nearestBookingStart!, onCountdownComplete: fetchNearestUpcomingBooking),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isPageLocked ? showSkipConfirmation : null,
                    child: Text("Skip"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isPageLocked || sessionState.isSessionStarted ? null : () {
                      sessionState.startSession();
                    },
                    child: Text("Start Session"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: sessionState.isSessionStarted ? () {
                      showFuelPageConfirmation(sessionState);
                    } : null,
                    child: Text("End Session"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  buildUpcomingBookingDetails(),
                ],
              ),
            if (nearestBookingStart == null)
              Text(
                'No Upcoming Booking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        currentIndex: 2,
        onTap: (int index) {
          switch (index) {
            case 0:
              navigateToPage(HomePage());
              break;
            case 1:
              navigateToPage(MyBookingPage());
              break;
            case 2:
              break;
          }
        },
      ),
    );
  }

  void showFuelPageConfirmation(SessionState sessionState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Proceed to Fuel Update Form"),
          content: Text("It is advised to refuel the car to avoid penalty. Do you really wish to proceed to the Fuel Update Form?"),
          actions: [
            TextButton(
              onPressed: () {
                sessionState.endSession();
                Navigator.of(context).pop();
                navigateToFuelPage();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void navigateToFuelPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FuelPage(bookingId: bookingId)), // Pass the bookingId
    );
  }

  void navigateToPage(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void showSkipConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Skip Lock"),
          content: Text("Are you sure you want to skip the lock and start the session?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isPageLocked = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Widget buildUpcomingBookingDetails() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('booking').doc(bookingId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData) {
          return Text('No Upcoming Booking');
        }

        final booking = snapshot.data!;
        DateTime startDateTime = booking['startDateTime'].toDate();
        String brand = booking['brand'];
        String carModel = booking['carModel'];
        String plateNumber = booking['plateNumber'];
        String status = Provider.of<SessionState>(context).isSessionStarted ? 'Ongoing' : 'Upcoming';
        Color statusColor = Provider.of<SessionState>(context).isSessionStarted ? Colors.blue : Colors.purple;

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
              ],
            ),
          ),
        );
      },
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final DateTime nearestBookingStart;
  final VoidCallback onCountdownComplete;

  CountdownTimer({required this.nearestBookingStart, required this.onCountdownComplete});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _timeRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.nearestBookingStart.difference(DateTime.now());
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_timeRemaining.inSeconds > 0) {
          _timeRemaining -= Duration(seconds: 1);
        } else {
          _timeRemaining = Duration.zero;
          timer.cancel();
          widget.onCountdownComplete(); // Call the callback when countdown completes
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${_timeRemaining.inHours}h ${_timeRemaining.inMinutes.remainder(60)}m ${_timeRemaining.inSeconds.remainder(60)}s",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        LinearProgressIndicator(
          value: (_timeRemaining.inSeconds > 0)
              ? _timeRemaining.inSeconds / widget.nearestBookingStart.difference(DateTime.now()).inSeconds
              : 0,
        ),
      ],
    );
  }
}
