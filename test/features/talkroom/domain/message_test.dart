import 'package:flutter_test/flutter_test.dart';
import 'package:voice_chat_app/features/talkroom/domain/message.dart';
import 'package:voice_chat_app/features/talkroom/domain/message_constants.dart';

void main() {
  group('fromMap', () {
    Map<String, dynamic> mockMessage1 = {
      'messageId': '1',
      'idFrom': 'bob',
      'idTo': 'alice',
      'createdAt': '2023-11-06',
      'type': 1,
      'body': 'Hello, World!',
      'voiceUrl': null,
      'voiceText': null,
      'imageUrls': null,
      'videoUrl': null,
      'readCount': 0,
      'showIcon': true,
    };
    test('Message with all properties', () {
      final message = Message.fromMap(mockMessage1);
      final list = mockMessage1.values.toList();
      expect(message.message, list);
    });

    test('readCount is null', () {
      var clonedMessage = Map<String, dynamic>.from(mockMessage1);
      clonedMessage['readCount'] = null;
      final message = Message.fromMap(clonedMessage);
      expect(message.message[MessageConstants.readCount], 0);
    });

    test('showIcon is null', () {
      var clonedMessage = Map<String, dynamic>.from(mockMessage1);
      clonedMessage['showIcon'] = null;
      final message = Message.fromMap(clonedMessage);
      expect(message.message[MessageConstants.showIcon], true);
    });
  });

  group('toMap', () {
    final mockMessage2 = Message(
      messageId: '1',
      idFrom: 'bob',
      idTo: 'alice',
      createdAt: '2023-11-06',
      type: 1,
      body: 'Hello, World!',
      voiceUrl: null,
      voiceText: null,
      imageUrls: null,
      videoUrl: null,
      readCount: 0,
      showIcon: true,
    );
    Map<String, dynamic> mockMessageMap = {
      'messageId': '1',
      'idFrom': 'bob',
      'idTo': 'alice',
      'createdAt': '2023-11-06',
      'type': 1,
      'body': 'Hello, World!',
      'voiceUrl': null,
      'voiceText': null,
      'imageUrls': null,
      'videoUrl': null,
      'readCount': 0,
    };
    test('Message with all properties', () {
      final message = mockMessage2;
      expect(message.toMap(), mockMessageMap);
    });
  });

  group('setter', () {
    final mockMessage3 = Message(
      messageId: null,
      idFrom: 'bob',
      idTo: 'alice',
      createdAt: '2023-11-06',
      type: null,
      body: null,
      voiceUrl: null,
      voiceText: null,
      imageUrls: null,
      videoUrl: null,
      readCount: 0,
      showIcon: true,
    );

    test ('set valid messageId', () {
      final message = mockMessage3.deepCopy();
      message.messageId = '2';
      expect(message.message[MessageConstants.messageId], '2');
    });

    test ('Should throw an exception if messageId is empty', () {
      expect(() => mockMessage3.messageId = '', throwsException);
    });

    test ('Should throw an exception if messageId is already set', () {
      final message = mockMessage3.deepCopy();
      message.messageId = '2';
      expect(() => message.messageId = '3', throwsException);
    });

    test('set valid showIcon', () {
      final message = mockMessage3.deepCopy();
      message.showIcon = false;
      expect(message.message[MessageConstants.showIcon], false);
    });

    test('set valid readCount', () {
      final message = mockMessage3.deepCopy();
      message.readCount = 3;
      expect(message.message[MessageConstants.readCount], 3);
    });

    test('set invalid readCount', () {
      final message = mockMessage3.deepCopy();
      expect(() {
        message.readCount = -1;
      }, throwsA(isA<Exception>()));
    });

    test('set valid type', () {
      final message = mockMessage3.deepCopy();
      message.type = 1;
      expect(message.message[MessageConstants.type], 1);
    });

    test('set invalid type', () {
      final message = mockMessage3.deepCopy();
      expect(() {
        message.type = -1;
      }, throwsA(isA<Exception>()));
    });

    test('set valid body', () {
      final message = mockMessage3.deepCopy();
      message.type = 1;
      message.body = 'Hello, World!';
      expect(message.message[MessageConstants.body], 'Hello, World!');
    });

    test('set invalid body : type is null', () {
      final message = mockMessage3.deepCopy();
      expect(() {
        message.body = 'Hello, World!';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid body : type is wrong', () {
      final message = mockMessage3.deepCopy();
      message.type = 3;
      expect(() {
        message.body = 'Hello, World!';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid body : empty string', () {
      final message = mockMessage3.deepCopy();
      message.type = 1;
      expect(() {
        message.body = '';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid body : space', () {
      final message = mockMessage3.deepCopy();
      message.type = 1;
      expect(() {
        message.body = ' ';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid body : 全角 space', () {
      final message = mockMessage3.deepCopy();
      message.type = 1;
      expect(() {
        message.body = '　';
      }, throwsA(isA<Exception>()));
    });

    test('set valid voiceUrl', () {
      final message = mockMessage3.deepCopy();
      message.type = 0;
      message.voiceUrl = 'https://example.com';
      expect(message.message[MessageConstants.voiceUrl], 'https://example.com');
    });

    test('set invalid voiceUrl : type is null', () {
      final message = mockMessage3.deepCopy();
      expect(() {
        message.voiceUrl = 'https://example.com';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid voiceUrl : type is wrong', () {
      final message = mockMessage3.deepCopy();
      message.type = 3;
      expect(() {
        message.voiceUrl = 'https://example.com';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid voiceUrl : empty string', () {
      final message = mockMessage3.deepCopy();
      message.type = 0;
      expect(() {
        message.voiceUrl = '';
      }, throwsA(isA<Exception>()));
    });

    test('set valid voiceText', () {
      final message = mockMessage3.deepCopy();
      message.type = 0;
      message.voiceText = 'Hello, World!';
      expect(message.message[MessageConstants.voiceText], 'Hello, World!');
    });

    test('set invalid voiceText : type is null', () {
      final message = mockMessage3.deepCopy();
      expect(() {
        message.voiceText = 'Hello, World!';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid voiceText : type is wrong', () {
      final message = mockMessage3.deepCopy();
      message.type = 3;
      expect(() {
        message.voiceText = 'Hello, World!';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid voiceText : empty string', () {
      final message = mockMessage3.deepCopy();
      message.type = 0;
      expect(() {
        message.voiceText = '';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid VoiceText : space', () {
      final message = mockMessage3.deepCopy();
      message.type = 0;
      expect(() {
        message.voiceText = ' ';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid VoiceText : 全角 space', () {
      final message = mockMessage3.deepCopy();
      message.type = 0;
      expect(() {
        message.voiceText = '　';
      }, throwsA(isA<Exception>()));
    });

    test('set valid videoUrl', () {
      final message = mockMessage3.deepCopy();
      message.type = 3;
      message.videoUrl = 'https://example.com';
      expect(message.message[MessageConstants.videoUrl], 'https://example.com');
    });

    test('set invalid videoUrl : type is null', () {
      final message = mockMessage3.deepCopy();
      expect(() {
        message.videoUrl = 'https://example.com';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid videoUrl : type is wrong', () {
      final message = mockMessage3.deepCopy();
      message.type = 0;
      expect(() {
        message.videoUrl = 'https://example.com';
      }, throwsA(isA<Exception>()));
    });

    test('set invalid videoUrl: empty string', () {
      final message = mockMessage3.deepCopy();
      message.type = 3;
      expect(() {
        message.videoUrl = '';
      }, throwsA(isA<Exception>()));
    });

    test('set valid imageUrls', () {
      final message = mockMessage3.deepCopy();
      message.type = 2;
      message.imageUrls = ['https://example.com'];
      expect(
          message.message[MessageConstants.imageUrls], ['https://example.com']);
    });

    test('set invalid imageUrls : type is null', () {
      final message = mockMessage3.deepCopy();
      expect(() {
        message.imageUrls = ['https://example.com'];
      }, throwsA(isA<Exception>()));
    });

    test('set invalid imageUrls : type is wrong', () {
      final message = mockMessage3.deepCopy();
      message.type = 0;
      expect(() {
        message.imageUrls = ['https://example.com'];
      }, throwsA(isA<Exception>()));
    });

    test('set invalid imageUrls : empty list', () {
      final message = mockMessage3.deepCopy();
      message.type = 2;
      expect(() {
        message.imageUrls = [];
      }, throwsA(isA<Exception>()));
    });
  });
}
