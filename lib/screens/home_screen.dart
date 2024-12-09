import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/resources/firestore_methods.dart';
import 'package:final_app/screens/compose_screen.dart';
import 'package:final_app/screens/detail_screen.dart';
import 'package:final_app/screens/draft_screen.dart';
import 'package:final_app/screens/label_screen.dart';
import 'package:final_app/screens/login_screen.dart';
import 'package:final_app/screens/profile_screen.dart';
import 'package:final_app/screens/sent_screen.dart';
import 'package:final_app/screens/star_screen.dart';
import 'package:final_app/screens/trash_screen.dart';
import 'package:final_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String? mail = FirebaseAuth.instance.currentUser!.email;
  bool isDetailedView = false;
  bool isSearching = false;
  bool isSent = false;
  List<dynamic> labels = [];
  String? selectedLabel;
  String searchQuery = ''; // For storing the search text
  String? filterSender; // For filtering by sender
  String? filterLabel; // For filtering by label

  @override
  void initState() {
    super.initState();
    fetchArrayData();
  }

  Future<void> fetchArrayData() async {
    try {
      // Access the Firestore document
      final DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(mail).get();

      final List<dynamic> fetchedArray = doc['label'];

      setState(() {
        labels = fetchedArray;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

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
        title: isSearching
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search emails...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_alt,
                        color: Color.fromARGB(255, 92, 92, 92)),
                    onPressed: _showAdvancedFilterDialog,
                  ),
                ],
              )
            : Row(
                children: [
                  Text("Inbox", style: GoogleFonts.lato(fontSize: 24)),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = '';
                  filterSender = null;
                  filterLabel = null;
                }
              });
            },
          ),
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
            icon: Icon(Icons.label_important),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LabelScreen(mail!),
                ),
              );
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
                    items: labels.map((label) {
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
                          child: mail == emails['receiver'] &&
                                  emails['deleted'] == false &&
                                  emails['draft'] == false &&
                                  isSearching == false
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
                                              .map<Widget>((label) =>
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _showCancelLabelDialog(
                                                            context,
                                                            emails['mailID'],
                                                            label),
                                                    child: Chip(
                                                      label: Text(label,
                                                          style:
                                                              const TextStyle(
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
                                        icon: Icon(
                                          emails['harshed']
                                              ? Icons.mark_email_read
                                              : Icons.mark_email_unread,
                                          color: emails['harshed']
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.label,
                                            color: Colors.grey),
                                        onPressed: () => _showLabelDialog(
                                            context, labels, emails['mailID']),
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
                              : mail == emails['receiver'] &&
                                      emails['deleted'] == false &&
                                      emails['draft'] == false &&
                                      isSearching == true &&
                                      filterSender == emails['sender'] &&
                                      emails['labels'].contains(filterLabel) &&
                                      emails['subject'] == searchQuery
                                  ? ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue[200],
                                        child: Text(
                                            emails['sender'][0].toUpperCase()),
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
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ],
                                          if (emails['labels'].isNotEmpty)
                                            Wrap(
                                              spacing: 6.0,
                                              runSpacing: 6.0,
                                              children: emails['labels']
                                                  .map<Widget>((label) =>
                                                      GestureDetector(
                                                        onTap: () =>
                                                            _showCancelLabelDialog(
                                                                context,
                                                                emails[
                                                                    'mailID'],
                                                                label),
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
                                            icon: Icon(
                                              emails['harshed']
                                                  ? Icons.mark_email_read
                                                  : Icons.mark_email_unread,
                                              color: emails['harshed']
                                                  ? Colors.green
                                                  : Colors.grey,
                                            ),
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.label,
                                                color: Colors.grey),
                                            onPressed: () => _showLabelDialog(
                                                context,
                                                labels,
                                                emails['mailID']),
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

  void _showAdvancedFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? tempSender;
        String? tempLabel;
        return AlertDialog(
          title: Text('Advanced Filters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Sender'),
                onChanged: (value) {
                  tempSender = value;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Label'),
                value: tempLabel,
                items: labels.map((label) {
                  return DropdownMenuItem<String>(
                    value: label,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  tempLabel = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  filterSender = tempSender;
                  filterLabel = tempLabel;
                });
                Navigator.pop(context);
              },
              child: Text('Apply'),
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

  void _showLabelDialog(BuildContext context, List<dynamic> data, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Label', style: GoogleFonts.lato(fontSize: 20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: data.map((label) {
                return TextButton(
                  onPressed: () => asLabel(id, label),
                  child: Text(label),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void asLabel(String id, String label) async {
    try {
      String res = await FireStoreMethods().assignLabel(mail!, id, label);
      if (res == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
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

  void delLabel(String id, String label) async {
    try {
      String res = await FireStoreMethods().deleteMailLabel(mail!, id, label);
      if (res == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
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

  void _showCancelLabelDialog(BuildContext context, String id, String label) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove Label', style: GoogleFonts.lato(fontSize: 20)),
          content: Text('Do you want to remove this label from the email?'),
          actions: [
            TextButton(
              onPressed: () => delLabel(id, label),
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
