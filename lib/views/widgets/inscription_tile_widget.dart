import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controllers/inscription_controller.dart';
import '../../models/inscription_model.dart';

class InscriptionTileWidget extends StatefulWidget {
  final OrdinalInscription inscription;
  final bool ifPossibleToBuy ;

  const InscriptionTileWidget({super.key, required this.inscription, required this.ifPossibleToBuy});

  @override
  State<InscriptionTileWidget> createState() => _InscriptionTileWidgetState();
}

class _InscriptionTileWidgetState extends State<InscriptionTileWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final InscriptionController controller = Get.find<InscriptionController>();
        await controller.fetchInscriptionDetail(widget.inscription.inscriptionId);
          if (!mounted) return; 
          if(widget.ifPossibleToBuy){
            context.push('/inscriptionDetailsBuy');
          }
          else{
            context.push('/inscriptionDetails');
          }
          
          

      },
      child: Card(
        color: Colors.grey[900],
        margin:  EdgeInsets.symmetric(vertical: 1.h),
        child: Padding(
          padding:  EdgeInsets.all(12.sp),
          child: Row(
            children: [
              Image.network(widget.inscription.contentUrl,
                  width: 20.w, height: 10.h, fit: BoxFit.cover, 
                  errorBuilder: (context, error, stackTrace) => Container(
                  width: 20.w,
                  height: 10.h,
                  color: Colors.grey[800],
                  child:  Icon(Icons.broken_image,
                      color: Colors.white, size: 35.sp),
                ),
              ),
               SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  "Inscription #${widget.inscription.inscriptionNumber}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
