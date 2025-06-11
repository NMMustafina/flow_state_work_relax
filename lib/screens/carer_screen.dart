import 'package:flow_state_work_relax_223a/fswr/fswr_color.dart';
import 'package:flow_state_work_relax_223a/fswr/fswr_moti.dart';
import 'package:flow_state_work_relax_223a/screens/models/taskoo_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'all_tasks_screen.dart';
import 'new_task_screen.dart';

class CarerScreen extends StatelessWidget {
  const CarerScreen({super.key});

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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Text(
                        'TASK LIST',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 30.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _buildAddButton(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewTaskScreen(),
                          ),
                        );
                      }),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: ValueListenableBuilder(
                      valueListenable:
                          GetIt.I.get<Box<TaskooModel>>().listenable(),
                      builder: (context, Box<TaskooModel> box, _) {
                        final maxItems = box.length > 4 ? 4 : box.length;
                        final showMore = box.length > 4;
                        final totalItems = showMore ? maxItems + 1 : maxItems;

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (showMore && index == maxItems) {
                                return Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.h, bottom: 20.h),
                                  child: Center(
                                    child: FswrMotiiButT(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AllTasksScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Show more',
                                        style: TextStyle(
                                          color: FSWRColor.blue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final task = box.getAt(index);
                              final GlobalKey itemKey = GlobalKey();

                              return Padding(
                                padding: EdgeInsets.only(bottom: 20.h),
                                child: GestureDetector(
                                  key: itemKey,
                                  onLongPress: () async {
                                    final RenderBox renderBox = itemKey
                                        .currentContext!
                                        .findRenderObject() as RenderBox;
                                    final Offset offset =
                                        renderBox.localToGlobal(Offset.zero);
                                    final selected = await showMenu(
                                      context: context,
                                      position: RelativeRect.fromLTRB(
                                        offset.dx,
                                        offset.dy + renderBox.size.height,
                                        offset.dx + 1,
                                        offset.dy + renderBox.size.height + 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                      color: Colors.white,
                                      shadowColor: Colors.black54,
                                      elevation: 8,
                                      items: [
                                        PopupMenuItem(
                                          value: 'EDIT TASK',
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/icons/ediit.svg'),
                                              SizedBox(width: 8.w),
                                              Text(
                                                'EDIT TASK',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18.sp,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'DELETE TASK',
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/icons/delete.svg'),
                                              SizedBox(width: 8.w),
                                              Text(
                                                'DELETE TASK',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18.sp,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                    if (selected == 'EDIT TASK') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NewTaskScreen(
                                            taskooModel: task,
                                          ),
                                        ),
                                      );
                                    } else if (selected == 'DELETE TASK') {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (context) {
                                          return CupertinoTheme(
                                            data: const CupertinoThemeData(
                                              brightness: Brightness.light,
                                            ),
                                            child: CupertinoAlertDialog(
                                              title: const Text('Delete the current task?'),
                                              actions: [
                                                CupertinoDialogAction(
                                                  child: const Text('Cancel'),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                                CupertinoDialogAction(
                                                  isDestructiveAction: true,
                                                  child: const Text('Delete'),
                                                  onPressed: () async {
                                                    await box.delete(task.key);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );

                                    }
                                  },
                                  child: _buildTaskItem(
                                    title: task!.title,
                                    subtitle: task.description ?? '',
                                    time: task.time,
                                    date: task.date,
                                    tag: task.category,
                                    isDone: task.isDone,
                                    onToggleDone: () async {
                                      final updatedTask = TaskooModel(
                                        title: task.title,
                                        description: task.description,
                                        time: task.time,
                                        date: task.date,
                                        category: task.category,
                                        isDone: !task.isDone, id: task.id,
                                      );

                                      await box.put(task.key, updatedTask);
                                    },

                                  ),
                                ),
                              );
                            },
                            childCount: totalItems,
                          ),
                        );
                      }),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 80.h),
                ),
              ],
            ),
          )
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
              color: Color(0xFF353637).withOpacity(0.1),
            ),
          ],
          color: Color(0xFFF7F8FD),
        ),
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
    );
  }

  Widget _buildAddButton(VoidCallback onTap) {
    return FswrMotiiButT(
      onPressed: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(56.r),
          color: FSWRColor.blue,
        ),
        width: double.infinity,
        height: 50.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Add task',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Icon(Icons.add)
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem({
    required String title,
    required String subtitle,
    required String time,
    required String date,
    required String tag,
    required bool isDone,
    required VoidCallback onToggleDone,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF353637).withOpacity(0.1),
            blurRadius: 48,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onToggleDone,
                child: SvgPicture.asset(
                  isDone
                      ? 'assets/icons/selected.svg'
                      : 'assets/icons/unselected.svg',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$time  /  $date',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 12.sp,
                ),
              ),
              Text(
                tag,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF181818).withOpacity(0.6),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
