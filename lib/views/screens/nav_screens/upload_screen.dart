import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_app/controllers/category_controller.dart';
import 'package:vendor_app/controllers/product_controller.dart';
import 'package:vendor_app/controllers/subcategory_controller.dart';
import 'package:vendor_app/models/category.dart';
import 'package:vendor_app/models/subcategory.dart';
import 'package:vendor_app/provider/vendor_provider.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final ProductController _productController = ProductController();
  final ImagePicker _picker = ImagePicker();
  List<File> images = [];
  late Future<List<Category>> _futureCategories;
  late String name;
  late String description;
  late double price;
  late int quantity;
  Future<List<Subcategory>>? _futureSubcategories;
  Subcategory? _selectedSubcategory;
  Category? _selectedCategory;
  chooseImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      print('No image selected');
    } else {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  getSubcategoryByCategory(value) {
    _futureSubcategories = SubcategoryController()
        .getSubCategoriesByCategoryName(value.name);

    _selectedSubcategory = null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureCategories = CategoryController().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            itemCount: images.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return index == 0
                  ? Center(
                      child: IconButton(
                        onPressed: chooseImage,
                        icon: Icon(Icons.add),
                      ),
                    )
                  : SizedBox(
                      width: 50,
                      height: 40,
                      child: Image.file(images[index - 1], fit: BoxFit.cover),
                    );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    onChanged: (value) {
                      name = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Product Name',
                      hintText: 'Product Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      price = double.parse(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product price';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Product Price',
                      hintText: 'Product Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      quantity = int.parse(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product quantity';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Product Quantity',
                      hintText: 'Product Quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: FutureBuilder(
                    future: _futureCategories,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        List<Category> categories = snapshot.data!;
                        return DropdownButton<Category>(
                          value: _selectedCategory,
                          hint: Text('Select Category'),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _selectedSubcategory = null;
                            });
                            getSubcategoryByCategory(_selectedCategory!);
                          },
                        );
                      } else {
                        return Center(child: Text('No categories found'));
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: FutureBuilder(
                    future: _futureSubcategories,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        List<Subcategory> subcategories = snapshot.data!;
                        return DropdownButton<Subcategory>(
                          value: _selectedSubcategory,
                          hint: Text('Select Subcategory'),
                          items: subcategories.map((subcategory) {
                            return DropdownMenuItem(
                              value: subcategory,
                              child: Text(subcategory.subCategoryName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubcategory = value;
                            });
                          },
                        );
                      } else {
                        return Center(child: Text('No categories found'));
                      }
                    },
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    onChanged: (value) {
                      description = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter product description';
                      }
                      return null;
                    },
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: 'Enter Product Description',
                      hintText: 'Product Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: InkWell(
              onTap: () async {
                final vendorData = ref.read(vendorProvider);
                if (vendorData == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Lỗi: Không tìm thấy thông tin người bán. Vui lòng đăng nhập lại.',
                      ),
                    ),
                  );
                  return;
                }
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isLoading = true;
                  });
                  await _productController
                      .uploadProduct(
                        name: name,
                        description: description,
                        price: price,
                        quantity: quantity,
                        category: _selectedCategory!.name,
                        subCategory: _selectedSubcategory!.subCategoryName,
                        pickedImages: images,
                        vendorId: vendorData.id,
                        fullName: vendorData.fullName,
                        context: context,
                      )
                      .whenComplete(() {
                        setState(() {
                          isLoading = false;
                        });
                      });
                  _selectedCategory = null;
                  _selectedSubcategory = null;
                  images.clear();
                } else {
                  print('Validation failed');
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.7,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
