class VoiceComment {
  final String id;
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String audioUrl;
  final String duration;
  final int likes;
  final int replies;
  final String timeAgo;
  final String? createdAt;

  VoiceComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.audioUrl,
    required this.duration,
    required this.likes,
    required this.replies,
    required this.timeAgo,
    this.createdAt,
  });

  factory VoiceComment.fromJson(Map<String, dynamic> json) {
    try {
      
      final id = json['id'] ?? json['_id'] ?? '';
      
      // Handle userId - can be string or nested object
      String userIdValue = '';
      String usernameValue = '@unknown';
      String displayNameValue = 'Unknown';
      
      final userIdField = json['userId'];
      
      if (userIdField is Map) {
        userIdValue = userIdField['id'] ?? userIdField['_id'] ?? '';
        usernameValue = userIdField['username'] ?? '@unknown';
        displayNameValue = userIdField['displayName'] ?? userIdField['username'] ?? 'Unknown';
      } else {
        userIdValue = userIdField ?? '';
        usernameValue = json['username'] ?? '@unknown';
        displayNameValue = json['displayName'] ?? json['username'] ?? 'Unknown';
      }
      
      // Handle duration - convert to seconds string format
      final duration = json['duration'];
      final durationSeconds = duration is int ? duration : int.tryParse(duration.toString()) ?? 0;
      final durationString = '0:${durationSeconds.toString().padLeft(2, '0')}';
      
      final audioUrl = json['audioUrl'] ?? '';
      final likes = json['likes'] ?? 0;
      final replies = json['replies'] ?? 0;
      final avatarUrl = json['avatarUrl'];
      final createdAt = json['createdAt'];
      
      // Calculate timeAgo
      String timeAgo = 'now';
      if (createdAt != null) {
        try {
          final created = DateTime.parse(createdAt.toString());
          final diff = DateTime.now().difference(created);
          if (diff.inSeconds < 60) timeAgo = '${diff.inSeconds}s ago';
          else if (diff.inMinutes < 60) timeAgo = '${diff.inMinutes}m ago';
          else if (diff.inHours < 24) timeAgo = '${diff.inHours}h ago';
          else if (diff.inDays < 7) timeAgo = '${diff.inDays}d ago';
          else timeAgo = '${(diff.inDays / 7).floor()}w ago';
        } catch (e) {
          print('Error parsing createdAt: $e');
        }
      }
      
      
      return VoiceComment(
        id: id,
        userId: userIdValue,
        username: usernameValue,
        displayName: displayNameValue,
        avatarUrl: avatarUrl,
        audioUrl: audioUrl,
        duration: durationString,
        likes: likes,
        replies: replies,
        timeAgo: timeAgo,
        createdAt: createdAt,
      );
    } catch (e) {
      print('VoiceComment.fromJson: ERROR parsing comment: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'audioUrl': audioUrl,
      'duration': duration,
      'likes': likes,
      'replies': replies,
      'timeAgo': timeAgo,
      'createdAt': createdAt,
    };
  }
}
