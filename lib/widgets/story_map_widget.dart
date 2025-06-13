import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/story.dart';

class StoryMapWidget extends StatefulWidget {
  final Story story;
  final double height;

  const StoryMapWidget({
    super.key,
    required this.story,
    this.height = 200,
  });

  @override
  State<StoryMapWidget> createState() => _StoryMapWidgetState();
}

class _StoryMapWidgetState extends State<StoryMapWidget> {
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarker();
  }

  void _createMarker() {
    if (widget.story.lat != null && widget.story.lon != null) {
      _markers = {
        Marker(
          markerId: MarkerId(widget.story.id),
          position: LatLng(widget.story.lat!, widget.story.lon!),
          infoWindow: InfoWindow(
            title: widget.story.name,
            snippet: 'Story location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.story.lat == null || widget.story.lon == null) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No location data',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.story.lat!, widget.story.lon!),
            zoom: 15,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            // Map controller is ready - can be used for future enhancements
          },
          mapType: MapType.normal,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          compassEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
        ),
      ),
    );
  }
}
