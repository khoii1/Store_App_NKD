import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Hàm xử lý phản hồi HTTP từ yêu cầu mạng
void manageHttpResponse({
  required http.Response response, // Phản hồi HTTP từ request
  required BuildContext context, // Context dùng để hiển thị snackbar
  required VoidCallback
  onSuccess, // Hàm callback sẽ thực thi khi request thành công
}) {
  // Sử dụng switch-case để xử lý các mã trạng thái HTTP khác nhau
  switch (response.statusCode) {
    case 200: // Mã trạng thái 200 thể hiện request thành công
      onSuccess();
      break;
    case 400: // Mã trạng thái 400 thể hiện request bị lỗi (Bad Request)
      showSnackBar(context, json.decode(response.body)['msg']);
      break;
    case 500:
      showSnackBar(context, json.decode(response.body)['error']);
      break;
    case 201:
      onSuccess();
      break;
  }
}

/// Hàm hiển thị thông báo lỗi bằng Snackbar
void showSnackBar(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
}
