import 'package:flutter/material.dart';
import 'package:game_template/screens/games/wire/logic/types.dart';
import 'package:game_template/screens/games/wire/logic/wire_logic.dart';
import 'package:game_template/screens/games/wire/logic/wire_tile.dart';
import 'package:game_template/screens/games/wire/wire_tile_paint.dart';
import 'package:game_template/widgets/text_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

Logger _logger = Logger("MainWireScreen");

class MainWireScreen extends StatefulWidget {
  late WireGame wireGame;
  MainWireScreen({super.key}) {
    wireGame = WireGame(
      tileImport: [
        WireTile(
          polygonTileForm: TessellateType.triangle,
          importPolarCords: [2, 0, -1],
        ),
        WireTile(
          polygonTileForm: TessellateType.square,
          importPolarCords: [4, 2],
        ),
        WireTile(
          polygonTileForm: TessellateType.hexagon,
          importPolarCords: [2, 0, -2],
        ),
      ]
    );
  }

  @override
  State<MainWireScreen> createState() => _MainWireScreenState();
}

class _MainWireScreenState extends State<MainWireScreen> {

  List<Offset> cs=[];
  List<List<Offset>> ps=[];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.red,
                    width: 2
                ),
              ),
              child: CustomPaint(
                child: SizedBox(
                  width: double.infinity,
                  height: 500,
                ),
                painter: WireTilePaint(cs, ps),
              ),
            ),
            TextWidget(
              text: "Wire",
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cs = [];
                  ps = [];
                  for(WireTile wt in widget.wireGame.tiles){
                    Offset center = wt.tileSize.getTileLocationCenter(wt.polarTile);
                    List<Offset> points = wt.tileSize.getTileVertices(wt.polarTile);
                    _logger.info("Offset(${center.dx}, ${center.dy})");
                    _logger.fine("Points(${points.map((e) => "Of(${e.dx.toStringAsFixed(5)}, ${e.dy.toStringAsFixed(5)})").join(", ")})");
                    cs.add(center);
                    ps.add(points);
                  }
                });
              },
              child: TextWidget(
                text: "Play",
              )
            )
          ],
        ),
      ),
    );
  }
}
