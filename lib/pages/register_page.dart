import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fyp_psm/pages/login_page.dart';
import 'package:fyp_psm/pages/status_page.dart';
import 'package:fyp_psm/pages/terms_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _icNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _termsChecked = false;
  String? _drivingLicenseFilePath;
  String? _malaysianIdFilePath;

  @override
  void dispose() {
    _nameController.dispose();
    _icNumberController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16.0),

            // IC Number
            TextFormField(
              controller: _icNumberController,
              decoration: InputDecoration(labelText: 'IC Number'),
            ),
            SizedBox(height: 16.0),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 16.0),

            // Phone Number
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 16.0),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),

            // Create Password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Create Password (Minimum 6 characters)'),
            ),
            SizedBox(height: 16.0),

            // Driving License File
            GestureDetector(
              onTap: () => _pickFile(isUploadFile: true),
              child: Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.attach_file, size: 40),
                    SizedBox(height: 8.0),
                    Text('Upload Driving License File'),
                    if (_drivingLicenseFilePath != null)
                      Text('Selected file: $_drivingLicenseFilePath'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),

            // Malaysian ID File
            GestureDetector(
              onTap: () => _pickFile(isUploadFile: false),
              child: Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.attach_file, size: 40),
                    SizedBox(height: 8.0),
                    Text('Upload Malaysian ID File'),
                    if (_malaysianIdFilePath != null)
                      Text('Selected file: $_malaysianIdFilePath'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),

            // Term and Condition Checkbox
            Row(
              children: [
                Checkbox(
                  value: _termsChecked,
                  onChanged: (value) {
                    setState(() {
                      _termsChecked = value!;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    // Redirect to TermsPage when "Term and Condition" is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TermsPage()),
                    );
                  },
                  child: Text(
                    'Term and Condition',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitButtonEnabled() ? () => _submitForm() : null,
              child: Text('Submit'),
            ),
            SizedBox(height: 16.0),

            // Cancel button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {})),
                );
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSubmitButtonEnabled() {
    return _termsChecked &&
        _nameController.text.isNotEmpty &&
        _icNumberController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _drivingLicenseFilePath != null &&
        _malaysianIdFilePath != null;
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

  Future<void> _pickFile({required bool isUploadFile}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        if (isUploadFile) {
          _drivingLicenseFilePath = file.path;
        } else {
          _malaysianIdFilePath = file.path;
        }
      });
    }
  }
  
  Future<void> _uploadFileToStorage(String userId, String filePath, String fileName) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child('files/$userId/$fileName');
      await storageReference.putFile(File(filePath));
      // You can also get the download URL for the file if needed
      String downloadURL = await storageReference.getDownloadURL();
      print('File uploaded. Download URL: $downloadURL');
    } catch (e) {
      print('File upload failed: $e');
      // Handle file upload failure if needed
      throw e; // Rethrow the exception to propagate it up the call stack
    }
  }

  Future<void> _submitForm() async {
  try {
    // Step 1: Create a user in Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Step 2: Get the UID of the newly created user
    String uid = userCredential.user!.uid;

    // Step 3: Save user details to Firestore
    await FirebaseFirestore.instance.collection('customer').doc(uid).set({
      'name': _nameController.text,
      'icNumber': _icNumberController.text,
      'address': _addressController.text,
      'phoneNumber': _phoneNumberController.text,
      'email': _emailController.text,
      // Add more fields as needed
    });

    // Step 4: Upload files to Firebase Storage
    await _uploadFileToStorage(uid, _drivingLicenseFilePath!, 'driving_license.pdf');
    await _uploadFileToStorage(uid, _malaysianIdFilePath!, 'malaysian_id.pdf');

    // Step 5: Show success pop-up message
    _showPopUpMessage('Submission Successful', 'Your registration was successful!');

    // Step 6: Navigate to the next screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {  },)),
        );
  } catch (e) {
    print("Registration failed: $e");
    // Step 7: Show failure pop-up message
    _showPopUpMessage('Submission Failed', 'Registration failed. Please try again.');
  }
}

}
