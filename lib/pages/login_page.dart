import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_psm/pages/home_page.dart';
import 'package:fyp_psm/pages/register_page.dart';
import 'package:fyp_psm/pages/status_page.dart';
import 'package:fyp_psm/staff/car_rental_page.dart';
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
      if (_role == 'Customer') {
        // Check if entered credentials match admin credentials
        String adminEmail = 'admin@carapp.com'; // Admin email
        String adminPassword = 'admin@123'; // Admin password
        String enteredEmail = _emailController.text.trim();
        String enteredPassword = _passwordController.text.trim();
        if (enteredEmail == adminEmail && enteredPassword == adminPassword) {
          // If admin credentials used for customer role, show error message
          throw Exception("Admin credentials cannot be used to log in as a customer.");
        }
        
        // Perform customer login using Firebase
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: enteredEmail, 
          password: enteredPassword,
        );
      } else if (_role == 'Admin') {
        // Check if the entered credentials are for admin
        String adminEmail = 'admin@carapp.com'; // Change to your admin email
        String adminPassword = 'admin@123'; // Change to your admin password
        String enteredEmail = _emailController.text.trim();
        String enteredPassword = _passwordController.text.trim();
        if (enteredEmail == adminEmail && enteredPassword == adminPassword) {
          // Navigate to StaffCarRentalPage after successful admin login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StaffCarRentalPage()),
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
            content: Text("User not found or incorrect credentials. Please try again."),
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
                  style: GoogleFonts.bebasNeue(fontSize: 34),
                ),
                SizedBox(height: 0),
                Text(
                  "Please enter your email and password",
                  style: TextStyle(fontSize: 20),
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
