import 'dart:convert';
import 'dart:typed_data';

class User {
  final int id;
  final String username;
  final String email;
  final String pswHash;
  final String salt;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.pswHash,
    required this.salt,
    required this.token,
  });

  Uint8List toBytes() {
    final data = {
      'id': id,
      'username': username,
      'email': email,
      'psw_hash': pswHash,
      'salt': salt,
      'token': token,
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(data)));
  }

  static User fromBytes(Uint8List bytes) {
    final json = jsonDecode(utf8.decode(bytes));
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      pswHash: json['psw_hash'],
      salt: json['salt'],
      token: json['token'],
    );
  }
}

class Creature {
  final int id;
  final String name;
  final String photo;
  final int rarity;

  Creature({
    required this.id,
    required this.name,
    required this.photo,
    required this.rarity,
  });

  Uint8List toBytes() {
    final data = {
      'id': id,
      'name': name,
      'photo': photo,
      'rarity': rarity,
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(data)));
  }

  static Creature fromBytes(Uint8List bytes) {
    final json = jsonDecode(utf8.decode(bytes));
    return Creature(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      rarity: json['rarity'],
    );
  }
}

class CreaturesInTheWild {
  final int type;
  final int resiliencePoints;
  final String geohash;
  final double lat;
  final double lon;

  CreaturesInTheWild({
    required this.type,
    required this.resiliencePoints,
    required this.geohash,
    required this.lat,
    required this.lon,
  });

  Uint8List toBytes() {
    final data = {
      'type': type,
      'resilience_points': resiliencePoints,
      'geohash': geohash,
      'lat': lat,
      'lon': lon,
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(data)));
  }

  static CreaturesInTheWild fromBytes(Uint8List bytes) {
    final json = jsonDecode(utf8.decode(bytes));
    return CreaturesInTheWild(
      type: json['type'],
      resiliencePoints: json['resilience_points'],
      geohash: json['geohash'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}

class CreaturesCaught {
  final int id;
  final int type;
  final int resiliencePoints;
  final int userId;

  CreaturesCaught({
    required this.id,
    required this.type,
    required this.resiliencePoints,
    required this.userId,
  });

  Uint8List toBytes() {
    final data = {
      'id': id,
      'type': type,
      'resilience_points': resiliencePoints,
      'user_id': userId,
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(data)));
  }

  static CreaturesCaught fromBytes(Uint8List bytes) {
    final json = jsonDecode(utf8.decode(bytes));
    return CreaturesCaught(
      id: json['id'],
      type: json['type'],
      resiliencePoints: json['resilience_points'],
      userId: json['user_id'],
    );
  }
}