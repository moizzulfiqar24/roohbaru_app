Here are all the places in your app where you’re still using `StatefulWidget` + `setState` to hold UI-state that isn’t backed by BLoC, along with a sketch of how you’d lift each one into its own bloc (or cubit):

---

## 1. NewEntryScreen (`new_entry_screen.dart`)

### What you’re managing with `setState`:

* **Editing mode toggle** (`_isEditing`)
* **Mic active toggle** (`_isMicActive`)
* **Validation flag** (`_showTitleError`)
* **List of attachments** (`_attachments`)

### How to convert to BLoC:

* **Bloc name**: `NewEntryBloc`
* **State**:

  ```dart
  class NewEntryState {
    final bool isEditing;
    final bool isMicActive;
    final bool showTitleError;
    final List<Attachment> attachments;
    // plus current title & content text if you want to fully bind the TextFields
  }
  ```
* **Events**:

  * `ToggleEditing`
  * `ToggleMic`
  * `AddAttachments(List<Attachment>)`
  * `RemoveAttachment(int index)`
  * `TitleSubmitted` (to flip on validation error)
  * `SubmitEntry`
* **UI wiring**:

  * Wrap the screen in a `BlocProvider<NewEntryBloc>`
  * Replace every `setState(...)` call with `context.read<NewEntryBloc>().add(...)`
  * Drive your widgets (buttons, error text, attachment list) through a `BlocBuilder<NewEntryBloc,NewEntryState>`

---

## 2. EditEntryScreen (`edit_entry_screen.dart`)

Very similar shape to **NewEntryScreen**, but pre-populated from an existing `JournalEntry`.

### What you’re managing:

* **Editing mode** (`_isEditing`)
* **Mic toggle** (`_isMicActive`)
* **Validation** (`_showTitleError`)
* **Mutable attachments** (`_attachments`)

### BLoC sketch:

* **Bloc**: `EditEntryBloc`
* **State/Events**: same set as above, plus an initial `LoadEntry(JournalEntry)` event
* **Submit flow**: Event `SaveEntry` triggers the `JournalBloc` under the hood

---

## 3. SignupScreen (`signup_screen.dart`)

### What you’re managing:

* **Live email-valid flag** (`_emailValid`)
* **Obscure-text toggle** (`_obscurePass`)
* **Password-error flag** (`_showPasswordError`)

### BLoC sketch:

* **Bloc**: `SignupFormBloc` (or a `Cubit<SignupFormState>`)
* **State**:

  ```dart
  class SignupFormState {
    final String email;
    final String name;
    final String password;
    final bool emailValid;
    final bool obscurePassword;
    final bool passwordValid;
  }
  ```
* **Events**:

  * `EmailChanged(String)`
  * `NameChanged(String)`
  * `PasswordChanged(String)`
  * `ToggleObscurePassword`
  * `SubmitSignup`
* **Validation**: on each change, update `emailValid`/`passwordValid` in the bloc

---

## 4. LoginScreen (`login_screen.dart`)

### What you’re managing:

* **Email-valid toggle** (`_emailValid`)
* **Obscure-text toggle** (`_obscurePass`)

### BLoC sketch:

* **Bloc**: `LoginFormBloc`
* **State**:

  ```dart
  class LoginFormState {
    final String email;
    final String password;
    final bool emailValid;
    final bool obscurePassword;
  }
  ```
* **Events**:

  * `EmailChanged(String)`
  * `PasswordChanged(String)`
  * `ToggleObscurePassword`
  * `SubmitLogin`

---

## 5. ProfileScreen (`profile_screen.dart`)

### What you’re managing:

* **Show-info toggle** (`_showInfo`) once the avatar animation completes

### BLoC sketch:

* **Bloc**: `ProfileUiCubit`
* **State**: simple `bool showInfo`
* **Event**: `AnimationCompleted` → sets `showInfo = true`

---

## 6. HomeScreen (`home_screen.dart`)

### What you’re managing:

* **Bottom-nav selection** (`_selectedIndex`)
* **Picked date** (`_selectedDate`)
* **(Quote fetching & journal loading are already in services/blocs)**

### BLoC sketch:

* **Bloc**: `HomeUiBloc`
* **State**:

  ```dart
  class HomeUiState {
    final int selectedIndex;
    final DateTime? selectedDate;
  }
  ```
* **Events**:

  * `SelectTab(int index)`
  * `DatePicked(DateTime?)`
* **UI wiring**: dispatch on nav-tap and on calendar/reset taps; build out sections driven by `selectedDate` in state

---

### General Conversion Steps

1. **Define your bloc/cubit** with an immutable state class capturing exactly the bits you were storing in fields and `setState`.
2. **Enumerate events** for every user action that used to call `setState(...)`.
3. **Move your business logic** (e.g. validation, adding/removing attachments) into the bloc’s `mapEventToState` (or cubit methods).
4. **Wrap** your screen with a `BlocProvider` and swap out local state reads for `BlocBuilder` and event dispatches.
5. **Remove** all `setState` calls and **fields** that held intermediate UI flags.

This will give you a single, testable source of truth for each screen’s UI-state, fully aligned with the rest of your flutter\_bloc architecture.
