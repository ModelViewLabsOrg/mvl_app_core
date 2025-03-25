import 'package:mvl_app_core/app_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionAvailableFlag {
  VersionAvailableFlag(this.version) : _key = 'version_available_$version';

  final String version;
  final String _key;

  Future<bool> shouldShow() async {
    final lastDate = await AppStorage(_key).read<int>();
    if (lastDate == null) return true;

    final lastShowed = DateTime.fromMillisecondsSinceEpoch(lastDate);
    return DateTime.now().difference(lastShowed).inDays > 2;
  }

  Future<void> didShow() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setInt(_key, DateTime.now().millisecondsSinceEpoch);
  }
}
