import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarRentalAdd extends StatefulWidget {
  @override
  _CarRentalAddState createState() => _CarRentalAddState();
}

class _CarRentalAddState extends State<CarRentalAdd> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _carModelController;
  late TextEditingController _carTypeController;
  late TextEditingController _fuelTankCapacityController;
  late TextEditingController _numberOfSeatsController;
  late TextEditingController _transmissionTypeController;
  late TextEditingController _yearController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _brandController = TextEditingController();
    _carModelController = TextEditingController();
    _carTypeController = TextEditingController();
    _fuelTankCapacityController = TextEditingController();
    _numberOfSeatsController = TextEditingController();
    _transmissionTypeController = TextEditingController();
    _yearController = TextEditingController();
  }

  Future<void> _addCarData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('rentalCar').add({
          'brand': _brandController.text,
          'carModel': _carModelController.text,
          'carType': _carTypeController.text,
          'fuelTankCapacity': _fuelTankCapacityController.text,
          'numberOfSeats': int.parse(_numberOfSeatsController.text),
          'transmissionType': _transmissionTypeController.text,
          'year': int.parse(_yearController.text),
        });
        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Error adding car data: $e');
      }
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _carModelController.dispose();
    _carTypeController.dispose();
    _fuelTankCapacityController.dispose();
    _numberOfSeatsController.dispose();
    _transmissionTypeController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Car Details'),
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        _buildTextFormField(
                          controller: _brandController,
                          label: 'Brand',
                          validator: (value) => value!.isEmpty ? 'Please enter the car brand' : null,
                        ),
                        _buildTextFormField(
                          controller: _carModelController,
                          label: 'Car Model',
                          validator: (value) => value!.isEmpty ? 'Please enter the car model' : null,
                        ),
                        _buildTextFormField(
                          controller: _carTypeController,
                          label: 'Car Type',
                          validator: (value) => value!.isEmpty ? 'Please enter the car type' : null,
                        ),
                        _buildTextFormField(
                          controller: _fuelTankCapacityController,
                          label: 'Fuel Tank Capacity',
                          validator: (value) => value!.isEmpty ? 'Please enter the fuel tank capacity' : null,
                        ),
                        _buildTextFormField(
                          controller: _numberOfSeatsController,
                          label: 'Number of Seats',
                          validator: (value) => value!.isEmpty ? 'Please enter the number of seats' : null,
                        ),
                        _buildTextFormField(
                          controller: _transmissionTypeController,
                          label: 'Transmission Type',
                          validator: (value) => value!.isEmpty ? 'Please enter the transmission type' : null,
                        ),
                        _buildTextFormField(
                          controller: _yearController,
                          label: 'Year',
                          validator: (value) => value!.isEmpty ? 'Please enter the year' : null,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _addCarData,
                          child: Text(
                            'Add Car',
                            style: TextStyle(
                              color: Colors.white, // Set the text color to white
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 173, 129, 80), // Set the button background color
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
  }
}
