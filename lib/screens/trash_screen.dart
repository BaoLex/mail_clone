import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/resources/firestore_methods.dart';
import 'package:final_app/screens/compose_screen.dart';
import 'package:final_app/screens/detail_screen.dart';
import 'package:final_app/screens/draft_screen.dart';
import 'package:final_app/screens/home_screen.dart';
import 'package:final_app/screens/login_screen.dart';
import 'package:final_app/screens/profile_screen.dart';
import 'package:final_app/screens/sent_screen.dart';
import 'package:final_app/screens/star_screen.dart';
import 'package:final_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String? mail = FirebaseAuth.instance.currentUser!.email;
  bool isDetailedView = false;
  bool? isSent;

  trashMail(String id) async {
    try {
      // upload to storage and db
      String res = await FireStoreMethods().deleteEmail(mail!, id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text("Trash", style: GoogleFonts.lato(fontSize: 24)),
        actions: [
          IconButton(
            icon: Icon(Icons.folder),
            onPressed: _showFolderSelectionDialog,
          ),
          IconButton(
            icon: Icon(isDetailedView ? Icons.view_list : Icons.view_module),
            onPressed: () {
              setState(() {
                isDetailedView = !isDetailedView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                          mail: mail!,
                        )),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(mail)
              .collection('mails')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot emails = snapshot.data!.docs[index];
                      mail == emails['receiver'] ? isSent = true : false;
                      return InkWell(
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: emails['deleted'] == true &&
                                  emails['draft'] == false
                              ? ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[200],
                                    child:
                                        Text(emails['sender'][0].toUpperCase()),
                                  ),
                                  title: Text(
                                    emails['sender'],
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(emails['subject'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      if (isDetailedView) ...[
                                        Text(emails['body'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                      if (emails['labels'].isNotEmpty)
                                        Wrap(
                                          spacing: 6.0,
                                          runSpacing: 6.0,
                                          children: emails['labels']
                                              .map<Widget>(
                                                  (label) => GestureDetector(
                                                        // onTap: () =>
                                                        //     _showCancelLabelDialog(
                                                        //         context, email, label),
                                                        child: Chip(
                                                          label: Text(label,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                          backgroundColor:
                                                              Colors.blue,
                                                        ),
                                                      ))
                                              .toList(),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            trashMail(emails['mailID']),
                                        child: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailScreen(
                                            emails['mailID'],
                                            emails['sender'],
                                            emails['receiver'],
                                            emails['subject'],
                                            emails['body'],
                                            emails['attachments'],
                                            isSent!)),
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ComposeScreen()),
          );
        },
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.add),
      ),
    );
  }

  void _showFolderSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Folder', style: GoogleFonts.lato(fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Inbox'),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                ),
              ),
              ListTile(
                title: Text('Starred'),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StarScreen()),
                ),
              ),
              ListTile(
                title: Text('Sent'),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SentScreen()),
                ),
              ),
              ListTile(
                title: Text('Draft'),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DraftScreen()),
                ),
              ),
              ListTile(
                title: Text('Trash'),
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TrashScreen()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
