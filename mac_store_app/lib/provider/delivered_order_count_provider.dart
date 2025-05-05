import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app/controller/order_controller.dart';
import 'package:mac_store_app/services/manage_http_responses.dart';

class DeliveredOrderCountProvider extends StateNotifier<int> {
  DeliveredOrderCountProvider() : super(0);
  Future<void> fetchDeliveredOrderCount(String buyerId, context) async {
    try {
      OrderController orderController = OrderController();
      int count = await orderController.getDeliveredOrderCount(
        buyerId: buyerId,
      );
      state = count;
    } catch (e) {
      showSnackBar(context, "Error Fetching Delivered order : $e");
    }
  }

  void resetCount() {
    state = 0;
  }
}

final deliveredOrderCountProvider =
    StateNotifierProvider<DeliveredOrderCountProvider, int>((ref) {
      return DeliveredOrderCountProvider();
    });
