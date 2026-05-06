import "package:flutter_secure_storage/flutter_secure_storage.dart";

// singleton class for handling the storage of the user's jwt used to connect to the server
class JwtStorage {
  static const JwtStorage _instance = JwtStorage._privCon();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  const JwtStorage._privCon();

  factory JwtStorage() {
    return _instance;
  }

  Future<void> write(String token) async{
    await _storage.write(key: "jwt", value: token);
  }

  Future<String?> read() async{
    String? token = await _storage.read(key: "jwt");
    return token;
  }

  Future<void> delete() async{
    _storage.delete(key: "jwt");
  }

  Future<void> deleteAll() async{
    _storage.deleteAll();
  }
}