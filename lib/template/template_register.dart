/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _icNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Fetch user data from Firestore when the widget is initialized
    fetchUserData();
  }

  // Fetch user data from Firestore
  void fetchUserData() async {
    // Assume you have the user's UID (replace 'userUid' with the actual UID)
    String userUid = 'userUid';
    
    try {
      // Get the user document from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('customer').doc(userUid).get();

      // Check if the document exists
      if (userSnapshot.exists) {
        // Set the text controllers with the user data
        setState(() {
          _nameController.text = userSnapshot['name'];
          _icNumberController.text = userSnapshot['icNumber'];
          _addressController.text = userSnapshot['address'];
          _phoneNumberController.text = userSnapshot['phoneNumber'];
          _emailController.text = userSnapshot['email'];
        });
      } else {
        // Handle the case where the user document does not exist
        print('User document does not exist.');
      }
    } catch (error) {
      // Handle any errors that occur during the fetch
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 173, 129, 80),
              ),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  // Title
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
                    // Name
                    buildTextField('Name', _nameController),
                    SizedBox(height: 20),

                    // IC Number (Read-only)
                    buildReadOnlyTextField('IC Number', _icNumberController),
                    SizedBox(height: 20),

                    // Address
                    buildTextField('Address', _addressController),
                    SizedBox(height: 20),

                    // Phone Number
                    buildTextField('Phone Number', _phoneNumberController),
                    SizedBox(height: 20),

                    // Email (Read-only)
                    buildReadOnlyTextField('Email', _emailController),
                    SizedBox(height: 40),

                    // Edit / Save button
                    _isEditing
                        ? buildButton('Save', () => onSave())
                        : buildButton('Edit', () => onEdit()),
                    SizedBox(height: 10),

                    // Cancel button
                    buildButton('Cancel', () => onCancel()),

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
                enabled: false, // Disable editing
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
    });
  }

  void onSave() async {
    // Get the current user's UID (replace 'userUid' with the actual UID)
    String userUid = 'userUid';

    try {
      // Update the user document in Firestore with the new data
      await FirebaseFirestore.instance.collection('customer').doc(userUid).update({
        'name': _nameController.text,
        'icNumber': _icNumberController.text,
        'address': _addressController.text,
        'phoneNumber': _phoneNumberController.text,
        'email': _emailController.text,
      });

      setState(() {
        _isEditing = false;
      });

      // Show a success pop-up message
      _showPopUpMessage('Update Successful', 'Your profile was updated successfully!');
    } catch (error) {
      // Handle any errors that occur during the update
      print('Error updating user data: $error');

      // Show an error pop-up message
      _showPopUpMessage('Update Failed', 'An error occurred while updating your profile.');
    }
  }

  void onCancel() {
    setState(() {
      _isEditing = false;
    });

    // TODO: If you want to reset the text fields to the original values, do it here

    // Show a cancel pop-up message
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
}
*/