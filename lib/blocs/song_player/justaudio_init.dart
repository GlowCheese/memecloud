import 'package:just_audio_background/just_audio_background.dart';

Future<void> justAudioInit() async {
  await justAudioBackgroundInit();
}

Future<void> justAudioBackgroundInit() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.memecloud.audio',
    androidNotificationChannelName: 'memeCloud Audio Playback',
    androidNotificationOngoing: true,
  );
}