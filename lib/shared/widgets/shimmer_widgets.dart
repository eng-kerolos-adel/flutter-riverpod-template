import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Base shimmer container — use this to build any skeleton shape.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E2433) : const Color(0xFFE5E7EB),
      highlightColor: isDark ? const Color(0xFF2A3347) : const Color(0xFFF9FAFB),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for a post card.
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 120, height: 14),
                  const SizedBox(height: 6),
                  ShimmerBox(width: 80, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShimmerBox(width: double.infinity, height: 18),
          const SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 14),
          const SizedBox(height: 4),
          ShimmerBox(width: 200, height: 14),
          const SizedBox(height: 16),
          ShimmerBox(width: double.infinity, height: 180, borderRadius: 12),
        ],
      ),
    );
  }
}

/// A list of [PostCardSkeleton] for loading states.
class PostListSkeleton extends StatelessWidget {
  const PostListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) => const PostCardSkeleton(),
    );
  }
}

/// Skeleton for a profile header.
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ShimmerBox(width: 90, height: 90, borderRadius: 45),
          const SizedBox(height: 16),
          ShimmerBox(width: 160, height: 20),
          const SizedBox(height: 8),
          ShimmerBox(width: 120, height: 14),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                ShimmerBox(width: 60, height: 24),
                const SizedBox(height: 4),
                ShimmerBox(width: 40, height: 12),
              ]),
              Column(children: [
                ShimmerBox(width: 60, height: 24),
                const SizedBox(height: 4),
                ShimmerBox(width: 40, height: 12),
              ]),
              Column(children: [
                ShimmerBox(width: 60, height: 24),
                const SizedBox(height: 4),
                ShimmerBox(width: 40, height: 12),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
