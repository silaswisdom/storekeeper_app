import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../helpers/database_helper.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = true;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    _products = await DatabaseHelper.instance.readAllProducts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final newProduct = await DatabaseHelper.instance.create(product);
    _products.add(newProduct);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await DatabaseHelper.instance.update(product);
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final product = _products.firstWhere((p) => p.id == id);
      if (product.imagePath != null) {
        final imageFile = File(product.imagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete(); 
        }
      }
    } catch (e) {
      print("Error finding product or deleting image: $e");
    }

    await DatabaseHelper.instance.delete(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}