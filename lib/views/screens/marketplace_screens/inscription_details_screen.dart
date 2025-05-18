import 'package:alpha_go/controllers/inscription_controller.dart';
import 'package:alpha_go/views/widgets/navbar_widget.dart';
import 'package:alpha_go/views/widgets/trail_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class InscriptionDetailPage extends StatelessWidget {
  const InscriptionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InscriptionController>();

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
                  "Ordinal Details",
                  style: TextStyle(
                    color: const Color(0xFFB4914B), // Gold color
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
          if (controller.isDetailLoading.value ||
              controller.selectedInscription.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
      
          final inscription = controller.selectedInscription.value!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  inscription.contentUrl,
                  width: 100.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80.w,
                    height: 25.h,
                    color: Colors.grey[800],
                    child:  Icon(Icons.broken_image,
                        color: Colors.white, size: 45.sp),
                  ),
                ),
                 SizedBox(height: 2.h),
                detailRow("Inscription ID", inscription.inscriptionId),
                detailRow(
                    "Inscription #", inscription.inscriptionNumber.toString()),
                detailRow("Content Type", inscription.contentType),
                detailRow("Owner", inscription.ownerAddress),
                detailRow("Created On", inscription.timestamp.toString()),
                detailRow("Genesis Address", inscription.genesisAddress),
                detailRow("Sat", inscription.sat.toString()),
                if (inscription.metaprotocol != null)
                  detailRow("Metaprotocol", inscription.metaprotocol!),
                if (inscription.satsName != null)
                  detailRow("Sats Name", inscription.satsName!),
                 SizedBox(height: 1.h),
                if (controller.traits.isNotEmpty) ...[
                  Text("Traits",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold)),
                   SizedBox(height: 1.h),
                  ...controller.traits
                      .map((trait) => TraitTileWidget(trait: trait))
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: const TextStyle(
                  color: Color(0xFFB4914B), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
