import 'package:firebase_database/firebase_database.dart';

class AccountModel{
  String userId;
  String username;

  Map<String, dynamic>? stats;
  Map<String, dynamic>? preferences;
  Map<String, dynamic>? personalInfo;

  String? get version => personalInfo?["version"];
  String? get platform => personalInfo?["platform"];
  String? get name => personalInfo?["name"];
  String? get about => personalInfo?["about"];
  String? get profilePicture => personalInfo?["profile_picture"];

  int? get createdAt => stats?["created_at"];
  bool? get loggedIn => stats?["logged_in"];

  AccountModel({
    required this.userId,
    required this.username,
    this.stats,
    this.preferences,
    this.personalInfo
  });

  AccountModel.fromRtdb(DataSnapshot snapshot) :
    assert(snapshot.exists && snapshot.value != null),
    userId = snapshot.child("user_id").value.toString(),
    username = snapshot.child("username").value.toString(),
    stats = snapshot.child("stats").value is Map
      ? snapshot.child("stats").value as Map<String,dynamic> : null,
    preferences = snapshot.child("preferences").value is Map
      ? snapshot.child("preferences").value as Map<String,dynamic> : null,
    personalInfo = snapshot.child("personal_info").value is Map
      ? snapshot.child("personal_info").value as Map<String,dynamic> : null;
}