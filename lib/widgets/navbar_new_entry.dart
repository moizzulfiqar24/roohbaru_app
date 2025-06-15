import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roohbaru_app/blocs/navbar_new_entry/navbar_new_entry_bloc.dart';

class NavbarNewEntry extends StatelessWidget {
  const NavbarNewEntry({
    Key? key,
    this.icon,
    this.iconWidget,
    required this.active,
    required this.onTap,
  }) : super(key: key);

  final IconData? icon;
  final Widget? iconWidget;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NavbarNewEntryBloc>(
      create: (_) => NavbarNewEntryBloc(),
      child: BlocBuilder<NavbarNewEntryBloc, NavbarNewEntryState>(
        builder: (context, state) {
          return GestureDetector(
            onTapDown: (_) => context
                .read<NavbarNewEntryBloc>()
                .add(const NavbarNewEntryPressedDown()),
            onTapUp: (_) {
              context
                  .read<NavbarNewEntryBloc>()
                  .add(const NavbarNewEntryPressedUp());
              onTap();
            },
            onTapCancel: () => context
                .read<NavbarNewEntryBloc>()
                .add(const NavbarNewEntryPressedCancel()),
            child: AnimatedScale(
              scale: state.scale,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFB6F09C)
                      : const Color(0xFFced4da),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: iconWidget ??
                      Icon(
                        icon,
                        size: 30,
                        color: active ? Colors.black : Colors.black54,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
