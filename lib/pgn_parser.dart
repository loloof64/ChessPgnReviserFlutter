import 'package:petitparser/petitparser.dart';
import 'package:chess_pgn_reviser/pgn_grammar.dart';

class PgnParserDefinition extends PgnGrammarDefinition {
  Parser start() => ref0(colorArrows).end();

  Parser tag() => super.tag().map((values) {
        return values[1];
      });

  Parser tagKeyValue() => super.tagKeyValue().map((values) {
        var result = {};
        result[values[0]] = values[2];
        return result;
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

  Parser colorArrows() => super.colorArrows().map((values) {
        final head = values[0];
        final tail = values[2];

        var results = [head];
        tail.forEach((value) {
          results.add(value[2]);
        });

        return results;
      }); 

  Parser colorArrow() =>
      super.colorArrow().map((values) => values[0] + values[1] + values[2]);

  Parser clockValue() => super.clockValue().map((values) {
        final h1 = values[0];
        final h2 = values[1];

        final m1 = values[3];
        final m2 = values[4];

        final s1 = values[6];
        final s2 = values[7];

        return "$h1${h2 ?? ''}:$m1$m2:$s1$s2";
      });

  Parser colorFields() => super.colorFields().map((values) {
        final head = values[0];
        final tail = values[2];

        var results = [head];
        tail.forEach((value) {
          results.add(value[2]);
        });

        return results;
      });

  Parser colorField() =>
      super.colorField().map((values) => values[0] + values[1]);

  Parser field() => super.field().map((values) => values[0] + values[1]);

  Parser variationWhite() => super.variationWhite().map((values) {
        final head = values[1];
        final tail = values[4];

        var results = tail ?? [];
        results.insert(0, head);

        return results;
      });

  Parser variationBlack() => super.variationBlack().map((values) {
        final head = values[1];
        final tail = values[4];

        var results = tail ?? [];
        results.insert(0, head);

        return results;
      });

  Parser moveNumber() => super.moveNumber().map((values) => values[0]);

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

  Parser result() => super.result().map((values) => values[1]);

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
