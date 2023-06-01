import 'dart:async';
import 'dart:io';

import 'package:easy_geofencing/easy_geofencing.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'firebasenotice.dart';
import 'dialog_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LocationExample(),
    );
  }
}

class LocationExample extends StatefulWidget {
  @override
  _LocationExampleState createState() => _LocationExampleState();
}

class _LocationExampleState extends State<LocationExample> {
  String _latitude = '';
  String _longitude = '';
  late StreamSubscription<Position> _positionStreamSubscription;
  String _locationMessage = '';
  String _inoutMessage = '';
  late Timer _timer;
  late Position _currentPosition;
  bool _change = false;

  @override
  void initState() {
    super.initState();
      _positionStreamSubscription = Geolocator.getPositionStream(
        desiredAccuracy: LocationAccuracy.high,
        distanceFilter: 10, // 位置情報の変更を監視する最小距離（メートル単位）
      ).listen((Position position) {
        setState(() {
          _latitude = position.latitude.toString();
          _longitude = position.longitude.toString();
          _change = !_change;
          _latitude = _change ? _latitude : '';
          _longitude = _change ? _longitude : '';
          _locationMessage = _change ? '表示':'取得中';
        });
      });
      getCurrentLocation();
  }
  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    Geofence.initialize();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (position.latitude >= 30.0 &&
        position.longitude >= 130.0 &&
        position.latitude <= 50.0 &&
        position.longitude <= 140.0 ) {
      setState(() {
        _inoutMessage = '入ってる';
      });
      _currentPosition = position;
    }else{
      setState(() {
        _inoutMessage = '出てる';
        closeFunc() {
          Navigator.pop(context);
        }
        DialogManager dm = new DialogManager();
        dm.showNotificationConfirmDialog(context, "出てる",  closeFunc);
        showNotification('Outside geofence');
      });
      _currentPosition = position;
    }
  }

  void showNotification(String message) {
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(
                      _currentPosition.latitude,
                      _currentPosition.longitude,
                    ),
                    zoom: 16.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
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
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                          radius: 100,
                          useRadiusInMeter: true,
                        ),
                      ],
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          radius: 100000,
                          point: const LatLng(50, 100),
                          useRadiusInMeter: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Text(
              'Latitude: $_latitude',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Text(
              'Longitude: $_longitude',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              _locationMessage,
              semanticsLabel: _inoutMessage,
               style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}