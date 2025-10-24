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
  
  @HiveField(5)
  final String? phone;
  
  @HiveField(6)
  final String? lastLogin;
  
  @HiveField(7)
  final bool? isActive;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.phone,
    this.lastLogin,
    this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? json['_id']) as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      lastLogin: json['lastLogin'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'phone': phone,
      'lastLogin': lastLogin,
      'isActive': isActive,
    };
  }
  
  String get fullName => '$firstName $lastName';
  
  bool get isAdmin => role.toLowerCase() == 'admin';
}