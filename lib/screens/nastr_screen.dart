import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../fswr/fswr_dok.dart';
import '../fswr/fswr_moti.dart';
import '../fswr/fswr_url.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FD),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF019BE3)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),// Светлый фон
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsButton(title: 'Privacy Policy', onTap: () {
              fssrUrl(context, FswrDokum.ppolosk);
            }),
            SizedBox(height: 16.h),
            _SettingsButton(title: 'Terms of Use', onTap: () {
              fssrUrl(context, FswrDokum.terrndr);
            }),
            SizedBox(height: 16.h),
            _SettingsButton(title: 'Support Us', onTap: () {
              fssrUrl(context, FswrDokum.seuppe);
            }),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SettingsButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FswrMotiiButT(
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF83BFF9),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
