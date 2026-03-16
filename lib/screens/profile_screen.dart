import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/providers/auth_provider.dart';
import 'package:voiceapp/providers/profile_provider.dart';
import 'package:voiceapp/models/user.dart';
import 'package:voiceapp/services/user_service.dart';
import 'package:voiceapp/widgets/shimmer_loaders.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final String? userId;

  const ProfileScreen({super.key, this.onBack, this.userId});

  bool get isOwnProfile => userId == null;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  int? _playingSnippetIndex;
  late AnimationController _waveformController;
  UserModel? _viewedUser;
  bool _loadingUser = false;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadMyUploads();
      if (!widget.isOwnProfile) _loadUser();
    });
  }

  Future<void> _loadUser() async {
    setState(() => _loadingUser = true);
    try {
      final user = await UserService().getUserById(widget.userId!);
      if (mounted) setState(() { _viewedUser = user; _loadingUser = false; });
    } catch (e) {
      if (mounted) setState(() => _loadingUser = false);
    }
  }

  Future<void> _follow() async {
    try {
      await UserService().followUser(widget.userId!);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _waveformController.dispose();
    super.dispose();
  }

  void _togglePlayback(int index) {
    setState(() {
      if (_playingSnippetIndex == index) {
        _playingSnippetIndex = null;
        _waveformController.stop();
      } else {
        _playingSnippetIndex = index;
        _waveformController.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOwn = widget.isOwnProfile;
    return Scaffold(
      body: SafeArea(
        child: _loadingUser
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    _ProfileHeader(onBack: widget.onBack, isOwnProfile: false),
                    const SizedBox(height: 24),
                    const ProfileHeaderShimmer(),
                  ],
                ),
              )
            : SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(onBack: widget.onBack, isOwnProfile: isOwn),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final user = isOwn ? auth.user : _viewedUser;
                  return _Avatar(
                    profileImage: user?.profilePicture ?? '',
                    username: user?.username ?? '',
                  );
                }
              ),
              const SizedBox(height: 16),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final user = isOwn ? auth.user : _viewedUser;
                  return _UserInfo(
                    username: user?.username ?? '',
                    bio: user?.bio ?? '',
                  );
                },
              ),
              const SizedBox(height: 24),
              _ActionButtons(isOwnProfile: isOwn, userId: widget.userId, onFollow: _follow),
              const SizedBox(height: 24),
              const Divider(height: 1, thickness: 1, color: Color(0xFF2A2A2A)),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final user = isOwn ? auth.user : _viewedUser;
                  return _StatsRow(
                    followers: user?.followerCount ?? 0,
                    following: user?.followingCount ?? 0,
                    plays: user?.playCount ?? 0,
                  );
                },
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFF2A2A2A)),
              const SizedBox(height: 44),
              _TabBar(
                isOwnProfile: isOwn,
                selectedIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ),
              const SizedBox(height: 24),
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  if (profileProvider.isLoading) {
                    return const ProfileSnippetsShimmer();
                  }
                  final uploads = profileProvider.myUploads;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Snippets',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.tune,
                              color: Colors.white.withOpacity(0.5),
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (uploads.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No uploads yet',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        else
                          ...List.generate(
                            uploads.length,
                            (index) {
                              final post = uploads[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _SnippetCard(
                                  snippet: Snippet(
                                    title: post.title ?? 'Untitled',
                                    emoji: '',
                                    timeAgo: post.timeAgo,
                                    listens: '${post.shares}',
                                    likes: '${post.likes}',
                                    currentTime: '0:00',
                                    totalTime: post.durationFormatted,
                                  ),
                                  isPlaying: _playingSnippetIndex == index,
                                  onPlayPressed: () => _togglePlayback(index),
                                  animationController: _waveformController,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final bool isOwnProfile;

  const _ProfileHeader({this.onBack, this.isOwnProfile = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => onBack != null ? onBack!() : Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (isOwnProfile)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false,
                    );
                  }
                } else if (value == 'Share Profile') {
                  final userId = context.read<AuthProvider>().user?.id ?? '';
                  final link = 'https://sonarapp.io/profile/$userId';
                  if (context.mounted) {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _ShareProfileSheet(link: link),
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
                const PopupMenuItem(
                  value: 'Share Profile',
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Share'),
                      Icon(Icons.ios_share, size: 23),
                    ],
                  ),
                ),
              ],
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
              ),
            )
          else
            const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? profileImage;
  final String username;

  const _Avatar({this.profileImage, this.username = ''});

  @override
  Widget build(BuildContext context) {
    final hasImage = profileImage != null && profileImage!.isNotEmpty && !profileImage!.startsWith('assets/');
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Constants.primaryColor.withValues(alpha: 0.6),
          width: 3,
        ),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return CircleAvatar(
      radius: 52,
      backgroundColor: Constants.primaryColor.withValues(alpha: 0.2),
      child: username.isNotEmpty
          ? Text(
              username[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            )
          : const Icon(Icons.person, size: 48, color: Constants.primaryColor),
    );
  }
}

