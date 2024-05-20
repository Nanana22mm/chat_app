import 'package:flutter_test/flutter_test.dart';
import 'package:voice_chat_app/features/talks/data/talks_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:voice_chat_app/features/talks/domain/talk.dart';
// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/foundation.dart';

void main() {
  late FakeFirebaseFirestore mockFirestore;
  late TalksRepository talksRepository;
  late Talk talk1;
  late String uid;

  Map<String, dynamic> talkMap1 = {
    'roomId': null,
    'iconUrl': 'url',
    'name': 'name',
    'unreadCount': 5,
    'updatedAt': '2023-11-12 12:10:30',
    'roomType': 1,
    'latestMessageType': 2,
  };
  Map<String, dynamic> talkMap2 = {
    'roomId': null,
    'iconUrl': 'url',
    'name': 'name',
    'unreadCount': 5,
    'updatedAt': '2023-11-12 18:10:22',
    'roomType': 2,
    'latestMessageType': 2,
  };
  Map<String, dynamic> talkMap3 = {
    'roomId': null,
    'iconUrl': 'url',
    'name': 'name',
    'unreadCount': 4,
    'updatedAt': '2023-12-12 12:10:30',
    'roomType': 1,
    'latestMessageType': 2,
  };

  setUp(() {
    mockFirestore = FakeFirebaseFirestore();
    talk1 = Talk.fromMap(talkMap1);
    talksRepository = TalksRepository(mockFirestore);
    uid = 'test-uid';
  });

  group('add talk', () {
    test('add talk to empty database', () async {
      // run addTalk
      await talksRepository.addTalk(uid: uid, talk: talk1);

      // check data is added to firestore
      final snapshot =
          await mockFirestore.collection('users/$uid/attendingRooms').get();
      expect(snapshot.docs[0].data(), equals(talk1.toMap()));
    });

    test('add talk to non empty database', () async {
      // add talk to firestore
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap2);

      // run addTalk
      await talksRepository.addTalk(uid: uid, talk: talk1);

      // check data is added to firestore
      final snapshot =
          await mockFirestore.collection('users/$uid/attendingRooms').get();
      expect(snapshot.docs[0].data(), equals(talkMap2));
      expect(snapshot.docs[1].data(), equals(talk1.toMap()));
    });
  });

  group('update talk', () {
    test('update', () async {
      // add talk to firestore
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap3);

      // set document id to talk
      final snapshot1 =
          await mockFirestore.collection('users/$uid/attendingRooms').get();
      talk1.roomId = snapshot1.docs[0].id;

      // run updateTalk
      await talksRepository.updateTalk(uid: uid, talk: talk1);

      // check data is updated
      final snapshot2 =
          await mockFirestore.collection('users/$uid/attendingRooms').get();
      expect(snapshot2.docs[0].data(), equals(talk1.toMap()));
    });
  });

  group('delete talk', () {
    test('delete', () async {
      // add talk to firestore
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap1);

      // set document id to talk
      final snapshot1 =
          await mockFirestore.collection('users/$uid/attendingRooms').get();

      // run deleteTalk
      await talksRepository.deleteTalk(uid: uid, talkId: snapshot1.docs[0].id);

      // check data is deleted
      final snapshot2 =
          await mockFirestore.collection('users/$uid/attendingRooms').get();
      expect(snapshot2.docs.length, 0);
    });
  });

  group('query talk', () {
    test('query from empty database', () async {
      // run queryTalks
      final snapshot = await talksRepository.queryTalks(uid: uid).get();

      // check data is empty
      expect(snapshot.docs.length, 0);
    });

    test('query from database with one entry', () async {
      // add talk to firestore
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap1);

      // run queryTalks
      final snapshot = await talksRepository.queryTalks(uid: uid).get();

      // check data is added to firestore
      expect(snapshot.docs[0].data().toMap(), equals(talkMap1));
    });

    test('query from database with more than one entries', () async {
      // add talk to firestore
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap2);
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap3);
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap1);

      // run queryTalks
      final snapshot = await talksRepository.queryTalks(uid: uid).get();

      // check data is added to firestore
      // data should be sorted by updatedAt in descending order
      expect(snapshot.docs[0].data().toMap(), equals(talkMap3));
      expect(snapshot.docs[1].data().toMap(), equals(talkMap2));
      expect(snapshot.docs[2].data().toMap(), equals(talkMap1));
    });
  });

  group('watch talk', () {
    test('watch the first stream', () async {
      // add talk to firestore
      final convertedDocument = await mockFirestore
          .collection('users/$uid/attendingRooms')
          .doc('test')
          .withConverter<Talk>(
            fromFirestore: (snapshot, _) => Talk.fromMap(snapshot.data()!),
            toFirestore: (talk, _) => talk.toMap(),
          );
      await convertedDocument.set(talk1);

      // run watchTalk
      final stream = talksRepository.watchTalk(uid: uid, talkId: 'test');

      //check the stream
      expectLater(
          stream.first
              .then((value) => {expect(value.toMap(), equals(talkMap1))}),
          completes);
    });

    test('watch the subsequent stream after change data in database', () async {
      // add talk to firestore
      // we need to use converted document reference to set/update data because of the issue of fake_cloud_firestore
      // bug report is here: https://github.com/atn832/fake_cloud_firestore/issues/254
      final convertedDocument = await mockFirestore
          .collection('users/$uid/attendingRooms')
          .doc('test')
          .withConverter<Talk>(
            fromFirestore: (snapshot, _) => Talk.fromMap(snapshot.data()!),
            toFirestore: (talk, _) => talk.toMap(),
          );

      //set initial data
      await convertedDocument.set(talk1);

      // run watchTalk
      final stream = talksRepository.watchTalk(uid: uid, talkId: 'test');

      expectLater(
        stream,
        emitsInOrder([
          predicate((Talk talk) => equals(talk.toMap()).matches(talkMap1, {})),
          predicate((Talk talk) => equals(talk.toMap()).matches(talkMap2, {})),
        ]),
      );

      // update data
      await convertedDocument.update(talkMap2);
    }, timeout: const Timeout(Duration(milliseconds: 1000)));

    test('watch the subsequent stream after delete data in database', () async {
      //add talk to firestore
      final convertedDocument = await mockFirestore
          .collection('users/$uid/attendingRooms')
          .doc('test')
          .withConverter<Talk>(
            fromFirestore: (snapshot, _) => Talk.fromMap(snapshot.data()!),
            toFirestore: (talk, _) => talk.toMap(),
          );

      //set initial data
      await convertedDocument.set(talk1);

      // run watchTalk
      final stream = talksRepository.watchTalk(uid: uid, talkId: 'test');

      expectLater(
        stream,
        emitsInOrder([
          predicate((Talk talk) => equals(talk.toMap()).matches(talkMap1, {})),
        ]),
      );

      // delete data
      await convertedDocument.delete();
    }, timeout: const Timeout(Duration(milliseconds: 1000)));
  });

  group('watch talks', () {
    // cannot use fake_cloud_firestore to test this function because of the issue of fake_cloud_firestore
    // bug report is here:
    // https://github.com/atn832/fake_cloud_firestore/issues/224

    test('watch the first stream', () async {
      // add talk to firestore
      // not sure we need to use converted collection reference
      final convertedCollection = await mockFirestore
          .collection('users/$uid/attendingRooms')
          .withConverter<Talk>(
            fromFirestore: (snapshot, _) => Talk.fromMap(snapshot.data()!),
            toFirestore: (talk, _) => talk.toMap(),
          );

      convertedCollection.add(talk1);

      // // run watchTalk
      // final stream = talksRepository.watchTalks(uid: uid);

      // int num = 0;
      // stream.listen(
      //   (data) {
      //     debugPrint('Received data $num: $data');
      //     num += 1;
      //   },
      //   onError: (error) {
      //     debugPrint('Error: $error');
      //   }
      // );

      // //check the stream
      // expectLater(stream.first.then((value) => {
      //   expect(value[0].toMap(), equals(talkMap1))
      // }), completes);
    });

    test('watch the subsequent stream after add data to firestore', () async {
      // add talk to firestore
      final convertedCollection = await mockFirestore
          .collection('users/$uid/attendingRooms')
          .withConverter<Talk>(
            fromFirestore: (snapshot, _) => Talk.fromMap(snapshot.data()!),
            toFirestore: (talk, _) => talk.toMap(),
          );

      convertedCollection.add(talk1);

      // // run watchTalk
      // final stream = talksRepository.watchTalks(uid: uid);
      // int num = 0;
      // stream.listen(
      //   (data) {
      //     debugPrint('Received data $num: $data');
      //     num += 1;
      //   },
      //   onError: (error) {
      //     debugPrint('Error: $error');
      //   }
      // );

      // //check the stream
      // expectLater(
      //   stream,
      //   emitsInOrder(
      //     [
      //       predicate<List<Talk>>(
      //         (d) => equals(talkMap1).matches(
      //           d[0].toMap(),
      //           {},
      //         ),
      //       ),
      //       // predicate<List<Talk>>(
      //       //   (d) => equals(talkMap2).matches(
      //       //     d[0].toMap(),
      //       //     {},
      //       //   ),
      //       // ),
      //     ],
      //   ),
      // );

      //add talk to firestore
      await convertedCollection.add(Talk.fromMap(talkMap2));
    });

    test('watch the subsequent stream after delete data in firestore',
        () async {
      // add talk to firestore
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap1);
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap2);

      // // run watchTalk
      // final stream = talksRepository.watchTalks(uid: uid);

      //check the stream
      // expectLater(
      //   stream,
      //   emitsInOrder(
      //     [
      //       // predicate(
      //       //   (List<Talk> talks) {
      //       //     //if (talks.length != 2) return false;

      //       //     return equals(talkMap1).matches(talks[0].toMap(), {}) &&
      //       //           equals(talkMap2).matches(talks[1].toMap(), {});
      //       //   }),
      //       // predicate<List<Talk>>(
      //       //   (list) {
      //       //     //if (list.length != 1) return false;

      //       //     return equals(talkMap1).matches(list[0].toMap(), {});
      //       //   }),
      //       predicate<List<Talk>>(
      //         (d) => equals(talkMap1).matches(
      //           d[0].toMap(),
      //           {},
      //         ),
      //       ),
      //     ],
      //   ),
      // );

      // delete talk from firestore
      final snapshot1 =
          await mockFirestore.collection('users/$uid/attendingRooms').get();
      await mockFirestore
          .collection('users/$uid/attendingRooms')
          .doc(snapshot1.docs[0].id)
          .delete();
    });
  });

  group('fetch talks', () {
    test('fetch from empty database', () async {
      // run fetchTalks
      final talks = await talksRepository.fetchTalks(uid: uid);

      // check data is empty
      expect(talks.length, 0);
    });

    test('fetch from database with one entry', () async {
      // add talk to firestore
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap1);

      // run fetchTalks
      final talks = await talksRepository.fetchTalks(uid: uid);

      // check data is added to firestore
      expect(talks[0].toMap(), equals(talkMap1));
    });

    test('fetch from database with more than one entries', () async {
      // add talk to firestore
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap2);
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap3);
      await mockFirestore.collection('users/$uid/attendingRooms').add(talkMap1);

      // run fetchTalks
      final talks = await talksRepository.fetchTalks(uid: uid);

      // check data is added to firestore
      // data should be sorted by updatedAt in descending order
      expect(talks[0].toMap(), equals(talkMap3));
      expect(talks[1].toMap(), equals(talkMap2));
      expect(talks[2].toMap(), equals(talkMap1));
    });
  });
}
