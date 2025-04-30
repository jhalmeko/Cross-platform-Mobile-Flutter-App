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

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppState()),
        ChangeNotifierProvider(create: (_) => MovieMatchProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MovieMatch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 99, 0, 156),
        ),
      ),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: "/",
            builder: (context, state) {
              return MyHomePage(GeneratorPage());
            },
          ),
          GoRoute(
            path: "/favorites",
            builder: (context, state) {
              return MyHomePage(FavoritesPage());
            },
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // class _MyHomePageState extends State<MyHomePage>... has now widget.child
  final Widget? child;

  const MyHomePage(this.child);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              label: 'Home',
              icon: GestureDetector(
                child: Icon(Icons.home),
                onTap: () => context.go("/"),
              ),
            ),
            BottomNavigationBarItem(
              label: "Favorites",
              icon: GestureDetector(
                child: Icon(Icons.favorite),
                onTap: () => context.go("/favorites"),
              ),
            ),
          ],
        ),
      );
    }

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar.large(largeTitle: Text("Test")),
        child: Text("test"),
      );
    }

    return Container();
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
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: GestureDetector(
                      child: Icon(Icons.home),
                      onTap: () => context.go("/"),
                    ),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: GestureDetector(
                      child: Icon(Icons.favorite),
                      onTap: () => context.go("/favorites"),
                    ),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: null,
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: widget.child,
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

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have '
            '${appState.favorites.length} favorites:',
          ),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
