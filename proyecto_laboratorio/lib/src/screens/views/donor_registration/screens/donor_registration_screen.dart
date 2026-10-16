import 'package:flutter/material.dart';

import '../../../../general/config/colors.dart';
import '../../../../general/utils/blank_space.dart';
import '../../../../general/utils/formatters.dart';
import '../../../../general/utils/responsive.dart';
import '../../../../services/api_service.dart';
import '../../components/widgets/custom_appbar.dart';
import '../../components/widgets/custom_blood_group_box.dart';
import '../../components/widgets/custom_find_screen_item.dart';
import '../../components/widgets/custom_form_textfield.dart';
import '../../components/widgets/custom_red_btn.dart';
import '../../components/widgets/find_donor_date_picker.dart';

class DonorRegistrationForm extends StatefulWidget {
  static const pageRoute = "/donor-registraion";

  const DonorRegistrationForm({super.key});

  @override
  State<DonorRegistrationForm> createState() => _DonorRegistrationFormState();
}

class _DonorRegistrationFormState extends State<DonorRegistrationForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();

  String _blood = 'A+';
  DateTime? _lastDonation;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  // Rellena el formulario con los datos del perfil (si los hay)
  Future<void> _prefill() async {
    try {
      final p = await ApiService.miPerfil();
      if (!mounted) return;
      setState(() {
        if (_name.text.isEmpty) _name.text = (p['nombre'] ?? '').toString();
        if (_phone.text.isEmpty) _phone.text = (p['telefono'] ?? '').toString();
        if (_location.text.isEmpty) _location.text = (p['ubicacion'] ?? '').toString();
        final g = p['grupo_sanguineo'];
        if (g is String && g.isNotEmpty) _blood = g;
      });
    } catch (_) {
      // Si falla, el formulario simplemente queda vacío
    }
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _location.text.trim().isEmpty) {
      showMsg(context, 'Please complete all the required fields', error: true);
      return;
    }
    if (_lastDonation == null) {
      showMsg(context, 'Please choose the date of your last donation', error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiService.crearDonante({
        'nombre': _name.text.trim(),
        'telefono': _phone.text.trim(),
        'grupo_sanguineo': _blood,
        'ubicacion': _location.text.trim(),
        'ultima_donacion': dateToApi(_lastDonation!),
      });
      if (!mounted) return;
      showMsg(context, 'Thank you! You are now registered as a donor');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showMsg(context, errorText(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        actionTrue: true,
        titlee: "Donor Registration Form",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomFormText(
                textt: "Select Donor picture",
                isRequired: false,
              ),
              verticalSpace(twentyPixelHeight(context)),
              Center(
                  child: Image.asset(
                "assets/icons/profile.png",
                width: twentyPixelWidth(context) * 5,
              )),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(textt: 'Name', isRequired: true),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "Jorge Perez",
                prefixFalse: false,
                controller: _name,
              ),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(textt: 'Contact Number', isRequired: true),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "+18092249304",
                prefixFalse: false,
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(textt: "Blood Group", isRequired: true),
              verticalSpace(twentyPixelHeight(context)),
              Padding(
                padding: EdgeInsets.only(
                  left: twentyPixelWidth(context) * 1.5,
                  right: twentyPixelWidth(context) * 1.5,
                ),
                child: CustomBloodGroupBox(
                  initialValue: _blood,
                  onChanged: (v) => _blood = v,
                ),
              ),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(textt: "Location", isRequired: true),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "Santo Domingo, RD",
                prefixFalse: true,
                prefixxIcon: Icons.location_on,
                controller: _location,
              ),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(textt: "Last Date of Donation", isRequired: true),
              verticalSpace(twentyPixelHeight(context) * .5),
              FindDonorDatePicker(
                lastDate: DateTime.now(),
                onChanged: (d) => _lastDonation = d,
              ),
              verticalSpace(twentyPixelHeight(context) * 1.5),
              CustomRedBtn(
                textt: "Complete",
                textColor: AppColor.whiteColor,
                fillColor: AppColor.redColor,
                borderClr: Colors.transparent,
                loading: _loading,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
