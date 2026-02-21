import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:voiceapp/assets/constants.dart';

class AudioCardItem {
  final String time;
  final String url;
  final String title;
  final String category; 

  AudioCardItem({
    required this.time,
    required this.url,
    required this.title,
    required this.category,
  });
}

class AudioCard extends StatelessWidget {
  final String url;
  final String time;
  final String category;
  final String title;

  const AudioCard({
    super.key,
    required this.url,
    required this.title,
    required this.category,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(url),
          fit: BoxFit.cover,
        ),
        border: Border.all(width: 0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Top-right time overlay
          Positioned(
            right: 12,
            top: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(
                time,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Bottom-left info (category + title)
          Positioned(
            bottom: 15,
            left: 13,
            right: 13, // constrain width
            child: Column(
              mainAxisSize: MainAxisSize.min, // important: only take space needed
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.graphic_eq, color: Constants.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category,
                        style: Constants.subHeadingStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
