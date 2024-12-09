import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/screens/home_screen.dart';
import 'package:final_app/screens/login_screen.dart';
import 'package:final_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String mail;
  const ProfileScreen({Key? key, required this.mail}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  bool isTwoStepEnabled = false;
  bool isNotified = false;
  bool isAuto = false;
  bool isLoading = false;
  bool isDarkMode = false;
  var userData = {};
  String _selectedFontFamily = 'Roboto';
  double _fontSize = 16.0;

  final List<String> _fontFamilies = [
    'Roboto',
    'Arial',
    'Courier',
    'Times New Roman'
  ];
  Uint8List? _profileImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.mail)
          .get();
      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _profileImage = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[700],
          title: Text('Profile', style: GoogleFonts.lato(fontSize: 24)),
        ),
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: selectImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue[200],
                  backgroundImage: _profileImage != null
                      ? MemoryImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Icon(Icons.person, size: 50, color: Colors.blue[700])
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: userData["username"],
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return userData["username"];
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: userData["bio"],
                  prefixIcon: Icon(Icons.book),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return userData["bio"];
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: userData["phone"],
                  prefixIcon: Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return userData["phone"];
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue[700],
                ),
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.lato(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              _buildProfileOption(
                context,
                'Change Password',
                Icons.lock,
                onTap: () {
                  _changePassword();
                },
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(Icons.verified_user, color: Colors.blue),
                  title: Text('Two-step Verification',
                      style: GoogleFonts.lato(fontSize: 18)),
                  trailing: Switch(
                    value: isTwoStepEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        isTwoStepEnabled = value;
                      });
                      _toggleTwoStepVerification(value);
                    },
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(Icons.notifications, color: Colors.blue),
                  title: Text('Notification Status',
                      style: GoogleFonts.lato(fontSize: 18)),
                  trailing: Switch(
                    value: isNotified,
                    onChanged: (bool value) {
                      setState(() {
                        isNotified = value;
                      });
                      _toggleNotification(value);
                    },
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(Icons.phone_in_talk, color: Colors.blue),
                  title: Text('Auto Answer Mode',
                      style: GoogleFonts.lato(fontSize: 18)),
                  trailing: Switch(
                    value: isAuto,
                    onChanged: (bool value) {
                      setState(() {
                        isAuto = value;
                      });
                      _toggleAuto(value);
                    },
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.blue),
                  title: Text(isDarkMode ? 'Dark Mode' : 'Light Mode',
                      style: GoogleFonts.lato(fontSize: 18)),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (bool value) {
                      setState(() {
                        isDarkMode = value;
                      });
                    },
                  ),
                ),
              ),
              _buildProfileOption(
                context,
                'Text Editor',
                Icons.lock,
                onTap: _showFontSettingsDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (userData["uid"] == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.mail)
        .update({
      'username': _nameController.text,
      'bio': _bioController.text,
      'phone': _phoneController.text
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password', style: GoogleFonts.lato(fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _updatePassword,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Re-authenticate the user with the current password
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _currentPasswordController.text,
          );
          await user.reauthenticateWithCredential(credential);

          // Change the password
          await user.updatePassword(_newPasswordController.text);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error changing password')),
        );
      }
    }
  }

  void _toggleTwoStepVerification(bool isEnabled) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEnabled
                ? 'Enable Two-step Verification'
                : 'Disable Two-step Verification',
            style: GoogleFonts.lato(fontSize: 20),
          ),
          content: Text(
            isEnabled
                ? 'Two-step verification is now enabled for your account.'
                : 'Two-step verification is now disabled for your account.',
            style: GoogleFonts.lato(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _toggleNotification(bool isEnabled) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEnabled
                ? 'Enable Notification Status'
                : 'Disable Notification Status',
            style: GoogleFonts.lato(fontSize: 20),
          ),
          content: Text(
            isEnabled
                ? 'Notification Status is now enabled for your account.'
                : 'Notification Status is now disabled for your account.',
            style: GoogleFonts.lato(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _toggleAuto(bool isEnabled) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEnabled ? 'Enable Auto Answer Mode' : 'Disable Auto Answer Mode',
            style: GoogleFonts.lato(fontSize: 20),
          ),
          content: Text(
            isEnabled
                ? 'Auto Answer Mode is now enabled for your account.'
                : 'Auto Answer Mode is now disabled for your account.',
            style: GoogleFonts.lato(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showFontSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Font Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Font Family Dropdown
              Row(
                children: [
                  Text('Font Family: '),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedFontFamily,
                      items: _fontFamilies.map((font) {
                        return DropdownMenuItem(
                          value: font,
                          child: Text(font),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFontFamily = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Font Size Slider
              Row(
                children: [
                  Text('Font Size:'),
                  SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 10.0,
                      max: 30.0,
                      divisions: 20,
                      label: _fontSize.toString(),
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('APPLY'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileOption(BuildContext context, String label, IconData icon,
      {required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: GoogleFonts.lato(fontSize: 18)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
