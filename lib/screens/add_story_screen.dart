import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../providers/story_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/location_data.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  LocationData? _selectedLocation;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await context.pushNamed('home-location-picker');
    if (result is LocationData) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _uploadStory() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) return;
    setState(() => _isLoading = true);
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    try {
      await storyProvider.addStory(
        sessionProvider.token!,
        _descController.text,
        _imageFile!,
        lat: _selectedLocation?.lat,
        lon: _selectedLocation?.lon,
      );
      if (mounted) {
        context.goNamed('home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story uploaded successfully!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('add_story'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child:
                    _imageFile == null
                        ? Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 60),
                        )
                        : Image.file(
                          _imageFile!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Location Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Location (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_selectedLocation != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Location selected:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedLocation!.address.isNotEmpty 
                                    ? _selectedLocation!.address 
                                    : 'Lat: ${_selectedLocation!.lat.toStringAsFixed(4)}, Lon: ${_selectedLocation!.lon.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickLocation,
                                icon: const Icon(Icons.edit_location),
                                label: const Text('Change Location'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedLocation = null;
                                  });
                                },
                                icon: const Icon(Icons.clear),
                                label: const Text('Remove'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Text(
                          'Add your current location or pick a location on the map to make your story more engaging.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _pickLocation,
                            icon: const Icon(Icons.add_location),
                            label: const Text('Add Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: loc.translate('description'),
                  border: const OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        v == null || v.isEmpty ? 'Description required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadStory,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(loc.translate('upload')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
