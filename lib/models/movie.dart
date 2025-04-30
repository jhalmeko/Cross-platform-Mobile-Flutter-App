class Movie {
  final int id;
  final String originalTitle;
  final String posterPath;
  final DateTime releaseDate;

  Movie({
    required this.id,
    required this.originalTitle,
    required this.posterPath,
    required this.releaseDate,
  });

  Movie.fromJson(Map<String, dynamic> json)
    : id = json["id"],
      originalTitle = json["original_title"],
      posterPath = json["poster_path"],
      releaseDate = DateTime.parse(json["release_date"]);
}




  /* 
  {
  "page": 1,
  "results": [
    {
      "adult": false,
      "backdrop_path": "/9nhjGaFLKtddDPtPaX5EmKqsWdH.jpg",
      "genre_ids": [
        10749,
        878,
        53
      ],
      "id": 950396,
      "original_language": "en",
      "original_title": "The Gorge",
      "overview": "Two highly trained operatives grow close from a distance after being sent to guard opposite sides of a mysterious gorge. When an evil below emerges, they must work together to survive what lies within.",
      "popularity": 2462.807,
      "poster_path": "/7iMBZzVZtG0oBug4TfqDb9ZxAOa.jpg",
      "release_date": "2025-02-13",
      "title": "The Gorge",
      "video": false,
      "vote_average": 7.83,
      "vote_count": 1365
    },
   */