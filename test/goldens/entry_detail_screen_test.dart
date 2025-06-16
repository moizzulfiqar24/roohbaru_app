// test/goldens/entry_detail_screen_test.dart

import 'dart:async';

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
import 'package:roohbaru_app/screens/entry_detail_screen.dart';

/// A MockBloc for JournalBloc so we don’t have to implement `on`/`onEvent`/etc.
class MockJournalBloc extends MockBloc<JournalEvent, JournalState>
    implements JournalBloc {}

/// Fakes so mocktail can register fallback values.
class FakeJournalEvent extends Fake implements JournalEvent {}

class FakeJournalState extends Fake implements JournalState {}

void main() {
  // Ensure we have a Test binding for timers & animations.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeJournalEvent());
    registerFallbackValue(FakeJournalState());
  });

  group('EntryDetailScreen golden', () {
    late JournalBloc journalBloc;

    // IDs & sample data for our one entry
    const entryId = 'e1';
    final sampleEntry = JournalEntry(
      id: entryId,
      userId: 'u1',
      title: 'Test Entry',
      content: 'This is a detailed view of the entry for golden testing.',
      timestamp: DateTime(2025, 1, 1, 12, 0),
      mood: 'Happy',
      suggestions: ['Listen to some music', 'Watch a movie'],
      analysis: 'You were reflective today.',
    );

    setUp(() {
      journalBloc = MockJournalBloc();

      // Stub the current state to a loaded list containing our sample.
      when(() => journalBloc.state).thenReturn(JournalLoaded([sampleEntry]));

      // Stub the stream so any listeners immediately see the same loaded list
      whenListen<JournalState>(
        journalBloc,
        Stream.value(JournalLoaded([sampleEntry])),
        initialState: JournalLoaded([sampleEntry]),
      );
    });

    goldenTest(
      'with one entry',
      fileName: 'entry_detail_screen_with_entry',
      // Let all animations (if any) complete before capturing.
      pumpBeforeTest: (tester) async {
        await tester.pumpAndSettle(const Duration(seconds: 2));
      },
      builder: () => GoldenTestGroup(
        // iPhone-8-ish frame
        scenarioConstraints: BoxConstraints.tight(Size(375, 667)),
        children: [
          GoldenTestScenario(
            name:
                'renders title, date, mood selector, body, suggestions & analysis',
            child: BlocProvider<JournalBloc>.value(
              value: journalBloc,
              child: const EntryDetailScreen(entryId: entryId),
            ),
          ),
        ],
      ),
    );
  });
}
