# 👨‍💻 Smart Student Information System (SSIS)

A comprehensive, role-based portal application built with **Flutter** and **Firebase** for educational institutions. It provides separate, feature-rich interfaces for both Students and Instructors for managing academic records, course enrollments, schedules, grades, and attendance.

---

## 📌 Features

### 🔐 Common & Security Features
- **Secure Authentication**: Email & password authentication powered by Firebase Auth.
- **Password Reset**: Integrated self-service password recovery via automated email links.
- **Role-Based Access Control (RBAC)**: Automatically routes users to dedicated Student or Instructor dashboards upon login.
- **Profile Management**: Profile page displaying personal details, academic metrics, and photo avatars.

### 🧑‍🎓 Student Portal
- **Personalized Dashboard**: Overview of enrolled courses, schedules, and academic progress.
- **Enrolled Courses View**: List of all enrolled courses, including course code, course name, and credit hours.
- **Lecture Schedule & Attendance**: Real-time lecture schedules and attendance tracking logs.

### 👩‍🏫 Instructor Portal
- **Instructor Dashboard**: Real-time view of daily lecture schedules and student attendance summaries.
- **Taught Courses Roster**: Dedicated view of courses taught by the instructor.
- **Attendance & Grade Management**: Interface for tracking student attendance and recording course evaluation grades.

---

## ⚙️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Backend-as-a-Service (BaaS)**: [Firebase](https://firebase.google.com/)
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore & Firebase Realtime Database
- **UI & Design**: Custom Material Design components & responsive layouts

---

## 📁 Project Structure

```text
app/
├── assets/                  # Images, assets, and profile photos
│   ├── instructor/          # Instructor profile avatars
│   └── student/             # Student profile avatars
├── lib/
│   ├── firebase_options.dart # Firebase configuration setup
│   ├── main.dart            # Core application logic & route screens
│   └── utils/               # Reusable styling & custom widgets
│       ├── app_styles.dart  # Theme colors and styles
│       ├── custom_button.dart# Styled custom button
│       └── snackbar_utils.dart # Custom snackbar notification helper
├── pubspec.yaml             # Flutter dependencies and assets manifest
└── firebase.json            # Firebase CLI configuration
```

---

## 🗄️ Cloud Firestore Schema

To run this project, structure your Cloud Firestore database with the following collections and fields. The `uid` from Firebase Authentication is used as the document ID in `users`, `student`, and `instructor`.

- **`users`**: Maps Auth `uid` to user role.
  - **Doc ID**: Firebase Auth `uid`
  - **Fields**: `role` (String, e.g., `"student"` or `"instructor"`)

- **`student`**: Stores student profiles.
  - **Doc ID**: Firebase Auth `uid`
  - **Fields**: `s_FirstName`, `s_LastName`, `s_Email`, `s_Contact`, `s_StudentID` (e.g. `"STU12345"`), `s_ProfilePic` (String asset path)

- **`instructor`**: Stores instructor profiles.
  - **Doc ID**: Firebase Auth `uid`
  - **Fields**: `i_FirstName`, `i_LastName`, `i_Email`, `i_Contact`, `i_InstructorID` (e.g. `"INS54321"`), `i_ProfilePic` (String asset path)

- **`course`**: Details of academic courses.
  - **Fields**: `c_CourseCode` (e.g. `"CS101"`), `c_CourseName` (e.g. `"Data Structures"`), `c_credit` (Number)

- **`lecture`**: Defines lecture sessions.
  - **Fields**: `l_LectureID` (e.g. `"LEC001"`), `c_CourseCode`, `i_InstructorID`, `l_Date` (e.g. `"wednesday"`), `start_time` (e.g. `"10:00 AM"`)

- **`enrollment`**: Links students to lectures/courses.
  - **Fields**: `s_StudentID`, `l_LectureID`

- **`attendance`**: Logs student attendance records.
  - **Fields**: `s_StudentID`, `l_LectureID`, `time`

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.4.0 or higher)
- [Dart SDK](https://dart.dev/get-sdk)
- Firebase Account & Project setup

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yassinshebl/Smart-Student-Information-System.git
   cd Smart-Student-Information-System/app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Enable **Email/Password** Authentication and **Cloud Firestore**.
   - Configure your app using the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/):
     ```bash
     flutterfire configure
     ```
   - Alternatively, pass credentials using environment variables (`--dart-define`).

4. **Run the application**:
   ```bash
   # Run on connected device or Chrome
   flutter run -d chrome
   ```

---

## 🛡️ Security & Environment Variables

### 🔒 Firebase Security Best Practices
- **Cloud Firestore Rules**: Enforce strict Firestore security rules in the Firebase Console (e.g. `allow read, write: if request.auth != null;`).
- **GCP API Key Restrictions**: Restrict your API key in Google Cloud Console by HTTP referrer or app package signature.

### 🔑 Compile-Time Environment Variables (`--dart-define`)
To avoid hardcoding Firebase API keys in source code when pushing to public repositories, pass them at compile time:

```bash
flutter run \
  --dart-define=FIREBASE_API_KEY="YOUR_API_KEY" \
  --dart-define=FIREBASE_APP_ID="YOUR_APP_ID" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="YOUR_MESSAGING_SENDER_ID" \
  --dart-define=FIREBASE_PROJECT_ID="YOUR_PROJECT_ID"
```

Or create a local `.env.json` file (which is added to `.gitignore`):

```json
{
  "FIREBASE_API_KEY": "YOUR_API_KEY",
  "FIREBASE_APP_ID": "YOUR_APP_ID",
  "FIREBASE_MESSAGING_SENDER_ID": "YOUR_MESSAGING_SENDER_ID",
  "FIREBASE_PROJECT_ID": "YOUR_PROJECT_ID"
}
```

Run with:
```bash
flutter run --dart-define-from-file=.env.json
```

---

## 📜 License

This project is open-source and available under the [MIT License](LICENSE).
