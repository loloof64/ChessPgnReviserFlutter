import 'package:petitparser/petitparser.dart';
import 'package:chess_pgn_reviser/pgn_grammar.dart';

class PgnParserDefinition extends PgnGrammarDefinition {
  Parser start() => ref0(stringP).end();

  Parser stringP() => super.stringP().map((values) {
        return values[1].join().trim();
      });
}
