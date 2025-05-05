import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app/controller/product_controller.dart'; // Đảm bảo import đúng
import 'package:mac_store_app/models/product.dart'; // Import Product model
// import 'package:mac_store_app/provider/product_provider.dart'; // Provider này có vẻ không dùng ở đây?
import 'package:mac_store_app/provider/top_rated_product_provider.dart'; // Đảm bảo import đúng
import 'package:mac_store_app/views/screens/nav_screen/widgets/product_item_widget.dart'; // Đảm bảo import đúng

// ----- Provider (Giả sử đã có ở top_rated_product_provider.dart) -----
// class TopRatedProductProvider extends StateNotifier<List<Product>> {
//   TopRatedProductProvider() : super([]);
//   void setProducts(List<Product> products) {
//     state = products;
//   }
// }
// final topRatedProductProvider = StateNotifierProvider<TopRatedProductProvider, List<Product>>((ref) {
//   return TopRatedProductProvider();
// });
// -----------------------------------------------------------------

class TopRatedProductWidget extends ConsumerStatefulWidget {
  const TopRatedProductWidget({super.key});

  @override
  ConsumerState<TopRatedProductWidget> createState() =>
      _TopRatedProductWidgetState();
}

class _TopRatedProductWidgetState extends ConsumerState<TopRatedProductWidget> {
  bool _isLoading = true; // Đổi tên biến

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Đọc provider cụ thể cho top rated products
        final products = ref.read(topRatedProductProvider);
        if (products.isEmpty) {
          _fetchProduct();
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    });
  }

  Future<void> _fetchProduct() async {
    final ProductController productController = ProductController();
    try {
      final products = await productController.loadTopRatedProduct();
      // *** KIỂM TRA MOUNTED ***
      if (mounted) {
        // Cập nhật đúng provider
        ref.read(topRatedProductProvider.notifier).setProducts(products);
      }
    } catch (e) {
      print('Lỗi khi tải sản phẩm top rated: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải sản phẩm: ${e.toString()}')),
        );
      }
    } finally {
      // *** KIỂM TRA MOUNTED ***
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch đúng provider
    final products = ref.watch(topRatedProductProvider);
    return SizedBox(
      height: 250,
      child:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              )
              : products.isEmpty
              ? const Center(child: Text('Không có sản phẩm nào.'))
              : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductItemWidget(product: product);
                },
              ),
    );
  }
}
