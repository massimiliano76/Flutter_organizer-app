import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

@immutable
@JsonSerializable()
class AuthUser {
  const AuthUser({
    @required this.uid,
    this.email,
    this.photoUrl,
    this.displayName,
    this.token,
  });

  final String uid;
  final String email;
  final String photoUrl;
  final String displayName;
  final String token;

  AuthUser.fromMap(Map<String,dynamic> json) :
    this.uid = json["uid"],
    this.email = json['email'],
    this.photoUrl = json['photoUrl'],
    this.displayName = json['displayName'],
    this.token = json['token'];

  Map<String, dynamic> toMap() => {
      "id": this.uid,
      "email":this.email,
      "photoUrl":this.photoUrl,
      "displayName":this.displayName,
      "token":this.token
  };
}