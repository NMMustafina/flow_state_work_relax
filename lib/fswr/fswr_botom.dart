import 'package:flow_state_work_relax_223a/screens/carer_screen.dart';
import 'package:flow_state_work_relax_223a/screens/kniga_screen.dart';
import 'package:flow_state_work_relax_223a/screens/leisure_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'fswr_color.dart';

class FswrTopBar extends StatefulWidget {
  const FswrTopBar({super.key, this.indexScr = 0});

  final int indexScr;

  @override
  State<FswrTopBar> createState() => _FswrTopBarState();
}

class _FswrTopBarState extends State<FswrTopBar> {
  late int _currentIndex;
  final GlobalKey<LeisureScreenState> leisureKey =
      GlobalKey<LeisureScreenState>();

  final List<String> titles = ['Career', 'Leisure', 'Creativity'];

  final List<String> icons = [
    'assets/icons/n_top.svg',
    'assets/icons/n_top_2.svg',
    'assets/icons/n_top_3.svg',
  ];

  final List<String> activeIcons = [
    'assets/icons/top.svg',
    'assets/icons/top_2.svg',
    'assets/icons/top_3.svg',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.indexScr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FSWRColor.bg,
      body: Column(
        children: [
          SizedBox(height: 60.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(3, (index) {
                  final isSelected = _currentIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                      });
                      if (index == 1) {
                        leisureKey.currentState?.onTabOpened();
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          isSelected ? activeIcons[index] : icons[index],
                          height: 36.h,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          titles[index],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? FSWRColor.blue
                                : Colors.grey.shade500,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: EdgeInsets.only(top: 4.h),
                            height: 2.h,
                            width: 24.w,
                            color: FSWRColor.blue,
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                const CarerScreen(),
                LeisureScreen(key: leisureKey),
                const CreativityScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
