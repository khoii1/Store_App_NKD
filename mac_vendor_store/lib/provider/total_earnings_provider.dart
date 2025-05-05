import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/models/order.dart';

// A class that extends StateNotifier to manage the state of total earnings.
class TotalEarningsProvider extends StateNotifier<Map<String, dynamic>> {
  // Constructor that initializes the state with 0.0 (representing zero initial total earnings).
  TotalEarningsProvider() : super({'totalEarnings': 0.0, "totalOrders": 0});

  // Method to calculate the total earnings based on orders marked as delivered.
  void calculateEarnings(List<Order> orders) {
    // Initialize a local variable to accumulate the earnings.
    double earnings = 0.0;
    int orderCount = 0;

    // Loop through each order in the provided list.
    for (Order order in orders) {
      // Check if the current order has been delivered.
      if (order.delivered) {
        orderCount++;
        // If delivered, add the order's total value (price * quantity) to the earnings.
        earnings += order.productPrice * order.quantity;
      }
    }
    // Update the state with the calculated total earnings.
    // This will notify any listeners subscribed to this state.
    state = {'totalEarnings': earnings, 'totalOrders': orderCount};
  }
}

final totalEarningsProvider =
    StateNotifierProvider<TotalEarningsProvider, Map<String, dynamic>>((ref) {
      return TotalEarningsProvider();
    });
