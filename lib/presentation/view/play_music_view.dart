import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:memecloud/data/models/song/song_dto.dart';
import 'package:memecloud/presentation/ui/ui_wrapper.dart';



// class MusicPlayerScreen extends StatefulWidget {
//   final SongDto song;

//   const MusicPlayerScreen({super.key, required this.song});

//   @override
//   State<MusicPlayerScreen> createState() => _MusicPlayerScreen();
// }

// class _MusicPlayerScreen extends State<MusicPlayerScreen>
//     with SingleTickerProviderStateMixin {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isPlaying = false;
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//   late AnimationController _rotationController;

//   @override
//   void initState() {
//     super.initState();
//     _initAudioPlayer();
//     _rotationController = AnimationController(
//       duration: const Duration(seconds: 10),
//       vsync: this,
//     )..repeat();
//     _rotationController.stop();
//   }

//   Future<void> _initAudioPlayer() async {
//     try {
//       await _audioPlayer.setUrl(widget.song.url);
//       _audioPlayer.durationStream.listen((duration) {
//         if (duration != null) {
//           setState(() => _duration = duration);
//         }
//       });
//       _audioPlayer.positionStream.listen((position) {
//         setState(() => _position = position);
//       });
//     } catch (e) {
//       debugPrint('Error initializing audio player: $e');
//     }
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return UiWrapper(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         centerTitle: true,
//         title: Text('Now Playing', style: TextStyle(color: Colors.white)),
//         leading: BackButton(
//           onPressed: () {
//             try {
//               context.pop();
//             } catch (e) {
//               context.go('/404');
//             }
//           },
//           color: Colors.white,
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             RotationTransition(
//               turns: _rotationController,
//               child: ClipOval(
//                 child: Image.network(
//                   widget.song.coverUrl,
//                   height: 250,
//                   width: 250,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             Text(
//               widget.song.artist,
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 8),
//             Slider(
//               value: _position.inSeconds.toDouble(),
//               max: _duration.inSeconds.toDouble(),
//               onChanged: (value) {
//                 _audioPlayer.seek(Duration(seconds: value.toInt()));
//               },
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(_formatDuration(_position)),
//                   Text(_formatDuration(_duration)),
//                 ],
//               ),
//             ),
//             IconButton(
//               icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//               iconSize: 48,
//               onPressed: () async {
//                 setState(() {
//                   _isPlaying = !_isPlaying;
//                   if (_isPlaying) {
//                     _rotationController.repeat();
//                   } else {
//                     _rotationController.stop();
//                   }
//                 });
//                 if (_isPlaying) {
//                   await _audioPlayer.play();
//                 } else {
//                   await _audioPlayer.pause();
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: null,
//     );
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     _rotationController.dispose();
//     super.dispose();
//   }
// }
