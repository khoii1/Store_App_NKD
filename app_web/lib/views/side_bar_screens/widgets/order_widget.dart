import 'package:app_web/controllers/order_controller.dart';

import 'package:app_web/models/order.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  late Future<List<Order>> futureOrders;
  @override
  void initState() {
    super.initState();
    futureOrders = OrderController().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    Widget orderData(int flex, Widget widget) {
      return Expanded(
        flex: flex,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: Padding(padding: const EdgeInsets.all(8), child: widget),
        ),
      );
    }

    return FutureBuilder(
      future: futureOrders,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Orders'));
        } else {
          final orders = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: orders.length,

            itemBuilder: (context, index) {
              final order = orders[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    orderData(
                      2,
                      Image.network(order.image, width: 50, height: 50),
                    ),
                    orderData(
                      3,
                      Text(
                        order.productName,
                        style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    orderData(
                      2,
                      Text(
                        "\$${order.productPrice.toStringAsFixed(2)}",
                        style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    orderData(
                      3,
                      Text(
                        order.category,
                        style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    orderData(
                      3,
                      Text(
                        order.fullName,
                        style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),

                    orderData(
                      2,
                      Text(
                        order.email,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    orderData(
                      2,
                      Text(
                        order.locality,
                        style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    orderData(
                      1,
                      Text(
                        order.delivered == true
                            ? "delivered"
                            : order.processing == true
                            ? "processing"
                            : "canceled",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
