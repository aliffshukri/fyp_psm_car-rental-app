import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:fyp_psm/pages/mybooking_page.dart';

class CheckoutPage extends StatefulWidget {
  final String startDate;
  final String endDate;
  final String rentalPeriod;
  final String carBrand;
  final String carModel;
  final String carPlate;
  //final String totalPrice;

  const CheckoutPage({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.rentalPeriod,
    required this.carBrand,
    required this.carModel,
    required this.carPlate,
    //required this.totalPrice,
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

  void _confirmBooking() {
    // Navigate to MyBookingPage or perform any booking confirmation logic here
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyBookingPage()),
    );
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
                _buildDetailRow("Start Date:", widget.startDate),
                _buildDetailRow("End Date:", widget.endDate),
                _buildDetailRow("Rental Period:", widget.rentalPeriod),
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
                //_buildDetailRow("Total Price:", widget.totalPrice),
                _buildDetailRow("Bank Account:", "123-456-789"),
                const SizedBox(height: 16.0),
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
                    onPressed: _isButtonEnabled ? _confirmBooking : null,
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
