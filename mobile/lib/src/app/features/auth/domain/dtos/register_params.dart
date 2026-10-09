class RegisterParams {
  String name;
  String email;
  String password;
  String passwordConfirmation;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  void setName(String value) {
    name = value;
  }

  void setEmail(String value) {
    email = value;
  }

  void setPassword(String value) {
    password = value;
  }

  void setPasswordConfirmation(String value) {
    passwordConfirmation = value;
  }

  static RegisterParams empty() {
    return RegisterParams(
        name: '', email: '', password: '', passwordConfirmation: '');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterParams &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.passwordConfirmation == passwordConfirmation;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        password.hashCode ^
        passwordConfirmation.hashCode;
  }

  @override
  String toString() {
    return 'RegisterParams(name: $name, email: $email, password: $password, passwordConfirmation: $passwordConfirmation)';
  }
}
