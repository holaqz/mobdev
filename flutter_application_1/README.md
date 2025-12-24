# Справочник продуктов

Flutter-приложение, показывающее калорийность, состав и противопоказания
популярных продуктов. Источником данных служит Supabase (Postgres + REST API)
с заранее засеянным списком самых востребованных товаров.

## Требования
- Аккаунт в [Supabase](https://supabase.com/) (бесплатного тарифа хватает)

## Настройка Supabase

1. Создать проект и скопировать `Project URL` и `anon key`.
2. В SQL Editor выполнить миграцию:

   ```sql
   create table if not exists products (
     id text primary key,
     name text not null,
     generic_name text default '',
     category text default 'All',
     barcode text,
     image_url text,
     ingredients jsonb default '[]'::jsonb,
     allergens jsonb default '[]'::jsonb,
     warnings jsonb default '[]'::jsonb,
     categories jsonb default '[]'::jsonb,
     kcal numeric,
     proteins numeric,
     fat numeric,
     carbs numeric,
     popularity int default 0
   );
   ```

3. Разрешить `select` для `anon` роли:

   ```sql
   grant select on products to anon;
   ```

## Засев продуктов

В репозитории есть файл `assets/seed/products_seed.json` с ~30 популярными
позициями. Загрузить их можно скриптом:

```bash
flutter pub run tool/seed_supabase.dart `
  --url https://vcyftcxkhuikjcmmtasq.supabase.co `
  --key eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjeWZ0Y3hraHVpa2pjbW10YXNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1NTE0ODEsImV4cCI6MjA3OTEyNzQ4MX0.W7YjQ25cIRFuILQm9fto0rHkwrd5g3TL43_Vj6HpCzQ
```

> Используйте service role key, чтобы иметь права на `insert`.

## Переменные окружения

Клиент Supabase инициализируется через `--dart-define` (или `.env` для
Flutter run):

```bash
flutter run `
  --dart-define=SUPABASE_URL=https://vcyftcxkhuikjcmmtasq.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjeWZ0Y3hraHVpa2pjbW10YXNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1NTE0ODEsImV4cCI6MjA3OTEyNzQ4MX0.W7YjQ25cIRFuILQm9fto0rHkwrd5g3TL43_Vj6HpCzQ
```

Если ключи не заданы, приложение будет работать с локальным списком
 `sampleProducts` (режим оффлайн).

## Основные команды

```bash
flutter pub get        # установка зависимостей
flutter analyze        # статический анализ
flutter test           # тесты
flutter run            # запуск приложения
```

## Структура данных

Модель `Product` содержит:

- идентификатор/штрихкод (`id`, `barcode`);
- категории, ингредиенты, аллергены, предупреждения;
- макронутриенты на 100 г;
- поле `popularity` для сортировки.

Экран поддерживает поиск по названию, фильтрацию по категориям, просмотр
подробностей и избранное (сохраняется локально).
