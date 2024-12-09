import 'package:final_app/resources/firestore_methods.dart';
import 'package:final_app/screens/home_screen.dart';
import 'package:final_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_quill/flutter_quill.dart' as quill;

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});
  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final TextEditingController _toController = TextEditingController();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _CCController = TextEditingController();
  final TextEditingController _BCCController = TextEditingController();

  final quill.QuillController _bodyController = quill.QuillController.basic();

  Uint8List? image;
  bool isLoading = false;
  String? sender = FirebaseAuth.instance.currentUser!.email;
  bool isCC = false;
  bool isBCC = false;

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      image = im;
    });
  }

  void sendEmail() async {
    String body = _bodyController.document.toPlainText();
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().sendMail(
          _toController.text, sender!, _subjectController.text, body, image!);
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
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
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void draftMail() async {
    String body = _bodyController.document.toPlainText();
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().saveDraft(
          _toController.text, sender!, _subjectController.text, body, image!);
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
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
      setState(() {
        isLoading = false;
      });
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
        leading: InkWell(
          onTap: draftMail,
          child: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
        ),
        title: Text('Compose Email', style: GoogleFonts.lato(fontSize: 24)),
        actions: [
          InkWell(
            onTap: selectImage,
            child: const Icon(Icons.attach_file, color: Colors.white),
          ),
          const SizedBox(
            width: 10,
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  isCC = !isCC;
                });
              },
              child: Text("CC")),
          TextButton(
              onPressed: () {
                setState(() {
                  isBCC = !isBCC;
                });
              },
              child: Text("BCC"))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField('To', Icon(Icons.person), _toController),
            isCC == true
                ? const SizedBox(height: 10)
                : const SizedBox(
                    width: 1,
                  ),
            isCC == true
                ? _buildTextField('CC', Icon(Icons.person), _CCController)
                : const SizedBox(
                    width: 1,
                  ),
            isBCC == true
                ? const SizedBox(height: 10)
                : const SizedBox(width: 1),
            isBCC
                ? _buildTextField('BCC', Icon(Icons.person), _BCCController)
                : const SizedBox(
                    width: 1,
                  ),
            SizedBox(height: 10),
            _buildTextField(
                'Subject', const Icon(Icons.subject), _subjectController),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: quill.QuillEditor.basic(
                  controller: _bodyController,
                ),
              ),
            ),
            SizedBox(height: 20),
            image == null
                ? Container()
                : Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 200,
                            height: 200,
                            child: Image(
                              image: MemoryImage(image!),
                            ))
                      ],
                    ),
                  ),
            SizedBox(height: 20),
            quill.QuillToolbar.simple(controller: _bodyController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendEmail,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
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
      ),
    );
  }

  Widget _buildTextField(
      String label, Icon icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
