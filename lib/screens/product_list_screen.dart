import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storekeeper Inventory'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Text(
                'No products yet. Tap "+" to add one!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              final imageFile = product.imagePath != null
                  ? File(product.imagePath!)
                  : null;

              return Dismissible(
                key: ValueKey(product.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  provider.deleteProduct(product.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.indigo[100],
                      backgroundImage: (imageFile != null && imageFile.existsSync())
                          ? FileImage(imageFile)
                          : null,
                      child: (imageFile == null || !imageFile.existsSync())
                          ? const Icon(Icons.inventory_2, color: Colors.indigo)
                          : null,
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Quantity: ${product.quantity} • Price: \₦${product.price.toStringAsFixed(2)}',
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.grey),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        ProductFormScreen.routeName,
                        arguments: product,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(ProductFormScreen.routeName);
        },
      ),
    );
  }
}