// test/goldens/new_entry_screen_test.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alchemist/alchemist.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:roohbaru_app/blocs/Journal/journal_bloc.dart';
import 'package:roohbaru_app/blocs/Journal/journal_event.dart';
import 'package:roohbaru_app/blocs/Journal/journal_state.dart';
import 'package:roohbaru_app/models/journal_entry.dart';
import 'package:roohbaru_app/screens/new_entry_screen.dart';

class _MockJournalBloc extends Mock implements JournalBloc {}

class _FakeJournalEvent extends Fake implements JournalEvent {}

class _FakeJournalState extends Fake implements JournalState {}

void main() {
  const speechChannelName = 'plugin.csdcorp.com/speech_to_text';
  final speechChannel = MethodChannel(speechChannelName);

  setUpAll(() {
    registerFallbackValue(_FakeJournalEvent());
    registerFallbackValue(_FakeJournalState());
  });

  setUp(() {
    // Initialize the binding for platform-channel stubbing:
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(speechChannel,
        (call) async {
      switch (call.method) {
        case 'initialize':
          return true;
        case 'listen':
        case 'stop':
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    // Clear our stub after each test:
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(speechChannel, null);
  });

  group('NewEntryScreen golden tests', () {
    late JournalBloc journalBloc;

    setUp(() {
      journalBloc = _MockJournalBloc();

      // Fake an "empty" loaded state
      when(() => journalBloc.state).thenReturn(JournalLoaded(<JournalEntry>[]));
      when(() => journalBloc.stream)
          .thenAnswer((_) => Stream.value(JournalLoaded(<JournalEntry>[])));
    });

    goldenTest(
      'initial state — hints & buttons',
      fileName: 'new_entry_screen_initial',
      // **advance fake time** so that the 2 s speech_to_text Timer is drained
      pumpBeforeTest: (tester) async {
        await tester.pump(const Duration(seconds: 3));
      },
      builder: () => GoldenTestGroup(
        scenarioConstraints: BoxConstraints.tight(Size(375, 667)),
        children: [
          GoldenTestScenario(
            name: 'empty attachments, edit off',
            child: BlocProvider<JournalBloc>.value(
              value: journalBloc,
              child: const NewEntryScreen(userId: 'u1'),
            ),
          ),
        ],
      ),
    );
  });
}
