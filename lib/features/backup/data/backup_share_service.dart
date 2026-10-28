import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class BackupShareService {
  Future<void> share(File file, {Rect? sharePositionOrigin});
}

final class NativeBackupShareService implements BackupShareService {
  const NativeBackupShareService();

  @override
  Future<void> share(File file, {Rect? sharePositionOrigin}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/vnd.sqlite3')],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}
