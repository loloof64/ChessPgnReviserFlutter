import 'package:petitparser/petitparser.dart';

class PgnGrammarDefinition extends GrammarDefinition {
  Parser start() => ref0(games).end();

  Parser games() =>
      ref0(ws).optional() &
      (ref0(game) & (ref0(ws) & ref0(game)).star()).optional();
  Parser game() =>
      ref0(tags).optional() & ref0(comments).optional() & ref0(pgn);
  Parser tags() => ref0(tag).plus();

  Parser tag() => ref0(bl) & ref0(tagKeyValue) & ref0(br);

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
      ref0(anyKey) & ref0(ws) & ref0(stringP);

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

  Parser eventKey() => string('Event').trim() | string('event').trim();
  Parser siteKey() => string('Site').trim() | string('site').trim();
  Parser dateKey() => string('Date').trim() | string('date').trim();
  Parser roundKey() => string('Round').trim() | string('round').trim();
  Parser whiteKey() => string('White').trim() | string('white').trim();
  Parser blackKey() => string('Black').trim() | string('black').trim();
  Parser resultKey() => string('Result').trim() | string('result').trim();
  Parser whiteTitleKey() =>
      string('WhiteTitle').trim() |
      string('Whitetitle').trim() |
      string('whitetitle').trim() |
      string('whiteTitle').trim();
  Parser blackTitleKey() =>
      string('BlackTitle').trim() |
      string('Blacktitle').trim() |
      string('blacktitle').trim() |
      string('blackTitle').trim();
  Parser whiteEloKey() =>
      string('WhiteELO').trim() |
      string('WhiteElo').trim() |
      string('Whiteelo').trim() |
      string('whiteelo').trim() |
      string('whiteElo').trim();
  Parser blackEloKey() =>
      string('BlackELO').trim() |
      string('BlackElo').trim() |
      string('Blackelo').trim() |
      string('blackelo').trim() |
      string('blackElo').trim();
  Parser whiteUSCFKey() =>
      string('WhiteUSCF').trim() |
      string('WhiteUscf').trim() |
      string('Whiteuscf').trim() |
      string('whiteuscf').trim() |
      string('whiteUscf').trim();
  Parser blackUSCFKey() =>
      string('BlackUSCF').trim() |
      string('BlackUscf').trim() |
      string('Blackuscf').trim() |
      string('blackuscf').trim() |
      string('blackUscf').trim();
  Parser whiteNAKey() =>
      string('WhiteNA').trim() |
      string('WhiteNa').trim() |
      string('Whitena').trim() |
      string('whitena').trim() |
      string('whiteNa').trim() |
      string('whiteNA').trim();
  Parser blackNAKey() =>
      string('BlackNA').trim() |
      string('BlackNa').trim() |
      string('Blackna').trim() |
      string('blackna').trim() |
      string('blackNA').trim() |
      string('blackNa').trim();
  Parser whiteTypeKey() =>
      string('WhiteType').trim() |
      string('Whitetype').trim() |
      string('whitetype').trim() |
      string('whiteType').trim();
  Parser blackTypeKey() =>
      string('BlackType').trim() |
      string('Blacktype').trim() |
      string('blacktype').trim() |
      string('blackType').trim();
  Parser eventDateKey() =>
      string('EventDate').trim() |
      string('Eventdate').trim() |
      string('eventdate').trim() |
      string('eventDate').trim();
  Parser eventSponsorKey() =>
      string('EventSponsor').trim() |
      string('Eventsponsor').trim() |
      string('eventsponsor').trim() |
      string('eventSponsor').trim();
  Parser sectionKey() => string('Section').trim() | string('section').trim();
  Parser stageKey() => string('Stage').trim() | string('stage').trim();
  Parser boardKey() => string('Board').trim() | string('board').trim();
  Parser openingKey() => string('Opening').trim() | string('opening').trim();
  Parser variationKey() =>
      string('Variation').trim() | string('variation').trim();
  Parser subVariationKey() =>
      string('SubVariation').trim() |
      string('Subvariation').trim() |
      string('subvariation').trim() |
      string('subVariation').trim();
  Parser ecoKey() =>
      string('ECO').trim() | string('Eco').trim() | string('eco'.trim());
  Parser nicKey() =>
      string('NIC').trim() | string('Nic').trim() | string('nic').trim();
  Parser timeKey() => string('Time').trim() | string('time').trim();
  Parser utcTimeKey() =>
      string('UTCTime').trim() |
      string('UTCtime').trim() |
      string('UtcTime').trim() |
      string('Utctime').trim() |
      string('utctime').trim() |
      string('utcTime').trim();
  Parser utcDateKey() =>
      string('UTCDate').trim() |
      string('UTCdate').trim() |
      string('UtcDate').trim() |
      string('Utcdate').trim() |
      string('utcdate').trim() |
      string('utcDate').trim();
  Parser timeControlKey() =>
      string('TimeControl').trim() |
      string('Timecontrol').trim() |
      string('timecontrol').trim() |
      string('timeControl').trim();
  Parser setUpKey() =>
      string('SetUp').trim() |
      string('Setup').trim() |
      string('setup').trim() |
      string('setUp').trim();
  Parser fenKey() =>
      string('FEN').trim() | string('Fen').trim() | string('fen').trim();
  Parser terminationKey() =>
      string('Termination').trim() | string('termination').trim();
  Parser anotatorKey() =>
      string('Annotator').trim() | string('annotator').trim();
  Parser modeKey() => string('Mode').trim() | string('mode').trim();
  Parser plyCountKey() =>
      string('PlyCount').trim() |
      string('Plycount').trim() |
      string('plycount').trim() |
      string('plyCount').trim();
  Parser variantKey() => string('Variant').trim() | string('variant').trim();
  Parser whiteRatingDiffKey() => string('WhiteRatingDiff').trim();
  Parser blackRatingDiffKey() => string('BlackRatingDiff').trim();
  Parser whiteFideIdKey() => string('WhiteFideId').trim();
  Parser blackFideIdKey() => string('BlackFideId').trim();
  Parser whiteTeamKey() => string('WhiteTeam').trim();
  Parser blackTeamKey() => string('BlackTeam').trim();
  Parser anyKey() => ref0(stringNoQuot);

