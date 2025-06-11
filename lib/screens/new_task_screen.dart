import 'package:flow_state_work_relax_223a/fswr/fswr_color.dart';
import 'package:flow_state_work_relax_223a/fswr/fswr_moti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import 'models/taskoo_model.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key, this.taskooModel});

  final TaskooModel? taskooModel;

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  String selectedCategory = 'MAIN JOB';
  List<String> categories = ['MAIN JOB', 'FREELANCE', 'PART-TIME JOB', 'OTHER'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TimeOfDay? selectedTime;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    final task = widget.taskooModel;
    if (task != null) {
      titleController.text = task.title;
      descriptionController.text = task.description ?? '';
      selectedCategory = task.category;
      selectedTime = _parseTimeOfDay(task.time);
      selectedDate = _parseDate(task.date);
    }
  }

  TimeOfDay? _parseTimeOfDay(String time) {
    try {
      final parts = time.split(":");
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1].split(' ')[0]) ?? 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('.');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final month = int.tryParse(parts[1]) ?? 1;
        final year = int.tryParse(parts[2]) ?? 2020;
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }
  void _pickDate() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        DateTime now = DateTime.now();
        DateTime initialDate = selectedDate ?? now;

        return Container(
          height: 250.h,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text("Cancel",
                          style: TextStyle(
                              color: FSWRColor.blue, fontSize: 16.sp)),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedDate = initialDate);
                        Navigator.pop(context);
                      },
                      child: Text("Done",
                          style: TextStyle(
                              color: FSWRColor.blue, fontSize: 16.sp)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate ?? DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() => selectedDate = newDate);
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _pickTime() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        TimeOfDay tempTime = selectedTime ?? TimeOfDay.now();
        DateTime now = DateTime.now();
        DateTime initialDateTime = DateTime(
            now.year, now.month, now.day, tempTime.hour, tempTime.minute);

        return Container(
          height: 250.h,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text("Cancel",
                          style: TextStyle(
                              color: FSWRColor.blue, fontSize: 16.sp)),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedTime =
                            TimeOfDay.fromDateTime(initialDateTime));
                        Navigator.pop(context);
                      },
                      child: Text("Done",
                          style: TextStyle(
                              color: FSWRColor.blue, fontSize: 16.sp)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: initialDateTime,
                    use24hFormat: false,
                    onDateTimeChanged: (DateTime newDateTime) {
                      initialDateTime = newDateTime;
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  String getFormattedDate() {
    if (selectedDate == null) return 'Select';
    return '${selectedDate!.day.toString().padLeft(2, '0')}.'
        '${selectedDate!.month.toString().padLeft(2, '0')}.'
        '${selectedDate!.year}';
  }

  bool get isFormValid =>
      titleController.text.trim().isNotEmpty &&
      selectedTime != null &&
      selectedDate != null;

  void _onSave() async {
    if (isFormValid) {
      final taskid = widget.taskooModel?.id ?? DateTime.now().toIso8601String();
      final addTaskk = TaskooModel(
        id: taskid,
        title: titleController.text.trim(),
        category: selectedCategory,
        time: selectedTime!.format(context),
        date: getFormattedDate(),
        description: descriptionController.text.trim(),
      );

      var rec = GetIt.I.get<Box<TaskooModel>>();
      await rec.put(taskid, addTaskk);

      Navigator.pop(context, addTaskk);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FswrMotiiButT(
          onPressed: ()=>Navigator.of(context).pop(),
          child: SvgPicture.asset('assets/icons/back.svg'),
        ),
        title: Text(
          widget.taskooModel == null?'NEW TASK':'EDIT TASK',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text('TITLE',
                  style: TextStyle(color: Colors.black, fontSize: 16.sp)),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildTextField(
                  controller: titleController, hint: 'Required'),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text('CATEGORY',
                  style: TextStyle(color: Colors.black, fontSize: 16.sp)),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 44.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedCategory = category),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 26.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text('DESCRIPTION',
                  style: TextStyle(color: Colors.black, fontSize: 16.sp)),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildTextField(
                  controller: descriptionController,
                  hint: 'Not Required',
                  maxLines: 4),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text('TIME',
                  style: TextStyle(color: Colors.black, fontSize: 16.sp)),
            ),
            SizedBox(height: 16.h),
            FswrMotiiButT(
              onPressed: _pickTime,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                height: 56.h,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF353637).withOpacity(0.1),
                      blurRadius: 48,
                      offset: const Offset(0, 0),
                    )
                  ],
                  borderRadius: BorderRadius.circular(20.r),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedTime != null
                          ? selectedTime!.format(context)
                          : 'Select',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: FSWRColor.blue,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'DATE',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            FswrMotiiButT(
              onPressed: _pickDate,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                height: 56.h,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF353637).withOpacity(0.1),
                      blurRadius: 48,
                      offset: const Offset(0, 0),
                    )
                  ],
                  borderRadius: BorderRadius.circular(20.r),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getFormattedDate(),
                        style: TextStyle(fontSize: 16.sp, color: Colors.black)),
                    const Icon(Icons.arrow_forward_ios_sharp,
                        color: FSWRColor.blue, size: 18),
                  ],
                ),
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FswrMotiiButT(
        onPressed: isFormValid
            ? () {
                _onSave();
              }
            : null,
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 50.h,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(56.r),
            color: isFormValid ? FSWRColor.blue : const Color(0xFF8DBEF3),
          ),
          child: Text(
            widget.taskooModel == null ? 'Add':'Edit',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF353637).withOpacity(0.1),
            blurRadius: 48,
            offset: const Offset(0, 0),
          )
        ],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
        cursorColor: FSWRColor.blue,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: Color(0xFF181818).withOpacity(0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }
}
