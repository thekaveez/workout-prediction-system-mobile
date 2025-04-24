import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? photoUrl;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoUrl,
    this.metadata,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      photoUrl: data['photoUrl'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'photoUrl': photoUrl,
      'metadata': metadata ?? {},
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      createdAt: createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, name, email, createdAt, photoUrl, metadata];
}
