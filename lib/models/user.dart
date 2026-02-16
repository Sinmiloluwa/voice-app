class UserModel {
  final String id;
  final String username;
  final String? profilePicture;
  final String? bio;
  final int followerCount;
  final int followingCount;
  final int playCount;

  UserModel({
    required this.id,
    required this.username,
    this.profilePicture,
    this.bio,
    this.followerCount = 0,
    this.followingCount = 0,
    this.playCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? json["_id"],
      username: json["username"],
      profilePicture: json["profilePicture"],
      bio: json["bio"],
      followerCount: json["followerCount"] ?? 0,
      followingCount: json["followingCount"] ?? 0,
      playCount: json["playCount"] ?? 0,
    );
  }
}