class _UserInfo extends StatelessWidget {
  final String username;
  final String bio;

  const _UserInfo({required this.username, required this.bio});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '@$username',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          bio,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 14,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              'New York, NY',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// class _ActionButtons extends StatelessWidget {
//   const _ActionButtons();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 60),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               height: 42,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(21),
//                 border: Border.all(color: Colors.white.withOpacity(0.3)),
//               ),
//               child: const Center(
//                 child: Text(
//                   'Follow',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Container(
//               height: 42,
//               decoration: BoxDecoration(
//                 color: Constants.primaryColor,
//                 borderRadius: BorderRadius.circular(21),
//               ),
//               child: const Center(
//                 child: Text(
//                   'Message',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _StatsRow extends StatelessWidget {
  final int followers;
  final int following;
  final int plays;

  const _StatsRow({
    required this.followers,
    required this.following,
    required this.plays,
  });

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatBasic(value: followers.toString(), label: 'FOLLOWERS'),
          _StatBasic(value: following.toString(), label: 'FOLLOWING'),
          _StatBasic(value: plays.toString(), label: 'PLAYS'),
        ],
        // children: [
        //   Expanded(child: _StatCard(value: _formatCount(followers), label: 'FOLLOWERS')),
        //   const SizedBox(width: 10),
        //   Expanded(child: _StatCard(value: _formatCount(following), label: 'FOLLOWING')),
        //   const SizedBox(width: 10),
        //   Expanded(child: _StatCard(value: _formatCount(plays), label: 'PLAYS')),
        // ],
      ),
    );
  }
}

class _StatBasic extends StatelessWidget {
  final String value;
  final String label;

