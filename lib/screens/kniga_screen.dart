import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'creativity_ideas_list.dart';
import 'creativity_timer.dart';
import 'creativity_welcome_dialog.dart';
import 'models/creative_idea_model.dart';

class CreativityScreen extends StatefulWidget {
  const CreativityScreen({super.key});

  @override
  State<CreativityScreen> createState() => _CreativityScreenState();
}

class _CreativityScreenState extends State<CreativityScreen> {
  bool _dialogShownInThisSession = false;
  Duration _currentElapsed = Duration.zero;
  late Box<CreativeIdeaModel> _ideaBox;

  @override
  void initState() {
    super.initState();
    _ideaBox = GetIt.I<Box<CreativeIdeaModel>>();
    Future.delayed(Duration.zero, _checkAndShowWelcomeDialog);
  }

  Future<void> _checkAndShowWelcomeDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool('creativityWelcomeShown') ?? false;

    if (!alreadyShown && !_dialogShownInThisSession) {
      _dialogShownInThisSession = true;
      await Future.delayed(const Duration(milliseconds: 300));
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => const CreativityWelcomeDialog(),
      );
      prefs.setBool('creativityWelcomeShown', true);
    }
  }

  void _onTimerReset() {
    setState(() => _currentElapsed = Duration.zero);
  }

  void _onTimerTick(Duration elapsed) {
    _currentElapsed = elapsed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: ValueListenableBuilder(
              valueListenable: _ideaBox.listenable(),
              builder: (context, Box<CreativeIdeaModel> box, _) {
                final hasIdeas = box.isNotEmpty;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Idea Notes'.toUpperCase(),
                              style: TextStyle(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: CreativityTimer(
                              onReset: _onTimerReset,
                              onTick: _onTimerTick,
                            ),
                          ),
                          if (hasIdeas) ...[
                            SizedBox(height: 24.h),
                            Divider(color: Colors.grey[300], thickness: 1),
                          ],
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            CreativityIdeasList(
                              ideas: box.values.toList().reversed.toList(),
                            ),
                            SizedBox(height: 80.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
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
