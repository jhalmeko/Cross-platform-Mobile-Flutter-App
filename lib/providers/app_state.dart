import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:moviematch/models/movie.dart';

class MyAppState extends ChangeNotifier {
  List<Movie> movies = [];

  var current = WordPair.random();
  String currentTitle = "Loading...";
  late final String readAccessKey;

  MyAppState() {
    String? key = dotenv.env["TMDB_READ_ACCESS_KEY"];

    if (key == null) {
      throw Exception(
        "No read access key found in app_state init, does .env exist?",
      );
    }

    readAccessKey = key;
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  // Add import to top of the file: import 'package:http/http.dart' as http;
  Future<List<Movie>> getPopularMovies() async {
    final Uri url = Uri.parse("https://api.themoviedb.org/3/movie/popular");

    var response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $readAccessKey",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    var data = jsonDecode(response.body) as Map<String, dynamic>;

    List moviesJson = data["results"];

    return moviesJson.map((movieJson) => Movie.fromJson(movieJson)).toList();

    /* List<String> titles =
        movies.map((movie) {
          return movie["original_title"] as String;
        }).toList(); */

    /* currentTitle = titles.first; */
    /* notifyListeners(); */
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
}
