import 'dart:typed_data';

final class ExportFile {
  ExportFile({
    required this.fileName,
    required this.mimeType,
    required List<int> bytes,
  }) : bytes = Uint8List.fromList(bytes) {
    if (fileName.trim().isEmpty) {
      throw ArgumentError.value(fileName, 'fileName', 'Cannot be empty');
    }

    if (mimeType.trim().isEmpty) {
      throw ArgumentError.value(mimeType, 'mimeType', 'Cannot be empty');
    }

    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'Cannot be empty');
    }
  }

  final String fileName;
  final String mimeType;
  final Uint8List bytes;
}
