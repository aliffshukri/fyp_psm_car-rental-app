import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_psm/pages/login_page.dart';
import 'package:fyp_psm/staff/car_rental_page.dart';
import 'package:fyp_psm/staff/cust_booking_page.dart';
import 'package:fyp_psm/staff/track_page.dart';
import 'package:fyp_psm/staff/custdetails_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String reportType = 'Booking';
  String frequency = 'Past 3 days';
  List<Map<String, dynamic>> reportData = [];

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300, // Set the height of the ListView here
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Filter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true, // This makes the scrollbar always visible
                  child: ListView(
                    children: <String>[
                      'Booking',
                      'Fuel Status',
                      'Car Rental',
                      'Age Category',
                    ].map((String value) {
                      return ListTile(
                        title: Text(value),
                        onTap: () {
                          setState(() {
                            reportType = value;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Rental Car Management",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
            icon: Icon(
              Icons.logout,
              size: 40.0,
              color: const Color.fromARGB(255, 7, 7, 7),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showFilterOptions,
              child: Text('Report Type: $reportType'),
            ),
            ElevatedButton(
              onPressed: generateReport,
              child: Text('Generate Report'),
            ),
            Expanded(
              child: reportData.isEmpty
                  ? Center(child: Text('No data available'))
                  : _buildChart(),
            ),
            ElevatedButton(
              onPressed: downloadReport,
              child: Text('Download Report as PDF'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Verification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental, size: 24),
            label: 'Car Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, size: 24),
            label: 'Cust Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 24),
            label: 'Track Customer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt, size: 24),
            label: 'Generate Report',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: 4,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CustDetailsPage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StaffCarRentalPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CustomerBookingPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TrackPage()),
              );
              break;
            case 4:
              break;
          }
        },
      ),
      backgroundColor: Color.fromARGB(255, 255, 217, 195),
    );
  }

  Widget _buildChart() {
  switch (reportType) {
    case 'Booking':
      return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        legend: Legend(isVisible: true),
        series: <CartesianSeries>[
          LineSeries<Map<String, dynamic>, String>(
            dataSource: reportData,
            xValueMapper: (Map<String, dynamic> data, _) => data['category'],
            yValueMapper: (Map<String, dynamic> data, _) => data['count'] as int,
            color: Colors.yellow,
            name: 'Past 5 days',
          ),
          LineSeries<Map<String, dynamic>, String>(
            dataSource: reportData,
            xValueMapper: (Map<String, dynamic> data, _) => data['category'],
            yValueMapper: (Map<String, dynamic> data, _) => data['count'] as int,
            color: Colors.green,
            name: 'Past a week',
          ),
          LineSeries<Map<String, dynamic>, String>(
            dataSource: reportData,
            xValueMapper: (Map<String, dynamic> data, _) => data['category'],
            yValueMapper: (Map<String, dynamic> data, _) => data['count'] as int,
            color: Colors.blue,
            name: 'Past a month',
          ),
        ],
      );
    case 'Fuel Status':
      return SfCircularChart(
        legend: Legend(isVisible: true),
        series: <CircularSeries>[
          PieSeries<Map<String, dynamic>, String>(
            dataSource: reportData,
            xValueMapper: (Map<String, dynamic> data, _) => data['category'],
            yValueMapper: (Map<String, dynamic> data, _) => data['count'] as int,
            dataLabelSettings: DataLabelSettings(isVisible: true),
            pointColorMapper: (Map<String, dynamic> data, _) => data['category'] == 'Yes' ? Colors.green : Colors.red,
          ),
        ],
      );
    case 'Car Rental':
      return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries>[
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: reportData,
            xValueMapper: (Map<String, dynamic> data, _) => data['category'],
            yValueMapper: (Map<String, dynamic> data, _) => data['count'] as int,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      );

    case 'Age Category':
      return SfCartesianChart(
        primaryXAxis: CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          interval: 1,
          majorGridLines: MajorGridLines(width: 0.5),
        ),
        series: <CartesianSeries>[
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: reportData,
            xValueMapper: (Map<String, dynamic> data, _) => data['category'],
            yValueMapper: (Map<String, dynamic> data, _) => data['count'] as int,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      );
    default:
      return Center(child: Text('Invalid report type'));
  }
}


  Future<void> generateReport() async {
    DateTime now = DateTime.now();
    DateTime startDate;
    if (frequency == 'Past 3 days') {
      startDate = now.subtract(Duration(days: 3));
    } else if (frequency == 'Past 5 days') {
      startDate = now.subtract(Duration(days: 5));
    } else {
      startDate = now.subtract(Duration(days: 7));
    }

    QuerySnapshot querySnapshot;
    if (reportType == 'Booking') {
      querySnapshot = await FirebaseFirestore.instance
          .collection('booking')
          .where('bookingDateTime', isGreaterThan: startDate)
          .get();
      List<Map<String, dynamic>> data = querySnapshot.docs.map((doc) {
        return {
          'category': doc['carModel'],
          'count': 1,
        };
      }).toList();

      Map<String, int> bookingCounts = {};
      for (var item in data) {
        bookingCounts.update(item['category'], (value) => value + 1, ifAbsent: () => 1);
      }

      setState(() {
        reportData = bookingCounts.entries.map((entry) {
          return {'category': entry.key, 'count': entry.value};
        }).toList();
      });
    } else if (reportType == 'Fuel Status') {
      querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('fuel')
          .get();
      List<Map<String, dynamic>> data = querySnapshot.docs.map((doc) {
        return {
          'category': doc['isRefuel'] ? 'Yes' : 'No',
          'count': 1,
        };
      }).toList();

      Map<String, int> fuelCounts = {};
      for (var item in data) {
        fuelCounts.update(item['category'], (value) => value + 1, ifAbsent: () => 1);
      }

      setState(() {
        reportData = fuelCounts.entries.map((entry) {
          return {'category': entry.key, 'count': entry.value};
        }).toList();
      });
    } else if (reportType == 'Car Rental') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('rentalCar')
            .get();
        List<Map<String, dynamic>> data = querySnapshot.docs.map((doc) {
          return {
            'category': '${doc['brand']} ${doc['carModel']}',
            'count': doc['quantity'],
          };
        }).toList();

        setState(() {
          reportData = data;
        });
    } else if (reportType == 'Age Category') {
      querySnapshot = await FirebaseFirestore.instance.collection('customer').get();
      List<Map<String, dynamic>> data = querySnapshot.docs.map((doc) {
        int age = doc['age'];
        String category;
        if (age >= 18 && age <= 21) {
          category = '18-21';
        } else if (age >= 22 && age <= 30) {
          category = '22-30';
        } else if (age >= 31 && age <= 50) {
          category = '31-50';
        } else {
          category = '50+';
        }
        return {'category': category, 'count': 1};
      }).toList();

      Map<String, int> ageCounts = {};
      for (var item in data) {
        ageCounts.update(item['category'], (value) => value + 1, ifAbsent: () => 1);
      }

      setState(() {
        reportData = ageCounts.entries.map((entry) {
          return {'category': entry.key, 'count': entry.value};
        }).toList();
      });
    }

  }

  Future<void> downloadReport() async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfTextElement element = PdfTextElement(
      text: 'Report: $reportType\nFrequency: $frequency\n\n',
      font: font,
    );
    element.draw(page: page, bounds: Rect.fromLTWH(0, 0, 0, 0));

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 2);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Category';
    header.cells[1].value = 'Count';

    for (var data in reportData) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = data['category'];
      row.cells[1].value = data['count'].toString();
    }

    grid.draw(page: page, bounds: Rect.fromLTWH(0, 50, 0, 0));

    final List<int> bytes = await document.save();
    document.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/Report.pdf');
    await file.writeAsBytes(bytes, flush: true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report saved as ${file.path}')),
    );
  }
}
