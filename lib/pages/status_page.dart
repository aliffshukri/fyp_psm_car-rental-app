import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_psm/pages/login_page.dart';

class TrackStatus extends StatefulWidget {
  const TrackStatus({super.key});

  @override
  State<TrackStatus> createState() => _TrackStatusState();
}

class _TrackStatusState extends State<TrackStatus> {
  final _emailController = TextEditingController();
  String _statusMessage = "Enter your email to track your account status.";
  bool _detailsSubmitted = false;
  bool _adminReviewing = false;
  bool _accountVerified = false;
  bool _accountDeleted = false;

  Future<void> _trackStatus() async {
    setState(() {
      _statusMessage = "Tracking...";
      _detailsSubmitted = false;
      _adminReviewing = false;
      _accountVerified = false;
      _accountDeleted = false;
    });

    try {
      String email = _emailController.text.trim();
      if (email.isEmpty) {
        _showDialog("Email Required", "Please enter your email.");
        setState(() {
          _statusMessage = "Enter your email to track your account status.";
        });
        return;
      }

      // Check customer collection
      QuerySnapshot customerQuerySnapshot = await FirebaseFirestore.instance
          .collection('customer')
          .where('email', isEqualTo: email)
          .get();

      if (customerQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot docSnapshot = customerQuerySnapshot.docs.first;
        bool isVerified = docSnapshot['isVerified'];

        setState(() {
          _statusMessage = "Account status tracked successfully.";
          _detailsSubmitted = true;
          _adminReviewing = true;
          _accountVerified = isVerified;
          _accountDeleted = !isVerified;
        });

        // If not verified, add to nonverifyCust collection
        if (!isVerified) {
          await FirebaseFirestore.instance
              .collection('nonverifyCust')
              .doc(docSnapshot.id)
              .set(docSnapshot.data() as Map<String, dynamic>);
        }
      } else {
        // Check nonverifyCust collection
        QuerySnapshot nonVerifyQuerySnapshot = await FirebaseFirestore.instance
            .collection('nonverifyCust')
            .where('email', isEqualTo: email)
            .get();

        if (nonVerifyQuerySnapshot.docs.isNotEmpty) {
          setState(() {
            _statusMessage = "Account status tracked successfully.";
            _detailsSubmitted = true;
            _adminReviewing = true;
            _accountVerified = false;
            _accountDeleted = true;
          });
        } else {
          _showDialog("Email Not Registered", "The email is not registered or does not exist. Please enter a registered email.");
          setState(() {
            _statusMessage = "Enter your email to track your account status.";
          });
        }
      }
    } catch (e) {
      print("Error tracking status: $e");
      setState(() {
        _statusMessage = "An error occurred. Please try again.";
      });
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Status Page",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Enter your email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _trackStatus,
              child: Text("Track Status"),
            ),
            SizedBox(height: 16.0),
            Text(
              _statusMessage,
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            if (_detailsSubmitted || _adminReviewing || _accountVerified || _accountDeleted) ...[
              Card(
                color: _detailsSubmitted ? Colors.green : Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Your Details Have been Submitted",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Card(
                color: _adminReviewing ? Colors.green : Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Admin is Reviewing your Account Details",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Card(
                color: _accountVerified ? Colors.green : Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Your Account Has been Verified",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              if (_accountDeleted)
                Card(
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Your Account Has been Rejected",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {  },)),
            );
          },
          child: Text("Return to Login"),
        ),
      ),
    );
  }
}
