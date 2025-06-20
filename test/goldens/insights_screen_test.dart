import 'package:alchemist/alchemist.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:roohbaru_app/blocs/Journal/journal_bloc.dart';
import 'package:roohbaru_app/blocs/Journal/journal_event.dart';
import 'package:roohbaru_app/blocs/Journal/journal_state.dart';
import 'package:roohbaru_app/models/journal_entry.dart';
import 'package:roohbaru_app/screens/insights_screen.dart';

class MockJournalBloc extends MockBloc<JournalEvent, JournalState>
    implements JournalBloc {}

class FakeJournalEvent extends Fake implements JournalEvent {}

class FakeJournalState extends Fake implements JournalState {}

void main() {
  // Ensure all the timers/animations are wired up for flutter_test
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Register our fakes so mocktail can fall back to them
    registerFallbackValue(FakeJournalEvent());
    registerFallbackValue(FakeJournalState());
  });

  group('InsightsScreen golden', () {
    late JournalBloc journalBloc;

    setUp(() {
      journalBloc = MockJournalBloc();

      // 3a) Stub the "current" state to be an empty list of JournalEntry
      when(() => journalBloc.state)
          .thenReturn( JournalLoaded(<JournalEntry>[]));

      // 3b) Stub the stream so InsightsBloc sees that same empty state
      whenListen<JournalState>(
        journalBloc,
        Stream.value( JournalLoaded(<JournalEntry>[])),
        initialState:  JournalLoaded(<JournalEntry>[]),
      );
    });

    goldenTest(
      'initial empty state',
      fileName: 'insights_screen_initial',
      // 4) Let all of the built-in animations finish (up to 1.2s)
      pumpBeforeTest: (tester) async {
        await tester.pumpAndSettle(const Duration(seconds: 2));
      },
      builder: () => GoldenTestGroup(
        // match a typical phone
        scenarioConstraints: BoxConstraints.tight(const Size(375, 667)),
        children: [
          GoldenTestScenario(
            name: 'no entries, all-time filter',
            child: BlocProvider<JournalBloc>.value(
              value: journalBloc,
              child: const InsightsScreen(),
            ),
          ),
        ],
      ),
    );
  });
}
