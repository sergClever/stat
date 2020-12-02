import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String name;
  final String image;
  final String phoneNumber;
  final String uid;
  final Timestamp lastUpdate;
 
  Profile({ this.lastUpdate, this.name, this.image, this.phoneNumber, this.uid });
}

class Stat {
  final Timestamp lastUpdate;
  final String stat;
  final String uid;
  final String phoneNumber;

  Stat({ this.lastUpdate, this.stat, this.uid, this.phoneNumber });
}

class FilterDigits {
  final String name;
  final String image;
  final Timestamp lastUpdate;
  final String phoneNumber;

  FilterDigits({ this.lastUpdate, this.name, this.image, this.phoneNumber });
}

class FilterStat {
  final String stat;
  final Timestamp lastUpdate;
  final String uid;
  final String phoneNumber;

  FilterStat({this.uid, this.stat, this.lastUpdate, this.phoneNumber });
}
