import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:moviematch/models/movie.dart';

// Sovelluksen tila, joka hallitsee elokuvia, suosikkeja ja muita tietoja.
class MyAppState extends ChangeNotifier {
  List<Movie> movies = []; // Lista elokuvista.
  var current = WordPair.random(); // Nykyinen satunnainen sanapari.
  String currentTitle = "Loading..."; // Nykyinen otsikko (esim. elokuvan nimi).
  late final String readAccessKey; // TMDB:n lukuoikeusavain.

  // Konstruktori, joka alustaa sovelluksen tilan.
  MyAppState() {
    // Haetaan TMDB:n lukuoikeusavain ympäristömuuttujista.
    String? key = dotenv.env["TMDB_READ_ACCESS_KEY"];

    if (key == null) {
      // Jos avainta ei löydy, heitetään poikkeus.
      throw Exception(
        "No read access key found in app_state init, does .env exist?",
      );

      String? matchData; // Yhteensopivuusdata.

      // Ilmoittaa, kun yhteensopivuus löytyy.
      void notifyMatch(String data) {
        matchData = data;
        notifyListeners(); // Päivittää kuuntelijat.
      }

      // Tyhjentää yhteensopivuusilmoituksen.
      void clearNotification() {
        matchData = null;
        notifyListeners(); // Päivittää kuuntelijat.
      }
    }

    readAccessKey = key; // Tallennetaan lukuoikeusavain.
  }

  // Hakee seuraavan satunnaisen sanaparin.
  void getNext() {
    current = WordPair.random(); // Päivitetään satunnainen sanapari.
    notifyListeners(); // Päivitetään kuuntelijat.
  }

  var favorites = <WordPair>[]; // Lista suosikeista.

  // Lisää tai poistaa nykyisen sanaparin suosikeista.
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current); // Poistetaan suosikeista, jos se on jo siellä.
    } else {
      favorites.add(current); // Lisätään suosikkeihin, jos sitä ei ole.
    }
    notifyListeners(); // Päivitetään kuuntelijat.
  }

  // Hakee suositut elokuvat TMDB:n API:sta.
  Future<List<Movie>> getPopularMovies() async {
    final Uri url = Uri.parse("https://api.themoviedb.org/3/movie/popular"); // API:n URL.

    // Lähetetään HTTP GET -pyyntö API:lle.
    var response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $readAccessKey", // Lukuoikeusavain.
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    // Puretaan API:n vastaus JSON-muotoon.
    var data = jsonDecode(response.body) as Map<String, dynamic>;

    List moviesJson = data["results"]; // Haetaan elokuvat JSON:sta.

    // Muutetaan JSON-data Movie-olioiksi ja palautetaan lista.
    return moviesJson.map((movieJson) => Movie.fromJson(movieJson)).toList();
  }
}