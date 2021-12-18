import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:maps_toolkit/maps_toolkit.dart' as map;

class ZoneMap extends StatefulWidget {
  @override
  State<ZoneMap> createState() => ZoneMapState();
}

class ZoneMapState extends State<ZoneMap> {
  Completer<GoogleMapController> _controller = Completer();

  final polygons = <Polygon>{};
  final polygonArea1 = [ [ -99.1638816, 19.4638269 ], [ -99.1793311, 19.4230352 ], [ -99.1721213, 19.4524969 ], [ -99.2002738, 19.4557341 ], [ -99.2198432, 19.4369573 ], [ -99.2414725, 19.4100834 ], [ -99.2438758, 19.3916252 ], [ -99.2301429, 19.3741365 ], [ -99.21641, 19.3592373 ], [ -99.1958106, 19.3864435 ], [ -99.1927207, 19.3663632 ], [ -99.2119468, 19.3530829 ], [ -99.2043937, 19.3446606 ], [ -99.193064, 19.3326744 ], [ -99.1889441, 19.3090234 ], [ -99.1539252, 19.2983307 ], [ -99.139849, 19.3099954 ], [ -99.0880072, 19.3216593 ], [ -99.095217, 19.3466043 ], [ -99.0608847, 19.3585895 ], [ -99.0608847, 19.3900059 ], [ -99.0567649, 19.4084643 ], [ -99.0519584, 19.4330722 ], [ -99.0231192, 19.4887501 ], [ -99.0135062, 19.5418204 ], [ -99.0238059, 19.570937 ], [ -99.0588248, 19.5482912 ], [ -99.0794242, 19.5521736 ], [ -99.0993369, 19.4816295 ], [ -99.1089499, 19.4842189 ], [ -99.1055167, 19.4991066 ], [ -99.1027701, 19.5230536 ], [ -99.1206229, 19.539232 ], [ -99.1412223, 19.5379378 ], [ -99.1968406, 19.5508795 ], [ -99.2373526, 19.513993 ], [ -99.2421592, 19.4602661 ], [ -99.2112601, 19.4874554 ], [ -99.1851676, 19.4783928 ], [ -99.1638816, 19.4638269 ] ];
  final polygonArea2 = [ [ -99.1828104, 19.3959295 ], [ -99.1793771, 19.365162 ], [ -99.1584345, 19.3509098 ], [ -99.1282221, 19.3535012 ], [ -99.1110559, 19.3810323 ], [ -99.096293, 19.3981964 ], [ -99.1347452, 19.394958 ], [ -99.1368051, 19.4033776 ], [ -99.1254755, 19.4033776 ], [ -99.1244455, 19.4111492 ], [ -99.1086527, 19.4079111 ], [ -99.098353, 19.4075873 ], [ -99.0980097, 19.4169776 ], [ -99.0942331, 19.4208631 ], [ -99.1100259, 19.4276625 ], [ -99.1306253, 19.4292814 ], [ -99.1340585, 19.4079111 ], [ -99.1447015, 19.4056444 ], [ -99.1429849, 19.3884811 ], [ -99.1285654, 19.3810323 ], [ -99.1405817, 19.3739071 ], [ -99.1567178, 19.3800607 ], [ -99.1567178, 19.4069396 ], [ -99.152598, 19.4208631 ], [ -99.161181, 19.4231296 ], [ -99.1814371, 19.4134158 ], [ -99.1828104, 19.3959295 ] ];
  
  Set<Marker> _markers = {};

