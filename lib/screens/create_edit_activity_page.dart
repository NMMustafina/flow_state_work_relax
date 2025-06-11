import 'package:flow_state_work_relax_223a/fswr/fswr_color.dart';
import 'package:flow_state_work_relax_223a/screens/audio_thoughts_section.dart';
import 'package:flow_state_work_relax_223a/screens/text_thoughts_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'models/activity_model.dart';

class CreateEditActivityPage extends StatefulWidget {
  final bool isEdit;
  final String moodTag;
  final ActivityModel? existingActivity;

  const CreateEditActivityPage({
    super.key,
    this.isEdit = false,
    required this.moodTag,
    this.existingActivity,
  });

  @override
  State<CreateEditActivityPage> createState() => _CreateEditActivityPageState();
}

class _CreateEditActivityPageState extends State<CreateEditActivityPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController textThoughtsController = TextEditingController();
  TimeOfDay? selectedTime;
  DateTime? selectedDate;
  List<String> audioPaths = [];

  bool hasChanges = false;

  late Box<ActivityModel> activityBox;

  bool get isFormValid =>
      nameController.text.trim().isNotEmpty &&
      selectedTime != null &&
      selectedDate != null;

  @override
  void initState() {
    super.initState();
    activityBox = GetIt.I<Box<ActivityModel>>();

    if (widget.existingActivity != null) {
      final a = widget.existingActivity!;
      nameController.text = a.name;
      tagController.text = a.moodTag;
      textThoughtsController.text = a.textThoughts ?? '';
      audioPaths = a.audioPaths;
      selectedTime = _parseTime(a.time);
      selectedDate = _parseDate(a.date);
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final now = TimeOfDay.now();
    try {
      final parts = timeStr.split(RegExp(r'[:\s]'));
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final isPM = timeStr.toLowerCase().contains('pm');
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return now;
    }
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('.');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  void _onSave() async {
    final isEdit = widget.isEdit && widget.existingActivity != null;

    final activity = ActivityModel(
      id: isEdit ? widget.existingActivity!.id : const Uuid().v4(),
      name: nameController.text.trim(),
      moodTag: tagController.text.trim(),
      category: widget.moodTag,
      time: selectedTime!.format(context),
      date: _formattedDateValue(),
      textThoughts: textThoughtsController.text.trim(),
      audioPaths: audioPaths,
    );

    await activityBox.put(activity.id, activity);
    Navigator.pop(context, activity);
  }

  void _pickTime() {
    DateTime now = DateTime.now();
    TimeOfDay initialTime =
        selectedTime ?? TimeOfDay(hour: now.hour, minute: now.minute);
    DateTime initialDateTime = DateTime(
        now.year, now.month, now.day, initialTime.hour, initialTime.minute);
    DateTime tempDateTime = initialDateTime;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CupertinoPickerWrapper(
        onDone: () {
          setState(() {
            selectedTime = TimeOfDay.fromDateTime(tempDateTime);
            hasChanges = true;
          });
        },
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: initialDateTime,
          use24hFormat: false,
          onDateTimeChanged: (DateTime value) {
            tempDateTime = value;
          },
        ),
      ),
    );
  }

  void _pickDate() {
    DateTime now = DateTime.now();
    DateTime initial = selectedDate ?? now;
    DateTime tempDate = initial;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CupertinoPickerWrapper(
        onDone: () {
          setState(() {
            selectedDate = tempDate;
            hasChanges = true;
          });
        },
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: initial,
          onDateTimeChanged: (DateTime value) {
            tempDate = value;
          },
        ),
      ),
    );
  }

  String _formattedDateValue() {
    return '${selectedDate!.day.toString().padLeft(2, '0')}.'
        '${selectedDate!.month.toString().padLeft(2, '0')}.'
        '${selectedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isSaveEnabled =
        widget.isEdit ? hasChanges && isFormValid : isFormValid;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          widget.isEdit ? 'EDIT ACTIVITY' : 'NEW ACTIVITY',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('NAME'),
              SizedBox(height: 8.h),
              _inputField(
                  controller: nameController,
                  hint: 'Required',
                  onChanged: (_) => setState(() => hasChanges = true)),
              SizedBox(height: 24.h),
              _label('TAG'),
              SizedBox(height: 8.h),
              _inputField(
                  controller: tagController,
                  hint: 'Not Required',
                  onChanged: (_) => setState(() => hasChanges = true)),
              SizedBox(height: 24.h),
              AudioThoughtsSection(
                initialPaths: audioPaths,
                onChanged: (paths) {
                  setState(() {
                    audioPaths = paths;
                    hasChanges = true;
                  });
                },
              ),
              SizedBox(height: 24.h),
              TextThoughtsSection(
                controller: textThoughtsController,
                onChanged: (_) => setState(() => hasChanges = true),
              ),
              SizedBox(height: 24.h),
              _label('TIME'),
              SizedBox(height: 8.h),
              _pickerTile(
                  text: selectedTime?.format(context) ?? 'Select',
                  onTap: _pickTime),
              SizedBox(height: 24.h),
              _label('DATE'),
              SizedBox(height: 8.h),
              _pickerTile(
                  text: selectedDate != null ? _formattedDateValue() : 'Select',
                  onTap: _pickDate),
              SizedBox(height: 32.h),
              _buildButton(isSaveEnabled),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    void Function(String)? onChanged,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      style: TextStyle(fontSize: 16.sp, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _pickerTile({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(fontSize: 16.sp, color: Colors.black)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(bool isEnabled) {
    return GestureDetector(
      onTap: isEnabled ? _onSave : null,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF019BE3) : const Color(0xFF8DBEF3),
          borderRadius: BorderRadius.circular(56.r),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.isEdit ? 'Save' : 'Add',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp),
        ),
      ),
    );
  }
}

class _CupertinoPickerWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDone;

  const _CupertinoPickerWrapper({required this.child, this.onDone});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250.h,
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.light,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text("Cancel",
                        style:
                            TextStyle(color: FSWRColor.blue, fontSize: 16.sp)),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (onDone != null) onDone!();
                      Navigator.pop(context);
                    },
                    child: Text("Done",
                        style:
                            TextStyle(color: FSWRColor.blue, fontSize: 16.sp)),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              color: Color(0xFFE0E0E0),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
