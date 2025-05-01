import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'generated/moviematch.pbgrpc.dart';

// MovieMatchClient-luokka on Flutter-sovelluksen pääwidget.
class MovieMatchClient extends StatefulWidget {
  @override
  _MovieMatchClientState createState() => _MovieMatchClientState();
}

// _MovieMatchClientState sisältää sovelluksen tilan ja toiminnallisuuden.
class _MovieMatchClientState extends State<MovieMatchClient> {
  // gRPC-kanava, joka yhdistää palvelimeen.
  final channel = ClientChannel(
    'localhost', // Palvelimen osoite (localhost tässä tapauksessa).
    port: 50051, // Palvelimen portti.
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()), // Yhteys ilman salausta.
  );
  late MovieMatchServiceClient stub; // gRPC-palvelun Käyttäjä.
  late Stream<StateMessage> responseStream; // Palvelimen lähettämä viestivirta.

  @override
  void initState() {
    super.initState();
    // Alustetaan gRPC-palvelun Käyttäjä.
    stub = MovieMatchServiceClient(channel);

    // Aloitetaan palvelimen viestivirran kuuntelu.
    responseStream = stub.streamState(
      Stream.fromIterable([
        StateMessage()..user = 'user1' // Lähetetään käyttäjän tunniste palvelimelle.
      ]),
    );

    // Kuunnellaan palvelimen lähettämiä viestejä.
    responseStream.listen((message) {
      if (message.user == 'server') {
        // Jos viestin lähettäjä on palvelin, näytetään ilmoitus yhteensopivuudesta.
        _showMatchNotification(message.data);
      }
    });
  }

  // Näyttää modaalin, kun yhteensopivuus löytyy.
  void _showMatchNotification(String matchData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Match Found!'), // Modaalin otsikko.
          content: Text('You have a match on: $matchData'), // Modaalin sisältö.
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Sulkee modaalin.
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Suljetaan gRPC-kanava, kun widget tuhotaan.
    channel.shutdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rakentaa käyttöliittymän.
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Match Client'), // Sovelluksen otsikko.
      ),
      body: Center(
        child: Text('Listening for matches...'), // Näyttää viestin, kun odotetaan yhteensopivuuksia.
      ),
    );
  }
}