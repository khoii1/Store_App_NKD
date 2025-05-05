import 'dart:convert';
import 'package:app_web/gloab_variable.dart';
import 'package:app_web/models/order.dart';
import 'package:http/http.dart' as http;

class OrderController {
  Future<List<Order>> loadOrders() async {
    try {
      // Gửi một yêu cầu HTTP GET để lấy danh sách đơn hàng từ server
      final response = await http.get(
        Uri.parse('$uri/api/orders'),
        // Đặt headers để chỉ định kiểu nội dung là JSON, đảm bảo mã hóa và giao tiếp đúng cách
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      // Kiểm tra xem mã trạng thái phản hồi HTTP có phải là 200 hay không, nghĩa là yêu cầu thành công
      if (response.statusCode == 200) {
        // Giải mã phần thân phản hồi JSON thành danh sách các đối tượng động
        final List<dynamic> data = jsonDecode(response.body);

        // Ánh xạ từng đối tượng JSON thành một đối tượng Order
        final List<Order> orders =
            data.map((order) => Order.fromJson(order)).toList();

        return orders;
      } else {
        // Xử lý lỗi nếu mã trạng thái không phải 200
        throw Exception(
          'Failed to load orders. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Xử lý lỗi nếu có bất kỳ lỗi nào xảy ra trong quá trình thực hiện yêu cầu
      throw Exception('Error loading orders: $e');
    }
  }
}
