import "package:flutter/material.dart";
import "package:provider/provider.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "package:stat/models/user.dart";
import 'package:stat/screens/home.dart';
import "package:stat/screens/authentication/phone_verify.dart";




  class Wrapper extends StatefulWidget {

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  
    @override
    Widget build(BuildContext context) {
      final user = Provider.of<User>(context);

      if (user == null) {
        return PhoneVerification();
      } else {
        return Home(); 
      }
    }           
}         


  const String SIGNED_IN = "signedIn";

  Future setUserCode() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    bool setUserCode = await _pref.setString(SIGNED_IN, "signedIn");

    return setUserCode;
  }


  Future getUserCode() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();

    String getUserCode =_pref.getString(SIGNED_IN) ?? "notSignedIn";

    return getUserCode;
  }

 