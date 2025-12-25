import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'favorites_page.dart';
import '../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _category = 'All';
  bool _loading = false;
  bool _hasSearched = false;
  String? _statusMessage;
  List<Product> _products = [];
  ProductRepository? _repository;
  bool _initialized = false;

  final List<String> _categories = [
    'All',
    'Cereals',
    'Seafood',
    'Meat',
    'Bakery',
    'Vegetables',
    'Fruits',
    'Dairy',
    'Snacks',
    'Drinks',
  ];

  String _getLocalizedCategory(String category) {
    final l10n = AppLocalizations.of(context);
    switch (category) {
      case 'All':
        return l10n?.categoryAll ?? 'All';
      case 'Cereals':
        return l10n?.categoryCereals ?? 'Cereals';
      case 'Seafood':
        return l10n?.categorySeafood ?? 'Seafood';
      case 'Meat':
        return l10n?.categoryMeat ?? 'Meat';
      case 'Bakery':
        return l10n?.categoryBakery ?? 'Bakery';
      case 'Vegetables':
        return l10n?.categoryVegetables ?? 'Vegetables';
      case 'Fruits':
        return l10n?.categoryFruits ?? 'Fruits';
      case 'Dairy':
        return l10n?.categoryDairy ?? 'Dairy';
      case 'Snacks':
        return l10n?.categorySnacks ?? 'Snacks';
      case 'Drinks':
        return l10n?.categoryDrinks ?? 'Drinks';
      default:
        return category;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository ??= Provider.of<ProductRepository>(context);
    if (!_initialized) {
      _initialized = true;
      _loadInitial();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
    });

    try {
      final repo = _repository;
      List<Product> list = [];

      if (repo != null) {
        list = await repo.fetchProducts();
      }

      setState(() {
        _products = list.isEmpty ? sampleProducts : list;
      });
    } catch (_) {
      setState(() {
        _products = sampleProducts;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _search() async {
    final searchQuery = _searchController.text.trim();
    final repo = _repository;

    setState(() {
      _loading = true;
      _hasSearched = true;
      _statusMessage = null;
    });

    try {
      List<Product> results = [];
      if (repo != null) {
        results = await repo.fetchProducts(query: searchQuery, category: _category);
      }

      if (results.isEmpty) {
        String message = searchQuery.isEmpty
            ? 'Нет продуктов для выбранной категории'
            : 'Ничего не найдено по запросу "$searchQuery"';

        setState(() {
          _products = [];
          _statusMessage = message;
        });
      } else {
        setState(() {
          _products = results;
        });
      }
    } catch (e) {
      debugPrint('❌ fetchProducts error: $e');

      var fallbackResults = <Product>[];
      fallbackResults.addAll(sampleProducts);

      if (_category != 'All') {
        fallbackResults = fallbackResults.where(
          (product) => product.categories.any(
            (category) => category.toLowerCase() == _category.toLowerCase(),
          ),
        ).toList();
      }

      if (searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        fallbackResults = fallbackResults.where(
          (product) =>
              product.displayName.toLowerCase().contains(lowerQuery) ||
              product.genericName.toLowerCase().contains(lowerQuery),
        ).toList();
      }

      setState(() {
        _products = fallbackResults;
        _statusMessage = 'Ошибка загрузки. Показаны офлайн-данные.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const FavoritesPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          l10n?.searchHint ??
                          'Поиск по названию или ключевому слову',
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _search,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final selected = cat == _category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_getLocalizedCategory(cat)),
                      selected: selected,
                      onSelected: (v) {
                        setState(() => _category = cat);
                        _search();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                  ? Center(
                      child: Text(
                        _statusMessage ??
                            (_hasSearched
                                ? 'Ничего не найдено'
                                : 'Список пуст'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final p = _products[index];
                        return ProductCard(product: p);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}