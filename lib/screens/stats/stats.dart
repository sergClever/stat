import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:stat/localization/localization_constants.dart';
import 'package:stat/models/language.dart';
import 'package:stat/services/auth_service.dart';
import "package:stat/services/database_service.dart";
import "package:stat/models/profile.dart";
import 'package:stat/loading.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../main.dart';


class Stats extends StatefulWidget {

  final Map message;

  Stats({ this.message });


  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  Iterable<Contact> _contacts;
  List<String> myContacts = [];
  List<String> myNumbersFromFirestore = [];
  List tokensToSend = [];

  // Created list for comparing sharedNums and filterDigits and final for screen
  List<String> notificationNumber = [];

  ItemScrollController _itemScrollController;
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _myTks = Firestore.instance.collection("tokens");
  final CollectionReference _myTokens = Firestore.instance.collection("myTokens");

  String title = "Title";
  String helper = "Helper";
  String getfcmToken;
  String currentUser;
  String avatar = "";
  int scrollToIndex = 0;

  Future<String> _getUserUid() async {
    FirebaseUser user = await _auth.currentUser();

    return user.uid;
  }

  void _saveDeviceToken() async {
    FirebaseUser user = await _auth.currentUser();

    currentUser = user.phoneNumber;

    String fcmToken = await _fcm.getToken();
    
    QuerySnapshot checkForMyToken = await _myTks
      .where("phoneNumber", isEqualTo: user.phoneNumber).getDocuments();

    if (checkForMyToken.documents.length == 0) {
      if (fcmToken != null) {
        getfcmToken = fcmToken;
        var tokens = _db.collection('tokens').document(user.uid);

        await tokens.setData({"token": fcmToken, "phoneNumber": user.phoneNumber});
      }
    }
  }

  Future<QuerySnapshot> _getTokens() async {
    final QuerySnapshot tks = await _myTks.getDocuments();

    return tks;
  }
  
  Future<QuerySnapshot> _getMyTokens() async {
    final QuerySnapshot mytks = await _myTokens.getDocuments();

    return mytks;
  }

  Future _changeLanguage(Language language) async {
    Locale _temp = await setLocale(language.languageCode);

    MyApp.setLocale(context, _temp);
  }

  
  @override
  void initState() {
    super.initState();
    
    _itemScrollController = ItemScrollController();

    // For scrolling to index
    if (widget.message != null) { 
    Future.delayed(Duration(seconds: 1), () { // needs to be a delay to load build widget
      notificationNumber.asMap().forEach((key, value) {
       
        if (widget.message["data"]["number"] == value || widget.message["notification"]["number"] == value) {
          setState(() => scrollToIndex = key);
        }
      });

        _itemScrollController.scrollTo(
          index: scrollToIndex, 
          duration: Duration(seconds: 2)
        );  
    });
  }


    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
      _saveDeviceToken();
    } else {
      _saveDeviceToken();
    }


