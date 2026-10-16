import 'package:flutter/material.dart';

import '../../../../general/config/colors.dart';
import '../../../../general/utils/responsive.dart';

class CustomBloodGroupBox extends StatefulWidget {
  /// Se llama cada vez que el usuario elige un grupo ("A+", "O-", ...)
  final ValueChanged<String>? onChanged;

  /// Grupo seleccionado al inicio. Si es null, no hay ninguno seleccionado.
  final String? initialValue;

  const CustomBloodGroupBox({super.key, this.onChanged, this.initialValue});

  @override
  State<CustomBloodGroupBox> createState() => _CustomBloodGroupBoxState();
}

class _CustomBloodGroupBoxState extends State<CustomBloodGroupBox> {
  static const bloodList = ["A+", "B+", "AB+", "O+", "A-", "B-", "AB-", "O-"];
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = bloodList.indexOf(widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant CustomBloodGroupBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el valor inicial cambia desde afuera (por ejemplo, al cargar el perfil)
    if (widget.initialValue != oldWidget.initialValue) {
      selectedIndex = bloodList.indexOf(widget.initialValue ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: twentyPixelWidth(context) * 1.25,
              mainAxisSpacing: twentyPixelHeight(context) * 1),
          itemCount: bloodList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.onChanged?.call(bloodList[index]);
              },
              child: Container(
                  width: twentyPixelWidth(context) * 2.5,
                  height: twentyPixelWidth(context) * 2.5,
                  decoration: ShapeDecoration(
                    color: selectedIndex == index
                        ? AppColor.redColor
                        : AppColor.whiteColor,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 1, color: AppColor.redColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      bloodList[index],
                      style: TextStyle(
                        color: selectedIndex == index
                            ? AppColor.whiteColor
                            : AppColor.redColor,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                      textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                    ),
                  )),
            );
          }),
    );
  }
}
