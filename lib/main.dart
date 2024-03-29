import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:location/location.dart' as setarea;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

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

class _MapExampleState extends State<MapExample> {
  Position? _currentPosition;//現在地。getcurrentlocationで設定される
  final List<LatLng> _stayPointsList = [];//点リスト
  List<LatLng> _dangerCirclesList = [];//円リスト
  bool checkHereIsDanger = false;//危険かどうか
  int countEnterDanger = 0;//危険区域に入った回数
  int unitePoints = -1;//点と点をくっつける
  List<LatLng> saveLatlngList = [];//位置を端末に保存する場所
  setarea.LocationData? currentLocation;//現在緯度経度
  LatLng? tappedPoint;//タップした場所
  bool isButtonRed = true;//ボタン押したかどうか
  List<double> dangerCircleRadiusList = [];//危険半径リスト
  int circleNumber = -1;//危険区域入場回数格納場所。０と正の数でなければなんでもいい。
  List<LatLng> circleIreruBasho = [];//円を端末に保存する場所
  List<double> hankeiIreruBasho = [];//半径を端末に保存する場所
  double sliderValue = 50.0;//円半径の初期値
  final MapController mapController = MapController();//地図動作用
  bool deleteCheck = false;//円削除実施チェック
  late LatLng deletePoint;//削除円地点
  late double deleteRadius;//削除円半径
  bool isMoveMode = false;//ボタン押したかどうか
  int escapeNum = -1;//端末内保存リストの配列番号格納用変数（初期値に意味なし）
  bool lastCheck = false;//円移動先地点
  late LatLng moveCheck;//円移動先確認判定

  @override
  void initState() {
    super.initState();
    checkLocationPermission();//通知設定
    getCurrentLocation();//現在地取得
    loadCircles();//端末円保存情報の取得
    startLocationUpdates();//毎秒の位置情報更新
    loadPoints();//端末位置保存情報の取得
  }

