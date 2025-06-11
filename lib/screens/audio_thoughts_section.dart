import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioThoughtsSection extends StatefulWidget {
  final void Function(List<String>) onChanged;
  final List<String> initialPaths;
  final bool showDeleteButton;

  const AudioThoughtsSection({
    super.key,
    required this.onChanged,
    this.initialPaths = const [],
    this.showDeleteButton = true,
  });

  @override
  State<AudioThoughtsSection> createState() => _AudioThoughtsSectionState();
}

class _AudioThoughtsSectionState extends State<AudioThoughtsSection> {
  late List<File> audioFiles;
  FlutterSoundRecorder? _recorder;
  final AudioPlayer _player = AudioPlayer();
  bool isRecording = false;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    audioFiles = widget.initialPaths.map((p) => File(p)).toList();
    _recorder = FlutterSoundRecorder();
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _player.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _onMicTap() async {
    final micStatus = await Permission.microphone.status;

    if (micStatus.isGranted) {
      await _recorder!.openRecorder();
      await _startRecording();
    } else if (micStatus.isDenied || micStatus.isRestricted) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        await _recorder!.openRecorder();
        await _startRecording();
      } else {
        _showPermissionDialog();
      }
    } else if (micStatus.isPermanentlyDenied) {
      _showMicDeniedDialog();
    }
  }

  Future<void> _startRecording() async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${const Uuid().v4()}.aac';
    await _recorder!.startRecorder(toFile: path);
    setState(() {
      isRecording = true;
      _recordingDuration = Duration.zero;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordingDuration += const Duration(seconds: 1);
      });
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder?.stopRecorder();
    _recordingTimer?.cancel();
    if (path != null) {
      setState(() {
        audioFiles.add(File(path));
        isRecording = false;
      });
      widget.onChanged(audioFiles.map((f) => f.path).toList());
    }
  }

  void _showPermissionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Microphone Access Required'),
        content: const Text('Allow access to record your audio thoughts.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Not Now'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Allow'),
            onPressed: () async {
              Navigator.pop(context);
              final result = await Permission.microphone.request();
              if (result.isGranted) {
                await _recorder!.openRecorder();
                await _startRecording();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showMicDeniedDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Microphone access denied'),
        content: const Text('Enable microphone permission in Settings.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Open Settings'),
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAudio(int index) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete this audio?'),
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
    );

    if (confirmed ?? false) {
      setState(() {
        audioFiles.removeAt(index);
      });
      widget.onChanged(audioFiles.map((f) => f.path).toList());
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AUDIO THOUGHTS',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                for (int i = 0; i < audioFiles.length; i++)
                  _buildAudioCard(audioFiles[i], i),
              ],
            ),
            if (!isRecording &&
                audioFiles.length < 5 &&
                widget.showDeleteButton) ...[
              SizedBox(height: 16.h),
              _buildRecordButton(),
            ]
          ],
        ),
        if (isRecording) ...[
          SizedBox(height: 16.h),
          _buildRecordingIndicator(),
        ]
      ],
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _onMicTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Row(
      children: [
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: const Icon(Icons.stop, color: Colors.white),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          'Recording... ${_formatDuration(_recordingDuration)}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioCard(File file, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AudioPlayerSlider(file: file),
        if (widget.showDeleteButton)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _deleteAudio(index),
              icon: const Icon(Icons.delete, size: 16, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          )
      ],
    );
  }
}

class _AudioPlayerSlider extends StatefulWidget {
  final File file;
  const _AudioPlayerSlider({required this.file});

  @override
  State<_AudioPlayerSlider> createState() => _AudioPlayerSliderState();
}

class _AudioPlayerSliderState extends State<_AudioPlayerSlider> {
  final AudioPlayer _player = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.setSource(DeviceFileSource(widget.file.path));
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.file.path));
    }
    setState(() => isPlaying = !isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: position.inMilliseconds.toDouble(),
                min: 0,
                max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                onChanged: (value) {
                  _player.seek(Duration(milliseconds: value.toInt()));
                },
              ),
              Text(
                '${_format(position)} / ${_format(duration)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _format(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}
