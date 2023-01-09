


import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeCompass extends StatefulWidget {
  const HomeCompass({Key? key}) : super(key: key);

  @override
  State<HomeCompass> createState() => _HomeCompassState();
}

class _HomeCompassState extends State<HomeCompass> {

  double? heading = 0.0;
  bool _hasPermissions = false;
  bool isAvailable = false;


  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
    FlutterCompass.events!.listen((event) {setState(() {
      heading = event.heading;
    });});

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.black,
        body: _hasPermissions ?
        isAvailable ?
        _buildBody() : _buildCompassNotAvailable()
            :
        _buildPermissionSheet()
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Container(
          padding: const EdgeInsets.all(30),
          child: Text('${heading!.ceil()}°',
              style: const TextStyle(color: Colors.white, fontSize: 26)
          ),
        ),

        Stack(
          alignment: Alignment.center,
          children: [

            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Image.asset('assets/cadrant.png'),
            ),

            Container(
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: ((heading ?? 0) * (pi / 180) * -1),
                child: Image.asset('assets/compass.png', scale: 1.6),
              ),
            ),

          ],
        )
      ],
    );
  }

  Widget _buildCompassNotAvailable() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Text('Compass not avaialbe on this deviece!', style: TextStyle(color: Colors.white, fontSize: 30)),
        ],
      ),
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Location Permission Required'),
          ElevatedButton(
            child: Text('Request Permissions'),
            onPressed: () {
              Permission.locationWhenInUse.request().then((ignored) {
                _fetchPermissionStatus();
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Open App Settings'),
            onPressed: () {
              openAppSettings().then((opened) {
                //
              });
            },
          )
        ],
      ),
    );
  }

  void _fetchPermissionStatus() async {
    isAvailable = await SensorManager().isSensorAvailable(Sensors.ROTATION);
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}
