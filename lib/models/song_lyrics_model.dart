import 'dart:io';
import 'package:flutter/foundation.dart';

class LyricLine {
  final String text;
  final Duration time;
  LyricLine({required this.text, required this.time});
}

class SongLyricsModel {
  final List<LyricLine> lyricLines;
  SongLyricsModel._({required this.lyricLines});

  static SongLyricsModel noTimeLine(String lyric) {
    return SongLyricsModel._(lyricLines: [
      LyricLine(text: lyric, time: Duration.zero)
    ]);
  }

  static Future<SongLyricsModel> parse(File file) async {
    final raw = await file.readAsString();

    final lines = raw.split('\n');
    final regex = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\](.*)');
    final result = <LyricLine>[];

    for (final line in lines) {
      final match = regex.firstMatch(line.trim());
      if (match != null) {
        final minute = int.parse(match.group(1)!);
        final second = int.parse(match.group(2)!);
        final millisecond = int.parse(match.group(3) ?? '0');
        final text = match.group(4)?.trim() ?? '';

        final duration = Duration(
          minutes: minute,
          seconds: second,
          milliseconds:
              millisecond.toString().length == 2
                  ? millisecond * 10
                  : millisecond,
        );

        result.add(LyricLine(time: duration, text: text));
      }
    }

    result.sort((a, b) => a.time.compareTo(b.time)); // Sort theo thời gian
    return SongLyricsModel._(lyricLines: result);
  }
}
