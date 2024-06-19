/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_psm/pages/cardetails_page.dart';
import 'package:fyp_psm/pages/login_page.dart';
import 'package:fyp_psm/pages/mybooking_page.dart';
import 'package:fyp_psm/pages/session_page.dart';
import '../pages/profile_update_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  DateTime? selectedDate;
  String? selectedTime;
  List<String> timeOptions = ['9:00 AM', '12:00 PM', '2:00 PM', '4:00 PM', '6:00 PM'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "HELLO THERE, ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "${user.email ?? 'user'}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
          icon: const Icon(
            Icons.person,
            size: 40.0,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage(showRegisterPage: () {})),
              );
            },
            icon: const Icon(
              Icons.login,
              size: 40.0,
              color: Colors.white,
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "SELECT DATE AND TIME TO BOOK THE RENTAL CAR",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 400,
                            child: Column(
                              children: [
                                SizedBox(height: 16),
                                Text(
                                  'Select Date',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: CalendarDatePicker(
                                    onDateChanged: (DateTime date) {
                                      setState(() {
                                        selectedDate = date;
                                        selectedTime = null; // Reset selected time when date changes
                                      });
                                      Navigator.pop(context);
                                    },
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2101),
                                    initialDate: selectedDate ?? DateTime.now(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null
                                ? DateFormat('dd-MM-yyyy').format(selectedDate!)
                                : 'Select date',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedDate != null) {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            List<String> filteredTimeOptions = _filterTimeOptions(selectedDate!);
                            return Container(
                              height: 200,
                              child: Column(
                                children: [
                                  SizedBox(height: 16),
                                  Text(
                                    'Select Time',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: filteredTimeOptions.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return ListTile(
                                          title: Center(
                                            child: Text(
                                              filteredTimeOptions[index],
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              selectedTime = filteredTimeOptions[index];
                                            });
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a date first')),
                        );
                      }
                    },
                    child: Container(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedTime ?? 'Select Time',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rentalCar').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  padding: EdgeInsets.all(16.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    var rentalCarData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                    return _buildRentalCarItem(
                      rentalCarData['brand'],
                      rentalCarData['carModel'],
                      rentalCarData['carType'],
                      rentalCarData['numberOfSeats'],
                      rentalCarData['year'],
                      rentalCarData['transmissionType'],
                      rentalCarData['fuelTankCapacity'],
                      rentalCarData['priceHour'],
                      snapshot.data!.docs[index].id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Session',
          ),
        ],
        selectedItemColor: Colors.black,
        onTap: (int index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyBookingPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SessionPage()),
              );
              break;
          }
        },
      ),
    );
  }

  List<String> _filterTimeOptions(DateTime selectedDate) {
    DateTime now = DateTime.now();
    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      return timeOptions.where((timeOption) {
        DateTime timeOptionDateTime = DateFormat('h:mm a').parse(timeOption);
        DateTime fullTimeOptionDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          timeOptionDateTime.hour,
          timeOptionDateTime.minute,
        );
        return fullTimeOptionDateTime.isAfter(now);
      }).toList();
    } else {
      return timeOptions;
    }
  }

  Widget _buildRentalCarItem(
    String brand,
    String carModel,
    String carType,
    int numberOfSeats,
    int year,
    String transmissionType,
    String fuelTankCapacity,
    double priceHour,
    String carId,
  ) {
    Map<String, dynamic> rentalCarData = {
      'brand': brand,
      'modelName': carModel,
      'year': year,
      'transmissionType': transmissionType,
      'carType': carType,
      'fuelTankCapacity': fuelTankCapacity,
      'numSeats': numberOfSeats,
      'priceHour': priceHour,
      'carId': carId,
    };

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: (selectedDate != null && selectedTime != null) ? () {
          try {
            DateTime startDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse("${DateFormat('yyyy-MM-dd').format(selectedDate!)} $selectedTime");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CarDetailsPage(
                  brand: rentalCarData['brand'],
                  modelName: rentalCarData['modelName'],
                  year: rentalCarData['year'],
                  transmissionType: rentalCarData['transmissionType'],
                  carType: rentalCarData['carType'],
                  fuelTankCapacity: rentalCarData['fuelTankCapacity'],
                  numSeats: rentalCarData['numSeats'],
                  priceHour: rentalCarData['priceHour'],
                  selectedDateTime: startDateTime,
                  carId: rentalCarData['carId'],
                ),
              ),
            );
          } catch (e) {
            print('Error parsing date and time: $e');
          }
        } : null,
        splashColor: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Brand: $brand',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Model: $carModel',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Type: $carType',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Seats: $numberOfSeats',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onPressed) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30.0,
              color: Colors.black,
            ),
            SizedBox(height: 10.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/