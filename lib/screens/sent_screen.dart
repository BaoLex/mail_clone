import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/resources/firestore_methods.dart';
import 'package:final_app/screens/compose_screen.dart';
import 'package:final_app/screens/detail_screen.dart';
import 'package:final_app/screens/draft_screen.dart';
import 'package:final_app/screens/home_screen.dart';
import 'package:final_app/screens/label_screen.dart';
import 'package:final_app/screens/login_screen.dart';
import 'package:final_app/screens/profile_screen.dart';
import 'package:final_app/screens/star_screen.dart';
import 'package:final_app/screens/trash_screen.dart';
import 'package:final_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SentScreen extends StatefulWidget {
  const SentScreen({super.key});

  @override
  _SentScreenState createState() => _SentScreenState();
}

class _SentScreenState extends State<SentScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String? mail = FirebaseAuth.instance.currentUser!.email;
  bool isDetailedView = false;
  String? selectedLabel;
  bool isSent = false;
  starMessage(String id) async {
    try {
      String res = await FireStoreMethods().starMail(mail!, id);
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

  unStarMessage(String id) async {
    try {
      String res = await FireStoreMethods().unStarMail(mail!, id);
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
        title: Text("Sent", style: GoogleFonts.lato(fontSize: 24)),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    hint: const Text("Filter by label",
                        style: TextStyle(color: Colors.black)),
                    value: selectedLabel,
                    items: ['Work', 'Personal', 'Important'].map((label) {
                      return DropdownMenuItem<String>(
                        value: label,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (label) {
                      setState(() {
                        selectedLabel = label;
                      });
                    },
                  ),
                ),
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
                          child: mail == emails['sender'] &&
                                  emails['deleted'] == false &&
                                  emails['draft'] == false
                              ? ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[200],
                                    child: Text(
                                        emails['receiver'][0].toUpperCase()),
                                  ),
                                  title: Text(
                                    emails['receiver'],
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
                                      emails['starred']
                                          ? InkWell(
                                              onTap: () => unStarMessage(
                                                    emails['mailID'],
                                                  ),
                                              child: const Icon(Icons.star,
                                                  color: Colors.yellow))
                                          : InkWell(
                                              onTap: () => starMessage(
                                                emails['mailID'],
                                              ),
                                              child: const Icon(
                                                  Icons.star_border,
                                                  color: Colors.grey),
                                            ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.label,
                                            color: Colors.grey),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LabelScreen(mail!),
                                            ),
                                          );
                                        },
                                        // onPressed: () =>
                                        //     _showLabelDialog(context, mail),
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
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
                                            isSent)),
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

  void _showLabelDialog(BuildContext context, Map<String, dynamic> email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Label', style: GoogleFonts.lato(fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                  onPressed: () => _assignLabel(context, email, 'Work'),
                  child: Text('Work')),
              TextButton(
                  onPressed: () => _assignLabel(context, email, 'Personal'),
                  child: Text('Personal')),
              TextButton(
                  onPressed: () => _assignLabel(context, email, 'Important'),
                  child: Text('Important')),
            ],
          ),
        );
      },
    );
  }

  void _assignLabel(
      BuildContext context, Map<String, dynamic> email, String label) {
    setState(() {
      if (!email['labels'].contains(label)) {
        email['labels'].add(label);
      }
    });
    Navigator.pop(context);
  }

  void _showCancelLabelDialog(
      BuildContext context, Map<String, dynamic> email, String label) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Label', style: GoogleFonts.lato(fontSize: 20)),
          content: Text('Do you want to remove this label from the email?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  email['labels'].remove(label);
                });
                Navigator.pop(context);
              },
              child: Text('Remove'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
