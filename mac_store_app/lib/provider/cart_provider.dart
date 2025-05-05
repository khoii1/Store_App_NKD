import 'dart:convert';

import 'package:mac_store_app/models/cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, Cart>>((
  ref,
) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Map<String, Cart>> {
  CartNotifier() : super({}) {
    _loadCartItems();
  }
  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart_items');
    if (cartString != null) {
      final Map<String, dynamic> cartMap = jsonDecode(cartString);
      final cartItems = cartMap.map(
        (key, value) => MapEntry(key, Cart.fromJson(value)),
      );
      state = cartItems;
    }
  }

  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = jsonEncode(state);
    await prefs.setString('cart_items', cartString);
  }

  void addProductToCart({
    required String productName,
    required int productPrice,
    required String category,
    required List<String> image,
    required String vendorId,
    required int productQuantity,
    required int quantity,
    required String productId,
    required String description,
    required String fullName,
  }) {
    if (state.containsKey(productId)) {
      state = {
        ...state,
        productId: Cart(
          productName: state[productId]!.productName,
          productPrice: state[productId]!.productPrice,
          category: state[productId]!.category,
          image: state[productId]!.image,
          vendorId: state[productId]!.vendorId,
          productQuantity: state[productId]!.productQuantity,
          quantity: state[productId]!.quantity + 1,
          productId: state[productId]!.productId,
          description: state[productId]!.description,
          fullName: state[productId]!.fullName,
        ),
      };
      _saveCartItems();
    } else {
      state = {
        ...state,
        productId: Cart(
          productName: productName,
          productPrice: productPrice,
          category: category,
          image: image,
          vendorId: vendorId,
          productQuantity: productQuantity,
          quantity: quantity,
          productId: productId,
          description: description,
          fullName: fullName,
        ),
      };
      _saveCartItems();
    }
  }

  void incrementCartItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity++;
      state = {...state};
      _saveCartItems();
    }
  }

  void decrementCartItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity--;
      state = {...state};
      _saveCartItems();
    }
  }

  void removeCartItem(String productId) {
    state.remove(productId);
    state = {...state};
    _saveCartItems();
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.quantity * cartItem.productPrice;
    });
    return totalAmount;
  }

  void clearCart() {
    state = {};

    state = {...state};
    _saveCartItems();
  }

  Map<String, Cart> get getCartItems => state;
}
