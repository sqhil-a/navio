import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class PickedPdfFile {
  final String name;
  final int size;
  final Uint8List bytes;

  const PickedPdfFile({
    required this.name,
    required this.size,
    required this.bytes,
  });
}

Future<PickedPdfFile?> pickPdfFileBytes() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['pdf'],
    withData: true,
  );

  if (result == null || result.files.isEmpty) return null;

  final file = result.files.single;
  final bytes = file.bytes;
  if (bytes == null || bytes.isEmpty) return null;

  return PickedPdfFile(name: file.name, size: file.size, bytes: bytes);
}
