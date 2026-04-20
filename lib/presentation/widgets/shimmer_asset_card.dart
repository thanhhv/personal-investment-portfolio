import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';

class ShimmerAssetCard extends StatelessWidget {
  const ShimmerAssetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: context.isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
