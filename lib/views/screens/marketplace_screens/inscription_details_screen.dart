  import 'package:alpha_go/controllers/inscription_controller.dart';
  import 'package:alpha_go/views/widgets/navbar_widget.dart';
  import 'package:alpha_go/views/widgets/trail_tile_widget.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_html/flutter_html.dart';
  import 'package:flutter_svg/svg.dart';
  import 'package:get/get.dart';
  import 'package:go_router/go_router.dart';
  import 'package:responsive_sizer/responsive_sizer.dart';
  class InscriptionDetailPage extends StatelessWidget {
    final bool showBuyButton;

    const InscriptionDetailPage({super.key, required this.showBuyButton});

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
                _buildContent(
                    inscription.contentType,
                    inscription.contentUrl,
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
        floatingActionButton: showBuyButton
              ? Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      // Your action here
                    },
                    backgroundColor: const Color(0xFFB4914B),
                    icon: const Icon(Icons.shopping_cart, color: Colors.white,),
                    label: Text(
                      "Buy Now",
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                  ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        ),
      );
    }

    Widget detailRow(String label, String value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB4914B),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    Get.snackbar(
                      'Copied',
                      '$label copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }


  }


  Widget _buildContent(String contentType, String url) {
    final type = contentType.toLowerCase();

    if (type == 'image/svg+xml') {
      return SizedBox(
        height: 25.h,
        width: 100.w,
        child: SvgPicture.network(
          url,
          fit: BoxFit.cover,
          placeholderBuilder: (context) =>
              const Center(child: CircularProgressIndicator()),
          height: 25.h,
          width: 100.w,
          errorBuilder: (context, error, stackTrace) => const Center(child: CircularProgressIndicator()),
        ),
      );
    } else if (type.startsWith('image/')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholderContent(),
        
      );
    } else if (type.contains('text') || type.contains('html')) {
      return FutureBuilder<String>(
        future: _loadTextContent(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _placeholderContent();
          }

          return SizedBox(
    height: 25.h,
    width: 100.w,
    child: SingleChildScrollView(
      padding: EdgeInsets.all(2.w),
      child: Html(
        data: snapshot.data!,
        style: {
          "body": Style(color: Colors.white), // Optional styling
        },
      ),
    ),

          );
        },
      );
    } else {
      return _placeholderContent();
    }
  }

  Future<String> _loadTextContent(String url) async {
    final response = await NetworkAssetBundle(Uri.parse(url)).loadString('');
    return response;
  }

  Widget _placeholderContent() {
    return Container(
      color: Colors.grey[800],
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image, color: Colors.white, size: 45.sp),
    );
  }
