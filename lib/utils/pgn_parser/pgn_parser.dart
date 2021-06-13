import 'package:petitparser/petitparser.dart';
import 'pgn_grammar.dart';

class PgnParserDefinition extends PgnGrammarDefinition {
  Parser start() => ref0(games).end();

  Parser games() => super.games().map((values) {
        final games = values[1];
        var results = [];

        if (games != null) {
          final head = games[0];
          final tail = games[1].map((items) => items[1]);

          results.add(head);
          results.addAll(tail);
        }

        return results;
      });
  Parser game() => super.game().map((values) {
        return {
          'tags': values[0],
          'gameComment': values[1],
          'moves': values[2],
        };
      });

  Parser tags() => super.tags().map((values) {
        var results = {};
        for (var pair in values) {
          results[pair[0]] = pair[1];
        }
        return results;
      });

  Parser tag() => super.tag().map((values) {
        return values[1];
      });

  Parser tagKeyValue() => super.tagKeyValue().map((values) {
        return [values[0], values[2]];
      });

  Parser eventKey() => super.eventKey().map((values) => "Event");
  Parser siteKey() => super.siteKey().map((values) => "Site");
  Parser dateKey() => super.dateKey().map((values) => "Date");
  Parser roundKey() => super.roundKey().map((values) => "Round");
  Parser whiteKey() => super.whiteKey().map((values) => "White");
  Parser blackKey() => super.blackKey().map((values) => "Black");
  Parser resultKey() => super.resultKey().map((values) => "Result");
  Parser whiteTitleKey() => super.whiteTitleKey().map((values) => "WhiteTitle");
  Parser blackTitleKey() => super.blackTitleKey().map((values) => "BlackTitle");
  Parser whiteEloKey() => super.whiteEloKey().map((values) => "WhiteELO");
  Parser blackEloKey() => super.blackEloKey().map((values) => "BlackELO");
  Parser whiteUSCFKey() => super.whiteUSCFKey().map((values) => "WhiteUSCF");
  Parser blackUSCFKey() => super.blackUSCFKey().map((values) => "BlackUSCF");
  Parser whiteNAKey() => super.whiteNAKey().map((values) => "WhiteNA");
  Parser blackNAKey() => super.blackNAKey().map((values) => "BlackNA");
  Parser whiteTypeKey() => super.whiteTypeKey().map((values) => "WhiteType");
  Parser blackTypeKey() => super.blackTypeKey().map((values) => "BlackType");
  Parser eventDateKey() => super.eventDateKey().map((values) => "EventDate");
  Parser eventSponsorKey() =>
      super.eventSponsorKey().map((values) => "EventSponsor");
  Parser sectionKey() => super.sectionKey().map((values) => "Section");
  Parser stageKey() => super.stageKey().map((values) => "Stage");
  Parser boardKey() => super.boardKey().map((values) => "Board");
  Parser openingKey() => super.openingKey().map((values) => "Opening");
  Parser variationKey() => super.variationKey().map((values) => "Variation");
  Parser subVariationKey() =>
      super.subVariationKey().map((values) => "SubVariation");
  Parser ecoKey() => super.ecoKey().map((values) => "ECO");
  Parser nicKey() => super.nicKey().map((values) => "NIC");
  Parser timeKey() => super.timeKey().map((values) => "Times");
  Parser utcTimeKey() => super.utcTimeKey().map((values) => "UTCTime");
  Parser utcDateKey() => super.utcDateKey().map((values) => "UTCDate");
  Parser timeControlKey() =>
      super.timeControlKey().map((values) => "TimeControl");
  Parser setUpKey() => super.setUpKey().map((values) => "SetUp");
  Parser fenKey() => super.fenKey().map((values) => "FEN");
  Parser terminationKey() =>
      super.terminationKey().map((values) => "Termination");
  Parser anotatorKey() => super.anotatorKey().map((values) => "Annotator");
  Parser modeKey() => super.modeKey().map((values) => "Mode");
  Parser plyCountKey() => super.plyCountKey().map((values) => "PlyCount");
  Parser variantKey() => super.variantKey().map((values) => "Variant");
  Parser whiteRatingDiffKey() =>
      super.whiteRatingDiffKey().map((values) => "WhiteRatingDiff");
  Parser blackRatingDiffKey() =>
      super.blackRatingDiffKey().map((values) => "BlackRatingDiff");
  Parser whiteFideIdKey() =>
      super.whiteFideIdKey().map((values) => "WhiteFideId");
  Parser blackFideIdKey() =>
      super.blackFideIdKey().map((values) => "BlackFideId");
  Parser whiteTeamKey() => super.whiteTeamKey().map((values) => "WhiteTeam");
  Parser blackTeamKey() => super.blackTeamKey().map((values) => "BlackTeam");

