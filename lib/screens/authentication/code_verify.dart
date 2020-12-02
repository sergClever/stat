import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stat/services/database_service.dart';
import "package:stat/models/user.dart";
import "package:stat/components/default_button.dart";
import 'package:stat/loading.dart';
import "package:stat/components/form_errors.dart";
import "package:stat/size_config.dart";
import "package:stat/constants.dart";
import "package:stat/services/auth_service.dart";



class CodeVerification extends StatefulWidget {
  final String verificationId;
  final Function stopLoading;
  final Function wrongFormatPhone;
  final String phoneNumber;

  CodeVerification({ this.verificationId, this.stopLoading, this.phoneNumber, this.wrongFormatPhone });

  @override
  _CodeVerificationState createState() => _CodeVerificationState();
}

class _CodeVerificationState extends State<CodeVerification> {

  bool isLoading = false;
  bool reSendOTP = false;

  void isLoadingError() {
    setState(() => isLoading = true);
  }  

  void isLoadingOff() {
     setState(() => isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return isLoading ? Loading() : Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: Text(
          "OTP Verification",
          style: TextStyle(
            color: Colors.white60
          )
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);

            widget.stopLoading();
          }
        )
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.07),
          child: SingleChildScrollView(
            child: Column( 
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: SizeConfig.screenHeight * 0.1),
                Text(
                  "We have sent you an SMS with your code",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 0.5,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,

                  ),
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.02),
                buildTimer(),
                SizedBox(height: SizeConfig.screenHeight * 0.07),
                BuildForm(
                  verId: widget.verificationId, 
                  isLoading: isLoadingError,
                  isLoadingOff: isLoadingOff
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.09,),
                GestureDetector(
                  onTap: () {
                    if (reSendOTP) {
                      AuthService().phoneVerification(
                        widget.phoneNumber, 
                        context, 
                        widget.stopLoading, 
                        widget.wrongFormatPhone,
                        true
                      );
                   }
                  },
                  child: Text(
                    "Resend OTP",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange[900]
                    )
                  ),
                )
          ]),
        ),
      ),
    );
  }

  Row buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Can resend OTP in: ",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
        )
      ),
        TweenAnimationBuilder(              // HOW TO LET USER KNWO THAT THEY MAXED OUT THEIR SMS MSG?
          tween: Tween(begin: 60.0, end: 0), 
          duration: Duration(seconds: 60),
          builder: (context, value, child) => Text(
            " 00:${value.toInt()}",
            style: TextStyle(color: Colors.orange),
          ),
          onEnd: () {
            setState(() => reSendOTP = true);
          }
        )
      ]
    );
  }
}

  class BuildForm extends StatefulWidget {
    final String verId;
    final Function isLoading;
    final Function isLoadingOff;

    BuildForm({ this.verId, this.isLoading, this.isLoadingOff });

    @override
    _BuildFormState createState() => _BuildFormState();
  }
  
  class _BuildFormState extends State<BuildForm> {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final CollectionReference _db = Firestore.instance.collection("profile");
    final _formKey = GlobalKey<FormState>();
    final List<String> errors = [];
    
    FocusNode pin2FocusNode;
    FocusNode pin3FocusNode;
    FocusNode pin4FocusNode;
    FocusNode pin5FocusNode;
    FocusNode pin6FocusNode;
    String smsCode;
  
    void addError({error}) {
      if (!errors.contains(error))
        setState(() => errors.add(error));
    }

    void removeError({error}) {
      if (errors.contains(error))
        setState(() => errors.remove(error));
    }

    // Getting users uid
    User _gettingUserFromFirebase(FirebaseUser user) {
      return user != null ? User(uid: user.uid) : null;
    }

    // Stream for AuthChange 
    Stream<User> get user {
      return _auth.onAuthStateChanged
        .map(_gettingUserFromFirebase);
    }

    void nextField({String value, FocusNode focusNode}) {
      if (value.length == 1) {
        focusNode.requestFocus();
      }
    }

 

    @override
    Widget build(BuildContext context) {
      return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            autofocus: true,
            obscureText: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 10, 8),
                child: SvgPicture.asset("assets/icons/lock-24px -.svg"),
              )
            ),
            style: TextStyle(
              fontSize: 30,
            ),
            validator: (val) {
              if (val.trim().isEmpty) {
                addError(error: otpNullError);
                return "";
              }
              return null;
            },
            onChanged: (val) {
              if (val.trim().isNotEmpty) {
                removeError(error: otpNullError);
              }
              setState(() => smsCode = val);
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.03),
          FormError(errors: errors),
          SizedBox(height: SizeConfig.screenHeight * 0.04),
          DefaultButton(
            text: "Confirm",
            press: () async {
              if (_formKey.currentState.validate()) {
                Navigator.pop(context);
                
                widget.isLoading();

                removeError(error: "The code entered is incorrect, please try again");
              try {
                AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: widget.verId, smsCode: smsCode);
                AuthResult result = await _auth.signInWithCredential(credential);
                FirebaseUser user = result.user;
                
                // (if it has a value of that value)
          // if it has this field
                QuerySnapshot resultFromFirestore = await _db
                  .where("phoneNumber", isEqualTo: user.phoneNumber)
                  .getDocuments();
                final List<DocumentSnapshot> docs = resultFromFirestore.documents;
                if (docs.length == 0) {
                  await DatabaseService(uid: user.uid).updatingProfile(
                  "New Member", 
                  "https://www.nacdnet.org/wp-content/uploads/2016/06/person-placeholder.jpg",
                  user.phoneNumber
                );
                  await DatabaseService(uid: user.uid).updatingStat("", user.phoneNumber);
                  await DatabaseService(uid: user.uid).updatingLastUpdateOnProfile();
                  return _gettingUserFromFirebase(user);  
                }
              } catch (err) {
                setState(() {
                  widget.isLoadingOff();
                  addError(error: "The code entered is incorrect, please try again");
                });
                return null;
              }
            }
            return true;
          },
  )
        ],
      ),
    );
    }
  }