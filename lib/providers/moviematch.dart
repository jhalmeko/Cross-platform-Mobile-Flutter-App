// Code is here: https://pastebin.com/x5sChMiL

import 'dart:async';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

import '../generated/moviematch.pbgrpc.dart';

class MovieMatchProvider extends ChangeNotifier {
  late final ClientChannel _channel;
  late final MovieMatchClient _stub;
  late final StreamController<StateMessage> _send;
  late final ResponseStream<StateMessage> _receive;
  String userName = WordPair.random().join();

  MovieMatchProvider() {
    var isAndroid = Platform.isAndroid;

    String baseUrl = isAndroid ? '10.0.2.2' : "localhost";

    _channel = ClientChannel(
      baseUrl, // This is android emulator's proxy to localhost on host machine
      port: 50051,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    _stub = MovieMatchClient(_channel);
    _send = StreamController<StateMessage>();
    _receive = _stub.streamState(_send.stream);

    _receive.listen((msg) {
      print("message: ${msg.user}: ${msg.data}");
    });
  }

  void setUserName(String name) {
    userName = name;
    notifyListeners();
  }

  void send(movieName) {
    var msg =
        StateMessage()
          ..data = movieName
          ..user = userName;

    _send.add(msg);
  }
}
