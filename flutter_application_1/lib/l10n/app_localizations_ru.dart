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
}
