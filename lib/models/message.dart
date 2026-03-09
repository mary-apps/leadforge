import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum OutreachChannel {
  @JsonValue('email') email,
  @JsonValue('whatsapp') whatsapp,
  @JsonValue('instagram') instagram,
  @JsonValue('phone') phone,
  @JsonValue('other') other,
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String businessId,
    required String userId,
    required OutreachChannel channel,
    @Default('professional') String tone,
    @Default('en') String language,
    required String content,
    DateTime? copiedAt,
    DateTime? markedSentAt,
    required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

extension MessageX on Message {
  bool get wasCopied => copiedAt != null;
  bool get wasSent => markedSentAt != null;
  
  String get channelLabel {
    switch (channel) {
      case OutreachChannel.email:
        return 'Email';
      case OutreachChannel.whatsapp:
        return 'WhatsApp';
      case OutreachChannel.instagram:
        return 'Instagram DM';
      case OutreachChannel.phone:
        return 'Phone Script';
      case OutreachChannel.other:
        return 'Other';
    }
  }
}
