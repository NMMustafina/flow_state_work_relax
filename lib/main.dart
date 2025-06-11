import 'package:flow_state_work_relax_223a/screens/models/activity_model.dart';
import 'package:flow_state_work_relax_223a/screens/models/creative_idea_model.dart';
import 'package:flow_state_work_relax_223a/screens/models/taskoo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import 'fswr/fswr_bord.dart';
import 'fswr/fswr_color.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskooModelAdapter());
  Hive.registerAdapter(ActivityModelAdapter());
  Hive.registerAdapter(CreativeIdeaModelAdapter());

  final box = await Hive.openBox<ActivityModel>('activityBox');
  GetIt.I.registerSingleton<Box<ActivityModel>>(box);

  final haikuBox = await Hive.openBox<TaskooModel>('haikuBox');
  GetIt.I.registerSingleton<Box<TaskooModel>>(haikuBox);

  final creativeBox = await Hive.openBox<CreativeIdeaModel>('creativeBox');
  GetIt.I.registerSingleton<Box<CreativeIdeaModel>>(creativeBox);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AntiqueLedger - Precious Opus',
        theme: ThemeData(
          brightness: Brightness.dark,
          appBarTheme: const AppBarTheme(
            backgroundColor: FSWRColor.bg,
            iconTheme: IconThemeData(
              color: FSWRColor.white,
            ),
          ),
          scaffoldBackgroundColor: FSWRColor.bg,
          fontFamily: 'Inter',
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        home: OnboardingScreen(),
      ),
    );
  }
}
