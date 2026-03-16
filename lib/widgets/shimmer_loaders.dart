import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

const _baseColor = Color(0xFF2A2A2A);
const _highlightColor = Color(0xFF3A3A3A);

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer loader for HomeScreen feed — mimics the _AudioCard layout.
class HomeFeedShimmer extends StatelessWidget {
  const HomeFeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _AudioCardShimmer(),
        ),
      ),
    );
  }
}

class _AudioCardShimmer extends StatelessWidget {
  const _AudioCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Header: avatar + name
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const _ShimmerBox(width: 48, height: 48, borderRadius: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _ShimmerBox(width: 120, height: 14),
                    SizedBox(height: 8),
                    _ShimmerBox(width: 80, height: 10),
                  ],
                ),
              ],
            ),
          ),
          // Waveform area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const _ShimmerBox(
              width: double.infinity,
              height: 200,
              borderRadius: 12,
            ),
          ),
          // Title + tags + engagement
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ShimmerBox(width: double.infinity, height: 16),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    _ShimmerBox(width: 60, height: 24, borderRadius: 12),
                    SizedBox(width: 8),
                    _ShimmerBox(width: 60, height: 24, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _ShimmerBox(width: 60, height: 28, borderRadius: 16),
                    _ShimmerBox(width: 60, height: 28, borderRadius: 16),
                    _ShimmerBox(width: 60, height: 28, borderRadius: 16),
                    _ShimmerBox(width: 24, height: 24, borderRadius: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loader for DiscoverScreen search results — mimics the 2-column AudioCard grid.
class DiscoverSearchShimmer extends StatelessWidget {
  const DiscoverSearchShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loader for ProfileScreen header — mimics avatar, name, bio, stats, action buttons.
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      child: Column(
        children: [
          // Avatar
          const Center(
            child: _ShimmerBox(width: 110, height: 110, borderRadius: 55),
          ),
          const SizedBox(height: 16),
          // Username
          const Center(child: _ShimmerBox(width: 140, height: 20)),
          const SizedBox(height: 10),
          // Bio
          const Center(child: _ShimmerBox(width: 200, height: 14)),
          const SizedBox(height: 8),
          // Location
          const Center(child: _ShimmerBox(width: 100, height: 12)),
          const SizedBox(height: 24),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: const [
                Expanded(child: _ShimmerBox(width: double.infinity, height: 42, borderRadius: 8)),
                SizedBox(width: 20),
                Expanded(child: _ShimmerBox(width: double.infinity, height: 42, borderRadius: 8)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatShimmer(),
                _StatShimmer(),
                _StatShimmer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatShimmer extends StatelessWidget {
  const _StatShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ShimmerBox(width: 40, height: 16),
        SizedBox(height: 6),
        _ShimmerBox(width: 70, height: 12),
      ],
    );
  }
}

/// Shimmer loader for ProfileScreen uploads — mimics the _SnippetCard layout.
class ProfileSnippetsShimmer extends StatelessWidget {
  const ProfileSnippetsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _ShimmerBox(width: 140, height: 18),
                _ShimmerBox(width: 20, height: 20, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: _SnippetCardShimmer(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnippetCardShimmer extends StatelessWidget {
  const _SnippetCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _ShimmerBox(width: 44, height: 44, borderRadius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _ShimmerBox(width: 160, height: 14),
                    SizedBox(height: 6),
                    _ShimmerBox(width: 80, height: 10),
                  ],
                ),
              ),
              const _ShimmerBox(width: 70, height: 12),
            ],
          ),
          const SizedBox(height: 14),
          const _ShimmerBox(width: double.infinity, height: 40, borderRadius: 4),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ShimmerBox(width: 30, height: 10),
              _ShimmerBox(width: 30, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
