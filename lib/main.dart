// 以下チャットGPTのやつ３

import 'package:easy_geofencing/easy_geofencing.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:geofence/geofence.dart';
import 'package:latlong2/latlong.dart';
// import 'package:geofence/geofence.dart' as geofence;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geofence App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GeofenceExample(),
    );
  }
}

class GeofenceExample extends StatefulWidget {
  @override
  _GeofenceExampleState createState() => _GeofenceExampleState();
}

class _GeofenceExampleState extends State<GeofenceExample> {
  //Position _currentPosition;
  late Position _currentPosition;
  // GeofenceStatus _geofenceStatus = GeofenceStatus.unknown;
  GeofenceStatus _geofenceStatus = GeofenceStatus.init;

  @override
  void initState() {
    super.initState();
    initGeofence();
    getCurrentLocation();
  }

  void initGeofence() async {
    Geofence.initialize();

    // Geofence.onGeofenceStatusChanged.listen((GeofenceStatus status) {
      Geofence.backgroundLocationUpdated.stream.listen((event){
      setState(() {
        // _geofenceStatus = status;
        _geofenceStatus = GeofenceStatus.values as GeofenceStatus;
      });
      // if (status == GeofenceStatus.outside) {
        if (_geofenceStatus == GeofenceStatus.exit) {
        showNotification('Outside geofence');
      }
    });

    // 緯度経度を指定してジオフェンスを設定
    final LatLng targetLocation = LatLng(35.123456, 139.654321);
    final radius = 100.0; // 半径100メートル
    final geofenceId = 'example_geofence';

    await Geofence.addGeolocation(
      // geofenceId,
      geofenceId as Geolocation,
      // geofence.Geolocation(
      //   latitude: targetLocation.latitude,
      //   longitude: targetLocation.longitude,
      //   radius: radius,
      // ),
      EasyGeofencing.startGeofenceService(
        // pointedLatitude: TextEditingController(text: position!.latitude.toString()).text,
        // pointedLongitude: TextEditingController(text: position!.longitude.toString()).text,
        pointedLatitude: "35.123456",
        pointedLongitude: "139.654321",
        radiusMeter: "100",
    ));

    // Geofence.startListening(GeolocationEvent.entry,);
    Geofence.startListening(GeolocationEvent.entry, (entry) {
      print("entrysimasita");
    });
    // Geofence.startListening(GeolocationEvent.exit,);
    Geofence.startListening(GeolocationEvent.exit, (entry) {
      print("exitsimasita");
    });
  }

