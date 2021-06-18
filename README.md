# Chess Pgn Reviser

Load your chess PGN file and try to find moves (from your side).

## Developpers

Do not forget to generate locals

$> `flutter packages pub run build_runner build`

You may need to clear existing files before (if you encounter some errors)

$> `flutter clean`

$> `flutter packages pub get`

## Credits

Using some pictures from flaticon.com:
* red_cross : downloaded at https://www.flaticon.com/free-icon/cancel_1168643 and designed by FreePik,
* race_flag : downloaded at https://www.flaticon.com/free-icon/racing-flag_1505471 and designed by SmashIcons
* first_item : downloaded at https://www.flaticon.com/free-icon/arrowheads-of-thin-outline-to-the-left_32766 and designed by FreePik
* previous_item : downloaded at https://www.flaticon.com/free-icon/black-triangular-arrowhead-pointing-to-left-direction_45050 and designed by FreePik
* last_item : downloaded at https://www.flaticon.com/free-icon/right-thin-arrowheads_32738 and designed by FreePik
* next_item : downloaded at https://www.flaticon.com/free-icon/right-triangular-arrowhead_44452 and designed by FreePik
* reverse_arrows : downloaded at https://www.flaticon.com/free-icon/arrows_685838 and designed by Good Ware
* stop : downloaded at https://www.flaticon.com/free-icon/stop_827428 and designed by SmashIcons

Adapted PGN PEG rules at https://github.com/mliebelt/pgn-parser/blob/master/src/pgn-rules.pegjs from project [pgn-parser](https://github.com/mliebelt/pgn-parser/blob/master/src/pgn-rules.pegjs), which is release under Apache License 2.0 (even if some elements - specially special kind of comments - have been removed).

FreeSerif font downloaded from https://fr.fonts2u.com/free-serif.police