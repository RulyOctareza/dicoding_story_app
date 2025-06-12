import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class NetworkImageWithLoader extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  const NetworkImageWithLoader({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: borderRadius != null ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(borderRadius: borderRadius),
      child: Image.network(
        imageUrl,
        fit: fit ?? BoxFit.cover,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          developer.log(
            'Error loading image: $error',
            name: 'NetworkImageWithLoader',
            error: error,
            stackTrace: stackTrace,
          );
          return Container(
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
