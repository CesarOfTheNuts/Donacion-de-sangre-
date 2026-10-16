import 'package:flutter/material.dart';

import '../../../../general/config/colors.dart';
import '../../../../general/utils/blank_space.dart';
import '../../../../general/utils/responsive.dart';

class FindDonorDatePicker extends StatefulWidget {
  /// Se llama con la fecha elegida
  final ValueChanged<DateTime>? onChanged;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const FindDonorDatePicker({
    super.key,
    this.onChanged,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<FindDonorDatePicker> createState() => _FindDonorDatePickerState();
}

class _FindDonorDatePickerState extends State<FindDonorDatePicker> {
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  Future<void> _pickDate(BuildContext context) async {
    final first = widget.firstDate ?? DateTime(2000);
    final last = widget.lastDate ?? DateTime(2050);
    var start = _date ?? DateTime.now();
    if (start.isBefore(first)) start = first;
    if (start.isAfter(last)) start = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: first,
      lastDate: last,
    );
    if (picked == null) return; // el usuario canceló
    setState(() => _date = picked);
    widget.onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final text = _date == null
        ? "Choose Date"
        : '${_date!.day}-${_date!.month}-${_date!.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            height: twentyPixelHeight(context) * 2,
            decoration: BoxDecoration(
                color: AppColor.textLight,
                borderRadius: BorderRadius.circular(5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                horizontalSpace(twentyPixelWidth(context) * .5),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColor.textAss,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w300,
                  ),
                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                ),
              ],
            ),
          ),
        ),
        horizontalSpace(twentyPixelWidth(context)),
        InkWell(
          onTap: () => _pickDate(context),
          child: Container(
            height: twentyPixelHeight(context) * 2,
            width: twentyPixelWidth(context) * 3,
            decoration: BoxDecoration(
                color: AppColor.redColor,
                borderRadius: BorderRadius.circular(5)),
            child: const Icon(
              Icons.calendar_month,
              color: AppColor.textLight,
            ),
          ),
        ),
      ],
    );
  }
}
