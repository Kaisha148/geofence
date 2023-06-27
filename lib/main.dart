import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';

//追加
import 'package:location/location.dart' as setarea;

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
  bool toTouch = false;

  //add
  setarea.LocationData? currentLocation;
  LatLng? tappedPoint;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    startLocationUpdates();

    //add
    getLocation();
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

  //add
  Future<void> getLocation() async {
    setarea.Location location = setarea.Location();

    bool _serviceEnabled;
    setarea.PermissionStatus _permissionGranted;
    setarea.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == setarea.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != setarea.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      currentLocation = _locationData;
    });
  }

  void handleMapTap(TapPosition event,LatLng latlng) {
    setState(() {
      tappedPoint = latlng;
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
        //children: [
           //Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(_currentPosition!.latitude,
                    _currentPosition!.longitude),
                zoom: 15.0,
                //onTap: _handleMapTap,
                //change
                onTap: (dynamic tapPosition, LatLng latLng) {
                  toTouch = true;
                  handleMapTap(tapPosition,latLng);
                }
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
                if (tappedPoint != null)
                MarkerLayer(
                  markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: tappedPoint!,
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.place,
                            color: Colors.blue,
                            size: 40.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (tappedPoint != null)
                CircleLayer(
                      circles: [
                        CircleMarker(
                          point: tappedPoint!,//isetan
                          radius: 100,
                          useRadiusInMeter: true,
                          color: Colors.yellow
                        ),
                      ],
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
                      strokeWidth: 10.0,
                    )
                  ],
                ),
              ],
            ),
          //),
        //],
      ),
    );
  }
}