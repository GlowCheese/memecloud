import 'package:flutter/material.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memecloud/models/playlist_model.dart';
import 'package:memecloud/blocs/dl_status/dl_status_enum.dart';
import 'package:memecloud/blocs/dl_status/dl_status_cubit.dart';
import 'package:memecloud/blocs/dl_status/dl_status_state.dart';
import 'package:memecloud/components/miscs/download_button.dart';
import 'package:memecloud/blocs/dl_status/dl_status_manager.dart';

class PlaylistDownloadButton extends StatelessWidget {
  final PlaylistModel playlist;
  final double? iconSize;
  late final DlStatusCubit cubit;

  PlaylistDownloadButton({super.key, required this.playlist, this.iconSize}) {
    cubit = getIt<PlaylistDlStatusManager>().getCubit(playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DlStatusCubit, DlStatusState>(
      bloc: cubit,
      builder: (context, state) {
        double? downloadProgress =
            state is DownloadingState ? state.downloadProgress : null;

        void onPressed() {
          switch (state.status) {
            case DlStatus.notDownloaded:
              fetchDownload(context);
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

        return DownloadButton(
          status: state.status,
          iconSize: iconSize,
          downloadProgress: downloadProgress,
          onPressed: onPressed,
        );
      },
    );
  }

  void fetchDownload(BuildContext context) {
    final songs = getIt<ApiKit>().getUndownloadedSongsInPlaylist(playlist);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Chọn chất lượng nhạc mà bạn muốn tải xuống"),
          actions: [
            for (String quality in ['128', '320', 'lossless'])
              TextButton(
                key: ValueKey(quality),
                child: Text(quality),
                onPressed: () {
                  Navigator.pop(context, true);
                  getIt<ApiKit>().downloadPlaylist(
                    playlist.id,
                    playlist.title,
                    songs,
                    quality,
                  );
                },
              ),
          ],
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
            "Bạn có muốn xóa playlist này khỏi danh sách tải xuống không?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                getIt<ApiKit>().undownloadPlaylist(playlist.id).then((_) {
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
