import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  final double radius;
  final Color color;

  const CustomTabIndicator({this.radius = 4, required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomPainter(radius: radius, color: color);
  }
}

class _CustomPainter extends BoxPainter {
  final double radius;
  final Color color;

  _CustomPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final double width = cfg.size!.width;
    final double height = cfg.size!.height;

    final Offset circleOffset = offset + Offset(width / 2, height - radius);
    canvas.drawCircle(circleOffset, radius, paint);
  }
}

class E14 extends StatefulWidget {
  const E14({super.key});

  @override
  State<E14> createState() => _E14State();
}

class _E14State extends State<E14> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: _tabController,
      indicator: CustomTabIndicator(color: Colors.blue),
      tabs: const [Tab(text: "Home"), Tab(text: "Settings")],
    );
  }
}
