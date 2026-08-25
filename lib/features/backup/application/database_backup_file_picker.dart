import 'dart:io';

abstract interface class DatabaseBackupFilePicker {
  Future<File?> pick();
}
