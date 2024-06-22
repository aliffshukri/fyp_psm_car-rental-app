import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'checkout_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class CarDetailsPage extends StatefulWidget {
  final String? brand;
  final String? modelName;
  final int? year;
  final String? transmissionType;
  final String? carType;
  final String? fuelTankCapacity;
  final int? numSeats;
  final String? carId;
  final double? priceHour;
  final DateTime selectedDateTime;
  final String carImage; // Add this line

  const CarDetailsPage({
    this.brand,
    this.modelName,
    this.year,
    this.transmissionType,
    this.carType,
    this.fuelTankCapacity,
    this.numSeats,
    this.carId,
    this.priceHour, 
    required this.selectedDateTime,
    required this.carImage, // Add this line
  });

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  String rentalType = 'Hours';
  int rentalPeriod = 1;
  bool isCheckoutEnabled = false;
  double priceHour = 0.0;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    priceHour = widget.priceHour ?? 0.0;
    _calculateTotalPrice();
  }

  Future<List<String>> _fetchAvailablePlateNumbers() async {
    final plateNumbersSnapshot = await FirebaseFirestore.instance
        .collection('rentalCar')
        .doc(widget.carId)
        .collection('plateNumbers')
        .get();
    final plateNumbers = plateNumbersSnapshot.docs.map((doc) => doc['plateNumber'] as String).toList();
    return plateNumbers;
  }

  Future<List<String>> _getUnavailablePlateNumbers(DateTime startDateTime, DateTime endDateTime) async {
    final bookingSnapshot = await FirebaseFirestore.instance.collection('booking').get();
    List<String> unavailablePlateNumbers = [];

    for (var booking in bookingSnapshot.docs) {
      DateTime bookingStart = booking['startDateTime'].toDate();
      DateTime bookingEnd = booking['endDateTime'].toDate();

      // Include 1-hour buffer before and after
      DateTime adjustedBookingStart = bookingStart.subtract(Duration(hours: 1));
      DateTime adjustedBookingEnd = bookingEnd.add(Duration(hours: 1));

      if (startDateTime.isBefore(adjustedBookingEnd) && endDateTime.isAfter(adjustedBookingStart)) {
        unavailablePlateNumbers.add(booking['plateNumber']);
      }
    }

    return unavailablePlateNumbers;
  }

  void _calculateTotalPrice() {
    double tempTotalPrice = 0.0;

    if (rentalType == 'Hours') {
      if (rentalPeriod == 1) {
        tempTotalPrice = priceHour; // 1 hour = price per hour
      } else if (rentalPeriod <= 12) {
        tempTotalPrice = priceHour + (rentalPeriod - 1) * (priceHour - 0.25);
      } else {
        // After the 12th hour, linearly decrease the price
        tempTotalPrice = priceHour + 11 * (priceHour - 0.25) - (rentalPeriod - 12) * 0.25;
      }
    } else { // rentalType == 'Days'
      double baseRate;
      switch (rentalPeriod) {
        case 1:
          baseRate = 24 * priceHour;
          tempTotalPrice = baseRate - (baseRate * 0.30); // ~15% discount for 1 day
          break;
        case 2:
          baseRate = 48 * priceHour;
          tempTotalPrice = baseRate - (baseRate * 0.30); // ~25% discount for 2 days
          break;
        case 3:
          baseRate = 72 * priceHour;
          tempTotalPrice = baseRate - (baseRate * 0.30); // ~30% discount for 3 days
          break;
        case 4:
          baseRate = 96 * priceHour;
          tempTotalPrice = baseRate - (baseRate * 0.30); // ~30% discount for 4 days
          break;
        case 5:
          baseRate = 120 * priceHour;
          tempTotalPrice = baseRate - (baseRate * 0.30); // ~30% discount for 5 days
          break;
        case 6:
          baseRate = 144 * priceHour;
          tempTotalPrice = baseRate - (baseRate * 0.35); // ~35% discount for 6 days
          break;
        case 7:
          baseRate = 168 * priceHour;
          tempTotalPrice = baseRate - (baseRate * 0.40); // ~40% discount for 7 days
          break;
        default:
          tempTotalPrice = priceHour * rentalPeriod * 24; // Fallback logic for > 7 days
      }
    }

    setState(() {
      totalPrice = tempTotalPrice;
      isCheckoutEnabled = true;
    });
  }

  DateTime calculateEndDateTime() {
    DateTime startDateTime = widget.selectedDateTime;
    if (rentalType == 'Hours') {
      return startDateTime.add(Duration(hours: rentalPeriod));
    } else {
      return startDateTime.add(Duration(days: rentalPeriod));
    }
  }

  Future<void> _handleCheckout() async {
    DateTime startDateTime = widget.selectedDateTime;
    DateTime endDateTime = calculateEndDateTime();

    List<String> availablePlateNumbers = await _fetchAvailablePlateNumbers();
    List<String> unavailablePlateNumbers = await _getUnavailablePlateNumbers(startDateTime, endDateTime);

    List<String> availablePlateNumbersFiltered = availablePlateNumbers
        .where((plateNumber) => !unavailablePlateNumbers.contains(plateNumber))
        .toList();

    if (availablePlateNumbersFiltered.isNotEmpty) {
      final random = Random();
      String plateNumber = availablePlateNumbersFiltered[random.nextInt(availablePlateNumbersFiltered.length)];

      // Navigate to CheckoutPage with the fetched plate number
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            rentalPeriodDescription: rentalType == 'Hours' ? '$rentalPeriod hours' : '$rentalPeriod days',
            rentalPeriodHours: rentalType == 'Hours' ? rentalPeriod : 0,
            rentalPeriodDays: rentalType == 'Days' ? rentalPeriod : 0,
            carBrand: widget.brand ?? '',
            carModel: widget.modelName ?? '',
            carPlate: plateNumber, // Pass the fetched plate number
            totalPrice: totalPrice,
          ),
        ),
      );
    } else {
      // Show a popup to advise the customer to pick another rental period with suggestions
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Available Cars'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please select a different rental period to avoid double booking.'),
              SizedBox(height: 10),
              Text('Suggestions:'),
              Text('- Avoid booking start or end times that overlap with another booking.'),
              Text('- Ensure at least a 1-hour buffer between bookings for maintenance.'),
              Text('- Try different start or end times within the same day.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 178, 191, 83),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Make your booking",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 173, 129, 80),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 4,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.carImage.isNotEmpty)
                    Image.network(
                      widget.carImage,
                      height: 200,
                    ),
                  CarDetailItem(label: 'Brand', value: widget.brand),
                  CarDetailItem(label: 'Model Name', value: widget.modelName),
                  CarDetailItem(label: 'Year', value: widget.year?.toString()),
                  CarDetailItem(label: 'Transmission Type', value: widget.transmissionType),
                  CarDetailItem(label: 'Car Type', value: widget.carType),
                  CarDetailItem(label: 'Fuel Tank Capacity', value: '${widget.fuelTankCapacity} L'),
                  CarDetailItem(label: 'Number of Seats', value: widget.numSeats?.toString()),

                  const SizedBox(height: 20),
                  const Text(
                    'Select Rental Period',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text('Hours'),
                          value: 'Hours',
                          groupValue: rentalType,
                          onChanged: (value) {
                            setState(() {
                              rentalType = value.toString();
                              rentalPeriod = 1; // Reset rental period to 1
                              _calculateTotalPrice(); // Recalculate price
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: const Text('Days'),
                          value: 'Days',
                          groupValue: rentalType,
                          onChanged: (value) {
                            setState(() {
                              rentalType = value.toString();
                              rentalPeriod = 1; // Reset rental period to 1
                              _calculateTotalPrice(); // Recalculate price
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'RM ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          Text(
                            'Select $rentalType',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          NumberPicker(
                            itemWidth: 60,
                            minValue: 1,
                            maxValue: rentalType == 'Hours' ? 12 : 7,
                            value: rentalPeriod,
                            onChanged: (value) {
                              setState(() {
                                rentalPeriod = value;
                                _calculateTotalPrice(); // Recalculate price
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: isCheckoutEnabled ? _handleCheckout : null,
                      child: const Text(
                        'Checkout',
                        style: TextStyle(color: Colors.black), // Keep font color
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white, // Change background color to white
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CarDetailItem extends StatelessWidget {
  final String label;
  final String? value;

  const CarDetailItem({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(
            value ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
