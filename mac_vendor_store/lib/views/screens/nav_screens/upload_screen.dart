import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mac_vendor_store/controllers/category_controller.dart';
import 'package:mac_vendor_store/controllers/product_controller.dart';
import 'package:mac_vendor_store/controllers/subcategory_controller.dart';
import 'package:mac_vendor_store/models/category.dart';
import 'package:mac_vendor_store/models/subcategory.dart';
import 'package:mac_vendor_store/provider/vendor_provider.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  late Future<List<Category>> futureCategories;
  Future<List<Subcategory>>? futureSubcategories;
  Category? selectedCategory;
  Subcategory? selectedSubcategory;
  late String productName;
  late int productPrice;
  late int quantity;
  late String description;

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  final ImagePicker picker = ImagePicker();
  List<File> images = [];

  chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      print('No image picked');
    } else {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  getSubcategoryByCategory(value) {
    futureSubcategories = SubcategoryController()
        .getSubCategoriesByCategoryName(value.name);
    selectedSubcategory = null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Thêm lề xung quanh form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: images.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return index == 0
                      ? Center(
                        child: IconButton(
                          onPressed: () {
                            chooseImage();
                          },
                          icon: Icon(Icons.add),
                        ),
                      )
                      : SizedBox(
                        child: Image.file(
                          images[index - 1],
                          fit: BoxFit.cover, // Đảm bảo hình ảnh vừa với ô lưới
                        ),
                      );
                },
              ),
              const SizedBox(
                height: 16,
              ), // Thêm khoảng cách giữa GridView và các TextFormField
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ), // Giới hạn chiều rộng tối đa
                child: TextFormField(
                  onChanged: (value) {
                    productName = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Product Name";
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Product Name',
                    hintText: 'Enter Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ), // Giới hạn chiều rộng tối đa
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    productPrice =
                        int.tryParse(value) ?? 0; // Xử lý lỗi nhập sai
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Product Price";
                    } else if (int.tryParse(value) == null) {
                      return "Enter a valid number";
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Product Price',
                    hintText: 'Enter Product Price',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ), // Giới hạn chiều rộng tối đa
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    quantity = int.tryParse(value) ?? 0; // Xử lý lỗi nhập sai
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Product Quantity";
                    } else if (int.tryParse(value) == null) {
                      return "Enter a valid number";
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Product Quantity',
                    hintText: 'Enter Product Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ), // Giới hạn chiều rộng tối đa
                child: FutureBuilder<List<Category>>(
                  future: futureCategories,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No Category'));
                    } else {
                      return DropdownButton<Category>(
                        value: selectedCategory,
                        hint: const Text('Select Category'),
                        items:
                            snapshot.data!.map((Category category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                          getSubcategoryByCategory(selectedCategory);
                        },
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ), // Giới hạn chiều rộng tối đa
                child: FutureBuilder<List<Subcategory>>(
                  future: futureSubcategories,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No Subcategory'));
                    } else {
                      return DropdownButton<Subcategory>(
                        value: selectedSubcategory,
                        hint: const Text('Select Subcategory'),
                        items:
                            snapshot.data!.map((Subcategory subcategory) {
                              return DropdownMenuItem(
                                value: subcategory,
                                child: Text(subcategory.subCategoryName ?? ''),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSubcategory = value;
                          });
                        },
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                onChanged: (value) {
                  description = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Product Description";
                  } else {
                    return null;
                  }
                },
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Enter Product Description',
                  hintText: 'Enter Product Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ), // Thêm khoảng cách giữa TextFormField và nút Upload
              InkWell(
                onTap: () async {
                  final fullName = ref.read(vendorProvider)!.fullName;
                  final vendorId = ref.read(vendorProvider)!.id;
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    await _productController
                        .uploadProduct(
                          productName: productName,
                          productPrice: productPrice,
                          quantity: quantity,
                          description: description,
                          category: selectedCategory!.name,
                          vendorId: vendorId,
                          fullName: fullName,
                          subCategory:
                              selectedSubcategory!.subCategoryName ?? '',
                          pickedImages: images,
                          context: context,
                        )
                        .whenComplete(() {
                          setState(() {
                            isLoading = false;
                          });
                          selectedCategory = null;
                          selectedSubcategory = null;
                          images.clear();
                        });
                  } else {
                    print("Please enter all the fields");
                  }
                },
                child: Container(
                  height: 50,
                  width: double.infinity, // Sử dụng chiều rộng tối đa
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Upload Product',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
