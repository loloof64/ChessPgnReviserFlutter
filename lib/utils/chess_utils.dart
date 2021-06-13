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
