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

  Future<void> _disableAccount(String customerId) async {
  try {
    // Get the current value of 'isDisabled' field
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('customer').doc(customerId).get();
    bool currentStatus = userDoc['isDisabled'] ?? false;

    // Toggle the value
    await FirebaseFirestore.instance.collection('customer').doc(customerId).update({
      'isDisabled': !currentStatus,
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
    actions: [
      IconButton(
        icon: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('customer')
              .where('isVerified', isEqualTo: false)
              .snapshots(),
          builder: (context, snapshot) {
            int waitingCount = 0;
            if (snapshot.hasData) {
              waitingCount = snapshot.data!.docs.length;
            }
            return Stack(
              children: [
                Icon(Icons.inbox, size: 40.0),
                if (waitingCount > 0)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$waitingCount',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VerifyCustomerAccountsPage()),
          );
        },
      ),
      SizedBox(width: 8), // Add some space between the icon and the title
      Expanded(
        child: Center(
          child: Text(
            "Rental Car Management",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

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
      stream: FirebaseFirestore.instance.collection('customer').where('isVerified', isEqualTo: true).snapshots(),
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
                  trailing: IconButton(
                    icon: Icon(
                      isDisabled ? Icons.lock : Icons.lock_open,
                      color: isDisabled ? Colors.red : Colors.green,
                     /* isDisabled ? Icons.lock_open : Icons.lock,
                      color: isDisabled ? Colors.green : Colors.red,*/
                    ),
                    onPressed: () {
                      _showConfirmationDialog(
                        context,
                        isDisabled ? 'Enable Account' : 'Disable Account',
                        isDisabled
                            ? 'Are you sure you want to enable this account?'
                            : 'Are you sure you want to disable this account?',
                        () => _disableAccount(customerId),
                      );
                    },
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
    backgroundColor: Color.fromARGB(255, 255, 217, 195),
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
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Details',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        _buildDetailRow('Name:', customerData['name']),
                        _buildDetailRow('IC Number:', customerData['icNumber']),
                        _buildDetailRow('Address:', customerData['address']),
                        _buildDetailRow('Age:', customerData['age'].toString()),
                        _buildDetailRow('Phone Number:', customerData['phoneNumber']),
                        _buildDetailRow('Email:', customerData['email']),
                        SizedBox(height: 20),
                        Text(
                          'Documents',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        _buildDocumentLink(
                          context,
                          'Driving License',
                          customerData['drivingLicenseUrl'],
                        ),
                        _buildDocumentLink(
                          context,
                          'Malaysian ID',
                          customerData['malaysianIdUrl'],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentLink(BuildContext context, String label, String? url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: url != null
          ? GestureDetector(
              onTap: () => launch(url),
              child: Text(
                'View $label',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            )
          : Text('$label not available'),
    );
  }
}





class VerifyCustomerAccountsPage extends StatelessWidget {
  const VerifyCustomerAccountsPage({Key? key}) : super(key: key);

  Future<void> _verifyAccount(String customerId) async {
    await FirebaseFirestore.instance.collection('customer').doc(customerId).update({'isVerified': true});
  }

  Future<void> _deleteAccount(String customerId) async {
    // Fetch customer details from the 'customer' collection
    DocumentSnapshot customerDoc = await FirebaseFirestore.instance.collection('customer').doc(customerId).get();
    Map<String, dynamic> customerData = customerDoc.data() as Map<String, dynamic>;

    // Add customer details to 'nonverifyCust' collection
    await FirebaseFirestore.instance.collection('nonverifyCust').doc(customerId).set(customerData);

    // Delete customer document from the 'customer' collection
    await FirebaseFirestore.instance.collection('customer').doc(customerId).delete();
  }

  Future<Map<String, dynamic>> _fetchCustomerDetails(String customerId) async {
    DocumentSnapshot customerDoc = await FirebaseFirestore.instance.collection('customer').doc(customerId).get();
    Map<String, dynamic> customerData = customerDoc.data() as Map<String, dynamic>;

    Reference storageRef = FirebaseStorage.instance.ref().child('files/$customerId');

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

  void _showCustomerDetails(BuildContext context, Map<String, dynamic> customerDetails, String customerId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Customer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Name: ${customerDetails['name']}'),
                Text('IC Number: ${customerDetails['icNumber']}'),
                Text('Address: ${customerDetails['address']}'),
                Text('Age: ${customerDetails['age']}'),
                Text('Phone Number: ${customerDetails['phoneNumber']}'),
                Text('Email: ${customerDetails['email']}'),
                SizedBox(height: 20),
                Text('Documents', style: TextStyle(fontWeight: FontWeight.bold)),
                customerDetails['drivingLicenseUrl'] != null
                    ? GestureDetector(
                        onTap: () => launch(customerDetails['drivingLicenseUrl']),
                        child: Text('View Driving License', style: TextStyle(color: Colors.blue)),
                      )
                    : Text('Driving License not available'),
                customerDetails['malaysianIdUrl'] != null
                    ? GestureDetector(
                        onTap: () => launch(customerDetails['malaysianIdUrl']),
                        child: Text('View Malaysian ID', style: TextStyle(color: Colors.blue)),
                      )
                    : Text('Malaysian ID not available'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _verifyAccount(customerId);
                        Navigator.of(context).pop();
                      },
                      child: Text('Verify'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _deleteAccount(customerId);
                        Navigator.of(context).pop();
                      },
                      child: Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Customer Accounts"),
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('customer')
            .where('isVerified', isEqualTo: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final customers = snapshot.data!.docs;
          if (customers.isEmpty) {
            return Center(child: Text('No accounts to verify'));
          }
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customerData = customers[index].data() as Map<String, dynamic>;
              final customerId = customers[index].id;
              final fullName = customerData['name'];
              final phoneNumber = customerData['phoneNumber'];
              final customerEmail = customerData['email'];

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
                    onTap: () async {
                      Map<String, dynamic> customerDetails = await _fetchCustomerDetails(customerId);
                      _showCustomerDetails(context, customerDetails, customerId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      backgroundColor: Color.fromARGB(255, 255, 217, 195),
    );
  }
}
