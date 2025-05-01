import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:moviematch/providers/app_state.dart';
import 'package:moviematch/providers/moviematch.dart';
import 'package:moviematch/views/generator_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

// Sovelluksen pääfunktio, joka alustaa ympäristömuuttujat ja käynnistää sovelluksen.
Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Ladataan ympäristömuuttujat .env-tiedostosta.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppState()), // Sovelluksen tila.
        ChangeNotifierProvider(create: (_) => MovieMatchProvider()), // MovieMatch-tila.
      ],
      child: MyApp(), // Käynnistetään sovellus.
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // Navigaattorin avain.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      navigatorKey: navigatorKey, // Navigaattorin avain.
      title: 'MovieMatch', // Sovelluksen nimi.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 99, 0, 156), // Sovelluksen teemaväri.
        ),
      ),
      routerConfig: GoRouter(
        routes: [
          // Reitit eri sivuille.
          GoRoute(
            path: "/",
            builder: (context, state) {
              return MyHomePage(GeneratorPage()); // Etusivu.
            },
          ),
          GoRoute(
            path: "/favorites",
            builder: (context, state) {
              return MyHomePage(FavoritesPage()); // Suosikkisivu.
            },
          ),
          GoRoute(
            path: "/movie-match",
            builder: (context, state) {
              return MyHomePage(MovieMatchClient()); // MovieMatch-sivu.
            },
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Widget? child; // Näytettävä lapsi-widget.

  const MyHomePage(this.child);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyAppState>(
      builder: (context, appState, child) {
        // Näytetään modaalidialogi, jos yhteensopivuus löytyy.
        if (appState.matchData != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Match Found!'), // Otsikko.
                  content: Text('You have a match: ${appState.matchData}'), // Sisältö.
                  actions: [
                    TextButton(
                      onPressed: () {
                        appState.clearNotification(); // Tyhjennetään ilmoitus.
                        Navigator.of(context).pop(); // Suljetaan dialogi.
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          });
        }

        // Android-käyttöliittymä.
        if (Platform.isAndroid) {
          return Scaffold(
            body: widget.child, // Näytettävä sisältö.
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  label: 'Home',
                  icon: GestureDetector(
                    child: Icon(Icons.home),
                    onTap: () => context.go("/"), // Navigointi etusivulle.
                  ),
                ),
                BottomNavigationBarItem(
                  label: "Favorites",
                  icon: GestureDetector(
                    child: Icon(Icons.favorite),
                    onTap: () => context.go("/favorites"), // Navigointi suosikkisivulle.
                  ),
                ),
              ],
            ),
          );
        }

        // iOS-käyttöliittymä.
        if (Platform.isIOS) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar.large(largeTitle: Text("Test")), // iOS-tyylinen navigaatiopalkki.
            child: Text("test"), // Näytettävä sisältö.
          );
        }

        return Container(); // Tyhjä näkymä, jos alusta ei ole Android tai iOS.
      },
    );
  }
}

class CustomNavigationRail extends StatelessWidget {
  const CustomNavigationRail({super.key, required this.widget});

  final MyHomePage widget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600, // Laajennettu tila, jos leveys on suuri.
                destinations: [
                  NavigationRailDestination(
                    icon: GestureDetector(
                      child: Icon(Icons.home),
                      onTap: () => context.go("/"), // Navigointi etusivulle.
                    ),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: GestureDetector(
                      child: Icon(Icons.favorite),
                      onTap: () => context.go("/favorites"), // Navigointi suosikkisivulle.
                    ),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: null, // Valittua indeksiä ei ole määritelty.
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer, // Taustaväri.
                child: widget.child, // Näytettävä sisältö.
              ),
            ),
          ],
        );
      },
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair; // Näytettävä sanapari.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary, // Tekstin väri.
    );

    return Card(
      color: theme.colorScheme.primary, // Kortin väri.
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, // Sanapari pienillä kirjaimilla.
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}", // Semanttinen tunniste.
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Haetaan sovelluksen tila.

    if (appState.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.')); // Näytetään viesti, jos suosikkeja ei ole.
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have '
            '${appState.favorites.length} favorites:', // Suosikkien määrä.
          ),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite), // Suosikkikuvake.
            title: Text(pair.asLowerCase), // Suosikin nimi.
          ),
      ],
    );
  }
}