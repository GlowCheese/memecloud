import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class E01 extends StatelessWidget {
  const E01({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [
        Container(color: Colors.red),
        Container(color: Colors.blue),
        Container(color: Colors.green),
      ],
      options: CarouselOptions(
        height: 400,
        enlargeCenterPage: true,
        autoPlay: false,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        initialPage: 0,
      ),
    );
  }
}