  Parser date() => super.date().map((values) {
        final year = values[1];
        final month = values[3];
        final day = values[5];

        return {
          'value': "$year.$month.$day",
          'year': year,
          'month': month,
          'day': day
        };
      });

  Parser time() => super.time().map((values) {
        final hour = values[1];
        final minute = values[3];
        final second = values[5];

        return {
          'value': '$hour:$minute:$second',
          'hour': hour,
          'minute': minute,
          'second': second,
        };
      });

  Parser timeControl() => super.timeControl().map((values) {
        return values[1];
      });

  Parser tcnq() => super.tcnq().map((values) {
        final head = values[0];

        if (head == '?') {
          return {'kind': 'unknown', 'value': '?'};
        } else if (head == '-') {
          return {'kind': 'unlimited', 'value': '-'};
        } else if (head == '*') {
          return {'kind': 'hourglass', 'seconds': values[1]};
        } else if (values[1] == '/') {
          return {
            'kind': 'movesInSeconds',
            'moves': head,
            'seconds': values[2]
          };
        } else if (values[1] == '+') {
          return {'kind': 'increment', 'seconds': head, 'increment': values[2]};
        } else {
          return {'kind': 'suddenDeath', 'seconds': head};
        }
      });

  Parser topLevelPgn() => super.topLevelPgn().map((values) {
        final inner = values[0];
        final result = values[1];

        return {'pgn': inner, 'result': result};
      });

  Parser variationPgn() => super.variationPgn().map((values) {
        final inner = values[0];
        final result = values[1];

        final pgn = inner != null ? inner[0] : null;

        return {'pgn': pgn, 'result': result};
      });

  Parser innerPgnWhite() => super.innerPgnWhite().map((values) {
        final commentBefore = values[0];
        final moveNumber = values[2];
        final halfMove = values[4];
        final nags = values[6];
        final commentAfter = values[8];
        final innerVariations = values[10];
        final innerPgnBlack = values[11];

        final newItem = {
          'turn': 'w',
          'moveNumber': moveNumber,
          'halfMove': halfMove,
          'variations': innerVariations ?? [],
          'nag': nags,
          'commentDiag': commentAfter,
          'commentBefore': commentBefore,
          'commentAfter': commentAfter,
        };

        var results = innerPgnBlack ?? [];
        results.insert(0, newItem);

        return results;
      });

  Parser innerPgnBlack() => super.innerPgnBlack().map((values) {
        final commentBefore = values[0];
        final moveNumber = values[2];
        final halfMove = values[4];
        final nags = values[6];
        final commentAfter = values[8];
        final innerVariations = values[10];
        final innerPgnWhite = values[11];

        final newItem = {
          'turn': 'b',
          'moveNumber': moveNumber,
          'halfMove': halfMove,
          'variations': innerVariations ?? [],
          'nag': nags,
          'commentDiag': commentAfter,
          'commentBefore': commentBefore,
          'commentAfter': commentAfter,
        };

        var results = innerPgnWhite ?? [];
        results.insert(0, newItem);

        return results;
      });

  Parser comment() => super.comment().map((values) {
        if (values.length == 1)
          return values[0];
        else
          return values[1];
      });

  Parser innerComment() =>
      super.innerComment().map((values) => values.join(''));

  Parser commentEndOfLine() =>
      super.commentEndOfLine().map((values) => values[1].join());

  Parser variation() => super.variation().map((values) => values[1]);

  Parser moveNumberWhite() =>
      super.moveNumberWhite().map((values) => values[0]);

  Parser moveNumberBlack() =>
      super.moveNumberBlack().map((values) => values[0]);

  Parser stringP() => super.stringP().map((values) {
        return values[1].join().trim();
      });

