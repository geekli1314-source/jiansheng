import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'history_controller.dart';
import 'widgets/history_header.dart';
import 'widgets/date_selector.dart';
import 'widgets/activity_day_card.dart';

class HistoryWidget extends GetView<HistoryController> {
  const HistoryWidget({super.key});

  static String routeName = 'history';
  static String routePath = '/history';

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
          padding: const EdgeInsets.only(top: 60),
          child: Obx(() {
            final isDateFiltered = controller.selectedDate.value.isNotEmpty;
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // Pull up to load more (only in non-date filter mode)
                if (!isDateFiltered &&
                    scrollInfo is ScrollEndNotification &&
                    scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
                  controller.loadMoreData();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () => controller.loadInitialData(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: const [
                          HistoryHeader(),
                          DateSelector(),
                        ],
                      ),
                    ),
                    Obx(() {
                      if (controller.records.isEmpty && !controller.isLoading.value) {
                        return SliverToBoxAdapter(
                          child: Container(
                            height: 200,
                            alignment: Alignment.center,
                            child: const Text(
                              'No records yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < controller.records.length) {
                              return ActivityDayCard(
                                record: controller.records[index],
                              );
                            }
                            return null;
                          },
                          childCount: controller.records.length,
                        ),
                      );
                    }),
                    // Load more indicator (only show in non-date filter mode)
                    Obx(() {
                      if (isDateFiltered) {
                        return const SliverToBoxAdapter(child: SizedBox.shrink());
                      }
                      if (controller.isLoading.value) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }
                      if (!controller.hasMore.value && controller.records.isNotEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No more records',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 30),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
