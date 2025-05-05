import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_store_app/controller/product_controller.dart';
import 'package:mac_store_app/provider/product_provider.dart';
import 'package:mac_store_app/views/screens/nav_screen/widgets/product_item_widget.dart';

class PopularProductWidget extends ConsumerStatefulWidget {
  const PopularProductWidget({super.key});

  @override
  ConsumerState<PopularProductWidget> createState() =>
      _PopularProductWidgetState();
}

class _PopularProductWidgetState extends ConsumerState<PopularProductWidget> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    // Sử dụng ref.read bên ngoài initState hoặc dùng Consumer thay vì ConsumerStatefulWidget nếu không cần state cục bộ
    // Hoặc gọi fetch trong postFrameCallback để đảm bảo context sẵn sàng nếu cần
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final products = ref.read(productProvider);
      if (products.isEmpty) {
        _fetchProduct();
      } else {
        // Kiểm tra mounted trước khi gọi setState
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _fetchProduct() async {
    // Không cần setState isLoading = true ở đây vì nó đã là true mặc định

    final ProductController productController = ProductController();
    try {
      // Cung cấp một giá trị cho tham số 'category' (ví dụ: 'popular').
      // Thay đổi 'popular' thành giá trị category thực tế bạn muốn sử dụng.
      final products = await productController.loadPopularProducts('popular');

      // *** KIỂM TRA MOUNTED ***
      if (mounted) {
        ref.read(productProvider.notifier).setProducts(products);
      }
    } catch (e) {
      print('Lỗi khi tải sản phẩm phổ biến: $e');
      // Xử lý lỗi một cách thích hợp hơn (ví dụ: hiển thị thông báo lỗi).
      // Nhớ kiểm tra mounted nếu bạn dùng context ở đây
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải sản phẩm')));
      // }
    } finally {
      // *** KIỂM TRA MOUNTED ***
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    return SizedBox(
      height: 250,
      child:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
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
