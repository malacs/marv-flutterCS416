import 'dart:convert';
import 'dart:typed_data';

class LocalMeshMessage {
  final String type;
  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final int timestamp;
  final int hopCount;

  const LocalMeshMessage({
    this.type = 'chat',
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.hopCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp,
      'hopCount': hopCount,
    };
  }

  factory LocalMeshMessage.fromJson(Map<String, dynamic> json) {
    return LocalMeshMessage(
      type: json['type'] as String? ?? 'chat',
      messageId: json['messageId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'Unknown Device',
      content: json['content'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      hopCount: (json['hopCount'] as num?)?.toInt() ?? 0,
    );
  }

  Uint8List toUtf8Bytes() {
    final jsonStr = jsonEncode(toJson());
    return Uint8List.fromList(utf8.encode(jsonStr));
  }

  static LocalMeshMessage? fromUtf8Bytes(Uint8List bytes) {
    try {
      final jsonStr = utf8.decode(bytes);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return LocalMeshMessage.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  LocalMeshMessage incrementHop() {
    return LocalMeshMessage(
      type: type,
      messageId: messageId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: timestamp,
      hopCount: hopCount + 1,
    );
  }
}
