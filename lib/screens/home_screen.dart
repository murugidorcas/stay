import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as fa;
import 'dart:html' as html;

class Subject {
  String name;
  Subject({required this.name});
}

class Scholarship {
  String name;
  double amount;
  String testimonial;

  Scholarship({required this.name, this.amount = 0.0, this.testimonial = ''});
}

class Student {
  String name;
  String admissionNumber;
  String section;
  int? guardianId;
  Map<String, double> grades;
  List<Scholarship> scholarships;
  int studentNumber;

  Student({
    required this.name,
    required this.admissionNumber,
    required this.section,
    this.guardianId,
    Map<String, double>? grades,
    List<Scholarship>? scholarships,
    required this.studentNumber,
  }) : grades = grades ?? {},
       scholarships = scholarships ?? [];

  double get totalMarks {
    return grades.values.fold(0.0, (sum, grade) => sum + grade);
  }

  double get averageGrade {
    if (grades.isEmpty) return 0.0;

    final gradedSubjects = grades.values.where((grade) => grade > 0).length;
    if (gradedSubjects == 0) return 0.0;
    return totalMarks / gradedSubjects;
  }

  String get performance {
    if (averageGrade >= 90) return 'Excellent';
    if (averageGrade >= 80) return 'Good';
    if (averageGrade >= 70) return 'Average';
    return 'Needs Improvement';
  }

  Color get performanceColor {
    if (averageGrade >= 90) return Colors.green.shade700;
    if (averageGrade >= 80) return Colors.orange.shade700;
    if (averageGrade >= 70) return Colors.amber.shade700;
    return Colors.red.shade700;
  }
}

class Guardian {
  String firstName;
  String lastName;
  String phoneNumber;
  int guardianNumber;

  Guardian({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.guardianNumber,
  });

  String get fullName => '$firstName $lastName';
}

class SchoolData extends ChangeNotifier {
  String schoolName = 'Gssa';
  String academicYear = '2025';
  String term = 'First Term';
  String examType = 'Endterm Exam';

  List<Subject> subjects = [
    Subject(name: 'Mathematics'),
    Subject(name: 'English'),
    Subject(name: 'Science'),
    Subject(name: 'History'),
  ];
  List<Student> students = [];
  List<Guardian> guardians = [];

  int _studentCounter = 0;
  int _guardianCounter = 0;
  int _scholarshipCounter = 0;

  void updateSchoolConfig({
    String? name,
    String? year,
    String? termType,
    String? exam,
  }) {
    if (name != null) schoolName = name;
    if (year != null) academicYear = year;
    if (termType != null) term = termType;
    if (exam != null) examType = exam;
    notifyListeners();
  }

  void addSubject(String name) {
    if (name.isNotEmpty && !subjects.any((s) => s.name == name)) {
      subjects.add(Subject(name: name));

      for (var student in students) {
        if (!student.grades.containsKey(name)) {
          student.grades[name] = 0.0;
        }
      }
      notifyListeners();
    }
  }

  void removeSubject(String name) {
    subjects.removeWhere((s) => s.name == name);

    for (var student in students) {
      student.grades.remove(name);
    }
    notifyListeners();
  }

  void addGuardian({String? firstName, String? lastName, String? phoneNumber}) {
    _guardianCounter++;
    guardians.add(
      Guardian(
        firstName: firstName ?? 'Guardian',
        lastName: lastName ?? '$_guardianCounter',
        phoneNumber: phoneNumber ?? '',
        guardianNumber: _guardianCounter,
      ),
    );
    notifyListeners();
  }

  void removeGuardian(int guardianNumber) {
    guardians.removeWhere((g) => g.guardianNumber == guardianNumber);

    for (var student in students) {
      if (student.guardianId == guardianNumber) {
        student.guardianId = null;
      }
    }

    for (int i = 0; i < guardians.length; i++) {
      guardians[i].guardianNumber = i + 1;
    }
    _guardianCounter = guardians.length;
    notifyListeners();
  }

  void clearAllGuardians() {
    guardians.clear();

    for (var student in students) {
      student.guardianId = null;
    }
    _guardianCounter = 0;
    notifyListeners();
  }

