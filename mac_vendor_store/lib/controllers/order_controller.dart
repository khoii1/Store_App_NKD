import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mac_vendor_store/global_variables.dart';
import 'package:mac_vendor_store/models/order.dart';
import 'package:mac_vendor_store/services/manage_http_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderController {
  Future<List<Order>> loadOrders({required String vendorId}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString('auth_token');
      // Gửi một HTTP GET request để lấy các đơn hàng theo vendorId
      final response = await http.get(
        Uri.parse('$uri/api/orders/vendors/$vendorId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      // Kiểm tra xem response status code có phải là 200 (OK) không.
      if (response.statusCode == 200) {
        // Parse phần body của response JSON thành một List động (dynamic List).
        // Điều này chuyển đổi dữ liệu JSON thành một định dạng có thể được xử lý thêm trong Dart.
        final List<dynamic> data = jsonDecode(response.body);

        // Map List động này thành một List các đối tượng Order bằng cách sử dụng factory method `fromJson`.
        // Bước này chuyển đổi dữ liệu thô thành List các instance của Order, dễ dàng làm việc hơn.
        final List<Order> orders =
            data.map((order) => Order.fromJson(order)).toList();
        return orders;
      }
      {
        // Nếu status code không phải là 200, ném ra một exception để báo lỗi.
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('error Loading Orders');
    }
  }

  Future<void> deleteOrder({required String id, required context}) async {
    try {
      // Gửi yêu cầu HTTP DELETE để xóa đơn hàng theo id
      final response = await http.delete(
        Uri.parse("$uri/api/orders/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      // Xử lý phản hồi HTTP
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          // Hiển thị thông báo xóa đơn hàng thành công
          showSnackBar(context, 'Đơn hàng đã được xóa thành công');
        },
      );
    } catch (e) {
      // Xử lý lỗi nếu có lỗi xảy ra trong quá trình xóa đơn hàng
      // Hiển thị thông báo lỗi lên SnackBar
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateDeliveryStatus({
    required String id,
    required context,
  }) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/delivered'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'delivered': true, "processing": false}),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Order Updated');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> cancelOrder({required String id, required context}) async {
    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/orders/$id/processing'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'processing': false, "delivered": false}),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Order Canceled');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
