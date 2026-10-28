import 'dart:io';

import 'package:chuspita/features/backup/application/database_backup_file_picker.dart';
import 'package:file_selector/file_selector.dart';

final class NativeDatabaseBackupFilePicker implements DatabaseBackupFilePicker {
  const NativeDatabaseBackupFilePicker();

  static const _backupType = XTypeGroup(
    label: 'Chuspita backup',
    extensions: ['sqlite3'],
    mimeTypes: [
      'application/vnd.sqlite3',
      'application/x-sqlite3',
      'application/octet-stream',
    ],
    uniformTypeIdentifiers: ['public.database', 'public.data'],
  );

  @override
  Future<File?> pick() async {
    final selected = await openFile(acceptedTypeGroups: [_backupType]);
    return selected == null ? null : File(selected.path);
  }
}
