class VoicePost {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String audioUrl;
  final int duration;
  final String? title;
  final List<String> tags;
  final int likes;
  final int comments;
  final int shares;
  final DateTime createdAt;

  VoicePost({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.audioUrl,
    required this.duration,
    this.title,
    this.tags = const [],
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.createdAt,
  });

  factory VoicePost.fromJson(Map<String, dynamic> json) {
    return VoicePost(
      id: json["id"] ?? json["_id"] ?? "",
      userId: json["userId"] ?? "",
      username: json["username"] ?? "",
      avatarUrl: json["avatarUrl"],
      audioUrl: json["audioUrl"] ?? "",
      duration: json["duration"] ?? 0,
      title: json["title"],
      tags: List<String>.from(json["tags"] ?? []),
      likes: json["likes"] ?? 0,
      comments: json["comments"] ?? 0,
      shares: json["shares"] ?? 0,
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
