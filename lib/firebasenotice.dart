import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Firebasenotice {
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// FCMにトークンを登録する。
  /// 登録されたトークンはフィールドに格納する
  void registFcmToken() {
    Firebase.initializeApp();
    var _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((token) {
      _fcmToken = token;
      print('----------');
      print('TOKEN::: $_fcmToken');
      print('----------');
    });
    _firebaseMessaging.subscribeToTopic("all");
  }
}
