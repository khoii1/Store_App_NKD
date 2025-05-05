import 'dart:convert';
import 'dart:io'; // Import thêm để dùng PlatformException nếu cần phân biệt lỗi mạng

import 'package:flutter/material.dart'; // Import để dùng BuildContext (dù không nên)
import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/models/order.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app/services/manage_http_responses.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderController {
  // --- uploadOrders ---
  // Lưu ý: Truyền context vào đây không phải là cách làm tốt.
  // Nên để hàm này trả về Future<void> và bắt lỗi ở Widget để hiển thị SnackBar.
  uploadOrders({
    required String id,
    required String fullName,
    required String email,
    required String state,
    required String city,
    required String locality,
    required String productName,
    required int productPrice,
    required int quantity,
    required String category,
    required String image,
    required String buyerId,
    required String vendorId,
    required bool processing,
    required bool delivered,
    required BuildContext context, // Không nên truyền context vào controller
  }) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('auth_token');
      if (token == null) {
        // Nên throw lỗi rõ ràng thay vì để lỗi ở dòng token! sau đó
        throw Exception('Authentication token not found.');
      }

      final Order order = Order(
        id: id, // id này thường do backend tạo, bạn có chắc cần truyền từ client?
        fullName: fullName,
        email: email,
        state: state,
        city: city,
        locality: locality,
        productName: productName,
        productPrice: productPrice,
        quantity: quantity,
        category: category,
        image: image, // Đây là một ảnh hay list ảnh? Model Order cần khớp
        buyerId: buyerId,
        vendorId: vendorId,
        processing: processing,
        delivered: delivered,
      );

      http.Response response = await http.post(
        Uri.parse("$uri/api/orders"), // Endpoint tạo order mới
        body: order.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token, // Đã kiểm tra token != null
        },
      );

      // manageHttpResponse có thể cũng dùng context, cần xem xét lại hàm này
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          // Hiển thị SnackBar nên thực hiện ở Widget sau khi gọi hàm này thành công
          showSnackBar(context, 'You have placed an order');
        },
      );
    } catch (e) {
      // Hiển thị SnackBar nên thực hiện ở Widget
      showSnackBar(context, e.toString());
    }
  }

  // --- loadOrders ---
  Future<List<Order>> loadOrders({required String buyerId}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('auth_token');
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$uri/api/orders/$buyerId',
        ), // Endpoint lấy order theo buyerId
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Cần đảm bảo Order.fromJson xử lý đúng cấu trúc JSON trả về
        final List<Order> orders =
            data.map((order) => Order.fromJson(order)).toList();
        return orders;
      } else if (response.statusCode == 404) {
        // Nếu API trả 404 nghĩa là không có đơn hàng nào, trả về list rỗng
        return [];
      } else {
        // Các lỗi khác từ server (500, 401, 403,...)
        // Ném lỗi kèm theo status code và body (nếu có) để debug dễ hơn
        throw Exception(
          'Failed to load orders. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } on SocketException catch (e) {
      // Lỗi mạng cụ thể
      throw Exception('Network error: Failed to load orders. ${e.message}');
    } on FormatException catch (e) {
      // Lỗi parse JSON
      throw Exception(
        'Data format error: Failed to parse orders. ${e.message}',
      );
    } catch (e) {
      // Các lỗi khác không xác định
      throw Exception('Unknown error loading orders: ${e.toString()}');
    }
  }

  // --- deleteOrder ---
  // Tương tự uploadOrders, không nên truyền context
  Future<void> deleteOrder({
    required String id,
    required BuildContext context,
  }) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('auth_token');
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      final response = await http.delete(
        Uri.parse("$uri/api/orders/$id"), // Endpoint xóa order theo id
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Đơn hàng đã được xóa thành công');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // --- getDeliveredOrderCount (Đã sửa) ---
  Future<int> getDeliveredOrderCount({required String buyerId}) async {
    try {
      // Bước 1: Gọi loadOrders để lấy dữ liệu
      List<Order> orders = await loadOrders(buyerId: buyerId);

      // Bước 2: Thực hiện việc đếm trên dữ liệu đã lấy được
      int deliveredCount = orders.where((order) => order.delivered).length;
      return deliveredCount;
    } catch (e) {
      // Bước 3: Bắt lỗi TỪ loadOrders
      // In lỗi gốc ra console để dễ debug
      print(
        "Lỗi gốc xảy ra khi gọi loadOrders (trong getDeliveredOrderCount): $e",
      );

      // Bước 4: Ném LẠI (rethrow) lỗi gốc đó ra ngoài
      // Provider hoặc Widget gọi hàm này sẽ nhận được lỗi gốc chi tiết
      rethrow;

      // --- Hoặc: Ném lỗi mới nhưng bao gồm thông tin lỗi gốc ---
      // throw Exception("Error counting delivered orders: ${e.toString()}");
      // --- Không nên: Ném lỗi chung chung làm mất thông tin lỗi gốc ---
      // throw Exception("Error counting Delivered Orders");
    }
  }
}