    getPermission().whenComplete(() {
      _getTokens().then((numberAndtoken) {

        _getUserUid().then((uid) {


          numberAndtoken.documents.forEach((docs) {

            if (myContacts != null) {

             // Removing user now so current user token wont be saved(done right below)
             myContacts.removeWhere((element) {
               return element.contains(currentUser);
             });
             
            myContacts.forEach((myContacts) {

              if (myContacts == docs["phoneNumber"]) {
                if (!tokensToSend.contains(docs["token"])) {
                  tokensToSend.add(docs["token"]);
                }
                // tokensToSend.contains(docs["token"] )
                //     ? null
                //     : tokensToSend.add(docs["token"]);

                _getMyTokens().then((myTokens) {
                  myTokens.documents.forEach((tokensFromdb) {
                    tokensToSend.forEach((tokensForCloud) {
                      if (tokensFromdb["tokens"] == tokensForCloud) {
                        return false;
                      } else {
                        print("TOKENS TO SEND $tokensToSend");
                        print("TOKENS FOR CLOUD: $tokensForCloud");
                        print("I HAVE BEEN CALLED HOW MANY TIMES??");
                          // To send the tokens to cloud functions
                          CloudFunctions.instance
                            .getHttpsCallable(functionName:"getTokens")
                              .call(<String, dynamic>{
                                "uid": uid,
                                "tokens": tokensToSend
                            });
                      }
                    });
                  });
                });
               }
            });
            } else {
                return Loading();
            }
          });
        });
      });
    });
  }

  
  Future getPermission() async {
    if (await Permission.contacts.request().isGranted) {
      // Thumbnail set to false for optimization
      final Iterable<Contact> contacts =
          await ContactsService.getContacts(withThumbnails: false);

      setState(() {
        _contacts = contacts;
      });

      if (_contacts == null) {
        return Loading();
      } else {
        for (var j = 0; j < _contacts.length; j++) {
          Contact contact = _contacts.elementAt(j);
          List<Item> phone = contact.phones.toList();

          phone.map((e) {
            String modifiedNums = e.value.replaceAll(RegExp("[^0-9\\+]"), "");

            if (!myContacts.contains(modifiedNums)) {
               myContacts.add(modifiedNums);
            }
            // myContacts.contains(modifiedNums)
            //     ? null
            //     : myContacts.add(modifiedNums);
          }).toList();
        }
      }
    } else if (await Permission.contacts.isPermanentlyDenied) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "Permissions Error. Please enable contact access in the system settings."),
            actions: <Widget>[
              RaisedButton(
                child: Text("Back"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
         
    return StreamBuilder<List<FilterDigits>>(
        stream: DatabaseService().filteringPhoneNumbers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<FilterDigits> filterDigits = snapshot.data;

            // Created list for comparing sharedNums and filterDigits and final for screen
            List<FilterDigits> finalComparedForFilterDigits = [];

            // For finally comparing shared numbers to have your contacts on 'stat' screen
            // (If they have an account (For name and avatar))
            myContacts.forEach((myContacts) {
              // Removing currentUsers number
              filterDigits.removeWhere((removeCurrentUserNum) {
                return removeCurrentUserNum.phoneNumber == currentUser;
              });

              filterDigits.forEach((docs) {
                if (myContacts == docs.phoneNumber) {
                  if (!finalComparedForFilterDigits.contains(docs)) {
                    finalComparedForFilterDigits.add(docs);
                  }
                  // finalComparedForFilterDigits.contains(docs)
                  //     ? null
                  //     : finalComparedForFilterDigits.add(docs);
                }
              });
            });


            // Part of cloud function procdure
            finalComparedForFilterDigits.forEach((element) {
              

             if (!notificationNumber.contains(element.phoneNumber)) {
               notificationNumber.add(element.phoneNumber);
             }
              // notificationNumber.contains(element.phoneNumber)
              //     ? null
              //     : notificationNumber.add(element.phoneNumber);
              
            });

            finalComparedForFilterDigits.sort((a, b) {
              return b.lastUpdate.compareTo(a.lastUpdate);
            });

            return StreamBuilder<List<FilterStat>>(
                stream: DatabaseService().usersStat,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<FilterStat> filterStat = snapshot.data;

                    // Created list for comparing sharedNums and filtetStat and final for screen
                    List<FilterStat> finalComparedForFilterStat = [];

                    // For finally comparing shared numbers to have your contacts on 'stat' screen
                    // (If they have an account (For timestamp and stat))
                    myContacts.forEach((myContacts) {
                      // Removing currentUsers number
                      filterStat.removeWhere((removeCurrentUser) {
                        return removeCurrentUser.phoneNumber == currentUser;
                      });

                      filterStat.forEach((docs) {
                        if (myContacts == docs.phoneNumber) {
                          if (!finalComparedForFilterStat.contains(docs)) {
                            finalComparedForFilterStat.add(docs);
                          }
                          // finalComparedForFilterStat.contains(docs)
                          //     ? null
                          //     : finalComparedForFilterStat.add(docs);
                        }
                      });
                    });

                    finalComparedForFilterStat.sort((a, b) {
                      return b.lastUpdate.compareTo(a.lastUpdate);
                    });

                    return Scaffold(
                      floatingActionButton: FloatingActionButton(
                        onPressed: () {
                          AuthService().signOut();  
                        }
                      ),
                      backgroundColor: Colors.grey[100],
                      appBar: AppBar(
                        title: Text("STATS"),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: DropdownButton(
                              onChanged: (Language language) {
                                _changeLanguage(language);
                              },
                              underline: SizedBox(),
                              icon: Icon(
                                Icons.language,
                                size: 30,
                                color: Colors.white,
                              ),
                              items: Language.languageList()
                                  .map<DropdownMenuItem<Language>>((lang) =>
                                      DropdownMenuItem(
                                        value: lang,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              lang.flag,
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            Text(lang.name)
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                     body: ListView.builder(
                           itemCount: finalComparedForFilterStat.length &
                               finalComparedForFilterDigits.length,
                           itemBuilder: (context, index) {
                             return Stack(children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 4),
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 16),
                                          blurRadius: 27,
                                          spreadRadius: -18,
                                          color: Colors.black12)
                                    ]),
                              ),
                              Positioned(
                                  left: 25,
                                  top: 20,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40.0),
                                    child: FadeInImage(
                                        fit: BoxFit.cover,
                                        height: 80,
                                        width: 80,
                                        placeholder: AssetImage(
                                            "assets/gifs/spinner.gif"),
                                        image: NetworkImage(
                                            finalComparedForFilterDigits[index]
                                                .image)),
                                  )),
                              Positioned(
                                top: 20,
                                left: 120,
                                child: SizedBox(
                                  height: 80,
                                  width: size.width - 150,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Spacer(),
                                      Text(
                                          finalComparedForFilterDigits[index]
                                              .name,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18)),
                                      Spacer(),
                                      Text(
                                        finalComparedForFilterStat[index].stat,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 20,
                                right: 30,
                                child: Text(
                                    DateFormat.yMMMd().add_jm().format(
                                        finalComparedForFilterStat[index]
                                            .lastUpdate
                                            .toDate()),
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                              )
                            ]);
                           }),
                    );
                  } else {
                    return Loading();
                  }
                });
          } else {
            return Loading();
          }
        });
  }
}
