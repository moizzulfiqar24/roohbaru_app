import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/personality_bloc.dart';
import '../../blocs/personality_state.dart';
import '../../blocs/personality_event.dart';

class PersonalitySelector extends StatelessWidget {
  const PersonalitySelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonalityBloc, PersonalityState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.black54.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              // BoxShadow(
              //   color: Colors.black.withOpacity(0.07),
              //   blurRadius: 20,
              //   offset: const Offset(0, 8),
              // ),
              // BoxShadow(
              //   color: Colors.white.withOpacity(0.7),
              //   blurRadius: 10,
              //   offset: const Offset(-2, -2),
              // ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select Your AI Personality',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'lufga-bold',
                        // fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: 0.5,
                        color: Colors.black87,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: LayoutBuilder(builder: (context, constraints) {
                  final buttonWidth = (constraints.maxWidth - 36) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    children:
                        PersonalityBloc.allPersonalities.map((personality) {
                      final isSelected = state.selected.contains(personality);

                      return GestureDetector(
                        onTap: () {
                          if (isSelected && state.selected.length == 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'At least one personality must remain selected.'),
                              ),
                            );
                          } else {
                            context
                                .read<PersonalityBloc>()
                                .add(TogglePersonality(personality));
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: buttonWidth,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.indigo.shade600
                                // ? Color(0xFFB6F09C)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  // ? Colors.indigo.shade600
                                  ? Color(0xFFB6F09C)
                                  : Colors.grey.shade300,
                              width: 1.4,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      // color: Colors.indigo.withOpacity(0.2),
                                      color: Color(0xFFB6F09C).withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              personality,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    // ? Colors.black
                                    : Colors.grey[800],
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
