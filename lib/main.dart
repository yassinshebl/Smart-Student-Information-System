// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:app/utils/app_styles.dart';
import 'package:app/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();
        String role = userData.get('role');
        if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => StudentHomePage(userId: user.uid)),
          );
        } else if (role == 'instructor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => InstructorHomePage(userId: user.uid)),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/1609391092746.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(50),
                height: 500,
                width: 800,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Log in to your Account',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: _emailController,
                            cursorColor: AppTheme.accent,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.accent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Password:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            cursorColor: AppTheme.accent,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.accent,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        onPressed: _login,
                        text: _isLoading ? 'Logging in...' : 'Log in',
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResetPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSending = false;

  void _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    try {
      setState(() {
        _isSending = true;
      });
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/1609391092746.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                height: 420,
                width: 800,
                padding: const EdgeInsets.all(50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            BackButton(
                              color: Colors.black,
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Reset your Password',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          controller: _emailController,
                          cursorColor: AppTheme.accent,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Column(
                      children: [
                        CustomButton(
                          text: _isSending ? "Sending..." : "Send Email",
                          onPressed: () {
                            _resetPassword();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentHomePage extends StatelessWidget {
  final String userId;
  final String role = "student";

  const StudentHomePage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Home Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.accent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.accent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Student Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(userId: userId, role: role),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Courses'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CoursesPage(userId: userId, role: role),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('student').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }
          var studentData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};
          return Center(
            child: Column(
              children: [
                Text('Welcome, ${studentData['s_FirstName']}!'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class InstructorHomePage extends StatelessWidget {
  final String userId;
  final String role = "instructor";

  const InstructorHomePage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Instructor Home Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.accent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.accent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Instructor Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(userId: userId, role: role),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('My Courses'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CoursesPage(userId: userId, role: role),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('instructor')
            .doc(userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }
          var instructorData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/1609391092746.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45),
                      color: AppTheme.accentTransparent,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              AssetImage('${instructorData['i_ProfilePic']}'),
                        ),
                        const SizedBox(width: 50),
                        Text(
                          'Welcome, Dr. ${instructorData['i_FirstName']} ${instructorData['i_LastName']}!',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchLecturesForToday(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading lectures'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No lectures available today'));
                        }
                        var lectures = snapshot.data!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              padding: const EdgeInsets.all(50),
                              height: 500,
                              width: 627,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        'Today\'s lecture',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      DataTable(
                                        border: TableBorder.all(
                                          color: Colors.black45,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                        columns: const [
                                          DataColumn(
                                              label: Text('Course Code')),
                                          DataColumn(
                                              label: Text('Course Name')),
                                          DataColumn(label: Text('Credits')),
                                          DataColumn(label: Text('Start Time')),
                                        ],
                                        rows: lectures
                                            .map(
                                              (lecture) => DataRow(
                                                cells: [
                                                  DataCell(Text(
                                                      lecture['c_CourseCode'])),
                                                  DataCell(Text(
                                                      lecture['c_CourseName'])),
                                                  DataCell(Text(
                                                      lecture['c_Credit']
                                                          .toString())),
                                                  DataCell(Text(
                                                      lecture['start_time'])),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              padding: const EdgeInsets.all(50),
                              height: 500,
                              width: 627,
                              child: Column(
                                children: [
                                  const Text(
                                    'Taken Attendance',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _fetchAttendanceForLecture(
                                        lectures.first['l_LectureID']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError) {
                                        return const Center(
                                            child: Text(
                                                'Error loading attendance'));
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text(
                                                'No attendance records available'));
                                      }
                                      var attendance = snapshot.data!;
                                      return Expanded(
                                        child: DataTable(
                                          border: TableBorder.all(
                                            color: Colors.black45,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(8)),
                                          ),
                                          columns: const [
                                            DataColumn(
                                                label: Text('Lecture ID')),
                                            DataColumn(
                                                label: Text('Student ID')),
                                            DataColumn(label: Text('Time')),
                                          ],
                                          rows: attendance
                                              .map(
                                                (record) => DataRow(
                                                  cells: [
                                                    DataCell(Text(
                                                        record['l_LectureID'])),
                                                    DataCell(Text(
                                                        record['s_StudentID'])),
                                                    DataCell(
                                                        Text(record['time'])),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchLecturesForToday() async {
    DateTime now = DateTime.now();
    List<String> weekdays = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday'
    ];
    String today =
        weekdays[now.weekday]; // Adjust for 0-based index in the list
    print("Today's day: $today");

    QuerySnapshot lectureSnapshot = await FirebaseFirestore.instance
        .collection('lecture')
        .where('l_Date', isEqualTo: today)
        .get();
    print(
        "Lecture snapshot retrieved: ${lectureSnapshot.docs.length} documents found");

    List<Map<String, dynamic>> lectures = [];

    for (var lectureDoc in lectureSnapshot.docs) {
      var lectureData = lectureDoc.data() as Map<String, dynamic>;
      print("Lecture data: $lectureData");

      QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection('course')
          .where('c_CourseCode', isEqualTo: lectureData['c_CourseCode'])
          .get();
      print(
          "Course query executed for c_CourseCode: ${lectureData['c_CourseCode']}");

      if (courseSnapshot.docs.isNotEmpty) {
        var courseData =
            courseSnapshot.docs.first.data() as Map<String, dynamic>;
        print("Course data: $courseData");

        lectures.add({
          'l_LectureID': lectureData['l_LectureID'],
          'c_CourseCode': courseData['c_CourseCode'],
          'c_CourseName': courseData['c_CourseName'],
          'c_Credit': courseData['c_credit'],
          'start_time': lectureData['start_time'],
        });
        print("Lecture added to list: ${lectures.last}");
      } else {
        print(
            "No course found for c_CourseCode: ${lectureData['c_CourseCode']}");
      }
    }

    print("Total lectures for today: ${lectures.length}");
    return lectures;
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceForLecture(
      String lectureId) async {
    print("Fetching attendance for lecture ID: $lectureId");

    QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('l_LectureID', isEqualTo: lectureId)
        .get();
    print(
        "Attendance snapshot retrieved: ${attendanceSnapshot.docs.length} documents found");

    List<Map<String, dynamic>> attendanceRecords = [];

    for (var attendanceDoc in attendanceSnapshot.docs) {
      var attendanceData = attendanceDoc.data() as Map<String, dynamic>;
      print("Attendance data: $attendanceData");

      var studentSnapshot = await FirebaseFirestore.instance
          .collection('student')
          .where('s_StudentID', isEqualTo: attendanceData['s_StudentID'])
          .get();
      print(
          "Student document retrieved for ID: ${attendanceData['s_StudentID']}");

      var studentData = studentSnapshot;
      print("Student data: $studentData");

      attendanceRecords.add({
        'l_LectureID': attendanceData['l_LectureID'],
        's_StudentID': attendanceData['s_StudentID'],
        'time': attendanceData['time'],
      });
      print("Attendance record added: ${attendanceRecords.last}");
    }

    print("Total attendance records: ${attendanceRecords.length}");
    return attendanceRecords;
  }
}

class ProfilePage extends StatelessWidget {
  final String userId;
  final String role;

  const ProfilePage({required this.userId, required this.role, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.accent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection(role).doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/1609391092746.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.all(30),
                          height: 529,
                          width: 800,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role == 'student'
                                    ? 'Student\'s Information'
                                    : 'Instructor\'s Information',
                                style: const TextStyle(fontSize: 30),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundImage: AssetImage(
                                      '${userData[role == 'student' ? 's_ProfilePic' : 'i_ProfilePic']}'),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Center(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  width: 500,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name: ${userData[role == 'student' ? 's_FirstName' : 'i_FirstName']} ${userData[role == 'student' ? 's_LastName' : 'i_LastName']}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Email: ${userData[role == 'student' ? 's_Email' : 'i_Email']}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Contact: ${userData[role == 'student' ? 's_Contact' : 'i_Contact']}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'ID: ${userData[role == 'student' ? 's_StudentID' : 'i_InstructorID']}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CoursesPage extends StatelessWidget {
  final String role;
  final String userId;

  const CoursesPage({required this.role, required this.userId, super.key});

  Future<List<Map<String, dynamic>>> _fetchCourses() async {
    final firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> courses = [];

    if (role == 'student') {
      final studentDoc =
          await firestore.collection('student').doc(userId).get();
      final sStudentid = studentDoc.get('s_StudentID');
      print('Fetched student document: ${studentDoc.data()}');
      print('Student ID: $sStudentid');

      final enrollmentDocs = await firestore
          .collection('enrollment')
          .where('s_StudentID', isEqualTo: sStudentid)
          .get();
      print(
          'Fetched enrollment documents for student: ${enrollmentDocs.docs.length} enrollments found.');

      for (var enrollment in enrollmentDocs.docs) {
        final lLectureid = enrollment.get('l_LectureID');
        print('Enrollment ID: ${enrollment.id}, Lecture ID: $lLectureid');

        final lectureQuery = await firestore
            .collection('lecture')
            .where('l_LectureID', isEqualTo: lLectureid)
            .get();
        if (lectureQuery.docs.isNotEmpty) {
          final lectureDoc = lectureQuery.docs.first;
          final cCoursecode = lectureDoc.get('c_CourseCode');
          print('Fetched lecture document: ${lectureDoc.data()}');
          print('Course Code: $cCoursecode');

          final courseQuery = await firestore
              .collection('course')
              .where('c_CourseCode', isEqualTo: cCoursecode)
              .get();
          print(
              'Fetched course documents for Course Code $cCoursecode: ${courseQuery.docs.length} courses found.');

          for (var courseDoc in courseQuery.docs) {
            final courseData = courseDoc.data();
            print('Course document data: $courseData');

            courses.add({
              'c_CourseCode': courseData['c_CourseCode'],
              'c_CourseName': courseData['c_CourseName'],
              'c_credit': courseData['c_credit'],
            });
            print('Added course to list: ${courseData['c_CourseName']}');
          }
        } else {
          print('Lecture document not found for Lecture ID: $lLectureid');
        }
      }
    } else if (role == 'instructor') {
      final instructorDoc =
          await firestore.collection('instructor').doc(userId).get();
      final iInstructorID = instructorDoc.get('i_InstructorID');
      print('Fetched instructor document: ${instructorDoc.data()}');
      print('Instructor ID: $iInstructorID');

      final lectureDocs = await firestore
          .collection('lecture')
          .where('i_InstructorID', isEqualTo: iInstructorID)
          .get();
      print(
          'Fetched lecture documents for instructor: ${lectureDocs.docs.length} lectures found.');

      Set<String> courseCodes = {};

      for (var lecture in lectureDocs.docs) {
        final cCoursecode = lecture.get('c_CourseCode');
        print('Lecture ID: ${lecture.id}, Course Code: $cCoursecode');

        if (!courseCodes.contains(cCoursecode)) {
          final courseQuery = await firestore
              .collection('course')
              .where('c_CourseCode', isEqualTo: cCoursecode)
              .get();
          print(
              'Fetched course documents for Course Code $cCoursecode: ${courseQuery.docs.length} courses found.');

          for (var courseDoc in courseQuery.docs) {
            final courseData = courseDoc.data();
            print('Course document data: $courseData');

            courses.add({
              'c_CourseCode': courseData['c_CourseCode'],
              'c_CourseName': courseData['c_CourseName'],
              'c_credit': courseData['c_credit'],
            });
            print('Added course to list: ${courseData['c_CourseName']}');
          }
          courseCodes.add(cCoursecode);
        } else {
          print('Course Code $cCoursecode already processed, skipping.');
        }
      }
    }

    return courses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Courses',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.accent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading courses'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses available'));
          }

          final courses = snapshot.data!;

          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/1609391092746.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
            child: Center(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.all(30),
                        height: 300,
                        width: 800,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Courses',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course['c_CourseName'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Course Code: ${course['c_CourseCode']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Credits: ${course['c_credit']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
