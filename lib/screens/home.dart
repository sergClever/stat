import "package:flutter/material.dart";
import 'package:stat/localization/localization_constants.dart';
import 'package:stat/screens/mystat/my_stat.dart';
import 'package:stat/screens/stats/stats.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import "package:flutter_local_notifications/flutter_local_notifications.dart";


class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
final FirebaseMessaging _fcm = FirebaseMessaging();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Map callMessage;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
     

     //initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('status');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification
    );

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

      flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

      _fcm.configure(
      
      onMessage: (Map<String, dynamic> message) async {
        
        setState(() => callMessage = message);

        showNotification(message["notification"]["title"], message["notification"]["body"] );  
        
      },
  
      onResume: (Map<String, dynamic> message) async {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => Stats(message: message),
          )
        );
      },

      onLaunch: (Map<String, dynamic> message) async {
         Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => Stats(message: message),
          )
        );
    
      },
    );
  }
    
  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    if (_currentIndex != 0) {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => Stats(message: callMessage),
        ),
      );
    }
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload MAIN: ' + payload);
    }

    if (_currentIndex != 0) {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => Stats(message: callMessage),
        ),
      );
    }
  }


   void showNotification(String title, String body) async {
    await _demoNotification(title, body);
  }

  Future<void> _demoNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      enableVibration: true
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }


  
  List<Widget> navigationBarScreens = <Widget> [
    Stats(),

    MyStat()
  ];

  void _currentIndexOnTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: navigationBarScreens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey,
        unselectedItemColor: Colors.black,
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
           icon: Icon(Icons.people),
           label: "Stats",
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.person),
           label: "${getTranslated(context, 'my' )} Stat", 
         ),
        ],
        currentIndex: _currentIndex,
        onTap: _currentIndexOnTap,
        selectedItemColor: Colors.grey[300],
      ),
    );
  }
}
