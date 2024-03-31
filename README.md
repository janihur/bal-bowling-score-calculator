# 10 Pin Bowling Score Calculator

Scoring rules (traditional rules):
* https://en.wikipedia.org/wiki/Ten-pin_bowling#Pins_and_scoring
* http://www.fryes4fun.com/Bowling/scoring.htm

Used Ballerina version:
```
$ bal version
Ballerina 2201.8.6 (Swan Lake Update 8)
Language specification 2023R1
Update Tool 1.4.2
```

## Version 1

Reads list of score sheets from a file and calculates total score for each sheet. Includes several know (and unknown) bugs.

Usage:
```
bal run -- ../score-sheets
```

### TODO

* 10th frame will remain open (i.e. only two rolls allowed) if not all 10 pins were not knocked down during the first 2 shots.

## Scoring Examples

The calculator supports the following score sheet syntax:
* `1-9`: knocked down pins
* `X`: strike
* `/`: spare
* `-`: miss
* whitespace: frame separator

|Score|Rolls                           |
|-----|--------------------------------|
|300  |`X  X  X  X  X  X  X  X  X  XXX`|
|255  |`X  X  X  X  X  X  X  X  5/ 5/5`|
|195  |`X  X  X  X  5/ 5/ 5/ 5/ 5/ 5/5`|
|150  |`5/ 5/ 5/ 5/ 5/ 5/ 5/ 5/ 5/ 5/5`|
|149  |`8/ 54 9- X  X  5/ 53 63 9/ 9/X`|
| 90  |`9- 9- 9- 9- 9- 9- 9- 9- 9- 9- `|
| 50  |`5- 5- 5- 5- 5- 5- 5- 5- 5- 5- `|
|  0  |`-- -- -- -- -- -- -- -- -- -- `|
