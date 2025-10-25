import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  static const routeName = '/product-form';

  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isInit = true;
  var _isSaving = false;
  
  var _editedProduct = Product(
    id: null,
    name: '',
    quantity: 0,
    price: 0.0,
    imagePath: null,
  );

  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final existingProduct = ModalRoute.of(context)!.settings.arguments as Product?;
      if (existingProduct != null) {
        _editedProduct = existingProduct;
        if (existingProduct.imagePath != null) {
          _imageFile = File(existingProduct.imagePath!);
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 600,
    );

    if (pickedFile == null) {
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(pickedFile.path);
    final savedImagePath = p.join(appDir.path, fileName);
    
    final savedImage = await File(pickedFile.path).copy(savedImagePath);

    setState(() {
      _imageFile = savedImage;
    });
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    
    setState(() { _isSaving = true; });

    _editedProduct = Product(
      id: _editedProduct.id,
      name: _editedProduct.name,
      quantity: _editedProduct.quantity,
      price: _editedProduct.price,
      imagePath: _imageFile?.path,
    );
    
    final provider = Provider.of<ProductProvider>(context, listen: false);

    try {
      if (_editedProduct.id != null) {
        await provider.updateProduct(_editedProduct);
      } else {
        await provider.addProduct(_editedProduct);
      }
    } catch (error) {
       await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error occurred!'),
          content: const Text('Something went wrong. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () => Navigator.of(ctx).pop(),
            )
          ],
        ),
      );
    } finally {
       setState(() { _isSaving = false; });
       if(mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editedProduct.id != null ? 'Edit Product' : 'Add Product'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveForm,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: (_imageFile != null && _imageFile!.existsSync())
                          ? FileImage(_imageFile!)
                          : null,
                      child: (_imageFile == null || !_imageFile!.existsSync())
                          ? Icon(Icons.inventory_2, size: 60, color: Colors.grey[600])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: () => _showImagePicker(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                initialValue: _editedProduct.name,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    name: value!,
                    quantity: _editedProduct.quantity,
                    price: _editedProduct.price,
                    imagePath: _editedProduct.imagePath,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _editedProduct.quantity.toString(),
                decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder()),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Please enter a quantity greater than zero.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    name: _editedProduct.name,
                    quantity: int.parse(value!),
                    price: _editedProduct.price,
                    imagePath: _editedProduct.imagePath,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _editedProduct.price.toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'Price', prefixText: '\₦', border: OutlineInputBorder()),
                textInputAction: TextInputAction.done,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price.';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Please enter a price greater than zero.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    name: _editedProduct.name,
                    quantity: _editedProduct.quantity,
                    price: double.parse(value!),
                    imagePath: _editedProduct.imagePath,
                  );
                },
                onFieldSubmitted: (_) => _saveForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}