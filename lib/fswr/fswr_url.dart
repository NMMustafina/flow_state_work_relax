import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void fssrUrl(BuildContext context, String url) async {
  final Uri uriaktan = Uri.parse(url);
  if (!await launchUrl(uriaktan)) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not launch $uriaktan'),
      ),
    );
  }
}