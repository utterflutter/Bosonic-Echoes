s.boot;
s.scope;
s.freqscope;

//receiving measured state from python



(
// SynthDef for chords
SynthDef(\chordPlayer, { |freqs = #[440], amp = 0.3|
    var env = EnvGen.kr(Env.perc(0.01, 1.8), doneAction: 2);
	var sig = Mix(SinOsc.ar(freqs + Saw.ar(11, mul:18))) * env * amp;
    Out.ar(0, Pan2.ar(sig, 0));
}).add;


// Mapping state strings to chords
~stateToChordMap = Dictionary.new;

~stateToChordMap.put([0, 0, 0, 0], nil);            // Silence
~stateToChordMap.put([0, 0, 0, 1], [62]);
~stateToChordMap.put([0, 0, 1, 0], [67]);
~stateToChordMap.put([0, 0, 1, 1], [67, 62]);
~stateToChordMap.put([0, 1, 0, 0], [60]);
~stateToChordMap.put([0, 1, 0, 1], [60, 62]);
~stateToChordMap.put([0, 1, 1, 0], [60, 67]);
~stateToChordMap.put([0, 1, 1, 1], [60, 67, 62]);
~stateToChordMap.put([1, 0, 0, 0], [53]);
~stateToChordMap.put([1, 0, 0, 1], [53, 62]);
~stateToChordMap.put([1, 0, 1, 0], [53, 67]);
~stateToChordMap.put([1, 0, 1, 1], [53, 67, 62]);
~stateToChordMap.put([1, 1, 0, 0], [53, 60]);
~stateToChordMap.put([1, 1, 0, 1], [53, 60, 62]);
~stateToChordMap.put([1, 1, 1, 0], [53, 60, 67]);
~stateToChordMap.put([1, 1, 1, 1], [53, 60, 67, 62]);


)


(
// OSC handler
OSCdef(\measuredStateToChord, { |msg|
    var rawStr, stateArray, freqs;

    rawStr = msg[1].asString; // msg[1] is like "(1, 0, 1, 0)"
	"Receiving state: %".format(rawStr).postln;

    // Remove parentheses and split by comma
    stateArray = rawStr
        .copyRange(1, rawStr.size - 2) // removes "(" and ")"
        .split($,)                     // split at commas
        .collect { |s| s.tr.asInteger }; // remove spaces and convert to int

    "Parsed state: %".format(stateArray).postln;

    freqs = ~stateToChordMap[stateArray];

    if (freqs.notNil) {
		Routine({
			freqs.do { |midi, i|
            var freq = midi.midicps;
				 Synth(\chordPlayer, [\freqs, [freq], \amp, 0.8]);
            rrand(0.06, 0.12).wait; // wait time between notes – adjust as needed
        };
    }).play;

        "Playing chord for state %: MIDI %".format(stateArray, freqs).postln;
    } {
        "No chord mapped for state %".format(stateArray).warn;
    };
}, "/measured_state");
)

//Stop the sound
OSCdef(\measuredStateToChord).free;