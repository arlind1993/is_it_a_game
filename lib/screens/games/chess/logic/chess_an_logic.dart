import 'dart:collection';
import 'dart:math';

import 'package:game_template/screens/games/chess/models/chess_constants.dart';
import 'package:game_template/screens/games/chess/models/chess_possible_move_group.dart';
import 'package:game_template/services/extensions/iterable_extensions.dart';
import 'package:logging/logging.dart';
import '../models/chess_location.dart';
import '../models/chess_movement.dart';
import '../models/chess_piece.dart';
import '../models/chess_board_state.dart';
import 'chess_possible_move_logic.dart';

/// HIGHKEY A LOT TO DO
class ChessANAlgorithms{
  static ChessANAlgorithms _algorithms = ChessANAlgorithms._();
  factory ChessANAlgorithms(){
    return _algorithms;
  }
  ChessANAlgorithms._();
  Logger _logger = Logger("ChessANAlgorithms");


  PossibleMoveGroup? tryParseGameStatesToMoveGroup(ChessBoardState previousState, ChessBoardState currentState){
    try{
      PossibleMoveGroup possibleMoveGroup = parseGameStatesToMoveGroup(previousState, currentState);
      return possibleMoveGroup;
    }catch(e){
      return null;
    }
  }
  PossibleMoveGroup parseGameStatesToMoveGroup(ChessBoardState previousState, ChessBoardState currentState){
    int differencePrevToNow = previousState.aliveGamePieces.length - currentState.aliveGamePieces.length;
    if(!(differencePrevToNow == 0 || differencePrevToNow == 1)){
      throw "To many game pieces eaten or a game piece appeared out of nowhere";
    }

    bool kingSide = false;
    bool queenSide = false;
    ChessPiece? pieceEaten;
    late ChessMovement movement;

    //_logger.info("${currentState.gamePiecesMapped.length} ${currentState.gamePiecesMapped}");
    HashSet<NullableChessMovement> currentPiecesChanged = HashSet<NullableChessMovement>(
      equals: (el1, el2) => el1 == el2,
      hashCode: (el) => el.hashCode,
    );
    for(MapEntry<ChessLocation,ChessPiece> previousPiece in previousState.gamePiecesMapped.entries){
      ChessPiece prev = previousPiece.value;
      ChessPiece? curr = currentState.gamePiecesMapped[previousPiece.key];
      if(prev != curr){
        currentPiecesChanged.add(NullableChessMovement(from: prev, to: curr));
      }
    }
    for(MapEntry<ChessLocation,ChessPiece> currentPiece in currentState.gamePiecesMapped.entries){
      ChessPiece curr = currentPiece.value;
      ChessPiece? prev = previousState.gamePiecesMapped[currentPiece.key];
      if(curr != prev){
        currentPiecesChanged.add(NullableChessMovement(from: prev, to: curr));
      }
    }

    if(currentPiecesChanged.length == 0){
      throw "No movement observed";
    }else if(currentPiecesChanged.length > 4){
      _logger.warning("Wierd af case so many movements ${currentPiecesChanged}");
    }

    _logger.fine(currentPiecesChanged);
    pieceEaten = currentPiecesChanged.firstWhereIfThere((element) {
      if(element.from != null){
        if(element.to != null
          && !element.from!.eaten && !element.to!.eaten
          && element.from!.isWhite == !element.to!.isWhite){
          return true;
        }else if(previousState.lastEnPassantMove != null){
          if(element.from!.isWhite){
            if(element.from!.location == (previousState.lastEnPassantMove! + ChessLocation(rank: 1, file: 0))){
              return true;
            }
          }else{
            if(element.from!.location == (previousState.lastEnPassantMove! - ChessLocation(rank: 1, file: 0))){
              return true;
            }
          }
        }
      }
      return false;
    }

    )?.from;

    ChessPiece? kingOfMove = currentPiecesChanged.firstWhereIfThere((element) => element.from != null
        && !element.from!.eaten
        && element.from!.pieceType == ChessPieceType.King
    )?.from; //Checking for kingside // queenside

    if(kingOfMove != null){
      ChessPiece? queenSideRook = currentPiecesChanged.firstWhereIfThere((element) => element.from != null
          && !element.from!.eaten
          && element.from!.pieceType == ChessPieceType.Rook
          && element.from!.isWhite == kingOfMove.isWhite
          && element.from!.location.file < kingOfMove.location.file
      )?.from;
      ChessPiece? kingSideRook = currentPiecesChanged.firstWhereIfThere((element) => element.from != null
          && !element.from!.eaten
          && element.from!.pieceType == ChessPieceType.Rook
          && element.from!.isWhite == kingOfMove.isWhite
          && element.from!.location.file > kingOfMove.location.file
      )?.from;
      if(queenSideRook != null){
        queenSide = true;
      }else if(kingSideRook != null){
        kingSide = true;
      }
    }
    ChessPiece from = currentPiecesChanged.firstWhereIfThere((element) => element.from != null && element.to == null && element.from!.isWhite == previousState.isWhiteTurn)!.from!;
    _logger.warning("from $from");
    ChessPiece to = currentPiecesChanged.firstWhereIfThere((element) => element.to!=null
        && ChessPossibleMovesAlgorithms().getPossibleMovesForPiece(from, previousState)
          .map((e) => e.pieceMovement.to.location).contains(element.to?.location))!.to! ;
    movement = ChessMovement(from: from, to: to);

    return PossibleMoveGroup(
      pieceMovement: movement,
      eatenPiece: pieceEaten,
      kingSide: kingSide,
      queenSide: queenSide,
    );
  }

