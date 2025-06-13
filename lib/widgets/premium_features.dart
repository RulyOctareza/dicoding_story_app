import 'package:flutter/material.dart';

class PremiumFeatureBanner extends StatelessWidget {
  final String featureName;
  final Widget child;
  final VoidCallback? onUpgradePressed;

  const PremiumFeatureBanner({
    super.key,
    required this.featureName,
    required this.child,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class FlavorBadge extends StatelessWidget {
  const FlavorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'FREE',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
