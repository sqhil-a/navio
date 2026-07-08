import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

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

Future<PickedPdfFile?> pickPdfFileBytes() {
  final completer = Completer<PickedPdfFile?>();
  final input = HTMLInputElement()
    ..type = 'file'
    ..accept = 'application/pdf,.pdf'
    ..multiple = false;
  input.style.display = 'none';

  StreamSubscription<Event>? changeSubscription;
  StreamSubscription<Event>? readerSubscription;
  EventListener? focusListener;
  Timer? focusSettleTimer;
  Timer? timeoutTimer;
  var canTreatFocusAsCancel = false;
  var isReading = false;

  void complete(PickedPdfFile? file, [Object? error]) {
    if (completer.isCompleted) return;
    changeSubscription?.cancel();
    if (focusListener != null) {
      window.removeEventListener('focus', focusListener);
    }
    readerSubscription?.cancel();
    focusSettleTimer?.cancel();
    timeoutTimer?.cancel();
    input.remove();
    if (error != null) {
      completer.completeError(error);
    } else {
      completer.complete(file);
    }
  }

  changeSubscription = input.onChange.listen((_) {
    final files = input.files;
    if (files == null || files.length < 1) {
      complete(null);
      return;
    }

    final file = files.item(0);
    if (file == null) {
      complete(null);
      return;
    }

    final reader = FileReader();
    isReading = true;

    readerSubscription = reader.onLoadEnd.listen((_) {
      if (reader.error != null) {
        complete(null, StateError('Could not read this PDF.'));
        return;
      }

      final result = (reader.result as JSArrayBuffer?)?.toDart;
      if (result != null) {
        complete(
          PickedPdfFile(
            name: file.name,
            size: file.size,
            bytes: result.asUint8List(),
          ),
        );
      } else {
        complete(null, StateError('Could not read this PDF.'));
      }
    });

    reader.readAsArrayBuffer(file);
  });

  focusListener = ((Event _) {
    if (!canTreatFocusAsCancel || isReading || completer.isCompleted) return;

    focusSettleTimer?.cancel();
    focusSettleTimer = Timer(const Duration(milliseconds: 700), () {
      if (!isReading && !completer.isCompleted) {
        complete(null);
      }
    });
  }).toJS;
  window.addEventListener('focus', focusListener);

  timeoutTimer = Timer(const Duration(seconds: 35), () {
    if (!completer.isCompleted) complete(null);
  });

  document.querySelector('body')?.children.add(input);
  input.click();
  Timer(const Duration(milliseconds: 600), () {
    canTreatFocusAsCancel = true;
  });

  return completer.future;
}
