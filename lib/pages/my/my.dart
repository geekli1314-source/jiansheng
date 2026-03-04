import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_controller.dart';
import 'widgets/my_header.dart';
import 'widgets/privacy_card.dart';
import 'widgets/profile_card.dart';
import 'widgets/system_settings_card.dart';
import 'widgets/training_objectives_card.dart';

class MyView extends GetView<MyController> {
  const MyView({super.key});

  static String routeName = 'my';
  static String routePath = '/my';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFF6FF), Colors.white],
            stops: [0.5, 0.8],
            begin: Alignment(1, 1),
            end: Alignment(-1, -1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
          child: ListView(
            padding: EdgeInsets.zero,
            primary: false,
            shrinkWrap: true,
            children: const [
              MyHeader(),
              ProfileCard(),
              TrainingObjectivesCard(),
              SystemSettingsCard(),
              PrivacyCard(),
            ],
          ),
        ),
      ),
    );
  }
}
