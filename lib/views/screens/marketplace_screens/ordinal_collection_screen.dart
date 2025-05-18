import 'package:alpha_go/controllers/collections_controller.dart';
import 'package:alpha_go/models/collection_model.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CollectionPage extends StatelessWidget {
  final controller = Get.put(CollectionController());

  CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchCollections(refresh: true);

    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                  "Ordinal Collections",
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
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!controller.isFetchingMore.value &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 100) {
                controller.fetchCollections();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: controller.collections.length +
                  (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= controller.collections.length) {
                  return  Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final OrdinalCollectionModel collection =
                    controller.collections[index];

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: const Color(0xFFB4914B), 
                      width: 4.sp, 
                    ),
                    borderRadius: BorderRadius.circular(
                        16.sp), 
                  ),
                  child: ListTile(
                    title: Text(collection.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB4914B), 
                        )),
                    subtitle: Text(collection.description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    trailing: Text("Ordinals: ${collection.itemCount}", style: TextStyle(
                      color: const Color(0xFFB4914B),
                      fontSize: 14.sp,
                    )),
                    
                   onTap: () {
  context.push('/collectionDetails', extra: collection);
}
,
                    contentPadding: EdgeInsets.all(16.sp),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