  void updateGuardian(
    int guardianNumber, {
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) {
    final guardian = guardians.firstWhere(
      (g) => g.guardianNumber == guardianNumber,
    );
    if (firstName != null) guardian.firstName = firstName;
    if (lastName != null) guardian.lastName = lastName;
    if (phoneNumber != null) guardian.phoneNumber = phoneNumber;
    notifyListeners();
  }

  void addStudent({
    String? name,
    String? admission,
    String? section,
    int? guardianId,
  }) {
    _studentCounter++;
    students.add(
      Student(
        name: name ?? 'Student',
        admissionNumber: admission ?? '',
        section: section ?? '',
        guardianId: guardianId,
        grades: {for (var s in subjects) s.name: 0.0},
        studentNumber: _studentCounter,
      ),
    );
    notifyListeners();
  }

  void removeStudent(int studentNumber) {
    students.removeWhere((s) => s.studentNumber == studentNumber);

    for (int i = 0; i < students.length; i++) {
      students[i].studentNumber = i + 1;
    }
    _studentCounter = students.length;
    notifyListeners();
  }

  void clearAllStudents() {
    students.clear();
    _studentCounter = 0;
    notifyListeners();
  }

  void updateStudent(
    int studentNumber, {
    String? name,
    String? admission,
    String? section,
    int? guardianId,
  }) {
    final student = students.firstWhere(
      (s) => s.studentNumber == studentNumber,
    );
    if (name != null) student.name = name;
    if (admission != null) student.admissionNumber = admission;
    if (section != null) student.section = section;
    if (guardianId != null) student.guardianId = guardianId;
    notifyListeners();
  }

  void updateStudentGrade(int studentNumber, String subjectName, double grade) {
    final student = students.firstWhere(
      (s) => s.studentNumber == studentNumber,
    );
    student.grades[subjectName] = grade;
    notifyListeners();
  }

  void addScholarship(
    int studentNumber, {
    String? name,
    double? amount,
    String? testimonial,
  }) {
    final student = students.firstWhere(
      (s) => s.studentNumber == studentNumber,
    );
    _scholarshipCounter++;
    student.scholarships.add(
      Scholarship(
        name: name ?? 'Scholarship $_scholarshipCounter',
        amount: amount ?? 0.0,
        testimonial: testimonial ?? '',
      ),
    );
    notifyListeners();
  }

  void removeScholarship(int studentNumber, Scholarship scholarship) {
    final student = students.firstWhere(
      (s) => s.studentNumber == studentNumber,
    );
    student.scholarships.remove(scholarship);
    notifyListeners();
  }

  String getGuardianName(int? guardianId) {
    if (guardianId == null) return 'N/A';
    final guardian = guardians.firstWhereOrNull(
      (g) => g.guardianNumber == guardianId,
    );
    return guardian?.fullName ?? 'N/A';
  }

  String getGuardianPhone(int? guardianId) {
    if (guardianId == null) return 'N/A';
    final guardian = guardians.firstWhereOrNull(
      (g) => g.guardianNumber == guardianId,
    );
    return guardian?.phoneNumber ?? 'N/A';
  }

  void addSampleData() {
    addGuardian(
      firstName: 'John',
      lastName: 'Doe',
      phoneNumber: '254712345678',
    );
    addGuardian(
      firstName: 'Jane',
      lastName: 'Smith',
      phoneNumber: '254722334455',
    );
    addStudent(
      name: 'Alice Smith',
      admission: 'GSSA/001/2025',
      section: 'Grade 1A',
      guardianId: 1,
    );
    final alice = students.firstWhere((s) => s.studentNumber == 1);
    updateStudentGrade(alice.studentNumber, 'Mathematics', 95);
    updateStudentGrade(alice.studentNumber, 'English', 88);
    updateStudentGrade(alice.studentNumber, 'Science', 92);
    updateStudentGrade(alice.studentNumber, 'History', 85);
    addScholarship(
      alice.studentNumber,
      name: 'Academic Excellence Award',
      amount: 500.00,
      testimonial:
          'Alice consistently demonstrates outstanding academic performance.',
    );

    addStudent(
      name: 'Bob Johnson',
      admission: 'GSSA/002/2025',
      section: 'Grade 1B',
      guardianId: 2,
    );
    final bob = students.firstWhere((s) => s.studentNumber == 2);
    updateStudentGrade(bob.studentNumber, 'Mathematics', 70);
    updateStudentGrade(bob.studentNumber, 'English', 75);
    updateStudentGrade(bob.studentNumber, 'Science', 68);
    updateStudentGrade(bob.studentNumber, 'History', 80);
    addScholarship(
      bob.studentNumber,
      name: 'Sports Scholarship',
      amount: 300.00,
      testimonial: 'Bob excels in inter-school sports.',
    );

    notifyListeners();
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

class StudentGradeSystemHomePage extends StatefulWidget {
  const StudentGradeSystemHomePage({super.key});

  @override
  State<StudentGradeSystemHomePage> createState() =>
      _StudentGradeSystemHomePageState();
}

class _StudentGradeSystemHomePageState extends State<StudentGradeSystemHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _subjectInputController = TextEditingController();

  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();
  String? _selectedTerm;
  String? _selectedExamType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final schoolData = Provider.of<SchoolData>(context, listen: false);
    _schoolNameController.text = schoolData.schoolName;
    _academicYearController.text = schoolData.academicYear;
    _selectedTerm = schoolData.term;
    _selectedExamType = schoolData.examType;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      schoolData.addSampleData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectInputController.dispose();
    _schoolNameController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSchoolConfiguration(),
                const SizedBox(height: 20),
                _buildSubjectConfiguration(),
                const SizedBox(height: 20),
                _buildGuardianStudentTabs(),
                const SizedBox(height: 20),
                _buildExportSection(context),
                const SizedBox(height: 20),
                _buildPreviewSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          const Text(
            '📊 Gssa Student Grade System',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Manage students grades, guardians and scholarships with Excel export',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  FaIcon(icon, size: 24, color: Colors.grey.shade700),
                  const SizedBox(width: 10),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 1, color: Color(0xFFe9ecef)),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolConfiguration() {
    return _buildSection(
      title: 'School Configuration',
      icon: fa.FontAwesomeIcons.school,
      child: Consumer<SchoolData>(
        builder: (context, schoolData, child) {
          return Column(
            children: [
              TextFormField(
                controller: _schoolNameController,
                decoration: const InputDecoration(labelText: 'School Name'),
                onChanged:
                    (value) => schoolData.updateSchoolConfig(name: value),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _academicYearController,
                decoration: const InputDecoration(labelText: 'Academic Year'),
                onChanged:
                    (value) => schoolData.updateSchoolConfig(year: value),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedTerm,
                decoration: const InputDecoration(labelText: 'Term/Semester'),
                items:
                    <String>[
                      'First Term',
                      'Second Term',
                      'Third Term',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTerm = newValue;
                  });
                  if (newValue != null)
                    schoolData.updateSchoolConfig(termType: newValue);
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedExamType,
                decoration: const InputDecoration(labelText: 'Exam Type'),
                items:
                    <String>[
                      'Opener Exam',
                      'Midterm Exam',
                      'Endterm Exam',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedExamType = newValue;
                  });
                  if (newValue != null)
                    schoolData.updateSchoolConfig(exam: newValue);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubjectConfiguration() {
    return _buildSection(
      title: 'Subject Configuration',
      icon: fa.FontAwesomeIcons.book,
      child: Consumer<SchoolData>(
        builder: (context, schoolData, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _subjectInputController,
                decoration: InputDecoration(
                  labelText: 'Add Subject',
                  hintText: 'Enter subject name',
                  suffixIcon: ElevatedButton(
                    onPressed: () {
                      schoolData.addSubject(_subjectInputController.text);
                      _subjectInputController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      minimumSize: const Size(50, 48),
                    ),
                    child: const FaIcon(fa.FontAwesomeIcons.plus),
                  ),
                ),
                onSubmitted: (value) {
                  schoolData.addSubject(value);
                  _subjectInputController.clear();
                },
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children:
                    schoolData.subjects.map((subject) {
                      return Chip(
                        backgroundColor: const Color(0xFF4facfe),
                        label: Text(
                          subject.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onDeleted: () => schoolData.removeSubject(subject.name),
                        deleteIconColor: Colors.white,
                      );
                    }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGuardianStudentTabs() {
    return _buildSection(
      title: '',
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4facfe),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: const Color(0xFF4facfe),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(fa.FontAwesomeIcons.users, size: 18),
                    SizedBox(width: 8),
                    Text('Guardians'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(fa.FontAwesomeIcons.userGraduate, size: 18),
                    SizedBox(width: 8),
                    Text('Students'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: TabBarView(
              controller: _tabController,
              children: [_buildGuardiansTab(), _buildStudentsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardiansTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed:
                  () =>
                      Provider.of<SchoolData>(
                        context,
                        listen: false,
                      ).addGuardian(),
              icon: const FaIcon(fa.FontAwesomeIcons.userPlus, size: 16),
              label: const Text('Add Guardian'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed:
                  () =>
                      Provider.of<SchoolData>(
                        context,
                        listen: false,
                      ).clearAllGuardians(),
              icon: const FaIcon(fa.FontAwesomeIcons.trashAlt, size: 16),
              label: const Text('Clear All Guardians'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFff416c),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Expanded(
          child: Consumer<SchoolData>(
            builder: (context, schoolData, child) {
              if (schoolData.guardians.isEmpty) {
                return const Center(child: Text('No guardians added yet.'));
              }
              return ListView.builder(
                itemCount: schoolData.guardians.length,
                itemBuilder: (context, index) {
                  final guardian = schoolData.guardians[index];
                  return _buildGuardianEntry(guardian, schoolData);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuardianEntry(Guardian guardian, SchoolData schoolData) {
    final TextEditingController firstNameController = TextEditingController(
      text: guardian.firstName,
    );
    final TextEditingController lastNameController = TextEditingController(
      text: guardian.lastName,
    );
    final TextEditingController phoneController = TextEditingController(
      text: guardian.phoneNumber,
    );

    firstNameController.addListener(() {
      schoolData.updateGuardian(
        guardian.guardianNumber,
        firstName: firstNameController.text,
      );
    });
    lastNameController.addListener(() {
      schoolData.updateGuardian(
        guardian.guardianNumber,
        lastName: lastNameController.text,
      );
    });
    phoneController.addListener(() {
      schoolData.updateGuardian(
        guardian.guardianNumber,
        phoneNumber: phoneController.text,
      );
    });

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: const Color(0xFFff6b6b),
                      child: Text(
                        '${guardian.guardianNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Guardian ${guardian.guardianNumber}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const FaIcon(
                    fa.FontAwesomeIcons.timesCircle,
                    color: Color(0xFFff4757),
                  ),
                  onPressed:
                      () => schoolData.removeGuardian(guardian.guardianNumber),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      hintText: 'First Name',
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      hintText: 'Last Name',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Phone Number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            Text(
              'Associated Students:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Consumer<SchoolData>(
              builder: (context, schoolData, child) {
                final associatedStudents =
                    schoolData.students
                        .where((s) => s.guardianId == guardian.guardianNumber)
                        .map(
                          (s) =>
                              s.name.isNotEmpty
                                  ? s.name
                                  : 'Unnamed Student ${s.studentNumber}',
                        )
                        .toList();
                return Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children:
                      associatedStudents.map((name) {
                        return Chip(
                          backgroundColor: Colors.blueGrey.shade100,
                          label: Text(
                            name,
                            style: TextStyle(
                              color: Colors.blueGrey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed:
                  () =>
                      Provider.of<SchoolData>(
                        context,
                        listen: false,
                      ).addStudent(),
              icon: const FaIcon(fa.FontAwesomeIcons.userPlus, size: 16),
              label: const Text('Add Student'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed:
                  () =>
                      Provider.of<SchoolData>(
                        context,
                        listen: false,
                      ).clearAllStudents(),
              icon: const FaIcon(fa.FontAwesomeIcons.trashAlt, size: 16),
              label: const Text('Clear All Students'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFff416c),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Expanded(
          child: Consumer<SchoolData>(
            builder: (context, schoolData, child) {
              if (schoolData.students.isEmpty) {
                return const Center(child: Text('No students added yet.'));
              }
              return ListView.builder(
                itemCount: schoolData.students.length,
                itemBuilder: (context, index) {
                  final student = schoolData.students[index];
                  return _buildStudentEntry(student, schoolData);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentEntry(Student student, SchoolData schoolData) {
    final TextEditingController nameController = TextEditingController(
      text: student.name,
    );
    final TextEditingController admissionController = TextEditingController(
      text: student.admissionNumber,
    );

    nameController.addListener(() {
      schoolData.updateStudent(
        student.studentNumber,
        name: nameController.text,
      );
    });
    admissionController.addListener(() {
      schoolData.updateStudent(
        student.studentNumber,
        admission: admissionController.text,
      );
    });

    List<DropdownMenuItem<int>> guardianDropdownItems =
        schoolData.guardians.map((g) {
          return DropdownMenuItem<int>(
            value: g.guardianNumber,
            child: Text(g.fullName),
          );
        }).toList();
    guardianDropdownItems.insert(
      0,
      const DropdownMenuItem<int>(value: null, child: Text('Select Guardian')),
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: const Color(0xFF4facfe),
                      child: Text(
                        '${student.studentNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Student ${student.studentNumber}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const FaIcon(
                    fa.FontAwesomeIcons.timesCircle,
                    color: Color(0xFFff4757),
                  ),
                  onPressed:
                      () => schoolData.removeStudent(student.studentNumber),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                hintText: 'Student Name',
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: admissionController,
              decoration: const InputDecoration(
                labelText: 'Admission Number',
                hintText: 'Admission Number',
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: student.section.isNotEmpty ? student.section : null,
              decoration: const InputDecoration(labelText: 'Class/Section'),
              items:
                  <String>[
                    'Grade 1A',
                    'Grade 1B',
                    'Grade 2A',
                    'Grade 2B',
                    'Grade 3A',
                    'Grade 3B',
                    'Grade 4A',
                    'Grade 4B',
                    'Grade 5A',
                    'Grade 5B',
                    'Grade 6A',
                    'Grade 6B',
                    'Grade 7A',
                    'Grade 7B',
                    'Grade 8A',
                    'Grade 8B',
                    'Grade 9A',
                    'Grade 9B',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null)
                  schoolData.updateStudent(
                    student.studentNumber,
                    section: newValue,
                  );
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<int>(
              value: student.guardianId,
              decoration: const InputDecoration(labelText: 'Guardian'),
              items: guardianDropdownItems,
              onChanged: (int? newValue) {
                schoolData.updateStudent(
                  student.studentNumber,
                  guardianId: newValue,
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Grades:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 15.0,
              runSpacing: 15.0,
              children:
                  schoolData.subjects.map((subject) {
                    return SizedBox(
                      width: 180,
                      child: TextFormField(
                        initialValue: student.grades[subject.name]
                            ?.toStringAsFixed(0),
                        decoration: InputDecoration(
                          labelText: subject.name,
                          hintText: 'Grade',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final grade = double.tryParse(value);
                          if (grade != null) {
                            schoolData.updateStudentGrade(
                              student.studentNumber,
                              subject.name,
                              grade,
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🎓 Scholarships',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      () => schoolData.addScholarship(student.studentNumber),
                  icon: const FaIcon(fa.FontAwesomeIcons.plus, size: 14),
                  label: const Text('Add Scholarship'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf7971e),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (student.scholarships.isEmpty)
              const Text('No scholarships added for this student.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: student.scholarships.length,
                itemBuilder: (context, idx) {
                  final scholarship = student.scholarships[idx];
                  final TextEditingController scholarshipNameController =
                      TextEditingController(text: scholarship.name);
                  final TextEditingController scholarshipAmountController =
                      TextEditingController(
                        text: scholarship.amount.toStringAsFixed(2),
                      );
                  final TextEditingController scholarshipTestimonialController =
                      TextEditingController(text: scholarship.testimonial);

                  return Card(
                    color: const Color(0xFFfff3cd),
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Scholarship ${idx + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF856404),
                                ),
                              ),
                              IconButton(
                                icon: const FaIcon(
                                  fa.FontAwesomeIcons.times,
                                  size: 18,
                                  color: Color(0xFFff4757),
                                ),
                                onPressed:
                                    () => schoolData.removeScholarship(
                                      student.studentNumber,
                                      scholarship,
                                    ),
                                tooltip: 'Remove Scholarship',
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: scholarshipNameController,
                            decoration: const InputDecoration(
                              labelText: 'Scholarship Name',
                            ),
                            onChanged: (value) => scholarship.name = value,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: scholarshipAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              scholarship.amount =
                                  double.tryParse(value) ?? 0.0;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: scholarshipTestimonialController,
                            decoration: const InputDecoration(
                              labelText: 'Provider Testimonial',
                            ),
                            maxLines: 3,
                            onChanged:
                                (value) => scholarship.testimonial = value,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Text(
            '📤 Export Data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Export comprehensive student data including grades, scholarships, and guardian information',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Wrap(
            spacing: 15.0,
            runSpacing: 15.0,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _exportToExcel(context),
                icon: const FaIcon(fa.FontAwesomeIcons.fileExcel, size: 20),
                label: const Text('Export to Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF56ab2f),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _previewData(context),
                icon: const FaIcon(fa.FontAwesomeIcons.eye, size: 20),
                label: const Text('Preview Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4facfe),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return Consumer<SchoolData>(
      builder: (context, schoolData, child) {
        if (schoolData.students.isEmpty && !showPreview) {
          return const SizedBox.shrink();
        }
        return AnimatedOpacity(
          opacity: showPreview ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child:
                showPreview
                    ? _buildSection(
                      title: 'Data Preview',
                      icon: fa.FontAwesomeIcons.eye,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _generatePreviewTable(schoolData),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  bool showPreview = false;

  DataTable _generatePreviewTable(SchoolData schoolData) {
    if (schoolData.students.isEmpty) {
      return DataTable(columns: const [], rows: const []);
    }

    final maxScholarships =
        schoolData.students.isEmpty
            ? 0
            : schoolData.students
                .map((s) => s.scholarships.length)
                .reduce((a, b) => a > b ? a : b);

    List<DataColumn> columns = [
      const DataColumn(label: Text('Student Name')),
      const DataColumn(label: Text('Admission No.')),
      const DataColumn(label: Text('Class/Section')),
      const DataColumn(label: Text('Guardian Name')),
      const DataColumn(label: Text('Guardian Phone')),
    ];

    for (var subject in schoolData.subjects) {
      columns.add(DataColumn(label: Text(subject.name)));
    }
    columns.add(const DataColumn(label: Text('Total Marks')));
    columns.add(const DataColumn(label: Text('Average Grade')));
    columns.add(const DataColumn(label: Text('Performance')));

    for (int i = 1; i <= maxScholarships; i++) {
      columns.add(DataColumn(label: Text('Scholarship $i (Name)')));
      columns.add(DataColumn(label: Text('Scholarship $i (Amount)')));
      //columns.add(DataColumn(label: Text('Scholarship $i (Testimonial)')));
    }

    List<DataRow> rows =
        schoolData.students.map((student) {
          List<DataCell> cells = [
            DataCell(Text(student.name)),
            DataCell(Text(student.admissionNumber)),
            DataCell(Text(student.section)),
            DataCell(Text(schoolData.getGuardianName(student.guardianId))),
            DataCell(Text(schoolData.getGuardianPhone(student.guardianId))),
          ];

          for (var subject in schoolData.subjects) {
            final grade = student.grades[subject.name] ?? 0.0;
            cells.add(DataCell(Text(grade.toStringAsFixed(0))));
          }

          cells.add(DataCell(Text(student.totalMarks.toStringAsFixed(0))));
          cells.add(DataCell(Text(student.averageGrade.toStringAsFixed(2))));
          cells.add(
            DataCell(
              Row(
                children: [
                  Text(student.performance),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: student.performanceColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        student.performance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          for (int i = 0; i < maxScholarships; i++) {
            final scholarship =
                i < student.scholarships.length
                    ? student.scholarships[i]
                    : null;
            cells.add(DataCell(Text(scholarship?.name ?? '')));
            cells.add(
              DataCell(Text(scholarship?.amount.toStringAsFixed(2) ?? '')),
            );
          }

          return DataRow(cells: cells);
        }).toList();

    return DataTable(
      columns: columns,
      rows: rows,
      headingRowColor: MaterialStateProperty.resolveWith(
        (states) => const Color(0xFF4facfe),
      ),
      headingTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),

      columnSpacing: 10,
      horizontalMargin: 10,
    );
  }

  void _exportToExcel(BuildContext context) async {
    final schoolData = Provider.of<SchoolData>(context, listen: false);

    if (schoolData.students.isEmpty) {
      _showSnackBar(context, 'No student data to export.', Colors.red);
      return;
    }

    final excel = Excel.createExcel();
    final sheet = excel['Student Grades'];

    sheet.appendRow([
      TextCellValue('School Name:'),
      TextCellValue(schoolData.schoolName),
    ]);
    sheet.appendRow([
      TextCellValue('Academic Year:'),
      TextCellValue(schoolData.academicYear),
    ]);
    sheet.appendRow([
      TextCellValue('Term/Semester:'),
      TextCellValue(schoolData.term),
    ]);
    sheet.appendRow([
      TextCellValue('Exam Type:'),
      TextCellValue(schoolData.examType),
    ]);
    sheet.appendRow([]);

    List<CellValue> mainHeaders = [
      TextCellValue('Student Name'),
      TextCellValue('Admission No.'),
      TextCellValue('Class/Section'),
      TextCellValue('Guardian Name'),
      TextCellValue('Guardian Phone'),
    ];

    for (var subject in schoolData.subjects) {
      mainHeaders.add(TextCellValue(subject.name));
    }
    mainHeaders.add(TextCellValue('Total Marks'));
    mainHeaders.add(TextCellValue('Average Grade'));
    mainHeaders.add(TextCellValue('Performance'));

    final maxScholarships =
        schoolData.students.isEmpty
            ? 0
            : schoolData.students
                .map((s) => s.scholarships.length)
                .reduce((a, b) => a > b ? a : b);
    for (int i = 1; i <= maxScholarships; i++) {
      mainHeaders.add(TextCellValue('Scholarship $i Name'));
      mainHeaders.add(TextCellValue('Scholarship $i Amount'));
    }
    sheet.appendRow(mainHeaders);

    for (var student in schoolData.students) {
      List<CellValue> rowData = [
        TextCellValue(student.name),
        TextCellValue(student.admissionNumber),
        TextCellValue(student.section),
        TextCellValue(schoolData.getGuardianName(student.guardianId)),
        TextCellValue(schoolData.getGuardianPhone(student.guardianId)),
      ];

      for (var subject in schoolData.subjects) {
        rowData.add(DoubleCellValue(student.grades[subject.name] ?? 0.0));
      }
      rowData.add(DoubleCellValue(student.totalMarks));
      rowData.add(
        DoubleCellValue(double.parse(student.averageGrade.toStringAsFixed(2))),
      );
      rowData.add(TextCellValue(student.performance));

      for (int i = 0; i < maxScholarships; i++) {
        final scholarship =
            i < student.scholarships.length ? student.scholarships[i] : null;
        rowData.add(TextCellValue(scholarship?.name ?? ''));
        rowData.add(DoubleCellValue(scholarship?.amount ?? 0.0));
        //rowData.add(TextCellValue(scholarship?.testimonial ?? ''));
      }
      sheet.appendRow(rowData);
    }

    try {
      final List<int>? fileBytes = excel.save();
      if (fileBytes == null) {
        _showSnackBar(context, 'Failed to generate Excel file.', Colors.red);
        return;
      }

      if (kIsWeb) {
        final blob = html.Blob([fileBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.Url.revokeObjectUrl(url);
        _showSnackBar(
          context,
          'Excel file downloaded successfully!',
          Colors.green,
        );
      } else {
        final directory = await getTemporaryDirectory();
        final String filePath = '${directory.path}/Gssa_Student_Grades.xlsx';
        final File file = File(filePath);
        await file.writeAsBytes(fileBytes);
        await OpenFilex.open(filePath);
        _showSnackBar(
          context,
          'Excel file exported successfully to $filePath',
          Colors.green,
        );
      }
    } catch (e) {
      _showSnackBar(context, 'Error exporting Excel: $e', Colors.red);
    }
  }

  void _previewData(BuildContext context) {
    setState(() {
      showPreview = !showPreview;
    });
    if (Provider.of<SchoolData>(context, listen: false).students.isEmpty &&
        showPreview) {
      _showSnackBar(
        context,
        'No student data to preview. Please add students.',
        Colors.red,
      );
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
