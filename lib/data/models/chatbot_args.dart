import 'dart:typed_data';
import 'package:eco/data/models/scan_result_model.dart';

class ChatbotArgs {
  final String? sessionId;
  final ScanResultModel? scanContext;
  final Uint8List? localImageBytes;
  final String? initialMessage;

  const ChatbotArgs({
    this.sessionId,
    this.scanContext,
    this.localImageBytes,
    this.initialMessage,
  });
}
