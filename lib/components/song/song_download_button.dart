import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/components/miscs/download_button.dart';

class SongDownloadButton extends StatefulWidget {
  final String songId;
  final double? iconSize;

  const SongDownloadButton({super.key, required this.songId, this.iconSize});

  @override
  State<SongDownloadButton> createState() => _SongDownloadButtonState();
}

class _SongDownloadButtonState extends State<SongDownloadButton> {
  double? downloadProgress;
  late DownloadStatus status =
      (getIt<ApiKit>().isSongDownloaded(widget.songId))
          ? (DownloadStatus.downloaded)
          : (DownloadStatus.notDownloaded);

  void startDownloadProcess() {
    setState(() {
      status = DownloadStatus.fetchingDownload;
      downloadProgress = null;
      unawaited(getIt<ApiKit>().getSongUri(widget.songId).then(onUriReceived));
    });
  }

  void onUriReceived(Uri? uri) {
    setState(() {
      if (uri == null) {
        status = DownloadStatus.notDownloaded;
      } else {
        status = DownloadStatus.downloading;
        unawaited(
          getIt<ApiKit>()
              .downloadSong(
                widget.songId,
                uri.toString(),
                onProgress: onProgress,
              )
              .then((_) => onDownloadComplete()),
        );
      }
    });
  }

  void onProgress(int received, int total) {
    setState(() => downloadProgress = received / total);
  }

  void onDownloadComplete() {
    setState(() => status = DownloadStatus.downloaded);
  }

  void confirmUndownload() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text(
            "Bạn có muốn xóa bài hát này khỏi danh sách tải xuống không?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                getIt<ApiKit>().undownloadSong(widget.songId).then((_) {
                  if (context.mounted) Navigator.pop(context);
                  setState(() => status = DownloadStatus.notDownloaded);
                });
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DownloadButton(
      status: status,
      iconSize: widget.iconSize,
      downloadProgress: downloadProgress,
      onPressed: () {
        switch (status) {
          case DownloadStatus.notDownloaded:
            startDownloadProcess();
            break;
          case DownloadStatus.downloaded:
            confirmUndownload();
            break;
          default:
            break;
        }
      },
    );
  }
}
