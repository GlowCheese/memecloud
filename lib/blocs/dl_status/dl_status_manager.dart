import 'package:async/async.dart';
import 'package:memecloud/core/getit.dart';
import 'package:memecloud/apis/apikit.dart';
import 'package:memecloud/blocs/dl_status/dl_status_cubit.dart';
import 'package:memecloud/blocs/dl_status/dl_status_state.dart';

class DlStatusManager {
  bool Function(String id) isDownloadedCheck;
  Map<String, DlStatusCubit> dlStatusCubitMap = {};

  DlStatusManager({required this.isDownloadedCheck});

  DlStatusCubit getCubit(String id) {
    return dlStatusCubitMap[id] ??= DlStatusCubit(
      isDownloadedCheck(id) ? DownloadedState() : NotDownloadedState(),
    );
  }

  void updateState(
    String id, {
    bool isFetching = false,
    bool isCompleted = false,
    CancelableOperation<bool>? downloadTask,
  }) {
    final cubit = dlStatusCubitMap[id];

    if (isCompleted) {
      cubit?.update(DownloadedState());
    } else if (isFetching) {
      cubit?.update(FetchingDownloadState());
    } else if (downloadTask != null) {
      cubit?.update(DownloadingState(0), downloadTask: downloadTask);
    }
  }

  void updateProgress(String id, double downloadProgress) {
    dlStatusCubitMap[id]?.updateProgress(downloadProgress);
  }

  Future<void> cancelDownload(String id) async {
    dlStatusCubitMap[id]?.updateCancel();
  }
}

class SongDlStatusManager extends DlStatusManager {
  SongDlStatusManager()
    : super(isDownloadedCheck: getIt<ApiKit>().isSongDownloaded);
}

class PlaylistDlStatusManager extends DlStatusManager {
  PlaylistDlStatusManager()
    : super(isDownloadedCheck: getIt<ApiKit>().isPlaylistDownloaded);

  bool hasPlaylistInDownload() {
    return dlStatusCubitMap.values.any(
      (cubit) => cubit.state is DownloadingState,
    );
  }
}
