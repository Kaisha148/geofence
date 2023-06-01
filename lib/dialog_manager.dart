import 'package:flutter/material.dart';

class DialogManager {
  /// 通知取得時の確認ダイアログを表示する
  void showNotificationConfirmDialog(
      BuildContext context, String msg, Function closeFunc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          content: new Text("$msg"),
          actions: <Widget>[
            new TextButton(child: const Text('閉じる'), onPressed: () => closeFunc()),
          ],
        );
      },
    );
  }
}