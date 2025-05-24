// import 'package:alpha_go/views/screens/chat.dart';
import 'package:alpha_go/views/screens/chat_screens/chat.dart';
import 'package:alpha_go/views/screens/users.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// import 'chat.dart';
// import 'login.dart';
// import 'users.dart';
// import 'util.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  bool _error = false;
  bool _initialized = false;
  User? _user;

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  void initializeFlutterFire() async {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        setState(() {
          _user = user;
        });
      });
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget _buildAvatar(types.Room room) {
    var color = Colors.transparent;

    if (room.type == types.RoomType.direct) {
      try {
        final otherUser = room.users.firstWhere(
          (u) => u.id != _user!.uid,
        );

        color = Colors.red;
      } catch (e) {
        // Do nothing if other user is not found.
      }
    }

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 20.sp,
        child: !hasImage
            ? Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container();
    }

    if (!_initialized) {
      return Container();
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomNavBar(
          leadingWidget: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: const Text(
              'Your Chats',
              style: TextStyle(color: Color(0xffb4914b)),
            ),
          ),
          actionWidgets: IconButton(
            icon: Icon(
              Icons.add,
              size: 35.px,
              color: const Color(0xffb4914b),
            ),
            onPressed: _user == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => const UsersPage(),
                      ),
                    );
                  },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: 2.h,
            left: 2.w,
            right: 2.w,
            bottom: 1.h,
          ),
          child: StreamBuilder<List<types.Room>>(
            stream: FirebaseChatCore.instance.rooms(),
            initialData: const [],
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    top: 1.h,
                    left: 2.w,
                    right: 2.w,
                    bottom: 1.h,
                  ),
                  child: const Text('No rooms'),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final room = snapshot.data![index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            room: room,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20.sp),
                          border: Border.all(
                            width: 0.7,
                            color: const Color(0xffb4914b),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.h,
                          vertical: 2.h,
                        ),
                        child: Row(
                          children: [
                            _buildAvatar(room),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.users[0].firstName ?? '',
                                  style: TextStyle(fontSize: 17.sp),
                                ),
                                Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          room.updatedAt!)
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color.fromARGB(
                                          255, 78, 78, 78)),
                                )
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Color.fromARGB(255, 78, 78, 78),
                                ))
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
