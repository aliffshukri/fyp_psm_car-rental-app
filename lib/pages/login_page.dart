import 'package:flutter/material.dart';
import 'package:fyp_psm/pages/home_page.dart';
import 'package:fyp_psm/pages/register_page.dart';
import 'package:fyp_psm/pages/status_page.dart';
import 'package:google_fonts/google_fonts.dart';

import '../staff (admin)/car_rental_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAdmin = false; // Flag to track whether it's admin login or not

  // Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> logIn(BuildContext context) async {
    // Show a loading indicator while logging in
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing the dialog
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Perform login based on isAdmin flag
      if (isAdmin) {
        // Admin login
        if (_emailController.text.trim() == 'admin' &&
            _passwordController.text.trim() == '123admin') {
          // Navigate to StaffCarRentalPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StaffCarRentalPage()),
          );
        } else {
          // Show error message for invalid credentials
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Login Error"),
                content: Text("Invalid username or password. Please try again."),
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
      } else {
        // Customer login
        // Perform login with Firebase Auth
        // await FirebaseAuth.instance.signInWithEmailAndPassword(
        //   email: _emailController.text.trim(),
        //   password: _passwordController.text.trim(),
        // );

        // For demo purposes, navigate to HomePage directly
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      // Close the loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      // Handle login failure if needed
      print("Login failed: $e");

      // You can show an error message to the user if needed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Login Error"),
            content: Text("User not found. Please try again."),
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
  void dispose() {
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
                // Toggle Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isAdmin = false;
                        });
                      },
                      child: Text('Customer'),
                      style: ElevatedButton.styleFrom(
                        primary: isAdmin ? Colors.grey : Colors.blue,
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isAdmin = true;
                        });
                      },
                      child: Text('Admin'),
                      style: ElevatedButton.styleFrom(
                        primary: isAdmin ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Logo
                Image.asset(
                  'image/KSJ logo.jpg',
                  height: 200,
                ),
                SizedBox(height: 40),

                // Welcome text
                Text(
                  'Welcome to Kereta Sewa Jimat App',
                  style: GoogleFonts.bebasNeue(fontSize: 34),
                ),
                SizedBox(height: 0),
                Text(
                  "Please enter your ${isAdmin ? 'username and password' : 'email and password'}",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),

                // Email or Username
                if (!isAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ), // BoxDecoration
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
                if (isAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ), // BoxDecoration
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Username',
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20),

                // Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ), // BoxDecoration
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Password',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),

                // Login button
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
                      child: Center(
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isAdmin) // Display only for customer login
                  Column(
                    children: [
                      SizedBox(height: 10),

                      // Track btn
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
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
                            child: Center(
                              child: Text(
                                'Track your Account Status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),

                      // Not a member? Register now
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
                              // Redirect to RegisterPage when "Register Here" is clicked
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
