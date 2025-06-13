import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiStudent {
  final int? id;
  final String name;
  final String admissionNumber;
  final String section;
  final int? guardianId;
  final int studentNumber;

  ApiStudent({
    this.id,
    required this.name,
    required this.admissionNumber,
    required this.section,
    this.guardianId,
    required this.studentNumber,
  });

  factory ApiStudent.fromJson(Map<String, dynamic> json) {
    return ApiStudent(
      id: json['id'],
      name: json['name'] ?? '',
      admissionNumber: json['admission_number'] ?? '',
      section: json['section'] ?? '',
      guardianId: json['guardian_id'],
      studentNumber: json['student_number'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'admission_number': admissionNumber,
      'section': section,
      'guardian_id': guardianId,
      'student_number': studentNumber,
    };
  }
}

class ApiGrade {
  final int? id;
  final int studentId;
  final int subjectId;
  final double grade;

  ApiGrade({
    this.id,
    required this.studentId,
    required this.subjectId,
    required this.grade,
  });

  factory ApiGrade.fromJson(Map<String, dynamic> json) {
    return ApiGrade(
      id: json['id'],
      studentId: json['student_id'],
      subjectId: json['subject_id'],
      grade: (json['grade'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
      'grade': grade,
    };
  }
}

class ApiSubject {
  final int? id;
  final String name;

  ApiSubject({this.id, required this.name});

  factory ApiSubject.fromJson(Map<String, dynamic> json) {
    return ApiSubject(id: json['id'], name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'name': name};
  }
}

class ApiGuardian {
  final int? id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final int guardianNumber;

  ApiGuardian({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.guardianNumber,
  });

  factory ApiGuardian.fromJson(Map<String, dynamic> json) {
    return ApiGuardian(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      guardianNumber: json['guardian_number'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'guardian_number': guardianNumber,
    };
  }
}

class ApiScholarship {
  final int? id;
  final int studentId;
  final String name;
  final double amount;
  final String testimonial;

  ApiScholarship({
    this.id,
    required this.studentId,
    required this.name,
    required this.amount,
    required this.testimonial,
  });

  factory ApiScholarship.fromJson(Map<String, dynamic> json) {
    return ApiScholarship(
      id: json['id'],
      studentId: json['student_id'],
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      testimonial: json['testimonial'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'student_id': studentId,
      'name': name,
      'amount': amount,
      'testimonial': testimonial,
    };
  }
}

class ApiSchoolConfig {
  final int? id;
  final String schoolName;
  final String academicYear;
  final String term;
  final String examType;

  ApiSchoolConfig({
    this.id,
    required this.schoolName,
    required this.academicYear,
    required this.term,
    required this.examType,
  });

  factory ApiSchoolConfig.fromJson(Map<String, dynamic> json) {
    return ApiSchoolConfig(
      id: json['id'],
      schoolName: json['school_name'] ?? '',
      academicYear: json['academic_year'] ?? '',
      term: json['term'] ?? '',
      examType: json['exam_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'school_name': schoolName,
      'academic_year': academicYear,
      'term': term,
      'exam_type': examType,
    };
  }
}

class ApiPerformance {
  final int studentId;
  final String studentName;
  final double totalMarks;
  final double averageGrade;
  final String performance;

  ApiPerformance({
    required this.studentId,
    required this.studentName,
    required this.totalMarks,
    required this.averageGrade,
    required this.performance,
  });

  factory ApiPerformance.fromJson(Map<String, dynamic> json) {
    return ApiPerformance(
      studentId: json['student_id'],
      studentName: json['student_name'] ?? '',
      totalMarks: (json['total_marks'] ?? 0.0).toDouble(),
      averageGrade: (json['average_grade'] ?? 0.0).toDouble(),
      performance: json['performance'] ?? '',
    );
  }
}

class ApiService {
  static const String baseUrl =
      'http://localhost:8000/api'; // Replace with your backend URL
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  static Future<List<ApiStudent>> getStudents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/students'),
      headers: headers,
    );
    _handleError(response);

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ApiStudent.fromJson(json)).toList();
  }

  static Future<ApiStudent> createStudent(ApiStudent student) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students'),
      headers: headers,
      body: json.encode(student.toJson()),
    );
    _handleError(response);

    return ApiStudent.fromJson(json.decode(response.body));
  }

  static Future<ApiStudent> updateStudent(int id, ApiStudent student) async {
    final response = await http.put(
      Uri.parse('$baseUrl/students/$id'),
      headers: headers,
      body: json.encode(student.toJson()),
    );
    _handleError(response);

    return ApiStudent.fromJson(json.decode(response.body));
  }

  static Future<void> deleteStudent(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/students/$id'),
      headers: headers,
    );
    _handleError(response);
  }

  static Future<List<ApiGrade>> getGrades({int? studentId}) async {
    String url = '$baseUrl/grades';
    if (studentId != null) {
      url += '?student_id=$studentId';
    }

    final response = await http.get(Uri.parse(url), headers: headers);
    _handleError(response);

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ApiGrade.fromJson(json)).toList();
  }

  static Future<ApiGrade> createGrade(ApiGrade grade) async {
    final response = await http.post(
      Uri.parse('$baseUrl/grades'),
      headers: headers,
      body: json.encode(grade.toJson()),
    );
    _handleError(response);

    return ApiGrade.fromJson(json.decode(response.body));
  }

  static Future<ApiGrade> updateGrade(int id, ApiGrade grade) async {
    final response = await http.put(
      Uri.parse('$baseUrl/grades/$id'),
      headers: headers,
      body: json.encode(grade.toJson()),
    );
    _handleError(response);

    return ApiGrade.fromJson(json.decode(response.body));
  }

  static Future<void> deleteGrade(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/grades/$id'),
      headers: headers,
    );
    _handleError(response);
  }

  static Future<List<ApiSubject>> getSubjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subjects'),
      headers: headers,
    );
    _handleError(response);

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ApiSubject.fromJson(json)).toList();
  }

  static Future<ApiSubject> createSubject(ApiSubject subject) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subjects'),
      headers: headers,
      body: json.encode(subject.toJson()),
    );
    _handleError(response);

    return ApiSubject.fromJson(json.decode(response.body));
  }

  static Future<ApiSubject> updateSubject(int id, ApiSubject subject) async {
    final response = await http.put(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: headers,
      body: json.encode(subject.toJson()),
    );
    _handleError(response);

    return ApiSubject.fromJson(json.decode(response.body));
  }

  static Future<void> deleteSubject(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/subjects/$id'),
      headers: headers,
    );
    _handleError(response);
  }

  static Future<List<ApiGuardian>> getGuardians() async {
    final response = await http.get(
      Uri.parse('$baseUrl/guardians'),
      headers: headers,
    );
    _handleError(response);

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ApiGuardian.fromJson(json)).toList();
  }

  static Future<ApiGuardian> createGuardian(ApiGuardian guardian) async {
    final response = await http.post(
      Uri.parse('$baseUrl/guardians'),
      headers: headers,
      body: json.encode(guardian.toJson()),
    );
    _handleError(response);

    return ApiGuardian.fromJson(json.decode(response.body));
  }

  static Future<ApiGuardian> updateGuardian(
    int id,
    ApiGuardian guardian,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/guardians/$id'),
      headers: headers,
      body: json.encode(guardian.toJson()),
    );
    _handleError(response);

    return ApiGuardian.fromJson(json.decode(response.body));
  }

  static Future<void> deleteGuardian(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/guardians/$id'),
      headers: headers,
    );
    _handleError(response);
  }

  static Future<List<ApiScholarship>> getScholarships({int? studentId}) async {
    String url = '$baseUrl/scholarships';
    if (studentId != null) {
      url += '?student_id=$studentId';
    }

    final response = await http.get(Uri.parse(url), headers: headers);
    _handleError(response);

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ApiScholarship.fromJson(json)).toList();
  }

  static Future<ApiScholarship> createScholarship(
    ApiScholarship scholarship,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/scholarships'),
      headers: headers,
      body: json.encode(scholarship.toJson()),
    );
    _handleError(response);

    return ApiScholarship.fromJson(json.decode(response.body));
  }

  static Future<ApiScholarship> updateScholarship(
    int id,
    ApiScholarship scholarship,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/scholarships/$id'),
      headers: headers,
      body: json.encode(scholarship.toJson()),
    );
    _handleError(response);

    return ApiScholarship.fromJson(json.decode(response.body));
  }

  static Future<void> deleteScholarship(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/scholarships/$id'),
      headers: headers,
    );
    _handleError(response);
  }

  static Future<ApiSchoolConfig> getSchoolConfig() async {
    final response = await http.get(
      Uri.parse('$baseUrl/school_config'),
      headers: headers,
    );
    _handleError(response);

    return ApiSchoolConfig.fromJson(json.decode(response.body));
  }

  static Future<ApiSchoolConfig> updateSchoolConfig(
    ApiSchoolConfig config,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/school_config'),
      headers: headers,
      body: json.encode(config.toJson()),
    );
    _handleError(response);

    return ApiSchoolConfig.fromJson(json.decode(response.body));
  }

  static Future<List<ApiPerformance>> getPerformance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/performance'),
      headers: headers,
    );
    _handleError(response);

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ApiPerformance.fromJson(json)).toList();
  }

  static Future<ApiPerformance> getStudentPerformance(int studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/performance/$studentId'),
      headers: headers,
    );
    _handleError(response);

    return ApiPerformance.fromJson(json.decode(response.body));
  }
}
