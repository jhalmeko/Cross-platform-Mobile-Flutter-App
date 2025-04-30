import 'package:flutter/material.dart';
import 'package:moviematch/main.dart';
import 'package:moviematch/models/movie.dart';
import 'package:moviematch/providers/app_state.dart';
import 'package:moviematch/providers/moviematch.dart';
import 'package:moviematch/widgets/swipeable_cards.dart';
import 'package:provider/provider.dart';

class GeneratorPage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var movieState = context.watch<MovieMatchProvider>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<List<Movie>>(
            future: appState.getPopularMovies(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError &&
                  snapshot.hasData) {
                return SwipeableCards(snapshot.data!);
              }

              return Text("No movies at this time :(");
            },
          ),
          Text("${movieState.userName}"),
          TextFormField(controller: controller),
          TextButton(
            onPressed: () {
              print("${controller.text}");

              movieState.setUserName(controller.text);
            },
            child: Text("save username"),
          ),
        ],
      ),
    );
  }
}
