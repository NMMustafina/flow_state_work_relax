import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreativityWelcomeDialog extends StatelessWidget {
  const CreativityWelcomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300.w,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/top_3.svg',
                    height: 80.h,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Creativity'.toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'This section allows you to capture follow up and capture your creative ideas and real-time realizations. Start a timer and mark areas of work done.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(24.r),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text('OK',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.sp)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -10.h,
                right: -10.w,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(CupertinoIcons.clear,
                      size: 24.sp, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
