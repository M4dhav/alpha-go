import 'dart:convert';
import 'dart:developer';
import 'package:alpha_go/controllers/event_controller.dart';
import 'package:alpha_go/controllers/user_controller.dart';
import 'package:alpha_go/models/const_model.dart';
import 'package:alpha_go/models/event_model.dart';
import 'package:alpha_go/models/user_model.dart';
import 'package:alpha_go/views/widgets/drawer_widget.dart';
import 'package:alpha_go/views/widgets/event_widget.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ltlng;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  ltlng.LatLng? userPos;

  mb.MapboxMap? mapboxMap;
  final EventController eventController = Get.find();
  final UserController userController = Get.find();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<geo.Position> determinePosition() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best);
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await requestLocationPermission();
      mb.MapboxOptions.setAccessToken(Constants.mapboxToken);
      determinePosition().then((value) {
        setState(() {
          userPos = ltlng.LatLng(value.latitude, value.longitude);
          log('userPos: $userPos');
        });
      });
    });
  }

  addModelLayer(List<EventModel> events) async {
    List<Feature> features = [];

    for (EventModel event in events) {
      features.add(Feature(
          id: events.indexOf(event),
          geometry: Point(
              coordinates: mb.Position(
                  event.location.longitude, event.location.latitude)),
          properties: {
            'name': event.eventName,
            'location': event.locationName,
            'index': events.indexOf(event)
          }));
    }
    FeatureCollection featureCollection = FeatureCollection(features: features);
    if (mapboxMap == null) {
      throw Exception("MapboxMap is not ready yet");
    }
    await mapboxMap?.style.addSource(
        GeoJsonSource(id: "events", data: json.encode(featureCollection)));

    await mapboxMap?.style.addStyleModel("eventsModel",
        "https://github.com/M4dhav/alpha-go/raw/demo-v1.3.1/assets/bitcoin/main.glb");

    var modelLayer = ModelLayer(id: "eventsLayer", sourceId: "events");
    modelLayer.modelId = "eventsModel";
    modelLayer.modelScale = [10, 10, 10];
    modelLayer.modelType = ModelType.COMMON_3D;
    await mapboxMap?.style.addLayer(modelLayer);

    log('added modelLayer');
  }

  _onMapCreated(mb.MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.location.updateSettings(mb.LocationComponentSettings(
        enabled: true,
        puckBearing: mb.PuckBearing.HEADING,
        puckBearingEnabled: true,
        locationPuck: mb.LocationPuck(
            locationPuck3D: mb.LocationPuck3D(
          modelUri:
              "https://github.com/M4dhav/alpha-go/raw/dev/assets/pointer.glb",
          modelScale: [2, 2, 2],
          position: [userPos!.longitude, userPos!.latitude],
        ))));
    log('puck added');
  }

  _onStyleLoaded(StyleLoadedEventData data) async {
    await addModelLayer(eventController.events);
    log('style loaded');
    mapboxMap!.addInteraction(
        TapInteraction(
          FeaturesetDescriptor(
            layerId: "eventsLayer",
          ),
          (feature, mapContext) async {
            EventModel event =
                eventController.events[feature.properties['index'] as int];

            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => EventWidget(
                  event: event,
                  hosts: event.hosts,
                ),
              );
            }
          },
          stopPropagation: false,
        ),
        interactionID: "eventTapInteraction");

    log('loaded interactions');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover)),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const CustomDrawer(),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: CustomNavBar(
            leadingWidget: Padding(
              padding: EdgeInsets.only(left: 3.w),
              child: Image.asset(
                'assets/alpha.jpg',
                fit: BoxFit.contain,
              ),
            ),
            actionWidgets: Row(
              children: [
                InkWell(
                  onTap: () {
                    context.push("/search");
                  },
                  child: Container(
                    width: 50.w,
                    padding: EdgeInsets.only(bottom: 1.h, top: 1.h, right: 2.w),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xffb4914b),
                          width: 0.4.sp,
                        ),
                      ),
                    ),
                    child: Text(
                      'Search',
                      style: TextStyle(
                        color: const Color(0xffb4914b),
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 3.w,
                  ),
                  child: Center(
                    child: IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                          log('opening');
                        },
                        icon: Icon(
                          Icons.menu,
                          color: const Color(0xffb4914b),
                          size: 29.sp,
                        )),
                  ),
                )
              ],
            )),
        body: userPos == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : mb.MapWidget(
                // mapOptions: mb.MapOptions(
                //     pixelRatio: 1.0, orientation: mb.NorthOrientation.UPWARDS),
                key: const ValueKey("mapWidget"),
                onMapCreated: _onMapCreated,
                onStyleLoadedListener: _onStyleLoaded,
                // onTapListener: _onTapListener,
                styleUri: Constants.mapboxStyleUrl,
                cameraOptions: mb.CameraOptions(
                    pitch: 80,
                    center: mb.Point(
                        coordinates: mb.Position(
                            2.3561321520770133, 48.857386674033336)),
                    // center: mb.Point(
                    //     coordinates: mb.Position(
                    //         userPos!.longitude, userPos!.latitude + 0.0016)),
                    zoom: 18.0),
              ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     determinePosition().then((value) {
        //       setState(() async {
        //         await mapboxMap?.flyTo(
        //             mb.CameraOptions(
        //                 pitch: 90,
        //                 center: mb.Point(
        //                     coordinates:
        //                         mb.Position(value.longitude, value.latitude)),
        //                 zoom: 12.0),
        //             mb.MapAnimationOptions());
        //       });
        //     });
        //   },
        //   child: const Icon(Icons.my_location),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      ),
    );
  }
}
