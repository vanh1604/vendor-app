import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_app/controllers/category_controller.dart';
import 'package:vendor_app/controllers/subcategory_controller.dart';
import 'package:vendor_app/models/category.dart';
import 'package:vendor_app/models/subcategory.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> images = [];
  late Future<List<Category>> _futureCategories;
  late Future<List<Subcategory>> _futureSubcategories;
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureCategories = CategoryController().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              FutureBuilder(
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
                        });
                      },
                    );
                  } else {
                    return Center(child: Text('No categories found'));
                  }
                },
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 400,
                child: TextFormField(
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
      ],
    );
  }
}
