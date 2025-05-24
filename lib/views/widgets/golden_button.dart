
import 'package:flutter/material.dart';

class GoldenButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GoldenButton({
    super.key, 
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: const Color(0xffb4914b), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Rounded corners
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}