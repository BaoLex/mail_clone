import 'package:final_app/resources/firestore_methods.dart';
import 'package:final_app/screens/home_screen.dart';
import 'package:final_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReplyForwardScreen extends StatefulWidget {
  final String sender;
  final String receiver;
  final String subject;
  final String body;
  final bool isReply;

  ReplyForwardScreen({
    required this.sender,
    required this.receiver,
    required this.subject,
    required this.body,
    required this.isReply,
  });

  @override
  _ReplyForwardScreenState createState() => _ReplyForwardScreenState();
}

class _ReplyForwardScreenState extends State<ReplyForwardScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _newBodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(
          widget.isReply ? 'Reply' : 'Forward',
          style: GoogleFonts.lato(fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          Padding(
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
                            widget.receiver[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.receiver,
                          style: GoogleFonts.lato(
                              fontSize: 20, color: Colors.black),
                        ),
                      ],
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
                  onTap: () {},
                  child: Text('Click here to download attachment',
                      style:
                          GoogleFonts.lato(fontSize: 20, color: Colors.indigo)),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: widget.isReply
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Reply to ${widget.receiver}',
                          style: GoogleFonts.lato(
                              fontSize: 20, color: Colors.black)),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _newBodyController,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'Your Message',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: replyEmail,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blue[700],
                        ),
                        child: Text(
                          'Send',
                          style: GoogleFonts.lato(fontSize: 18),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Forward from ${widget.sender}',
                          style: GoogleFonts.lato(
                              fontSize: 20, color: Colors.black)),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _toController,
                        decoration: InputDecoration(
                          labelText: 'To',
                          prefixIcon: Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: forwardEmail,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blue[700],
                        ),
                        child: Text(
                          'Send',
                          style: GoogleFonts.lato(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  void replyEmail() async {
    try {
      // upload to storage and db
      String res = await FireStoreMethods().relyMail(widget.sender,
          widget.receiver, widget.subject, _newBodyController.text);
      if (res == "success") {
        if (context.mounted) {
          showSnackBar(
            context,
            'Sended',
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

  void forwardEmail() async {
    try {
      // upload to storage and db
      String res = await FireStoreMethods().relyMail(_toController.text,
          widget.sender, widget.subject, _newBodyController.text);
      if (res == "success") {
        if (context.mounted) {
          showSnackBar(
            context,
            'Sended',
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
}
