import 'package:flow_state_work_relax_223a/screens/audio_thoughts_section.dart';
import 'package:flow_state_work_relax_223a/screens/create_edit_activity_page.dart';
import 'package:flow_state_work_relax_223a/screens/models/activity_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActivityDetailPage extends StatelessWidget {
  final ActivityModel activity;

  const ActivityDetailPage({super.key, required this.activity});

  Color get tagColor {
    final mood = activity.category.toLowerCase();
    if (mood == 'serenity') return const Color(0xFF7184CF);
    if (mood == 'melancholy') return const Color(0xFFCC691E);
    if (mood == 'happiness') return const Color(0xFF8FD8A8);
    if (mood == 'romance') return const Color(0xFFE7996E);
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.blue,
                      size: 24.sp,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'ACTIVITY',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 24.w),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/bg_card.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  activity.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (activity.moodTag.trim().isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(left: 8.w),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: tagColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    activity.moodTag.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${activity.time}  /  ${activity.date}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateEditActivityPage(
                                  isEdit: true,
                                  moodTag: activity.category,
                                  existingActivity: activity,
                                ),
                              ),
                            );
                            if (updated != null) Navigator.pop(context, true);
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset('assets/icons/ediit.svg',
                                height: 20),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () async {
                            final confirmed = await showCupertinoDialog<bool>(
                              context: context,
                              builder: (_) => CupertinoTheme(
                                data: const CupertinoThemeData(
                                    brightness: Brightness.light),
                                child: CupertinoAlertDialog(
                                  title: const Text(
                                      'Do you really want to delete this activity?'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                    CupertinoDialogAction(
                                      isDestructiveAction: true,
                                      child: const Text('Delete'),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            if (confirmed ?? false) {
                              await activity.delete();
                              Navigator.pop(context, true);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset('assets/icons/delete.svg',
                                height: 20),
                          ),
                        ),
                      ],
                    ),
                    if (activity.hasVoice) ...[
                      SizedBox(height: 24.h),
                      AudioThoughtsSection(
                        initialPaths: activity.audioPaths,
                        onChanged: (_) {},
                        showDeleteButton: false,
                      ),
                    ],
                    if (activity.hasText) ...[
                      SizedBox(height: 24.h),
                      Text(
                        'TEXT THOUGHTS',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        activity.textThoughts ?? '',
                        style:
                            TextStyle(fontSize: 16.sp, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
