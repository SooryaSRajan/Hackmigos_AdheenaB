import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MapWidget extends StatelessWidget {
  MapWidget({required this.srcLatLng, required this.dstLatLng});

  final LatLng srcLatLng;
  final LatLng dstLatLng;

  @override
  Widget build(BuildContext context) {
    return new FlutterMap(
      options: new MapOptions(
        bounds: LatLngBounds(srcLatLng, dstLatLng),
        boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(50.0)),
      ),
      layers: [
        new TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        new MarkerLayerOptions(
          markers: [
            new Marker(
              width: 50.0,
              height: 60.0,
              point: srcLatLng,
              builder: (ctx) => new Container(
                child: FaIcon(FontAwesomeIcons.ambulance, color: Colors.green),
              ),
            ),
            new Marker(
              width: 50.0,
              height: 60.0,
              point: dstLatLng,
              builder: (ctx) => new Container(
                child: FaIcon(FontAwesomeIcons.mapMarkerAlt, color: Colors.red),
              ),
            ),
          ],
        ),
        new PolylineLayerOptions()
      ],
    );
  }
}
