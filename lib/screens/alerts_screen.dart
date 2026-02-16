import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  static const Color primaryColor = Color(0xFFD4E157);
  static const Color backgroundColor = Color(0xFF0D0D0D);
  static const Color cardBackground = Color(0xFF1A1A1A);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Comments', 'Followers', 'Reads'];

  final List<Activity> _allActivities = [
    Activity(
      type: ActivityType.voiceComment,
      userName: 'Sam',
      userAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBzhoZVHbEYm5sLGQT7i5zaSb-x93X1cokRyIgPHgBfrbgV80dt_w-zu5U63eyFjiNcv4P38FR8jdyQvybjygozjWaS_AfPOjs9Fnqi2i7Lat8EIJI96BNs_ut8FYZLSLIyGY3M3JlSNQk90LF3YMwyATw66SkXAH4gqn_rmbckAkWzlY3XVI9JL0BQ4xbePx0WNGeXYQrDILiL7c4yNhDvZPO_UyN7GYBw0o7DMwK3OOeAk78fQ_XPpzzxpP3cLVcOQ5Ub4TPfJd4',
      action: 'left a voice comment',
      timestamp: '1h ago',
      audioInfo: '0:15 audio',
      actionIcon: Icons.play_arrow,
    ),
    Activity(
      type: ActivityType.following,
      userName: 'User123',
      userAvatar: 'https://placehold.co/48/4ECDC4/FFFFFF?text=U',
      action: 'started following you',
      timestamp: '2m ago',
      showFollowBack: true,
    ),
    Activity(
      type: ActivityType.reaction,
      userName: 'Alex',
      userAvatar: 'https://placehold.co/48/FFE66D/FFFFFF?text=A',
      action: 'reacted 🔥 to your clip',
      subtitle: "'Morning Vibes'",
      timestamp: '15m ago',
    ),
    Activity(
      type: ActivityType.likes,
      userName: 'Jordan and 3 others',
      avatars: [
        'https://placehold.co/32/FF6B6B/FFFFFF?text=J',
        'https://placehold.co/32/4ECDC4/FFFFFF?text=K',
        'https://placehold.co/32/FFE66D/FFFFFF?text=L',
      ],
      action: 'liked your audio',
      timestamp: '3h ago',
    ),
    Activity(
      type: ActivityType.reply,
      userName: 'Chloe',
      userAvatar: 'https://placehold.co/48/95E1D3/FFFFFF?text=C',
      action: 'replied to your story',
      subtitle: "'Love this melody!'",
      timestamp: '5h ago',
      audioInfo: '0:08 audio',
      actionIcon: Icons.play_arrow,
    ),
  ];

  List<Activity> get _filteredActivities {
    switch (_selectedTabIndex) {
      case 1:
        return _allActivities.where((a) => a.type == ActivityType.voiceComment || a.type == ActivityType.reply).toList();
      case 2:
        return _allActivities.where((a) => a.type == ActivityType.following).toList();
      case 3:
        return _allActivities.where((a) => a.type == ActivityType.likes).toList();
      default:
        return _allActivities;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AlertsScreen.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            _TabNavigation(
              tabs: _tabs,
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _filteredActivities.length,
                itemBuilder: (context, index) {
                  return _ActivityCard(activity: _filteredActivities[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Activity',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.done_all,
              color: AlertsScreen.primaryColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabNavigation extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabChanged;

  const _TabNavigation({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => GestureDetector(
            onTap: () => onTabChanged(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: selectedIndex == index ? AlertsScreen.primaryColor : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selectedIndex == index ? AlertsScreen.primaryColor : Colors.white10,
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: selectedIndex == index ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final Activity activity;

  const _ActivityCard({required this.activity});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AlertsScreen.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.activity.avatars != null)
                SizedBox(
                  width: 60,
                  height: 48,
                  child: Stack(
                    children: List.generate(
                      widget.activity.avatars!.length,
                      (index) {
                        return Positioned(
                          left: index * 24.0,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AlertsScreen.backgroundColor, width: 2),
                            ),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(widget.activity.avatars![index]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.activity.userAvatar ?? ''),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AlertsScreen.primaryColor,
                          border: Border.all(color: AlertsScreen.backgroundColor, width: 2),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.activity.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: ' ${widget.activity.action}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.activity.subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.activity.subtitle!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    if (widget.activity.audioInfo != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.activity.audioInfo!,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.activity.timestamp,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.activity.actionIcon != null)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AlertsScreen.primaryColor,
                    ),
                    child: Icon(
                      widget.activity.actionIcon,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                )
              else if (widget.activity.showFollowBack)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFollowing = !_isFollowing;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isFollowing ? Colors.white.withOpacity(0.1) : AlertsScreen.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isFollowing ? Colors.white10 : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      _isFollowing ? 'Following' : 'Follow Back',
                      style: TextStyle(
                        color: _isFollowing ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: Colors.white30),
            ],
          ),
        ],
      ),
    );
  }
}

enum ActivityType {
  voiceComment,
  following,
  reaction,
  likes,
  reply,
}

class Activity {
  final ActivityType type;
  final String userName;
  final String? userAvatar;
  final List<String>? avatars;
  final String action;
  final String? subtitle;
  final String timestamp;
  final String? audioInfo;
  final IconData? actionIcon;
  final bool showFollowBack;

  Activity({
    required this.type,
    required this.userName,
    this.userAvatar,
    this.avatars,
    required this.action,
    this.subtitle,
    required this.timestamp,
    this.audioInfo,
    this.actionIcon,
    this.showFollowBack = false,
  });
}
