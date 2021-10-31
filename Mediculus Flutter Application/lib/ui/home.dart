import 'dart:core';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:automated_ambualnce/ripple.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:automated_ambualnce/ui/map.dart';

//https://emergency-io.herokuapp.com
//http://192.168.29.188:8080/

class Home extends StatefulWidget {
  static const String id = 'home_screen';

  Home({this.flag = 0});

  int flag;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Duration dur = Duration(milliseconds: 2300);
  Duration dur2 = Duration(milliseconds: 0);
  IO.Socket? socket;

  void initSocket() {
    print('init socket');

    socket = IO.io('https://emergency-io.herokuapp.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
    print(socket!.connected.toString());
    socket!.on("connect_error", (data) => print('connect_error: ' + data));
  }

  void initState() {
    super.initState();

    initSocket();
    initLocation(context);

    print('after init');

    socket!.onDisconnect((_) {
      print('disconnect');
    });

    socket!.on('emergency', (emergencyData) {
      getCurrentStaticLocation().then((data) {
        print(['here', data[0], data[1]]);

        socket!.disconnect();
        print(data);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Map(data[0], data[1], emergencyData[0], emergencyData[1]),
          ),
          (Route<dynamic> route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF1b3b56),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(),
              (widget.flag == 1)
                  ? RippleAnimation(
                      repeat: true,
                      color: Colors.teal.shade500,
                      minRadius: 200,
                      ripplesCount: 6,
                      duration: dur,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget.flag = 0;
                            socket!.disconnect();
                            print(socket!.connected.toString());
                          });
                        },
                        child: Container(
                            width: 150,
                            height: 150,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Icon(
                              Icons.stop,
                              color: Color(0xFF1E415F),
                              size: 90,
                            )),
                        style: ElevatedButton.styleFrom(
                            shape: CircleBorder(), primary: Color(0xFF1DA8AC)),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.flag = 1;
                          socket!.connect();
                          print(socket!.connected.toString());
                          getCurrentStaticLocation().then((value) => socket!
                              .emit('coordinates', [value[0], value[1]]));

                          print('sent');
                        });
                      },
                      child: Container(
                          width: 150,
                          height: 150,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Icon(
                            Icons.play_arrow,
                            color: Color(0xFF1E415F),
                            size: 90,
                          )),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), primary: Color(0xFF1DA8AC)),
                    ),
            ]));
  }

  Future<void> getLiveLocation(Location location, BuildContext context) async {
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (widget.flag == 1) {
        socket!.emit('coordinates',
            [currentLocation.latitude, currentLocation.longitude]);
        print('sent');
      }
      print([currentLocation.latitude, currentLocation.longitude]);
    });
  }

  Future<void> initLocation(BuildContext context) async {
    print('called');
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    print(_serviceEnabled);
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    getLiveLocation(location, context);
    print('here');
  }

  Future<List<double?>> getCurrentStaticLocation() async {
    print('here');
    Location location = new Location();
    LocationData _locationData = await location.getLocation();
    double? srcLat = _locationData.latitude;
    double? srcLong = _locationData.longitude;
    return [srcLat, srcLong];
  }
}