  Parser integerString() =>
      super.integerString().map((values) => num.parse(values[1]));

  Parser integer() => super.integer().map((values) => num.parse(values));

  Parser whiteSpace() => super.whiteSpace().map((values) => '');

  Parser halfMove() => super.halfMove().map((values) {
        if (values[0] == 'O-O-O') {
          final check = values[1];
          return {
            'notation': 'O-O-O${values[1] ?? ""}',
            'check': check,
          };
        } else if (values[0] == 'O-O') {
          final check = values[1];
          return {
            'notation': 'O-O${values[1] ?? ""}',
            'check': check,
          };
        } else if (values[1] == '@') {
          final figure = values[0];
          final col = values[2];
          final row = values[3];

          return {
            'fig': figure,
            'drop': true,
            'col': col,
            'row': row,
            'notation': "$figure@$col$row",
          };
        } else if (values.length == 6) {
          final figure = values[0];
          final strike = values[1];
          final col = values[2];
          final row = values[3];
          final promotion = values[4];
          final check = values[5];

          return {
            'fig': figure,
            'strike': strike,
            'col': col,
            'row': row,
            'check': check,
            'promotion': promotion,
            'notation':
                "${figure ?? ""}${strike ?? ""}$col$row${promotion ?? ""}${check ?? ""}"
          };
        }
        // case 2 : values.length is 8
        else if (values.length == 8) {
          final figure = values[0];
          final cols = values[1];
          final rows = values[2];
          final strike = values[3];
          final col = values[4];
          final row = values[5];
          final promotion = values[6];
          final check = values[7];

          return {
            'fig': figure,
            'strike': strike == 'x' ? strike : null,
            'col': col,
            'row': row,
            'check': check,
            'promotion': promotion,
            'notation':
                '${figure != null && figure != 'P' ? figure : ''}$cols$rows${strike == 'x' ? strike : '-'}$col$row${promotion ?? ""}${check ?? ""}'
          };
        } else {
          final figure = values[0];
          final discriminator = values[1];
          final strike = values[2];
          final col = values[3];
          final row = values[4];
          final promotion = values[5];
          final check = values[6];

          return {
            'fig': figure,
            'disc': discriminator,
            'strike': strike,
            'col': col,
            'row': row,
            'check': check,
            'promotion': promotion,
            'notation':
                "${figure ?? ""}${discriminator ?? ""}${strike ?? ""}$col$row${promotion ?? ""}${check ?? ""}",
          };
        }
      });

  Parser check() => super.check().map((values) => values[0]);

  Parser promotion() => super.promotion().map((values) => "=${values[1]}");

  Parser nags() => super.nags().map((values) {
        final head = values[0];
        var tail = values[2] ?? [];
        tail.insert(0, head);
        return tail;
      });

  Parser nag() => super.nag().map((values) {
        final first = values[0];
        switch (first) {
          case '\$':
            return "\$${values[1]}";
          case '!!':
            return '\$3';
          case '??':
            {
              return '\$4';
            }
          case '!?':
            {
              return '\$5';
            }
          case '?!':
            {
              return '\$6';
            }
          case '!':
            {
              return '\$1';
            }
          case '?':
            {
              return '\$2';
            }
          case '‼':
            {
              return '\$3';
            }
          case '⁇':
            {
              return '\$4';
            }
          case '⁉':
            {
              return '\$5';
            }
          case '⁈':
            {
              return '\$6';
            }
          case '□':
            {
              return '\$7';
            }
          case '=':
            {
              return '\$10';
            }
          case '∞':
            {
              return '\$13';
            }
          case '⩲':
            {
              return '\$14';
            }
          case '⩱':
            {
              return '\$15';
            }
          case '±':
            {
              return '\$16';
            }
          case '∓':
            {
              return '\$17';
            }
          case '+-':
            {
              return '\$18';
            }
          case '-+':
            {
              return '\$19';
            }
          case '⨀':
            {
              return '\$22';
            }
          case '⟳':
            {
              return '\$32';
            }
          case '→':
            {
              return '\$36';
            }
          case '↑':
            {
              return '\$40';
            }
          case '⇆':
            {
              return '\$132';
            }
          case 'D':
            {
              return '\$220';
            }
        }
      });
}
