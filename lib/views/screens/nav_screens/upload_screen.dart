import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_app/controllers/category_controller.dart';
import 'package:vendor_app/controllers/product_controller.dart';
import 'package:vendor_app/controllers/subcategory_controller.dart';
import 'package:vendor_app/models/category.dart';
import 'package:vendor_app/models/subcategory.dart';
import 'package:vendor_app/provider/vendor_provider.dart';

// Constants
class _UploadScreenConstants {
  static const double horizontalPadding = 8.0;
  static const double verticalSpacing = 10.0;
  static const double inputFieldWidth = 200.0;
  static const double descriptionFieldWidth = 400.0;
  static const double borderRadius = 8.0;
  static const double buttonHeight = 50.0;
  static const int maxDescriptionLength = 500;
  static const int maxDescriptionLines = 3;
  static const int gridCrossAxisCount = 3;
  static const double gridSpacing = 4.0;
}

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  // Form and Controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  final ImagePicker _picker = ImagePicker();

  // State Variables
  bool _isLoading = false;
  final List<File> _images = [];
  late Future<List<Category>> _futureCategories;
  Future<List<Subcategory>>? _futureSubcategories;

  // Form Data
  String _name = '';
  String _description = '';
  double? _price;
  int? _quantity;
  Category? _selectedCategory;
  Subcategory? _selectedSubcategory;
  @override
  void initState() {
    super.initState();
    _futureCategories = CategoryController().loadCategories();
  }

  // Image Picker Method
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi chọn ảnh: $e');
    }
  }

  // Remove Image Method
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // Load Subcategories by Category
  void _loadSubcategoriesByCategory(Category category) {
    setState(() {
      _futureSubcategories = SubcategoryController()
          .getSubCategoriesByCategoryName(category.name);
      _selectedSubcategory = null;
    });
  }

  // Show Error SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show Success SnackBar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Reset Form
  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _name = '';
      _description = '';
      _price = null;
      _quantity = null;
      _selectedCategory = null;
      _selectedSubcategory = null;
      _images.clear();
    });
  }

  // Validate and Upload Product
  Future<void> _uploadProduct() async {
    final vendorData = ref.read(vendorProvider);

    if (vendorData == null) {
      _showErrorSnackBar(
          'Lỗi: Không tìm thấy thông tin người bán. Vui lòng đăng nhập lại.');
      return;
    }

    if (_images.isEmpty) {
      _showErrorSnackBar('Vui lòng chọn ít nhất một ảnh sản phẩm.');
      return;
    }

    if (_selectedCategory == null) {
      _showErrorSnackBar('Vui lòng chọn danh mục sản phẩm.');
      return;
    }

    if (_selectedSubcategory == null) {
      _showErrorSnackBar('Vui lòng chọn danh mục con.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _productController.uploadProduct(
        name: _name,
        description: _description,
        price: _price!,
        quantity: _quantity!,
        category: _selectedCategory!.name,
        subCategory: _selectedSubcategory!.subCategoryName,
        pickedImages: _images,
        vendorId: vendorData.id,
        fullName: vendorData.fullName,
        context: context,
      );

      _showSuccessSnackBar('Sản phẩm đã được upload thành công!');
      _resetForm();
    } catch (e) {
      _showErrorSnackBar('Lỗi khi upload sản phẩm: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGrid(),
            _buildFormFields(),
            _buildUploadButton(),
          ],
        ),
      ),
    );
  }

  // Build Image Grid with Add and Remove functionality
  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.all(_UploadScreenConstants.horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _images.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _UploadScreenConstants.gridCrossAxisCount,
          crossAxisSpacing: _UploadScreenConstants.gridSpacing,
          mainAxisSpacing: _UploadScreenConstants.gridSpacing,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddImageButton();
          }
          return _buildImageCard(_images[index - 1], index - 1);
        },
      ),
    );
  }

  // Add Image Button
  Widget _buildAddImageButton() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_UploadScreenConstants.borderRadius),
      ),
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(_UploadScreenConstants.borderRadius),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Thêm ảnh',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Image Card with Remove button
  Widget _buildImageCard(File image, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_UploadScreenConstants.borderRadius),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_UploadScreenConstants.borderRadius),
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Form Fields
  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.all(_UploadScreenConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductNameField(),
          const SizedBox(height: _UploadScreenConstants.verticalSpacing),
          _buildPriceField(),
          const SizedBox(height: _UploadScreenConstants.verticalSpacing),
          _buildQuantityField(),
          const SizedBox(height: _UploadScreenConstants.verticalSpacing),
          _buildCategoryDropdown(),
          const SizedBox(height: _UploadScreenConstants.verticalSpacing),
          _buildSubcategoryDropdown(),
          const SizedBox(height: _UploadScreenConstants.verticalSpacing),
          _buildDescriptionField(),
        ],
      ),
    );
  }

  // Product Name Field
  Widget _buildProductNameField() {
    return SizedBox(
      width: _UploadScreenConstants.inputFieldWidth,
      child: TextFormField(
        initialValue: _name,
        onChanged: (value) => _name = value,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập tên sản phẩm';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Tên sản phẩm',
          hintText: 'Nhập tên sản phẩm',
          prefixIcon: const Icon(Icons.inventory_2_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_UploadScreenConstants.borderRadius),
          ),
        ),
      ),
    );
  }

  // Price Field
  Widget _buildPriceField() {
    return SizedBox(
      width: _UploadScreenConstants.inputFieldWidth,
      child: TextFormField(
        initialValue: _price?.toString() ?? '',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        onChanged: (value) {
          _price = double.tryParse(value);
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập giá sản phẩm';
          }
          final price = double.tryParse(value);
          if (price == null || price <= 0) {
            return 'Giá không hợp lệ';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Giá sản phẩm',
          hintText: 'Nhập giá',
          prefixIcon: const Icon(Icons.attach_money),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_UploadScreenConstants.borderRadius),
          ),
        ),
      ),
    );
  }

  // Quantity Field
  Widget _buildQuantityField() {
    return SizedBox(
      width: _UploadScreenConstants.inputFieldWidth,
      child: TextFormField(
        initialValue: _quantity?.toString() ?? '',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          _quantity = int.tryParse(value);
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập số lượng';
          }
          final quantity = int.tryParse(value);
          if (quantity == null || quantity <= 0) {
            return 'Số lượng không hợp lệ';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Số lượng',
          hintText: 'Nhập số lượng',
          prefixIcon: const Icon(Icons.production_quantity_limits),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_UploadScreenConstants.borderRadius),
          ),
        ),
      ),
    );
  }

  // Category Dropdown
  Widget _buildCategoryDropdown() {
    return SizedBox(
      width: _UploadScreenConstants.inputFieldWidth,
      child: FutureBuilder<List<Category>>(
        future: _futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Lỗi: ${snapshot.error}',
                style: const TextStyle(color: Colors.red));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('Không có danh mục nào');
          }

          final categories = snapshot.data!;
          return DropdownButtonFormField<Category>(
            initialValue: _selectedCategory,
            hint: const Text('Chọn danh mục'),
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(_UploadScreenConstants.borderRadius),
              ),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
                _loadSubcategoriesByCategory(value);
              }
            },
          );
        },
      ),
    );
  }

  // Subcategory Dropdown
  Widget _buildSubcategoryDropdown() {
    return SizedBox(
      width: _UploadScreenConstants.inputFieldWidth,
      child: FutureBuilder<List<Subcategory>>(
        future: _futureSubcategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Lỗi: ${snapshot.error}',
                style: const TextStyle(color: Colors.red));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('Không có danh mục con nào');
          }

          final subcategories = snapshot.data!;
          return DropdownButtonFormField<Subcategory>(
            initialValue: _selectedSubcategory,
            hint: const Text('Chọn danh mục con'),
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.subdirectory_arrow_right),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(_UploadScreenConstants.borderRadius),
              ),
            ),
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
        },
      ),
    );
  }

  // Description Field
  Widget _buildDescriptionField() {
    return SizedBox(
      width: _UploadScreenConstants.descriptionFieldWidth,
      child: TextFormField(
        initialValue: _description,
        onChanged: (value) => _description = value,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập mô tả sản phẩm';
          }
          return null;
        },
        maxLines: _UploadScreenConstants.maxDescriptionLines,
        maxLength: _UploadScreenConstants.maxDescriptionLength,
        decoration: InputDecoration(
          labelText: 'Mô tả sản phẩm',
          hintText: 'Nhập mô tả chi tiết',
          prefixIcon: const Icon(Icons.description),
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_UploadScreenConstants.borderRadius),
          ),
        ),
      ),
    );
  }

  // Upload Button
  Widget _buildUploadButton() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        width: double.infinity,
        height: _UploadScreenConstants.buttonHeight,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _uploadProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(_UploadScreenConstants.borderRadius),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'UPLOAD SẢN PHẨM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.7,
                  ),
                ),
        ),
      ),
    );
  }
}
