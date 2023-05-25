const String completionsKey = 'completions';
const String variationsKey = 'variations';
const String pgnKey = 'pgn';
const String turnKey = 'turn';
const String whiteTurn = 'w';
const String blackTurn = 'b';

/// Says if the given node is completed. So if it's main variation is completed,
/// as well as all of its sub variations.
/// A variation is completed if its last node has been reached successfully
/// till its end at least completionTarget times.
/// So if the last node of this main variation has not a property 'completions',
/// then it's false.
/// Otherwise it's true if the propery 'completions' is at least completionTarget.
/// For a variation to be complete, not only the main variation must be complete,
/// but also all the variations of all nodes of the variation.
///
/// Of course, a sub variation is complete if its main variation as well as its sub
/// variations are completed, and so on.
///
/// One last caution is about the fact that we may want to check only white/black
/// moves, not always both.
bool isCompleted(List<dynamic> gamePgnNode, int completionTarget,
    bool includeWhiteMoves, bool includeBlackMoves) {
  // We always complete an empty task.
  if (gamePgnNode.isEmpty) return true;

  // User has not move to guess : it's completed.
  if (!includeWhiteMoves && !includeBlackMoves) return true;

  // Checks that all subvarations are completed.
  for (var currentNode in gamePgnNode) {
    final allVariations = currentNode[variationsKey] as List<dynamic>;
    for (var variation in allVariations) {
      if (!isCompleted(variation[pgnKey], completionTarget, includeWhiteMoves,
          includeBlackMoves)) return false;
    }
  }

  final lastNode = gamePgnNode.last;

  // Node that has not been reached yet has not marked its completion status.
  if (!lastNode.containsKey(completionsKey)) return false;

  final completionsValue = lastNode[completionsKey];
  final completed = completionsValue >= completionTarget;

  return completed;
}

/// Returns the total number of variations starting from the given game node.
int variationsCount(List<dynamic> gamePgnNode) {
  // We always complete an empty task.
  if (gamePgnNode.isEmpty) return 1;

  int result = 1; // the main line
  for (var currentNode in gamePgnNode) {
    final allVariations = currentNode[variationsKey] as List<dynamic>;
    for (var variation in allVariations) {
      result += variationsCount(variation[pgnKey]);
    }
  }
  return result;
}

/// Returns the total number of completed variations starting from the given game node.
/// A variation is completed if its last node has been reached successfully
/// till its end at least completionTarget times.
int completedVariationsCount(List<dynamic> gamePgnNode, int completionTarget,
    bool includeWhiteMoves, bool includeBlackMoves) {
  // We always complete an empty task.
  if (gamePgnNode.isEmpty) return 1;

  // User has not move to guess : it's completed.
  if (!includeWhiteMoves && !includeBlackMoves) return 1;

  int result = 0;

  // Counts completed sub variations (recursively)
  for (var currentNode in gamePgnNode) {
    final allVariations = currentNode[variationsKey] as List<dynamic>;
    for (var variation in allVariations) {
      result += completedVariationsCount(
        variation[pgnKey],
        completionTarget,
        includeWhiteMoves,
        includeBlackMoves,
      );
    }
  }

  final lastNode = gamePgnNode.last;

  // Node that has not been reached yet has not marked its completion status.
  if (lastNode.containsKey(completionsKey)) {
    final completionsValue = lastNode[completionsKey];
    final lastNodeCompleted = completionsValue >= completionTarget;
    if (lastNodeCompleted) {
      result += 1;
    }
  }

  return result;
}
