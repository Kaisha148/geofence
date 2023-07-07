// import 'dart:html';
// import 'dart:io';今後これを使おうものならFlutterのバージョンアップは避けられない
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';

//追加
import 'package:location/location.dart' as setarea;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapExample(),
    );
  }
}

class MapExample extends StatefulWidget {
  @override
  _MapExampleState createState() => _MapExampleState();
}

// class circleAndRadius{
//   LatLng point = LatLng(0, 0);
//   double radius = 0;  
// }

class _MapExampleState extends State<MapExample> {
  Position? _currentPosition;//現在地。getcurrentlocationで設定される
  final List<LatLng> _points = [];//点リスト
  List<LatLng> _circles = [];//円リスト
  bool checkHereIsDanger = false;//危険かどうか
  int count = 0;//危険区域に入った回数
  int tentotenwokuttukeru = -1;//点と点をくっつける
  List<LatLng> latlungIreruBasho = [];//位置を端末に保存する場所
  //add
  setarea.LocationData? currentLocation;//現在緯度経度
  LatLng? tappedPoint;//タップした場所
  bool isButtonRed = true;//ボタン押したかどうか
  bool backtoApp = false;//保存情報あるかどうか
  List<double> hankei = [];//危険半径リスト

  @override
  void initState() {
    super.initState();
    checkLocationPermission();//通知設定
    getCurrentLocation();//現在地取得
    startLocationUpdates();//毎秒の位置情報更新
    loadPoint();//端末保存情報の取得
  }

  //通知設定
  Future<void> checkLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      showDialog(//でてった報告
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('位置情報未許可'),
            content: const Text('設定してください'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  //現在地取得
  void getCurrentLocation() async {    

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  //毎秒の位置情報更新
  void startLocationUpdates() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        //現在地を再度取得する
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _points.add(LatLng(position.latitude, position.longitude));//現在地をpointに追加
          tentotenwokuttukeru = tentotenwokuttukeru +1;//位置を結ぶ用のカウント
        });
        await savePoint(_points);//↑を位置情報全部いれる
        
        bool isFlag = false;
        for(var i = 0; i < _circles.length; i++){
          double distance = Geolocator.distanceBetween(//危険区域からの距離
            position.latitude,position.longitude,
            _circles[i].latitude, _circles[i].longitude//タップで設定した場所
          );

          if (distance <= hankei[i]) {//距離が設定値以内
            isFlag = true;
            if(!checkHereIsDanger){ //false　初めて入った場合
              count = count + 1;
              String countSt = count.toString();
              showDialog(//入った警告
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(countSt + '回目の警告'),
                    content: const Text('危険区域です'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              checkHereIsDanger = true;//危険区域内で何度もメッセージ出ないように
              return;
            }
          }else{
            if(checkHereIsDanger){//true 危険区域にいた場合
              showDialog(//でてった報告
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('報告'),
                    content: const Text('危険区域から出ました'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              //checkHereIsDanger = false;//判定を戻す
              return;
            }
          }
        }
        if(isFlag){
          checkHereIsDanger = false;
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    });
  }

  //円を追加するメソッド
  void handleMapTap(TapPosition event,LatLng latlng) {
    //ここで円の半径を設定できるようにしたい。それはボディ側で設定できそう
    if(isButtonRed){//円が赤の時だけ円を追加できる
      showDialog(//
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('円の大きさは？'),
            content: const Text('円の大きさは？'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    tappedPoint = latlng;
                    _circles.add(LatLng(latlng.latitude, latlng.longitude));
                  });
                  hankei.add(100);
                  Navigator.of(context).pop();
                },
                child: const Text('100m'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    tappedPoint = latlng;
                    _circles.add(LatLng(latlng.latitude, latlng.longitude));
                  });
                  hankei.add(50);
                  Navigator.of(context).pop();
                },
                child: const Text('50m'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('キャンセル'),
              ),
            ],
          );
        },
      );
    }
  }

  //右下ボタンのチェック
  void toggleButtonColor() {
    setState(() {
      isButtonRed = !isButtonRed;
    });
  }

  //位置の集合体を端末保存する
  Future<void> savePoint(List<LatLng> latlngList) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stringHenkanList = [];//Stringでしか入れられないのでそれ用の受け皿
    for(var i = 0; i < latlngList.length; i++) {
      String kariokiu = latlngList[i].toString();
      stringHenkanList.add(kariokiu);
    }
    await prefs.setStringList('savedText', stringHenkanList);//これで保存
    await prefs.setBool('canLoad', true);//これで保存
  }

  //端末内に保存した位置情報を再取得
  Future<void> loadPoint() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      String okibasho;
      List<String> split = ["",""];
      List<String>? latlungHenkanList = prefs.getStringList('savedText');
      
      double latitude;double longitude;
      LatLng basho;
      for(var i = 0; i <= latlungHenkanList!.length; i++) {
        okibasho = latlungHenkanList[i].toString();
        okibasho = okibasho.replaceAll("LatLng(latitude:", "");
        okibasho = okibasho.replaceAll("longitude:", "");
        okibasho = okibasho.replaceAll(")", "");
        okibasho = okibasho.trim();
        split = okibasho.split(",");
        latitude = double.parse(split[0]);
        longitude = double.parse(split[1]);
        basho = LatLng(latitude, longitude);
        setState(() {
          latlungIreruBasho.add(basho);
        });
      }
      prefs.setBool('isFirstLaunch', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map App'),
      ),
      body: GestureDetector(       
        child: FlutterMap(
          options: MapOptions(
                center: LatLng(_currentPosition!.latitude,
                _currentPosition!.longitude),
            zoom: 15.0,
            //change
            onTap: (dynamic tapPosition, LatLng latLng) {
              handleMapTap(tapPosition,latLng);
            }
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            if(latlungIreruBasho != null)
            MarkerLayer(
              markers: latlungIreruBasho!.map((LatLng point) {
                return Marker(
                  point: point,
                  builder: (ctx) => Container(
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.purple,
                    ),
                  ),
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: _points.map((LatLng point) {
                return Marker(
                  point: point,
                  builder: (ctx) => Container(
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (tappedPoint != null&&!isButtonRed)
            MarkerLayer(
              markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: tappedPoint!,
                    builder: (ctx) => Container(
                      child: const Icon(
                        Icons.place,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                    ),
                  ),
                ],
              ),
            // if (tappedPoint != null&&!isButtonRed)
            // CircleLayer(
            //   circles: [
            //     CircleMarker(
            //       point: tappedPoint!,//isetan
            //       radius: 100,
            //       useRadiusInMeter: true,
            //       color: Colors.yellow
            //     ),
            //   ],
            // ),
            CircleLayer(
              circles: _circles.map((LatLng point) {
                return CircleMarker(
                  point: point,
                  radius: 100,
                    useRadiusInMeter: true,
                  );
                }).toList(),
              ),
            if(tentotenwokuttukeru >0)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _points,
                  color:Colors.red,
                  strokeWidth: 10.0,
                )
              ],
            ),
            if(latlungIreruBasho != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: latlungIreruBasho,
                  color:Colors.purple,
                  strokeWidth: 10.0,
                )
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: toggleButtonColor,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isButtonRed ? Colors.red : Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}