  void getCurrentLocation() async {
    //final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    // Position position = await geolocator.getCurrentPosition(
      Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });
  }

  void showNotification(String message) {
    // 通知を表示する処理を実装
  }

  @override
  void dispose() {
    // Geofence.stopListening();
    Geofence.stopListeningForLocationChanges();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geofence App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentPosition != null)
              Container(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(
                      _currentPosition.latitude,
                      _currentPosition.longitude,
                    ),
                    zoom: 16.0,
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayerOptions(
                      markers: [
                        Marker(
                          width: 30.0,
                          height: 30.0,
                          point: LatLng(
                            _currentPosition.latitude,
                            _currentPosition.longitude,
                          ),
                          builder: (ctx) => Container(
                            child: Icon(Icons.location_on),
                          ),
                        ),
                      ],
                    ),
                    // if (_geofenceStatus == GeofenceStatus.outside)
                    if (_geofenceStatus == GeofenceStatus.exit)
                      CircleLayerOptions(
                        circles: [
                          CircleMarker(
                            point: LatLng(
                              _currentPosition.latitude,
                              _currentPosition.longitude,
                            ),
                            radius: 100.0,
                            color: Colors.red.withOpacity(0.2),
                            borderColor: Colors.red,
                            borderStrokeWidth: 2.0,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            Text(
              'Geofence Status:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              _geofenceStatus.toString(),
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}


// 以下チャットGPTのやつ②
// import 'package:flutter/material.dart';
//import 'package:flutter_geofence/Geolocation.dart';
// import 'package:flutter_geofence/geofence.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geofence/geofence.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       //title: 'Flutter Demo',
//       title: 'Geofence Example',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       //home: MyHomePage(title: 'Flutter Demo Home Page'),
//       home: GeofenceExample(),
//     );
//   }
// }

// class GeofenceExample extends StatefulWidget {
//   @override
//   _GeofenceExampleState createState() => _GeofenceExampleState();
// }

// class _GeofenceExampleState extends State<GeofenceExample> {
//   late Position _currentPosition;
//   //GeofenceStatus _geofenceStatus = GeofenceStatus.unknown;
//   Geofence _geofenceStatus = Geofence.initialize();

//   @override
//   void initState() {
//     super.initState();
//     initGeofence();
//     getCurrentLocation();
//   }

//   void initGeofence() async {
//     Geofence.initialize();

//     //Geofence.onGeofenceStatusChanged.listen((GeofenceStatus status) {
//       Geofence.onGeofenceStatusChanged.listen(_geofenceStatus status);
//       setState(() {
//         _geofenceStatus = status;
//       });
//     }

//     Geofence.startListening(GeolocationEvent.entry);
//     Geofence.startListening(GeolocationEvent.exit);
//   }

//   void getCurrentLocation() async {
//     final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
//     Position position = await geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       _currentPosition = position;
//     });
//   }

//   @override
//   void dispose() {
//     Geofence.stopListeningForLocationChanges();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Geofence Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Current Position:',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 8),
//             Text(
//               _currentPosition != null
//                   ? 'Lat: ${_currentPosition.latitude}, Lng: ${_currentPosition.longitude}'
//                   : 'Fetching...',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 32),
//             Text(
//               'Geofence Status:',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 8),
//             Text(
//               _geofenceStatus.toString(),
//               style: TextStyle(fontSize: 24),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//}


// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// 以下チャットGPTのやつ①

// import 'package:flutter/material.dart';
// import 'package:flutter_geofence/Geolocation.dart';
// import 'package:flutter_geofence/geofence.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geofence/geofence.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Geofence Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//     );
//   }
// }

// class GeofenceExample extends StatefulWidget {
//   @override
//   _GeofenceExampleState createState() => _GeofenceExampleState();
// }

// class _GeofenceExampleState extends State<GeofenceExample> {
//   GeofenceStatus _geofenceStatus = GeofenceStatus.unknown;
//   Position _currentPosition;

//   @override
//   void initState() {
//     super.initState();
//     initGeofence();
//     getCurrentLocation();
//   }

//   void initGeofence() async {
//     await Geofence.initialize();

//     Geofence.startListening(GeolocationEvent.entry, (entry) {
//       setState(() {
//         _geofenceStatus = GeofenceStatus.inside;
//       });
//       // ジオフェンスに入った時の処理
//       // 例えば通知を表示するなどのアクションを実行
//     });

//     Geofence.startListening(GeolocationEvent.exit, (exit) {
//       setState(() {
//         _geofenceStatus = GeofenceStatus.outside;
//       });
//       // ジオフェンスから出た時の処理
//       // 例えば通知を表示するなどのアクションを実行
//     });
//   }

//   void getCurrentLocation() async {
//     final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
//     Position position = await geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       _currentPosition = position;
//     });
//   }

//   @override
//   void dispose() {
//     Geofence.stopListening();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Geofence Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Current Position:',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 8),
//             Text(
//               _currentPosition != null
//                   ? 'Lat: ${_currentPosition.latitude}, Lng: ${_currentPosition.longitude}'
//                   : 'Fetching...',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 32),
//             Text(
//               'Geofence Status:',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 8),
//             Text(
//               _geofenceStatus == GeofenceStatus.inside
//                   ? 'Inside Geofence'
//                   : _geofenceStatus == GeofenceStatus.outside
//                       ? 'Outside Geofence'
//                       : 'Unknown',
//               style: TextStyle(fontSize: 24),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// 以下、ネットの拾いもの
// import 'dart:math';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_geofence/geofence.dart';
// import 'geolocations.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:gap/gap.dart';
// import 'package:oktoast/oktoast.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() {
//   //runApp(MyApp());
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   //下追加
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     //↓flutterの画面テンプレみたいな
//     return OKToast(
//       child: MaterialApp(
//         title: 'Geofencing',
//         home: MainPage(),
//       ),
//     );
//   }
// }

// class MainPage extends HookWidget {
//   //通知
//   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
//   //リスト三つ用意してる？
//   // static final locationCount = 3;
//   static const locationCount = 3;
//   final latitudeController =
//       List.generate(locationCount, (_) => TextEditingController());
//   final longitudeController =
//       List.generate(locationCount, (_) => TextEditingController());
//   final radiusController =
//       List.generate(locationCount, (_) => TextEditingController(text: '100'));

// //下追加
//   MainPage({super.key});

//   String entryID(int locationNum) => 'entry_location${locationNum + 1}';
//   String exitID(int locationNum) => 'exit_location${locationNum + 1}';

//   @override
//   Widget build(BuildContext context) {
//     //https://note.com/jigjp_engineer/n/n6b53b2c16867 
//     //useEffect には effect というコールバックを渡すことができます。
//     //このコールバックは HookWidget の build 時に同期的に （すなわち、build メソッドで呼び出されたタイミングで即座に）実行されます。
//     //また、Widget が dispose されるタイミングで、effect コールバックで返した disposer が実行されます。
//     useEffect(() {
//       _initialize();
//       return null;
//     }, const []);

//     return Scaffold(
//       appBar: AppBar(
//         // title: Text('Geofence Sample'),
//         title: const Text('Geofence Sample'),
//       ),
//       body: Container(
//         // padding: EdgeInsets.only(
//           padding: const EdgeInsets.only(
//           left: 16.0,
//           right: 16.0,
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: _buildLocation(),
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildLocation() {
//     final widgets = <Widget>[];
//     for (int index = 0; index < locationCount; index++) {
//       widgets.add(TextField(
//         keyboardType: TextInputType.number,
//         //↓入力フォームのデコレーション
//         decoration:
//             InputDecoration(labelText: 'Location ${index + 1} latitude'),
//         //緯度
//         controller: latitudeController[index],
//       ));
//       widgets.add(TextField(
//         keyboardType: TextInputType.number,
//         decoration:
//             InputDecoration(labelText: 'Location ${index + 1} longitude'),
//         //経度
//         controller: longitudeController[index],
//       ));
//       widgets.add(TextField(
//         keyboardType: TextInputType.number,
//         decoration: InputDecoration(
//             labelText: 'Location ${index + 1} radius', hintText: 'mater'),
//         //半径
//         controller: radiusController[index],
//       ));
//       // widgets.add(Gap(8));
//       //レイアウト調整用ギャップ
//       widgets.add(const Gap(8));
//       widgets.add(ElevatedButton(
//         onPressed: () => _addGeolocation(index),
//         child: Text('Add Location ${index + 1}'),
//       ));
//       widgets.add(ElevatedButton(
//         onPressed: () => _setCurrentLocation(index),
//         child: Text('Set Current Location to ${index + 1}'),
//       ));
//       // widgets.add(Gap(8));
//       widgets.add(const Gap(8));
//     }
//     widgets.add(ElevatedButton(
//       onPressed: _removeAllGeolocation,
//       // child: Text('Remove All Geolocation'),
//       child: const Text('Remove All Geolocation'),
//       style: ElevatedButton.styleFrom(
//         // primary: Colors.red,
//         backgroundColor: Colors.red,
//       ),
//     ));
//     // widgets.add(Gap(32));
//     widgets.add(const Gap(32));

//     return widgets;
//   }

//   Future<void> _initialize() async {
//     if (kDebugMode) {print("あああ");}
//     //final initializationSettingsAndroid =
//     const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
//     if (kDebugMode) {print("いいい");}
//     //final initializationSettingsIOS =
//     const initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: null);
//     if (kDebugMode) {print("ううう");}
//     // final initializationSettings = InitializationSettings(
//     const initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid, iOS: initializationSettingsIOS
//     );
//     if (kDebugMode) {print("えええ");}
//     //通知の設定初期化
//     await _requestPermissions();
//     if (kDebugMode) {print("おおお");}
//     await FlutterLocalNotificationsPlugin().initialize(initializationSettings, onSelectNotification: null);
//     if (kDebugMode) {print("かかか");}
//     _loadSharedPreference();
//     if (kDebugMode) {print("キキキ");}
//     Geofence.initialize();
//     if (kDebugMode) {print("ククク");}
//     _startListening();
//     if (kDebugMode) {print("けけけ");}
//   }

//   Future<void> _requestPermissions() async {
//     if (kDebugMode) {print("こここ");}
//     await [Permission.notification, Permission.location].request();
//     if (kDebugMode) {print("さささ");}
//   }

//   Future<void> _loadSharedPreference() async {
//     if (kDebugMode) {print("獅子氏");}
//     for (int locationNum = 0; locationNum < locationCount; locationNum++) {
//       if (kDebugMode) {print("すすす");}
//       final location = await Geolocations.getGeolocation(locationNum);
//       if (kDebugMode) {print("せせせ");}
//       if (location != null) {
//         if (kDebugMode) {print("そそそ");}
//         latitudeController[locationNum].text = location.latitude.toString();
//         if (kDebugMode) {print("他たた");}
//         longitudeController[locationNum].text = location.longitude.toString();
//         if (kDebugMode) {print("父ち");}
//         radiusController[locationNum].text = location.radius.toString();
//         if (kDebugMode) {print("つつつ");}
//       }
//       if (kDebugMode) {print("ててて");}
//     }
//     if (kDebugMode) {print("ととと");}
//   }

//   void _addGeolocation(int locationNum) {
//     if (kDebugMode) {print("ななな");}
//     var isSuccess = true;
//     if (kDebugMode) {print("ににに");}
//     final entry = Geolocation(
//         latitude: double.parse(latitudeController[locationNum].text),
//         longitude: double.parse(longitudeController[locationNum].text),
//         radius: double.parse(radiusController[locationNum].text),
//         id: entryID(locationNum)
//     );
//     if (kDebugMode) {print("ぬぬぬ");}
//     final exit = Geolocation(
//         latitude: double.parse(latitudeController[locationNum].text),
//         longitude: double.parse(longitudeController[locationNum].text),
//         radius: double.parse(radiusController[locationNum].text),
//         id: exitID(locationNum)
//     );
//     if (kDebugMode) {print("ねねね");}

//     Geofence.addGeolocation(
//       entry,
//       GeolocationEvent.entry,
//     ).catchError((onError) {
//     if (kDebugMode) {print("ののの");}
//       isSuccess = false;
//       if (kDebugMode) {print("母は");}
//     });
//       if (kDebugMode) {print("ひひひ");}
//     Geofence.addGeolocation(
//       exit,
//       GeolocationEvent.exit,
//     ).catchError((onError) {
//       if (kDebugMode) {print("ふふふ");}
//       isSuccess = false;
//         if (kDebugMode) {print("へへへ");}
//     });
//       if (kDebugMode) {print("ほほほ");}
//     if (isSuccess) {
//     if (kDebugMode) {print("魔まま");}
//       showToast('success to add location ${locationNum + 1}');
//     if (kDebugMode) {print("みみみ");}
//       Geolocations.setGeolocation(locationNum, entry);
//     if (kDebugMode) {print("むむむ");}
//       } else {
//       if (kDebugMode) {print("めめめ");}
//       showToast('failure to add ${locationNum + 1}');
//       if (kDebugMode) {print("ももも");}
//     }
//       if (kDebugMode) {print("ややや");}
//   }

//   Future<void> _setCurrentLocation(int locationNum) async {
//       if (kDebugMode) {print("ゆゆゆ");}
//     final location = await Geofence.getCurrentLocation();
//       if (kDebugMode) {print("よよよ");}
//     if (location != null) {
//       if (kDebugMode) {print("ららら");}
//       // print('current ${location.latitude},${location.longitude}');
//       if (kDebugMode) {
//       if (kDebugMode) {print("理リリ");}
//         print('current ${location.latitude},${location.longitude}');
//   if (kDebugMode) {print("ルルル");}
//       }
//     if (kDebugMode) {print("れれれ");}
//       longitudeController[locationNum].text = '${location.longitude}';
//       if (kDebugMode) {print("ロロろ");}
//       latitudeController[locationNum].text = '${location.latitude}';
//       if (kDebugMode) {print("わわわ");}
//       showToast('set current location to TextField \nNot yet add');
//         if (kDebugMode) {print("ををを");}
//     } else {
//         if (kDebugMode) {print("んんん");}
//       showToast('Location information has not been acquired');
//       if (kDebugMode) {print("ががが");}
//     }
//         if (kDebugMode) {print("ギギギ");}
//   }

//   void _removeAllGeolocation() {
//         if (kDebugMode) {print("グググ");}
//     Geofence.removeAllGeolocations().then((value) {
//       if (kDebugMode) {print("ゲゲゲ");}
//       showToast('remove all geolocations');
//         if (kDebugMode) {print("午後後");}
//       // longitudeController.forEach((controller) => controller.clear());
//       // latitudeController.forEach((controller) => controller.clear());
//       // radiusController.forEach((controller) => controller.text = '100');
//       for (var controller in longitudeController) {
//         if (kDebugMode) {print("ざざざ");}
//         controller.clear();
//       if (kDebugMode) {print("時事児");}
//       }
//         if (kDebugMode) {print("ズズズ");}
//       for (var controller in latitudeController) {
//       if (kDebugMode) {print("膳所ぜ");}
//         controller.clear();
//     if (kDebugMode) {print("ゾゾゾ");}
//       }
//     if (kDebugMode) {print("ダダダ");}
//       for (var controller in radiusController) {
//       if (kDebugMode) {print("ぢぢぢ");}
//         controller.text = '100';
//         if (kDebugMode) {print("づづづ");}
//       }
//         if (kDebugMode) {print("デデデ");}
//       Geolocations.clear();
//       if (kDebugMode) {print("ドドド");}
//     // }).onError((error, stackTrace) {
//       // ignore: sdk_version_since
//       }).onError((error, stackTrace) {
//       if (kDebugMode) {print("バババ");}
//       showToast('failure to remove all geolocations');
//     if (kDebugMode) {print("ビビビ");}
//     });
//       if (kDebugMode) {print("ぶぶぶ");}
//   }

//   void _startListening() {
//         if (kDebugMode) {print("べべべ");}
//     Geofence.startListening(GeolocationEvent.entry, (entry) {
//         if (kDebugMode) {print("ボボぼ");}
//       // print("Entry ${entry.id}");
//       if (kDebugMode) {
//       if (kDebugMode) {print("パパパ");}
//         print("Entry ${entry.id}");
//       if (kDebugMode) {print("ピピぴ");}
//       }
//     if (kDebugMode) {print("プププ");}
//       // scheduleNotification('entry', '${entry.id}');
//       scheduleNotification('entry', entry.id);
//     if (kDebugMode) {print("ぺぺぺ");}
//     });
//         if (kDebugMode) {print("ぽぽぽ");}
//     Geofence.startListening(GeolocationEvent.exit, (entry) {
//       if (kDebugMode) {print("ぁぁぁ");}
//       // print("Exit ${entry.id}");
//       if (kDebugMode) {
//       if (kDebugMode) {print("ぃぃぃ");}
//         print("Exit ${entry.id}");
//       if (kDebugMode) {print("ぅぅぅ");}
//       }
//       if (kDebugMode) {print("ぇぇぇ");}
//       // scheduleNotification('exit', '${entry.id}');
//       scheduleNotification('exit', entry.id);
//       if (kDebugMode) {print("ぉぉぉ");}
//     });
//       if (kDebugMode) {print("っっっ");}
//   }

//   void scheduleNotification(String title, String subtitle) {
//     if (kDebugMode) {print("ゃゃゃ");}
//     // Future.delayed(Duration(seconds: 5)).then((result) async {
//       Future.delayed(const Duration(seconds: 5)).then((result) async {
//         if (kDebugMode) {print("ゅゅゅ");}
//       // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
//           //'id', 'name', 'description',
//           'id', 'name',
//           importance: Importance.high, priority: Priority.high
//       );
//       if (kDebugMode) {print("ょょょ");}
//       // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//       var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
//       if (kDebugMode) {print("ゎゎゎ");}
//       var platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: iOSPlatformChannelSpecifics
//       );
//       if (kDebugMode) {print("ヴヴヴ");}
//       await flutterLocalNotificationsPlugin.show(Random().nextInt(100000), title, subtitle, platformChannelSpecifics);
//       if (kDebugMode) {print("けつ１");}
//     });
//     if (kDebugMode) {print("けつ２");}
//   }
// }

// 以下ネットの拾い物２

// import 'dart:async';
// import 'package:easy_geofencing/easy_geofencing.dart';
// import 'package:easy_geofencing/enums/geofence_status.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

///
///This is an [example] app for testing the [EasyGeofencing] dart package
///that is purely written in dart
///
// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Easy Geofencing',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'Easy Geofencing'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, this.title}) : super(key: key);

//   final String? title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   TextEditingController latitudeController = new TextEditingController();
//   TextEditingController longitudeController = new TextEditingController();
//   TextEditingController radiusController = new TextEditingController();
//   StreamSubscription<GeofenceStatus>? geofenceStatusStream;
//   Geolocator geolocator = Geolocator();
//   String geofenceStatus = '';
//   bool isReady = false;
//   Position? position;
//   @override
//   void initState() {
//     super.initState();
//     getCurrentPosition();
//   }

//   getCurrentPosition() async {
//     position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     print("LOCATION => ${position!.toJson()}");
//     isReady = (position != null) ? true : false;
//   }

//   setLocation() async {
//     await getCurrentPosition();
//     // print("POSITION => ${position!.toJson()}");
//     latitudeController =
//         TextEditingController(text: position!.latitude.toString());
//     longitudeController =
//         TextEditingController(text: position!.longitude.toString());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title!),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.my_location),
//             onPressed: () {
//               if (isReady) {
//                 setState(() {
//                   setLocation();
//                 });
//               }
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           // mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             TextField(
//               controller: latitudeController,
//               decoration: InputDecoration(
//                   border: InputBorder.none, hintText: 'Enter pointed latitude'),
//             ),
//             TextField(
//               controller: longitudeController,
//               decoration: InputDecoration(
//                   border: InputBorder.none,
//                   hintText: 'Enter pointed longitude'),
//             ),
//             TextField(
//               controller: radiusController,
//               decoration: InputDecoration(
//                   border: InputBorder.none, hintText: 'Enter radius in meter'),
//             ),
//             SizedBox(
//               height: 60,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // RaisedButton(
//                   ElevatedButton(
//                   child: Text("Start"),
//                   onPressed: () {
//                     print("starting geoFencing Service");
//                     EasyGeofencing.startGeofenceService(
//                         pointedLatitude: latitudeController.text,
//                         pointedLongitude: longitudeController.text,
//                         radiusMeter: radiusController.text,
//                         // pointedLatitude: "35",
//                         // pointedLongitude: "140",
//                         // radiusMeter: "100" ,
//                         eventPeriodInSeconds: 5);
//                     if (geofenceStatusStream == null) {
//                       geofenceStatusStream = EasyGeofencing.getGeofenceStream()!
//                           .listen((GeofenceStatus status) {
//                         print(status.toString());
//                         setState(() {
//                           geofenceStatus = status.toString();
//                         });
//                       });
//                     }
//                   },
//                 ),
//                 SizedBox(
//                   width: 10.0,
//                 ),
//                 // RaisedButton(
//                   ElevatedButton(
//                   child: Text("Stop"),
//                   onPressed: () {
//                     print("stop");
//                     EasyGeofencing.stopGeofenceService();
//                     geofenceStatusStream!.cancel();
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 100,
//             ),
//             Text(
//               "Geofence Status: \n\n\n" + geofenceStatus,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     latitudeController.dispose();
//     longitudeController.dispose();
//     radiusController.dispose();
//     super.dispose();
//   }
// }