import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeriodPrice extends StatefulWidget {
  final String carId;

  PeriodPrice({required this.carId});

  @override
  _PeriodPriceState createState() => _PeriodPriceState();
}

class _PeriodPriceState extends State<PeriodPrice> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _price1HourController;
  late TextEditingController _price2HoursController;
  late TextEditingController _price4HoursController;
  late TextEditingController _price6HoursController;
  late TextEditingController _price12HoursController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadPeriodPrices();
  }

  void _loadPeriodPrices() async {
  try {
    final docSnapshot = await FirebaseFirestore.instance.collection('periodPrice').doc(widget.carId).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _price1HourController.text = data['1Hour'] ?? '';
        _price2HoursController.text = data['2Hour'] ?? '';
        _price4HoursController.text = data['4Hour'] ?? '';
        _price6HoursController.text = data['6Hour'] ?? '';
        _price12HoursController.text = data['12Hour'] ?? '';
      });
    }
  } catch (e) {
    print('Error loading period prices: $e');
  }
}

  void _initializeControllers() {
    _price1HourController = TextEditingController();
    _price2HoursController = TextEditingController();
    _price4HoursController = TextEditingController();
    _price6HoursController = TextEditingController();
    _price12HoursController = TextEditingController();
  }

  Future<void> _savePeriodPrices() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('periodPrice').doc(widget.carId).set({
          '1Hour': _price1HourController.text,
          '2Hour': _price2HoursController.text,
          '4Hour': _price4HoursController.text,
          '6Hour': _price6HoursController.text,
          '12Hour': _price12HoursController.text,
        });
        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Error saving period prices: $e');
      }
    }
  }

  @override
  void dispose() {
    _price1HourController.dispose();
    _price2HoursController.dispose();
    _price4HoursController.dispose();
    _price6HoursController.dispose();
    _price12HoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Period Prices'),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextFormField(
                          controller: _price1HourController,
                          label: 'Price for 1 Hour',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter the price for 1 hour' : null,
                        ),
                        _buildTextFormField(
                          controller: _price2HoursController,
                          label: 'Price for 2 Hours',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter the price for 2 hours' : null,
                        ),
                        _buildTextFormField(
                          controller: _price4HoursController,
                          label: 'Price for 4 Hours',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter the price for 4 hours' : null,
                        ),
                        _buildTextFormField(
                          controller: _price6HoursController,
                          label: 'Price for 6 Hours',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter the price for 6 hours' : null,
                        ),
                        _buildTextFormField(
                          controller: _price12HoursController,
                          label: 'Price for 12 Hours',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter the price for 12 hours' : null,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _savePeriodPrices,
                          child: Text(
                            'Set Rental Period',
                            style: TextStyle(
                              color: Colors.white, // Set the text color to white
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 173, 129, 80),
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
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
  }
}
