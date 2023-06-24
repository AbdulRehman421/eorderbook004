class User {
  final String userName;
  final String cmpcd;
  final String password;
  final String actype;
  final double code;
  final String description;
  final double userId;
  final String email;
  final String enabled;

  User({
    required this.userName,
    required this.cmpcd,
    required this.password,
    required this.actype,
    required this.code,
    required this.description,
    required this.userId,
    required this.email,
    required this.enabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userName: "${json['username']}"??'',
      cmpcd: "${json['cmpcd']}"??'',
      password: "${json['password']}"??'',
      actype: "${json['actype']}"??'',
      code: json['code'].toDouble()??'',
      description: "${json['description']}"??'',
      userId: json['userid'].toDouble(),
      email: json['email']??'',
      enabled: json['enabled']??'',
    );
  }

  @override
  String toString() {
    return 'User{userName: $userName, cmpcd: $cmpcd, password: $password, actype: $actype, code: $code, description: $description, userId: $userId, email: $email, enabled: $enabled}';
  }
}
