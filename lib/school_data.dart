import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gssa_2/data/api_service.dart';
import 'package:gssa_2/screens/home_screen.dart';

class Subject {
  int? id;
  String name;

  Subject({this.id, required this.name});

  factory Subject.fromApi(ApiSubject apiSubject) {
    return Subject(id: apiSubject.id, name: apiSubject.name);
  }

  ApiSubject toApi() {
    return ApiSubject(id: id, name: name);
  }
}

class Scholarship {
  int? id; // Add database ID
  String name;
  double amount;
  String testimonial;

  Scholarship({
    this.id,
    required this.name,
    this.amount = 0.0,
    this.testimonial = '',
  });

  factory Scholarship.fromApi(ApiScholarship apiScholarship) {
    return Scholarship(
      id: apiScholarship.id,
      name: apiScholarship.name,
      amount: apiScholarship.amount,
      testimonial: apiScholarship.testimonial,
    );
  }

  ApiScholarship toApi(int studentId) {
    return ApiScholarship(
      id: id,
      studentId: studentId,
      name: name,
      amount: amount,
      testimonial: testimonial,
    );
  }
}

class Student {
  int? id; // Add database ID
  String name;
  String admissionNumber;
  String section;
  int? guardianId;
  Map<String, double> grades;
  List<Scholarship> scholarships;
  int studentNumber;

