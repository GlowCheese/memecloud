import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              'https://picsum.photos/200/200?random=20',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Text(
          'Tên bài hát đang phát',
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: const Text(
          'Tên nghệ sĩ',
          style: TextStyle(color: Color(0xFF64B5F6), fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Color(0xFF1976D2)),
              onPressed: () {},
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withAlpha(30),
                    spreadRadius: 1,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                onPressed: () {},
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Color(0xFF6E44FF)),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
