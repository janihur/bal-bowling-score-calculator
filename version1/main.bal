import ballerina/io;

const STRIKE = "X";
const SPARE = "/";
const MISS = "-";

type Roll STRIKE|SPARE|MISS|int;

type Frame record  {|
    readonly int number;
    Roll? roll1;
    Roll? roll2;
    Roll? roll3;
    int? score;
|};

public function main(string rollsFile) returns error? {
    string[] lines = checkpanic io:fileReadLines(rollsFile);
    foreach var line in lines {
        io:println("calculating total score of game:");
        io:println(line);

        table<Frame> key (number) frames = table [];

        // --------------------------------------------------------------------
        // 1/3 parsing

        string[] framesStr = re` `.split(line);
        
        // io:println(framesStr);

        foreach string frameRolls in framesStr {
            if (frameRolls == "") {
                continue;
            }

            Frame frame = {number: frames.length() + 1, roll1: 0, roll2: (), roll3: (), score: ()};
            match frameRolls.length() {
                1 => { // frame 1-9: strike
                    frame.roll1 = toRoll(frameRolls);
                }
                2 => { // frame 1-9: anything but strike
                    frame.roll1 = toRoll(frameRolls[0]);
                    frame.roll2 = toRoll(frameRolls[1]);
                }
                3 => { // 10th frame
                    frame.roll1 = toRoll(frameRolls[0]);
                    frame.roll2 = toRoll(frameRolls[1]);
                    frame.roll3 = toRoll(frameRolls[2]);
                }
            }
            
            frames.add(frame);
        }
        
        // --------------------------------------------------------------------
        // 2/3 scoring

        foreach var frame in frames {
            if frame.number < 10 { // frames 1-9
                if frame.roll1 is STRIKE {
                    Frame nextFrame1 = <Frame>frames[frame.number + 1];
                    Frame nextFrame2 = <Frame>frames[frame.number + 2];

                    frame.score = rollScore(STRIKE);
                    if nextFrame1.roll1 == STRIKE {
                        frame.score = frame.score + rollScore(STRIKE) + rollScore(nextFrame2.roll1);
                    } else {
                        frame.score = frame.score + frameScore(nextFrame1);
                    }
                } else if frame.roll2 is SPARE {
                    Frame nextFrame = <Frame>frames[frame.number + 1];
                    frame.score = frameScore(frame) + rollScore(nextFrame.roll1);
                }
            } else { // 10th frame
                frame.score = frameScore(frame);
            }
            frames.put(frame);
        }

        // foreach var frame in frames {
        //     io:println(frame);
        // }
        
        // --------------------------------------------------------------------
        // 3/3 total score

        final int totalScore = frames.reduce(
            function(int accu, Frame frame) returns int => accu + frame.score ?: 0,
            0
        );
        io:println("total score: ", totalScore);
    }
}

function toRoll(string str) returns Roll {
    match str {
        "X"|"/"|"-" => { return <Roll>str; }
        "1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"=> {
            int|error pinsDown = int:fromString(str);
            return pinsDown is int ? <Roll>pinsDown : "-";
        }
        // TODO: this should be a parsing error instead
        _ => { return "-"; }
    }
}

function rollScore(Roll? roll) returns int {
    // TODO: evaluating spare here is a bug, raise error if happens
    if roll is STRIKE {return 10; }
    if roll is int { return roll; }
    return 0;
}

function frameScore(Frame frame) returns int {
    // TODO: a bug - frame 10 can be open after two rolls so no third roll
    if frame.roll3 is () { // frames 1-9
        if frame.roll1 is STRIKE { return 10; }
        if frame.roll2 is SPARE { return 10; }
        return rollScore(frame.roll1) + rollScore(frame.roll2);
    } else { // 10th frame
        if frame.roll2 is SPARE { return 10 + rollScore(frame.roll3); }
        if frame.roll3 is SPARE { return rollScore(frame.roll1) + 10; }
        return rollScore(frame.roll1) + rollScore(frame.roll2) + rollScore(frame.roll3);
    }
}