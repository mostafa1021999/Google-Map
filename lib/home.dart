import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapController =
  Completer<GoogleMapController>();
  GoogleMapController? mapController; //contrller for Google map
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  static const LatLng _pApplePark = LatLng(37.3346, -122.0090);
  LatLng? _currentP = null;
  late BitmapDescriptor imageDelivery;

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  getMarker()async{
    imageDelivery= await BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, 'assets/other.png');
  }
  @override
  void initState() {
    super.initState();
    _addMarker(LatLng(37.4223, -122.0848), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(37.3346, -122.0090), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? const Center(
        child: Text("Loading..."),
      )
          : GoogleMap(
         onMapCreated: (controller) { //method called when map is created
        setState(() {
      mapController = controller;
          });
          },
        initialCameraPosition: const CameraPosition(
          target: _pGooglePlex,
          zoom: 13,
        ),
        myLocationEnabled: true,
        tiltGesturesEnabled: true,
        compassEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.gps_fixed),
        onPressed: (){
                _getLocation();
        },
      ),
    );
  }
  void _getLocation() async {
    LocationData? currentLocation;
    try {
      currentLocation = await _locationController.getLocation();
    } catch (e) {
      print('Error getting location: $e');
    }

    if (currentLocation != null) {
      setState(() {
        _currentP = LatLng(currentLocation!.latitude!, currentLocation.longitude!);
        _cameraToPosition(_currentP!);
      });
    }
  }
  void _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
          setState(() {
            _currentP =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
          });
      }
    });
  }
  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }
  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyBs84inBDcoKMETIdIqd8TpaF6K0G-LMxk',
        PointLatLng(37.4223, -122.0848),
        PointLatLng(37.3346, -122.0090),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}
