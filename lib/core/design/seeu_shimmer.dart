import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'tokens.dart';

class SeeUShimmer extends StatelessWidget {
  final Widget child;

  const SeeUShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: SeeUColors.surface,
      highlightColor: SeeUColors.surfaceElevated,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: SeeUColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
