# 👨‍💻 Smart Student Information System
A comprehensive portal application built with Flutter and Firebase, designed for educational institutions. It provides separate, feature-rich interfaces for both Students and Instructors, ensuring a tailored user experience based on their roles.

---

## 📜 Description
This project is a role-based application that serves as a central hub for students and instructors. It leverages Firebase Authentication for secure user login and Cloud Firestore for real-time data storage and retrieval. The primary goal is to provide users with quick access to their essential academic information, such as course schedules, profile details, and attendance records, all within a clean and intuitive interface.

---

## ✨ Key Features
### Common Features
- **Secure Authentication:** Robust email and password login system powered by Firebase Auth.
- **Password Reset:** A self-service "Forgot Password" feature that sends a reset link to the user's email.
- **Role-Based Access Control (RBAC):** Automatically directs users to the correct dashboard (Student or Instructor) after login.
- **Profile Page:** A unified profile screen where users can view their personal and academic information.

---

## 🧑‍🎓 Student-Specific Features
- **Personalized Dashboard:** A welcoming home screen for students.
- **View Enrolled Courses:** A dedicated page to list all courses the student is currently enrolled in, showing details like course name, code, and credit hours.
- **Navigation Drawer:** Easy access to all student-specific pages.

---

## 👩‍🏫 Instructor-Specific Features
- **Dynamic Dashboard:** A powerful home screen that displays the instructor's profile and a real-time schedule of lectures for the current day.
- **Attendance Overview:** The dashboard also shows a summary of attendance records for the day's lectures.
- **View Taught Courses:** A "My Courses" page that lists all unique courses taught by the instructor.
- **Intuitive Data Tables:** Schedules and attendance are presented in clean, easy-to-read tables.

---

## ⚙️ Technology Stack
- **Framework:** Flutter
- **Backend-as-a-Service (BaaS):** Firebase
- **Authentication:** Firebase Authentication
- **Database:** Cloud Firestore
- **State Management:** StatefulWidget (setState)
- **Language:** Dart

---

## 🗄️ Firebase Firestore Schema
To run this project, you must structure your Cloud Firestore database with the following collections and fields. The `uid` from Firebase Authentication is used as the document ID in the `users`, `student`, and `instructor` collections to link data.
- `users`: Links Auth `uid` to a role.
  - **Document ID:** Firebase Auth `uid`
  - **Fields:**
    - `role`: (String) e.g., "student" or "instructor"
- `student`: Stores student-specific data.
  - **Document ID:** Firebase Auth `uid`
  - **Fields:**
    - `s_FirstName`: (String)
    - `s_LastName`: (String)
    - `s_Email`: (String)
    - `s_Contact`: (String)
    - `s_StudentID`: (String) e.g., "STU12345"
    - `s_ProfilePic`: (String) Path to an asset image.
- `instructor`: Stores instructor-specific data.
  - **Document ID:** Firebase Auth `uid`
  - **Fields:**
    - `i_FirstName`: (String)
    - `i_LastName`: (String)
    - `i_Email`: (String)
    - `i_Contact`: (String)
    - `i_InstructorID`: (String) e.g., "INS54321"
    - `i_ProfilePic`: (String) Path to an asset image.
- `course`: Details of each course.
  - **Fields:**
    - `c_CourseCode`: (String) e.g., "CS101"
    - `c_CourseName`: (String) e.g., "Introduction to Programming"
    - `c_credit`: (Number) e.g., 3
- `lecture`: Defines lecture sessions.
  - **Fields:**
    - `l_LectureID: (String) e.g., "LEC001"
    - `c_CourseCode`: (String) Foreign key to `course`.
    - `i_InstructorID`: (String) Foreign key to `instructor`.
    - `l_Date`: (String) The day of the week, e.g., "wednesday" (lowercase).
    - `start_time`: (String) e.g., "10:00 AM"
- `enrollment`: Links students to lectures.
  - **Fields:**
    - `s_StudentID`: (String) Foreign key to `student`.
    - `l_LectureID`: (String) Foreign key to `lecture`.
- `attendance`: Logs student attendance.
  - **Fields:**
    - `l_LectureID`: (String) Foreign key to `lecture`.
    - `s_StudentID`: (String) Foreign key to `student`.
    - `time`: (String) The time of attendance marking.

---

## 🚀 Getting Started
Follow these instructions to set up and run the project on your local machine.

**Prerequisites**
- Flutter SDK installed.
- A code editor like VS Code or Android Studio.
- A Google account to create a Firebase project.

**Installation & Setup**
1. Clone the Repository
  ```bash
  git clone https://github.com/yassinshebl/Smart-Student-Information-System.git
  cd Smart-Student-Information-System
  ```
2. Set Up Firebase
  - Go to the Firebase Console and create a new project.
  - Enable Authentication and add the "Email/Password" sign-in method.
  - Go to Firestore Database, create a new database in production or test mode, and create the collections and documents as defined in the Firestore Schema section above.
  - Register your app (iOS, Android, or Web) in the Firebase project settings.
  - Follow the on-screen instructions to connect your Flutter app. The easiest way is using the FlutterFire CLI:
  ```Bash
  flutterfire configure
  ```
  This will automatically generate the `firebase_options.dart` file with your project's credentials.

3. Populate Data
  - In the Firebase console, manually add a few users in the Authentication tab.
  - In Firestore, add corresponding documents in the `users`, `student`/`instructor`, `course`, `lecture`, and `enrollment` collections so you have data to test with. Make sure the document IDs and foreign keys match!

4. Install Dependencies
  ```Bash
  flutter pub get
  ```

5. Run the Application
  ```Bash
  flutter run
  ```
You can now log in using the credentials you created in Firebase Authentication.
