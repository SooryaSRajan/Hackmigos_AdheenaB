import 'package:automated_ambualnce/functions/LaunchMap.dart';
import 'package:flutter/material.dart';
import 'package:automated_ambualnce/ui/MapWidget.dart';
import 'package:latlong2/latlong.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:automated_ambualnce/ui/home.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

num getLocationDistance(srcLat, srcLong, dstLat, dstLong) {
  print([srcLat, srcLong]);
  print([dstLat, dstLong]);
  var distanceInMeters = mp.SphericalUtil.computeDistanceBetween(
      mp.LatLng(srcLat, srcLong), mp.LatLng(dstLat, dstLong));
  return distanceInMeters / 1000;
}

void alert(BuildContext context) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Center(child: const Text('NEW EMERGENCY')),
      content: const Text(
          'An emergency was detected at the following location and medical attention is needed'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

playLocal() async {
  final AudioCache player = AudioCache();
  player.play('siren_f.mp3');
}

class Map extends StatelessWidget {
  static const String id = 'map_screen';

  Map(this.srcLat, this.srcLong, this.dstLat, this.dstLong);

  final double? srcLat;
  final double? srcLong;
  final double dstLat;
  final double dstLong;
  late num distanceInKMs =
      getLocationDistance(srcLat, srcLong, dstLat, dstLong);
  bool done = false;

  void initState() {}

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => alert(context));
    playLocal();
    print('Done');
    return Scaffold(
      body: Scaffold(
        body: Container(
          child: MapWidget(
            srcLatLng: LatLng(srcLat!, srcLong!),
            dstLatLng: LatLng(dstLat, dstLong),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: FloatingActionButton.extended(
                heroTag: "directions",
                onPressed: () {
                  launchMap(srcLat, srcLong, dstLat, dstLong);
                },
                label: Text(
                  'Get Directions',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                backgroundColor: Color(0xFF1b3b56),
              ),
            ),
            SizedBox(width: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: FloatingActionButton.extended(
                heroTag: "completed",
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(flag: 1),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                label: Text(
                  'Completed',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                backgroundColor: Color(0xFF1DA8AC),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 15.0),
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color(0xFF1b3b56),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            distanceInKMs.toStringAsFixed(1) + ' KM',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