  Student({
    this.id,
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

  factory Student.fromApi(ApiStudent apiStudent) {
    return Student(
      id: apiStudent.id,
      name: apiStudent.name,
      admissionNumber: apiStudent.admissionNumber,
      section: apiStudent.section,
      guardianId: apiStudent.guardianId,
      studentNumber: apiStudent.studentNumber,
    );
  }
  ApiStudent toApi() {
    return ApiStudent(
      id: id,
      name: name,
      admissionNumber: admissionNumber,
      section: section,
      guardianId: guardianId,
      studentNumber: studentNumber,
    );
  }
}

class Guardian {
  int? id; // Add database ID
  String firstName;
  String lastName;
  String phoneNumber;
  int guardianNumber;

  Guardian({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.guardianNumber,
  });

  String get fullName => '$firstName $lastName';

  factory Guardian.fromApi(ApiGuardian apiGuardian) {
    return Guardian(
      id: apiGuardian.id,
      firstName: apiGuardian.firstName,
      lastName: apiGuardian.lastName,
      phoneNumber: apiGuardian.phoneNumber,
      guardianNumber: apiGuardian.guardianNumber,
    );
  }

  ApiGuardian toApi() {
    return ApiGuardian(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      guardianNumber: guardianNumber,
    );
  }
}

class SchoolData extends ChangeNotifier {
  String schoolName = 'Gssa';
  String academicYear = '2025';
  String term = 'First Term';
  String examType = 'Endterm Exam';

  List<Subject> subjects = [];
  List<Student> students = [];
  List<Guardian> guardians = [];

  bool isLoading = false;
  String? errorMessage;

  int _studentCounter = 0;
  int _guardianCounter = 0;
  int _scholarshipCounter = 0;

  Map<int, String> subjectIdToName = {};
  Map<String, int> subjectNameToId = {};

  Future<void> initializeFromBackend() async {
    setLoading(true);
    try {
      await Future.wait([
        loadSchoolConfig(),
        loadSubjects(),
        loadGuardians(),
        loadStudents(),
      ]);
      await loadGradesAndScholarships();
      setError(null);
    } catch (e) {
      setError('Failed to load data: $e');
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    errorMessage = error;
    notifyListeners();
  }

  Future<void> loadSchoolConfig() async {
    try {
      final config = await ApiService.getSchoolConfig();
      schoolName = config.schoolName;
      academicYear = config.academicYear;
      term = config.term;
      examType = config.examType;
    } catch (e) {
      print('No school config found, using defaults');
    }
  }

  Future<void> loadSubjects() async {
    final apiSubjects = await ApiService.getSubjects();
    subjects = apiSubjects.map((api) => Subject.fromApi(api)).toList();

    subjectIdToName.clear();
    subjectNameToId.clear();
    for (var subject in subjects) {
      if (subject.id != null) {
        subjectIdToName[subject.id!] = subject.name;
        subjectNameToId[subject.name] = subject.id!;
      }
    }
  }

  Future<void> loadGuardians() async {
    final apiGuardians = await ApiService.getGuardians();
    guardians = apiGuardians.map((api) => Guardian.fromApi(api)).toList();
    _guardianCounter = guardians.length;
  }

  Future<void> loadStudents() async {
    final apiStudents = await ApiService.getStudents();
    students = apiStudents.map((api) => Student.fromApi(api)).toList();
    _studentCounter = students.length;
  }

  Future<void> loadGradesAndScholarships() async {
    for (var student in students) {
      if (student.id != null) {
        await loadStudentGrades(student);
        await loadStudentScholarships(student);
      }
    }
  }

  Future<void> loadStudentGrades(Student student) async {
    if (student.id == null) return;

    final grades = await ApiService.getGrades(studentId: student.id!);
    student.grades.clear();

    for (var subject in subjects) {
      student.grades[subject.name] = 0.0;
    }

    for (var grade in grades) {
      final subjectName = subjectIdToName[grade.subjectId];
      if (subjectName != null) {
        student.grades[subjectName] = grade.grade;
      }
    }
  }

  Future<void> loadStudentScholarships(Student student) async {
    if (student.id == null) return;

    final scholarships = await ApiService.getScholarships(
      studentId: student.id!,
    );
    student.scholarships =
        scholarships.map((api) => Scholarship.fromApi(api)).toList();
  }

  Future<void> updateSchoolConfig({
    String? name,
    String? year,
    String? termType,
    String? exam,
  }) async {
    if (name != null) schoolName = name;
    if (year != null) academicYear = year;
    if (termType != null) term = termType;
    if (exam != null) examType = exam;

    try {
      final config = ApiSchoolConfig(
        schoolName: schoolName,
        academicYear: academicYear,
        term: term,
        examType: examType,
      );
      await ApiService.updateSchoolConfig(config);
      notifyListeners();
    } catch (e) {
      setError('Failed to update school config: $e');
    }
  }

  Future<void> addSubject(String name) async {
    if (name.isEmpty || subjects.any((s) => s.name == name)) return;

    try {
      final apiSubject = await ApiService.createSubject(ApiSubject(name: name));
      final subject = Subject.fromApi(apiSubject);
      subjects.add(subject);

      if (subject.id != null) {
        subjectIdToName[subject.id!] = subject.name;
        subjectNameToId[subject.name] = subject.id!;
      }

      for (var student in students) {
        student.grades[name] = 0.0;
        if (student.id != null && subject.id != null) {
          await ApiService.createGrade(
            ApiGrade(
              studentId: student.id!,
              subjectId: subject.id!,
              grade: 0.0,
            ),
          );
        }
      }

      notifyListeners();
    } catch (e) {
      setError('Failed to add subject: $e');
    }
  }

  Future<void> removeSubject(String name) async {
    final subject = subjects.firstWhereOrNull((s) => s.name == name);
    if (subject?.id == null) return;

    try {
      await ApiService.deleteSubject(subject!.id!);
      subjects.removeWhere((s) => s.name == name);

      subjectIdToName.remove(subject.id);
      subjectNameToId.remove(name);

      for (var student in students) {
        student.grades.remove(name);
      }

      notifyListeners();
    } catch (e) {
      setError('Failed to remove subject: $e');
    }
  }

  Future<void> addStudent({
    String? name,
    String? admissionNumber,
    String? section,
    int? guardianId,
  }) async {
    _studentCounter++;

    try {
      final apiStudent = await ApiService.createStudent(
        ApiStudent(
          name: name ?? 'Student $_studentCounter',
          admissionNumber: admissionNumber ?? 'AD$_studentCounter',
          section: section ?? 'Section A',
          guardianId: guardianId,
          studentNumber: _studentCounter,
        ),
      );

      final student = Student.fromApi(apiStudent);
      students.add(student);

      for (var subject in subjects) {
        student.grades[subject.name] = 0.0;
        if (subject.id != null) {
          await ApiService.createGrade(
            ApiGrade(
              studentId: student.id!,
              subjectId: subject.id!,
              grade: 0.0,
            ),
          );
        }
      }

      notifyListeners();
    } catch (e) {
      _studentCounter--;
      setError('Failed to add student: $e');
    }
  }

  Future<void> addGuardian({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    _guardianCounter++;

    try {
      final apiGuardian = await ApiService.createGuardian(
        ApiGuardian(
          firstName: firstName ?? 'Guardian',
          lastName: lastName ?? '$_guardianCounter',
          phoneNumber: phoneNumber ?? '',
          guardianNumber: _guardianCounter,
        ),
      );

      guardians.add(Guardian.fromApi(apiGuardian));
      notifyListeners();
    } catch (e) {
      _guardianCounter--;
      setError('Failed to add guardian: $e');
    }
  }

  Future<void> updateStudent(int studentId, Student updatedStudent) async {
    final index = students.indexWhere((s) => s.id == studentId);
    if (index == -1) return;

    try {
      await ApiService.updateStudent(studentId, updatedStudent.toApi());
      students[index] = updatedStudent;
      notifyListeners();
    } catch (e) {
      setError('Failed to update student: $e');
    }
  }

  Future<void> removeGuardian(int guardianNumber) async {
    final guardian = guardians.firstWhereOrNull(
      (g) => g.guardianNumber == guardianNumber,
    );
    if (guardian?.id == null) return;

    try {
      await ApiService.deleteGuardian(guardian!.id!);
      guardians.removeWhere((g) => g.guardianNumber == guardianNumber);

      for (var student in students) {
        if (student.guardianId == guardianNumber) {
          student.guardianId = null;
          if (student.id != null) {
            await ApiService.updateStudent(student.id!, student.toApi());
          }
        }
      }

      for (int i = 0; i < guardians.length; i++) {
        guardians[i].guardianNumber = i + 1;
        if (guardians[i].id != null) {
          await ApiService.updateGuardian(
            guardians[i].id!,
            guardians[i].toApi(),
          );
        }
      }
      _guardianCounter = guardians.length;
      notifyListeners();
    } catch (e) {
      setError('Failed to remove guardian: $e');
    }
  }

  Future<void> clearAllGuardians() async {
    try {
      for (var guardian in guardians) {
        if (guardian.id != null) {
          await ApiService.deleteGuardian(guardian.id!);
        }
      }

      guardians.clear();

      for (var student in students) {
        if (student.guardianId != null) {
          student.guardianId = null;
          if (student.id != null) {
            await ApiService.updateStudent(student.id!, student.toApi());
          }
        }
      }

      _guardianCounter = 0;
      notifyListeners();
    } catch (e) {
      setError('Failed to clear guardians: $e');
    }
  }
}