  LatLng? userLocation;
  String zone = "";
  
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_){
      init();
    });    
  }

  Set<Polygon> myPoligons(){
   polygons.add(Polygon(
        polygonId: PolygonId("Area1"), points: getPoints(polygonArea1), fillColor: Colors.black.withAlpha(75), strokeWidth: 4)
      );
      polygons.add(
        Polygon(polygonId: PolygonId("Area2"), points: getPoints(polygonArea2), fillColor: Colors.black.withAlpha(75), strokeWidth: 4)
      );
    return polygons;
  }

  void init(){
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Permiso de ubicación"),
            content: Text("1.- Podrá utilizar su ubicación para conocer en que área esta\n2.- De no ser posible acceder a su ubicación podrá elegir cualquier área de desee\n3.- Para cambiar ubicación mantenga presionado el marcador y podrá moverse"),
            actions:<Widget>[
              TextButton(
            child: Text("Aceptar"),
            onPressed: () {
              Navigator.of(context).pop();
            }),
            ] 
          );
        }
      );
  }

  Future<void> userLocationMarker(LatLng position) async {
      setState(() {
        userLocation = position;
      });
      Marker userMarker = Marker(
        markerId: MarkerId('2'), 
        infoWindow: InfoWindow(title: "Mi ubicación"),

        icon: BitmapDescriptor.defaultMarkerWithHue(240), 
        position: userLocation!,
        draggable: true,
            onDragEnd: (dragEndPosition){
              print(dragEndPosition);
              zoneName(dragEndPosition);
                showDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(Duration(seconds: 1), () {
                      Navigator.of(context).pop(true);
                    });
                    return AlertDialog(
                      title: Text(zone),
                    );
                  }
                );
            }
      );
      setState(() {
        _markers.add(userMarker);
      });
      zoneName(userLocation!);
      var _googleMapController = await _controller.future;
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17
          )
        )
      );
  }


  List<LatLng> getPoints(List<List<double>> polygon) {
    var result = <LatLng>[];
    
    for (var point in polygon) {
      result.add(LatLng(point[1], point[0]));
    }
    
    return result;
  }

 
  bool inside(List<double> point, List<List<double>> polygon) {

    var mpPoint = map.LatLng(point[0], point[1]);
    var mpPolygon = <map.LatLng>[];

    for (var item in polygon) {
      mpPolygon.add(map.LatLng(item[1], item[0]));
    }

    return map.PolygonUtil.containsLocation(mpPoint, mpPolygon, false);
  }

  Future<void> getLocation() async {
    try {
      final position = await _getUserPosition();
      userLocationMarker(LatLng(position.latitude, position.longitude));
    } catch (e) {
      print(e);
    }
  }

  Future<Position> _getUserPosition() async {
    return await Geolocator.getCurrentPosition();
  }

   String zoneName(LatLng _userLocation){
 
    if(inside([_userLocation.latitude, _userLocation.longitude], polygonArea2)) {
      zone= "Área 2";
      showDialogUserLocation(zone);
    }
    else if(inside([_userLocation.latitude, _userLocation.longitude], polygonArea1)) {
      zone= "Área 1";
      showDialogUserLocation(zone);
    }
    else {
      zone = "Fuera de zona";
      showDialogUserLocation(zone);
    }
    return zone;

  }

  Future showDialogUserLocation(String zone){
    return showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop(true);
        });
        return AlertDialog(
          title: Text(zone),
        );
      }
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      
      appBar: AppBar(
        title: Text("Ubicación de área"),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(19.350771, -99.139403),
          zoom: 14.4746,
        ),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
        },
        polygons: myPoligons(),
        markers: _markers,
        onTap: (_userLocation) {
          Marker tapMarker = Marker(
            markerId: MarkerId('1'), 
            icon: BitmapDescriptor.defaultMarker, 
            position: _userLocation,
            infoWindow: InfoWindow(title: "Área seleccionada"),
            draggable: true,
            onDragEnd: (dragEndPosition){
              print(dragEndPosition);
              zoneName(dragEndPosition);
                showDialogUserLocation(zone);
            },
            
          );
          setState(() {
            _markers.add(tapMarker);
          });
          zoneName(_userLocation);
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 40),
        child: FloatingActionButton.small(
          backgroundColor: Colors.white,
          onPressed: () async {
            await getLocation();
          },
          child: Icon(Icons.my_location, color: Colors.black,),
          shape: RoundedRectangleBorder(),
        ),
      ),
      
    );
  }

}