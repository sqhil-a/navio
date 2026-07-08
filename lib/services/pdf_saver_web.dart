import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

Future<void> savePdfBytes({
  required Uint8List bytes,
  required String filename,
}) async {
  final blob = Blob(
    [bytes.toJS].toJS,
    BlobPropertyBag(type: 'application/pdf'),
  );
  final url = URL.createObjectURL(blob);
  final anchor = HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';

  document.querySelector('body')?.children.add(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(url);
}
