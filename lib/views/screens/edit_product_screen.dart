import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_app/controllers/category_controller.dart';
import 'package:vendor_app/controllers/product_controller.dart';
import 'package:vendor_app/controllers/subcategory_controller.dart';
import 'package:vendor_app/models/category.dart';
import 'package:vendor_app/models/product.dart';
import 'package:vendor_app/models/subcategory.dart';
import 'package:vendor_app/provider/vendor_provider.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProductController _productController = ProductController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  final List<File> _newImages = [];
  late Future<List<Category>> _futureCategories;
  Future<List<Subcategory>>? _futureSubcategories;

  late String _name;
  late String _description;
  late double _price;
  late int _quantity;
  Category? _selectedCategory;
  Subcategory? _selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _description = widget.product.description;
    _price = widget.product.price;
    _quantity = widget.product.quantity;
    _futureCategories = CategoryController().loadCategories();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final categories = await _futureCategories;
    final category = categories.firstWhere(
      (cat) => cat.name == widget.product.category,
      orElse: () => categories.first,
    );

    setState(() {
      _selectedCategory = category;
    });

    _loadSubcategoriesByCategory(category);
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _newImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi chọn ảnh: $e');
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _loadSubcategoriesByCategory(Category category) async {
    setState(() {
      _futureSubcategories = SubcategoryController()
          .getSubCategoriesByCategoryName(category.name);
      _selectedSubcategory = null;
    });

    final subcategories = await _futureSubcategories!;
    final subcategory = subcategories.firstWhere(
      (sub) => sub.subCategoryName == widget.product.subCategory,
      orElse: () => subcategories.first,
    );

    setState(() {
      _selectedSubcategory = subcategory;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updateProduct() async {
    final vendorData = ref.read(vendorProvider);

    if (vendorData == null) {
      _showErrorSnackBar(
          'Lỗi: Không tìm thấy thông tin người bán. Vui lòng đăng nhập lại.');
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
      await _productController.updatedProduct(
        productId: widget.product.id,
        name: _name,
        description: _description,
        price: _price,
        quantity: _quantity,
        category: _selectedCategory!.name,
        subCategory: _selectedSubcategory!.subCategoryName,
        pickedImages: _newImages,
        existingImages: widget.product.images,
        vendorId: vendorData.id,
        fullName: vendorData.fullName,
        context: context,
      );

      _showSuccessSnackBar('Sản phẩm đã được cập nhật thành công!');

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi cập nhật sản phẩm: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa sản phẩm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExistingImages(),
              _buildNewImagesGrid(),
              _buildFormFields(),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingImages() {
    if (widget.product.images.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ảnh hiện tại:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.product.images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.product.images[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewImagesGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thêm ảnh mới (không bắt buộc):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _newImages.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddImageButton();
              }
              return _buildImageCard(_newImages[index - 1], index - 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(8),
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

  Widget _buildImageCard(File image, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeNewImage(index),
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

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductNameField(),
          const SizedBox(height: 10),
          _buildPriceField(),
          const SizedBox(height: 10),
          _buildQuantityField(),
          const SizedBox(height: 10),
          _buildCategoryDropdown(),
          const SizedBox(height: 10),
          _buildSubcategoryDropdown(),
          const SizedBox(height: 10),
          _buildDescriptionField(),
        ],
      ),
    );
  }

  Widget _buildProductNameField() {
    return SizedBox(
      width: 200,
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
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return SizedBox(
      width: 200,
      child: TextFormField(
        initialValue: _price.toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        onChanged: (value) {
          _price = double.tryParse(value) ?? _price;
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
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityField() {
    return SizedBox(
      width: 200,
      child: TextFormField(
        initialValue: _quantity.toString(),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          _quantity = int.tryParse(value) ?? _quantity;
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
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return SizedBox(
      width: 200,
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
                borderRadius: BorderRadius.circular(8),
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

  Widget _buildSubcategoryDropdown() {
    return SizedBox(
      width: 200,
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
                borderRadius: BorderRadius.circular(8),
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

  Widget _buildDescriptionField() {
    return SizedBox(
      width: 400,
      child: TextFormField(
        initialValue: _description,
        onChanged: (value) => _description = value,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập mô tả sản phẩm';
          }
          return null;
        },
        maxLines: 3,
        maxLength: 500,
        decoration: InputDecoration(
          labelText: 'Mô tả sản phẩm',
          hintText: 'Nhập mô tả chi tiết',
          prefixIcon: const Icon(Icons.description),
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _updateProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'CẬP NHẬT SẢN PHẨM',
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
