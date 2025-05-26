s.boot;
s.scope(4);
s.freqscope;


// Always boot the server first ;)
Server.local.boot;



ServerOptions.devices;

s.options.device = "Scarlett 4i4 4th Gen";

s.options.inDevice = "Scarlett 4i4 4th Gen";
s.options.outDevice = "Scarlett 4i4 4th Gen";

s.options.outDevice = "MacBook Pro Speakers";

s.options.numInputBusChannels = 4;
s.options.numOutputBusChannels = 4;

s.options.numInputBusChannels;
s.options.numOutputBusChannels;

s.reboot;

s.meter;

s.boot;

///


//receiving measured state from python
(


// SynthDef for chords
SynthDef(\chordPlayer, { |freqs = #[440], amp = 0.3, out = 0|
    var env = EnvGen.kr(Env.perc(0.01, 1.8), doneAction: 2);
	var sig = SinOsc.ar(freqs) * env * amp;
    Out.ar(out, sig);
}).add;



// Mapping state strings to chords
~stateToChordMap = Dictionary.new;

~stateToChordMap.put([0, 0, 0, 0], nil);            // Silence

//CH1 & 2
~stateToChordMap.put([0, 1, 0, 0], [60]);
~stateToChordMap.put([1, 0, 0, 0], [53]);

~stateToChordMap.put([0, 0, 0, 1], [62]);
~stateToChordMap.put([0, 0, 1, 0], [67]);

~stateToChordMap.put([0, 0, 1, 1], [67, 62]);

~stateToChordMap.put([0, 1, 0, 1], [60, 62]);
~stateToChordMap.put([0, 1, 1, 0], [60, 67]);
~stateToChordMap.put([0, 1, 1, 1], [60, 67, 62]);

~stateToChordMap.put([1, 0, 0, 1], [53, 62]);
~stateToChordMap.put([1, 0, 1, 0], [53, 67]);
~stateToChordMap.put([1, 0, 1, 1], [53, 67, 62]);
~stateToChordMap.put([1, 1, 0, 0], [53, 60]);
~stateToChordMap.put([1, 1, 0, 1], [53, 60, 62]);
~stateToChordMap.put([1, 1, 1, 0], [53, 60, 67]);
~stateToChordMap.put([1, 1, 1, 1], [53, 60, 67, 62]);

~midiToChannel = IdentityDictionary.newFrom([
    53, 0,
    60, 1,
    67, 2,
    62, 3
]);


)


(
s.waitForBoot {
    var oscPort = 57120; // or whatever port you use

(
OSCdef(\measuredStateToChord, { |msg|
    var rawStr, stateArray, freqs;

    rawStr = msg[1].asString;
    "Receiving state: %".format(rawStr).postln;

    stateArray = rawStr
        .copyRange(1, rawStr.size - 2)
        .split($,)
        .collect { |s| s.tr.asInteger };

    "Parsed state: %".format(stateArray).postln;

    freqs = ~stateToChordMap[stateArray];

    if (freqs.notNil) {
        Routine({
            freqs.do { |midi|
                var freq = midi.midicps;
                var out = ~midiToChannel[midi];
                if (out.notNil) {
                    Synth(\chordPlayer, [\freqs, freq, \amp, 0.6, \out, out]);
                };
                rrand(0.06, 0.12).wait;
            };
        }).play;

        "Playing chord for state %: MIDI %".format(stateArray, freqs).postln;
    } {
        "No chord mapped for state %".format(stateArray).warn;
    };
}, "/measured_state", nil, 8888);
)


};
)


//Stop the sound
OSCdef(\measuredStateToChord).free;


// Test each output channel
Synth(\chordPlayer, [\freqs, 53.midicps, \out, 0]); // speaker 1
Synth(\chordPlayer, [\freqs, 60.midicps, \out, 1]); // speaker 2
Synth(\chordPlayer, [\freqs, 67.midicps, \out, 2]); // speaker 3
Synth(\chordPlayer, [\freqs, 62.midicps, \out, 3]); // speaker 4

