import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginCredentials {
  String username = "";
  String password = "";

  LoginCredentials(this.username, this.password);
}

Future<void> saveLoginCredentials(String username, String password) async {
  final storage = FlutterSecureStorage();
  await storage.write(key: "username", value: username);
  await storage.write(key: "password", value: password);
}

Future<LoginCredentials> retrieveLoginCredentials() async {
  final storage = FlutterSecureStorage();
  final username = await storage.read(key: "username") ?? "";
  final password = await storage.read(key: "password") ?? "";
  return LoginCredentials(username, password);
}

Future<void> deleteLoginCredentials() async {
  final storage = FlutterSecureStorage();
  await storage.delete(key: "username");
  await storage.delete(key: "password");
}
