import 'package:encrypt/encrypt.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/request/login_request.dart';
import 'package:pointycastle/pointycastle.dart' as pc;

/// RSA 加密工具：封装"拉后端公钥 + 加密明文"链路。
///
/// 复用登录页的实现（`login_screen.dart` 内联版），Profile 改密码调用它。
/// 后端 `GET /getRsaPublicKey` 返回裸 base64 公钥，需补 PEM 头尾并每 64 字符换行。
class RsaUtil {
  const RsaUtil._();

  /// 将裸 base64 公钥包装为 PEM 格式（RFC 规范每 64 字符换行）。
  static String formatPublicKey(String rawBase64) {
    const header = '-----BEGIN PUBLIC KEY-----\n';
    const footer = '\n-----END PUBLIC KEY-----';
    final sb = StringBuffer(header);
    for (var i = 0; i < rawBase64.length; i += 64) {
      final end = (i + 64) > rawBase64.length ? rawBase64.length : i + 64;
      sb.writeln(rawBase64.substring(i, end));
    }
    return '$sb$footer';
  }

  /// 用后端 RSA 公钥加密 [plain]，返回 base64 密文。
  ///
  /// 每次调用都拉取一次公钥（与登录一致），失败抛 [FxApiException]。
  static Future<String> rsaEncrypt(String plain) async {
    final res = await LoginService().getRsaPublicKey();
    final rawKey = FxApi.unwrap(res);
    if (rawKey is! String || rawKey.isEmpty) {
      throw FxApiException(-1, '获取加密公钥失败');
    }
    final pem = formatPublicKey(rawKey);
    final publicKey = RSAKeyParser().parse(pem) as pc.RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    return encrypter.encrypt(plain).base64;
  }
}

/// 顶层便捷函数，Profile 改密码直接调 `rsaEncrypt(pwd)`。
Future<String> rsaEncrypt(String plain) => RsaUtil.rsaEncrypt(plain);
