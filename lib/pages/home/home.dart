import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'widgets/action_buttons.dart';
import 'widgets/current_action_card.dart';
import 'widgets/device_status_bar.dart';
import 'widgets/home_header.dart';
import 'widgets/today_count_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static String routeName = 'home';
  static String routePath = '/home';

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
        child: const SingleChildScrollView(
          child: Column(
            children: [
              HomeHeader(),
              DeviceStatusBar(),
              CurrentActionCard(),
              TodayCountCard(),
              ActionButtons(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
