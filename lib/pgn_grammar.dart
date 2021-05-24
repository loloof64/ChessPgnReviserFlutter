import 'package:petitparser/petitparser.dart';

class PgnGrammarDefinition extends GrammarDefinition {
  Parser start() => ref0(stringP).end();

  Parser games() =>
      ref0(ws).optional() & (ref0(game) & (ref0(ws) & ref0(game)).star()).optional();
  Parser game() =>
      ref0(tags).optional() & ref0(comments).optional() & ref0(pgn);
  Parser tags() =>
      ref0(ws).optional() &
      (ref0(tag) & (ref0(ws) & ref0(tag)).star()).optional() &
      ref0(ws);

  Parser tag() => ref0(bl) & ref0(ws).optional() & ref0(tagKeyValue) & ref0(ws).optional() & ref0(br);

  Parser tagKeyValue() =>
      ref0(eventKey) & ref0(ws) & ref0(stringP) |
      ref0(siteKey) & ref0(ws) & ref0(stringP) |
      ref0(dateKey) & ref0(ws) & ref0(date) |
      ref0(roundKey) & ref0(ws) & ref0(stringP) |
      ref0(whiteTitleKey) & ref0(ws) & ref0(stringP) |
      ref0(blackTitleKey) & ref0(ws) & ref0(stringP) |
      ref0(whiteEloKey) & ref0(ws) & ref0(integerOrDash) |
      ref0(blackEloKey) & ref0(ws) & ref0(integerOrDash) |
      ref0(whiteUSCFKey) & ref0(ws) & ref0(integerString) |
      ref0(blackUSCFKey) & ref0(ws) & ref0(integerString) |
      ref0(whiteNAKey) & ref0(ws) & ref0(stringP) |
      ref0(blackNAKey) & ref0(ws) & ref0(stringP) |
      ref0(whiteTypeKey) & ref0(ws) & ref0(stringP) |
      ref0(blackTypeKey) & ref0(ws) & ref0(stringP) |
      ref0(whiteKey) & ref0(ws) & ref0(stringP) |
      ref0(blackKey) & ref0(ws) & ref0(stringP) |
      ref0(resultKey) & ref0(ws) & ref0(result) |
      ref0(eventDateKey) & ref0(ws) & ref0(date) |
      ref0(eventSponsorKey) & ref0(ws) & ref0(stringP) |
      ref0(sectionKey) & ref0(ws) & ref0(stringP) |
      ref0(stageKey) & ref0(ws) & ref0(stringP) |
      ref0(boardKey) & ref0(ws) & ref0(integerString) |
      ref0(openingKey) & ref0(ws) & ref0(stringP) |
      ref0(variationKey) & ref0(ws) & ref0(stringP) |
      ref0(subVariationKey) & ref0(ws) & ref0(stringP) |
      ref0(ecoKey) & ref0(ws) & ref0(stringP) |
      ref0(nicKey) & ref0(ws) & ref0(stringP) |
      ref0(timeKey) & ref0(ws) & ref0(time) |
      ref0(utcTimeKey) & ref0(ws) & ref0(time) |
      ref0(utcDateKey) & ref0(ws) & ref0(date) |
      ref0(timeControlKey) & ref0(ws) & ref0(timeControl) |
      ref0(setUpKey) & ref0(ws) & ref0(stringP) |
      ref0(fenKey) & ref0(ws) & ref0(stringP) |
      ref0(terminationKey) & ref0(ws) & ref0(stringP) |
      ref0(anotatorKey) & ref0(ws) & ref0(stringP) |
      ref0(modeKey) & ref0(ws) & ref0(stringP) |
      ref0(plyCountKey) & ref0(ws) & ref0(integerString) |
      ref0(variantKey) & ref0(ws) & ref0(stringP) |
      ref0(whiteRatingDiffKey) & ref0(ws) & ref0(stringP) |
      ref0(blackRatingDiffKey) & ref0(ws) & ref0(stringP) |
      ref0(whiteFideIdKey) & ref0(ws) & ref0(stringP) |
      ref0(blackFideIdKey) & ref0(ws) & ref0(stringP) |
      ref0(whiteTeamKey) & ref0(ws) & ref0(stringP) |
      ref0(blackTeamKey) & ref0(ws) & ref0(stringP) |
      ref0(validatedKey).not() & ref0(anyKey) & ref0(ws) & ref0(stringP);

