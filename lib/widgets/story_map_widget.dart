import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../models/story.dart';

class StoryMapWidget extends StatefulWidget {
  final Story story;
  final double height;

  const StoryMapWidget({super.key, required this.story, this.height = 200});

  @override
  State<StoryMapWidget> createState() => _StoryMapWidgetState();
}

class _StoryMapWidgetState extends State<StoryMapWidget> {
  Set<Marker> _markers = {};
  String _address = 'Fetching address...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _createMarker();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    if (widget.story.lat == null || widget.story.lon == null) {
      setState(() {
        _address = 'No location data';
        _isLoading = false;
      });
      return;
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        widget.story.lat!,
        widget.story.lon!,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        setState(() {
          _address = address;
          _isLoading = false;
        });

        // Recreate marker with the new address
        _createMarker();
      } else {
        setState(() {
          _address = 'Address not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Failed to fetch address';
        _isLoading = false;
      });
    }
  }

  void _createMarker() {
    if (widget.story.lat != null && widget.story.lon != null) {
      String snippet = _isLoading ? 'Fetching address...' : _address;

      setState(() {
        _markers = {
          Marker(
            markerId: MarkerId(widget.story.id),
            position: LatLng(widget.story.lat!, widget.story.lon!),
            infoWindow: InfoWindow(
              title: 'Story by ${widget.story.name}',
              snippet: snippet,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        };
      });
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
              Text('No location data', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: widget.height,
                width: constraints.maxWidth,
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _isLoading
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey[600]!,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Fetching address...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _address,
                              style: TextStyle(
                                color: Colors.grey[600], 
                                fontSize: 14,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
