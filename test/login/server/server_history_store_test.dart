import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/login/model/users.dart';
import 'package:fortuneboot/login/server/server_endpoint.dart';
import 'package:fortuneboot/login/server/server_history_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    UserDataSingleton().init(prefs);
    // 单例存在进程级内存缓存，同一文件内用例间会互相残留，显式清空历史。
    UserDataSingleton().setStr(ServerHistoryStore.prefsKey, '');
  });

  test('remember keeps newest first and dedupes', () async {
    final store = ServerHistoryStore();
    final a = ServerEndpoint.parse(
      protocol: 'https',
      host: 'a.example.com',
      port: '443',
    );
    final b = ServerEndpoint.parse(protocol: 'http', host: '192.168.1.8');

    await store.remember(a);
    await store.remember(b);
    await store.remember(a);

    final list = await store.load();
    expect(list.map((e) => e.displayLabel).toList(), [
      'https://a.example.com:443',
      'http://192.168.1.8',
    ]);
  });

  test('rememberCurrentSaved reads persisted base url fields', () async {
    final user = UserDataSingleton();
    user.setStr(UserDataSingleton.baseUrlProtocol, 'https');
    user.setStr(UserDataSingleton.baseUrlDomain, 'demo.fortuneboot.com');
    user.setStr(UserDataSingleton.baseUrlPort, '443');

    final store = ServerHistoryStore();
    await store.rememberCurrentSaved();

    final list = await store.load();
    expect(list.single.displayLabel, 'https://demo.fortuneboot.com:443');
  });
}
