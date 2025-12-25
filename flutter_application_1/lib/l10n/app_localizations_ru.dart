// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Справочник продуктов';

  @override
  String get searchHint => 'Поиск продукта...';

  @override
  String get addButton => 'Добавить';

  @override
  String get editButton => 'Редактировать';

  @override
  String get deleteButton => 'Удалить';

  @override
  String get emptyList => 'Пока нет записей';

  @override
  String get categoryAll => 'Все';

  @override
  String get categoryCereals => 'Гарнир';

  @override
  String get categorySeafood => 'Морепродукты';

  @override
  String get categoryMeat => 'Мясо';

  @override
  String get categoryBakery => 'Выпечка';

  @override
  String get categoryVegetables => 'Овощи';

  @override
  String get categoryFruits => 'Фрукты';

  @override
  String get categoryDairy => 'Молочка';

  @override
  String get categorySnacks => 'Закуски';

  @override
  String get categoryDrinks => 'Напитки';
}
