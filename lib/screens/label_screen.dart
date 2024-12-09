import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/resources/firestore_methods.dart';
import 'package:final_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LabelScreen extends StatefulWidget {
  final String mail;
  LabelScreen(this.mail);

  @override
  _LabelScreenState createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _newLabelController = TextEditingController();
  List<dynamic> labels = [];

  @override
  void initState() {
    super.initState();
    fetchArrayData();
  }

  Future<void> fetchArrayData() async {
    try {
      // Access the Firestore document
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.mail)
          .get();

      final List<dynamic> fetchedArray = doc['label'];

      setState(() {
        labels = fetchedArray;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Manage Labels', style: GoogleFonts.lato(fontSize: 24)),
        backgroundColor: Colors.blue[700],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.mail)
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
                    itemCount: labels.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(labels[index].toString(),
                            style: GoogleFonts.lato(
                                fontSize: 18, color: Colors.black)),
                        trailing: InkWell(
                          onTap: () => deLabel(labels[index]),
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                        onTap: () => _editLabel(index),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addLabel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                  child: Text('Add New Label',
                      style:
                          GoogleFonts.lato(fontSize: 18, color: Colors.black)),
                ),
              ],
            );
          }),
    );
  }

  void deLabel(String label) async {
    try {
      String res = await FireStoreMethods().deleteLabel(widget.mail, label);
      if (res == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LabelScreen(
                    widget.mail,
                  )),
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

  void _addLabel() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Label', style: GoogleFonts.lato(fontSize: 20)),
          content: TextField(
            controller: _labelController,
            decoration: InputDecoration(labelText: 'Label Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: conLabel,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void conLabel() async {
    try {
      String res =
          await FireStoreMethods().addLabel(widget.mail, _labelController.text);
      if (res == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LabelScreen(
                    widget.mail,
                  )),
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

  void eLabel() async {
    try {
      String res = await FireStoreMethods().editLabel(
          widget.mail, _labelController.text, _newLabelController.text);
      if (res == "success") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LabelScreen(
                    widget.mail,
                  )),
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

  void _editLabel(int index) {
    _newLabelController.text = labels[index];
    _labelController.text = labels[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Label', style: GoogleFonts.lato(fontSize: 20)),
          content: TextField(
            controller: _newLabelController,
            decoration: InputDecoration(labelText: 'Label Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: eLabel,
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
