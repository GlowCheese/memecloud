import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ArtistBio extends StatelessWidget {
  final String realName;
  final String bio;

  const ArtistBio({super.key, required this.realName, required this.bio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tên thật',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(realName, style: Theme.of(context).textTheme.bodyLarge),

        Divider(color: Theme.of(context).dividerColor, thickness: 0.5),
        const SizedBox(height: 4),
        Text(
          'Tiểu sử',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Html(data: bio.isNotEmpty ? bio : 'Chưa có thông tin tiểu sử.'),
      ],
    );
  }
}
