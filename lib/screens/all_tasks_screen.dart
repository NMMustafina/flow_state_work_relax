import 'package:flow_state_work_relax_223a/fswr/fswr_color.dart';
import 'package:flow_state_work_relax_223a/fswr/fswr_moti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../generated/assets.dart';
import 'models/taskoo_model.dart';
import 'new_task_screen.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> filters = [
      'ALL',
      'COMPLETED',
      'IN THE PROCESS',
      'MAIN JOB',
      'FREELANCE',
      'Part-time job'.toUpperCase(),
      'other'.toUpperCase(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: FswrMotiiButT(
          onPressed: () => Navigator.of(context).pop(),
          child: SvgPicture.asset(Assets.iconsBack),
        ),
        title: Text(
          'ALL THE TASKS',
          style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF181818)),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
            valueListenable: GetIt.I.get<Box<TaskooModel>>().listenable(),
            builder: (context, Box<TaskooModel> box, _) {
              final List<TaskooModel> allTasks = box.values.toList();
              final filteredTasks = selectedTab == 0
                  ? allTasks
                  : selectedTab == 1
                  ? allTasks.where((task) => task.isDone).toList()
                  : selectedTab == 2
                  ? allTasks.where((task) => !task.isDone).toList()
                  : allTasks
                  .where((task) =>
              task.category.toUpperCase() == filters[selectedTab])
                  .toList();

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemBuilder: (context, index) {
                          final isSelected = selectedTab == index;
                          return Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: GestureDetector(
                              onTap: () => setState(() => selectedTab = index),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 26.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? FSWRColor.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  filters[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : FSWRColor.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = filteredTasks[index];
                          final GlobalKey itemKey = GlobalKey();
                          return Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: GestureDetector(
                              key: itemKey,
                              onLongPress: () async {
                                final RenderBox renderBox =
                                    itemKey.currentContext!.findRenderObject()
                                        as RenderBox;
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
                                    borderRadius: BorderRadius.circular(16.r),
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
                                title: task.title,
                                subtitle: task.description ?? '',
                                time: task.time,
                                date: task.date,
                                tag: task.category,
                                isDone: task.isDone,
                                onToggleDone: () async {
                                  final updatedTask = task.copyWith(isDone: !task.isDone);
                                  await box.put(task.key, updatedTask);

                                },
                              ),
                            ),
                          );
                        },
                        childCount: filteredTasks.length,
                      ),
                    ),
                  ),
                ],
              );
            }),
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
