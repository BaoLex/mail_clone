import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:final_app/models/mail.dart' as model;
import 'package:final_app/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> sendMail(String receiver, String sender, String subject,
      String body, Uint8List attach) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('mailPics', attach, true);
      String mailId = const Uuid().v1(); // creates unique id based on time
      model.Mail mail = model.Mail(
          mailID: mailId,
          receiver: receiver,
          sender: sender,
          subject: subject,
          body: body,
          attachments: photoUrl,
          harshed: false,
          starred: false,
          draft: false,
          marked: false,
          deleted: false,
          labels: []);
      await _firestore
          .collection('users')
          .doc(sender)
          .collection('mails')
          .doc(mailId)
          .set(mail.toJson());
      await _firestore
          .collection('users')
          .doc(receiver)
          .collection('mails')
          .doc(mailId)
          .set(mail.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> relyMail(
      String receiver, String sender, String subject, String body) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String mailId = const Uuid().v1(); // creates unique id based on time
      model.Mail mail = model.Mail(
          mailID: mailId,
          receiver: receiver,
          sender: sender,
          subject: subject,
          body: body,
          harshed: false,
          starred: false,
          draft: false,
          marked: false,
          deleted: false,
          labels: [],
          attachments: '');
      await _firestore
          .collection('users')
          .doc(sender)
          .collection('mails')
          .doc(mailId)
          .set(mail.toJson());
      await _firestore
          .collection('users')
          .doc(receiver)
          .collection('mails')
          .doc(mailId)
          .set(mail.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> saveDraft(String receiver, String sender, String subject,
      String body, Uint8List attach) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('mailPics', attach, true);
      String mailId = const Uuid().v1(); // creates unique id based on time
      model.Mail mail = model.Mail(
          mailID: mailId,
          receiver: receiver,
          sender: sender,
          subject: subject,
          body: body,
          attachments: photoUrl,
          harshed: false,
          starred: false,
          draft: true,
          marked: false,
          deleted: false,
          labels: []);
      await _firestore
          .collection('users')
          .doc(sender)
          .collection('mails')
          .doc(mailId)
          .set(mail.toJson());
      await _firestore
          .collection('users')
          .doc(receiver)
          .collection('mails')
          .doc(mailId)
          .set(mail.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Delete Mail
  Future<String> deleteEmail(String mail, String mailId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('users')
          .doc(mail)
          .collection('mails')
          .doc(mailId)
          .delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // moveToTrash
  Future<String> moveToTrash(String mail, String mailId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('users')
          .doc(mail)
          .collection('mails')
          .doc(mailId)
          .update({'deleted': true});
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // harshed mail
  Future<String> harshedMail(String mail, String mailId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('users')
          .doc(mail)
          .collection('mails')
          .doc(mailId)
          .update({'harshed': true});
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // starred mail
  Future<String> starMail(String mail, String mailId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('users')
          .doc(mail)
          .collection('mails')
          .doc(mailId)
          .update({'starred': true});
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> addLabel(String mail, String label) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('users').doc(mail).update({
        'label': FieldValue.arrayUnion([label])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> assignLabel(String mail, String id, String label) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('users')
          .doc(mail)
          .collection('mails')
          .doc(id)
          .update({
        'labels': FieldValue.arrayUnion([label])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteMailLabel(String mail, String id, String label) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('users')
          .doc(mail)
          .collection('mails')
          .doc(id)
          .update({
        'labels': FieldValue.arrayRemove([label])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> editLabel(String mail, String label, String newLabel) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('users').doc(mail).update({
        'label': FieldValue.arrayRemove([label])
      });
      await _firestore.collection('users').doc(mail).update({
        'label': FieldValue.arrayUnion([newLabel])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteLabel(String mail, String label) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('users').doc(mail).update({
        'label': FieldValue.arrayRemove([label])
      });
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> unStarMail(String mail, String mailId) async {
    String res = "Some error occurred";
    try {
      await _firestore
          .collection('users')
          .doc(mail)
          .collection('mails')
          .doc(mailId)
          .update({'starred': false});
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
