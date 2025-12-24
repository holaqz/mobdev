import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://oyecfepknlsdaxlyloya.supabase.co');
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im95ZWNmZXBrbmxzZGF4bHlsb3lhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1NjA3OTMsImV4cCI6MjA4MjEzNjc5M30.qR1iIlSmpQFuUBu_hHEjvs4yOZI8U2jKbBR89vS_t58',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasEnv = _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;
  SupabaseClient? client;
  if (hasEnv) {
    debugPrint('✅ Supabase env loaded');
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    client = Supabase.instance.client;
  } else {
    debugPrint(
      '❌ Supabase env not provided (SUPABASE_URL / SUPABASE_ANON_KEY)',
    );
  }
  final prefs = await SharedPreferences.getInstance();
  final repository = ProductRepository(client);
  runApp(
    MultiProvider(
      providers: [
        Provider<ProductRepository>.value(value: repository),
        ChangeNotifierProvider(create: (_) => FavoritesModel(prefs)),
      ],
      child: const CalorieGuideApp(),
    ),
  );
}

class FavoritesModel extends ChangeNotifier {
  final SharedPreferences prefs;
  static const _key = 'favorite_barcodes';
  Set<String> _favorites = {};

  FavoritesModel(this.prefs) {
    _favorites = prefs.getStringList(_key)?.toSet() ?? {};
  }

  Set<String> get favorites => _favorites;

  bool isFavorite(String id) => _favorites.contains(id);

  void toggle(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    prefs.setStringList(_key, _favorites.toList());
    notifyListeners();
  }
}

class CalorieGuideApp extends StatelessWidget {
  const CalorieGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    final whiteColor = const Color(0xFFFFFFFF);
    final greenAccent = const Color(0xFF4CAF50);
    return MaterialApp(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Справочник продуктов',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: whiteColor,
        scaffoldBackgroundColor: whiteColor,
        colorScheme: ColorScheme.light(
          primary: whiteColor,
          secondary: greenAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF000000),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4CAF50),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
      ),
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}

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
    'Drinks',
    'Snacks',
    'Dairy',
    'Fruits',
    'Vegetables',
    'Bakery',
    'Meat',
    'Seafood',
    'Cereals',
  ];

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
    setState(() => _loading = true);
    try {
      final repo = _repository;
      List<Product> list = [];
      if (repo != null) {
        list = await repo.fetchProducts();
      }
      if (list.isEmpty) list = sampleProducts;
      setState(() => _products = list);
    } catch (_) {
      setState(() => _products = sampleProducts);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _search() async {
    final q = _searchController.text.trim();
    final repo = _repository;
    setState(() {
      _loading = true;
      _hasSearched = true;
      _statusMessage = null;
    });
    try {
      List<Product> list = [];
      if (repo != null) {
        list = await repo.fetchProducts(query: q, category: _category);
      }
      if (list.isEmpty) {
        setState(() {
          _products = [];
          _statusMessage = q.isEmpty
              ? 'Нет продуктов для выбранной категории'
              : 'Ничего не найдено по запросу "$q"';
        });
      } else {
        setState(() => _products = list);
      }
    } catch (e) {
      debugPrint('❌ fetchProducts error: $e');
      Iterable<Product> result = sampleProducts;
      if (_category != 'All') {
        result = result.where(
          (p) => p.categories.any(
            (c) => c.toLowerCase() == _category.toLowerCase(),
          ),
        );
      }
      if (q.isNotEmpty) {
        final lower = q.toLowerCase();
        result = result.where(
          (p) =>
              p.displayName.toLowerCase().contains(lower) ||
              p.genericName.toLowerCase().contains(lower),
        );
      }
      setState(() {
        _products = result.toList();
        _statusMessage = 'Ошибка загрузки. Показаны офлайн-данные.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справочник: калории и состав'),
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
                      label: Text(cat),
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

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final favModel = Provider.of<FavoritesModel>(context);
    final kcal = product.kcalPer100g != null
        ? '${product.kcalPer100g!.toStringAsFixed(0)} kcal/100g'
        : 'kcal: —';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ProductImage(imageUrl: product.imageUrl, size: 56),
        title: Text(product.displayName),
        subtitle: Text(kcal),
        trailing: IconButton(
          icon: Icon(
            favModel.isFavorite(product.id)
                ? Icons.favorite
                : Icons.favorite_border,
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

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.size = 56,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(6);
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: radius),
      child: const Icon(Icons.food_bank),
    );
    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder;
    }
    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favModel = Provider.of<FavoritesModel>(context);
    final repository = Provider.of<ProductRepository>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: FutureBuilder<List<Product>>(
        future: repository.fetchProductsByIds(favModel.favorites.toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Нет избранных продуктов'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) => ProductCard(product: list[index]),
          );
        },
      ),
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
      final response =
          await request.order('popularity', ascending: false).limit(60)
              as List<dynamic>;
      final products = response
          .map((row) => Product.fromSupabase(row as Map<String, dynamic>))
          .where((p) => p.displayName.isNotEmpty)
          .toList();
      if (products.isNotEmpty) return products;
    } catch (e) {
      debugPrint('❌ fetchProducts error: $e');
    }
    return _filterSampleProducts(query: query, category: category);
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
    genericName: 'Молочные продукты',
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
    genericName: 'Молочные продукты',
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
