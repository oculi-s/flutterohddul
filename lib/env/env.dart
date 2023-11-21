import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: ".env")
abstract class Env {
  @EnviedField(varName: 'KAKAO_NATIVE_KEY')
  static const String kakaoNative = _Env.kakaoNative;
  @EnviedField(varName: 'KAKAO_JS_KEY')
  static const String kakaoJS = _Env.kakaoJS;
  @EnviedField(varName: 'OHDDUL_KEY')
  static const String ohddulApi = _Env.ohddulApi;
}
