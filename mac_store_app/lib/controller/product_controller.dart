import 'dart:convert';

import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/models/product.dart';
import 'package:http/http.dart' as http;

class ProductController {
  Future<List<Product>> loadPopularProducts(String category) async {
    try {
      http.Response response = await http.get(
        Uri.parse("$uri/api/popular-products"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Product> products =
            data
                .map(
                  (product) => Product.fromMap(product as Map<String, dynamic>),
                )
                .toList();
        return products;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load popular products');
      }
    } catch (e) {
      throw Exception('Error loading product : $e');
    }
  }

  Future<List<Product>> loadProductByCategory(String category) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/products-by-category/$category'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Product> products =
            data
                .map(
                  (product) => Product.fromMap(product as Map<String, dynamic>),
                )
                .toList();
        return products;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load popular products');
      }
    } catch (e) {
      throw Exception('Error loading product : $e');
    }
  }

  //display related products by subcategory

  Future<List<Product>> loadRelatedProductsBySubcategory(
    String productId,
  ) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/related-products-by-subcategory/$productId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Product> relatedProducts =
            data
                .map(
                  (product) => Product.fromMap(product as Map<String, dynamic>),
                )
                .toList();
        return relatedProducts;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load related products');
      }
    } catch (e) {
      throw Exception('Error related product : $e');
    }
  }

  //
  Future<List<Product>> loadTopRatedProduct() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/top-rated-products'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Product> topRateProducts =
            data
                .map(
                  (product) => Product.fromMap(product as Map<String, dynamic>),
                )
                .toList();
        return topRateProducts;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load top Rate products');
      }
    } catch (e) {
      throw Exception('Error topRateProducts product : $e');
    }
  }
}
