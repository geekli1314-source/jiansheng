import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../history_controller.dart';

class DateSelector extends GetView<HistoryController> {
  const DateSelector({super.key});

  void _showDatePicker(BuildContext context) {
    DateTime tempDate =
        controller.selectedDate.value.isNotEmpty
            ? DateTime.tryParse(controller.selectedDate.value) ?? DateTime.now()
            : DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部拖动条
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题栏
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF8E8E93),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      'Select Date',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final formatted =
                            '${tempDate.year}-'
                            '${tempDate.month.toString().padLeft(2, '0')}-'
                            '${tempDate.day.toString().padLeft(2, '0')}';
                        controller.selectDate(formatted);
                        Get.back();
                      },
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 分割线
              Container(
                height: 0.5,
                color: const Color(0xFFD1D1D6),
              ),
              // iOS 滚轮日期选择器
              SizedBox(
                height: 260,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate,
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (date) {
                    tempDate = date;
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
      child: Obx(() {
        final hasDate = controller.selectedDate.value.isNotEmpty;
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showDatePicker(context),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10,
                        color: Color(0x0C000000),
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hasDate ? controller.selectedDate.value : 'Select date',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            letterSpacing: 0.0,
                            color: hasDate
                                ? const Color(0xFF1C1C1E)
                                : const Color(0xFF9CA3AF),
                            fontWeight: hasDate ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (hasDate) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => controller.clearDateFilter(),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.clear,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
