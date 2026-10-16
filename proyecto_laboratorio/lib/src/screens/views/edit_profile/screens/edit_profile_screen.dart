import 'package:flutter/material.dart';

import '../../../../general/config/colors.dart';
import '../../../../general/utils/blank_space.dart';
import '../../../../general/utils/formatters.dart';
import '../../../../general/utils/responsive.dart';
import '../../../../services/api_service.dart';
import '../../components/widgets/custom_appbar.dart';
import '../../components/widgets/custom_blood_group_box.dart';
import '../../components/widgets/custom_form_textfield.dart';
import '../../components/widgets/custom_gender_box.dart';
import '../../components/widgets/custom_red_btn.dart';
import '../../components/widgets/custom_find_screen_item.dart';

class EditProfileScreen extends StatefulWidget {
  static const pageRoute = "/edit-profile";

  final Map<String, dynamic>? profile;

  const EditProfileScreen({super.key, this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _location;
  String? _gender;
  String? _blood;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile ?? const <String, dynamic>{};
    _name = TextEditingController(text: (p['nombre'] ?? '').toString());
    _phone = TextEditingController(text: (p['telefono'] ?? '').toString());
    _location = TextEditingController(text: (p['ubicacion'] ?? '').toString());
    final g = p['genero'];
    if (g is String && g.isNotEmpty) _gender = g.toLowerCase();
    final b = p['grupo_sanguineo'];
    if (b is String && b.isNotEmpty) _blood = b;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      showMsg(context, 'Name cannot be empty', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.actualizarPerfil(
        nombre: _name.text.trim(),
        telefono: _phone.text.trim(),
        ubicacion: _location.text.trim(),
        genero: _gender,
        grupoSanguineo: _blood,
      );
      if (!mounted) return;
      showMsg(context, 'Profile updated');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showMsg(context, errorText(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titlee: "Edit Profile", actionTrue: true, profileFalse: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomFormText(textt: 'Name', isRequired: true),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "Jorge Perez",
                prefixFalse: false,
                controller: _name,
              ),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(textt: 'Mobile Number', isRequired: false),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "+18092249304",
                prefixFalse: false,
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(textt: 'Location', isRequired: false),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "Santo Domingo, RD",
                prefixFalse: true,
                prefixxIcon: Icons.location_on,
                controller: _location,
              ),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(textt: 'Gender', isRequired: false),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomGenderBox(
                initialValue: _gender,
                onChanged: (v) => _gender = v,
              ),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(textt: 'Blood Group', isRequired: false),
              verticalSpace(twentyPixelHeight(context) * .5),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: twentyPixelWidth(context) * 1.5),
                child: CustomBloodGroupBox(
                  initialValue: _blood,
                  onChanged: (v) => _blood = v,
                ),
              ),
              verticalSpace(twentyPixelHeight(context) * 1.5),
              CustomRedBtn(
                textt: "Save",
                textColor: AppColor.whiteColor,
                fillColor: AppColor.redColor,
                borderClr: Colors.transparent,
                loading: _loading,
                onTap: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
