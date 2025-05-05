import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/controller/category_controller.dart'; // Đảm bảo import đúng
import 'package:mac_store_app/provider/category_provider.dart'; // Đảm bảo import đúng
import 'package:mac_store_app/models/category.dart'; // Import Category model
import 'package:mac_store_app/views/screens/detail/screens/inner_category_screen.dart'; // Đảm bảo import đúng
import 'package:mac_store_app/views/screens/nav_screen/widgets/reusable_text_widget.dart'; // Đảm bảo import đúng

// ----- Provider (Giả sử đã có ở category_provider.dart) -----
// class CategoryProvider extends StateNotifier<List<Category>> {
//   CategoryProvider() : super([]);
//   void setCategories(List<Category> categories) {
//     state = categories;
//   }
// }
// final categoryProvider = StateNotifierProvider<CategoryProvider, List<Category>>((ref) {
//   return CategoryProvider();
// });
// --------------------------------------------------------------

class CategoryItemWidget extends ConsumerStatefulWidget {
  const CategoryItemWidget({super.key});

  @override
  ConsumerState<CategoryItemWidget> createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends ConsumerState<CategoryItemWidget> {
  bool _isLoading = true; // Thêm biến trạng thái loading

  @override
  void initState() {
    super.initState();
    // Gọi fetch trong addPostFrameCallback để an toàn hơn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Kiểm tra mounted trước khi đọc ref
      if (mounted) {
        // Kiểm tra xem provider đã có dữ liệu chưa, nếu có thì không cần fetch lại
        final categories = ref.read(categoryProvider);
        if (categories.isEmpty) {
          _fetchCategories();
        } else {
          // Nếu đã có dữ liệu, cập nhật trạng thái loading
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    });
  }

  Future<void> _fetchCategories() async {
    // Không cần setState loading = true vì đã là true ban đầu

    final CategoryController categoryController = CategoryController();
    try {
      final categories = await categoryController.loadCategories();
      // *** KIỂM TRA MOUNTED TRƯỚC KHI GỌI REF.READ ***
      if (mounted) {
        ref.read(categoryProvider.notifier).setCategories(categories);
      }
    } catch (e) {
      print('Lỗi khi tải danh mục: $e');
      // Xử lý lỗi, ví dụ hiển thị SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh mục: ${e.toString()}')),
        );
      }
    } finally {
      // *** LUÔN KIỂM TRA MOUNTED TRƯỚC KHI GỌI SETSTATE ***
      if (mounted) {
        setState(() {
          _isLoading = false; // Cập nhật loading khi hoàn tất
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    // Hiển thị loading indicator hoặc GridView dựa trên _isLoading và categories
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ReusableTextWidget(title: 'Categories', subtitle: 'View All'),
        _isLoading
            ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0), // Thêm padding cho dễ nhìn
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
            : categories.isEmpty
            ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Không có danh mục nào.'),
              ),
            )
            : GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          // Đảm bảo InnerCategoryScreen nhận đúng tham số
                          return InnerCategoryScreen(category: category);
                        },
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Căn giữa nội dung trong ô
                    children: [
                      Image.network(
                        category.image,
                        height: 47, // Điều chỉnh kích thước nếu cần
                        width: 47,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Icon(Icons.error, size: 47), // Xử lý lỗi ảnh
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 47,
                            width: 47,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4), // Thêm khoảng cách
                      Text(
                        category.name,
                        textAlign: TextAlign.center, // Căn giữa text
                        maxLines: 2, // Cho phép xuống dòng nếu tên dài
                        overflow:
                            TextOverflow.ellipsis, // Thêm dấu ... nếu quá dài
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 12, // Giảm cỡ chữ nếu cần
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ],
    );
  }
}
