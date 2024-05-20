import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voice_chat_app/features/talkroom/domain/message.dart';
import 'package:voice_chat_app/features/talkroom/domain/message_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages_repository.g.dart';

@riverpod
MessagesRepository messagesRepository(MessagesRepositoryRef ref) =>
    MessagesRepository(FirebaseFirestore.instance);

class MessagesRepository {
  const MessagesRepository(this._firestore);
  final FirebaseFirestore _firestore;

  // roomType
  // 0: directRooms, 1: groupRooms
  String messagePath(String roomId, String messageId, int roomType) {
    if (roomType == 0) {
      return 'directRooms/$roomId/messages/$messageId';
    } else if (roomType == 1) {
      return 'groupRooms/$roomId/messages/$messageId';
    } else {
      return '';
    }
  }

  String messagesPath(String roomId, int roomType) {
    if (roomType == 0) {
      return 'directRooms/$roomId/messages';
    } else if (roomType == 1) {
      return 'groupRooms/$roomId/messages';
    } else {
      return '';
    }
  }

//calculate whether show Icon
  bool isShowIcon(String firstMessageCreatedAt, String secondMessageCreatedAt) {
    DateTime firstTime = DateTime.parse(firstMessageCreatedAt);
    DateTime secondTime = DateTime.parse(secondMessageCreatedAt);
    int timeDiff = secondTime.difference(firstTime).inMinutes;

    int oneMinute = 1;
    if (timeDiff < oneMinute) {
      return false; // do not show icon
    }
    return true; // show icon
  }

  // create
  Future<void> sendMessage({
    required Message message,
    required String roomId,
    required int roomType,
  }) async {
    // add message
    final messageRef = await _firestore
        .collection(messagesPath(roomId, roomType))
        .add(message.toMap());
    message.messageId = messageRef.id;
    await messageRef.update(message.toMap());
    return Future.value();
  }

  // delete
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
    required int roomType,
  }) async {
    // delete message
    final messageRef = _firestore.doc(messagePath(roomId, messageId, roomType));
    await messageRef.delete();
  }

  Stream<List<Message>> watchMessages(
          {required String roomId, required int roomType}) =>
      queryMessages(roomId: roomId, roomType: roomType)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  Query<Message> queryMessages({
    required String roomId,
    required int roomType,
  }) =>
      _firestore
          .collection(messagesPath(roomId, roomType))
          .orderBy("createdAt", descending: false)
          .withConverter(
            fromFirestore: (snapshot, _) => Message.fromMap(snapshot.data()!),
            toFirestore: (message, _) => message.toMap(),
          );

  Future<List<Message>> fetchMessages(
      {required String roomId, required int roomType}) async {
    final messages =
        await queryMessages(roomId: roomId, roomType: roomType).get();
    final messagesList = messages.docs.map((doc) => doc.data()).toList();
    // because return value is Future<List<Message>>, messagesList is needed

    for (int i = 0; i < messagesList.length; i++) {
      //show icon in the first message
      if (i == 0) {
        messagesList[i].showIcon = true;
      } else {
        String firstMessageCreatedAt =
            (messagesList[i - 1].message[MessageConstants.createdAt] as String);
        String secondMessageCreatedAt =
            (messagesList[i].message[MessageConstants.createdAt] as String);
        messagesList[i].showIcon =
            isShowIcon(firstMessageCreatedAt, secondMessageCreatedAt);
      }
    }
    return messagesList;
  }
}

@riverpod
Query<Message> queryMessages(
    QueryMessagesRef ref, String roomId, int roomType) {
  // TODO: query only when the user join the room
  // check this on the server side ?
  return ref
      .watch(messagesRepositoryProvider)
      .queryMessages(roomId: roomId, roomType: roomType);
}
