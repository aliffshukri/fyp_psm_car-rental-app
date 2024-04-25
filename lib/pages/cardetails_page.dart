// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class CarDetailsPage extends StatefulWidget {
  final String? brand;
  final String? modelName;
  final int? year;
  final String? transmissionType;
  final String? carType;
  final String? fuelTankCapacity;
  final int? numSeats;

  const CarDetailsPage({
    this.brand,
    this.modelName,
    this.year,
    this.transmissionType,
    this.carType,
    this.fuelTankCapacity,
    this.numSeats,
  });

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Make your booking",
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
                CarDetailItem(label: 'Brand', value: widget.brand),
                CarDetailItem(label: 'Model Name', value: widget.modelName),
                CarDetailItem(label: 'Year', value: widget.year?.toString()),
                CarDetailItem(
                    label: 'Transmission Type',
                    value: widget.transmissionType),
                CarDetailItem(label: 'Car Type', value: widget.carType),
                CarDetailItem(
                    label: 'Fuel Tank Capacity',
                    value: widget.fuelTankCapacity),
                CarDetailItem(
                    label: 'Number of Seats',
                    value: widget.numSeats?.toString()),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showRentalPeriodBottomSheet(context);
                  },
                  child: Text('Select Rental Period'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRentalPeriodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rental Period',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                _buildRentalPeriodItem('1 Hour'),
                _buildRentalPeriodItem('2 Hours'),
                _buildRentalPeriodItem('4 Hours'),
                _buildRentalPeriodItem('6 Hours'),
                _buildRentalPeriodItem('12 Hours'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRentalPeriodItem(String period) {
    return ListTile(
      title: Text(
        period,
        textAlign: TextAlign.center,
      ),
      onTap: () {
        // Handle the selected rental period
        // You can use the selected period as needed
        print('Selected Rental Period: $period');
        Navigator.pop(context); // Close the bottom sheet
      },
    );
  }
}

class CarDetailItem extends StatelessWidget {
  final String label;
  final String? value;

  const CarDetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
