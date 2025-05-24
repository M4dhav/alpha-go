import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseUtils {
  static final users = FirebaseFirestore.instance.collection('wallets');
  static final messages = FirebaseFirestore.instance.collection('messages');
  static final events = FirebaseFirestore.instance.collection('events');
  static final userPfp = FirebaseStorage.instance.ref().child('pfps');
  static final eventImages = FirebaseStorage.instance.ref().child('events');
  static final timelinePics = FirebaseStorage.instance.ref().child('timeline');
  static final timelinePosts =
      FirebaseFirestore.instance.collection('timeline');
}
