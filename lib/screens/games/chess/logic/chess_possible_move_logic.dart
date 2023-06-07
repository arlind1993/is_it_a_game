import 'package:game_template/screens/games/chess/models/chess_movement.dart';
import 'package:logging/logging.dart';

import '../models/chess_constants.dart';
import '../models/chess_location.dart';
import '../models/chess_board_state.dart';
import '../models/chess_piece.dart';
import '../models/chess_possible_move_group.dart';
///HIGHKEY A LOT TO DO
class ChessPossibleMovesAlgorithms{
  static ChessPossibleMovesAlgorithms _possibleMovesAlgorithms = ChessPossibleMovesAlgorithms._();
  factory ChessPossibleMovesAlgorithms(){
    return _possibleMovesAlgorithms;
  }
  ChessPossibleMovesAlgorithms._();

  Logger _logger = Logger("Possible Moves");


  bool isInCheck(bool isWhite){

    return false;
  }

  List<PossibleMoveGroup> getPossibleMovesForPiece(ChessPiece chessPiece, ChessBoardState gameState){

    if(gameState.isWhiteTurn && chessPiece.isWhite){//movesForWhite
      _logger.fine("Moves only for white");
      switch(chessPiece.pieceType){
        case ChessPieceType.Pawn:
          List<PossibleMoveGroup> pawnLocations= [];
          if(gameState.lastEnPassantMove!=null){//en passant move
            ChessLocation actualLocEnPassantPiece = ChessLocation(
                rank : gameState.lastEnPassantMove!.rank - 1,
                file : gameState.lastEnPassantMove!.file
            );
            ChessPiece? lastEnPassantMovedPiece = gameState.aliveGamePiecesMapped[actualLocEnPassantPiece];
            _logger.warning("En passant: $lastEnPassantMovedPiece");
            if(lastEnPassantMovedPiece !=null && !lastEnPassantMovedPiece.isWhite && chessPiece.location.rank == actualLocEnPassantPiece.rank
                && (chessPiece.location.file - actualLocEnPassantPiece.file).abs() == 1
            ){
              pawnLocations.add(
                  PossibleMoveGroup(
                    pieceMovement: ChessMovement(
                      from: chessPiece, 
                      to: ChessPiece.clone(chessPiece)..location = ChessLocation(
                        rank: chessPiece.location.rank + 1,
                        file: gameState.lastEnPassantMove!.file
                      )
                    ),
                    eatenPiece: lastEnPassantMovedPiece,
                    enPassant: true
                  )
              );//enPassantMove if possible added
            }
          }

          pawnLocations.addAll([
            ...gameState.gamePiecesMapped.values.where((element){
              return !element.eaten && !element.isWhite
                  && (chessPiece.location.file - element.location.file).abs() == 1
                  && chessPiece.location.rank + 1 == element.location.rank;
            }).map((e) => PossibleMoveGroup(
              pieceMovement: ChessMovement(
                from: chessPiece,
                to: ChessPiece.clone(chessPiece)..location = e.location
              ),
              eatenPiece: e
            )).toList()
          ]);//the two adjacent pawns if there

          //add forwardMove if not blocked;
          bool firstMovePossible = !gameState.gamePiecesMapped.values.any((element) {
            return !element.eaten && chessPiece.location.file == element.location.file
                && chessPiece.location.rank + 1 == element.location.rank;
          });
          bool secondMovePossible = chessPiece.location.rank == 2 &&
              !gameState.gamePiecesMapped.values.any((element) {
                return !element.eaten && chessPiece.location.file == element.location.file
                    && chessPiece.location.rank + 2 == element.location.rank;
              });

          if(firstMovePossible){
            pawnLocations.add(PossibleMoveGroup(
              pieceMovement: ChessMovement(
                from: chessPiece,
                to: ChessPiece.clone(chessPiece)..location = ChessLocation(
                  rank: chessPiece.location.rank + 1, 
                  file: chessPiece.location.file
                )
              )
            ));
            if(secondMovePossible){
              pawnLocations.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                  from: chessPiece,
                  to: ChessPiece.clone(chessPiece)..location = ChessLocation(
                    rank: chessPiece.location.rank + 2, 
                    file: chessPiece.location.file
                  )
                )
              ));
            }
          }