  Parser ws() => (char(' ') | char('\t') | char('\n') | char('\r')).star();
  Parser wsp() => (char(' ') | char('\t') | char('\n') | char('\r')).plus();
  Parser eol() => (char('\n') | char('\r')).plus();

  Parser stringP() =>
      ref0(quotationMark) & ref0(charP).star() & ref0(quotationMark);

  Parser stringNoQuot() => pattern("-a-zA-Z0-9.").trim().star();

  Parser quotationMark() => char('"').trim();

  Parser charP() => pattern("^\x22\x5C");

  Parser dateDigit() => pattern('0-9').trim() | char('?').trim();

  Parser date() =>
      ref0(quotationMark) &
      (ref0(dateDigit) & ref0(dateDigit) & ref0(dateDigit) & ref0(dateDigit))
          .flatten() &
      char('.').trim() &
      (ref0(dateDigit) & ref0(dateDigit)).flatten() &
      char('.').trim() &
      (ref0(dateDigit) & ref0(dateDigit)).flatten() &
      ref0(quotationMark);

  Parser time() =>
      ref0(quotationMark) &
      digit().plus().flatten() &
      char(':').trim() &
      digit().plus().flatten() &
      char(':').trim() &
      digit().plus().flatten() &
      ref0(quotationMark);

  Parser timeControl() =>
      ref0(quotationMark) & ref0(tcnq) & ref0(quotationMark);

  Parser tcnq() =>
      char('?').trim() |
      char('-').trim() |
      ref0(integer) & char('/').trim() & ref0(integer) |
      ref0(integer) & char('+').trim() & ref0(integer) |
      ref0(integer) |
      char('*').trim() & ref0(integer);

  Parser result() =>
      ref0(quotationMark) & ref0(innerResult) & ref0(quotationMark);
  Parser innerResult() =>
      string("1-0").trim() |
      string("0-1").trim() |
      string("1/2-1/2").trim() |
      char('*').trim();

  Parser integerOrDash() =>
      ref0(integerString) |
      ref0(quotationMark) & char('-').trim() & ref0(quotationMark);

