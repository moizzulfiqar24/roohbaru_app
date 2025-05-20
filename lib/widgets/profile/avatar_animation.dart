import 'package:flutter/material.dart';

typedef AnimationCompleted = void Function();

class AvatarAnimation extends StatefulWidget {
  final AnimationCompleted onCompleted;
  const AvatarAnimation({Key? key, required this.onCompleted})
      : super(key: key);

  @override
  _AvatarAnimationState createState() => _AvatarAnimationState();
}

class _AvatarAnimationState extends State<AvatarAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _shapeMoveUp;
  late final Animation<Offset> _avatarSlideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Shape starts immediately and moves the full duration
    _shapeMoveUp = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.2),
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    // Avatar waits a bit (20%), then moves up together with the shape
    _avatarSlideUp = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted();
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SlideTransition(
            position: _shapeMoveUp,
            child: Image.asset('assets/images/shape.png'),
          ),
          SlideTransition(
            position: _avatarSlideUp,
            child: Image.asset('assets/images/avatar.png'),
          ),
        ],
      ),
    );
  }
}
