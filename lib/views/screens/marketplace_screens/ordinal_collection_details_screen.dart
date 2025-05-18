import 'package:alpha_go/controllers/inscription_controller.dart';
import 'package:alpha_go/models/collection_model.dart';
import 'package:alpha_go/views/widgets/inscription_tile_widget.dart';
import 'package:alpha_go/views/widgets/link_row_widget.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:alpha_go/views/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CollectionDetailPage extends StatelessWidget {
  final OrdinalCollectionModel collection;
  final InscriptionController inscriptionController =
      Get.put(InscriptionController());

  CollectionDetailPage({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    inscriptionController.init(collection.slug);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomNavBar(
        leadingWidget: Padding(
          padding: EdgeInsets.all(1.w),
          child: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB4914B)),
          ),
        ),
        actionWidgets: SizedBox(
          width: 75.w,
          child: Row(
            children: [
              Text(
                collection.name,
                style: TextStyle(
                  color: const Color(0xFFB4914B),
                  fontSize: 16.sp,
                  fontFamily: 'Cinzel',
                ),
              ),
              const Spacer()
            ],
          ),
        ),
      ),
      body: Obx(() {
        return inscriptionController.isLoading.value
            ? const ShimmerPlaceholderWidget()
            : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!inscriptionController.isFetchingMore.value &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 100 &&
                      inscriptionController.hasMore.value) {
                    inscriptionController.fetchInscriptions();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(4.w),
                  itemCount: 4 +
                      inscriptionController.inscriptions.length +
                      (inscriptionController.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Text(
                        collection.description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      );
                    } else if (index == 1) {
                      return SizedBox(height: 2.h);
                    } else if (index == 2) {
                      return Text(
                        "Total Items: ${collection.itemCount}",
                        style: TextStyle(
                          color: const Color(0xFFB4914B),
                          fontSize: 15.sp,
                        ),
                      );
                    } else if (index == 3) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinkRowWidget(
                              label: "Twitter", url: collection.twitterLink),
                          LinkRowWidget(
                              label: "Discord", url: collection.discordLink),
                          LinkRowWidget(
                              label: "Website", url: collection.websiteLink),
                          SizedBox(height: 3.h),
                          Text(
                            "NFTs in Collection",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],
                      );
                    } else if (index <
                        4 + inscriptionController.inscriptions.length) {
                      final actualIndex = index - 4;
                      return InscriptionTileWidget(
                        inscription:
                            inscriptionController.inscriptions[actualIndex],
                      );
                    } else {
                      // Loading spinner at the end
                      return  Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.sp),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                ),
              );
      }),
    );
  }
}
