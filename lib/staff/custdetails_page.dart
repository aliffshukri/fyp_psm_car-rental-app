import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_psm/pages/login_page.dart';
import 'package:fyp_psm/staff/car_rental_page.dart';
import 'package:fyp_psm/staff/cust_booking_page.dart';
import 'package:fyp_psm/staff/report_page.dart';
import 'package:fyp_psm/staff/track_page.dart';
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

  Future<void> _deleteAccount(String customerId, String customerEmail) async {
    try {
      // Fetch the user by email
      List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(customerEmail);
      if (signInMethods.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email == customerEmail) {
          await FirebaseFirestore.instance.collection('customer').doc(customerId).delete();
          await user.delete();
        } else {
          throw Exception('User not found or email mismatch');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  Future<void> _disableAccount(String customerId, bool isDisabled) async {
    try {
      await FirebaseFirestore.instance.collection('customer').doc(customerId).update({
        'isDisabled': isDisabled,
      });
    } catch (e) {
      print('Error disabling/enabling account: $e');
    }
  }

  Future<void> _checkUserStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('customer').doc(user.uid).get();
      if (userDoc.exists) {
        bool isDisabled = userDoc['isDisabled'];
        if (isDisabled) {
          // Sign out the user if they are disabled
          await FirebaseAuth.instance.signOut();
          // Optionally show a message to the user
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Your account has been disabled.'),
          ));
        }
      }
    }
  }

  void _showConfirmationDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
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
              final customerId = customers[index].id;
              final fullName = customerData['name'];
              final phoneNumber = customerData['phoneNumber'];
              final customerEmail = customerData['email'];
              final isDisabled = customerData['isDisabled'] ?? false;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Full Name: $fullName'),
                        Text('Phone Number: $phoneNumber'),
                        Text('Email: $customerEmail'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isDisabled ? Icons.lock_open : Icons.lock,
                            color: isDisabled ? Colors.green : Colors.red,
                          ),
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              isDisabled ? 'Enable Account' : 'Disable Account',
                              isDisabled
                                  ? 'Are you sure you want to enable this account?'
                                  : 'Are you sure you want to disable this account?',
                              () => _disableAccount(customerId, !isDisabled),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              'Delete Account',
                              'Are you sure you want to delete this account?',
                              () => _deleteAccount(customerId, customerEmail),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MoreCustDetailsPage(customerEmail: customerEmail)),
                      );
                    },
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
            label: 'Generate Report',
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
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('customer')
        .where('email', isEqualTo: customerEmail)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No customer found with the given email');
    }

    DocumentSnapshot customerDoc = snapshot.docs.first;
    Map<String, dynamic> customerData = customerDoc.data() as Map<String, dynamic>;

    String uid = customerDoc.id;
    Reference storageRef = FirebaseStorage.instance.ref().child('files/$uid');

    try {
      String drivingLicenseUrl = await storageRef.child('driving_license.pdf').getDownloadURL();
      String malaysianIdUrl = await storageRef.child('malaysian_id.pdf').getDownloadURL();

      customerData['drivingLicenseUrl'] = drivingLicenseUrl;
      customerData['malaysianIdUrl'] = malaysianIdUrl;
    } catch (e) {
      print('Error fetching files from storage: $e');
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  Text('Age: ${customerData['age']}'),
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
