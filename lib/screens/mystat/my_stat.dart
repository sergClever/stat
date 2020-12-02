import "package:flutter/material.dart";
import 'package:stat/localization/localization_constants.dart';
import 'package:stat/screens/mystat/settings/settings.dart';
import "package:stat/services/database_service.dart";
import "package:stat/models/user.dart";
import "package:provider/provider.dart";
import "package:stat/models/profile.dart";
import 'package:stat/loading.dart';
import "package:stat/size_config.dart";
import "components/body.dart";


class MyStat extends StatefulWidget {
  final Profile profileData;

  MyStat({ this.profileData });
  
  @override
  _MyStatState createState() => _MyStatState();
}

class _MyStatState extends State<MyStat> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  String stat;
  bool isStatUpdated = false;
  bool editStat = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    SizeConfig().init(context);
  
    return StreamBuilder<Stat>(
        stream: DatabaseService(uid: user?.uid ?? "no user").stat,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
           
          Stat statData = snapshot.data;

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.lightBlue,
              title: Text(
                "${getTranslated(context, 'my')} Stat",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    setState(() => editStat = false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (snapshot) => Settings()
                      )
                    );
                  },
                )
              ],
            ),
            body: Body(statData: statData,),
              );
        } else {
          return Loading();
      }
    });
  }
}
