import 'dart:convert';

import 'package:app_web/gloab_variable.dart';
import 'package:app_web/services/manage_http_response.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:app_web/models/category.dart';
import 'package:http/http.dart' as http;

class CategoryController {
  uploadCategory({
    required dynamic pickedImage,
    required dynamic pickedBanner,
    required String name,
    required context,
  }) async {
    try {
      final cloudinary = CloudinaryPublic('diml6g3k2', 'z1i9mwmp');
      //upload the image

      CloudinaryResponse imageResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          pickedImage,
          identifier: 'pickImage',
          folder: 'categoryImages',
        ),
      );
      String image = imageResponse.secureUrl;

      CloudinaryResponse bannerResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          pickedBanner,
          identifier: 'pickedBanner',
          folder: 'categoryImages',
        ),
      );

      String banner = bannerResponse.secureUrl;

      Category category = Category(
        id: "",
        name: name,
        image: image,
        banner: banner,
      );
      http.Response response = await http.post(
        Uri.parse("$uri/api/categories"),
        body: category.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Uploaded Category');
        },
      );
    } catch (e) {
      print('Error uploading to cloudinary: $e');
    }
  }

  // load the upload category

  Future<List<Category>> loadCategories() async {
    try {
      // send an http get request to load the categories
      http.Response response = await http.get(
        Uri.parse('$uri/api/categories'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<Category> categories =
            data.map((category) => Category.fromJson(category)).toList();

        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error loading Categories: $e');
    }
  }
}
