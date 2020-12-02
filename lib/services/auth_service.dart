import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "package:stat/models/user.dart";
import 'package:stat/screens/authentication/code_verify.dart';
import 'package:stat/services/database_service.dart';
import 'dart:async';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _db = Firestore.instance.collection("profile");

  String verificationId;
  int forceResendOTP;
 

 // TODO: doing IOS integration for: "firebase cloud messaging"
 // GET READY TO PUBLISH YOUR APP THIS WEEK..... ;)
  // Phone verification
  Future phoneVerification(
    String phoneNumber, 
    BuildContext context, 
    Function stopLoading, 
    Function wrongFormatPhone,
    bool resendOTP
    ) {

  final PhoneVerificationCompleted verificationCompleted = (AuthCredential credential) async {
    AuthResult result = await _auth.signInWithCredential(credential);
    FirebaseUser user = result.user;
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
    }
    Navigator.pop(context);
    return _gettingUserFromFirebase(user);  
  };
  final PhoneVerificationFailed verificationFailed = (AuthException authException) { 
    wrongFormatPhone();
  };
  final PhoneCodeSent codeSent = (String verificationId, [int forceResendToken]) {
    this.forceResendOTP = forceResendToken;

    if (resendOTP) {
      Navigator.pop(context);
    }

    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => CodeVerification(
        verificationId: verificationId,
        stopLoading: stopLoading,
        phoneNumber: phoneNumber,
        wrongFormatPhone: wrongFormatPhone
        )
      ));
    };
  final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
    this.verificationId = verificationId;
  };
  
  return  _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber, 
    timeout: Duration(seconds: 60), 
    verificationCompleted: verificationCompleted, 
    verificationFailed: verificationFailed, 
    codeSent: codeSent, 
    codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    forceResendingToken: forceResendOTP
    );
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

 
  // Signing out user
  Future signOut() async {
    try {
      return await _auth.signOut();
    }
    catch (err) {
      print(err.toString());
      return null;
      }
    }
  }


