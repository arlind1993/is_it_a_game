import 'dart:math';
import 'sudoku_location.dart';
import 'sudoku_constants.dart';

enum SudokuCellType{
  initial,
  mutable,
  filled,
}

class SudokuCell{
  SudokuLocation sudokuLocation;
  int? value;
  int extra; //1,2,3,4,5,6,7,8,9 -> 1,2,4,8,16,32,64,128,256,
  int must;
  SudokuCellType type;

  List<int> get listExtra => decode(extra, SudokuConstants().SUDOKU_SIZE_SQUARE);
  List<int> get listMust => decode(must, SudokuConstants().SUDOKU_SIZE_SQUARE);

  List<int> decode(int input, int bitLength, {bool include0 = false}){
    List<int> result = [];
    for(int i = 0; i < bitLength ; i++){
      int val = pow(2, i).toInt();
      if(input & val == val){
        result.add(include0 ? i : i + 1);
      }
    }
    return result;
  }

  int encode(List<int> input, int bitLength, {bool include0 = false}){
    int result = 0;
    for(int i = 0; i < bitLength ; i++){
      int val = pow(2, i).toInt();
      int index = input.indexWhere((element) => element == (include0 ? i : i + 1));
      if(index != -1){
       result |= val;
      }
    }
    return result;
  }

  addOrRemoveExtra(List<int> newInputs) => extra ^= encode(newInputs, SudokuConstants().SUDOKU_SIZE_SQUARE);
  addOrRemoveMust(List<int> newInputs) => must ^= encode(newInputs, SudokuConstants().SUDOKU_SIZE_SQUARE);

  SudokuCell({
    required this.sudokuLocation,
    required this.value,
    this.extra = 0,
    this.must = 0,
    required this.type,
  });

  SudokuCell.clone(SudokuCell chessPiece):
    sudokuLocation = SudokuLocation.clone(chessPiece.sudokuLocation),
    value = chessPiece.value,
    extra = chessPiece.extra,
    must = chessPiece.must,
    type = chessPiece.type;

  @override
  String toString() {
    return "SC{${sudokuLocation.nameConvention}->$value}";
  }

  bool operator == (o) => o is SudokuCell
    && o.sudokuLocation == sudokuLocation
    && o.value == value
    && o.extra == extra
    && o.must == must
    && o.type == type;

  @override
  int get hashCode => Object.hash(sudokuLocation, value, extra, type);
}
