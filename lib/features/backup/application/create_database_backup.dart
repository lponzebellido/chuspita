import 'dart:io';

import 'package:chuspita/core/database/app_database.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class DatabaseBackupCreator {
  Future<File> call();
}

final class CreateDatabaseBackup implements DatabaseBackupCreator {
  CreateDatabaseBackup(
    this._database, {
    Future<Directory> Function()? temporaryDirectory,
    DateTime Function()? now,
  }) : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
       _now = now ?? DateTime.now;

  final AppDatabase _database;
  final Future<Directory> Function() _temporaryDirectory;
  final DateTime Function() _now;

  @override
  Future<File> call() async {
    final directory = await _temporaryDirectory();
    final destination = File.fromUri(
      directory.uri.resolve(_fileNameFor(_now())),
    );

    await _database.createBackup(destination);

    return destination;
  }
}

String _fileNameFor(DateTime dateTime) {
  final fraction = dateTime.millisecond * 1000 + dateTime.microsecond;

  return 'chuspita-backup-'
      '${dateTime.year.toString().padLeft(4, '0')}'
      '${dateTime.month.toString().padLeft(2, '0')}'
      '${dateTime.day.toString().padLeft(2, '0')}-'
      '${dateTime.hour.toString().padLeft(2, '0')}'
      '${dateTime.minute.toString().padLeft(2, '0')}'
      '${dateTime.second.toString().padLeft(2, '0')}-'
      '${fraction.toString().padLeft(6, '0')}.sqlite3';
}
