import 'package:app_web/controllers/buyer_controller.dart';
import 'package:app_web/models/buyer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyerWidget extends StatefulWidget {
  const BuyerWidget({super.key});

  @override
  State<BuyerWidget> createState() => _BuyerWidgetState();
}

class _BuyerWidgetState extends State<BuyerWidget> {
  late Future<List<Buyer>> futureBuyer;
  @override
  void initState() {
    super.initState();
    futureBuyer = BuyerController().loadBuyers();
  }

  @override
  Widget build(BuildContext context) {
    Widget buyerData(int flex, Widget widget) {
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
      future: futureBuyer,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Banners'));
        } else {
          final buyers = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: buyers.length,

            itemBuilder: (context, index) {
              final buyer = buyers[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    buyerData(
                      1,
                      CircleAvatar(
                        child: Text(
                          buyer.fullName[0],
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    buyerData(
                      3,
                      Text(
                        buyer.fullName,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buyerData(
                      2,
                      Text(
                        buyer.email,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buyerData(
                      2,
                      Text(
                        "${buyer.state} ${buyer.city}",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    buyerData(
                      1,
                      TextButton(onPressed: () {}, child: Text('DELETE')),
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
