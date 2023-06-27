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
  bool checkHereIsDanger = false;
  int count = 0;
  int tentotenwokuttukeru = -1;
  late LatLng _tappedLocation;

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

  void _handleMapTap(TapPosition tapPosition, LatLng tappedPoint) {
    setState(() {
      _tappedLocation = tappedPoint;
    });
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
        tentotenwokuttukeru = tentotenwokuttukeru +1;
        });

        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          35.6995495, 139.4129885
        );

        if (distance <= 100) {
          if(!checkHereIsDanger){ //false
            count = count + 1;
            String countSt = count.toString();
            showDialog(
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
            checkHereIsDanger = true;
          }
        }else{
          if(checkHereIsDanger){
            checkHereIsDanger = false;
          }
        }

      } catch (e) {
        print(e);
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
        // children: [
        //   Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(_currentPosition!.latitude,
                    _currentPosition!.longitude),
                zoom: 15.0,
                onTap: _handleMapTap,
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
                CircleLayer(
                      circles: [
                        CircleMarker(
                          point: LatLng(35.6995495, 139.4129885),//isetan
                          radius: 100,
                          useRadiusInMeter: true,
                        ),
                      ],
                    ),
                if(tentotenwokuttukeru >0)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _points,
                      color:Colors.red,
                      strokeWidth: 25.0,
                    )
                  ],
                ),
                if (_tappedLocation != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tapped Location: Lat: ${_tappedLocation.latitude}, Lng: ${_tappedLocation.longitude}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        //],
      //),
    );
  }
}