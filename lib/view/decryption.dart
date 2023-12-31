import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class DecryptionPage extends StatefulWidget {
  final TextEditingController encryptedkey;
  final String encryptiontext;

  const DecryptionPage(
      {super.key, required this.encryptedkey, required this.encryptiontext});

  @override
  State<DecryptionPage> createState() => _DecryptionPageState();
}

class _DecryptionPageState extends State<DecryptionPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _inputTextController =
      TextEditingController(); // Controller for input text
  TextEditingController _encryptionKeyController =
      TextEditingController(); // Controller for encrypted key
  TextEditingController _encryptedTextController =
      TextEditingController(); // Controller for encrypted text
  TextEditingController _decryptedTextController =
      TextEditingController(); // Controller for decrypted text
  late String _encryptionKey;
  late String _encryptedText;
  late String _decryptedText;
  @override
  void initState() {
    super.initState();
    _encryptionKey = generateRandomKey();
    _encryptionKeyController.text = _encryptionKey;
  }

  @override
  void dispose() {
    _inputTextController.dispose();
    _encryptionKeyController.dispose();
    _encryptedTextController.dispose();
    _decryptedTextController.dispose();
    super.dispose();
  }

  String generateRandomKey() {
    final key = encrypt.Key.fromLength(32);
    return key.base64;
  }

  String generateRandomIV() {
    final iv = IV.fromLength(16);
    return iv.base64;
  }

  String encryptText(String text) {
    final key = encrypt.Key.fromBase64(_encryptionKey);
    final iv = IV.fromBase64(generateRandomIV());
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }

  String decryptText(String encryptedText, String keyBase64, String ivBase64) {
    final key = encrypt.Key.fromBase64(keyBase64);
    final iv = IV.fromBase64(ivBase64);
    final encrypter = Encrypter(AES(key));
    final encrypted = Encrypted.fromBase64(encryptedText);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

  void _encryptText() {
    if (_formKey.currentState!.validate()) {
      final inputText = _inputTextController.text;
      final iv = generateRandomIV();
      setState(() {
        _encryptionKey = _encryptionKeyController.text;
        _encryptedText = encryptText(inputText);
        _encryptedTextController.text =
            _encryptedText; // Display encrypted text in the field
        _decryptedTextController.text = ''; // Clear the decrypted text field
      });

      _saveToFirestore(_encryptedText);
    }
  }

  void _decryptText() {
    final encryptedText = widget.encryptedkey.text;
    final iv = generateRandomIV();
    final decryptedText = decryptText(encryptedText, _encryptionKey, iv);
    setState(() {
      _decryptedText = decryptedText;
      _decryptedTextController.text =
          _decryptedText; // Display decrypted text in the field
    });

    _saveToFirestore(_decryptedText);
  }

  XFile? pickImage;
  num snabWalletBalance = 0;
  int check = 0;
  final picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Handle the selected image
      File selectedImage = File(pickedImage.path);
      // You can now use the selectedImage file for further operations
    }
  }

  void _saveToFirestore(String data) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final collectionReference =
          FirebaseFirestore.instance.collection('secrets');

      // Create a new document with a unique ID (Firestore will generate it)
      await collectionReference.add({
        'userId': user.uid,
        'data': data,
        'timestamp': FieldValue
            .serverTimestamp(), // Optional: to store the time of saving
      });

      // Show a snackbar or toast to inform the user that the data is saved.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved to Firestore!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Scaffold(
      backgroundColor: Color(0xff011826), // Customize the background color
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image(
                    height: height / 10,
                    width: width / 4,
                    image: AssetImage(
                      'assets/images/logo.png',
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("Decrypt your secrets. John use Dig Deep",
                    style: TextStyle(color: Colors.white)),
              ),
              Image(
                height: height / 5,
                width: width / 1,
                fit: BoxFit.contain,
                image: AssetImage('assets/images/encr.jpeg'),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xff011826), // Customize the background color
                  image: DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.2), BlendMode.dstATop),
                    image: AssetImage('assets/images/logo.png'),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            maxLines: 5,
                            controller: _decryptedTextController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              filled: true,
                              hintStyle: TextStyle(color: Colors.white),
                              fillColor: Colors.white.withOpacity(0.2),
                              hintText: widget.encryptiontext,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "CRC 16",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "CRC 16",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "CRC 32",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "MD 2",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "MD 4",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "SHA 128",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "SHA 256",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "SHA 512",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "SHAKE 128",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "SHAKE 256",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              InkWell(
                                onTap: _decryptText,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 10,
                                  child: Container(
                                    height: 50,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xfffda93e),
                                          Color(0xfff75230)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: const Text(
                                        'Decrypt',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_encryptedText.isNotEmpty) {
                              Share.share(_decryptedText);
                            }
                          },
                          child: Text('Share Encrypted Text'),
                        )
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
