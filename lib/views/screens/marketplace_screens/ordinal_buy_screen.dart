// import 'package:alpha_go/models/sample_ordinal_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:get/get.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:alpha_go/views/widgets/trail_tile_widget.dart';
// import 'package:alpha_go/views/widgets/navbar_widget.dart';
// import 'package:go_router/go_router.dart';


// class OrdinalListingDetailPage extends StatelessWidget {
//   final OrdinalListingModel listing;

//   const OrdinalListingDetailPage({super.key, required this.listing});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage("assets/bg.jpg"),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: CustomNavBar(
//           leadingWidget: Padding(
//             padding: EdgeInsets.all(1.w),
//             child: IconButton(
//               onPressed: () => context.pop(),
//               icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB4914B)),
//             ),
//           ),
//           actionWidgets: SizedBox(
//             width: 75.w,
//             child: Row(
//               children: [
//                 Text(
//                   "Ordinal Listing",
//                   style: TextStyle(
//                     color: const Color(0xFFB4914B),
//                     fontSize: 16.sp,
//                     fontFamily: 'Cinzel',
//                   ),
//                 ),
//                 const Spacer()
//               ],
//             ),
//           ),
//         ),
//         body: Stack(
//           children: [
//             Padding(
//               padding: EdgeInsets.only(bottom: 8.h),
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(4.w),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildContent(listing.metadata),
//                     SizedBox(height: 2.h),
//                     _detailRow("Name", listing.name),
//                     _detailRow("Description", listing.description),
//                     _detailRow("Inscription ID", listing.inscriptionId),
//                     _detailRow("Seller Address", listing.sellerAddress),
//                     _detailRow("Collection", listing.collectionName),
//                     _detailRow("Price", "${listing.price} sats"),
//                     _detailRow("Status", listing.status),
//                     _detailRow(
//                         "Created At", listing.createdAt.toLocal().toString()),
//                     _detailRow(
//                         "Expires At", listing.expiresAt.toLocal().toString()),
//                     if (listing.txid != null) _detailRow("TXID", listing.txid!),
//                     if (listing.traits.isNotEmpty) ...[
//                       SizedBox(height: 2.h),
//                       Text("Traits",
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 17.sp,
//                               fontWeight: FontWeight.bold)),
//                       SizedBox(height: 1.h),
//                       ...listing.traits
//                           .map((trait) => TraitTileWidget( ))
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 2.h,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     // Buy action here
//                   },
//                   icon: const Icon(Icons.shopping_cart, color: Colors.white),
//                   label: Text(
//                     "Buy Now for ${listing.price} sats",
//                     style: TextStyle(fontSize: 15.sp, color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFB4914B),
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 1.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label,
//               style: const TextStyle(
//                   color: Color(0xFFB4914B), fontWeight: FontWeight.bold)),
//           SizedBox(height: 0.5.h),
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   value,
//                   style: const TextStyle(color: Colors.white),
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 2,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//                 onPressed: () {
//                   Clipboard.setData(ClipboardData(text: value));
//                   Get.snackbar(
//                     'Copied',
//                     '$label copied to clipboard',
//                     snackPosition: SnackPosition.BOTTOM,
//                     backgroundColor: Colors.black87,
//                     colorText: Colors.white,
//                     duration: const Duration(seconds: 2),
//                     margin:
//                         EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent(String metadataUrl) {
//     if (metadataUrl.endsWith(".svg")) {
//       return SvgPicture.network(
//         metadataUrl,
//         height: 25.h,
//         width: 100.w,
//         fit: BoxFit.cover,
//         placeholderBuilder: (context) =>
//             const Center(child: CircularProgressIndicator()),
//       );
//     } else if (metadataUrl.contains("image")) {
//       return Image.network(
//         metadataUrl,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) => _placeholderContent(),
//       );
//     } else if (metadataUrl.contains("html") || metadataUrl.contains("text")) {
//       return FutureBuilder<String>(
//         future: _loadTextContent(metadataUrl),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError || !snapshot.hasData) {
//             return _placeholderContent();
//           }
//           return Container(
//             height: 25.h,
//             width: 100.w,
//             padding: EdgeInsets.all(2.w),
//             child: Html(
//               data: snapshot.data!,
//               style: {
//                 "body": Style(color: Colors.white),
//               },
//             ),
//           );
//         },
//       );
//     } else {
//       return _placeholderContent();
//     }
//   }

//   Future<String> _loadTextContent(String url) async {
//     final response = await NetworkAssetBundle(Uri.parse(url)).loadString('');
//     return response;
//   }

//   Widget _placeholderContent() {
//     return Container(
//       height: 25.h,
//       width: 100.w,
//       color: Colors.grey[800],
//       alignment: Alignment.center,
//       child: Icon(Icons.broken_image, color: Colors.white, size: 45.sp),
//     );
//   }
// }
