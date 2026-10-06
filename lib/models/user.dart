class User {
  String? email;
  String? password;
  String? name;
  String? lastName;
  DateTime? birthday;
  String? visualDegree;

  User({
    this.email,
    this.name,
    this.lastName,
    this.password,
    this.visualDegree,
    this.birthday,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] as String?,
      name: json['name'] as String?,
      lastName: json['lastName'] as String?,
      password: json['password'] as String?,
      visualDegree: json['visualImpairment'] as String?,
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'lastName': lastName,
      'birthday': birthday?.toIso8601String(),
      'visualImpairment': visualDegree,
    };
  }
}
