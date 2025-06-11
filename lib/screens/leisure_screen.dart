import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/activity_model.dart';
import 'mood_activity_page.dart';

class LeisureScreen extends StatefulWidget {
  const LeisureScreen({super.key});

  @override
  LeisureScreenState createState() => LeisureScreenState();
}

class LeisureScreenState extends State<LeisureScreen> {
  bool _dialogShownInThisSession = false;

  final List<_MoodCategory> categories = [
    _MoodCategory(
      title: 'Serenity',
      description:
          'Embrace serenity with calming activities—candlelit evenings, quiet tea rituals, gentle stretching, or stargazing. Let stillness bring you peace.',
      tagColor: const Color(0xFF7184CF),
    ),
    _MoodCategory(
      title: 'Melancholy',
      description:
          'Embrace melancholy with soothing activities - calm walks, soft music, journaling, or cozy movies. Let your mood lead the way. ',
      tagColor: const Color(0xFFCC691E),
    ),
    _MoodCategory(
      title: 'Romance',
      description:
          'Set the mood with heartfelt moments—candlelit dinners, love letters, stargazing, or slow dances. Let romance surround you.',
      tagColor: const Color(0xFFE7996E),
    ),
    _MoodCategory(
      title: 'Happiness',
      description:
          'Embrace happiness with uplifting activities—dancing, sunshine walks, laughter with friends, or creative fun. Let joy lead the way!',
      tagColor: const Color(0xFF8FD8A8),
    ),
  ];

  void onTabOpened() {
    if (!_dialogShownInThisSession) {
      _dialogShownInThisSession = true;
      _checkAndShowWelcomeDialog();
    }
  }

  Future<void> _checkAndShowWelcomeDialog() async {
    final prefs = await SharedPreferences.getInstance();

    final alreadyShown = prefs.getBool('leisureWelcomeShown') ?? false;

    if (!alreadyShown) {
      await Future.delayed(const Duration(milliseconds: 300));
      _showWelcomeDialog();
      prefs.setBool('leisureWelcomeShown', true);
    }
  }

  void _showWelcomeDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
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
                      'assets/icons/top_2.svg',
                      height: 80.h,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'LEISURE',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'This section is responsible for adding activities on different moods. Conveniently spend your leisure time adding your thoughts in text or audio.',
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
                            style: TextStyle(
                                color: Colors.white, fontSize: 16.sp)),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Mood Activities'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 16.w,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return GestureDetector(
                          onTap: () {
                            final filtered = GetIt.I<Box<ActivityModel>>()
                                .values
                                .where((a) =>
                                    a.moodTag != null &&
                                    a.moodTag!.toLowerCase() ==
                                        category.title.toLowerCase())
                                .toList();

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MoodActivityPage(
                                  moodTitle: category.title,
                                  moodDescription: category.description,
                                  tagColor: category.tagColor,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Image.asset(
                                  'assets/images/bg_${category.title.toLowerCase()}.png',
                                  fit: BoxFit.fitWidth,
                                  width: (MediaQuery.of(context).size.width -
                                          56.w) /
                                      2,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: Text(
                                    category.title,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        alignment: Alignment.center,
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 0),
              blurRadius: 54.r,
              color: const Color(0xFF353637).withOpacity(0.1),
            ),
          ],
          color: const Color(0xFFF7F8FD),
        ),
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
    );
  }
}

class _MoodCategory {
  final String title;
  final String description;
  final Color tagColor;

  _MoodCategory({
    required this.title,
    required this.description,
    required this.tagColor,
  });
}
