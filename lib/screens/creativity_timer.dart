import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import 'models/creative_idea_model.dart';

class CreativityTimer extends StatefulWidget {
  final VoidCallback onReset;
  final ValueChanged<Duration> onTick;

  const CreativityTimer(
      {super.key, required this.onReset, required this.onTick});

  @override
  State<CreativityTimer> createState() => _CreativityTimerState();
}

class _CreativityTimerState extends State<CreativityTimer> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  bool _canReset = false;

  final TextEditingController _noteController = TextEditingController();
  late Box<CreativeIdeaModel> _ideaBox;

  @override
  void initState() {
    super.initState();
    _ideaBox = GetIt.I<Box<CreativeIdeaModel>>();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
        widget.onTick(_elapsed);
      });
    }
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) _canReset = true;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsed = Duration.zero;
      _isRunning = false;
      _canReset = false;
    });
    widget.onReset();
  }

  void _saveIdea() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    final idea = CreativeIdeaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: _formatDuration(_elapsed),
    );
    await _ideaBox.put(idea.id, idea);
    _noteController.clear();
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNoteValid = _noteController.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF353637).withOpacity(0.1),
            blurRadius: 48,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildPlayPauseButton()),
              Expanded(child: _buildTimeBlock(_elapsed.inHours, 'HOURS')),
              Expanded(
                  child: _buildTimeBlock(
                      _elapsed.inMinutes.remainder(60), 'MINUTES')),
              Expanded(
                  child: _buildTimeBlock(
                      _elapsed.inSeconds.remainder(60), 'SECONDS')),
            ],
          ),
          SizedBox(height: 24.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'IDEA',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF353637).withOpacity(0.1),
                            blurRadius: 48,
                            offset: const Offset(0, 0),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 1,
                        style: TextStyle(fontSize: 16.sp, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Enter a note',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: isNoteValid ? _saveIdea : null,
                      child: Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: isNoteValid
                              ? Colors.blue
                              : Colors.blue.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(56.r),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Click here',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            SvgPicture.asset(
                              'assets/icons/pin.svg',
                              width: 20.w,
                              height: 20.h,
                              colorFilter: const ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: _canReset ? _resetTimer : null,
                child: Container(
                  width: 90.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color:
                        _canReset ? Colors.blue : Colors.blue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: _toggleTimer,
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: Icon(
          _isRunning ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTimeBlock(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
