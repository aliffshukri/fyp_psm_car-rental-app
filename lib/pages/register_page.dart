import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fyp_psm/pages/login_page.dart';
import 'package:fyp_psm/pages/terms_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

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
  final _ageController = TextEditingController();
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
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 180, 192, 86),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Register",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFB38E58),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name
            _buildTextField('Name', _nameController),
            SizedBox(height: 16.0),

            // IC Number
            _buildTextField('IC Number', _icNumberController, inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
              _ICNumberFormatter(),
            ]),
            SizedBox(height: 16.0),

            // Address
            _buildTextField('Address', _addressController),
            SizedBox(height: 16.0),

            // Phone Number
            _buildTextField('Phone Number', _phoneNumberController, inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _PhoneNumberFormatter(),
            ]),
            SizedBox(height: 16.0),

            // Age
            _buildTextField('Age', _ageController, keyboardType: TextInputType.number),
            SizedBox(height: 16.0),

            // Email
            _buildTextField('Email (Used for login)', _emailController),
            SizedBox(height: 16.0),

            // Create Password
            _buildTextField('Create Password (Minimum 6 characters)', _passwordController, obscureText: true),
            SizedBox(height: 16.0),

            // Driving License File
            _buildFilePicker('Upload Driving License File', _drivingLicenseFilePath, isUploadFile: true),
            SizedBox(height: 16.0),

            // Malaysian ID File
            _buildFilePicker('Upload Malaysian ID File', _malaysianIdFilePath, isUploadFile: false),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TermsPage()),
                    );
                  },
                  child: Text(
                    'Term and Condition',
                    style: TextStyle(
                      color: Color.fromARGB(255, 16, 93, 156),
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
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFB38E58),
              ),
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
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
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
              ),
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, {bool obscureText = false, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Color(0xFFEFEFEF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilePicker(String labelText, String? filePath, {required bool isUploadFile}) {
    return GestureDetector(
      onTap: () => _pickFile(isUploadFile: isUploadFile),
      child: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.attach_file, size: 40),
            SizedBox(height: 8.0),
            Text(labelText),
            if (filePath != null)
              Text('Selected file: $filePath'),
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

  Future<String> _uploadFileToStorage(String userId, String filePath, String fileName) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child('files/$userId/$fileName');
      await storageReference.putFile(File(filePath));
      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL; // Return the download URL
    } catch (e) {
      throw e; // Rethrow the exception to propagate it up the call stack
    }
  }

  void _submitForm() async {
  // Validate email format
  if (!_isValidEmail(_emailController.text.trim())) {
    _showPopUpMessage('Invalid Email', 'Please enter a valid email address.');
    return;
  }

  // Validate IC number format
  if (!_isValidICNumber(_icNumberController.text)) {
    _showPopUpMessage('Invalid IC Number', 'Please enter a valid IC number (e.g., XXXXXX-XX-XXXX).');
    return;
  }

  // Validate phone number format
  if (!_isValidPhoneNumber(_phoneNumberController.text)) {
    _showPopUpMessage('Invalid Phone Number', 'Please enter a valid phone number (e.g., XXX-XXXXXXXX).');
    return;
  }

  int? age = int.tryParse(_ageController.text);
  if (age == null || age < 18) {
    _showPopUpMessage('Invalid Age', 'You must be at least 18 years old to register.');
    return;
  }

  try {
    // Step 1: Check if email already exists
    bool emailExists = await _checkIfEmailExists(_emailController.text.trim());
    if (emailExists) {
      _showPopUpMessage('Email Already Exists', 'This email address is already registered. Please use a different email.');
      return;
    }

    // Step 2: Create a user in Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Step 3: Upload files to Firebase Storage (if files are selected)
    String userId = userCredential.user!.uid;
    String? drivingLicenseURL;
    String? malaysianIdURL;

    if (_drivingLicenseFilePath != null) {
      drivingLicenseURL = await _uploadFileToStorage(userId, _drivingLicenseFilePath!, 'driving_license.pdf');
    }
    if (_malaysianIdFilePath != null) {
      malaysianIdURL = await _uploadFileToStorage(userId, _malaysianIdFilePath!, 'malaysian_id.pdf');
    }

    // Step 4: Save user details to Firestore
    await FirebaseFirestore.instance.collection('customer').doc(userId).set({
      'name': _nameController.text.trim(),
      'icNumber': _icNumberController.text.trim().replaceAll('-', ''),
      'address': _addressController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim().replaceAll('-', ''),
      'age': age,
      'email': _emailController.text.trim(),
      'drivingLicenseURL': drivingLicenseURL ?? '',
      'malaysianIdURL': malaysianIdURL ?? '',
      'isVerified': false,  // Add isVerified field and set to false
      'isDisabled': false,
      // Add other fields as needed
    });

    // Show success message
    _showPopUpMessage('Registration Successful', 'You have successfully registered.');

     // Navigate to the next screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {  },)),
    );

  } catch (e) {
    print("Registration failed: $e");
    _showPopUpMessage('Submission Failed', 'Registration failed. Please try again.');
  }
}


  bool _isValidEmail(String email) {
    // Basic email format validation using RegExp
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidICNumber(String icNumber) {
    // IC number format validation
    return RegExp(r'^\d{6}-\d{2}-\d{4}$').hasMatch(icNumber);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    // Phone number format validation
    return RegExp(r'^\d{3}-\d{7,}$').hasMatch(phoneNumber);
  }

  Future<bool> _checkIfEmailExists(String email) async {
    // Check if email exists in Firestore
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('customer')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return querySnapshot.size > 0;
  }
}

class _ICNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length > 12) {
      return oldValue;
    }
    final buffer = StringBuffer();
    int selectionIndex = newValue.selection.end;

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 5 || i == 7) && text.length > i + 1) {
        buffer.write('-');
        if (i < selectionIndex - 1) selectionIndex++;
      }
    }

    final String formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length > 11) {
          return oldValue;
        }
    final buffer = StringBuffer();
    int selectionIndex = newValue.selection.end;

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 2 && text.length > i + 1) {
        buffer.write('-');
        if (i < selectionIndex - 1) selectionIndex++;
      }
    }

    final String formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
