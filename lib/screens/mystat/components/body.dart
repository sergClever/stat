import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:stat/localization/localization_constants.dart';
import "package:stat/services/database_service.dart";
import "package:stat/size_config.dart";
import "package:stat/models/profile.dart";
import "package:provider/provider.dart";
import "package:stat/models/user.dart";



class Body extends StatefulWidget {
  final Stat statData;

  Body({this.statData});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _statKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String stat;
  bool isStatUpdated = false;
  bool editStat = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Stack(
        children: [
          Container(
            height: SizeConfig.screenHeight * 0.25,
            width: double.infinity,
            color: Colors.lightBlue,
          ),
          Form(
            key: _statKey,
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.1),
                editStat
                    ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      autofocus: true,
                      style: TextStyle(fontSize: 20),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(40)
                      ],
                      initialValue: widget.statData.stat,
                      onChanged: (val) {
                        setState(() {
                          stat = val;
                          isStatUpdated = true;
                        });
                      },
                      validator: (val) => val.trim().isEmpty
                          ? "${getTranslated(context, 'enter_your_error')} Stat"
                          : null,
                      decoration: InputDecoration(
                          errorStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          enabledBorder: InputBorder.none,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black, width: 2.0))),
                    ),
                  )
                : Text(
                    widget.statData.stat,
                    style: TextStyle(fontSize: 20),
                  ),
            editStat
                ? Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                              "${getTranslated(context, 'update')} Stat",
                              style: TextStyle(
                                  color: Colors.green, fontSize: 20.0)),
                          onPressed: isStatUpdated
                              ? () async {
                                  if (_statKey.currentState.validate()) {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      isStatUpdated = false;
                                      editStat = false;
                                    });
                                    await DatabaseService(uid: user.uid)
                                        .updatingStat(
                                      stat ?? widget.statData.stat,
                                      widget.statData.phoneNumber,
                                    );

                                    await DatabaseService(uid: user.uid)
                                        .updatingLastUpdateOnProfile();

                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                      "Stat ${getTranslated(context, 'updated')}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    )));
                                  }
                                }
                              : null,
                        ),
                        FlatButton(
                          child: Text(
                            "${getTranslated(context, 'cancel')}",
                            style: TextStyle(
                                color: Colors.red, fontSize: 16.0),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _statKey.currentState.reset();
                            setState(() {
                              editStat = false;
                              isStatUpdated = false;
                              stat = widget.statData.stat;
                            });
                          },
                        ),
                      ],
                    ),
                  )
                : Container()
              ],
            ),
          ),
        ],
      ),
      SizedBox(height: SizeConfig.screenHeight * 0.03),
      editStat
          ? Container()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RaisedButton(
                splashColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(color: Colors.pink)),
                color: Colors.lightBlueAccent,
                onPressed: () {
                  setState(() => editStat = true);
                },
                child: Text(
                  "${getTranslated(context, 'edit')} Stat",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            )
    ]);
  }
}
