/// How should be handled the given side ?
enum PlayerMode {
  /// For this side, user must guess a valid move.
  GuessMove,

  /// For this side, computer selects a move among valid moves if several, randomly.
  /// Otherwise computer just plays the move.
  ReadMoveRandomly,

  /// For this side, computer selects a move among valid moves if several, based on user choice.
  /// Otherwise computer just plays the move.
  ReadMoveByUserChoice,
}

const errorString = '#Error';
