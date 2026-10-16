import 'package:flutter/material.dart';

import '../../../../general/utils/responsive.dart';

class CustomRedBtn extends StatelessWidget {
  final String textt;
  final Color textColor;
  final Color fillColor;
  final Color? borderClr;
  final VoidCallback? onTap;
  final bool loading;

  const CustomRedBtn({
    super.key,
    required this.textt,
    required this.textColor,
    required this.fillColor,
    this.borderClr,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading ? null : onTap,
      child: Container(
        padding: EdgeInsets.only(
          top: twentyPixelHeight(context) * .85,
          bottom: twentyPixelHeight(context) * .85,
        ),
        decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderClr ?? textColor)),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: textColor),
                )
              : Text(
                  textt,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    fontFamily: "Poppins",
                  ),
                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                ),
        ),
      ),
    );
  }
}
