import 'dart:developer';
import 'dart:typed_data';

import 'package:alpha_go/models/firebase_model.dart';
import 'package:alpha_go/models/timeline_post_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class TimelinePostController extends GetxController {
  List<TimelinePosts> posts = [];

  Future<void> getPosts() async {
    try {
      posts.clear();
      await FirebaseUtils.timelinePosts.get().then((value) {
        for (var post in value.docs.where((element) =>
            element.data()['uid'] == FirebaseAuth.instance.currentUser!.uid)) {
          posts.add(TimelinePosts.fromJson(post.data()));
        }
        log(posts.length.toString(), name: "getPostsLength");
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<String> takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      log(photo.name);
      return photo.path;
    } else {
      return "";
    }
  }

  Future<void> addPostToTimeline(String path) async {
    XFile photo = XFile(path);
    Uint8List file = await photo.readAsBytes();
    try {
      await FirebaseUtils.timelinePics
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg')
          .putData(file)
          .then((onValue) async {
        final String url = await onValue.ref.getDownloadURL();
        final String uid = FirebaseAuth.instance.currentUser!.uid;
        final TimelinePosts post = TimelinePosts(
          uid: uid,
          imageUrl: url,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        posts.add(post);
        await FirebaseUtils.timelinePosts.add(post.toJson());
      });
      log(posts.length.toString(), name: "addPostToTimelineLength");
    } catch (e) {
      log(e.toString(), name: "addPostToTimelineError");
    }
  }
}
