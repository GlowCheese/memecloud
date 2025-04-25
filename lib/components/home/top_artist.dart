import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TopArtistsSection extends StatelessWidget {
  const TopArtistsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> artists = [
      {'name': 'Nghệ sĩ A', 'image': 'https://picsum.photos/200/200?random=1'},
      {'name': 'Nghệ sĩ B', 'image': 'https://picsum.photos/200/200?random=2'},
      {'name': 'Nghệ sĩ C', 'image': 'https://picsum.photos/200/200?random=3'},
      {'name': 'Nghệ sĩ D', 'image': 'https://picsum.photos/200/200?random=4'},
      {'name': 'Nghệ sĩ E', 'image': 'https://picsum.photos/200/200?random=5'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nghệ sĩ nổi bật',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: artists.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2196F3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: artists[index]['image']!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      artists[index]['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
