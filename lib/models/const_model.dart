import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final class Constants {
  static final ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll<Color>(Colors.black),
      foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
      textStyle: WidgetStatePropertyAll<TextStyle>(TextStyle(
          fontFamily: 'Cinzel', color: Colors.white, fontSize: 17.sp)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.sp),
              side: const BorderSide(color: Color(0xffb4914b)))));
  static final InputDecoration inputDecoration = InputDecoration(
    focusColor: Colors.black,
    labelStyle: const TextStyle(
      color: Colors.white,
    ),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.sp),
        borderSide: const BorderSide(
          color: Color(0xffb4914b),
        )),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.sp),
        borderSide: const BorderSide(color: Color(0xffb4914b))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.sp),
        borderSide: const BorderSide(color: Color(0xffb4914b))),
    hintStyle: const TextStyle(color: Colors.white, fontFamily: 'Cinzel'),
    iconColor: Colors.white,
    filled: true,
    fillColor: Colors.black.withOpacity(0.7),
  );
  static final appBarBottom = PreferredSize(
      preferredSize: Size.fromHeight(1.h),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xffb4914b),
        ),
        height: 0.2.h,
      ));
  static const inputStyle =
      TextStyle(color: Colors.white, fontFamily: 'Roboto');
}
