import 'package:alpha_go/models/firebase_model.dart';
import 'package:alpha_go/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  WalletUser user = WalletUser(
    externalLink: '',
    pfpUrl: '',
    walletAddress: '',
    accountName: '',
    bio: '',
  );

  void setUser(WalletUser newUser) {
    user = newUser;
  }

  Future<WalletUser> getHost(String uid) async {
    DocumentSnapshot userDoc = await FirebaseUtils.users.doc(uid).get();
    return WalletUser.fromMap(userDoc.data() as Map<String, dynamic>);
  }

  void updatePfpUrl(String newPfpUrl) {
    user.pfpUrl = newPfpUrl;
  }
}
