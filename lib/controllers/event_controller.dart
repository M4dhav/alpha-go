import 'dart:developer';

import 'package:alpha_go/models/event_model.dart';
import 'package:alpha_go/models/firebase_model.dart';
import 'package:alpha_go/models/user_model.dart';
import 'package:get/get.dart';

class EventController extends GetxController {
  final List<EventModel> events = [];

  Future<void> getEvents() async {
    await FirebaseUtils.events.get().then((querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        List<String> hostIds = List<String>.from(data['hostId']);
        final EventModel event = EventModel.fromMap(data);
        event.hosts = await getEventHosts(hostIds);
        events.add(event);
      }
    });
    log(events.length.toString());
  }

  Future<void> addEvent(EventModel event) async {
    await FirebaseUtils.events.add(event.toMap());
    events.add(event);
  }

  Future<List<WalletUser>> getEventHosts(List<String> hostIds) async {
    List<WalletUser> hosts = [];
    for (var host in hostIds) {
      await FirebaseUtils.users.doc(host).get().then((doc) {
        hosts.add(WalletUser.fromMap(doc.data() as Map<String, dynamic>));
      });
    }
    return hosts;
  }
}
