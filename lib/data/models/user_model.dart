import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final String? studentId;
  final String? major;
  final String? school;
  final String? year;
  final String? photoUrl;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.studentId,
    this.major,
    this.school,
    this.year,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      studentId: map['studentId'],
      major: map['major'],
      school: map['school'],
      year: map['year'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'password': password,
      'studentId': studentId,
      'major': major,
      'school': school,
      'year': year,
      'photoUrl': photoUrl,
    };

    // crucial: only add id if it exists.
    // If it's null, sqlite will auto generate it.
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    String? studentId,
    String? major,
    String? school,
    String? year,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      studentId: studentId ?? this.studentId,
      major: major ?? this.major,
      school: school ?? this.school,
      year: year ?? this.year,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}