import 'package:app_web/views/side_bar_screens/widgets/order_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersScreen extends StatelessWidget {
  static const String id = 'orderscreen';
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget rowHeader(int flex, String text) {
      return Expanded(
        flex: flex,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700),
            color: const Color(0xFF3C55EF),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                'Manage Orders',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                rowHeader(2, 'Product Image'),
                rowHeader(3, 'Product Name'),
                rowHeader(2, 'Product Price'),
                rowHeader(3, 'Product Category'),
                rowHeader(3, 'Buyer Name'),
                rowHeader(2, 'Buyer Email'),
                rowHeader(2, 'Buyer Address'),
                rowHeader(1, 'Status'),
              ],
            ),
            OrderWidget(),
          ],
        ),
      ),
    );
  }
}
