import "package:stat/models/profile.dart";
import "package:cloud_firestore/cloud_firestore.dart";


class DatabaseService {
  final String uid;

  DatabaseService({ this.uid });

  // Create instance for Firestore collection 
  final CollectionReference _profileCollection = Firestore.instance.collection("profile");
  final CollectionReference _statCollection = Firestore.instance.collection("stat");

  // Updating user profile
  Future updatingProfile(String name, String image, String phoneNumber) async {
    return await _profileCollection.document(uid).setData({
      "name": name,
      "image": image,
      "phoneNumber": phoneNumber,
    });
  }

  // Updating lastUpdate on profile
  // WHY: to sort the users by date(Need this on profile too)
   Future updatingLastUpdateOnProfile() async {
    return await _profileCollection.document(uid).updateData({
      "lastUpdate": DateTime.now(),
    });
  }

  // Updating user Stat
  Future updatingStat(String stat, String phoneNumber) async {
    return await _statCollection.document(uid).setData({
      "uid": uid,                          
      "stat": stat,
      "lastUpdate": DateTime.now(),
      "phoneNumber": phoneNumber,
    });
  }

  // Extracting data from snapshots with custom model
  Profile _profileDataForStream(DocumentSnapshot snapshot) {
    return Profile(
      uid: uid,
      name: snapshot.data["name"], 
      image: snapshot.data["image"],
      phoneNumber: snapshot.data["phoneNumber"],
    );
  }

  // Stream for user profile
  Stream<Profile> get profile {
    return _profileCollection.document(uid).snapshots()
      .map(_profileDataForStream);
  }


  // Extracting data from snapshots with custom model
  Stat _statDataForStream(DocumentSnapshot snapshot) {
    return Stat(
      uid: uid, 
      lastUpdate: snapshot.data["lastUpdate"],
      stat: snapshot.data["stat"],
      phoneNumber: snapshot.data["phoneNumber"]
    );
  }

  // Stream for user Stat
  Stream<Stat> get stat {
    return _statCollection.document(uid).snapshots()
      .map(_statDataForStream);
    }

  // Extracting all users phone numbers 
  List<FilterDigits> _usersPhoneNumbers(QuerySnapshot snapshot) {
    return snapshot.documents.map((docs) {
      return FilterDigits(
        phoneNumber: docs.data["phoneNumber"],
        image: docs.data["image"],
        name: docs.data["name"],
        lastUpdate: docs.data["lastUpdate"],
        );
    }).toList();
  }

  // Stream for FilterDigits
  Stream<List<FilterDigits>> get filteringPhoneNumbers {
    return _profileCollection.snapshots()
      .map(_usersPhoneNumbers);
  }

  // Extracting all users phone numbers 
  List<FilterStat> _usersStat(QuerySnapshot snapshot) {
    return snapshot.documents.map((docs) {
      return FilterStat(
        uid: docs.data["uid"],
        stat: docs.data["stat"],
        lastUpdate: docs.data["lastUpdate"],
        phoneNumber: docs.data["phoneNumber"]
        );
    }).toList();
  }

  // Stream for FilterStat
  Stream<List<FilterStat>> get usersStat {
    return _statCollection.snapshots()
      .map(_usersStat);
  }
}