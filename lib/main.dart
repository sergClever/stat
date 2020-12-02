import 'package:flutter/material.dart';
import 'package:stat/localization/demo_localization.dart';
import 'package:stat/localization/localization_constants.dart';
import 'package:stat/models/user.dart';
import 'package:stat/services/auth_service.dart';
import 'package:stat/services/image_camera_service.dart';
import 'package:stat/loading.dart';
import "screens/wrapper.dart";
import "package:provider/provider.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {  
  Locale _locale;
  String _checkIfSignedIn;

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }


  @override
  void initState() {
    super.initState();

   
    getUserCode().then((user) {
      setState(() => this._checkIfSignedIn = user);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();


    getLocale().then((locale) {
      setState(() => this._locale = locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null && _checkIfSignedIn == "notSignedIn") {
      return Loading();
    } else {
        return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ImageAndCameraService()),
          StreamProvider<User>.value(value: AuthService().user)
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: _locale,
          theme: theme(),
          supportedLocales: [ 
          Locale('en', "US"),
          Locale('es', "MX"),
        ],
        localizationsDelegates: [
          DemoLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (var locale in supportedLocales) {
            if (locale.languageCode == deviceLocale.languageCode && locale.countryCode == deviceLocale.countryCode) {
              return deviceLocale;
            } 
          }
          return supportedLocales.first;
        },
        home: Wrapper()//CodeVerification(),
      ));
    }
  }
}

