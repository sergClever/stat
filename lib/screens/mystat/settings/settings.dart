import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stat/localization/localization_constants.dart';
import 'package:stat/models/profile.dart';
import 'package:stat/models/user.dart';
import 'package:stat/services/auth_service.dart';
import 'package:stat/services/database_service.dart';
import 'package:stat/services/image_camera_service.dart';
import 'package:stat/loading.dart';
import "package:stat/size_config.dart";



class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _profileKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String name;
  bool isProfileUpdated;
  bool editProfile = false;

  void chooseFromCameraOrGallery() {
    showModalBottomSheet(context: context, builder: (context) {
      final providerImageAndCamera = Provider.of<ImageAndCameraService>(context);

      return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        FlatButton.icon(
          onPressed: () {
            providerImageAndCamera.pickImage(ImageSource.camera);
            Navigator.pop(context);
          },
          icon: Icon(Icons.camera_alt),
          label: Text(
            "Camera", 
            style: TextStyle(fontSize: 16.0)
            )
          ),
        SizedBox(height: 10.0),
        FlatButton.icon(
          onPressed: () {
            providerImageAndCamera.pickImage(ImageSource.gallery);
            Navigator.pop(context);
          },
          icon: Icon(Icons.photo),
          label: Text(
            "Gallery", 
            style: TextStyle(fontSize: 16.0)
            ))
        ]);
      });
    }

  void popAndSignOut() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final providerImageAndCamera = Provider.of<ImageAndCameraService>(context);
    // updating form changenotifer to change avatar to make true
     isProfileUpdated = providerImageAndCamera.isProfileUpdated;

    final user = Provider.of<User>(context);

    return StreamBuilder<Profile>(
      stream: DatabaseService(uid: user?.uid ?? "no user").profile,
      builder: (context, snapshot) {
        if (snapshot.hasData) {

        Profile profileData = snapshot.data; 


        return Scaffold(
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text("${getTranslated(context, 'settings')}"),
            actions: [
              FlatButton(
                onPressed: () {
                  setState(() => editProfile = true);
                },
                child: Text(
                  "${getTranslated(context, 'edit')}",
                  style: TextStyle(fontSize: 18)
                ),
              ),
            ],
              ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: editProfile ? SizeConfig.screenHeight * 0.45 : SizeConfig.screenHeight * 0.35,
                  child: Stack(
                    children: [
                      ClipPath(
                        clipper: CustomShape(),
                        child: Container(
                          height: editProfile ? SizeConfig.screenHeight * 0.24 : SizeConfig.screenHeight * 0.26,
                          color: Colors.blue,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Center(
                          child: Form(
                            key: _profileKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: SizeConfig.screenWidth * 0.02,
                                      color: Colors.white
                                    )
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (editProfile) {
                                        chooseFromCameraOrGallery();
                                      }
                                    },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(70.0),
                              child: FadeInImage(
                                fit: BoxFit.cover,
                                height: SizeConfig.screenHeight * 0.19,
                                width: SizeConfig.screenWidth * 0.38,
                                placeholder: AssetImage("assets/gifs/spinner.gif"), 
                                image: NetworkImage(providerImageAndCamera.image ?? profileData.image)
                                    ) ,
                                    )
                                  ),
                                ),
                                  editProfile ? SizedBox(
                                    width: SizeConfig.screenWidth * 0.40,
                                    child: TextFormField(
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(15)
                                      ],
                                      initialValue: profileData.name,
                                      onChanged: (val) {
                                        setState(() {
                                          name = val;
                                          isProfileUpdated = true;
                                          providerImageAndCamera.makeTrue();
                                        });
                                      },
                                      validator: (val) => val.trim().isEmpty ? "${getTranslated(context, 'enter_your_name')}" : null,
                                      decoration: InputDecoration(
                                        errorStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue, 
                                          width: 2.0)
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green,
                                          width: 2.0
                                        )
                                      )
                                    ),
                                  ),
                                )
                                : Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    profileData.name,
                                    style: TextStyle(fontSize: 20)
                                    ),
                                ),
                                  
                    editProfile ? Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlatButton(
                              child: Text(
                                "${getTranslated(context, 'save')}",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: isProfileUpdated ? () async {
                                if (_profileKey.currentState.validate()) {
                                  isProfileUpdated = false;
                                  // make false again
                                  providerImageAndCamera.makeFalse();
                                  FocusScope.of(context).unfocus();
                                  setState(() => editProfile = false );
                                  await DatabaseService(uid: user.uid).updatingProfile(
                                    name ?? profileData.name,
                                    providerImageAndCamera.image ?? profileData.image,
                                    profileData.phoneNumber,
                                  );
                                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: Text(
                                      "${getTranslated(context, 'profile_updated')}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                      fontWeight:FontWeight.bold,
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
                          color: Colors.red, fontSize: 16.0
                          ),
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _profileKey.currentState.reset();
                          setState(() {
                            isProfileUpdated = false;
                            name = profileData.name;
                            editProfile = false;
                          });
                        },
                  ),],
                ),
              )
              : Container()
            ],),
        ),
      ),
      )
    ],
  ),
),
              Spacer(),
              GestureDetector(
              child: SettingOptions(
                title: "${getTranslated(context, 'system_settings')}",
                color: Colors.black,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: Text("${getTranslated(context, "dialog_system_settings")}"),
                    actions: [
                      FlatButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        color: Colors.grey[200],
                        onPressed: () {
                          openAppSettings();
                        },
                        child: Text(
                          "${getTranslated(context, "yes")}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18
                          )
                        )
                      ),
                      FlatButton(
                        onPressed: () {
                         Navigator.pop(context);
                        },
                        child: Text(
                          "${getTranslated(context, "cancel")}",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16
                          ),
                        )
                      )
                  ],
                )
              );
              }),
               GestureDetector(
                child: SettingOptions(
                  title: "${getTranslated(context, 'log_out')}",
                   color: Colors.red[900],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: Text("${getTranslated(context, "dialog_log_out")}"),
                      actions: [
                        FlatButton(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          color: Colors.grey[200],
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "${getTranslated(context, "cancel")}",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18
                            )
                          )
                        ),
                        FlatButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            popAndSignOut();
                            
                            AuthService().signOut();
                            
                            SharedPreferences _prefs = await SharedPreferences.getInstance();
                            
                            _prefs.clear();
                          },
                          child: Text(
                            "${getTranslated(context, "log_out")}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16
                            ),
                          )
                        )
                      ],
                    )
                  );

                  },
                  )]
              )
            );
          } else {
            return Loading();
          }
        }
     );
  }
}


// For settings
class SettingOptions extends StatelessWidget {
  final String title;
  final Color color;

  const SettingOptions({
    Key key, this.title, this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey,
        border: Border.all(color: Colors.black, width: 2.0)
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 16.0,
          fontWeight: FontWeight.bold
        ),
      ) 
    );
  }
}

class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double height = size.height;
    double width = size.width;
    path.lineTo(0, height - 100);
    path.quadraticBezierTo(width / 2, height, width, height - 100);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}