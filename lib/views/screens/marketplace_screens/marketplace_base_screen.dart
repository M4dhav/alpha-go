import 'package:alpha_go/controllers/ordinal_listing_controller.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class MarketPlaceBaseScreen extends StatelessWidget {
  
  
      
  const MarketPlaceBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OrdinalListingController());
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.jpg"),
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
            child: Row(
              children: [
                Text(
                  "Marketplace",
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
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Text(
                "Discover global ordinal collections or dive into our exclusive curated NFTs.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Cinzel',
                ),
              ),
              SizedBox(height: 6.h),

             Padding(
               padding:  EdgeInsets.symmetric(vertical: 2.h),
               child: InkWell(
                  onTap: () {
                    context.push('/exploreCollections');
                  },
                  child: Container(
                   
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Color(0xFFB4914B), width: 4.sp),
                      borderRadius: BorderRadius.circular(16.sp),
                    ),
                    child: Center(
                      child: Text(
                        "Explore Collections",
                        style: TextStyle(
                          color: Color(0xFFB4914B),
                          fontSize: 17.sp,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                    ),
                  ),
                ),
             ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: InkWell(
                  onTap: () {
                    context.push('/OrdinalBuy');
                  },
                  child: Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Color(0xFFB4914B), width: 4.sp),
                      borderRadius: BorderRadius.circular(16.sp),
                    ),
                    child: Center(
                      child: Text(
                        "Buy Ordinals",
                        style: TextStyle(
                          color: Color(0xFFB4914B),
                          fontSize: 17.sp,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: InkWell(
                  onTap: () {
                    context.push('/listOrdinal');
                  },
                  child: Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Color(0xFFB4914B), width: 4.sp),
                      borderRadius: BorderRadius.circular(16.sp),
                    ),
                    child: Center(
                      child: Text(
                        "Sell your Ordinals",
                        style: TextStyle(
                          color: Color(0xFFB4914B),
                          fontSize: 17.sp,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
             Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: InkWell(
                  onTap: () {
                    context.push('/mintOrdinal');
                  },
                  child: Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Color(0xFFB4914B), width: 4.sp),
                      borderRadius: BorderRadius.circular(16.sp),
                    ),
                    child: Center(
                      child: Text(
                        "Mint Ordinals",
                        style: TextStyle(
                          color: Color(0xFFB4914B),
                          fontSize: 17.sp,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
             
             
            ],
          ),
        ),
      ),
    );
  }
}
