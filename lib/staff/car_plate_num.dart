import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarPlateNumber extends StatefulWidget {
  final String carId;

  CarPlateNumber({required this.carId});

  @override
  _CarPlateNumberState createState() => _CarPlateNumberState();
}

class _CarPlateNumberState extends State<CarPlateNumber> {
  List<Map<String, dynamic>> _plateNumbers = [];
  int _quantity = 0;
  TextEditingController _editPlateNumberController = TextEditingController();
  TextEditingController _newPlateNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlateNumbers();
  }

  void _loadPlateNumbers() async {
    try {
      final carDoc = await FirebaseFirestore.instance
          .collection('rentalCar')
          .doc(widget.carId)
          .get();
      final plateNumbersSnapshot = await FirebaseFirestore.instance
          .collection('rentalCar')
          .doc(widget.carId)
          .collection('plateNumbers')
          .get();
      setState(() {
        _plateNumbers = plateNumbersSnapshot.docs
            .map((doc) => {'id': doc.id, 'plateNumber': doc['plateNumber']})
            .toList();
        _quantity = _plateNumbers.length;
      });
    } catch (e) {
      print('Error loading plate numbers: $e');
    }
  }

  Future<void> _editPlateNumber(String plateNumberId, String plateNumber) async {
    try {
      await FirebaseFirestore.instance
          .collection('rentalCar')
          .doc(widget.carId)
          .collection('plateNumbers')
          .doc(plateNumberId)
          .update({'plateNumber': plateNumber});
      _loadPlateNumbers();
    } catch (e) {
      print('Error editing plate number: $e');
    }
  }

  Future<void> _deletePlateNumber(String plateNumberId) async {
    try {
      await FirebaseFirestore.instance
          .collection('rentalCar')
          .doc(widget.carId)
          .collection('plateNumbers')
          .doc(plateNumberId)
          .delete();
      _updateQuantity(-1);
    } catch (e) {
      print('Error deleting plate number: $e');
    }
  }

  Future<void> _addPlateNumber(String plateNumber) async {
    try {
      await FirebaseFirestore.instance
          .collection('rentalCar')
          .doc(widget.carId)
          .collection('plateNumbers')
          .add({'plateNumber': plateNumber});
      _updateQuantity(1);
    } catch (e) {
      print('Error adding plate number: $e');
    }
  }

  Future<void> _updateQuantity(int change) async {
    setState(() {
      _quantity += change;
    });
    try {
      final carDoc = await FirebaseFirestore.instance
          .collection('rentalCar')
          .doc(widget.carId)
          .get();
      final currentAvailableQty = carDoc['availableQty'];
      final newAvailableQty = currentAvailableQty + change;
      await FirebaseFirestore.instance
          .collection('rentalCar')
          .doc(widget.carId)
          .update({'quantity': _quantity, 'availableQty': newAvailableQty});
      _loadPlateNumbers();
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> _confirmDelete(String plateNumberId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this plate number?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deletePlateNumber(plateNumberId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Quantity: $_quantity'),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _plateNumbers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_plateNumbers[index]['plateNumber']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editPlateNumberController.text = _plateNumbers[index]['plateNumber'];
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
                                        _plateNumbers[index]['id'],
                                        _editPlateNumberController.text,
                                      );
                                      _editPlateNumberController.clear();
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
                          _confirmDelete(_plateNumbers[index]['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
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
                            _newPlateNumberController.clear();
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
      backgroundColor: Color.fromARGB(255, 255, 217, 195),
    );
  }
}
