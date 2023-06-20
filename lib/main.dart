//import 'dart:async';
//import 'dart:io';

//import 'package:easy_geofencing/easy_geofencing.dart';
//import 'package:easy_geofencing/enums/geofence_status.dart';
//import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_geofence/geofence.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:flutter_map/plugin_api.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';

// import 'firebasenotice.dart';
// import 'dialog_manager.dart';

//map
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();  
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Location App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LocationExample(),
//     );
//   }
// }

// class LocationExample extends StatefulWidget {
//   @override
//   _LocationExampleState createState() => _LocationExampleState();
// }

// class _LocationExampleState extends State<LocationExample> {
//   String _latitude = '';
//   String _longitude = '';
//   late StreamSubscription<Position> _positionStreamSubscription;
//   String _locationMessage = '';
//   String _inoutMessage = '';
//   late Timer _timer;
//   late Position _currentPosition;
//   bool _change = false;

//   @override
//   void initState() {
//     super.initState();
//       _positionStreamSubscription = Geolocator.getPositionStream(
//         desiredAccuracy: LocationAccuracy.high,
//         distanceFilter: 10, // 位置情報の変更を監視する最小距離（メートル単位）
//       ).listen((Position position) {
//         setState(() {
//           _latitude = position.latitude.toString();
//           _longitude = position.longitude.toString();
//           _change = !_change;
//           _latitude = _change ? _latitude : '';
//           _longitude = _change ? _longitude : '';
//           _locationMessage = _change ? '表示':'取得中';
//         });
//       });
//       getCurrentLocation();
//   }
//   @override
//   void dispose() {
//     _positionStreamSubscription.cancel();
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> getCurrentLocation() async {
//     Geofence.initialize();
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     if (position.latitude >= 30.0 &&
//         position.longitude >= 130.0 &&
//         position.latitude <= 50.0 &&
//         position.longitude <= 140.0 ) {
//       setState(() {
//         _inoutMessage = '入ってる';
//       });
//       _currentPosition = position;
//     }else{
//       setState(() {
//         _inoutMessage = '出てる';
//         closeFunc() {
//           Navigator.pop(context);
//         }
//         DialogManager dm = new DialogManager();
//         dm.showNotificationConfirmDialog(context, "出てる",  closeFunc);
//         showNotification('Outside geofence');
//       });
//       _currentPosition = position;
//     }
//   }

//   void showNotification(String message) {
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Location App'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             SizedBox(
//                 height: 300,
//                 child: FlutterMap(
//                   options: MapOptions(
//                     center: LatLng(
//                       _currentPosition.latitude,
//                       _currentPosition.longitude,
//                     ),
//                     zoom: 16.0,
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                         'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                       subdomains: const ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: [
//                         Marker(
//                           width: 30.0,
//                           height: 30.0,
//                           point: LatLng(
//                             _currentPosition.latitude,
//                             _currentPosition.longitude,
//                           ),
//                           builder: (ctx) => Container(
//                             child: Icon(Icons.location_on),
//                           ),
//                         ),
//                       ],
//                     ),
//                     CircleLayer(
//                       circles: [
//                         CircleMarker(
//                           point: LatLng(_currentPosition.latitude, _currentPosition.longitude),
//                           radius: 100,
//                           useRadiusInMeter: true,
//                         ),
//                       ],
//                     ),
//                     CircleLayer(
//                       circles: [
//                         CircleMarker(
//                           radius: 100000,
//                           point: const LatLng(50, 100),
//                           useRadiusInMeter: true,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             Text(
//               'Latitude: $_latitude',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Longitude: $_longitude',
//               style: TextStyle(fontSize: 24),
//             ),
//             Text(
//               _locationMessage,
//               semanticsLabel: _inoutMessage,
//                style: TextStyle(fontSize: 24),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//3sec今のとこの確定
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
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
  Position? _currentPosition;
  List<LatLng> _points = [];

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    startLocationUpdates();
  }

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

  void onMapTap(TapUpDetails tapDetails) {
    double tappedLat = tapDetails.globalPosition.dx;
    double tappedLng = tapDetails.globalPosition.dy;

    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      tappedLat,
      tappedLng,
    );

    if (distance <= 100) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('警告'),
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
    }
  }

  void startLocationUpdates() {
    Timer.periodic(Duration(seconds: 3), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentPosition = position;
          _points.add(LatLng(position.latitude, position.longitude));
        });
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map App'),
      ),
      // body: Column(
        body: GestureDetector(
          onTapUp: onMapTap,
        // children: [
        //   Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(_currentPosition!.latitude,
                    _currentPosition!.longitude),
                zoom: 150.0,
              ),
              children: [
                
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
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
              ],
            ),
          ),
        //],
      //),
    );
  }
}

//kiknen
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Map App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MapExample(),
//     );
//   }
// }

// class MapExample extends StatefulWidget {
//   @override
//   _MapExampleState createState() => _MapExampleState();
// }

// class _MapExampleState extends State<MapExample> {
//   Position? _currentPosition;
//   LatLng? _selectedLocation;
//   List<CircleMarker> _circles = [];
//   List<LatLng> _points = [];

//   @override
//   void initState() {
//     super.initState();
//     getCurrentLocation();
//     startLocationUpdates();
//   }

//   void getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         _currentPosition = position;
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   void startLocationUpdates() {
//     Timer.periodic(Duration(seconds: 3), (timer) async {
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         setState(() {
//           _currentPosition = position;
//           _points.add(LatLng(position.latitude, position.longitude));
//         });
//       } catch (e) {
//         print(e);
//       }
//     });
//   }

//   void drawCircle() {
//     if (_selectedLocation != null) {
//       setState(() {
//         _circles = [
//           CircleMarker(
//             point: LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude),
//             radius: 100.0,
//             color: Colors.blue.withOpacity(0.3),
//             borderColor: Colors.blue,
//             borderStrokeWidth: 2.0,
//           ),
//         ];
//       });

//       double distance = Geolocator.distanceBetween(
//         _currentPosition!.latitude,
//         _currentPosition!.longitude,
//         _selectedLocation!.latitude,
//         _selectedLocation!.longitude,
//       );

//       if (distance <= 100.0) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('警告'),
//               content: Text('危険区域です'),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Text('OK'),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Map App'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: FlutterMap(
//               options: MapOptions(
//                 center: LatLng(
//                   _currentPosition?.latitude ?? 0.0,
//                   _currentPosition?.longitude ?? 0.0,
//                 ),
//                 zoom: 15.0,
//                 onTap: null,
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate:
//                       "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   subdomains: ['a', 'b', 'c'],
//                 ),
//                 CircleLayer(circles: _circles),
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Text(
//                   '入力フォーム',
//                   style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 16.0),
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: '緯度',
//                   ),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     setState(() {
//                       double? latitude = double.tryParse(value);
//                       if (latitude != null) {
//                         _selectedLocation = LatLng(
//                           latitude,
//                           _selectedLocation?.longitude ?? 0.0,
//                         );
//                       }
//                     });
//                   },
//                 ),
//                 SizedBox(height: 16.0),
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: '経度',
//                   ),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     setState(() {
//                       double? longitude = double.tryParse(value);
//                       if (longitude != null) {
//                         _selectedLocation = LatLng(
//                           _selectedLocation?.latitude ?? 0.0,
//                           longitude,
//                         );
//                       }
//                     });
//                   },
//                 ),
//                 SizedBox(height: 16.0),
//                 ElevatedButton(
//                   onPressed: () {
//                     drawCircle();
//                   },
//                   child: Text('GO'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }