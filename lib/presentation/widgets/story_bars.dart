import 'package:flutter/cupertino.dart';
import 'charts/linear_progress_bar.dart';

class StoryBars extends StatelessWidget {
  List<double> percentWatched = [];
  int count = 0;

  StoryBars({
    required this.count,
    required this.percentWatched,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 80, left: 10, right: 10),
      child: Row(
        children: List.generate(count, (index) => Expanded(
          child: StaticLinearProgressBar(
            percentWatched: percentWatched[index],
          ),
        ),
        )
      ),
    );
  }
}
