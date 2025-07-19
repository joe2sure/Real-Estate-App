import 'package:hive/hive.dart';
import '../hive/type_ids.dart';

part 'user_model.g.dart';

@HiveType(typeId: HiveTypeIds.user)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String role;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
    };
  }
}


// import 'package:hive/hive.dart';

// part 'user_model.g.dart';

// @HiveType(typeId: 0)
// class User extends HiveObject {
//   @HiveField(0)
//   final String id;

//   @HiveField(1)
//   final String firstName;

//   @HiveField(2)
//   final String lastName;

//   @HiveField(3)
//   final String email;

//   @HiveField(4)
//   final String role;

//   User({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.role,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'] as String,
//       firstName: json['firstName'] as String,
//       lastName: json['lastName'] as String,
//       email: json['email'] as String,
//       role: json['role'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'firstName': firstName,
//       'lastName': lastName,
//       'email': email,
//       'role': role,
//     };
//   }
// }