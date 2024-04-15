import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapContainer extends StatefulWidget {
  final LatLng initialLocation;

  const GoogleMapContainer({Key? key, required this.initialLocation})
      : super(key: key);

  @override
  _GoogleMapContainerState createState() => _GoogleMapContainerState();
}

class _GoogleMapContainerState extends State<GoogleMapContainer> {
  late LatLng _vendorLocation;

  @override
  void initState() {
    super.initState();
    _vendorLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _vendorLocation,
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('destinationLocation'),
            icon: BitmapDescriptor.defaultMarker,
            position: _vendorLocation,
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _vendorLocation = newPosition;
              });
            },
          ),
        },
      ),
    );
  }
}