          return pawnLocations.where((element) => element.pieceMovement.to.location.inside).toList();
        case ChessPieceType.Knight:
          List<ChessLocation> knightJumps = [
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 2),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file - 2),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 2),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file - 2),
            ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file - 1),
          ];
          List<PossibleMoveGroup> knightLocations = [];
          for(ChessLocation location in knightJumps){
            ChessPiece? pieceInLocation = gameState.aliveGamePiecesMapped[location];
            if(pieceInLocation == null){
              knightLocations.add(PossibleMoveGroup(
                pieceMovement: ChessMovement(
                  from: chessPiece,
                  to: ChessPiece.clone(chessPiece)..location = location
                )
              ));
            }else{
              if(!pieceInLocation.isWhite){
                knightLocations.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location =location
                  ),eatenPiece: pieceInLocation
                ));
              }
            }
          }
          return knightLocations.where((element) => element.pieceMovement.to.location.inside).toList();
        case ChessPieceType.Bishop:
          List<PossibleMoveGroup> bishopMoves = [];
          int rankDx = 1;
          List<bool> stoppedTlTrBlBR = [
            false,
            false,
            false,
            false,
          ];
          while(stoppedTlTrBlBR.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTlTrBlBR}");
            if(!stoppedTlTrBlBR[0]){//Top Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[0]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ),
                ));
              }else{
                if(!pieceStopping.isWhite){
                  bishopMoves.add(PossibleMoveGroup(
                    pieceMovement: ChessMovement(
                        from: chessPiece,
                        to: ChessPiece.clone(chessPiece)..location = toThisLocation
                    ),eatenPiece: pieceStopping)
                  );
                }
                stoppedTlTrBlBR[0]=true;
              }
            }
            if(!stoppedTlTrBlBR[1]){//Top Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[1]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )
                ));
              }else{
                if(!pieceStopping.isWhite){
                  bishopMoves.add(PossibleMoveGroup(
                    pieceMovement: ChessMovement(
                      from: chessPiece,
                      to: ChessPiece.clone(chessPiece)..location = toThisLocation
                    ), eatenPiece: pieceStopping
                  ));
                }
                stoppedTlTrBlBR[1]=true;
              }
            }
            if(!stoppedTlTrBlBR[2]){//Bottom Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[2]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ) 
                ));
              }else{
                if(!pieceStopping.isWhite){
                  bishopMoves.add(PossibleMoveGroup(
                    pieceMovement: ChessMovement(
                        from: chessPiece,
                        to: ChessPiece.clone(chessPiece)..location = toThisLocation
                    ), eatenPiece: pieceStopping
                  ));
                }
                stoppedTlTrBlBR[2]=true;
              }
            }
            if(!stoppedTlTrBlBR[3]){//Bottom Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[3]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )
                ));
              }else{
                if(!pieceStopping.isWhite){
                  bishopMoves.add(PossibleMoveGroup(
                    pieceMovement: ChessMovement(
                        from: chessPiece,
                        to: ChessPiece.clone(chessPiece)..location = toThisLocation
                    ), eatenPiece: pieceStopping
                  ));
                }
                stoppedTlTrBlBR[3]=true;
              }
            }
            rankDx++;
          }
          return bishopMoves;
        case ChessPieceType.Rook:
          List<PossibleMoveGroup> rookMoves = [];
          int rankDx = 1;
          List<bool> stoppedTBLR = [
            false,
            false,
            false,
            false,
          ];
          while(stoppedTBLR.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTBLR}");
            if(!stoppedTBLR[0]){//Top
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLR[0]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )
                ));
              }else{
                if(!pieceStopping.isWhite){
                  rookMoves.add(PossibleMoveGroup(
                    pieceMovement: ChessMovement(
                      from: chessPiece,
                      to: ChessPiece.clone(chessPiece)..location = toThisLocation
                    ), eatenPiece: pieceStopping
                  ));
                }
                stoppedTBLR[0]=true;
              }
            }
            if(!stoppedTBLR[1]){//Bottom
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLR[1]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )
                ));
              }else{
                if(!pieceStopping.isWhite){
                  rookMoves.add(PossibleMoveGroup(
                    pieceMovement: ChessMovement(
                        from: chessPiece,
                        to: ChessPiece.clone(chessPiece)..location = toThisLocation
                    ), eatenPiece: pieceStopping
                  ));
                }
                stoppedTBLR[1]=true;
              }
            }
            if(!stoppedTBLR[2]){//Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLR[2]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )
                ));
              }else{
                if(!pieceStopping.isWhite){
                  rookMoves.add(PossibleMoveGroup(
                    pieceMovement: ChessMovement(
                      from: chessPiece,
                      to: ChessPiece.clone(chessPiece)..location = toThisLocation
                    ), eatenPiece: pieceStopping
                  ));
                }
                stoppedTBLR[2]=true;
              }
            }
            if(!stoppedTBLR[3]){//Right
              ChessLocation toThisLocation = ChessLocation(
                rank: chessPiece.location.rank,
                file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLR[3]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )
                ));
              }else{
                if(!pieceStopping.isWhite){
                  rookMoves.add(PossibleMoveGroup(
                    pieceMovement: ChessMovement(
                      from: chessPiece,
                      to: ChessPiece.clone(chessPiece)..location = toThisLocation
                    ), eatenPiece: pieceStopping
                  ));
                }
                stoppedTBLR[3]=true;
              }
            }
            rankDx++;
          }
          return rookMoves;
        case ChessPieceType.Queen:
          List<PossibleMoveGroup> queenMoves = [];
          int rankDx = 1;
          List<bool> stoppedTBLRQEZC = [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          while(stoppedTBLRQEZC.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTBLRQEZC}");
            if(!stoppedTBLRQEZC[0]){//Top
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[0]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[0]=true;
              }
            }
            if(!stoppedTBLRQEZC[1]){//Bottom
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[1]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[1]=true;
              }
            }
            if(!stoppedTBLRQEZC[2]){//Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[2]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[2]=true;
              }
            }
            if(!stoppedTBLRQEZC[3]){//Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[3]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[3]=true;
              }
            }
            if(!stoppedTBLRQEZC[4]){//Top Left Q
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[4]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[4]=true;
              }
            }
            if(!stoppedTBLRQEZC[5]){//Top Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[5]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[5]=true;
              }
            }
            if(!stoppedTBLRQEZC[6]){//Bottom Left Z
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[6]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[6]=true;
              }
            }
            if(!stoppedTBLRQEZC[7]){//Bottom Right C
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[7]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(!pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[7]=true;
              }
            }
            rankDx++;
          }
          return queenMoves;
        case ChessPieceType.King:
          List<ChessLocation> kingJumps = [
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 0),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank + 0, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank + 0, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 0),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 1),
          ];
          List<PossibleMoveGroup> kingLocations = [];
          for(ChessLocation location in kingJumps){
            ChessPiece? pieceInLocation = gameState.aliveGamePiecesMapped[location];
            if(pieceInLocation == null){
              kingLocations.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = location
                  )));
            }else{
              if(!pieceInLocation.isWhite){
                kingLocations.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = location
                  ), eatenPiece: pieceInLocation));
              }
            }
          }

          if(gameState.whiteQueenSide){
            List<PossibleMoveGroup> queenSide = [];
            bool blocked = false;
            bool touchdown = false;
            int dx = 2;
            while(!blocked){
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file - dx
              );
              if(!toThisLocation.inside){
                blocked = true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenSide.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location
                  ), queenSide: true));
              }else{
                if(pieceStopping.isWhite && pieceStopping.pieceType == ChessPieceType.Rook){
                  queenSide.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location
                  ), queenSide: true));
                  touchdown = true;
                }
                blocked = true;
              }
              dx++;
            }
            if(touchdown){
              kingLocations.addAll(queenSide);
            }
          }
          if(gameState.whiteKingSide){
            List<PossibleMoveGroup> kingSide = [];
            bool blocked = false;
            bool touchdown = false;
            int dx = 2;
            while(!blocked){
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file + dx
              );
              if(!toThisLocation.inside){
                blocked = true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                kingSide.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)
                  ), kingSide: true));
              }else{
                if(pieceStopping.isWhite && pieceStopping.pieceType == ChessPieceType.Rook){
                  kingSide.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)
                  ), kingSide: true));
                  touchdown = true;
                }
                blocked = true;
              }
              dx++;
            }
            if(touchdown){
              kingLocations.addAll(kingSide);
            }
          }


          return kingLocations.where((element) => element.pieceMovement.to.location.inside).toList();
      }
    }else if(!gameState.isWhiteTurn && !chessPiece.isWhite){//Moves for black
      _logger.fine("Moves only for black");
      switch(chessPiece.pieceType){
        case ChessPieceType.Pawn:
          List<PossibleMoveGroup> pawnLocations= [];
          if(gameState.lastEnPassantMove!=null){//en passant move
            ChessLocation actualLocEnPassantPiece = ChessLocation(
                rank : gameState.lastEnPassantMove!.rank + 1,
                file : gameState.lastEnPassantMove!.file
            );
            ChessPiece? lastEnPassantMovedPiece = gameState.aliveGamePiecesMapped[actualLocEnPassantPiece];
            _logger.warning("En passant: $lastEnPassantMovedPiece");
            if(lastEnPassantMovedPiece !=null && lastEnPassantMovedPiece.isWhite && chessPiece.location.rank == actualLocEnPassantPiece.rank
                && (chessPiece.location.file - actualLocEnPassantPiece.file).abs() == 1
            ){
              pawnLocations.add(
                  PossibleMoveGroup(
                    pieceMovement: ChessMovement(
                      from: chessPiece,
                      to: ChessPiece.clone(chessPiece)..location = ChessLocation(
                          rank: chessPiece.location.rank - 1,
                          file: gameState.lastEnPassantMove!.file
                      )
                    ),
                      eatenPiece: lastEnPassantMovedPiece,
                      enPassant: true
                  )
              );//enPassantMove if possible added
            }
          }

          pawnLocations.addAll([
            ...gameState.gamePiecesMapped.values.where((element){
              return !element.eaten && element.isWhite
                  && (chessPiece.location.file - element.location.file).abs() == 1
                  && chessPiece.location.rank - 1 == element.location.rank;
            }).map((e) => PossibleMoveGroup(
              pieceMovement: ChessMovement(
                from: chessPiece,
                to: ChessPiece.clone(chessPiece)..location = e.location
              ), eatenPiece: e
            )).toList()
          ]);//the two adjacent pawns if there

          //add forwardMove if not blocked;
          bool firstMovePossible = !gameState.gamePiecesMapped.values.any((element) {
            return !element.eaten && chessPiece.location.file == element.location.file
                && chessPiece.location.rank - 1 == element.location.rank;
          });
          bool secondMovePossible = chessPiece.location.rank == ChessConstants().CHESS_SIZE_SQUARE - 1 &&
              !gameState.gamePiecesMapped.values.any((element) {
                return !element.eaten && chessPiece.location.file == element.location.file
                    && chessPiece.location.rank - 2 == element.location.rank;
              });

          if(firstMovePossible){
            pawnLocations.add(PossibleMoveGroup(
                pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file)
                )));
            if(secondMovePossible){
              pawnLocations.add(PossibleMoveGroup(
                pieceMovement: ChessMovement(
                  from: chessPiece,
                  to: ChessPiece.clone(chessPiece)..location = ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file)
                )
              ));
            }
          }

          return pawnLocations.where((element) => element.pieceMovement.to.location.inside).toList();
        case ChessPieceType.Knight:
          List<ChessLocation> knightJumps = [
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 2),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file - 2),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 2),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file - 2),
            ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank + 2, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank - 2, file: chessPiece.location.file - 1),
          ];
          List<PossibleMoveGroup> knightLocations = [];
          for(ChessLocation location in knightJumps){
            ChessPiece? pieceInLocation = gameState.aliveGamePiecesMapped[location];
            if(pieceInLocation == null){
              knightLocations.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = location
                  )));
            }else{
              if(pieceInLocation.isWhite){
                knightLocations.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = location
                  ), eatenPiece: pieceInLocation));
              }
            }
          }
          return knightLocations.where((element) => element.pieceMovement.to.location.inside).toList();
        case ChessPieceType.Bishop:
          List<PossibleMoveGroup> bishopMoves = [];
          int rankDx = 1;
          List<bool> stoppedTlTrBlBR = [
            false,
            false,
            false,
            false,
          ];
          while(stoppedTlTrBlBR.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTlTrBlBR}");
            if(!stoppedTlTrBlBR[0]){//Top Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[0]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTlTrBlBR[0]=true;
              }
            }
            if(!stoppedTlTrBlBR[1]){//Top Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[1]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTlTrBlBR[1]=true;
              }
            }
            if(!stoppedTlTrBlBR[2]){//Bottom Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[2]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTlTrBlBR[2]=true;
              }
            }
            if(!stoppedTlTrBlBR[3]){//Bottom Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTlTrBlBR[3]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  bishopMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTlTrBlBR[3]=true;
              }
            }
            rankDx++;
          }
          return bishopMoves;
        case ChessPieceType.Rook:
          List<PossibleMoveGroup> rookMoves = [];
          int rankDx = 1;
          List<bool> stoppedTBLR = [
            false,
            false,
            false,
            false,
          ];
          while(stoppedTBLR.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTBLR}");
            if(!stoppedTBLR[0]){//Top
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLR[0]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLR[0]=true;
              }
            }
            if(!stoppedTBLR[1]){//Bottom
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLR[1]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLR[1]=true;
              }
            }
            if(!stoppedTBLR[2]){//Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLR[2]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLR[2]=true;
              }
            }
            if(!stoppedTBLR[3]){//Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLR[3]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  rookMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLR[3]=true;
              }
            }
            rankDx++;
          }
          return rookMoves;
        case ChessPieceType.Queen:
          List<PossibleMoveGroup> queenMoves = [];
          int rankDx = 1;
          List<bool> stoppedTBLRQEZC = [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
          ];
          while(stoppedTBLRQEZC.any((element) => !element)){
            _logger.info("$rankDx loop -> { $stoppedTBLRQEZC}");
            if(!stoppedTBLRQEZC[0]){//Top
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[0]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[0]=true;
              }
            }
            if(!stoppedTBLRQEZC[1]){//Bottom
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[1]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[1]=true;
              }
            }
            if(!stoppedTBLRQEZC[2]){//Left
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[2]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[2]=true;
              }
            }
            if(!stoppedTBLRQEZC[3]){//Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[3]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[3]=true;
              }
            }
            if(!stoppedTBLRQEZC[4]){//Top Left Q
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[4]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[4]=true;
              }
            }
            if(!stoppedTBLRQEZC[5]){//Top Right
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank + rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[5]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[5]=true;
              }
            }
            if(!stoppedTBLRQEZC[6]){//Bottom Left Z
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file - rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[6]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[6]=true;
              }
            }
            if(!stoppedTBLRQEZC[7]){//Bottom Right C
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank - rankDx,
                  file: chessPiece.location.file + rankDx
              );
              if(!toThisLocation.inside){
                stoppedTBLRQEZC[7]=true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  )));
              }else{
                if(pieceStopping.isWhite){
                  queenMoves.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), eatenPiece: pieceStopping));
                }
                stoppedTBLRQEZC[7]=true;
              }
            }
            rankDx++;
          }
          return queenMoves;
        case ChessPieceType.King:
          List<ChessLocation> kingJumps = [
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 0),
            ChessLocation(rank: chessPiece.location.rank + 1, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank + 0, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank + 0, file: chessPiece.location.file + 1),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file - 1),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 0),
            ChessLocation(rank: chessPiece.location.rank - 1, file: chessPiece.location.file + 1),
          ];
          List<PossibleMoveGroup> kingLocations = [];
          for(ChessLocation location in kingJumps){
            ChessPiece? pieceInLocation = gameState.aliveGamePiecesMapped[location];
            if(pieceInLocation == null){
              kingLocations.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = location
                  )));
            }else{
              if(pieceInLocation.isWhite){
                kingLocations.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = location
                  ), eatenPiece: pieceInLocation));
              }
            }
          }

          if(gameState.blackQueenSide){
            List<PossibleMoveGroup> queenSide = [];
            bool blocked = false;
            bool touchdown = false;
            int dx = 2;
            while(!blocked){
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file - dx
              );
              if(!toThisLocation.inside){
                blocked = true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                queenSide.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), queenSide: true));
              }else{
                if(!pieceStopping.isWhite && pieceStopping.pieceType == ChessPieceType.Rook){
                  queenSide.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)..location = toThisLocation
                  ), queenSide: true));
                  touchdown = true;
                }
                blocked = true;
              }
              dx++;
            }
            if(touchdown){
              kingLocations.addAll(queenSide);
            }
          }
          if(gameState.blackKingSide){
            List<PossibleMoveGroup> kingSide = [];
            bool blocked = false;
            bool touchdown = false;
            int dx = 2;
            while(!blocked){
              ChessLocation toThisLocation = ChessLocation(
                  rank: chessPiece.location.rank,
                  file: chessPiece.location.file + dx
              );
              if(!toThisLocation.inside){
                blocked = true;
              }
              ChessPiece? pieceStopping = gameState.aliveGamePiecesMapped[toThisLocation];
              if(pieceStopping == null){
                kingSide.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)
                  ), kingSide: true));
              }else{
                if(!pieceStopping.isWhite && pieceStopping.pieceType == ChessPieceType.Rook){
                  kingSide.add(PossibleMoveGroup(
                  pieceMovement: ChessMovement(
                    from: chessPiece,
                    to: ChessPiece.clone(chessPiece)
                  ), kingSide: true));
                  touchdown = true;
                }
                blocked = true;
              }
              dx++;
            }
            if(touchdown){
              kingLocations.addAll(kingSide);
            }
          }

          return kingLocations.where((element) => element.pieceMovement.to.location.inside).toList();
      }
    }
    return [];
  }
}


