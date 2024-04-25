import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _user;
  late TextEditingController _nameController;
  late TextEditingController _icNumberController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  bool _isCancelEnabled = false;

  late String _originalName;
  late String _originalICNumber;
  late String _originalAddress;
  late String _originalPhoneNumber;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _nameController = TextEditingController();
    _icNumberController = TextEditingController();
    _addressController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        _emailController.text = currentUser.email ?? '';
      } else {
        print('User is not logged in.');
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('customer').doc(_user.uid).get();

      if (userDoc.exists) {
        setState(() {
          _originalName = userDoc['name'] ?? '';
          _originalICNumber = userDoc['icNumber'] ?? '';
          _originalAddress = userDoc['address'] ?? '';
          _originalPhoneNumber = userDoc['phoneNumber'] ?? '';

          _nameController.text = _originalName;
          _icNumberController.text = _originalICNumber;
          _addressController.text = _originalAddress;
          _phoneNumberController.text = _originalPhoneNumber;
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter $label',
                ),
                enabled: _isEditing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReadOnlyTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter $label',
                ),
                enabled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
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
      ),
    );
  }

  void onEdit() {
    setState(() {
      _isEditing = true;
      _isCancelEnabled = true;
    });
  }

  void onSave() async {
    try {
      await _firestore.collection('customer').doc(_user.uid).set({
        'name': _nameController.text,
        'icNumber': _icNumberController.text,
        'address': _addressController.text,
        'phoneNumber': _phoneNumberController.text,
      });

      setState(() {
        _isEditing = false;
        _isCancelEnabled = false;
      });

      _showPopUpMessage('Update Successful', 'Your profile was updated successfully!');
    } catch (error) {
      print('Error updating user data: $error');
      _showPopUpMessage('Update Failed', 'An error occurred while updating your profile.');
    }
  }

  void onCancel() {
    setState(() {
      _isEditing = false;
      _isCancelEnabled = false;

      _nameController.text = _originalName;
      _icNumberController.text = _originalICNumber;
      _addressController.text = _originalAddress;
      _phoneNumberController.text = _originalPhoneNumber;
    });

    _showPopUpMessage('Update Cancelled', 'Your changes were not saved.');
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
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 173, 129, 80),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Customer Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildTextField('Name', _nameController),
                    SizedBox(height: 20),
                    buildReadOnlyTextField('IC Number', _icNumberController),
                    SizedBox(height: 20),
                    buildTextField('Address', _addressController),
                    SizedBox(height: 20),
                    buildTextField('Phone Number', _phoneNumberController),
                    SizedBox(height: 20),
                    buildReadOnlyTextField('Email', _emailController),
                    SizedBox(height: 40),
                    _isEditing
                        ? buildButton('Save', () => onSave())
                        : buildButton('Edit', () => onEdit()),
                    SizedBox(height: 10),
                    _isCancelEnabled
                        ? buildButton('Cancel', () => onCancel())
                        : SizedBox.shrink(),
                    SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
