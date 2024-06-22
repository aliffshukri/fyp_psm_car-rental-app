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

                if (selectedDate == null || selectedTime == null) {
                  // Show all cars in a locked state
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
                        rentalCarData,
                        snapshot.data!.docs[index].id,
                        0, // Set availableQty to 0 to indicate locked state
                        false, // Pass a flag to indicate the card is locked
                      );
                    },
                  );
                }

                return FutureBuilder(
                  future: _getAvailableCars(),
                  builder: (context, AsyncSnapshot<List<DocumentSnapshot>> availableCarsSnapshot) {
                    if (availableCarsSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (availableCarsSnapshot.hasError) {
                      return Text('Error: ${availableCarsSnapshot.error}');
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      padding: EdgeInsets.all(16.0),
                      itemCount: availableCarsSnapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        var rentalCarData = availableCarsSnapshot.data![index].data() as Map<String, dynamic>;

                        return _buildRentalCarItem(
                          rentalCarData,
                          availableCarsSnapshot.data![index].id,
                          rentalCarData['availableQty'],
                          true, // Pass a flag to indicate the card is unlocked
                        );
                      },
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
      List<String> filteredOptions = timeOptions.where((timeOption) {
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
      if (filteredOptions.isEmpty) {
        _showTimeUnavailablePopup();
      }
      return filteredOptions;
    } else {
      return timeOptions;
    }
  }

  void _showTimeUnavailablePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Time Unavailable'),
        content: Text('The last start rental time has passed. Please select another date.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<List<DocumentSnapshot>> _getAvailableCars() async {
    if (selectedDate == null || selectedTime == null) {
      return [];
    }

    DateTime selectedDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse("${DateFormat('yyyy-MM-dd').format(selectedDate!)} $selectedTime");

    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance.collection('booking').get();
    List<String> unavailablePlateNumbers = [];

    for (var booking in bookingSnapshot.docs) {
      DateTime startDateTime = booking['startDateTime'].toDate();
      DateTime endDateTime = booking['endDateTime'].toDate();
      String plateNumber = booking['plateNumber'];
      String status = booking['status'];

      if (!(selectedDateTime.isBefore(startDateTime) || selectedDateTime.isAfter(endDateTime)) && status == 'Upcoming') {
        unavailablePlateNumbers.add(plateNumber);
      }

      // If the status is not 'Upcoming' and endDateTime is due, the car is available again
      if (status != 'Upcoming' && endDateTime.isBefore(DateTime.now())) {
        var carDoc = await FirebaseFirestore.instance.collection('rentalCar').doc(booking['carId']).get();
        int availableQty = carDoc['availableQty'];
        await FirebaseFirestore.instance.collection('rentalCar').doc(booking['carId']).update({
          'availableQty': availableQty + 1
        });
      }
    }

    QuerySnapshot rentalCarSnapshot = await FirebaseFirestore.instance.collection('rentalCar').get();
    List<DocumentSnapshot> availableCars = [];

    for (var rentalCar in rentalCarSnapshot.docs) {
      var plateNumbersSnapshot = await rentalCar.reference.collection('plateNumbers').get();
      int availableQty = plateNumbersSnapshot.docs.length;

      for (var plateNumberDoc in plateNumbersSnapshot.docs) {
        if (unavailablePlateNumbers.contains(plateNumberDoc['plateNumber'])) {
          availableQty--;
        }
      }

      if (availableQty > 0) {
        rentalCar.reference.update({'availableQty': availableQty});
        availableCars.add(rentalCar);
      }
    }

    return availableCars;
  }

  Widget _buildRentalCarItem(
    Map<String, dynamic> rentalCarData,
    String documentId,
    int availableQty,
    bool showAvailability,
  ) {
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
                  modelName: rentalCarData['carModel'],
                  year: rentalCarData['year'],
                  transmissionType: rentalCarData['transmissionType'],
                  carType: rentalCarData['carType'],
                  fuelTankCapacity: rentalCarData['fuelTankCapacity'],
                  numSeats: rentalCarData['numberOfSeats'],
                  priceHour: rentalCarData['priceHour'],
                  selectedDateTime: startDateTime,
                  carId: documentId,
                  carImage: rentalCarData['carImage'],
                ),
              ),
            );
          } catch (e) {
            print('Error parsing date and time: $e');
          }
        } : null,
        splashColor: Colors.black,
        child: Column(
          children: [
            if (rentalCarData['carImage'] != null && rentalCarData['carImage'].isNotEmpty)
              Container(
                height: 100,
                child: Image.network(rentalCarData['carImage'], fit: BoxFit.cover),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${rentalCarData['brand']} ${rentalCarData['carModel']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    if (showAvailability)
                      Text(
                        'Available: $availableQty',
                        style: TextStyle(fontSize: 16.0, color: availableQty > 0 ? Colors.green : Colors.red),
                      ),
                  ],
                ),
              ),
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
}
