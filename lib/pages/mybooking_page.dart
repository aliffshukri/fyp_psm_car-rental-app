import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_psm/pages/home_page.dart';
import 'package:fyp_psm/pages/session_page.dart';
import 'package:intl/intl.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({Key? key}) : super(key: key);

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Add this line to remove the back button
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('booking')
            .where('email', isEqualTo: user.email)
            .orderBy('startDateTime', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          // Sort the bookings list to ensure Upcoming bookings appear above Completed ones
          bookings.sort((a, b) {
            DateTime endDateTimeA = a['endDateTime'].toDate();
            DateTime endDateTimeB = b['endDateTime'].toDate();
            bool isPastA = endDateTimeA.isBefore(DateTime.now()) || endDateTimeA.isAtSameMomentAs(DateTime.now());
            bool isPastB = endDateTimeB.isBefore(DateTime.now()) || endDateTimeB.isAtSameMomentAs(DateTime.now());

            if (isPastA && !isPastB) {
              return 1; // A is Completed, B is Upcoming, so B comes first
            } else if (!isPastA && isPastB) {
              return -1; // A is Upcoming, B is Completed, so A comes first
            } else {
              // Both are either Upcoming or Completed, sort based on startDateTime
              return a['startDateTime'].compareTo(b['startDateTime']);
            }
          });

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              DateTime endDateTime = booking['endDateTime'].toDate();
              bool isPast = endDateTime.isBefore(DateTime.now()) || endDateTime.isAtSameMomentAs(DateTime.now());
              String status = isPast ? 'Completed' : 'Upcoming';

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    'Start Date & Time: ${DateFormat('dd-MM-yyyy hh:mm a').format(booking['startDateTime'].toDate())}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Brand: ${booking['brand']}'),
                      Text('Model: ${booking['carModel']}'),
                      Text('Plate Number: ${booking['plateNumber']}'),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: status == 'Upcoming' ? Colors.purple : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyBookingDetailsPage(bookingData: booking.data() as Map<String, dynamic>),
                      ),
                    );
                  },
                ),
              );
            },
          );

        },
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


class MyBookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  MyBookingDetailsPage({required this.bookingData});

  @override
  Widget build(BuildContext context) {
    DateTime endDateTime = bookingData['endDateTime'].toDate();
    String status = endDateTime.isBefore(DateTime.now()) || endDateTime.isAtSameMomentAs(DateTime.now())
        ? 'Completed'
        : 'Upcoming';

    // Update Firestore when status changes to "Completed"
    if (status == 'Completed' && !bookingData['isPast']) {
      FirebaseFirestore.instance.collection('booking').doc(bookingData['bookingId']).update({
        'isPast': true,
      });
    }

    // Determine rental period
    String rentalPeriod;
    if (bookingData['rentalPeriodDays'] != 0) {
      rentalPeriod = '${bookingData['rentalPeriodDays']} days';
    } else if (bookingData['rentalPeriodHours'] != 0) {
      rentalPeriod = '${bookingData['rentalPeriodHours']} hours';
    } else {
      rentalPeriod = 'N/A';
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Booking Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSection(
              Text(
                'Status: $status',
                style: TextStyle(
                  fontSize: 18,
                  color: status == 'Upcoming' ? Colors.purple : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            _buildSection(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Your Details'),
                  _buildDetailRow('Name', bookingData['name']),
                  _buildDetailRow('Phone Number', bookingData['phoneNumber']),
                  _buildDetailRow('Email', bookingData['email']),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildSection(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Rental Session Details'),
                  _buildDetailRow('Start Date & Time', DateFormat('dd-MM-yyyy hh:mm a').format(bookingData['startDateTime'].toDate())),
                  _buildDetailRow('End Date & Time', DateFormat('dd-MM-yyyy hh:mm a').format(endDateTime)),
                  _buildDetailRow('Rental Period', rentalPeriod),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildSection(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Car Details'),
                  _buildDetailRow('Brand', bookingData['brand']),
                  _buildDetailRow('Model', bookingData['carModel']),
                  _buildDetailRow('Plate Number', bookingData['plateNumber']),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildSection(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Booking Details'),
                  _buildDetailRow('Booking Made', DateFormat('dd-MM-yyyy hh:mm a').format(bookingData['bookingDateTime'].toDate())),
                  _buildDetailRow('Total Price', '\RM ${bookingData['totalPrice'].toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
    );
  }

  Widget _buildSection(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            spreadRadius: 2.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
