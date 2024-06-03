import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:fyp_psm/pages/mybooking_page.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  final String carBrand;
  final String carModel;
  final String carPlate;
  final double totalPrice;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int rentalPeriodHours;
  final int rentalPeriodDays;
  final String rentalPeriodDescription;

  const CheckoutPage({
    Key? key,
    required this.carBrand,
    required this.carModel,
    required this.carPlate,
    required this.totalPrice, 
    required this.endDateTime, 
    required this.startDateTime, 
    required this.rentalPeriodHours, 
    required this.rentalPeriodDays, 
    required this.rentalPeriodDescription,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  File? _receiptFile;
  bool _isButtonEnabled = false;

  void _pickReceiptFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      setState(() {
        _receiptFile = File(result.files.single.path!);
        _isButtonEnabled = true;
      });
    }
  }

  Future<void> _uploadReceiptAndConfirmBooking() async {
    if (_receiptFile == null) return;

    try {
      // Upload receipt file to Firebase Storage
      String fileName = 'receipts/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.pdf';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(_receiptFile!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String receiptUrl = await taskSnapshot.ref.getDownloadURL();

      // Fetch current user information
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? displayName = currentUser?.displayName;
      String? phoneNumber = currentUser?.phoneNumber;
      String? email = currentUser?.email;

      // Fetch user details from Firestore if not available in Auth
      if (displayName == null || phoneNumber == null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('customer').doc(currentUser!.uid).get();
        displayName = userDoc['name'] ?? 'No name';
        phoneNumber = userDoc['phoneNumber'] ?? 'No phone number';
      }

      // Get the current date and time for the booking
      DateTime bookingDateTime = DateTime.now();

      // Create booking in Firestore
      await FirebaseFirestore.instance.collection('booking').add({
        'startDateTime': widget.startDateTime,
        'endDateTime': widget.endDateTime,
        'rentalPeriodHours': widget.rentalPeriodHours,
        'rentalPeriodDays': widget.rentalPeriodDays,
        'totalPrice': widget.totalPrice,
        'paymentProof': receiptUrl,
        'plateNumber': widget.carPlate,
        'brand': widget.carBrand,
        'carModel': widget.carModel,
        'name': displayName,
        'phoneNumber': phoneNumber,
        'email': email,
        'bookingDateTime': bookingDateTime,
        'isPast': false, // Add status field as "no"
      });

      // Navigate to MyBookingPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyBookingPage()),
      );
    } catch (e) {
      // Handle errors
      print('Error uploading receipt and confirming booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 178, 191, 83),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Checkout Page",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 173, 129, 80),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rental Session Details
              _buildSection("Rental Session Details", [
                _buildDetailRow("Start Date & Time:", DateFormat('dd-MM-yyyy hh:mm a').format(widget.startDateTime)),
                _buildDetailRow("End Date & Time:", DateFormat('dd-MM-yyyy hh:mm a').format(widget.endDateTime)),
                _buildDetailRow("Rental Period:", widget.rentalPeriodDescription),
              ]),

              const SizedBox(height: 16.0),

              // Car Details
              _buildSection("Car Details", [
                _buildDetailRow("Brand:", widget.carBrand),
                _buildDetailRow("Model:", widget.carModel),
                _buildDetailRow("Plate Number:", widget.carPlate),
              ]),

              const SizedBox(height: 16.0),

              // Payment Details, Receipt Upload, and Confirm Booking Button
              _buildSection("Payment Details", [
                _buildDetailRow("Total Price:", 'RM ${widget.totalPrice.toStringAsFixed(2)}'),
                _buildDetailRow("Bank Account:", "123-456-789"),
                const SizedBox(height: 10),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'image/qr.jpg', 
                        height: 200, 
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),

                _buildSectionTitle("Upload Payment Receipt"),
                ElevatedButton(
                  onPressed: _pickReceiptFile,
                  child: const Text("Upload PDF Receipt"),
                ),
                if (_receiptFile != null) 
                  Text("Receipt uploaded: ${_receiptFile!.path.split('/').last}"),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? _uploadReceiptAndConfirmBooking : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled ?  const Color.fromARGB(255, 173, 129, 80) : Colors.grey,
                    ),
                    child: const Text("Confirm Booking", style: TextStyle(color: Colors.white),),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8.0),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
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
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
