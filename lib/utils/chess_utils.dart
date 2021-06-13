// @dart=2.9
import 'package:chess/chess.dart' as board_logic;

String pieceTypeToFen(board_logic.Piece pieceType) {
  if (pieceType.type == board_logic.PieceType.PAWN &&
      pieceType.color == board_logic.Color.WHITE) return 'P';
  if (pieceType.type == board_logic.PieceType.PAWN &&
      pieceType.color == board_logic.Color.BLACK) return 'p';
  if (pieceType.type == board_logic.PieceType.KNIGHT &&
      pieceType.color == board_logic.Color.WHITE) return 'N';
  if (pieceType.type == board_logic.PieceType.KNIGHT &&
      pieceType.color == board_logic.Color.BLACK) return 'n';
  if (pieceType.type == board_logic.PieceType.BISHOP &&
      pieceType.color == board_logic.Color.WHITE) return 'B';
  if (pieceType.type == board_logic.PieceType.BISHOP &&
      pieceType.color == board_logic.Color.BLACK) return 'b';
  if (pieceType.type == board_logic.PieceType.ROOK &&
      pieceType.color == board_logic.Color.WHITE) return 'R';
  if (pieceType.type == board_logic.PieceType.ROOK &&
      pieceType.color == board_logic.Color.BLACK) return 'r';
  if (pieceType.type == board_logic.PieceType.QUEEN &&
      pieceType.color == board_logic.Color.WHITE) return 'Q';
  if (pieceType.type == board_logic.PieceType.QUEEN &&
      pieceType.color == board_logic.Color.BLACK) return 'q';
  if (pieceType.type == board_logic.PieceType.KING &&
      pieceType.color == board_logic.Color.WHITE) return 'K';
  if (pieceType.type == board_logic.PieceType.KING &&
      pieceType.color == board_logic.Color.BLACK) return 'k';
  return null;
}

checkPiecesCount(board_logic.Chess gameLogic) {
  final piecesCounts = Map<String, int>();
  for (var rank = 0; rank < 8; rank++) {
    for (var file = 0; file < 8; file++) {
      final cell = board_logic.Chess.algebraic(16 * rank + file);
      final currentPiece = gameLogic.get(cell);
      if (currentPiece != null) {
        final currentFen = pieceTypeToFen(currentPiece);
        if (piecesCounts.containsKey(currentFen)) {
          piecesCounts[currentFen] += 1;
        } else {
          piecesCounts[currentFen] = 1;
        }
      }
    }
  }

  if (!piecesCounts.containsKey('K')) {
    throw Exception("No white king !");
  }
  if (!piecesCounts.containsKey('k')) {
    throw Exception("No black king !");
  }

  if (piecesCounts['K'] != 1) {
    throw Exception("There must be exactly one white king !");
  }
  if (piecesCounts['k'] != 1) {
    throw Exception("There must be exactly one black king !");
  }

  if (piecesCounts.containsKey('K') && piecesCounts['K'] > 8)
    throw Exception("Too many white pawns !");
  if (piecesCounts.containsKey('k') && piecesCounts['k'] > 8)
    throw Exception("Too many black pawns !");

  if (piecesCounts.containsKey('N') && piecesCounts['N'] > 10)
    throw Exception("Too many white knights !");
  if (piecesCounts.containsKey('n') && piecesCounts['n'] > 10)
    throw Exception("Too many black knights !");

  if (piecesCounts.containsKey('B') && piecesCounts['B'] > 10)
    throw Exception("Too many white bishops !");
  if (piecesCounts.containsKey('b') && piecesCounts['b'] > 10)
    throw Exception("Too many black bishops !");

  if (piecesCounts.containsKey('R') && piecesCounts['R'] > 10)
    throw Exception("Too many white rooks !");
  if (piecesCounts.containsKey('r') && piecesCounts['r'] > 10)
    throw Exception("Too many black rooks !");

  if (piecesCounts.containsKey('Q') && piecesCounts['Q'] > 9)
    throw Exception("Too many white queens !");
  if (piecesCounts.containsKey('q') && piecesCounts['q'] > 9)
    throw Exception("Too many black queens !");
}

board_logic.Move findMoveForPosition(board_logic.Chess position,
    String fromIntoAlgebraic, String toIntoAlgebraic, String promotionString) {
  final from = cellAlgebraicToInt(fromIntoAlgebraic);
  final to = cellAlgebraicToInt(toIntoAlgebraic);
  final promotion =
      promotionString != null ? pieceStringToPieceType(promotionString) : null;

  final allMoves = position.generate_moves({'legal': true});
  return allMoves.firstWhere((currentMove) {
    return currentMove.from == from &&
        currentMove.to == to &&
        currentMove.promotion == promotion;
  }, orElse: () => null);
}

int cellAlgebraicToInt(String cellAlgebraic) {
  final file = cellAlgebraic.codeUnitAt(0) - 'a'.codeUnitAt(0);
  final rank = 7 - (cellAlgebraic.codeUnitAt(1) - '1'.codeUnitAt(0));
  return file + 16 * rank;
}

board_logic.PieceType pieceStringToPieceType(String pieceTypeString) {
  switch (pieceTypeString.toLowerCase()) {
    case 'p':
      return board_logic.PieceType.PAWN;
    case 'n':
      return board_logic.PieceType.KNIGHT;
    case 'b':
      return board_logic.PieceType.BISHOP;
    case 'r':
      return board_logic.PieceType.ROOK;
    case 'q':
      return board_logic.PieceType.QUEEN;
    case 'k':
      return board_logic.PieceType.KING;
    default:
      throw 'Unrecognized piece $pieceTypeString';
  }
}
