import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/favorites.dart';
import '../widgets/product_image.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  const ProductDetailsPage({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final favModel = Provider.of<FavoritesModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(product.displayName),
        actions: [
          IconButton(
            icon: Icon(
              favModel.isFavorite(product.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            onPressed: () => favModel.toggle(product.id),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            ProductImage(
              imageUrl: product.imageUrl,
              size: 200,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Калорийность',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.kcalPer100g != null
                          ? '${product.kcalPer100g!.toStringAsFixed(0)} kcal на 100 г'
                          : 'нет данных',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Питательная ценность (на 100 г)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Белки: ${product.proteinsPer100g?.toStringAsFixed(1) ?? '—'} g',
                    ),
                    Text(
                      'Жиры: ${product.fatPer100g?.toStringAsFixed(1) ?? '—'} g',
                    ),
                    Text(
                      'Углеводы: ${product.carbsPer100g?.toStringAsFixed(1) ?? '—'} g',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ингредиенты',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.ingredients.isNotEmpty
                          ? product.ingredients.join(', ')
                          : 'нет данных',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Информация о вредных/противопоказаниях',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.allergens.isNotEmpty
                          ? product.allergens.join(', ')
                          : 'нет данных',
                    ),
                    if (product.warns.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Дополнительно:'),
                      Text(product.warns.join(', ')),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}