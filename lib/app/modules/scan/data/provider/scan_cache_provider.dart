import 'package:my_app/core/cache/cache_helper.dart';

class ScanCacheProvider {
  final CacheHelper _helper = CacheHelper();

  Future saveScanToCache(String path) async {
    await _helper.save('path', path);
  }

  retrieveScanFromCache() async {
    final String? result = await _helper.read('path');
    return result;
  }

  Future removeScanFromCache() async {
    await _helper.remove('path');
  }
}
