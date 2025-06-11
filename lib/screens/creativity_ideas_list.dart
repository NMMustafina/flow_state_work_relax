import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'models/creative_idea_model.dart';

class CreativityIdeasList extends StatelessWidget {
  final List<CreativeIdeaModel> ideas;

  const CreativityIdeasList({super.key, required this.ideas});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(ideas.length, (index) {
        final idea = ideas[index];
        final GlobalKey itemKey = GlobalKey();

        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: GestureDetector(
            key: itemKey,
            onLongPress: () async {
              final RenderBox renderBox =
                  itemKey.currentContext!.findRenderObject() as RenderBox;
              final Offset offset = renderBox.localToGlobal(Offset.zero);
              final selected = await showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy + renderBox.size.height + 8,
                  offset.dx + 1,
                  offset.dy + renderBox.size.height + 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                color: Colors.white,
                shadowColor: Colors.black38,
                elevation: 4,
                items: [
                  PopupMenuItem(
                    value: 'DELETE',
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/delete.svg'),
                        SizedBox(width: 8.w),
                        Text(
                          'DELETE IDEA',
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

              if (selected == 'DELETE') {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoTheme(
                      data: const CupertinoThemeData(
                        brightness: Brightness.light,
                      ),
                      child: CupertinoAlertDialog(
                        title: const Text(
                            'Do you really want to delete this idea?'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: const Text('Delete'),
                            onPressed: () async {
                              await idea.delete();
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
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    idea.text,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          color: Colors.grey, size: 24.sp),
                      SizedBox(width: 6.w),
                      Text(
                        idea.timestamp,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
