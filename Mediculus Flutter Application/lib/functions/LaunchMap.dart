import 'package:map_launcher/map_launcher.dart';

Future<void> launchMap(srcLat, srcLong, dstLat, dstLong) async {
  var x = await MapLauncher.isMapAvailable(MapType.google);
  if (x == true) {
    await MapLauncher.showDirections(
        mapType: MapType.google,
        origin: Coords(srcLat, srcLong),
        destination: Coords(dstLat, dstLong));
  }
}
