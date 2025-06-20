# Roohbaru – A Reflective AI-Powered Journaling App 🧠📓

Roohbaru is a cross-platform journaling app focused on **mental wellness and self-reflection**, powered by AI. It allows users to log their thoughts, attach photos, and receive emotional insights and creative suggestions based on their entries. The app supports login via email and Google, mood tracking, voice input, and visual insights—all in a beautifully designed interface.

## 🛠 Features

- 🔐 **Authentication**: Sign in with email/password or Google
- 📝 **Journal Entries**: Text, voice dictation, image attachments
- 🧠 **AI Analysis**: Sentiment, mood, and content-aware recommendations
- 📊 **Insights Dashboard**: Charts for mood trends and entry analysis
- 🔍 **Smart Search**: Filter entries by mood, text, photo, or date
- 👤 **Profile Page**: View user info, pick personality traits
- 💾 **Offline Support**: Caching for faster access
- 🎨 **Clean UI**: Smooth design with custom fonts and animations

## 📁 Project Structure

```

lib/
│
├── blocs/             
├── models/            
├── screens/           
├── services/          
├── widgets/           
└── main.dart          

````

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.6.1)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- A Firebase project created (see below)

### 1. Clone the Repository

```bash
git clone https://github.com/moizzulfiqar24/roohbaru_app.git
cd roohbaru_app
````

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Firebase

1. **Create a Firebase project** at [https://console.firebase.google.com/](https://console.firebase.google.com/)

2. Enable:

   * **Authentication > Sign-in methods**: enable *Email/Password* and *Google*
   * **Firestore Database**: Start in test mode

3. Add your platforms:

   * Android: register with your app's package name (e.g. `com.example.roohbaru`)
   * iOS/macOS: add bundle ID, download `GoogleService-Info.plist`
   * Web: add web app in Firebase Console

4. **Add Firebase config files** to the project:

   * `android/app/google-services.json`
   * `ios/Runner/GoogleService-Info.plist`
   * `macos/Runner/GoogleService-Info.plist` (if using macOS)
   * Optionally set web config in `web/index.html`

### 4. Add `.env` File

Create a file at `assets/.env` with the following content:

```env
GROQ_API_KEY=your_ai_api_key_here
```

(Used by the AI service to analyze journal entries.)

---

### 5. Run the App

Use your terminal or IDE:

```bash
flutter run
```

Choose your target (Android, iOS, macOS, Web, etc.)

## 📸 Screenshots

<!-- You can insert screenshots here -->

<!-- ![Home](assets/screenshots/home.png) -->

## 🤖 Tech Stack

* **Flutter & Dart**
* **Firebase (Auth, Firestore)**
* **AI (via HTTP API)**
* **SharedPreferences, Speech-to-Text**
* **flutter\_bloc** for state management