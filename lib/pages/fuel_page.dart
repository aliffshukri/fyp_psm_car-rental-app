import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_psm/pages/home_page.dart';
import 'package:fyp_psm/pages/session_page.dart';

class FuelPage extends StatefulWidget {
  const FuelPage({Key? key}) : super(key: key);

  @override
  State<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends State<FuelPage> {
  TextEditingController _mileageController = TextEditingController();
  TextEditingController _fuelBarController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image != null ? File(image.path) : null;
    });
  }

  // Add this method to reset the image state when the "Cancel" button is pressed
  void _cancelImageSelection() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _uploadImageAndSubmit() async {
    if (_image != null) {
      try {
        String imageUrl =
            await _uploadFileToStorage('dashboard_car.jpg', _image!);

        // Store the image URL and other details in Firestore
        await _storeDataInFirestore(imageUrl);

        // Reset the image state
        setState(() {
          _image = null;
        });

        // Show a success pop-up message
        _showPopUpMessage(
          'Submission Successful',
          'Your Rental Session has Ended. THANK YOU!',
          navigateToHomePage,
        );
      } catch (error) {
        // Show an error pop-up message
        _showPopUpMessage(
          'Submission Failed',
          'An error occurred while submitting your data.',
          () {
            // You can add additional actions if needed
          },
        );
      }
    } else {
      // Show a warning pop-up message if no image is selected
      _showPopUpMessage(
        'No Image Selected',
        'Please select an image before uploading.',
        () {
          // You can add additional actions if needed
        },
      );
    }
  }

  Future<String> _uploadFileToStorage(String fileName, File file) async {
    try {
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      await storageReference.putFile(file);
      // Get the download URL of the uploaded file
      return await storageReference.getDownloadURL();
    } catch (error) {
      throw error;
    }
  }

  Future<void> _storeDataInFirestore(String imageUrl) async {
    try {
      // Store other details in Firestore (excluding image URL)
      await FirebaseFirestore.instance.collection('fuel').add({
        'mileageNum': _mileageController.text,
        'fuelBar': _fuelBarController.text,
        // Add other fields as needed
      });
    } catch (error) {
      throw error;
    }
  }

  void _showPopUpMessage(String title, String message, VoidCallback onOkPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                // Close the pop-up dialog
                Navigator.of(context).pop();
                // Execute the callback (navigate to HomePage)
                onOkPressed();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void navigateToHomePage() {
    // Navigate to HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return HomePage();
      }),
    );
  }

  void navigateToSessionPage() {
    // Navigate to HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SessionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Fuel Status Form",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text Instruction
              SizedBox(height: 20),
              Text(
                "Please fill in the fuel details:",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),

              // Number of Mileage
              buildTextField("Number of Mileage", _mileageController),
              SizedBox(height: 20),

              // Fuel Bar
              buildTextField("Fuel Bar", _fuelBarController),
              SizedBox(height: 40),

              //Example Dashboard Meter
              Text(
                "Example of Dashboard Meter that should be uploaded:",
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 20),

              //Dashboard Meter Example
              Image.asset(
                'image/dashboard meter.jpg',
                height: 200,
              ),
              SizedBox(height: 20),

              // Image Upload
              buildAttachmentButton(
                "Upload The Dashboard Meter",
                _selectImage,
              ),
              SizedBox(height: 40),

              // Submit Button
              buildButton("Submit", _uploadImageAndSubmit),
              SizedBox(height: 10),

              // Return Button
              buildButton("Return", navigateToSessionPage),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,
          ),
        ),
      ),
    );
  }

  Widget buildAttachmentButton(String label, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 231, 180, 121),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          _image != null ? _image!.path.split('/').last : 'No file selected',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        if (_image != null)
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _cancelImageSelection,
            child: Text('Cancel'),
          ),
      ],
    );
  }

  Widget buildButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 173, 129, 80),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
