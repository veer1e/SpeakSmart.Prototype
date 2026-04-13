import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  static const _usersKey      = 'ss_users';
  static const _sessionKey    = 'ss_current_user';

  SharedPreferences? _prefs;



  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  AuthUser? get currentUser {
    final raw = _prefs?.getString(_sessionKey);
    if (raw == null) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn => currentUser != null;


  /// Returns [AuthResult.success] or a descriptive error.
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String username,
    required String password,
  }) async {
    _assertInit();

    if (username.trim().isEmpty) return AuthResult.error('Username cannot be empty.');
    if (password.length < 6)    return AuthResult.error('Password must be at least 6 characters.');

    final users = _loadUsers();


    if (users.containsKey(username.toLowerCase())) {
      return AuthResult.error('Username "${username}" is already taken.');
    }


    users[username.toLowerCase()] = {
      'username':  username,
      'firstName': firstName,
      'lastName':  lastName,
      'password':  _encode(password),
    };

    await _saveUsers(users);
    return AuthResult.success;
  }


  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    _assertInit();

    if (username.trim().isEmpty || password.isEmpty) {
      return AuthResult.error('Please fill in all fields.');
    }

    final users = _loadUsers();
    final record = users[username.toLowerCase()];

    if (record == null) {
      return AuthResult.error('No account found for "$username".');
    }

    if (_encode(password) != (record['password'] as String)) {
      return AuthResult.error('Incorrect password.');
    }


    final user = AuthUser(
      username:  record['username']  as String,
      firstName: record['firstName'] as String,
      lastName:  record['lastName']  as String,
    );
    await _prefs!.setString(_sessionKey, jsonEncode(user.toJson()));

    return AuthResult.success;
  }

 

  Future<void> logout() async {
    await _prefs?.remove(_sessionKey);
  }



  void _assertInit() {
    assert(_prefs != null, 'AuthService.init() must be called before use.');
  }

  Map<String, Map<String, dynamic>> _loadUsers() {
    final raw = _prefs?.getString(_usersKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as Map<String, dynamic>));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveUsers(Map<String, Map<String, dynamic>> users) async {
    await _prefs!.setString(_usersKey, jsonEncode(users));
  }

  String _encode(String password) {
    final reversed = password.split('').reversed.join();
    return base64Encode(utf8.encode(reversed));
  }
}

// ─── Auth result ───────────────────────────────────────────────────────────────

class AuthResult {
  final bool   isSuccess;
  final String? errorMessage;

  const AuthResult._({required this.isSuccess, this.errorMessage});

  static const success = AuthResult._(isSuccess: true);

  factory AuthResult.error(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}

// ─── Auth user model ───────────────────────────────────────────────────────────

class AuthUser {
  final String username;
  final String firstName;
  final String lastName;

  const AuthUser({
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  String get fullName => '$firstName $lastName';

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        username:  json['username']  as String,
        firstName: json['firstName'] as String,
        lastName:  json['lastName']  as String,
      );

  Map<String, dynamic> toJson() => {
        'username':  username,
        'firstName': firstName,
        'lastName':  lastName,
      };
}