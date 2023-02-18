import 'package:flutter/cupertino.dart';
import 'package:health_tracker/ui/widgets/linear_progress_bar.dart';

class StoryBars extends StatelessWidget {
  List<double> percentWatched = [];

  StoryBars({
    required this.percentWatched,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
      child: Row(
        children: [
          Expanded(
            child: StaticLinearProgressBar(
              percentWatched: percentWatched[0],
            ),
          ),
          Expanded(
            child: StaticLinearProgressBar(
              percentWatched: percentWatched[1],
            ),
          ),
          Expanded(
            child: StaticLinearProgressBar(
              percentWatched: percentWatched[2],
            ),
          ),
        ],
      ),
    );
  }
}
