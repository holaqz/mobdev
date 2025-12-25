import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

class Product {
  final String id; // product identifier / barcode
  final String displayName;
  final String genericName;
  final String? barcode;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> categories;
  final List<String> allergens;
  final List<String> warns;
  final double? kcalPer100g;
  final double? proteinsPer100g;
  final double? fatPer100g;
  final double? carbsPer100g;
  final int popularity;

  const Product({
    required this.id,
    required this.displayName,
    required this.genericName,
    this.barcode,
    this.imageUrl,
    this.ingredients = const [],
    this.categories = const [],
    this.allergens = const [],
    this.warns = const [],
    this.kcalPer100g,
    this.proteinsPer100g,
    this.fatPer100g,
    this.carbsPer100g,
    this.popularity = 0,
  });

  factory Product.fromSupabase(Map<String, dynamic> json) {
    List<String> asStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String && value.isNotEmpty) {
        return value.split(RegExp(r',\s*'));
      }
      return [];
    }

    final id = (json['id'] ?? json['barcode'] ?? '') as String;
    return Product(
      id: id,
      barcode: (json['barcode'] as String?) ?? id,
      displayName: (json['name'] ?? json['name_ru'] ?? '') as String,
      genericName: (json['generic_name'] ?? '') as String,
      imageUrl: json['image_url'] as String?,
      ingredients: asStringList(json['ingredients']),
      categories: asStringList(json['categories'] ?? json['category']),
      allergens: asStringList(json['allergens']),
      warns: asStringList(json['warnings']),
      kcalPer100g: (json['kcal'] as num?)?.toDouble(),
      proteinsPer100g: (json['proteins'] as num?)?.toDouble(),
      fatPer100g: (json['fat'] as num?)?.toDouble(),
      carbsPer100g: (json['carbs'] as num?)?.toDouble(),
      popularity: (json['popularity'] as int?) ?? 0,
    );
  }
}

class ProductRepository {
  ProductRepository(this._client);

  final SupabaseClient? _client;

  Future<List<Product>> fetchProducts({
    String query = '',
    String category = 'All',
  }) async {
    final client = _client;
    if (client == null) {
      return _filterSampleProducts(query: query, category: category);
    }
    try {
      var request = client.from('products').select();

      if (query.isNotEmpty) {
        request = request.ilike('name', '%${query.toLowerCase()}%');
      }
      if (category != 'All') {
        request = request.ilike('category', '%${category.toLowerCase()}%');
      }
      final response = await request
          .order('popularity', ascending: false)
          .limit(60) as List<dynamic>;

      final products = response
          .map((row) => Product.fromSupabase(row as Map<String, dynamic>))
          .where((product) => product.displayName.isNotEmpty)
          .toList();

      return products.isNotEmpty ? products : _filterSampleProducts(query: query, category: category);
    } catch (e) {
      debugPrint('❌ fetchProducts error: $e');
      return _filterSampleProducts(query: query, category: category);
    }
  }

  Future<List<Product>> fetchProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final client = _client;
    if (client == null) {
      return sampleProducts.where((p) => ids.contains(p.id)).toList();
    }
    try {
      final formattedIds = ids.map((id) => '"$id"').join(',');
      final response =
          await client
                  .from('products')
                  .select()
                  .filter('id', 'in', '($formattedIds)')
                  .order('popularity', ascending: false)
              as List<dynamic>;
      return response
          .map((row) => Product.fromSupabase(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ fetchProductsByIds error: $e');
      return sampleProducts.where((p) => ids.contains(p.id)).toList();
    }
  }

  List<Product> _filterSampleProducts({
    required String query,
    required String category,
  }) {
    Iterable<Product> result = sampleProducts;
    if (category != 'All') {
      result = result.where(
        (p) =>
            p.categories.any((c) => c.toLowerCase() == category.toLowerCase()),
      );
    }
    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      result = result.where(
        (p) =>
            p.displayName.toLowerCase().contains(lower) ||
            p.genericName.toLowerCase().contains(lower),
      );
    }
    return result.toList();
  }
}

final List<Product> sampleProducts = [
  Product(
    id: '0001',
    displayName: 'Яблоко',
    genericName: 'Фрукты',
    kcalPer100g: 52,
    proteinsPer100g: 0.3,
    fatPer100g: 0.2,
    carbsPer100g: 14,
    ingredients: ['Яблоко'],
    categories: ['Fruits'],
  ),
  Product(
    id: '0002',
    displayName: 'Банан',
    genericName: 'Фрукты',
    kcalPer100g: 89,
    proteinsPer100g: 1.1,
    fatPer100g: 0.3,
    carbsPer100g: 23,
    ingredients: ['Банан'],
    categories: ['Fruits'],
  ),
  Product(
    id: '0003',
    displayName: 'Молоко 2.5%',
    genericName: 'Молочка',
    kcalPer100g: 50,
    proteinsPer100g: 3.3,
    fatPer100g: 2.5,
    carbsPer100g: 4.8,
    ingredients: ['Молоко'],
    categories: ['Dairy'],
  ),
  Product(
    id: '0004',
    displayName: 'Хлеб ржаной',
    genericName: 'Хлеб',
    kcalPer100g: 250,
    proteinsPer100g: 8,
    fatPer100g: 4,
    carbsPer100g: 45,
    ingredients: ['Мука', 'Вода', 'Дрожжи'],
    categories: ['Bakery'],
  ),
  Product(
    id: '0005',
    displayName: 'Курица (грудка, жареная)',
    genericName: 'Мясо',
    kcalPer100g: 165,
    proteinsPer100g: 31,
    fatPer100g: 3.6,
    carbsPer100g: 0,
    ingredients: ['Курица'],
    categories: ['Meat'],
  ),
  Product(
    id: '0006',
    displayName: 'Шоколад молочный',
    genericName: 'Снэки',
    kcalPer100g: 535,
    proteinsPer100g: 7,
    fatPer100g: 30,
    carbsPer100g: 59,
    ingredients: ['Сахар', 'Какао-масло', 'Молоко'],
    categories: ['Snacks'],
  ),
  Product(
    id: '0007',
    displayName: 'Овсянка',
    genericName: 'Крупы',
    kcalPer100g: 389,
    proteinsPer100g: 17,
    fatPer100g: 7,
    carbsPer100g: 66,
    ingredients: ['Овсяные хлопья'],
    categories: ['Cereals'],
  ),
  Product(
    id: '0008',
    displayName: 'Сыр твёрдый',
    genericName: 'Молочка',
    kcalPer100g: 402,
    proteinsPer100g: 25,
    fatPer100g: 33,
    carbsPer100g: 1.3,
    ingredients: ['Молоко', 'Соль', 'Ферменты'],
    categories: ['Dairy'],
  ),
  Product(
    id: '0009',
    displayName: 'Сёмга (лосось)',
    genericName: 'Рыба',
    kcalPer100g: 208,
    proteinsPer100g: 20,
    fatPer100g: 13,
    carbsPer100g: 0,
    ingredients: ['Сёмга'],
    categories: ['Seafood'],
  ),
  Product(
    id: '0010',
    displayName: 'Газированный напиток (cola)',
    genericName: 'Напитки',
    kcalPer100g: 42,
    proteinsPer100g: 0,
    fatPer100g: 0,
    carbsPer100g: 10.6,
    ingredients: ['Вода', 'Сахар', 'Ароматизаторы'],
    categories: ['Drinks'],
  ),
];