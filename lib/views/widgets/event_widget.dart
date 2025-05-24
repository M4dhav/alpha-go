import 'package:alpha_go/models/const_model.dart';
import 'package:alpha_go/models/event_model.dart';
import 'package:alpha_go/models/user_model.dart';
import 'package:alpha_go/views/widgets/location_time_widget.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EventWidget extends StatelessWidget {
  final EventModel event;
  final List<WalletUser> hosts;
  const EventWidget({super.key, required this.event, required this.hosts});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 74.h,
          width: 84.w,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xffb4914b),
            ),
          ),
          // color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: event.imageUrl,
                    width: 80.w,
                    height: 38.h,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffb4914b),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 1.w), // Increased horizontal padding
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      event.eventName,
                      textAlign: TextAlign.left,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22.px,
                        fontFamily: 'Cinzel',
                        color: const Color(0xffb4914b),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 10.w,
                      child: AvatarStack(
                        height: 2.5.h,
                        borderWidth: 0.5,
                        avatars: [
                          for (var n = 0; n < event.hosts.length; n++)
                            NetworkImage(hosts[n].pfpUrl),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      "Hosted by: ${hosts.map((e) => e.accountName).join(", ")}",
                      style: TextStyle(
                        fontSize: 10.px,
                        fontFamily: 'Cinzel',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                EventLocationTimeWidget(
                  startTime: event.startTime,
                  endTime: event.endTime,
                  locationName: event.locationName,
                  location: event.location,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: Constants.buttonStyle,
                      onPressed: () {
                        context.push('/eventDetails', extra: [event, hosts]);
                      },
                      child: Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 12.px,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: Constants.buttonStyle,
                      onPressed: () {},
                      child: Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 12.px,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
