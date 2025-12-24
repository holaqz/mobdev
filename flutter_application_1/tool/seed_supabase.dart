import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  final url = _readArg(args, '--url') ?? Platform.environment['https://oyecfepknlsdaxlyloya.supabase.co'];
  final key =
      _readArg(args, '--key') ??
      Platform.environment['eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im95ZWNmZXBrbmxzZGF4bHlsb3lhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NjU2MDc5MywiZXhwIjoyMDgyMTM2NzkzfQ.wOiJ9iN6N5FozPRsmagHrbrcXyw3GcwjJNMc4qFSiHE'] ??
      Platform.environment['eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im95ZWNmZXBrbmxzZGF4bHlsb3lhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1NjA3OTMsImV4cCI6MjA4MjEzNjc5M30.qR1iIlSmpQFuUBu_hHEjvs4yOZI8U2jKbBR89vS_t58'];

  if (url == null || key == null) {
    stderr.writeln(
      'Укажите --url и --key или выставьте переменные SUPABASE_URL и SUPABASE_SERVICE_ROLE_KEY',
    );
    exit(1);
  }

  final seedFile = File('assets/seed/products_seed.json');
  if (!seedFile.existsSync()) {
    stderr.writeln('Не найден файл ${seedFile.path}');
    exit(1);
  }
  final payload = json.decode(await seedFile.readAsString()) as List<dynamic>;

  final endpoint = Uri.parse(
    '$url/rest/v1/products',
  ).replace(queryParameters: {'on_conflict': 'id'});

  final client = http.Client();
  try {
    final response = await client.post(
      endpoint,
      headers: {
        'apikey': key,
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates,return=minimal',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 300) {
      stderr.writeln(
        'Ошибка загрузки: ${response.statusCode}\n${response.body}',
      );
      exit(1);
    }
    stdout.writeln('Успешно загружено ${payload.length} продуктов');
  } finally {
    client.close();
  }
}

String? _readArg(List<String> args, String key) {
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('$key=')) {
      return arg.substring(key.length + 1);
    }
    if (arg == key && i + 1 < args.length) {
      return args[i + 1];
    }
  }
  return null;
}
