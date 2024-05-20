/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarPlateNumber extends StatefulWidget {
  final String carId;

  CarPlateNumber({required this.carId});

  @override
  _CarPlateNumberState createState() => _CarPlateNumberState();
}

class _CarPlateNumberState extends State<CarPlateNumber> {
  List<String> _plateNumbers = [];
  TextEditingController _editPlateNumberController = TextEditingController();
  TextEditingController _newPlateNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlateNumbers();
  }

  void _loadPlateNumbers() async {
    try {
      final plateNumbersSnapshot = await FirebaseFirestore.instance
          .collection('rentalCar')
          .doc(widget.carId)
          .collection('plateNumbers')
          .get();
      setState(() {
        _plateNumbers = plateNumbersSnapshot.docs.map((doc) => doc['plateNumber'] as String).toList();
      });
    } catch (e) {
      print('Error loading plate numbers: $e');
    }
  }

  Future<void> _editPlateNumber(String plateNumberId, String plateNumber) async {
    // Implement editing of plate number
    await FirebaseFirestore.instance
        .collection('rentalCar')
        .doc(widget.carId)
        .collection('plateNumbers')
        .doc(plateNumberId)
        .update({'plateNumber': plateNumber});
    _loadPlateNumbers();
  }

  Future<void> _deletePlateNumber(String plateNumberId) async {
    // Implement deletion of plate number
    await FirebaseFirestore.instance
        .collection('rentalCar')
        .doc(widget.carId)
        .collection('plateNumbers')
        .doc(plateNumberId)
        .delete();
    _loadPlateNumbers();
  }

  Future<void> _addPlateNumber(String plateNumber) async {
    // Implement addition of new plate number
    await FirebaseFirestore.instance
        .collection('rentalCar')
        .doc(widget.carId)
        .collection('plateNumbers')
        .add({'plateNumber': plateNumber});
    _loadPlateNumbers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Plate Numbers'),
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display existing plate numbers
            ListView.builder(
              shrinkWrap: true,
              itemCount: _plateNumbers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_plateNumbers[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Edit Plate Number'),
                                content: TextField(
                                  controller: _editPlateNumberController,
                                  decoration: InputDecoration(labelText: 'Plate Number'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      _editPlateNumber(
                                        _plateNumbers[index], // Assuming the plate number is the ID
                                        _editPlateNumberController.text,
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deletePlateNumber(_plateNumbers[index]); // Assuming the plate number is the ID
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            // Button to add new plate numbers
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Add New Plate Number'),
                      content: TextField(
                        controller: _newPlateNumberController,
                        decoration: InputDecoration(labelText: 'Plate Number'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _addPlateNumber(_newPlateNumberController.text);
                            Navigator.of(context).pop();
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Add New Plate Number'),
            ),
          ],
        ),
      ),
    );
  }
}
*/