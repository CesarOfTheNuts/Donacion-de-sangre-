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
import '../../components/widgets/custom_gender_box.dart';
import '../../components/widgets/custom_red_btn.dart';
import '../../components/widgets/find_donor_date_picker.dart';
import '../../donor_list/screens/donor_list_screen.dart';

class FindDonorScreen extends StatefulWidget {
  static const pageRoute = '/find-donor';

  const FindDonorScreen({super.key});

  @override
  State<FindDonorScreen> createState() => _FindDonorScreenState();
}

class _FindDonorScreenState extends State<FindDonorScreen> {
  final _bags = TextEditingController();
  final _phone = TextEditingController();
  final _emergency = TextEditingController();
  final _patient = TextEditingController();
  final _case = TextEditingController();
  final _location = TextEditingController();
  final _others = TextEditingController();

  String _blood = 'A+';
  String _gender = 'male';
  DateTime? _needBefore;
  bool _loading = false;

  @override
  void dispose() {
    _bags.dispose();
    _phone.dispose();
    _emergency.dispose();
    _patient.dispose();
    _case.dispose();
    _location.dispose();
    _others.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final bags = int.tryParse(_bags.text.trim());

    if (_patient.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _emergency.text.trim().isEmpty ||
        _case.text.trim().isEmpty ||
        _location.text.trim().isEmpty) {
      showMsg(context, 'Please complete all the required fields', error: true);
      return;
    }
    if (bags == null || bags <= 0) {
      showMsg(context, 'Number of bags must be greater than 0', error: true);
      return;
    }
    if (_needBefore == null) {
      showMsg(context, 'Please choose the date the blood is needed before', error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiService.crearSolicitud({
        'paciente': _patient.text.trim(),
        'grupo_sanguineo': _blood,
        'bolsas': bags,
        'telefono': _phone.text.trim(),
        'telefono_emergencia': _emergency.text.trim(),
        'causa': _case.text.trim(),
        'genero': _gender,
        'ubicacion': _location.text.trim(),
        'fecha_limite': dateToApi(_needBefore!),
        'otros': _others.text.trim(),
      });
      if (!mounted) return;
      showMsg(context, 'Request created. These are the available donors:');
      // Después de crear la solicitud se muestran los donantes de ese grupo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DonorListScreen(grupo: _blood)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showMsg(context, errorText(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      appBar: const CustomAppBar(
        titlee: "Request for Blood Donor",
        actionTrue: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: twentyPixelWidth(context),
            right: twentyPixelWidth(context),
            bottom: twentyPixelHeight(context),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(twentyPixelHeight(context)),
              Center(
                child: Text(
                  "Patient Details",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColor.blackColor,
                      fontFamily: "Poppins"),
                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                ),
              ),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(
                textt: "Choose Blood Group",
                isRequired: true,
              ),
              verticalSpace(twentyPixelHeight(context) * .5),
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
              const CustomFormText(
                textt: "Number of Bags",
                isRequired: true,
              ),
              verticalSpace(twentyPixelHeight(context) * .5),
              Row(
                children: [
                  Expanded(
                      child: CustomFormTextfield(
                    hintTextt: "3",
                    prefixFalse: false,
                    controller: _bags,
                    keyboardType: TextInputType.number,
                  )),
                  horizontalSpace(twentyPixelWidth(context) * .5),
                  const Text(
                    "Bags",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                      color: AppColor.blackColor,
                    ),
                  )
                ],
              ),
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(
                textt: "Contact Number",
                isRequired: true,
              ),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "+18092249304",
                prefixxIcon: Icons.call,
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),

              //Emergency Contact
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(
                textt: "Emergency Contact",
                isRequired: true,
              ),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "+18291234567",
                prefixFalse: true,
                prefixxIcon: Icons.call,
                controller: _emergency,
                keyboardType: TextInputType.phone,
              ),

              //Patient Name
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(
                textt: "Patient Name",
                isRequired: true,
              ),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "Jorge Perez",
                prefixFalse: true,
                prefixxIcon: Icons.person,
                controller: _patient,
              ),

              //Case
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(
                textt: "Case",
                isRequired: true,
              ),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "Cancer Patient",
                prefixFalse: false,
                prefixxIcon: Icons.person,
                controller: _case,
              ),

              //Location
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(
                textt: "Location",
                isRequired: true,
              ),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "Santo Domingo, RD",
                prefixFalse: true,
                prefixxIcon: Icons.location_on,
                controller: _location,
              ),

              //Gender
              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(
                textt: "Gender",
                isRequired: false,
              ),
              verticalSpace(twentyPixelHeight(context) * 1.5),

              Padding(
                padding: EdgeInsets.only(
                  left: twentyPixelWidth(context) * 3,
                  right: twentyPixelWidth(context) * 3,
                ),
                child: CustomGenderBox(
                  initialValue: _gender,
                  onChanged: (v) => _gender = v,
                ),
              ),

              verticalSpace(twentyPixelHeight(context) * 1.5),
              const CustomFormText(textt: "Blood Need Before", isRequired: true),
              verticalSpace(twentyPixelHeight(context) * .5),

              FindDonorDatePicker(
                firstDate: DateTime(today.year, today.month, today.day),
                lastDate: DateTime(today.year + 1, today.month, today.day),
                onChanged: (d) => _needBefore = d,
              ),

              verticalSpace(twentyPixelHeight(context)),
              const CustomFormText(
                textt: "Others",
                isRequired: false,
              ),
              verticalSpace(twentyPixelHeight(context) * .5),
              CustomFormTextfield(
                hintTextt: "Others",
                prefixFalse: true,
                prefixxIcon: Icons.person,
                controller: _others,
              ),
              verticalSpace(twentyPixelHeight(context) * 2),
              CustomRedBtn(
                textt: "Find Donors",
                textColor: AppColor.whiteColor,
                fillColor: AppColor.redColor,
                borderClr: Colors.transparent,
                loading: _loading,
                onTap: _submit,
              )
            ],
          ),
        ),
      ),
    );
  }
}
