import 'package:petitparser/petitparser.dart';
import 'package:chess_pgn_reviser/pgn_grammar.dart';

class PgnParserDefinition extends PgnGrammarDefinition {
  Parser start() => ref0(timeControl).end();

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
  Parser anyKey() => super.anyKey().map((values) => values.join());

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
          return {'kind': 'movesInSeconds', 'moves': head, 'seconds': values[2]};
        } else if (values[1] == '+') {
          return {'kind': 'increment', 'seconds': head, 'increment': values[2]};
        } else {
          return {'kind': 'suddenDeath', 'seconds': head};
        }
      });

  Parser stringP() => super.stringP().map((values) {
        return values[1].join().trim();
      });

  Parser integerString() =>
      super.integerString().map((values) => num.parse(values[1]));

  Parser integer() => super.integer().map((values) => num.parse(values));

  Parser result() => super.result().map((values) => values[1]);
}
