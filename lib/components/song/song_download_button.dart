import 'dart:async';
import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/apis/zingmp3/endpoints.dart';
import 'package:memecloud/components/miscs/download_button.dart';

class SongDownloadButton extends StatefulWidget {
  final SongModel song;
  final double? iconSize;

  const SongDownloadButton({super.key, required this.song, this.iconSize});

  @override
  State<SongDownloadButton> createState() => _SongDownloadButtonState();
}

class _SongDownloadButtonState extends State<SongDownloadButton> {
  double? downloadProgress;
  late DownloadStatus status =
      (getIt<ApiKit>().isSongDownloaded(widget.song.id))
          ? (DownloadStatus.downloaded)
          : (DownloadStatus.notDownloaded);

  void fetchDownloadUrls() {
    setState(() {
      status = DownloadStatus.fetchingDownload;
      downloadProgress = null;
      unawaited(
        getIt<ZingMp3Api>()
            .fetchSongUrls(widget.song.id)
            .then(onUrlsReceived)
            .catchError((e, stackTrace) {
              setState(() => status = DownloadStatus.notDownloaded);
            }),
      );
    });
  }

  void onUrlsReceived(Map<String, String> urls) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text(
            "Chọn chất lượng nhac mà bạn muốn tải xuống",
          ),
          actions:
            urls.entries.map((e) {
              return TextButton(
                key: ValueKey(e.key),
                child: Text(e.key),
                onPressed: () {
                  Navigator.pop(context, true);
                  startDownloadProcess(e.value);
                },
              );
            }).toList()
        );
      },
    ).then((data) {
      if (data != true) {
        setState(() => status = DownloadStatus.notDownloaded);
      }
    });
  }

  CancelToken? cancelToken;
  CancelableOperation? downloadTask;

  void startDownloadProcess(String url) {
    cancelToken = CancelToken();

    setState(() {
      status = DownloadStatus.downloading;
      downloadTask = CancelableOperation.fromFuture(
        getIt<ApiKit>()
            .downloadSong(
              widget.song,
              url,
              onProgress: onProgress,
              cancelToken: cancelToken,
            )
            .then((success) {
              if (success) onDownloadComplete();
            })
            .catchError((e, stackTrace) {
              setState(() => status = DownloadStatus.notDownloaded);
            }),
        onCancel: () async {
          cancelToken?.cancel();
          setState(() => status = DownloadStatus.notDownloaded);
        },
      );
    });
  }

  void onProgress(int received, int total) {
    setState(() => downloadProgress = received / total);
  }

  void onDownloadComplete() {
    setState(() => status = DownloadStatus.downloaded);
  }

  void cancelDownload() {
    downloadTask?.cancel();
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
                getIt<ApiKit>().undownloadSong(widget.song.id).then((_) {
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
            fetchDownloadUrls();
            break;
          case DownloadStatus.downloading:
            cancelDownload();
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
