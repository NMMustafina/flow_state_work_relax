import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'nastr_screen.dart';

class CreativScreen extends StatelessWidget {
  const CreativScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE), // подложка как на скрине
      body: const Center(
        child: Text('Carer Screen'),
      ),
      floatingActionButton: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.grey,
            size: 34,
          ),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (c) => const SettingsScreen()));
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