  Parser integerString() =>
      ref0(quotationMark) & digit().plus().flatten() & ref0(quotationMark);

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
          string("%csl").trim() &
          ref0(wsp) &
          ref0(colorFields) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star() |
      ref0(ws) &
          ref0(bl) &
          string("%cal").trim() &
          ref0(wsp) &
          ref0(colorArrows) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star() |
      ref0(ws) &
          ref0(bl) &
          char("%").trim() &
          ref0(clockCommand) &
          ref0(wsp) &
          ref0(clockValue) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star() |
      ref0(ws) &
          ref0(bl) &
          string("%eval").trim() &
          ref0(wsp) &
          ref0(stringNoQuot) &
          ref0(ws) &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star() |
      ref0(ws) &
          ref0(bl) &
          char("%").trim() &
          ref0(stringNoQuot) &
          ref0(wsp) &
          ref0(nbr).plus() &
          ref0(br) &
          ref0(ws) &
          ref0(innerComment).star() |
      ref0(nonCommand).plus() & ref0(innerComment).star();

  Parser nonCommand() =>
      string("[%").trim().not() & char('}').trim().not() & any();

  Parser nbr() => ref0(br).not() & any();

  Parser commentEndOfLine() =>
      ref0(semicolon) & pattern('^\r\n').trim().star() & ref0(eol);

  Parser colorFields() =>
      ref0(colorField) &
      ref0(ws) &
      (char(',').trim() & ref0(ws) & ref0(colorField)).star();

  Parser colorField() => ref0(color) & ref0(field);
  Parser colorArrows() =>
      ref0(colorArrow) &
      ref0(ws) &
      (char(',').trim() & ref0(ws) & ref0(colorArrow)).star();

  Parser colorArrow() => ref0(color) & ref0(field) & ref0(field);
  Parser color() =>
      char('Y').trim() | char('G').trim() | char('R').trim() | char('B').trim();

  Parser field() => ref0(column) & ref0(row);

  Parser cl() => char('{').trim();
  Parser cr() => char('}').trim();
  Parser bl() => char('[').trim();
  Parser br() => char(']').trim();
  Parser semicolon() => char(';').trim();

  Parser clockCommand() =>
      string('clk').trim() |
      string('egt').trim() |
      string('emt').trim() |
      string('mct').trim();
  Parser clockValue() =>
      digit() &
      digit().optional() &
      char(':').trim() &
      digit() &
      digit() &
      char(':').trim() &
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

  Parser pl() => char('(').trim();
  Parser pr() => char(')').trim();

  Parser moveNumber() =>
      ref0(integer) & ref0(whiteSpace).star() & ref0(dot).star();
  Parser dot() => char('.').trim();
  Parser integer() => digit().plus().flatten();
  Parser whiteSpace() => char(' ').trim();

  Parser halfMove() =>
      ref0(figure).optional() &
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
      string('O-O-O').trim() & ref0(check).optional() |
      string('O-O').trim() & ref0(check).optional() |
      ref0(figure) & char('@').trim() & ref0(column) & ref0(row);

  Parser check() =>
      char('+').trim() |
      char('#').trim();
  Parser promotion() => char('=').trim() & ref0(promFigure);

  Parser nags() => ref0(nag) & ref0(ws) & ref0(nags).optional();

  Parser nag() =>
      (char('\$').trim() & ref0(integer)) |
      string('!!').trim() |
      string('??').trim() |
      string('!?').trim() |
      string('?!').trim() |
      char('!').trim() |
      char('?').trim() |
      char('‼').trim() |
      char('⁇').trim() |
      char('⁉').trim() |
      char('⁈').trim() |
      char('□').trim() |
      char('=').trim() |
      char('∞').trim() |
      char('⩲').trim() |
      char('⩱').trim() |
      char('±').trim() |
      char('∓').trim() |
      string('+-').trim() |
      string('-+').trim() |
      char('⨀').trim() |
      char('⟳').trim() |
      char('→').trim() |
      char('↑').trim() |
      char('⇆').trim() |
      char('D').trim();

  Parser discriminator() => ref0(column) | ref0(row);

  Parser figure() =>
      char('R').trim() |
      char('N').trim() |
      char('B').trim() |
      char('Q').trim() |
      char('K').trim() |
      char('P').trim();

  Parser promFigure() =>
      char('R').trim() | char('N').trim() | char('B').trim() | char('Q').trim();
  Parser column() => pattern('a-h').trim();
  Parser row() => pattern('1-8').trim();
  Parser strike() => char('x').trim();
  Parser strikeOrDash() => char('x').trim() | char('-').trim();
}
