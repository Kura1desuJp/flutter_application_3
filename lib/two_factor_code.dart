import 'package:flutter/material.dart';
import 'package:flutter_application_3/database_helper.dart';

class TwoFactorCode {
  int? id;
  Color color;
  String website;
  String email;
  String secret;

  TwoFactorCode({
    this.id,
    required this.color,
    required this.website,
    required this.email,
    required this.secret,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnColor: color.value,
      DatabaseHelper.columnWebsite: website,
      DatabaseHelper.columnEmail: email,
      DatabaseHelper.columnSecret: secret,
    };
  }

  factory TwoFactorCode.fromMap(Map<dynamic, dynamic> map) {
    return TwoFactorCode(
      id: map[DatabaseHelper.columnId],
      color: Color(map[DatabaseHelper.columnColor]),
      website: map[DatabaseHelper.columnWebsite],
      email: map[DatabaseHelper.columnEmail],
      secret: map[DatabaseHelper.columnSecret],
    );
  }
}