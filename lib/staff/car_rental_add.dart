import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

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
  late TextEditingController _quantityController;
  late TextEditingController _priceHourController;
  bool _isLoading = false;
  List<TextEditingController> _plateNumberControllers = [];
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _quantityController.addListener(_updatePlateNumberFields);
  }

  void _initializeControllers() {
    _brandController = TextEditingController();
    _carModelController = TextEditingController();
    _carTypeController = TextEditingController();
    _fuelTankCapacityController = TextEditingController();
    _numberOfSeatsController = TextEditingController();
    _transmissionTypeController = TextEditingController();
    _yearController = TextEditingController();
    _quantityController = TextEditingController(); // Initialize quantity controller
    _priceHourController = TextEditingController(); // Initialize price per hour controller
  }

  void _updatePlateNumberFields() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _plateNumberControllers = List.generate(
        quantity,
        (index) => TextEditingController(),
      );
    });
  }

  Future<void> _addCarData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String imageUrl = '';
        if (_image != null) {
          imageUrl = await _uploadImageToFirebase(_image!);
        }

        DocumentReference carDoc = await FirebaseFirestore.instance.collection('rentalCar').add({
          'brand': _brandController.text,
          'carModel': _carModelController.text,
          'carType': _carTypeController.text,
          'fuelTankCapacity': _fuelTankCapacityController.text,
          'numberOfSeats': int.parse(_numberOfSeatsController.text),
          'transmissionType': _transmissionTypeController.text,
          'year': int.parse(_yearController.text),
          'quantity': int.parse(_quantityController.text),
          'availableQty': int.parse(_quantityController.text), // Added availableQty
          'priceHour': double.parse(_priceHourController.text),
          'carImage': imageUrl,
        });

        for (int i = 0; i < _plateNumberControllers.length; i++) {
          await carDoc.collection('plateNumbers').add({
            'plateNumber': _plateNumberControllers[i].text,
          });
        }

        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Error adding car data: $e');
      }
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('carImages/$fileName');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
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
    _quantityController.dispose(); // Dispose of quantity controller
    _priceHourController.dispose(); // Dispose of price per hour controller
    _plateNumberControllers.forEach((controller) => controller.dispose());
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
                        _buildTextFormField(
                          controller: _priceHourController,
                          label: 'Price per Hour',
                          validator: (value) => value!.isEmpty ? 'Please enter the price per hour' : null,
                        ),
                        _buildTextFormField(
                          controller: _quantityController,
                          label: 'Quantity',
                          validator: (value) => value!.isEmpty ? 'Please enter the quantity' : null,
                        ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text('Pick Car Image'),
                        ),
                        if (_image != null)
                          Image.file(
                            _image!,
                            height: 200,
                          ),
                        if (_plateNumberControllers.isNotEmpty) ..._buildPlateNumberFields(),
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
            backgroundColor: Color.fromARGB(255, 255, 217, 195),
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

  List<Widget> _buildPlateNumberFields() {
    return List<Widget>.generate(_plateNumberControllers.length, (index) {
      return _buildTextFormField(
        controller: _plateNumberControllers[index],
        label: 'Plate Number ${index + 1}',
        validator: (value) => value!.isEmpty ? 'Please enter the plate number' : null,
      );
    });
  }
}