  //通知設定
  Future<void> checkLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      showDialog(//位置情報未許可
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('位置情報未許可'),
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
          _stayPointsList.add(LatLng(position.latitude, position.longitude));//現在地をpointに追加
          unitePoints = unitePoints +1;//位置を結ぶ用のカウント
        });
        await savePoints(_stayPointsList,0);//↑を位置情報全部いれる
        
        for(var i = 0; i < _dangerCirclesList.length; i++){
          double distance = Geolocator.distanceBetween(//危険区域からの距離
            position.latitude,position.longitude,
            _dangerCirclesList[i].latitude, _dangerCirclesList[i].longitude//タップで設定した場所
          );
          if (distance <= dangerCircleRadiusList[i]) {//距離が設定値以内
            if(!checkHereIsDanger){ //false　初めて入った場合
              circleNumber = i;
              countEnterDanger = countEnterDanger + 1;
              String countSt = countEnterDanger.toString();
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
          }else if(circleNumber==i&&checkHereIsDanger){//true 危険区域にいた場合
            showDialog(//円から出た報告
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('報告'),
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
            checkHereIsDanger = false;//判定を戻す
            return;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    });
  }

  //円を追加するメソッド
  Future<void> handleMapTap(TapPosition event,LatLng tapPoint) async {
    if(isButtonRed){//円が赤の時だけ円を追加できる
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                  title: const Text('円の大きさは？'),
                  content: const Text('円の大きさは？'),
                  actions: [
                    Slider(
                      value: sliderValue,
                      min: 1,
                      max: 100,
                      divisions: 100,
                      onChanged: (value) {
                        setState(() {
                          sliderValue = value;
                        });
                      },
                    ),
                  Text(
                    '円の大きさ: ${sliderValue.toStringAsFixed(1)}''m',
                    style: const TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        tappedPoint = tapPoint;
                        _dangerCirclesList.add(LatLng(tapPoint.latitude, tapPoint.longitude));
                      });
                      dangerCircleRadiusList.add(sliderValue);
                      savePoints(_dangerCirclesList, 1);
                      saveRadius(dangerCircleRadiusList);
                      Navigator.of(context).pop();
                    },
                    child: const Text('決定'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('キャンセル'),
                  ),
                ],
              );
            }
          );
        },
      );
    }else{
      for(int i = 0;i < _dangerCirclesList.length; i++){
        LatLng checkPoint = _dangerCirclesList[i];
        double kyori = distanceBetween(tapPoint.latitude,tapPoint.longitude,checkPoint.latitude,checkPoint.longitude);
        if(kyori <= dangerCircleRadiusList[i]&&!isMoveMode){          
          deleteCheck = true;
          mapController.move(LatLng(checkPoint.latitude-0.0006, checkPoint.longitude), mapController.camera.zoom);
          deletePoint = LatLng(checkPoint.latitude, checkPoint.longitude);
          deleteRadius = dangerCircleRadiusList[i];
          //await showModalBottomSheet(
          final movePoint = await showModalBottomSheet(
            isDismissible: false,
            enableDrag: false,
            backgroundColor: Colors.white.withOpacity(0.3),
            barrierColor: Colors.white.withOpacity(0),
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 100,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        ElevatedButton(
                          onPressed: (){
                            setState(() {
                              _dangerCirclesList.removeAt(i);
                              dangerCircleRadiusList.removeAt(i);
                              savePoints(_dangerCirclesList, 1);
                              saveRadius(dangerCircleRadiusList);
                            });
                            deleteCheck = false;
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('消す'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            deleteCheck = false;
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('キャンセル'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //deleteCheck = false;
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('移動する'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
          if (movePoint == true) {
            escapeNum = i;
            isMoveMode = true;
          }
        }
      }
    }
  }

  void _showMoveLocationBottomSheet(TapPosition event,LatLng tapPoint) async {
    lastCheck = true;
    moveCheck = tapPoint;
    await showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white.withOpacity(0.3),
      barrierColor: Colors.white.withOpacity(0),
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _dangerCirclesList[escapeNum] = tapPoint;
                      savePoints(_dangerCirclesList, 1);
                      isMoveMode = false;
                      deleteCheck = false;
                      moveCheck = const LatLng(0, 0);
                    },
                    child: const Text('移動する'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      isMoveMode = false;
                      deleteCheck = false;
                      moveCheck = const LatLng(0, 0);
                    },
                    child: const Text('キャンセル'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  //右下ボタンのチェック
  void toggleButtonColor() {
    setState(() {
      isButtonRed = !isButtonRed;
    });
  }

  //位置と円の集合体を端末保存する
  Future<void> savePoints(List<LatLng> latlngList, double check) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> latlngListToString = [];//Stringでしか入れられないのでそれ用の受け皿
    for(var i = 0; i < latlngList.length; i++) {
      String latlngToString = latlngList[i].toString();
      latlngListToString.add(latlngToString);
    }
    if(check==0){
      await prefs.setStringList('savedLatlng', latlngListToString);//これで保存
    }else if(check==1){
      await prefs.setStringList('savedCircle', latlngListToString);//これで保存
    }
  }

  //半径の集合体を端末保存する
  Future<void> saveRadius(List<double> radiusList) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> radiusListToString = [];//Stringでしか入れられないのでそれ用の受け皿
    for(var i = 0; i < radiusList.length; i++) {
      String radiusToString = radiusList[i].toString();
      radiusListToString.add(radiusToString);
    }
    await prefs.setStringList('savedRadius', radiusListToString);//これで保存
  }

  //端末内に保存した位置情報を再取得
  Future<void> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      String latlngInfo;
      List<String> splitLatlng = ["",""];
      List<String>? latlngListToString = prefs.getStringList('savedLatlng');
      
      double latitude;
      double longitude;
      LatLng loadPoint;
      for(var i = 0; i <= latlngListToString!.length; i++) {
        latlngInfo = latlngListToString[i];
        latlngInfo = latlngInfo.replaceAll("LatLng(latitude:", "");
        latlngInfo = latlngInfo.replaceAll("longitude:", "");
        latlngInfo = latlngInfo.replaceAll(")", "");
        latlngInfo = latlngInfo.trim();
        splitLatlng = latlngInfo.split(",");
        latitude = double.parse(splitLatlng[0]);
        longitude = double.parse(splitLatlng[1]);
        loadPoint = LatLng(latitude, longitude);
        setState(() {
          saveLatlngList.add(loadPoint);
        });
      }
      prefs.setBool('isFirstLaunch', false);
    }
  }

  //端末内に保存した円情報を再取得
  Future<void> loadCircles() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunchCircle') ?? true;
    if (isFirstLaunch) {
      String circleInfo;
      List<String> splitCircle = ["",""];
      List<String>? circleListToString = prefs.getStringList('savedCircle');
      List<String>? radiusListToString = prefs.getStringList('savedRadius');      
      double latitude;
      double longitude;
      LatLng circlePoint;
      double radiusSize;

      for(var i = 0; i <= circleListToString!.length; i++) {
        circleInfo = circleListToString[i].toString();
        circleInfo = circleInfo.replaceAll("LatLng(latitude:", "");
        circleInfo = circleInfo.replaceAll("longitude:", "");
        circleInfo = circleInfo.replaceAll(")", "");
        circleInfo = circleInfo.trim();
        splitCircle = circleInfo.split(",");
        latitude = double.parse(splitCircle[0]);
        longitude = double.parse(splitCircle[1]);
        circlePoint = LatLng(latitude, longitude);
        radiusSize = double.parse(radiusListToString![i]);
        setState(() {
          _dangerCirclesList.add(circlePoint);
          dangerCircleRadiusList.add(radiusSize);
        });
      }
      _dangerCirclesList = circleIreruBasho;
      dangerCircleRadiusList = hankeiIreruBasho;      
      prefs.setBool('isFirstLaunchCircle', false);
    }
  }

  //距離計算メソッド
  double distanceBetween(double latitude1, double longitude1, double latitude2, double longitude2) {
    toRadians(double degree) => degree * pi / 180;
    const double r = 6378137.0; // 地球の半径
    final double f1 = toRadians(latitude1);
    final double f2 = toRadians(latitude2);
    final double l1 = toRadians(longitude1);
    final double l2 = toRadians(longitude2);
    final num a = pow(sin((f2 - f1) / 2), 2);
    final double b = cos(f1) * cos(f2) * pow(sin((l2 - l1) / 2), 2);
    final double d = 2 * r * asin(sqrt(a + b));
    return d;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map App'),
      ),
      body: GestureDetector(       
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            initialZoom: 15.0,
            onTap: (dynamic tapPosition, LatLng latLng) {
              //onLongPress: (dynamic tapPosition, LatLng latLng) {
              if(isMoveMode){
                _showMoveLocationBottomSheet(tapPosition,latLng);
              }else{
                handleMapTap(tapPosition,latLng);
              }
            }
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            if(saveLatlngList != null)
            MarkerLayer(
              markers: saveLatlngList!.map((LatLng point) {
                return Marker(
                  point: point,
                  builder: (ctx) => const Icon(
                    Icons.location_on,
                    color: Colors.purple,
                  ),
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: _stayPointsList.map((LatLng point) {
                return Marker(
                  point: point,
                  builder: (ctx) => const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                );
              }).toList(),
            ),
            //タップで追加する円
            for(int i = 0;i < _dangerCirclesList.length;i++)
            CircleLayer(
              circles:[
                CircleMarker(
                  point: _dangerCirclesList[i],
                  radius: dangerCircleRadiusList[i],
                  color: Colors.yellow.withOpacity(0.5),
                    useRadiusInMeter: true,
                ),
              ]
            ),
            //消す円
            if(deleteCheck)
            CircleLayer(
              circles:[
                CircleMarker(
                  point: deletePoint,
                  radius: deleteRadius,
                  color: Colors.brown.withOpacity(0.5),
                    useRadiusInMeter: true,
                ),
              ]
            ),
            if(lastCheck)
            CircleLayer(
              circles:[
                CircleMarker(
                  point: moveCheck,
                  radius: deleteRadius,
                  color: Colors.purple.withOpacity(0.5),
                    useRadiusInMeter: true,
                ),
              ]
            ),
            //現在位置のセット
            if(unitePoints >0)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _stayPointsList,
                  color:Colors.red,
                  strokeWidth: 10.0,
                )
              ],
            ),
            //再起動前にいた位置のセット
            if(saveLatlngList != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: saveLatlngList,
                  color:Colors.purple,
                  strokeWidth: 10.0,
                )
              ],
            ),
            if(isMoveMode)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                color: Colors.red,
              ),
            ),
            if(isMoveMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                color: Colors.red,
              ),
            ),
            if(isMoveMode)
            Positioned(
              top: 50,
              left: 0,
              bottom: 50,
              child: Container(
                width: 50,
                color: Colors.red,
              ),
            ),
            if(isMoveMode)
            Positioned(
              top: 50,
              right: 0,
              bottom: 50,
              child: Container(
                width: 50,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
      //ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: toggleButtonColor,
        child: GestureDetector(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}