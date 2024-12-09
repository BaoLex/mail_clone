import 'package:cloud_firestore/cloud_firestore.dart';

class Mail {
  final String mailID;
  final String sender;
  final String receiver;
  final String subject;
  final String body;
  final String attachments;
  final bool harshed;
  final bool starred;
  final bool draft;
  final bool marked;
  final bool deleted;
  final labels;

  const Mail({
    required this.mailID,
    required this.sender,
    required this.receiver,
    required this.subject,
    required this.body,
    required this.attachments,
    required this.harshed,
    required this.starred,
    required this.draft,
    required this.marked,
    required this.deleted,
    required this.labels,
  });

  static Mail fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Mail(
      mailID: snapshot["mailID"],
      receiver: snapshot["receiver"],
      sender: snapshot["sender"],
      subject: snapshot["subject"],
      body: snapshot["body"],
      attachments: snapshot["attachments"],
      harshed: snapshot["harshed"],
      starred: snapshot["starred"],
      draft: snapshot["draft"],
      marked: snapshot['marked'],
      deleted: snapshot['deleted'],
      labels: snapshot["labels"],
    );
  }

  Map<String, dynamic> toJson() => {
        "mailID": mailID,
        "receiver": receiver,
        "sender": sender,
        "subject": subject,
        "body": body,
        "attachments": attachments,
        "harshed": harshed,
        "starred": starred,
        "draft": draft,
        'marked': marked,
        'deleted': deleted,
        'labels': labels,
      };
}
