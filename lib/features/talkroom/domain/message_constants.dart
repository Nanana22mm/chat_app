class MessageConstants {
  static const int messageId = 0;
  static const int idFrom = 1;
  static const int idTo = 2;
  static const int createdAt = 3; // the time the message was sent
  static const int type = 4; // voice, text, image, or video
  static const int body = 5; // the content of the text
  static const int voiceUrl = 6;
  static const int voiceText = 7;
  static const int imageUrls = 8;
  static const int videoUrl = 9;
  static const int readCount =
      10; // whether the message is already read by reciever or not
  static const int showIcon = 11;
}
