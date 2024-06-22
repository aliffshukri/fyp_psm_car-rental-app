import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_psm/pages/login_page.dart';
import 'package:fyp_psm/staff/car_rental_page.dart';
import 'package:fyp_psm/staff/report_page.dart';
import 'package:fyp_psm/staff/track_page.dart';
import 'package:fyp_psm/staff/custdetails_page.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerBookingPage extends StatefulWidget {
  const CustomerBookingPage({super.key});

  @override
  State<CustomerBookingPage> createState() => _CustomerBookingPageState();
}

class _CustomerBookingPageState extends State<CustomerBookingPage> {
  String _selectedFilter = 'Nearest Booking';

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300, // Set the height of the ListView here
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Filter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true, // This makes the scrollbar always visible
                  child: ListView(
                    children: <String>[
                      'Nearest Booking',
                      'Oldest Booking',
                      'Status Upcoming',
                      'Status Completed',
                      'Status Completed (Pending Penalty Payment)',
                      'Status Completed (Paid Penalty)',
                    ].map((String value) {
                      return ListTile(
                        title: Text(value),
                        onTap: () {
                          setState(() {
                            _selectedFilter = value;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showFilterOptions,
              child: Text('Filter: $_selectedFilter'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    DateTime endDateTime = booking['endDateTime'].toDate();
                    String status = booking['status'] ?? 'Upcoming';

                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('booking')
                          .doc(booking.id)
                          .collection('fuel')
                          .get(),
                      builder: (context, fuelSnapshot) {
                        if (fuelSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (fuelSnapshot.hasError) {
                          return Center(child: Text('Error: ${fuelSnapshot.error}'));
                        }

                        if (fuelSnapshot.hasData && fuelSnapshot.data!.docs.isNotEmpty) {
                          var fuelData = fuelSnapshot.data!.docs.first.data() as Map<String, dynamic>?;

                          if (fuelData != null) {
                            if (fuelData['isRefuel'] == false) {
                              status = 'Completed (Pending Penalty Payment)';
                              if (booking['status'] == 'Upcoming') {
                                FirebaseFirestore.instance
                                    .collection('booking')
                                    .doc(booking.id)
                                    .update({'status': 'Completed (Pending Penalty Payment)'});
                              }
                            } else {
                              status = 'Completed';
                              if (booking['status'] == 'Upcoming') {
                                FirebaseFirestore.instance
                                    .collection('booking')
                                    .doc(booking.id)
                                    .update({'status': 'Completed'});
                              }
                            }
                          }

                          if (booking['status'] == 'Ongoing') {
                            status = 'Ongoing';
                          }

                          if (booking['status'] == 'Completed (Paid Penalty)') {
                            status = 'Completed (Paid Penalty)';
                          }
                        }

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
                                    color: status == 'Upcoming'
                                        ? Colors.purple
                                        : (status == 'Ongoing'
                                            ? Colors.blue
                                            : (status == 'Completed (Pending Penalty Payment)'
                                                ? Colors.red
                                                : (status == 'Completed (Paid Penalty)'
                                                    ? Colors.green
                                                    : Colors.green))),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomerBookingDetailsPage(
                                    bookingData: booking.data() as Map<String, dynamic>,
                                    initialStatus: status,
                                    bookingId: booking.id,
                                    initialStatusColor: status == 'Upcoming'
                                        ? Colors.purple
                                        : (status == 'Ongoing'
                                            ? Colors.blue
                                            : (status == 'Completed (Pending Penalty Payment)'
                                                ? Colors.red
                                                : (status == 'Completed (Paid Penalty)'
                                                    ? Colors.green
                                                    : Colors.green))),
                                  ),
                                ),
                              );
                              if (result == true) {
                                setState(() {});
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
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
        currentIndex: 2,
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

  Stream<QuerySnapshot> _getFilteredStream() {
    Stream<QuerySnapshot> stream;
    switch (_selectedFilter) {
      case 'Nearest Booking':
        stream = FirebaseFirestore.instance.collection('booking').orderBy('startDateTime', descending: false).snapshots();
        break;
      case 'Oldest Booking':
        stream = FirebaseFirestore.instance.collection('booking').orderBy('startDateTime', descending: true).snapshots();
        break;
      case 'Status Upcoming':
        stream = FirebaseFirestore.instance.collection('booking').where('status', isEqualTo: 'Upcoming').snapshots();
        break;
      case 'Status Completed':
        stream = FirebaseFirestore.instance.collection('booking').where('status', isEqualTo: 'Completed').snapshots();
        break;
      case 'Status Completed (Pending Penalty Payment)':
        stream = FirebaseFirestore.instance.collection('booking').where('status', isEqualTo: 'Completed (Pending Penalty Payment)').snapshots();
        break;
      case 'Status Completed (Paid Penalty)':
        stream = FirebaseFirestore.instance.collection('booking').where('status', isEqualTo: 'Completed (Paid Penalty)').snapshots();
        break;
      default:
        stream = FirebaseFirestore.instance.collection('booking').snapshots();
    }
    return stream;
  }
}

class CustomerBookingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final String initialStatus;
  final String bookingId;
  final Color initialStatusColor;

  CustomerBookingDetailsPage({
    required this.bookingData,
    required this.initialStatus,
    required this.bookingId,
    required this.initialStatusColor,
  });

  @override
  _CustomerBookingDetailsPageState createState() => _CustomerBookingDetailsPageState();
}

class _CustomerBookingDetailsPageState extends State<CustomerBookingDetailsPage> {
  File? _receiptFile;
  bool _isUploading = false;
  late String status;
  late Color statusColor;
  Map<String, dynamic>? fuelData;

  @override
  void initState() {
    super.initState();
    status = widget.initialStatus;
    statusColor = widget.initialStatusColor;
    _fetchFuelData();
  }

  Future<void> _fetchFuelData() async {
    final fuelSnapshot = await FirebaseFirestore.instance
        .collection('booking')
        .doc(widget.bookingId)
        .collection('fuel')
        .get();

    if (fuelSnapshot.docs.isNotEmpty) {
      setState(() {
        fuelData = fuelSnapshot.docs.first.data();
      });
    }
  }

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _receiptFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadReceipt() async {
    if (_receiptFile == null) {
      _showPopUpMessage('No File Selected', 'Please select a file to upload.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload the file to Firebase Storage
      String fileName = 'penalty_receipts/${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putFile(_receiptFile!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Store the download URL in the Firestore penaltyProof subcollection
      await FirebaseFirestore.instance
          .collection('booking')
          .doc(widget.bookingId)
          .collection('penaltyProof')
          .add({
        'proof': downloadURL,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the booking status
      await FirebaseFirestore.instance.collection('booking').doc(widget.bookingId).update({
        'status': 'Completed (Paid Penalty)',
      });

      // Show success message and update UI
      _showPopUpMessage('Payment Successful', 'Your penalty payment has been recorded.');
      setState(() {
        _receiptFile = null;
        status = 'Completed (Paid Penalty)';
        statusColor = Colors.green;
      });

      Navigator.pop(context, true); // Pass true to indicate the status was updated
    } catch (error) {
      _showPopUpMessage('Payment Failed', 'An error occurred while processing your payment. Please try again.');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showPopUpMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime endDateTime = widget.bookingData['endDateTime'].toDate();

    String rentalPeriod;
    if (widget.bookingData['rentalPeriodDays'] != 0) {
      rentalPeriod = '${widget.bookingData['rentalPeriodDays']} days';
    } else if (widget.bookingData['rentalPeriodHours'] != 0) {
      rentalPeriod = '${widget.bookingData['rentalPeriodHours']} hours';
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
                  color: statusColor,
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
                  _buildSectionTitle('Customer Details'),
                  _buildDetailRow('Name', widget.bookingData['name']),
                  _buildDetailRow('Phone Number', widget.bookingData['phoneNumber']),
                  _buildDetailRow('Email', widget.bookingData['email']),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildSection(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Rental Session Details'),
                  _buildDetailRow('Start Date & Time', DateFormat('dd-MM-yyyy hh:mm a').format(widget.bookingData['startDateTime'].toDate())),
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
                  _buildDetailRow('Brand', widget.bookingData['brand']),
                  _buildDetailRow('Model', widget.bookingData['carModel']),
                  _buildDetailRow('Plate Number', widget.bookingData['plateNumber']),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildSection(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Booking Details'),
                  _buildDetailRow('Booking Made', DateFormat('dd-MM-yyyy hh:mm a').format(widget.bookingData['bookingDateTime'].toDate())),
                  _buildDetailRow('Total Price', '\RM ${widget.bookingData['totalPrice'].toStringAsFixed(2)}'),
                  _buildDetailRow('Payment Booking Receipt:', ''),
                  widget.bookingData['paymentProof'] != null
                      ? GestureDetector(
                          onTap: () => launch(widget.bookingData['paymentProof']),
                          child: Text('View Payment Booking Receipt', style: TextStyle(color: Colors.blue)),
                        )
                      : Text('No proof available'),
                ],
              ),
            ),
            if (fuelData != null) ...[
              SizedBox(height: 20),
              _buildSection(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Fuel Details'),
                    _buildDetailRow('Mileage', '${fuelData!['mileageNum']}'),
                    _buildDetailRow('Fuel Bar', '${fuelData!['fuelBar']}'),
                    _buildDetailRow('Refuel', fuelData!['isRefuel'] ? 'Yes' : 'No'),
                    if (fuelData!['dashboardCar'] != null)
                      GestureDetector(
                        onTap: () => launch(fuelData!['dashboardCar']),
                        child: Text('View Dashboard Image', style: TextStyle(color: Colors.blue)),
                      )
                    else
                      Text('No Dashboard Image Available'),
                  ],
                ),
              ),
            ],
            if (status == 'Completed (Paid Penalty)') ...[
              SizedBox(height: 20),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('booking')
                    .doc(widget.bookingId)
                    .collection('penaltyProof')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    var penaltyProof = snapshot.data!.docs.first.data() as Map<String, dynamic>?;
                    String proofUrl = penaltyProof != null ? penaltyProof['proof'] : 'No proof available';

                    return _buildSection(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Penalty Details'),
                          _buildDetailRow('Price Fee Paid:', 'RM 10'),
                          _buildDetailRow('Penalty Payment Receipt:', ''),
                          proofUrl != 'No proof available'
                              ? GestureDetector(
                                  onTap: () => launch(proofUrl),
                                  child: Text('View Payment Receipt', style: TextStyle(color: Colors.blue)),
                                )
                              : Text('No proof available'),
                        ],
                      ),
                    );
                  } else {
                    return _buildSection(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Penalty Details'),
                          _buildDetailRow('Price Fee Paid:', 'RM 10'),
                          Text('No proof available'),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],

          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 217, 195),
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
