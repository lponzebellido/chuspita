import 'package:chuspita/features/export/application/export_file.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class ExportShareService {
  Future<void> share(ExportFile file, {Rect? sharePositionOrigin});
}

final class NativeExportShareService implements ExportShareService {
  const NativeExportShareService();

  @override
  Future<void> share(ExportFile file, {Rect? sharePositionOrigin}) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(file.bytes, mimeType: file.mimeType)],
        fileNameOverrides: [file.fileName],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}
