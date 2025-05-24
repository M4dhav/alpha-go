import 'package:alpha_go/models/const_model.dart';
import 'package:alpha_go/views/screens/chat_screens/chat.dart';
// import 'package:alpha_go/views/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:searchfield/searchfield.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  Widget _buildAvatar(types.User user) {
    const color = Colors.blue;
    final hasImage = user.imageUrl != null;
    final name = user.firstName;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
                name ?? '',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }

  void _handlePressed(types.User otherUser, BuildContext context) async {
    final navigator = Navigator.of(context);
    final room = await FirebaseChatCore.instance.createRoom(otherUser);

    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          room: room,
        ),
      ),
    );
  }

  static final List<String> countries = ['India', 'China', 'Russia'];

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'assets/bg.jpg',
                ),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: const Color(0xffb4914b),
            bottom: Constants.appBarBottom,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: SearchField<String>(
              searchInputDecoration: SearchInputDecoration(
                  hintText: 'Search',
                  cursorColor: Colors.white,
                  hintStyle: const TextStyle(
                    color: Color(0xffb4914b),
                  )),
              marginColor: const Color(0xffb4914b),
              suggestions: countries
                  .map(
                    (e) => SearchFieldListItem<String>(e,
                        item: e,
                        // Use child to show Custom Widgets in the suggestions
                        // defaults to Text widget
                        child: Text(e)),
                  )
                  .toList(),
            ),
          ),
          body: StreamBuilder<List<types.User>>(
            stream: FirebaseChatCore.instance.users(),
            initialData: const [],
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    bottom: 200,
                  ),
                  child: const Text('No users'),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final user = snapshot.data![index];

                  return InkWell(
                    onTap: () {
                      _handlePressed(user, context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          _buildAvatar(user),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.firstName ?? '',
                                style: TextStyle(fontSize: 18.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
}
