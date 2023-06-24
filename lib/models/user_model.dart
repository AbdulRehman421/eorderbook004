class User {
  final String actype;
  final String cmpcd;
  final int code;
  final String description;
  final String email;
  final String password;
  final int userid;
  final String username;

  User(
      {required this.actype,
      required this.cmpcd,
      required this.code,
      required this.description,
      required this.email,
      required this.password,
      required this.userid,
      required this.username});

  Map<String, Object?> toMap() {
    var map = <String, Object?>{};
    map['actype'] = actype;
    map['cmpcd'] = cmpcd;
    map['code'] = code;
    map['description'] = description;
    map['email'] = email;
    map['password'] = password;
    map['userid'] = userid;
    map['username'] = username;
    return map;
  }

  User.fromMap(Map<Object?, Object?> map)
      : this(
            actype: map['actype'] as String,
            cmpcd: map['cmpcd'] as String,
            code: (map['code'] as dynamic).toInt(),
            description: map['description'] as String,
            email: map['email'] as String,
            password: map['password'].toString(),
            userid: (map['userid'] as dynamic).toInt(),
            username: map['username'] as String);
}
