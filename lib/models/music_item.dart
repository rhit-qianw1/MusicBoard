class MusicItem {
  final String name;
  final String artist;
  final String genre;
  final String imageUrl;
  final String description;
  final String creatorId;

  MusicItem({
    required this.name,
    required this.artist,
    required this.genre,
    required this.imageUrl,
    required this.description,
    required this.creatorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'artist': artist,
      'genre': genre,
      'imageUrl': imageUrl,
      'description': description,
      'creatorId': creatorId,
    };
  }

  static MusicItem fromMap(Map<String, dynamic> map) {
    return MusicItem(
      name: map['name'] ?? '',
      artist: map['artist'] ?? '',
      genre: map['genre'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      creatorId: map['creatorId'] ?? '',
    );
  }
}
