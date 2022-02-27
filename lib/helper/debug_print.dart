import 'package:flutter/foundation.dart' show debugPrint;

void devPrint(String message) {
  const LOG_CHANNEL = '[ICNNSOFT]';
  debugPrint('$LOG_CHANNEL $message');
}
