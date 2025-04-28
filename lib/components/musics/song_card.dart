import 'package:flutter/material.dart';
import 'package:memecloud/models/song_model.dart';

class SongCard extends StatelessWidget {
  final SongModel song;
  final int variationType;
  
  const SongCard._(this.song, this.variationType);

  factory SongCard.variation1(SongModel song) {
    return SongCard._(song, 1);
  }

  @override
  Widget build(BuildContext context) {
    switch(variationType) {
      case 1:
        return _buildVariation1();
      case 2:
        return _buildVariation2();
      default:
        throw ArgumentError('Unexpected variationType: $variationType', 'variationType');
    }
  }

  Widget _buildVariation1() {
    return Placeholder();
  }

  Widget _buildVariation2() {
    return Placeholder();
  }
}