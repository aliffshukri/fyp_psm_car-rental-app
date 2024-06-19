import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_psm/pages/home_page.dart';
import 'package:fyp_psm/pages/register_page.dart';
import 'package:fyp_psm/pages/status_page.dart';
import 'package:fyp_psm/staff/car_rental_page.dart';
import 'package:fyp_psm/staff/custdetails_page.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key,required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = ''; // Track selected role
  bool _obscureText = true; // Track whether password text is obscured

  Future<void> logIn(BuildContext context) async {
  if (_role.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Role not selected"),
          content: Text("Please select your role."),
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
    return; // Exit the function if role not selected
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    String enteredEmail = _emailController.text.trim();
    String enteredPassword = _passwordController.text.trim();

    if (_role == 'Customer') {
      // Check if entered credentials match admin credentials
      String adminEmail = 'admin@carapp.com'; // Admin email
      String adminPassword = 'admin@123'; // Admin password
      if (enteredEmail == adminEmail && enteredPassword == adminPassword) {
        // If admin credentials used for customer role, show error message
        throw Exception("Admin credentials cannot be used to log in as a customer.");
      }

      // Perform customer login using Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );

      // Check if the user's account is disabled or not verified
      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('customer').doc(user.uid).get();
        if (userDoc.exists) {
          bool isDisabled = userDoc['isDisabled'] ?? false;
          bool isVerified = userDoc['isVerified'] ?? false;
          if (!isVerified) {
            // Sign out the user if they are not verified
            await FirebaseAuth.instance.signOut();
            Navigator.of(context, rootNavigator: true).pop();
            // Show a message to the user
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Account Not Verified"),
                  content: Text("Your account has not been verified by the admin. Please wait for verification."),
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
            return; // Exit the function after showing the message
          } else if (isDisabled) {
            // Sign out the user if they are disabled
            await FirebaseAuth.instance.signOut();
            Navigator.of(context, rootNavigator: true).pop();
            // Show a message to the user
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Account Disabled"),
                  content: Text("Your account has been disabled. Please contact support for more information."),
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
            return; // Exit the function after showing the message
          }
        } else {
          // User document does not exist
          throw Exception("User document not found.");
        }
      } else {
        // User is null
        throw Exception("User not found.");
      }
    } else if (_role == 'Admin') {
      // Check if the entered credentials are for admin
      String adminEmail = 'admin@carapp.com'; // Change to your admin email
      String adminPassword = 'admin@123'; // Change to your admin password
      if (enteredEmail == adminEmail && enteredPassword == adminPassword) {
        // Navigate to StaffCarRentalPage after successful admin login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustDetailsPage()),
        );
        return; // Exit the function after navigation
      } else {
        // If selected role is Admin but entered credentials don't match admin credentials
        throw Exception("Incorrect admin credentials");
      }
    }

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop();

    print("Login failed: $e");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Error"),
          content: Text(e is FirebaseAuthException && e.code == 'user-not-found'
              ? "User not found. Please check your credentials."
              : e is FirebaseAuthException && e.code == 'wrong-password'
              ? "Incorrect password. Please try again."
              : e is Exception && e.toString().contains("Admin credentials cannot be used to log in as a customer.")
              ? "Admin credentials cannot be used to log in as a customer."
              : e is Exception && e.toString().contains("User document not found.")
              ? "User document not found. Please contact support."
              : e is Exception && e.toString().contains("User not found.")
              ? "User not found. Please check your credentials."
              : "Login failed. Please try again."),
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



  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 180, 192, 86),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'image/KSJ logo.jpg', 
                  height: 200, 
                ),
                SizedBox(height: 40),
                Text(
                  'Welcome to Kereta Sewa Jimat App',
                  style: GoogleFonts.bebasNeue(fontSize: 28),
                ),
                SizedBox(height: 0),
                Text(
                  "Please enter your email and password",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Email',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(
                      value: 'Customer',
                      groupValue: _role,
                      onChanged: (String? value) {
                        setState(() {
                          _role = value!;
                        });
                      },
                    ),
                    Text('Customer'),
                    Radio<String>(
                      value: 'Admin',
                      groupValue: _role,
                      onChanged: (String? value) {
                        setState(() {
                          _role = value!;
                        });
                      },
                    ),
                    Text('Admin'),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () => logIn(context),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 173, 129, 80),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:Center(
                        child: Text('Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          ),
                        )
                        ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child:GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TrackStatus()),
                    ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 231, 180, 121),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:Center(
                      child: Text('Track your Account Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        ),
                      )
                      ),
                  ),
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Do not have an account yet?  ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        'Register Here',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
