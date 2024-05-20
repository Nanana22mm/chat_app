import 'package:voice_chat_app/features/talkroom/domain/message_type_constants.dart';

class Message {
  // private
  String? _messageId;
  final String _idFrom;
  final String _idTo;
  final String _createdAt; // the time the message was sent
  int? _type; // voice, text, image, or video
  String? _body; // the content of the text
  String? _voiceUrl;
  String? _voiceText;
  List<String>? _imageUrls;
  String? _videoUrl;
  int _readCount = 0; // whether the message is already read by reciever or not
  bool _showIcon =
      true; // if the time the message was sent were same, omit icon

  Message({
    String? messageId,
    required String idFrom,
    required String idTo,
    required String createdAt,
    int? type,
    String? body,
    String? voiceUrl,
    String? voiceText,
    List<String>? imageUrls,
    String? videoUrl,
    int readCount = 0,
    bool showIcon = true,
  })  : _messageId = messageId,
        _idFrom = idFrom,
        _idTo = idTo,
        _createdAt = createdAt,
        _type = type,
        _body = body,
        _voiceUrl = voiceUrl,
        _voiceText = voiceText,
        _imageUrls = imageUrls,
        _videoUrl = videoUrl,
        _readCount = readCount,
        _showIcon = showIcon;

  Message deepCopy() {
    return Message(
      messageId: _messageId,
      idFrom: _idFrom,
      idTo: _idTo,
      createdAt: _createdAt,
      type: _type,
      body: _body,
      voiceUrl: _voiceUrl,
      voiceText: _voiceText,
      imageUrls: _imageUrls != null ? List<String>.from(_imageUrls!) : null,
      videoUrl: _videoUrl,
      readCount: _readCount,
      showIcon: _showIcon,
    );
  }

  // Getter
  List<Object?> get message => [
        _messageId,
        _idFrom,
        _idTo,
        _createdAt,
        _type,
        _body,
        _voiceUrl,
        _voiceText,
        _imageUrls,
        _videoUrl,
        _readCount,
        _showIcon,
      ];

  // Setter
  set messageId(String messageId) {
    //set roomId only when roomId is null
    if (_messageId == null && messageId.trim().isNotEmpty) {
      _messageId = messageId;
    } else if (_messageId != null) {
      throw Exception('messageId should not be changed after initialization');
    } else {
      throw Exception('messageId must not be empty');
    }
  }

  set showIcon(bool trueOrFalse) {
    _showIcon = trueOrFalse;
  }

  set readCount(int count) {
    if (count < 0) {
      throw Exception('Error: readCount must be a positive number');
    }
    _readCount = count;
  }

  // return Error if the number except for the defined constants
  set type(int type) {
    if (type == MessageTypeConstants.voice ||
        type == MessageTypeConstants.text ||
        type == MessageTypeConstants.image ||
        type == MessageTypeConstants.video) {
      _type = type;
    } else {
      throw Exception('Error: The argument is wrong');
    }
  }

  set body(String body) {
    if (_type == null) {
      throw Exception('Error: type is null');
    } else if (_type != MessageTypeConstants.text) {
      throw Exception('Error: type is wrong');
    } else if (body.trim().isEmpty) {
      throw Exception('Error: String body is empty');
    } else {
      _body = body;
      _voiceUrl = null;
      _imageUrls = null;
      _videoUrl = null;
      _voiceText = null;
    }
  }

  set voiceUrl(String voiceUrl) {
    if (_type == null) {
      throw Exception('Error: type is null');
    } else if (_type != MessageTypeConstants.voice) {
      throw Exception('Error: type is wrong');
    } else if (voiceUrl.trim().isEmpty) {
      throw Exception('Error: String voiceUrl is empty');
    } else {
      _voiceUrl = voiceUrl;
      _body = null;
      _imageUrls = null;
      _videoUrl = null;
    }
  }

  set voiceText(String voiceText) {
    if (_type == null) {
      throw Exception('Error: type is null');
    } else if (_type != MessageTypeConstants.voice) {
      throw Exception('Error: type is wrong');
    } else if (voiceText.trim().isEmpty) {
      throw Exception('Error: String voiceText is empty');
    } else {
      _voiceText = voiceText;
      _body = null;
      _imageUrls = null;
      _videoUrl = null;
    }
  }

  set imageUrls(List<String> imageUrls) {
    if (_type == null) {
      throw Exception('Error: type is null');
    } else if (_type != MessageTypeConstants.image) {
      throw Exception('Error: type is wrong');
    } else if (imageUrls.isEmpty) {
      throw Exception('Error: List<String> imageUrls is empty');
    } else {
      _imageUrls = imageUrls;
      _body = null;
      _voiceUrl = null;
      _videoUrl = null;
      _voiceText = null;
    }
  }

  set videoUrl(String videoUrl) {
    if (_type == null) {
      throw Exception('Error: type is null');
    } else if (_type != MessageTypeConstants.video) {
      throw Exception('Error: type is wrong');
    } else if (videoUrl.trim().isEmpty) {
      throw Exception('Error: String videoUrl is empty');
    } else {
      _videoUrl = videoUrl;
      _body = null;
      _voiceUrl = null;
      _imageUrls = null;
      _voiceText = null;
    }
  }

  factory Message.fromMap(Map<String, dynamic> data) {
    final messageId = data['messageId'] as String?;
    final idFrom = data['idFrom'] as String;
    final idTo = data['idTo'] as String;
    final createdAt = data['createdAt'] as String;
    final type = data['type'] as int? ?? null;
    final body = data['body'] as String? ?? null;
    final voiceUrl = data['voiceUrl'] as String? ?? null;
    final voiceText = data['voiceText'] as String? ?? null;
    final imageUrls =
        (data['imageUrls'] as List?)?.map((item) => item as String).toList();
    final videoUrl = data['videoUrl'] as String? ?? null;
    final readCount = data['readCount'] as int? ?? 0;
    bool showIcon = true; // initial value

    return Message(
      messageId: messageId,
      idFrom: idFrom,
      idTo: idTo,
      createdAt: createdAt,
      type: type,
      body: body,
      voiceUrl: voiceUrl,
      voiceText: voiceText,
      imageUrls: imageUrls,
      videoUrl: videoUrl,
      readCount: readCount,
      showIcon: showIcon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': _messageId,
      'idFrom': _idFrom,
      'idTo': _idTo,
      'createdAt': _createdAt,
      'type': _type,
      'body': _body,
      'voiceUrl': _voiceUrl,
      'voiceText': _voiceText,
      'imageUrls': _imageUrls,
      'videoUrl': _videoUrl,
      'readCount': _readCount,
    };
  }
}