  Parser validatedKey() =>
      ref0(eventKey) |
      ref0(siteKey) |
      ref0(dateKey) |
      ref0(roundKey) |
      ref0(whiteTitleKey) |
      ref0(blackTitleKey) |
      ref0(whiteEloKey) |
      ref0(blackEloKey) |
      ref0(whiteUSCFKey) |
      ref0(blackUSCFKey) |
      ref0(whiteNAKey) |
      ref0(blackNAKey) |
      ref0(whiteTypeKey) |
      ref0(blackTypeKey) |
      ref0(whiteKey) |
      ref0(blackKey) |
      ref0(resultKey) |
      ref0(eventDateKey) |
      ref0(eventSponsorKey) |
      ref0(sectionKey) |
      ref0(stageKey) |
      ref0(boardKey) |
      ref0(openingKey) |
      ref0(variationKey) |
      ref0(subVariationKey) |
      ref0(ecoKey) |
      ref0(nicKey) |
      ref0(timeKey) |
      ref0(utcTimeKey) |
      ref0(utcDateKey) |
      ref0(timeControlKey) |
      ref0(setUpKey) |
      ref0(fenKey) |
      ref0(terminationKey) |
      ref0(anotatorKey) |
      ref0(modeKey) |
      ref0(plyCountKey) |
      ref0(variantKey) |
      ref0(whiteRatingDiffKey) |
      ref0(blackRatingDiffKey) |
      ref0(whiteFideIdKey) |
      ref0(blackFideIdKey) |
      ref0(whiteTeamKey) |
      ref0(blackTeamKey);

  Parser eventKey() => string('Event') | string('event');
  Parser siteKey() => string('Site') | string('site');
  Parser dateKey() => string('Date') | string('date');
  Parser roundKey() => string('Round') | string('round');
  Parser whiteKey() => string('White') | string('white');
  Parser blackKey() => string('Black') | string('black');
  Parser resultKey() => string('Result') | string('result');
  Parser whiteTitleKey() =>
      string('WhiteTitle') |
      string('Whitetitle') |
      string('whitetitle') |
      string('whiteTitle');
  Parser blackTitleKey() =>
      string('BlackTitle') |
      string('Blacktitle') |
      string('blacktitle') |
      string('blackTitle');
  Parser whiteEloKey() =>
      string('WhiteELO') |
      string('WhiteElo') |
      string('Whiteelo') |
      string('whiteelo') |
      string('whiteElo');
  Parser blackEloKey() =>
      string('BlackELO') |
      string('BlackElo') |
      string('Blackelo') |
      string('blackelo') |
      string('blackElo');
  Parser whiteUSCFKey() =>
      string('WhiteUSCF') |
      string('WhiteUscf') |
      string('Whiteuscf') |
      string('whiteuscf') |
      string('whiteUscf');
  Parser blackUSCFKey() =>
      string('BlackUSCF') |
      string('BlackUscf') |
      string('Blackuscf') |
      string('blackuscf') |
      string('blackUscf');
  Parser whiteNAKey() =>
      string('WhiteNA') |
      string('WhiteNa') |
      string('Whitena') |
      string('whitena') |
      string('whiteNa') |
      string('whiteNA');
  Parser blackNAKey() =>
      string('BlackNA') |
      string('BlackNa') |
      string('Blackna') |
      string('blackna') |
      string('blackNA') |
      string('blackNa');
  Parser whiteTypeKey() =>
      string('WhiteType') |
      string('Whitetype') |
      string('whitetype') |
      string('whiteType');
  Parser blackTypeKey() =>
      string('BlackType') |
      string('Blacktype') |
      string('blacktype') |
      string('blackType');
  Parser eventDateKey() =>
      string('EventDate') |
      string('Eventdate') |
      string('eventdate') |
      string('eventDate');
  Parser eventSponsorKey() =>
      string('EventSponsor') |
      string('Eventsponsor') |
      string('eventsponsor') |
      string('eventSponsor');
  Parser sectionKey() => string('Section') | string('section');
  Parser stageKey() => string('Stage') | string('stage');
  Parser boardKey() => string('Board') | string('board');
  Parser openingKey() => string('Opening') | string('opening');
  Parser variationKey() => string('Variation') | string('variation');
  Parser subVariationKey() =>
      string('SubVariation') |
      string('Subvariation') |
      string('subvariation') |
      string('subVariation');
  Parser ecoKey() => string('ECO') | string('Eco') | string('eco');
  Parser nicKey() => string('NIC') | string('Nic') | string('nic');
  Parser timeKey() => string('Time') | string('time');
  Parser utcTimeKey() =>
      string('UTCTime') |
      string('UTCtime') |
      string('UtcTime') |
      string('Utctime') |
      string('utctime') |
      string('utcTime');
  Parser utcDateKey() =>
      string('UTCDate') |
      string('UTCdate') |
      string('UtcDate') |
      string('Utcdate') |
      string('utcdate') |
      string('utcDate');
  Parser timeControlKey() =>
      string('TimeControl') |
      string('Timecontrol') |
      string('timecontrol') |
      string('timeControl');
  Parser setUpKey() =>
      string('SetUp') | string('Setup') | string('setup') | string('setUp');
  Parser fenKey() => string('FEN') | string('Fen') | string('fen');
  Parser terminationKey() => string('Termination') | string('termination');
  Parser anotatorKey() => string('Annotator') | string('annotator');
  Parser modeKey() => string('Mode') | string('mode');
  Parser plyCountKey() =>
      string('PlyCount') |
      string('Plycount') |
      string('plycount') |
      string('plyCount');
  Parser variantKey() => string('Variant') | string('variant');
  Parser whiteRatingDiffKey() => string('WhiteRatingDiff');
  Parser blackRatingDiffKey() => string('BlackRatingDiff');
  Parser whiteFideIdKey() => string('WhiteFideId');
  Parser blackFideIdKey() => string('BlackFideId');
  Parser whiteTeamKey() => string('WhiteTeam');
  Parser blackTeamKey() => string('BlackTeam');
  Parser anyKey() => ref0(stringNoQuot);

  Parser ws() => (char(' ') | char('\t') | char('\n') | char('\r')).star();
  Parser wsp() => (char(' ') | char('\t') | char('\n') | char('\r')).plus();
  Parser eol() => (char('\n') | char('\r'));

  Parser stringP() =>
      ref0(quotationMark) & ref0(charP).star()  & ref0(quotationMark);

  Parser stringNoQuot() => pattern("-a-zA-Z0-9.").star();

  Parser quotationMark() => char('"').trim();

  Parser charP() => pattern("^\x22\x5C");

  Parser dateDigit() => pattern('0-9') | char('?');

  Parser date() =>
      ref0(quotationMark) &
      (ref0(dateDigit) & ref0(dateDigit) & ref0(dateDigit) & ref0(dateDigit)) &
      char('.') &
      (ref0(dateDigit) & ref0(dateDigit)) &
      char('.') &
      (ref0(dateDigit) & ref0(dateDigit)) &
      ref0(quotationMark);

  Parser time() =>
      ref0(quotationMark) &
      digit().plus() &
      char(':') &
      digit().plus() &
      char(':') &
      digit().plus() &
      ref0(quotationMark);

  Parser timeControl() =>
      ref0(quotationMark) & ref0(tcnq) & ref0(quotationMark);

  Parser tcnq() =>
      char('?') |
      char('-') |
      ref0(integer) & char('/') & ref0(integer) |
      ref0(integer) & char('+') & ref0(integer) |
      ref0(integer) |
      char('*') & ref0(integer);

  Parser result() =>
      ref0(quotationMark) & ref0(innerResult) & ref0(quotationMark);
  Parser innerResult() =>
      string("1-0") | string("0-1") | string("1/2-1/2") | char('*');

  Parser integerOrDash() =>
      ref0(integerString) |
      ref0(quotationMark) & char('-') & ref0(quotationMark);

  Parser integerString() =>
      ref0(quotationMark) & digit().plus() & ref0(quotationMark);

  Parser pgn() =>
      ref0(ws) & ref0(pgnStartWhite) | ref0(ws) & ref0(pgnStartBlack);

  Parser pgnStartWhite() => ref0(pgnWhite) & ref0(ws);

  Parser pgnStartBlack() => ref0(pgnBlack) & ref0(ws);

  Parser pgnWhite() =>
      ref0(ws) &
          (ref0(comments) & ref0(ws)).optional() &
          (ref0(moveNumber) & ref0(ws)).optional() &
          (ref0(halfMove) & ref0(ws)) &
          (ref0(nags) & ref0(ws)).optional() &
          (ref0(comments) & ref0(ws)).optional() &
          ref0(variationWhite).optional() &
          ref0(pgnBlack).optional() |
      ref0(ws) & ref0(endGame) & ref0(ws);

  Parser pgnBlack() =>
      ref0(ws) &
          (ref0(comments) & ref0(ws)).optional() &
          (ref0(moveNumber) & ref0(ws)).optional() &
          (ref0(halfMove) & ref0(ws)) &
          (ref0(nags) & ref0(ws)).optional() &
          (ref0(comments) & ref0(ws)).optional() &
          ref0(variationBlack).optional() &
          ref0(pgnWhite).optional() |
      ref0(ws) & ref0(endGame) & ref0(ws);

  Parser endGame() => ref0(innerResult);

  Parser comments() => ref0(comment) & (ref0(ws) & ref0(comment)).star();

  Parser comment() =>
      ref0(cl) & ref0(innerComment) & ref0(cr) | ref0(commentEndOfLine);

