import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/models/user.dart';
import 'package:voiceapp/providers/location_provider.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadNearbyUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _NearbyHeader(
              onRefresh: () => context.read<LocationProvider>().loadNearbyUsers(),
            ),
            Expanded(
              child: Consumer<LocationProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) return const _LoadingState();
                  if (provider.locationServiceDisabled) {
                    return const _EmptyState(
                      icon: Icons.location_off,
                      title: 'Location services disabled',
                      subtitle: 'Enable location services in your device settings to find nearby users.',
                    );
                  }
                  if (provider.locationDenied) {
                    return const _EmptyState(
                      icon: Icons.location_disabled,
                      title: 'Location access denied',
                      subtitle: 'Allow location access in your app settings to find users near you.',
                    );
                  }
                  if (provider.error != null) {
                    return _EmptyState(
                      icon: Icons.wifi_off,
                      title: 'Something went wrong',
                      subtitle: provider.error!,
                    );
                  }
                  if (provider.nearbyUsers.isEmpty) {
                    return const _EmptyState(
                      icon: Icons.people_outline,
                      title: 'No users nearby',
                      subtitle: 'No Sonar users found within 50km of your location.',
                    );
                  }
                  return _UserList(users: provider.nearbyUsers);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyHeader extends StatelessWidget {
  final VoidCallback onRefresh;

  const _NearbyHeader({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.3, color: Colors.grey)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Sonar users within 50km',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Constants.primaryColor.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.refresh, color: Constants.primaryColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Constants.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Finding users near you...',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<UserModel> users;

  const _UserList({required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) => _UserTile(user: users[index]),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white10,
            child: ClipOval(
              child: user.profilePicture != null
                  ? CachedNetworkImage(
                      imageUrl: user.profilePicture!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white54),
                    )
                  : const Icon(Icons.person, color: Colors.white54),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.bio!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.graphic_eq, size: 13, color: Constants.primaryColor),
                    const SizedBox(width: 3),
                    Text(
                      '${user.playCount} plays',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.people_outline, size: 13, color: Colors.white38),
                    const SizedBox(width: 3),
                    Text(
                      '${user.followerCount} followers',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _FollowButton(userId: user.id),
        ],
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  final String userId;

  const _FollowButton({required this.userId});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _following = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: _following ? Colors.transparent : Constants.primaryColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _following ? Colors.white24 : Constants.primaryColor,
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
              )
            : Text(
                _following ? 'Following' : 'Follow',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _following ? Colors.white54 : Colors.black,
                ),
              ),
      ),
    );
  }

  Future<void> _toggle() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() { _following = !_following; _loading = false; });
  }
}
