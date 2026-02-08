import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:voiceapp/assets/constants.dart';
import 'package:voiceapp/widgets/audio_card.dart';
import 'package:voiceapp/widgets/creator_card.dart';
import 'package:voiceapp/widgets/custom_tab_bar.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _selectedTab = 0;

  final List<Map<String, String>> creators = [
    {'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCh7WF8XyNrY_y_AENhV-yU0u320JrPVDZVOjWTIRZTPZ5SAkyMx8cA7r_txCShmJlMrjkRyglj3WgTThrZM6j0TL8F18mQJgjMv2atl8Szwa6XPj8tQZu1NSqoBHrMj3vBxgMb2ocsOUTZgUOMyhln43HDURkqcwPXD_0CrnGUt3qxL_UL7sWU0tzdFUhmaKTiztb99MwbrNfTF82dUyZG_j9Ce3PGPqzcx60nufOE_f4ZOgLon6z0tmiBMHCs8dm7ZM48oOyrY-k', 'name': 'Sanjay'},
    {'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDeZ2dXYhnFS003wnZ6msEjeWQOmI2A79EedmSOx1t6rFXQPV3z8i5dSU7PuomSWq5aVDmLlNf5dOiAwQM4NchKEDQIl23tmU9px-mRYHsF8TOuuPsDaQH_ROFIUikg5S7bI4I4nGiN3NtqZFz9OlwtpawzKMsFUCrWRvn8RMyJDdl9JVaRnGRy37e4voiHwnE8gm_s5d41Bn9ERyKNoWpc9QYCavSvRp6k2hdIc__JkQZ0Iwr8ZzJPkIjADAcR0mEFEiYttpMI8wE', 'name': 'Kilman'},
    {'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDktDTkT1_c1sen2KSMOzRH3toggZVH6s5cE0c85KIKWLDKkwResLg7iOmTun26rG1Po1ANa7kXwxdzmieOi7DHPJR6jMVMAGDtTHQB8lv6RG0bRoSJt0phPJKVxlBJoc9s2qxQ0go-YEPXMNdsK2bHnuZkBk6goAYruiHQiLRwU5-Ng-U_UchXrn37DP7kR1vU_8UIDP-QqLvOPS7gn5Dx9ZNvlx1Dl0D_6x-KPlxahB4UQR3vMcOMNTw1Yyhib3Kqd6RiGCdlWPU', 'name': 'Remote'},
    {'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBzhoZVHbEYm5sLGQT7i5zaSb-x93X1cokRyIgPHgBfrbgV80dt_w-zu5U63eyFjiNcv4P38FR8jdyQvybjygozjWaS_AfPOjs9Fnqi2i7Lat8EIJI96BNs_ut8FYZLSLIyGY3M3JlSNQk90LF3YMwyATw66SkXAH4gqn_rmbckAkWzlY3XVI9JL0BQ4xbePx0WNGeXYQrDILiL7c4yNhDvZPO_UyN7GYBw0o7DMwK3OOeAk78fQ_XPpzzxpP3cLVcOQ5Ub4TPfJd4', 'name': 'Shanks'},
  ];

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
        child: SingleChildScrollView(
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
                          child: Image.network(
                            'https://cdn.pixabay.com/photo/2022/10/07/18/35/potrait-7505634_1280.jpg',
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
                          width: 8, // size of the dot
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          width: 8, // size of the dot
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
              SizedBox(
                height: 200, 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: creators.length,
                  itemBuilder: (context, index) {
                    final creator = creators[index];
                    return CreatorCard(
                      imageUrl: creator['imageUrl']!,
                      name: creator['name']!
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
