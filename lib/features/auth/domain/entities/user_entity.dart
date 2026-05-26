import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String login;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final String? company;
  final String? blog;
  final String? htmlUrl;
  final int followers;
  final int following;
  final int publicRepos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.login,
    this.name,
    this.email,
    this.avatarUrl,
    this.bio,
    this.location,
    this.company,
    this.blog,
    this.htmlUrl,
    this.followers = 0,
    this.following = 0,
    this.publicRepos = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        login,
        name,
        email,
        avatarUrl,
        bio,
        location,
        company,
        blog,
        htmlUrl,
        followers,
        following,
        publicRepos,
        createdAt,
        updatedAt,
      ];

  UserEntity copyWith({
    String? id,
    String? login,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    String? company,
    String? blog,
    String? htmlUrl,
    int? followers,
    int? following,
    int? publicRepos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      login: login ?? this.login,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      company: company ?? this.company,
      blog: blog ?? this.blog,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      publicRepos: publicRepos ?? this.publicRepos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