  ChessBoardState makeMoveWith(ChessBoardState chessBoardState, String an){
    return chessBoardState.getNewBoardFromMove(parseANToMoveGroup(chessBoardState, an));
  }

  String parseGameStatesToAN(ChessBoardState previousState, ChessBoardState currentState){
    PossibleMoveGroup moveGroup = parseGameStatesToMoveGroup(previousState, currentState);
    if(moveGroup.kingSide) return "O-O";
    if(moveGroup.queenSide) return "O-O-O";
    bool pieceCaptured = moveGroup.eatenPiece != null;
    bool piecePawn = moveGroup.pieceMovement.from.pieceType == ChessPieceType.Pawn;
    bool sameRow = false;
    bool sameCol = false;
    bool any = false;
    List<ChessPiece> othersPossibleToSameLocation = previousState.gamePiecesMapped.values.where((element) =>
      element != moveGroup.pieceMovement.from
      && !element.eaten
      && element.pieceType == moveGroup.pieceMovement.from.pieceType
      && element.isWhite == moveGroup.pieceMovement.from.isWhite
      && ChessPossibleMovesAlgorithms().getPossibleMovesForPiece(element, previousState).map((e) => e.pieceMovement.to.location)
          .contains(moveGroup.pieceMovement.to.location)
    ).toList();
    _logger.info("othersPossibleToSameLocation {$othersPossibleToSameLocation}");

    for(ChessPiece piece in othersPossibleToSameLocation){
      if(!any){
        any = true;
      }
      if(!sameRow){
        if(piece.location.rank == moveGroup.pieceMovement.from.location.rank){
          sameRow = true;
        }
      }
      if(!sameCol){
        if(piece.location.file == moveGroup.pieceMovement.from.location.file){
          sameCol = true;
        }
      }
    }


    String fromAn = "";
    if(any || (pieceCaptured && moveGroup.pieceMovement.from.pieceType == ChessPieceType.Pawn)){
      if(sameRow && sameCol){
        fromAn = "${moveGroup.pieceMovement.from.location.fileName}${moveGroup.pieceMovement.from.location.rankName}";
      }else if(sameRow && !sameCol){
        fromAn = "${moveGroup.pieceMovement.from.location.fileName}";
      }else if(!sameRow && sameCol){
        fromAn = "${moveGroup.pieceMovement.from.location.rankName}";
      }else{
        fromAn = "${moveGroup.pieceMovement.from.location.fileName}";
      }
    }


    _logger.info("ASC{${any?1:0}${sameRow?1:0}${sameCol?1:0}} -> $fromAn");
    bool piecePromotion = moveGroup.pieceMovement.from.pieceType == ChessPieceType.Pawn
        && moveGroup.pieceMovement.to.pieceType != ChessPieceType.Pawn
        && moveGroup.pieceMovement.from.isWhite == moveGroup.pieceMovement.to.isWhite;

    return "${piecePawn ? "" : moveGroup.pieceMovement.from.pieceCode.toUpperCase()}"
        "${fromAn}"
        "${pieceCaptured ? "x" : ""}"
        "${moveGroup.pieceMovement.to.location}"
        "${piecePromotion ? "=${moveGroup.pieceMovement.to.pieceCode.toUpperCase()}":""}";
  }