  Parser innerComment() =>
      ref0(ws) &
          ref0(bl) &
          string("%csl") &
          ref0(wsp) &
          ref0(colorFields) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star() |
      ref0(ws) &
          ref0(bl) &
          string("%cal") &
          ref0(wsp) &
          ref0(colorArrows) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star() |
      ref0(ws) &
          ref0(bl) &
          char("%") &
          ref0(clockCommand) &
          ref0(wsp) &
          ref0(clockValue) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star() |
      ref0(ws) &
          ref0(bl) &
          string("%eval") &
          ref0(wsp) &
          ref0(stringNoQuot) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star() |
      ref0(ws) &
          ref0(bl) &
          char("%") &
          ref0(stringNoQuot) &
          ref0(wsp) &
          ref0(nbr).plus() &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star() |
      ref0(nonCommand).plus() & ref0(innerComment).star();

  Parser nonCommand() => string("[%").not() & char('}').not() & any();

  Parser nbr() => ref0(br).not() & any();

  Parser commentEndOfLine() =>
      ref0(semicolon) & pattern('^\r\n').star() & ref0(eol);

  Parser colorFields() =>
      ref0(colorField) &
      ref0(ws) &
      (char(',') & ref0(ws) & ref0(colorField)).star();

  Parser colorField() => ref0(color) & ref0(field);
  Parser colorArrows() =>
      ref0(colorArrow) &
      ref0(ws) &
      (char(',') & ref0(ws) & ref0(colorArrow)).star();

  Parser colorArrow() => ref0(color) & ref0(field) & ref0(field);
  Parser color() => char('Y') | char('G') | char('R') | char('B');

  Parser field() => ref0(column) & ref0(row);

  Parser cl() => char('{');
  Parser cr() => char('}');
  Parser bl() => char('[');
  Parser br() => char(']');
  Parser semicolon() => char(';');

  Parser clockCommand() =>
      string('clk') | string('egt') | string('emt') | string('mct');
  Parser clockValue() =>
      digit() &
      digit().optional() &
      char(':') &
      digit() &
      digit() &
      char(':') &
      digit() &
      digit();

  Parser variationWhite() =>
      ref0(pl) &
      ref0(pgnWhite) &
      ref0(pr) &
      ref0(ws) &
      ref0(variationWhite).optional();
  Parser variationBlack() =>
      ref0(pl) &
      ref0(pgnStartBlack) &
      ref0(pr) &
      ref0(ws) &
      ref0(variationBlack).optional();

  Parser pl() => char('(');
  Parser pr() => char(')');

  Parser moveNumber() =>
      ref0(integer) & ref0(whiteSpace).star() & ref0(dot).star();
  Parser dot() => char('.');
  Parser integer() => digit().plus();
  Parser whiteSpace() => char(' ');

  Parser halfMove() =>
      ref0(figure).optional() &
          ref0(checkdisc).and() &
          ref0(discriminator) &
          ref0(strike).optional() &
          ref0(column) &
          ref0(row) &
          ref0(promotion).optional() &
          ref0(check).optional() |
      ref0(figure).optional() &
          ref0(column) &
          ref0(row) &
          ref0(strikeOrDash).optional() &
          ref0(column) &
          ref0(row) &
          ref0(promotion).optional() &
          ref0(check) |
      ref0(figure).optional() &
          ref0(strike).optional() &
          ref0(column) &
          ref0(row) &
          ref0(promotion).optional() &
          ref0(check).optional() |
      string('O-O-O') & ref0(check).optional() |
      string('O-O') & ref0(check).optional() |
      ref0(figure) & char('@') & ref0(column) & ref0(row);

  Parser check() =>
      (string('+-').not() & char('+')) | (string(r'$$$').not() & char('#'));
  Parser promotion() => char('=') & ref0(promFigure);

  Parser nags() => ref0(nag) & ref0(ws) & ref0(nags).optional();

  Parser nag() =>
      (char('\$') & ref0(integer)) |
      string('!!') |
      string('??') |
      string('!?') |
      string('?!') |
      char('!') |
      char('?') |
      char('‼') |
      char('⁇') |
      char('⁉') |
      char('⁈') |
      char('□') |
      char('=') |
      char('∞') |
      char('⩲') |
      char('⩱') |
      char('±') |
      char('∓') |
      string('+-') |
      string('-+') |
      char('⨀') |
      char('⟳') |
      char('→') |
      char('↑') |
      char('⇆') |
      char('D');

  Parser discriminator() => ref0(column) | ref0(row);
  Parser checkdisc() =>
      ref0(discriminator) & ref0(strike).optional() & ref0(column) & ref0(row);

  Parser figure() =>
      char('R') | char('N') | char('B') | char('Q') | char('K') | char('P');

  Parser promFigure() => char('R') | char('N') | char('B') | char('Q');
  Parser column() => pattern('a-h');
  Parser row() => pattern('1-8');
  Parser strike() => char('x');
  Parser strikeOrDash() => char('x') | char('-');
}
