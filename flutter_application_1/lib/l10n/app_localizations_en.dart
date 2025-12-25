// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Food Reference';

  @override
  String get searchHint => 'Search product...';

  @override
  String get addButton => 'Add';

  @override
  String get editButton => 'Edit';

  @override
  String get deleteButton => 'Delete';

  @override
  String get emptyList => 'No items yet';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryCereals => 'Cereals';

  @override
  String get categorySeafood => 'Seafood';

  @override
  String get categoryMeat => 'Meat';

  @override
  String get categoryBakery => 'Bakery';

  @override
  String get categoryVegetables => 'Vegetables';

  @override
  String get categoryFruits => 'Fruits';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryDrinks => 'Drinks';
}
