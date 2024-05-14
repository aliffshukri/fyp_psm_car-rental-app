import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_psm/pages/login_page.dart';
import 'package:fyp_psm/staff/car_rental_page.dart';
import 'package:fyp_psm/staff/cust_booking_page.dart';
import 'package:fyp_psm/staff/report_page.dart';
import 'package:fyp_psm/staff/track_page.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class CustDetailsPage extends StatefulWidget {
  const CustDetailsPage({Key? key}) : super(key: key);

  @override
  State<CustDetailsPage> createState() => _CustDetailsPageState();
}

class _CustDetailsPageState extends State<CustDetailsPage> {
  late String adminEmail;

  @override
  void initState() {
    super.initState();
    getAdminEmail();
  }

  Future<void> getAdminEmail() async {
    final currentUser = await FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        adminEmail = currentUser.email ?? '';
      });
    }
  }

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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('customer').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final customers = snapshot.data!.docs;
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customerData = customers[index].data() as Map<String, dynamic>;
              final fullName = customerData['name'];
              final phoneNumber = customerData['phoneNumber'];
              final customerEmail = customerData['email'];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoreCustDetailsPage(customerEmail: customerEmail)),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Full Name: $fullName'),
                      Text('Phone Number: $phoneNumber'),
                      Text('Email: $customerEmail'), // Display customer email
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Cust Details',
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
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (int index) {
          switch (index) {
            case 0:
              // Navigate to current page
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TrackPage()),
              );
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
    );
  }
}



class MoreCustDetailsPage extends StatelessWidget {
  final String customerEmail;

  const MoreCustDetailsPage({Key? key, required this.customerEmail}) : super(key: key);

  Future<Map<String, dynamic>> _fetchCustomerDetails() async {
    // Fetch customer details from Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('customer')
        .where('email', isEqualTo: customerEmail)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No customer found with the given email');
    }

    DocumentSnapshot customerDoc = snapshot.docs.first;
    Map<String, dynamic> customerData = customerDoc.data() as Map<String, dynamic>;

    // Fetch file URLs from Firebase Storage
    String uid = customerDoc.id;
    Reference storageRef = FirebaseStorage.instance.ref().child('files/$uid');

    try {
      String drivingLicenseUrl = await storageRef.child('driving_license.pdf').getDownloadURL();
      String malaysianIdUrl = await storageRef.child('malaysian_id.pdf').getDownloadURL();

      customerData['drivingLicenseUrl'] = drivingLicenseUrl;
      customerData['malaysianIdUrl'] = malaysianIdUrl;
    } catch (e) {
      print('Error fetching files from storage: $e');
      // Handle error, e.g., set URLs to null or empty
      customerData['drivingLicenseUrl'] = null;
      customerData['malaysianIdUrl'] = null;
    }

    return customerData;
  }

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
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchCustomerDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No customer data found'));
          } else {
            var customerData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Customer Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Name: ${customerData['name']}'),
                  Text('IC Number: ${customerData['icNumber']}'),
                  Text('Address: ${customerData['address']}'),
                  Text('Phone Number: ${customerData['phoneNumber']}'),
                  Text('Email: ${customerData['email']}'),
                  SizedBox(height: 20),
                  Text(
                    'Documents',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  customerData['drivingLicenseUrl'] != null
                      ? GestureDetector(
                          onTap: () => launch(customerData['drivingLicenseUrl']),
                          child: Text(
                            'View Driving License',
                            style: TextStyle(color: Colors.blue),
                          ),
                        )
                      : Text('Driving License not available'),
                  customerData['malaysianIdUrl'] != null
                      ? GestureDetector(
                          onTap: () => launch(customerData['malaysianIdUrl']),
                          child: Text(
                            'View Malaysian ID',
                            style: TextStyle(color: Colors.blue),
                          ),
                        )
                      : Text('Malaysian ID not available'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}







