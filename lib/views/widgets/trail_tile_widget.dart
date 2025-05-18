import 'package:alpha_go/models/inscription_trait_model.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TraitTileWidget extends StatelessWidget {
  final InscriptionTrait trait;

  const TraitTileWidget({super.key, required this.trait});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text("${trait.name}: ${trait.value}",
            style: TextStyle(color: Colors.white, fontSize: 16.sp)),
        subtitle: Text("Rarity: ${trait.rarity.toStringAsFixed(2)}%",
            style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
