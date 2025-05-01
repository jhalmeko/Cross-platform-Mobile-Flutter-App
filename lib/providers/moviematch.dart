import 'dart:async';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

import '../generated/moviematch.pbgrpc.dart';

// MovieMatchProvider hallitsee gRPC-yhteyttä ja viestien lähettämistä/palauttamista.
class MovieMatchProvider extends ChangeNotifier {
  late final ClientChannel _channel; // gRPC-kanava palvelimeen.
  late final MovieMatchClient _stub; // gRPC-palvelun käyttäjä.
  late final StreamController<StateMessage> _send; // Lähetettävien viestien hallinta.
  late final ResponseStream<StateMessage> _receive; // Vastaanotettavien viestien hallinta.
  String userName = WordPair.random().join(); // Käyttäjän satunnainen nimi.

  // Konstruktori, joka alustaa gRPC-yhteyden ja kuuntelun.
  MovieMatchProvider() {
    var isAndroid = Platform.isAndroid; // Tarkistetaan, onko alusta Android.

    // Määritetään palvelimen osoite alustasta riippuen.
    String baseUrl = isAndroid ? '10.0.2.2' : "localhost";

    // Alustetaan gRPC-kanava.
    _channel = ClientChannel(
      baseUrl, // Android-emulaattorin proxy localhostille.
      port: 50051, // Palvelimen portti.
      options: ChannelOptions(credentials: ChannelCredentials.insecure()), // Salaamaton yhteys.
    );

    // Alustetaan gRPC-palvelun käyttäjä.
    _stub = MovieMatchClient(_channel);

    // Alustetaan viestien lähetys- ja vastaanottovirrat.
    _send = StreamController<StateMessage>();
    _receive = _stub.streamState(_send.stream);

    // Kuunnellaan palvelimen lähettämiä viestejä.
    _receive.listen((msg) {
      print("message: ${msg.user}: ${msg.data}"); // Tulostetaan saapuva viesti.
    });
  }

  // Päivittää käyttäjän nimen ja ilmoittaa kuuntelijoille.
  void setUserName(String name) {
    userName = name;
    notifyListeners(); // Ilmoittaa, että tila on muuttunut.
  }

  // Lähettää viestin palvelimelle.
  void send(movieName) {
    var msg = StateMessage()
      ..data = movieName // Viestin sisältö (elokuvan nimi).
      ..user = userName; // Viestin lähettäjä (käyttäjän nimi).

    _send.add(msg); // Lisätään viesti lähetysvirtaan.

    // Kuuntelee palvelimen tilavirtaa ja reagoi yhteensopivuuksiin.
    void _listenToStateStream() {
      _stateStream.listen((stateMessage) {
        // Ilmoittaa sovelluksen globaalille tilalle, kun yhteensopivuus löytyy.
        if (stateMessage.data.isNotEmpty) {
          // Haetaan sovelluksen globaali tila.
          final appState = Provider.of<MyAppState>(navigatorKey.currentContext!, listen: false);
          appState.notifyMatch(stateMessage.data); // Ilmoitetaan yhteensopivuudesta.
        }
      });
    }
  }
}