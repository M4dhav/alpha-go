import 'package:alpha_go/models/event_model.dart';
import 'package:alpha_go/models/user_model.dart';
import 'package:alpha_go/views/widgets/location_time_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen(
      {super.key, required this.event, required this.hosts});
  final EventModel event;
  final List<WalletUser> hosts;
  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h),
            child: Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: widget.event.imageUrl,
                      width: 90.w,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffb4914b),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Text(
                      widget.event.eventName,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 25.px,
                        fontFamily: 'Cinzel',
                        color: const Color(0xffb4914b),
                      ),
                    ),
                  ),
                  EventLocationTimeWidget(
                      startTime: widget.event.startTime,
                      endTime: widget.event.endTime,
                      location: widget.event.location,
                      locationName: widget.event.locationName)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
