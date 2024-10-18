import 'package:mvl_app_core/app_storage.dart';

abstract class FlagControl {
  FlagControl(String key) : _storage = AppStorage(key);

  final AppStorage _storage;

  Future<bool> shouldShow() async {
    return (await _storage.read<bool>()) ?? true;
  }

  Future<void> didShow() => _storage.write(true);
}
