import 'package:flutter/material.dart';
import 'package:game_template/services/extensions/string_extensions.dart';

import '../../services/get_it_helper.dart';
import '../../widgets/text_widget.dart';

class GameSelector extends StatefulWidget {
  const GameSelector({super.key});

  @override
  State<GameSelector> createState() => _GameSelectorState();
}

class _GameSelectorState extends State<GameSelector> {

  Map<String, bool> games_loading = {
    "murlan": false,
    "poker": false,
    "sudoku": false,
  };

  Future openGame(String actualGame) async{
    setState(() {
      games_loading[actualGame] = true;
    });
    global.screenController.value = "/play/$actualGame";
    setState(() {
      games_loading[actualGame] = false;
    });
    return;
  }

  @override
  void setState(VoidCallback fn) {
    if(mounted) super.setState(fn);
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: TextWidget(
            text: "Play Games",
            textSize: DefaultTextSizes.extra.value,
          ),
        ),
        Expanded(
          child: Center(
            child: GridView(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              children: games_loading.entries.map((e){
                return InkWell(
                  onTap: () async{
                    if(!e.value){
                      await openGame(e.key);
                    }
                  },
                  child: Container(
                    height: 50,
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          if(!e.value){
                            return TextWidget(
                              text: "Play ${e.key.toCapitalized()}",
                            );
                          }else{
                            return CircularProgressIndicator(
                              color: global.color.greenMain,
                            );
                          }
                        }
                      ),
                    )
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
