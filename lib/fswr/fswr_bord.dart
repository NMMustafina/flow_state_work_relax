import 'package:flow_state_work_relax_223a/fswr/fswr_botom.dart';
import 'package:flow_state_work_relax_223a/fswr/fswr_moti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'fswr_dok.dart';
import 'fswr_url.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardPageData> pages = [
    const _OnboardPageData(
      version: "0.1.2",
      imagePath: "assets/images/boar3.png",
      title: "BALANCED WORKFLOW AND WELL-BEING",
      buttonText: "Continue",
    ),
    const _OnboardPageData(
      version: "0.1.3",
      imagePath: "assets/images/image.png",
      title: "TASK ORGANIZATION AND PLANNING",
      buttonText: "Continue",
    ),
    const _OnboardPageData(
      version: "0.1.4",
      imagePath: "assets/images/boar_2.png",
      title: "CREATIVE NOTES AND TIME TRACKING",
      buttonText: "Get Started",
    ),
  ];

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const FswrTopBar(),
        ),
        (protected) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: pages.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            final page = pages[index];
            return Column(
              children: [
                SizedBox(height: 32.h),
                Expanded(
                  child: Image.asset(
                    page.imagePath,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      SizedBox(height: 24.h),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          width: double.infinity,
                          height: 64.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A99E0),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                left: 16.w,
                                child: SvgPicture.asset(
                                  "assets/icons/icon.svg",
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              Text(
                                page.buttonText,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FswrMotiiButT(
                            onPressed: () {
                              fssrUrl(context, FswrDokum.terrndr);
                            },
                            child: Text(
                              "Terms of use",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          FswrMotiiButT(
                            onPressed: () {
                              fssrUrl(context, FswrDokum.ppolosk);
                            },
                            child: Text(
                              "Privacy Policy",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardPageData {
  final String version;
  final String imagePath;
  final String title;
  final String buttonText;

  const _OnboardPageData({
    required this.version,
    required this.imagePath,
    required this.title,
    required this.buttonText,
  });
}
