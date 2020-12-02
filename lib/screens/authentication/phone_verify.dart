import "package:stat/size_config.dart";
import "package:flutter/material.dart";
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stat/screens/wrapper.dart';
import 'package:stat/loading.dart';
import "package:stat/services/auth_service.dart";
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import "package:stat/components/form_errors.dart";
import "package:stat/components/default_button.dart";
import "package:stat/constants.dart";


class PhoneVerification extends StatefulWidget {
  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {

  CountryCode countryCode;
  bool isLoading = false;
  String phoneNumber;
  String valPhoneNumber;
  String verificationId;
  final List<String> errors = [];
  final _formKey = GlobalKey<FormState>();

  var maskFormatter = new MaskTextInputFormatter(
    mask: "###-###-####", 
    filter: { "#": RegExp(r'[0-9]') 
  });

  void addError({error}) {
    if (!errors.contains(error))
      setState(() => errors.add(error));
  }

  void removeError({error}) {
    if (errors.contains(error))
      setState(() => errors.remove(error));
  }

  void wrongFormatPhone() {
    setState(() => isLoading = false);

    addError(error: phoneFormatError);
  }

  void stopLoading() {
    setState(() => isLoading = false);
  }

  void isLoadingError() {
    setState(() => isLoading = true);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return isLoading ? Loading() : Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.07),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: SizeConfig.screenHeight * 0.15),
            Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold
                  ),
                  text: "Welcome ",
                  children: [
                    TextSpan(
                      text: "to "
                    ),
                    TextSpan(
                      text: "Stat",
                      style: TextStyle(
                        color: Colors.blue[900]
                      )
                    )
                  ]
                )
                // "Welcome to Stat",
                // style: TextStyle(
                //   fontSize: 30,
                //   color: Colors.black54,
                //   fontWeight: FontWeight.bold
                // )
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.06),
            Padding(
              padding: EdgeInsets.only(left: SizeConfig.screenWidth * 0.05),
              child: Text(
                "Select your country",
                style: TextStyle(
                  letterSpacing: 0.5,
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold
                  )
                ),
            ),
            selectCountryField(),
            SizedBox(height: SizeConfig.screenHeight * 0.05),
            Form(
              key: _formKey,
              child: Column(
                children: [
              phoneFormField(),
              SizedBox(height: SizeConfig.screenHeight * 0.01),
              FormError(errors: errors),
              SizedBox(height: SizeConfig.screenHeight * 0.07),
              DefaultButton(
                text: "Continue",
                press: () async {
                  if (_formKey.currentState.validate()) {
                    removeError(error: phoneFormatError);
                    
                    isLoadingError();
                    
                    setState(() => phoneNumber = countryCode.toString() + valPhoneNumber);
          
                    await AuthService().phoneVerification(
                      phoneNumber, 
                      context,
                      stopLoading,
                      wrongFormatPhone,
                      false
                    );
                    
                    await setUserCode();

                    FocusScope.of(context).unfocus();
                      }
                    },
                  )
                ],
              )
            )
            ],
          ),
      ),
      ),
    );
  }

  Container selectCountryField() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 2)
      ),
      child: CountryCodePicker(
      onInit: (val) {
        countryCode = val;
      },
      onChanged: (val) {
        setState(() => countryCode = val);
      },
      textStyle: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.bold
      ),
      searchDecoration: InputDecoration(
        labelText: "Search your country",
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0)
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2.0)
        )
      ),
      initialSelection: "US",
      showCountryOnly: false,
      showOnlyCountryWhenClosed: true,
      alignLeft: false,
      ),
    );
  }

  TextFormField phoneFormField() {
    return TextFormField(
      keyboardType: TextInputType.phone , 
      inputFormatters: [maskFormatter],
      style: TextStyle(
        color: Colors.black,
        fontSize: 20.0,
        fontWeight: FontWeight.normal
      ),                      
      validator: (val) {
        if (val.trim().isEmpty) {
          addError(error: phoneNullError);
          return "";
        }
          return null;
      },
      onChanged: (val) {
        if (val.trim().isNotEmpty) {
          removeError(error: phoneNullError);
          
          setState(() => valPhoneNumber = val);
        }
    },
    decoration: InputDecoration(
      labelText: "Enter your phone number",
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.normal
      ),
      prefix: Text(
      countryCode == null ? "+1" : countryCode.toString(),
      style: TextStyle(
        fontSize: 20.0,
        color: Colors.black,
        fontWeight: FontWeight.bold
      ),
    ),
    suffixIcon: Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 10, 8),
      child: SvgPicture.asset("assets/icons/phone-24px.svg"),
        )
      ),
    );
  }
}
