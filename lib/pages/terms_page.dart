import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 178, 191, 83),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        centerTitle: true,
        title: Text(
          "Terms and Conditions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 173, 129, 80),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background color for the container
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: EdgeInsets.all(20.0), // Padding inside the container
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTerm("1.", "The MINIMUM age for borrowers and additional drivers is 18 YEARS OLD and MUST have a valid and current local driver's license. Probationary driving license holders will not be accepted."),
              _buildTerm("2.", "Customer need to update the fuel status after finishing their rental period."),
              _buildTerm("3.", "The vehicle's fuel meter bar when received must be the same as when the vehicle is returned. Reducing the fuel meter bar from the original will incur an ADDITIONAL CHARGE. The cost of fuel is the responsibility of the customer, and it cannot be claimed."),
              _buildTerm("4.", "The penalty payment period is ONE WEEK from the rental end date. Failure to pay the fine during that period, your account will be DISABLE."),
              _buildTerm("5.", "The customer is responsible for paying all summonses, compounds, or fines throughout the rental period."),
              _buildTerm("6.", "The customer is responsible for ensuring that the car is always in good condition and clean throughout the rental period until the vehicle is returned. Borrowers are absolutely FORBIDDEN to spit, smoke or litter in the car. If it is found that the exterior and interior of the car are very dirty such as spilled water or food on the car dashboard, door panels or cushions, and there is an unpleasant smell or there is any damage, the CUSTOMER will be charged an ADDITIONAL CHARGE for cleaning and all the costs of restoring the vehicle to condition original."),
              _buildTerm("7.", "The customer rental car will be tracked during rental period by the staff for safety reasons."),
              _buildTerm("8.", "If an accident occurs, the CUSTOMER must inform us as soon as possible and not take any other action before that to avoid problems between the borrower and us in the future."),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
          child: Text("Return to Register"),
        ),
      ),
    );
  }

  Widget _buildTerm(String number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
