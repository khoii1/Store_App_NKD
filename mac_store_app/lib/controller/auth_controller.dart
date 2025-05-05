import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app/models/user.dart';
import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/provider/delivered_order_count_provider.dart';
import 'package:mac_store_app/provider/user_provider.dart';
import 'package:mac_store_app/services/manage_http_responses.dart';
import 'package:mac_store_app/views/screens/authentication_screens/login_screen.dart';
import 'package:mac_store_app/views/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  Future<void> signUpUsers({
    required BuildContext context,
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      User user = User(
        id: '',
        fullName: fullName,
        email: email,
        state: '',
        city: '',
        locality: '',
        password: password,
        token: '',
      );

      http.Response response = await http.post(
        Uri.parse('$uri/api/signup'), // Gửi yêu cầu POST đến API đăng ký
        body:
            user.toJson(), // Chuyển đổi đối tượng `user` thành JSON để gửi lên server
        headers: <String, String>{
          "Content-Type":
              'application/json; charset=UTF-8', // Định dạng nội dung gửi là JSON
        },
      );
      // Gọi hàm xử lý phản hồi từ server
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          showSnackBar(
            context,
            'Account has been Created for you',
          ); // Hiển thị thông báo thành công
        },
      );

      // Xử lý lỗi nếu có
    } catch (e) {
      print('Lỗi xảy ra: $e'); // In lỗi ra console để dễ debug
    }
  }

  Future<void> signInUsers({
    required BuildContext context,
    required String email,
    required String password,
    required WidgetRef ref,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse("$uri/api/signin"),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String token = jsonDecode(response.body)['token'];
          await preferences.setString('auth_token', token);
          final userJson = jsonEncode(jsonDecode(response.body)['user']);
          ref.read(userProvider.notifier).setUser(userJson);

          await preferences.setString('user', userJson);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
          showSnackBar(context, 'Logged In');
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  //Signout
  Future<void> signOutUser({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove('auth_token');
      await preferences.remove('user');
      ref.read(userProvider.notifier).signOut();
      ref.read(deliveredOrderCountProvider.notifier).resetCount();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginScreen();
          },
        ),
        (route) => false,
      );
      showSnackBar(context, 'signout successfully');
    } catch (e) {
      showSnackBar(context, 'error signing out');
    }
  }

  Future<void> updateUserLocation({
    required BuildContext context,
    required String id,
    required String state,
    required String city,
    required String locality,
    required WidgetRef ref,
  }) async {
    try {
      final http.Response response = await http.put(
        Uri.parse('$uri/api/users/$id'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'state': state, 'city': city, 'locality': locality}),
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          final updateUser = jsonDecode(response.body);
          SharedPreferences preferences = await SharedPreferences.getInstance();
          final userJson = jsonEncode(updateUser);
          ref.read(userProvider.notifier).setUser(userJson);
          await preferences.setString('user', userJson);
        },
      );
    } catch (e) {
      showSnackBar(context, 'Error updating location');
    }
  }
}
