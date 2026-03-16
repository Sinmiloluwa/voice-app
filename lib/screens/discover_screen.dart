import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/providers/feed_provider.dart';
import 'package:voiceapp/providers/location_provider.dart';
import 'package:voiceapp/widgets/audio_card.dart';
import 'package:voiceapp/widgets/creator_card.dart';
import 'package:voiceapp/widgets/custom_tab_bar.dart';
import 'package:voiceapp/widgets/shimmer_loaders.dart';

class DiscoverScreen extends StatefulWidget {
  final void Function(String userId)? onUserProfileTap;

  const DiscoverScreen({super.key, this.onUserProfileTap});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _selectedTab = 0;
  bool isExpanded = false;
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadNearbyUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _isSearching = false);
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<FeedProvider>().searchPost(query.trim());
    });
  }

  final backgroundImage = "https://images.unsplash.com/photo-1453738773917-9c3eff1db985?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";

  final List<Map<String, String>> audioCards = [
    {
      'time': '3:42',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAva6xs7KF2wXX0OmaGyd9W_Da95z7_OKQlrDYvtaf__zSWsDXVopWVVJWpU1t7aK8Zc_rPmTuoqNnllaND5jWaMOi-d4sIEfiAYjs0wfEHrkvfuIXhXTQe5b2tOKo6auuY8mfepym7SCqziL1ew6l5dGvILTQ4HROQXUeNYSYHy07UGN9564yvLl1Df87vLDNACZm6VShZHKqWv6RE9Il78bXPMeAx8RB6p2Itny6bd2QvTdCzEmnZ4fPtjmq5Kt8QFauPgOQy3s8',
      'category': 'NEW EPISODE',
      'title': 'The future of AI voice technology',
    },
    {
      'time': '2:15',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAWIS75ztdu_tpjG9jhToxhyhAZm07dHi1CvS8mq-yiQoNvE4Corcs_k5_Pl9pmeD20i5zB7c0UVOJQQA1LlC_iHbTHxOer58DcFM6l09JL565puWRL2SDvcDCWwl4_su5XH1C6dUqkiHXZxR0qrhYu8TeqeLCo1UFLh-gJiolkvv9uEQLjr1bInHN1nM48Nt9-6GU7UfvzxTkDW8AgG3hFxidVBOX-x_xpIBW3QTnh9WOiWq7p07gyLOuoswnYp8_cqDtPsPvwGd0',
      'category': 'LATE NIGHT',
      'title': 'Daily Stoic Reflections on Life',
    },
    {
      'time': '12:05',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBpGqOmMo764qR4VboW3wzmclaEPEDwgQA4YI1bi3NEUMJNpBNrhQvGN0ji_aBWxLn1y_Kfb70KtfOwavPrJHiZKInAgKjb6qLtk5fIUvNiDDHv-cN5xE5RiyiqSoiww0bJOKb7ACNXlgdgLDloHQVS_HuTg5_GD4YKzXemPFHdbRhtG-bqzumVMfDhbC-Rn_LWUSo4gTuOcjS2h0nEII5c7NNXsDqjOhkLpFqK-WbRXejapCs-YWsQA-98lmjhVIsCgYzJmVaIPVE',
      'category': 'RELAXING',
      'title': 'Lofi Beats to Talk & Think To',
    },
    {
      'time': '8:15',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDY91cdDTDU-dLtSZe6vIii-mMvMDThrfqIf0ngsQ428q2jnMCj9rgikm9AvqavNOlmgQDoCdgPc1sm6rRwfMePcJlzcQRQJw6TizaVNAVmlgNIoTrFxLRCecvT88UXol9tuuW_xxZFASDE-bk5dnlM-B80cSG1KF06dB0VbxOe4OF4HqwTlUX498J7hnEmX9ANtDgZzScZrhydv139WZn5NwIq1b36rYbwhSfLvbYiUYn1tS9dVRKBaWenF7DB0wHKypHXH9sLp5M',
      'category': 'BUSINESS',
      'title': 'Startup Pitch Roast: Session #4',
    },
  ];

  final List<TabItem> myTabs = [
    TabItem(
      label: 'All',
      leading: SvgPicture.asset(
        'assets/icons/1F525.svg',
        width: 24,
        height: 24,
      ),
    ),
    TabItem(
      label: 'Tech',
      leading: SvgPicture.asset(
        'assets/icons/laptop.svg',
        width: 24,
        height: 24,
      ),
    ),
    TabItem(
      label: 'Stories',
      leading: SvgPicture.asset(
        'assets/icons/books.svg',
        width: 24,
        height: 24,
      ),
    ),
    TabItem(
      label: 'Music',
      leading: SvgPicture.asset(
        'assets/icons/music.svg',
        width: 24,
        height: 24,
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.3, color: Colors.grey),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: 'https://cdn.pixabay.com/photo/2022/10/07/18/35/potrait-7505634_1280.jpg',
                              ),
                            ),
                          ),

                          Text(
                            'Discover',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Constants.primaryColor.withOpacity(
                                0.1,
                              ), // 👈 background
                              border: Border.all(
                                color: Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.notifications,
                              color: Constants.primaryColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search voices, creators, or topics",
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF24271b),

                        prefixIcon: Icon(
                          Icons.search,
                          color: Constants.primaryColor,
                          size: 20,
                        ),

                        suffixIcon: _isSearching
                            ? IconButton(
                                icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 164, 171, 100),
                            width: 0.4,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 152, 158, 93),
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_isSearching) ...[
                    Consumer<FeedProvider>(
                      builder: (context, feedProvider, _) {
                        if (feedProvider.isLoading) {
                          return const DiscoverSearchShimmer();
                        }
                        if (feedProvider.error != null) {
                          return Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'Something went wrong',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          );
                        }
                        if (feedProvider.posts.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No results found',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: feedProvider.posts.length,
                          itemBuilder: (context, index) {
                            final post = feedProvider.posts[index];
                            return AudioCard(
                              url: post.category?["imageUrl"] ?? '',
                              time: post.durationFormatted,
                              category: post.category?["name"]?.isNotEmpty == true ? post.category!['name']! : post.tags.isNotEmpty ? post.tags.first.toUpperCase() : backgroundImage,
                              title: post.title ?? '',
                            );
                          },
                        );
                      },
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    CustomTabBar(
                      tabs: myTabs,
                      selectedIndex: _selectedTab,
                      onTabSelected: (index) {
                        setState(() {
                          _selectedTab = index;
                        });
                      },
                    ),

                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Trending Now', style: Constants.headingStyle),
                              const SizedBox(width: 4),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Constants.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          Text('See all', style: Constants.subHeadingStyle),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final card = audioCards[index];
                        return AudioCard(
                          url: card['url']!,
                          time: card['time']!,
                          category: card['category']!,
                          title: card['title']!,
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsetsGeometry.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Suggested Creators',
                                style: Constants.headingStyle,
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Constants.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          Text('View all', style: Constants.subHeadingStyle),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Consumer<LocationProvider>(
                      builder: (context, location, _) {
                        if (location.isLoading) {
                          return const SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Constants.primaryColor,
                              ),
                            ),
                          );
                        }
                        if (location.locationDenied || location.locationServiceDisabled) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_off, color: Colors.white38, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      location.locationServiceDisabled
                                          ? 'Enable location services to find nearby users'
                                          : 'Allow location access to find users near you',
                                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (location.error != null || location.nearbyUsers.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              location.error != null ? 'Could not load nearby users' : 'No users found nearby',
                              style: const TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: location.nearbyUsers.length,
                            itemBuilder: (context, index) {
                              final user = location.nearbyUsers[index];
                              return CreatorCard(
                                imageUrl: user.profilePicture ?? '',
                                name: user.username,
                                onTap: () => widget.onUserProfileTap?.call(user.id),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),

            _FloatingAudioPlayer()
          ],
        ),
      ),
    );
  }
}

class _FloatingAudioPlayer extends StatefulWidget {
  @override
  State<_FloatingAudioPlayer> createState() => _FloatingAudioPlayerState();
}

class _FloatingAudioPlayerState extends State<_FloatingAudioPlayer> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 70,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: CachedNetworkImageProvider(
                'https://cdn.pixabay.com/photo/2022/10/07/18/35/potrait-7505634_1280.jpg',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The future of AI voice technology',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.35,
                            minHeight: 4,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation(
                              Constants.primaryColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        "1:12 / 3:42",
                        style: TextStyle(
                          color: Color.fromARGB(255, 205, 226, 17),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            GestureDetector(
              onTap: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Constants.primaryColor,
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                   color: Colors.black,
                   size: 24,
                )
              )
            ),
          ],
        ),
      ),
    );
  }
}

