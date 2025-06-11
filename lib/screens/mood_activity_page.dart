import 'package:flow_state_work_relax_223a/screens/activity_detail_page.dart';
import 'package:flow_state_work_relax_223a/screens/create_edit_activity_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'models/activity_model.dart';

class MoodActivityPage extends StatefulWidget {
  final String moodTitle;
  final String moodDescription;
  final Color tagColor;

  const MoodActivityPage({
    super.key,
    required this.moodTitle,
    required this.moodDescription,
    required this.tagColor,
  });

  @override
  State<MoodActivityPage> createState() => _MoodActivityPageState();
}

class _MoodActivityPageState extends State<MoodActivityPage> {
  late List<ActivityModel> _activities;
  late List<ActivityModel> _filteredActivities;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() {
    final box = GetIt.I<Box<ActivityModel>>();
    _activities = box.values
        .where(
            (a) => a.category.toLowerCase() == widget.moodTitle.toLowerCase())
        .toList();

    _activities.sort((a, b) {
      final dateTimeA = _parseDateTime(a.date, a.time);
      final dateTimeB = _parseDateTime(b.date, b.time);
      return dateTimeB.compareTo(dateTimeA);
    });

    _applySearch();
  }

  void _applySearch() {
    setState(() {
      _filteredActivities = _activities.where((activity) {
        final nameMatch =
            activity.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final tagMatch =
            activity.moodTag.toLowerCase().contains(_searchQuery.toLowerCase());
        return nameMatch || tagMatch;
      }).toList();
    });
  }

  DateTime _parseDateTime(String date, String time) {
    try {
      final parsedDate = DateFormat('dd.MM.yyyy').parse(date);
      final parsedTime = DateFormat.jm().parse(time);
      return DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> _navigateToAddActivity() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateEditActivityPage(moodTag: widget.moodTitle),
      ),
    );

    if (result != null && result is ActivityModel) {
      setState(() => _loadActivities());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FC),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 70.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24.r),
                          bottomRight: Radius.circular(24.r),
                        ),
                        child: Image.asset(
                          backgroundAsset,
                          width: double.infinity,
                          height: 225.h,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      Positioned(
                        top: 16.h,
                        left: 16.w,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 50.w,
                            height: 50.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Transform.translate(
                                offset: Offset(5.w, 0),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.blue,
                                  size: 25.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.moodTitle.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.moodDescription,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Divider(color: Colors.grey[300]),
                        if (_activities.length >= 5) SizedBox(height: 8.h),
                        if (_activities.length >= 5) _searchBar(),
                      ],
                    ),
                  ),
                  if (_activities.isEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 475.h,
                      child: Center(
                        child: Text(
                          'There are no activities in this category',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      itemCount: _filteredActivities.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _buildActivityCard(_filteredActivities[index]),
                        );
                      },
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 24.h,
              left: 20.w,
              right: 20.w,
              child: _addActivityButton(),
            ),
          ],
        ),
      ),
    );
  }

  String get backgroundAsset {
    final mood = widget.moodTitle.toLowerCase();
    if (mood == 'serenity') return 'assets/images/bg_serenity.png';
    if (mood == 'melancholy') return 'assets/images/bg_melancholy.png';
    if (mood == 'happiness') return 'assets/images/bg_happiness.png';
    if (mood == 'romance') return 'assets/images/bg_romance.png';
    throw Exception('Unknown mood title: ${widget.moodTitle}');
  }

  Widget _searchBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black45),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _applySearch();
              },
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.black45, fontSize: 16.sp),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    final itemKey = GlobalKey();

    return GestureDetector(
      key: itemKey,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActivityDetailPage(activity: activity),
          ),
        ).then((updated) {
          if (updated == true) {
            setState(() => _loadActivities());
          }
        });
      },
      onLongPress: () async {
        final RenderBox renderBox =
            itemKey.currentContext!.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final selected = await showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + renderBox.size.height,
            offset.dx + 1,
            offset.dy + renderBox.size.height + 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          color: Colors.white,
          shadowColor: Colors.black54,
          elevation: 8,
          items: [
            PopupMenuItem(
              value: 'EDIT',
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/ediit.svg', height: 20),
                  SizedBox(width: 8.w),
                  Text(
                    'EDIT ACTIVITY',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'DELETE',
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/delete.svg', height: 20),
                  SizedBox(width: 8.w),
                  Text(
                    'DELETE ACTIVITY',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if (selected == 'EDIT') {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateEditActivityPage(
                isEdit: true,
                moodTag: widget.moodTitle,
                existingActivity: activity,
              ),
            ),
          );
          if (updated != null) setState(() => _loadActivities());
        } else if (selected == 'DELETE') {
          final confirmed = await showCupertinoDialog<bool>(
            context: context,
            builder: (_) => CupertinoTheme(
              data: const CupertinoThemeData(brightness: Brightness.light),
              child: CupertinoAlertDialog(
                title:
                    const Text('Do you really want to delete this activity?'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: const Text('Delete'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            ),
          );
          if (confirmed ?? false) {
            await activity.delete();
            setState(() => _loadActivities());
          }
        }
      },
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8.w,
              children: [
                if (activity.hasVoice)
                  _buildTag('VOICE', Colors.white,
                      iconPath: 'assets/icons/voice.svg'),
                if (activity.hasText)
                  _buildTag('TEXT', Colors.white,
                      iconPath: 'assets/icons/text.svg'),
                if (activity.moodTag.isNotEmpty)
                  _buildTag(activity.moodTag, widget.tagColor),
              ],
            ),
            Text(
              activity.name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
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
    );
  }

  Widget _buildTag(String label, Color bgColor, {String? iconPath}) {
    final isVoiceOrText =
        label.toUpperCase() == 'VOICE' || label.toUpperCase() == 'TEXT';
    final textColor = isVoiceOrText ? const Color(0xFF019BE3) : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null)
                Row(
                  children: [
                    SvgPicture.asset(
                      iconPath,
                      height: 14.h,
                      width: 14.w,
                      colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                    ),
                    SizedBox(width: 4.w),
                  ],
                ),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _addActivityButton() {
    return GestureDetector(
      onTap: _navigateToAddActivity,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 3.w,
              child: SvgPicture.asset(
                "assets/icons/icon.svg",
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                height: 44.h,
              ),
            ),
            Text(
              'Add activity',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
