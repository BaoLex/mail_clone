import 'package:final_app/resources/firestore_methods.dart';
import 'package:final_app/screens/home_screen.dart';
import 'package:final_app/screens/reply_forward_screen.dart';
import 'package:final_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DetailScreen extends StatefulWidget {
  final String mailID;
  final String people;
  final String user;
  final String subject;
  final String body;
  final String attachments;
  final bool sent;

  DetailScreen(this.mailID, this.people, this.user, this.subject, this.body,
      this.attachments, this.sent);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  initState() {
    super.initState();
    markasread();
  }

  void markasread() async {
    try {
      String res =
          await FireStoreMethods().harshedMail(widget.user, widget.mailID);
      if (res == "success") {
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  deleteMail() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            "Your mail will move to trash",
            style: GoogleFonts.lato(fontSize: 20, color: Colors.white),
          ),
          actions: [
            Row(
              children: [
                InkWell(
                  onTap: trashMail,
                  child: Container(
                    color: Colors.red,
                    child: Text(
                      "Yes",
                      style:
                          GoogleFonts.lato(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                      color: Colors.lightBlue,
                      child: Text(
                        "No",
                        style:
                            GoogleFonts.lato(fontSize: 20, color: Colors.black),
                      )),
                  onTap: () => Navigator.pop(context),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  downloadAttachment() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            "Attachments have been downloaded",
            style: GoogleFonts.lato(fontSize: 20, color: Colors.white),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child: Container(
                      color: Colors.lightBlue,
                      child: Text(
                        "Go back",
                        style:
                            GoogleFonts.lato(fontSize: 20, color: Colors.black),
                      )),
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  void trashMail() async {
    try {
      // upload to storage and db
      String res =
          await FireStoreMethods().moveToTrash(widget.user, widget.mailID);
      if (res == "success") {
        if (context.mounted) {
          showSnackBar(
            context,
            'Trashed',
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void _showReplyForwardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text('Choose an Action', style: GoogleFonts.lato(fontSize: 20)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReplyForwardScreen(
                      sender: widget.user,
                      receiver: widget.people,
                      subject: widget.subject,
                      body: widget.body,
                      isReply: true,
                    ),
                  ),
                );
              },
              child: Text('Reply'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReplyForwardScreen(
                      sender: widget.user,
                      receiver: widget.people,
                      subject: widget.subject,
                      body: widget.body,
                      isReply: false,
                    ),
                  ),
                );
              },
              child: Text('Forward'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: Text('Email Details', style: GoogleFonts.lato(fontSize: 24)),
          actions: [
            widget.sent == true
                ? InkWell(
                    onTap: () => _showReplyForwardDialog(context),
                    child:
                        const Icon(Icons.reply, size: 30, color: Colors.black),
                  )
                : const SizedBox(
                    height: 1,
                  ),
            const SizedBox(
              width: 20,
            ),
            InkWell(
                onTap: deleteMail,
                child: Icon(Icons.delete, size: 30, color: Colors.red))
          ]),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subject,
              style: GoogleFonts.lato(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[200],
                      child: Text(
                        widget.people[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.people,
                      style:
                          GoogleFonts.lato(fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
                widget.sent == true
                    ? InkWell(
                        onTap: () => _showReplyForwardDialog(context),
                        child: const Icon(Icons.reply,
                            size: 30, color: Colors.black),
                      )
                    : const SizedBox(
                        height: 1,
                      ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              widget.body,
              style: GoogleFonts.lato(fontSize: 28, color: Colors.black),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: downloadAttachment,
              onDoubleTap: () => launchUrlString('${widget.attachments}'),
              child: Text('Click here to download attachment',
                  style: GoogleFonts.lato(fontSize: 20, color: Colors.indigo)),
            ),
            const SizedBox(
              height: 20,
            ),
            widget.sent == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReplyForwardScreen(
                                sender: widget.user,
                                receiver: widget.people,
                                subject: widget.subject,
                                body: widget.body,
                                isReply: true,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.reply, size: 18),
                        label: Text("Reply"),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReplyForwardScreen(
                                sender: widget.user,
                                receiver: widget.people,
                                subject: widget.subject,
                                body: widget.body,
                                isReply: false,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.forward, size: 18),
                        label: Text("Forward"),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(
                    width: 1,
                  ),
          ],
        ),
      ),
    );
  }
}
