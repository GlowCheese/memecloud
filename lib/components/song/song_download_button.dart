import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/utils/snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/song_model.dart';
import 'package:memecloud/blocs/dl_status/dl_status_enum.dart';
import 'package:memecloud/blocs/dl_status/dl_status_cubit.dart';
import 'package:memecloud/blocs/dl_status/dl_status_state.dart';
import 'package:memecloud/components/miscs/download_button.dart';
import 'package:memecloud/blocs/dl_status/dl_status_manager.dart';

class SongDownloadButton extends StatelessWidget {
  final bool dimmed;
  final SongModel song;
  final double? iconSize;
  late final DlStatusCubit cubit;

  SongDownloadButton({
    super.key,
    required this.song,
    this.iconSize,
    this.dimmed = false,
  }) {
    cubit = getIt<SongDlStatusManager>().getCubit(song.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DlStatusCubit, DlStatusState>(
      bloc: cubit,
      builder: (context, state) {
        double? downloadProgress =
            state is DownloadingState ? state.downloadProgress : null;

        void onPressed() {
          if (getIt<PlaylistDlStatusManager>().hasPlaylistInDownload()) {
            showWarningSnackbar(
              context,
              message: 'Không thể thực hiện thao tác này ngay bây giờ!'
            );
          } else {
            switch (state.status) {
              case DlStatus.notDownloaded:
                fetchDownloadUrls(context);
                break;
              case DlStatus.downloading:
                cubit.updateCancel();
                break;
              case DlStatus.downloaded:
                confirmUndownload(context);
                break;
              default:
                break;
            }
          }
        }

        return Offstage(
          offstage: dimmed && state is NotDownloadedState,
          child: DownloadButton(
            status: state.status,
            iconSize: iconSize,
            downloadProgress: downloadProgress,
            onPressed: onPressed,
          ),
        );
      },
    );
  }

  void fetchDownloadUrls(BuildContext context) {
    getIt<ApiKit>().getSongUrlsForDownload(song.id).then((urls) {
      if (context.mounted) {
        onUrlsReceived(context, urls);
      }
    });
  }

  void onUrlsReceived(BuildContext context, Map<String, String>? urls) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Chọn chất lượng nhạc mà bạn muốn tải xuống"),
          actions:
              urls!.entries.map((e) {
                return TextButton(
                  key: ValueKey(e.key),
                  child: Text(e.key),
                  onPressed: () {
                    Navigator.pop(context, true);
                    getIt<ApiKit>().downloadSong(song, e.value);
                  },
                );
              }).toList(),
        );
      },
    ).then((data) {
      if (data != true) cubit.updateCancel();
    });
  }

  void confirmUndownload(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text(
            "Bạn có muốn xóa bài hát này khỏi danh sách tải xuống không?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                getIt<ApiKit>().undownloadSong(song.id).then((_) {
                  if (context.mounted) Navigator.pop(context);
                });
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