  PossibleMoveGroup parseANToMoveGroup(ChessBoardState prev, String an){
    bool kingSide = an == "O-O";
    bool queenSide = an == "O-O-O";
    if(an == "=" || an.contains(RegExp("^[0-9]+\\-[0-9]+\$"))){
      print(an);
    }
    ChessPiece? pieceEaten;
    late ChessMovement movement;

    ChessPiece kingOfMove = prev.gamePiecesMapped.values.firstWhere((element) => !element.eaten
        && element.isWhite == prev.isWhiteTurn && element.pieceType == ChessPieceType.King
    );
    if(kingSide || queenSide){
      movement = ChessMovement(from: kingOfMove, to: kingOfMove);
    }else{
      late ChessPieceType type;
      if(an.startsWith("K")){
        type = ChessPieceType.King;
      }else if(an.startsWith("Q")){
        type = ChessPieceType.Queen;
      }else if(an.startsWith("R")){
        type = ChessPieceType.Rook;
      }else if(an.startsWith("B")){
        type = ChessPieceType.Bishop;
      }else if(an.startsWith("N")){
        type = ChessPieceType.Knight;
      }else{
        type = ChessPieceType.Pawn;
      }
      bool takes = an.contains("x");
      List<String> splited= an.split("=");
      ChessPieceType? promotionType = splited.length != 2 ? null
          : (splited.last == "R" ? ChessPieceType.Rook :
                splited.last == "B" ? ChessPieceType.Bishop :
                    splited.last == "N"? ChessPieceType.Knight : ChessPieceType.Queen);
      String withoutTypeAndTakes = splited.first.replaceAll("x", "").substring(type == ChessPieceType.Pawn ? 1 : 0);
      assert(withoutTypeAndTakes.length > 2);
      String fromLoc = withoutTypeAndTakes.substring(0, withoutTypeAndTakes.length-2);
      String toLoc = withoutTypeAndTakes.substring(withoutTypeAndTakes.length-2);
      ChessLocation locationTo = ChessLocation.fromPieceFen(toLoc);
      List<ChessPiece> possiblePieces = prev.gamePiecesMapped.values.where((element) => !element.eaten
        && element.pieceType == type
        && ChessPossibleMovesAlgorithms().getPossibleMovesForPiece(element, prev).map((e) {
          return e.pieceMovement.to.location;
        }).contains(locationTo)
      ).toList();

      if(possiblePieces.length == 0){
        throw "No possible pieces";
      }else if(possiblePieces.length == 1){
        movement = ChessMovement(
          from: possiblePieces.first,
          to: (ChessPiece.clone(possiblePieces.first)..location = locationTo)..pieceType = (promotionType ?? possiblePieces.first.pieceType),
        );
      }else{//NarrowDownToOne
        String fileIntString = "";
        String rankIntString = "";
        for(int i = 0;  i < fromLoc.length; i++){
          int character = fromLoc.codeUnitAt(i);
          if(character >= 48 && character < 58){
            rankIntString += "${character - 48}";
          }else if(character >= 97 && character < 123){
            fileIntString += "${character - 96}";
          }
        }
        int? file = int.tryParse(fileIntString);
        int? rank = int.tryParse(rankIntString);
        ChessPiece chessPiece = possiblePieces.firstWhere((element){
          if(file != null && rank != null){
            return element.location.file == file && element.location.rank == rank;
          }
          if(file != null){
            return element.location.file == file;
          }
          if(rank != null){
            return element.location.rank == rank;
          }
          return true;
        });

        movement = ChessMovement(
          from: chessPiece,
          to: (ChessPiece.clone(chessPiece)..location = locationTo)..pieceType = (promotionType ?? chessPiece.pieceType),
        );
      }

      if(takes){
        if(prev.lastEnPassantMove == null){
          pieceEaten = movement.to;
        }else{
          if(movement.from.pieceType == ChessPieceType.Pawn && movement.to.location == prev.lastEnPassantMove){
            pieceEaten = prev.gamePiecesMapped.values.firstWhereIfThere((element){
              if(movement.from.isWhite){// you are white the other is black and you are trying to get the eaten piece
                if(element.location == (prev.lastEnPassantMove! - ChessLocation(rank: 1, file: 0))){
                  return true;
                }
              }else{
                if(element.location == (prev.lastEnPassantMove! + ChessLocation(rank: 1, file: 0))){
                  return true;
                }
              }
              return false;
            });

          }
        }
      }
    }


    PossibleMoveGroup possibleMoveGroup = PossibleMoveGroup(
      pieceMovement: movement,
      queenSide: queenSide,
      kingSide: kingSide,
      eatenPiece: pieceEaten
    );
    return possibleMoveGroup;
  }
}