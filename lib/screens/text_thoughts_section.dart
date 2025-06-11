import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextThoughtsSection extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const TextThoughtsSection({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEXT THOUGHTS',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF353637).withOpacity(0.1),
                blurRadius: 48,
                offset: const Offset(0, 0),
              )
            ],
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: TextField(
            controller: controller,
            maxLines: 6,
            onChanged: onChanged,
            style: TextStyle(fontSize: 16.sp, color: Colors.black),
            cursorColor: Colors.blue,
            decoration: InputDecoration(
              hintText: 'Not Required',
              filled: true,
              fillColor: Colors.white,
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF181818).withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ),
      ],
    );
  }
}
