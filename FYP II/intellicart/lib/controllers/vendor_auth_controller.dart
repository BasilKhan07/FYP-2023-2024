import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class VendorAuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> getUserInfo() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await _firestore
          .collection('vendors')
          .doc(user.uid)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (userDoc.exists) {
        String fullName = userData['fullName'];
        int indexOfSpace = fullName.indexOf(' ');
        String username =
            indexOfSpace != -1 ? fullName.substring(0, indexOfSpace) : fullName;
        return username;
      } else {
        return 'Username not found';
      }
    } else {
      return 'User not logged in';
    }
  }

  _uploadProfileImageToStorage(Uint8List? image) async {
    Reference ref =
        _storage.ref().child('vendorProfilePics').child(_auth.currentUser!.uid);
    UploadTask uploadTask =
        ref.putData(image!, SettableMetadata(contentType: 'image/jpeg'));
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  pickProfileImage(ImageSource source) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      XFile? file = await imagePicker.pickImage(source: source);
      if (file != null) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  Future<String> signUpUsers(String email, String fullName, String phoneNumber,
      String password, Uint8List? image) async {
    String res = 'Some error occured';
    try {
      if (email.isNotEmpty &&
          fullName.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String profileImageUrl = await _uploadProfileImageToStorage(image);
        await _firestore.collection('vendors').doc(cred.user!.uid).set(
          {
            'email': email,
            'fullName': fullName,
            'phoneNumber': phoneNumber,
            'vendorId': cred.user!.uid,
            'profileImage': profileImageUrl,
          },
        );

        res = "success";
      } else {
        res = 'Please fields must not be empty';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> loginUsers(String email, String password) async {
    String res = 'Something went wrong';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

      if (_auth.currentUser != null) {
        DocumentSnapshot userDoc = await _firestore.collection('vendors').doc(_auth.currentUser!.uid).get();
        if (userDoc.exists) {
          res = 'success';
        } else {
          await _auth.signOut();
          res = 'Invalid user credentials';
        }
      } else {
        res = 'User not logged in';
      }
    } else {
      res = 'Please fields must not be empty';
    }
  } catch (e) {
    res = e.toString();
  }
  return res;
  }

  Future signOut()  async{
    _auth.signOut();
}
}
