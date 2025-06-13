import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SafeGoogleMap extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final void Function(GoogleMapController)? onMapCreated;
  final void Function(LatLng)? onTap;
  final bool myLocationButtonEnabled;
  final bool myLocationEnabled;
  final MapType mapType;
  final bool compassEnabled;
  final bool zoomControlsEnabled;

  const SafeGoogleMap({
    super.key,
    required this.initialCameraPosition,
    this.markers = const {},
    this.onMapCreated,
    this.onTap,
    this.myLocationButtonEnabled = false,
    this.myLocationEnabled = false,
    this.mapType = MapType.normal,
    this.compassEnabled = true,
    this.zoomControlsEnabled = true,
  });

  @override
  State<SafeGoogleMap> createState() => _SafeGoogleMapState();
}

class _SafeGoogleMapState extends State<SafeGoogleMap> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.map_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Map unavailable',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'There was an issue loading the map',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    try {
      return GoogleMap(
        initialCameraPosition: widget.initialCameraPosition,
        markers: widget.markers,
        onMapCreated: (controller) {
          try {
            widget.onMapCreated?.call(controller);
          } catch (e) {
            setState(() {
              _hasError = true;
            });
          }
        },
        onTap: widget.onTap,
        myLocationButtonEnabled: widget.myLocationButtonEnabled,
        myLocationEnabled: widget.myLocationEnabled,
        mapType: widget.mapType,
        compassEnabled: widget.compassEnabled,
        zoomControlsEnabled: widget.zoomControlsEnabled,
      );
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
