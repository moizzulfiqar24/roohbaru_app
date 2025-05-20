import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomNavbar extends StatefulWidget {
  final int selectedIndex;
  final void Function(int) onItemSelected;
  final VoidCallback onAddPressed;

  const CustomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onAddPressed,
  });

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        lowerBound: 1.2,
        upperBound: 2,
      )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _controllers[index].reverse(); // Bounce back
          }
        });
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    widget.onItemSelected(index);
    _controllers[index].forward(); // Trigger bounce animation
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 2),
      height: 65,
      decoration: BoxDecoration(
        // color: Colors.white,
        // color: Color(0xFF473623),
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black12,
            // offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnimatedNavItem(
                0,
                'Home',
                Icons.home_rounded,
                // PhosphorIcons.house,
              ),
              _buildAnimatedNavItem(
                1,
                'Search',
                Icons.search_rounded,
                // PhosphorIcons.magnifyingGlass,
              ),
              const SizedBox(width: 48), // Reduced spacer for smaller FAB
              _buildAnimatedNavItem(
                2,
                'Insights',
                Icons.bar_chart_rounded,
              ),
              _buildAnimatedNavItem(
                3,
                'Profile',
                Icons.person,
                // PhosphorIcons.user,
                // PhosphorIcons.userCircle,
              ),
            ],
          ),
          Positioned(
            child: SizedBox(
              width: 50, // Smaller FAB width
              height: 50, // Smaller FAB height
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: widget.onAddPressed,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 24, // Smaller icon
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedNavItem(int index, String label, IconData icon) {
    final isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _controllers[index].drive(Tween(begin: 1.0, end: 1.2)),
              child: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'lufga-bold',
                // fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
