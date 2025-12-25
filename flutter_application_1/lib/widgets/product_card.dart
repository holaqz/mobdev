import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/favorites.dart';
import 'product_image.dart';
import '../screens/product_details.dart';
import '../utils/helpers.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final favModel = Provider.of<FavoritesModel>(context);
    final kcalText = formatCalories(product.kcalPer100g);
    final kcalColor = getCalorieColor(product.kcalPer100g);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ProductImage(imageUrl: product.imageUrl, size: 56),
        title: Text(
          product.displayName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          kcalText,
          style: TextStyle(color: kcalColor),
        ),
        trailing: IconButton(
          icon: Icon(
            favModel.isFavorite(product.id)
                ? Icons.favorite
                : Icons.favorite_border,
            color: favModel.isFavorite(product.id) ? Colors.red : null,
          ),
          onPressed: () => favModel.toggle(product.id),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          );
        },
      ),
    );
  }
}