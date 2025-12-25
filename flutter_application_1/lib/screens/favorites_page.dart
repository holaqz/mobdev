import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorites.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favModel = Provider.of<FavoritesModel>(context);
    final repository = Provider.of<ProductRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).primaryColorDark,
      ),
      body: _buildFavoritesContent(repository, favModel),
    );
  }

  Widget _buildFavoritesContent(ProductRepository repository, FavoritesModel favModel) {
    return FutureBuilder<List<Product>>(
      future: repository.fetchProductsByIds(favModel.favorites.toList()),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return const Center(
                child: Text(
                  'Нет избранных продуктов',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                // Refresh the list by calling the future again
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) => ProductCard(product: products[index]),
              ),
            );
          case ConnectionState.none:
            return const Center(child: Text('Ошибка загрузки'));
        }
      },
    );
  }
}