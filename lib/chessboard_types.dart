class Cell {
  int file;
  int rank;

  Cell(this.file, this.rank);

  String toAlgebraic() {
    return "${String.fromCharCode('a'.codeUnitAt(0) + file)}${String.fromCharCode('1'.codeUnitAt(0) + rank)}";
  }

  static Cell fromAlgebraic(String cellStr) {
    final file = cellStr.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = cellStr.codeUnitAt(1) - '1'.codeUnitAt(0);

    return Cell(file, rank);
  }
}

class Move {
  Cell start;
  Cell end;

  Move(this.start, this.end);
}

class DragAndDropData {
  String startCellName;
  String pieceType;

  DragAndDropData(this.startCellName, this.pieceType);
}
