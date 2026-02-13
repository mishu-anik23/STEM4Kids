class User {
  final String id;
  final String username;
  final String userType;
  final int? age;
  final int? grade;
  final int coins;
  final int totalStars;
  final int currentWorld;
  final int currentLevel;
  final String avatarUrl;
  final bool parentVerified;
  final int loginStreak;

  User({
    required this.id,
    required this.username,
    this.userType = 'student',
    this.age,
    this.grade,
    required this.coins,
    required this.totalStars,
    required this.currentWorld,
    required this.currentLevel,
    required this.avatarUrl,
    required this.parentVerified,
    this.loginStreak = 0,
  });

  // Helper getters for user type checking
  bool get isStudent => userType == 'student';
  bool get isTeacher => userType == 'teacher';
  bool get isParent => userType == 'parent';
  bool get hasUnrestrictedAccess => isTeacher || isParent;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      userType: json['userType'] ?? 'student',
      age: json['age'],
      grade: json['grade'],
      coins: json['coins'],
      totalStars: json['totalStars'],
      currentWorld: json['currentWorld'],
      currentLevel: json['currentLevel'],
      avatarUrl: json['avatarUrl'],
      parentVerified: json['parentVerified'],
      loginStreak: json['loginStreak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'userType': userType,
      'age': age,
      'grade': grade,
      'coins': coins,
      'totalStars': totalStars,
      'currentWorld': currentWorld,
      'currentLevel': currentLevel,
      'avatarUrl': avatarUrl,
      'parentVerified': parentVerified,
      'loginStreak': loginStreak,
    };
  }
}