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
}

class Creature {
  final int id;
  final String name;
  final String photo;
  final String rarity;

  Creature({
    required this.id,
    required this.name,
    required this.photo,
    required this.rarity,
  });
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
}