import 'package:flutter/material.dart';

import '../../../widgets/text_widget.dart';

class MainSudokuScreen extends StatelessWidget {
  const MainSudokuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextWidget(
        text: "Sudoku",
      ),
    );
  }
}