  const _StatBasic({
    required this.value,
    required this.label,
  });



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(
          fontWeight: FontWeight.w400
        )),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          fontWeight: FontWeight.bold))
      ]
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Constants.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int selectedIndex;
  final bool isOwnProfile;
  final Function(int) onTabSelected;

  const _TabBar({required this.selectedIndex, required this.onTabSelected, required this.isOwnProfile});

  @override
  Widget build(BuildContext context) {
    final tabs = ['Snippets', 'Liked', isOwnProfile ? 'Series' : 'About'];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                padding: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selectedIndex == index
                          ? Constants.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selectedIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnippetCard extends StatelessWidget {
  final Snippet snippet;
  final bool isPlaying;
  final VoidCallback onPlayPressed;
  final AnimationController animationController;

  const _SnippetCard({
    required this.snippet,
    required this.isPlaying,
    required this.onPlayPressed,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onPlayPressed,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Constants.primaryColor,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${snippet.title} ${snippet.emoji}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snippet.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.headphones, size: 14, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text(
                    snippet.listens,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.favorite, size: 14, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text(
                    snippet.likes,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: CustomPaint(
              painter: _SnippetWaveformPainter(
                isPlaying: isPlaying,
                animation: animationController,
              ),
              size: const Size(double.infinity, 40),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                snippet.currentTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              Text(
                snippet.totalTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnippetWaveformPainter extends CustomPainter {
  final bool isPlaying;
  final Animation<double> animation;

  _SnippetWaveformPainter({
    required this.isPlaying,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = Constants.primaryColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final inactivePaint = Paint()
      ..color = Constants.primaryColor.withOpacity(0.3)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final barWidth = 2.5;
    final spacing = 1.5;
    final totalBars = ((size.width / (barWidth + spacing)).toInt());
    final centerY = size.height / 2;
    final progressBars = (totalBars * 0.3).toInt();

    for (int i = 0; i < totalBars; i++) {
      final x = i * (barWidth + spacing);
      final seed = i * 12.5;
      final baseHeight =
          (size.height * 0.3) + ((sin(seed) * 0.5 + 0.5) * size.height * 0.4);

      final animatedHeight = isPlaying
          ? baseHeight * (0.5 + 0.5 * sin(seed + animation.value * 6.28).abs())
          : baseHeight * 0.6;

      final paint = i < progressBars ? activePaint : inactivePaint;

      canvas.drawLine(
        Offset(x, centerY - animatedHeight / 2),
        Offset(x, centerY + animatedHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SnippetWaveformPainter oldDelegate) => true;
}

class _ShareProfileSheet extends StatefulWidget {
  final String link;

  const _ShareProfileSheet({required this.link});

  @override
  State<_ShareProfileSheet> createState() => _ShareProfileSheetState();
}

class _ShareProfileSheetState extends State<_ShareProfileSheet> {
  bool _copied = false;
  Uint8List? _qrBytes;
  bool _loadingQr = true;
  bool _qrError = false;

  @override
  void initState() {
    super.initState();
    _fetchQr();
  }

  Future<void> _fetchQr() async {
    try {
      final bytes = await UserService().getProfileQrCode();
      if (mounted) setState(() { _qrBytes = bytes; _loadingQr = false; });
    } catch (_) {
      if (mounted) setState(() { _loadingQr = false; _qrError = true; });
    }
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: widget.link));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Share Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 232,
            height: 232,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _loadingQr
                ? const Center(child: CircularProgressIndicator(color: Constants.primaryColor))
                : _qrError
                    ? const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 40))
                    : Image.memory(_qrBytes!, fit: BoxFit.contain),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.link,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _copyLink,
                  child: Icon(
                    _copied ? Icons.check : Icons.copy,
                    color: _copied ? Constants.primaryColor : Colors.white54,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Snippet {
  final String title;
  final String emoji;
  final String timeAgo;
  final String listens;
  final String likes;
  final String currentTime;
  final String totalTime;

  Snippet({
    required this.title,
    required this.emoji,
    required this.timeAgo,
    required this.listens,
    required this.likes,
    required this.currentTime,
    required this.totalTime,
  });
}

class _ActionButtons extends StatefulWidget {
  final bool isOwnProfile;
  final String? userId;
  final Future<void> Function()? onFollow;

  const _ActionButtons({this.isOwnProfile = true, this.userId, this.onFollow});

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  bool _isFollowing = false;
  bool _followLoading = false;

  Future<void> _handleFollow() async {
    if (_followLoading) return;
    setState(() => _followLoading = true);
    try {
      await widget.onFollow?.call();
      if (mounted) setState(() { _isFollowing = !_isFollowing; _followLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> buttons = widget.isOwnProfile
        ? [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Edit Profile', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFafc12b)),
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Share', style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
          ]
        : [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                onPressed: _followLoading ? null : _handleFollow,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _followLoading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          _isFollowing ? 'Unfollow' : 'Follow',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFafc12b)),
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Message', style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buttons,
      ),
    );
  }
} 


