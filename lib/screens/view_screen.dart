import 'package:flutter/material.dart';
import 'package:voiceapp/assets/constants.dart';

class ViewScreen extends StatelessWidget {
  const ViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 34),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Center(
                    child: Text('New Wave', style: Constants.headingStyle),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.question_mark,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ' 00:15 ',
                        style: TextStyle(color: Colors.white, fontSize: 36),
                      ),
                      Text(
                        '/',
                        style: TextStyle(
                          color: Constants.secondaryColor,
                          fontSize: 36,
                        ),
                      ),
                      Text(
                        ' 3:45 ',
                        style: TextStyle(
                          color: Constants.secondaryColor,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.graphic_eq,
                  size: 200,
                  color: Constants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Constants.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Recording',
                  style: TextStyle(
                    color: Constants.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            BottomPanel(),
          ],
        ),
      ),
    );
  }
}

class BottomPanel extends StatelessWidget {
  const BottomPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF191b0f),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                ? MediaQuery.of(context).viewInsets.bottom
                : MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF24271b),
                    child: Icon(
                      Icons.replay,
                      color: Color(0xFFF6FDF7),
                      size: 24,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {},
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Constants.primaryColor,
                          child: Icon(
                            Icons.play_arrow,
                            color: Color(0xFFF6FDF7),
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: SliderComponentShape.noThumb,
                          activeTrackColor: const Color(0xFFCEFF52),
                          inactiveTrackColor: const Color(0xFFEDEDED),
      
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          min: 0,
                          max: 100,
                          value: 30.0,
                          onChanged: (val) {},
                        ),
                      ),
                    ),
                  ),
                  Text('0:15'),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        decoration: BoxDecoration(
                          color: Color(0xFF24271b),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.bar_chart,
                            color: Color(0xFFF6FDF7),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VIBE CHECK'),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "What's the tea? daily",
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF24271b),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      suffixText: '#',
                      suffixStyle: const TextStyle(
                        color: Constants.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF191b0f),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.delete,
                                color: Color(0xFFF6FDF7),
                                size:32,
                              ),
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Discard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
      
                      Container(
                            // padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF191b0f),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Constants.primaryColor,
                                  blurRadius: 12,
                                  // offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Constants.primaryColor,
                              child: Icon(
                                Icons.stop,
                                color: Colors.black,
                                size:40,
                              ),
                            )
                          ),
      
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF191b0f),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.send,
                                color: Color(0xFFF6FDF7),
                                size:32,
                              ),
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Post',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
