
import 'package:alpha_go/controllers/ordinal_listing_controller.dart';
import 'package:alpha_go/models/const_model.dart';
import 'package:alpha_go/models/sample_ordinal_model.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class OrdinalListingsScreen2 extends StatelessWidget {
  final OrdinalListingController controller =
      Get.find();

  OrdinalListingsScreen2({super.key});

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.all(1.w),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB4914B)),
            ),
          ),
          actionWidgets: SizedBox(
            width: 75.w,
            child: InkWell(
              onTap: () {
                
              },
              child: Row(
                children: [
                  Text(
                    "Buy Ordinals",
                    style: TextStyle(
                      color: const Color(0xFFB4914B),
                      fontSize: 18.sp,
                      fontFamily: 'Cinzel',
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final listings = controller.listings;
          if (listings.isEmpty) {
            return const Center(
                child: Text('No listings found.',
                    style: TextStyle(color: Colors.white)));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sectionTitle('Explore NFTs'),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    return NftCard(listing: listings[index]);
                  },
                ),
                const SizedBox(height: 24),
                sectionTitle('Popular Collections'),
               
                Padding(
                  padding:  EdgeInsets.only(top: 4.h, bottom: 10.h),
                  child: SizedBox(
                    height: 30.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: listings.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 45.w,
                          child: NftCard(listing: listings[index]),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFB4914B),
        fontFamily: 'Cinzel',
      ),
    );
  }
}
class NftCard extends StatelessWidget {
  final OrdinalListingModel listing;

  const NftCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10.h,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB4914B), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: listing.metadata,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                     SizedBox(height: 0.5.h),
                    Text(
                      '${listing.price} sats',
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 13.sp,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 3.w),
                      child: SizedBox(
                        width: double.infinity,
                        
                        child: ElevatedButton(
                          onPressed: () {
                            
                            print('Buy button pressed for ${listing.name}');
                          },
                          style: Constants.buttonStyle,
                          child: Text(
                            "Buy",
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              color: Colors.white,
                              fontSize: 17.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
