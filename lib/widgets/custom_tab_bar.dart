import 'package:flutter/material.dart';
import 'package:voiceapp/assets/constants.dart';

class TabItem {
  final String label;
  final Widget? leading; 

  TabItem({required this.label, this.leading});
}

class CustomTabBar extends StatelessWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(
            tabs.length,
            (index) {
              final tab = tabs[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onTabSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? Constants.primaryColor
                          : const Color.fromARGB(255, 47, 48, 40),
                      borderRadius: BorderRadius.circular(20),
                      border: selectedIndex != index
                          ? Border.all(color: Constants.secondaryColor)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tab.leading != null) ...[
                          tab.leading!,
                          const SizedBox(width: 6),
                        ],
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: selectedIndex == index
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
