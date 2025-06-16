// test/goldens/home_screen_test.dart

import 'package:alchemist/alchemist.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:roohbaru_app/blocs/Auth/auth_bloc.dart';
import 'package:roohbaru_app/blocs/Auth/auth_event.dart';
import 'package:roohbaru_app/blocs/Auth/auth_state.dart';
import 'package:roohbaru_app/blocs/Journal/journal_bloc.dart';
import 'package:roohbaru_app/blocs/Journal/journal_event.dart';
import 'package:roohbaru_app/blocs/Journal/journal_state.dart';
import 'package:roohbaru_app/models/journal_entry.dart';
import 'package:roohbaru_app/screens/home_screen.dart';

// -- Mocks & Fakes --------------------------------------------------------------------------------------------------

class MockJournalBloc extends MockBloc<JournalEvent, JournalState>
    implements JournalBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

// fallback values for mocktail / bloc_test
class _FakeJournalEvent extends Fake implements JournalEvent {}

class _FakeJournalState extends Fake implements JournalState {}

class _FakeAuthEvent extends Fake implements AuthEvent {}

class _FakeAuthState extends Fake implements AuthState {}

// We only care about `uid`, so stub a User:
class MockUser extends Mock implements User {}

void main() {
  // Register fakes so mocktail/bloc_test won’t complain
  setUpAll(() {
    registerFallbackValue(_FakeJournalEvent());
    registerFallbackValue(_FakeJournalState());
    registerFallbackValue(_FakeAuthEvent());
    registerFallbackValue(_FakeAuthState());
  });

  late MockJournalBloc journalBloc;
  late MockAuthBloc authBloc;
  late User fakeUser;

  setUp(() {
    journalBloc = MockJournalBloc();
    authBloc = MockAuthBloc();
    fakeUser = MockUser();

    // stub the `uid` on our fake user so HomeScreen’s initState "LoadEntries" gets a userId
    when(() => fakeUser.uid).thenReturn('u1');

    // prepare one dummy journal entry
    final testEntry = JournalEntry(
      id: 'e1',
      userId: 'u1',
      title: 'A Test Entry',
      content: 'This is just some test content to fill the card.',
      timestamp: DateTime(2025, 6, 15),
    );

    // stub JournalBloc to immediately be in loaded state with our one entry
    when(() => journalBloc.state).thenReturn(JournalLoaded([testEntry]));
    // also stub its stream so BlocBuilder can listen
    whenListen(
      journalBloc,
      Stream.value(JournalLoaded([testEntry])),
      initialState: JournalLoaded([testEntry]),
    );

    // stub AuthBloc to be authenticated
    when(() => authBloc.state).thenReturn(AuthAuthenticated(fakeUser));
    whenListen(
      authBloc,
      Stream.value(AuthAuthenticated(fakeUser)),
      initialState: AuthAuthenticated(fakeUser),
    );
  });

  tearDown(() {
    journalBloc.close();
    authBloc.close();
  });

  group('HomeScreen golden', () {
    goldenTest(
      'renders home screen with one entry and quote spinner',
      fileName: 'home_screen',
      builder: () => GoldenTestGroup(
        // mimic an iPhone 16 Pro Max in portrait (430×932 logical pixels)
        scenarioConstraints: BoxConstraints.tight(Size(430, 932)),
        children: [
          GoldenTestScenario(
            name: 'default',
            child: MultiBlocProvider(
              providers: [
                BlocProvider<JournalBloc>.value(value: journalBloc),
                BlocProvider<AuthBloc>.value(value: authBloc),
              ],
              child: MaterialApp(
                home: HomeScreen(user: fakeUser),
                // remove the debug banner
                debugShowCheckedModeBanner: false,
                theme: ThemeData(useMaterial3: true),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
