import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import '../models/location_data.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  Set<Marker> _markers = {};
  final loc.Location _location = loc.Location();
  bool _isLoading = false;
  bool _mapError = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      await _getCurrentLocation();
    } catch (e) {
      if (mounted) {
        setState(() {
          _mapError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() => _isLoading = false);
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final locationData = await _location.getLocation();
      final currentLocation = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      
      setState(() {
        _selectedLocation = currentLocation;
        _isLoading = false;
      });
      
      await _updateMarker(currentLocation);
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation, 15),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateMarker(LatLng position) async {
    setState(() => _isLoading = true);
    
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      String address = 'Unknown location';
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        address = [
          placemark.street,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }

      setState(() {
        _selectedLocation = position;
        _selectedAddress = address;
        _markers = {
          Marker(
            markerId: const MarkerId('selected'),
            position: position,
            infoWindow: InfoWindow(
              title: 'Selected Location',
              snippet: address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting address: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _selectedLocation != null ? () {
              final locationData = LocationData(
                lat: _selectedLocation!.latitude,
                lon: _selectedLocation!.longitude,
                address: _selectedAddress,
              );
              context.pop(locationData);
            } : null,
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_mapError)
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-6.2088, 106.8456), // Jakarta default
                zoom: 10,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                try {
                  _controller = controller;
                } catch (e) {
                  setState(() {
                    _mapError = true;
                  });
                }
              },
              onTap: _updateMarker,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              mapType: MapType.normal,
              compassEnabled: true,
              zoomControlsEnabled: false,
            )
          else
            Container(
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
                      'Please try again later',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _mapError = false;
                          _isLoading = true;
                        });
                        _initializeLocation();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Selected location info
          if (_selectedAddress.isNotEmpty && !_isLoading)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Selected Location:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedAddress,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Current location button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
