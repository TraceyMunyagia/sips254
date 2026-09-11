import 'dart:io';
import 'supabase_service.dart';

class StorageService {
  final _client = SupabaseService.client;

  Future<String> uploadCocktailPhoto(File file, String userId) async {
    final fileExt = file.path.split('.').last;
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = fileName;

    await _client.storage.from('cocktail-photos').upload(path, file);

    return _client.storage.from('cocktail-photos').getPublicUrl(path);
  }
}