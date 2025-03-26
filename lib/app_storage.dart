import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorageSecure {
  AppStorageSecure(this.key);

  static const _secureStorage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  final String key;

  Future<String?> read() => _secureStorage.read(key: key);
  Future<void> delete() => _secureStorage.delete(key: key);
  Future<void> write(String? value) => _secureStorage.write(key: key, value: value);
}

class AppStorage {
  AppStorage(this.key);

  final String key;

  Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<T?> read<T>() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }

  Future<String?> readString() => read<String>();

  Future<bool> write(dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is double) return prefs.setDouble(key, value);
    if (value is bool) return prefs.setBool(key, value);
    if (value is int) return prefs.setInt(key, value);
    if (value is String) return prefs.setString(key, value);
    if (value is List<String>) return prefs.setStringList(key, value);

    throw ArgumentError('Type of value ${value.runtimeType} is not supported! ');
  }
}
