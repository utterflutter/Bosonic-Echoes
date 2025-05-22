// Always boot the server first ;)
Server.local.boot;



ServerOptions.devices;

s.options.device = "Scarlett 4i4 4th Gen";

s.options.inDevice = "Scarlett 4i4 4th Gen";
s.options.outDevice = "Scarlett 4i4 4th Gen";

s.options.numInputBusChannels = 4;
s.options.numOutputBusChannels = 4;

s.options.numInputBusChannels;
s.options.numOutputBusChannels;

s.reboot;

s.meter;

s.boot;

///

(
s.scope(4);
s.freqscope;


b = Buffer.alloc(s, 2048);

// Define your point values
~pt1 = 1;
~pt2 = 0.1;
~pt3 = 0.1;
~pt4 = 0.1;

// Define a function to generate the wavetable
~generateWavetable = {
	var sig = Signal.sineFill(
		1024,
		[~pt1, ~pt2, ~pt3, ~pt4],
		0!4
	);
	sig.asWavetable;
};

// Generate wavetable
~wt = ~generateWavetable.();

b.loadCollection(~wt);

SynthDef(\wavetableSynth, {
	arg out=0, freq=87, amp=1, buf=0, phase=0, mul=1, lpr=1000, hpr=100, pt1=0.1, pt2=0.1, pt3=0.1, pt4=0.1;
	var sig, mod, outs, ch1, ch2, ch3, ch4;
	mod = SinOsc.kr(pt4*10).range(1, 1.001);

	// Use Osc for wavetable playback
	sig = Osc.ar(buf, (freq * mod), phase, mul);
	sig = LPF.ar(sig, lpr);
	sig = HPF.ar(sig, hpr);
	sig = sig * amp;

	// Sends to channels 0–3 varying amp
	ch1 = sig * pt1;
	ch2 = sig * pt2;
	ch3 = sig * pt3;
    ch4 = sig * pt4;

	Out.ar(0, ch1); // Speaker 1
    Out.ar(1, ch2); // Speaker 2
    Out.ar(2, ch3); // Speaker 3
    Out.ar(3, ch4); // Speaker 4

}).add;
)

//activate drone
x = Synth(\wavetableSynth, [\buf, b.bufnum]);

(
// 2. OSCdef for current_channel_probs
OSCdef(\recvProbs, { |msg, time, addr|
    var probs = msg.asArray.drop(1);

	"Receiving channels: %".format(probs).postln;

	~pt1 = probs[0]; // Modify harmonic amplitudes
	~pt2 = probs[1];
	~pt3 = probs[2];
	~pt4 = probs[3];

	// Regenerate and reload wavetable
~wt = ~generateWavetable.();
b.loadCollection(~wt);

		x.set(
			\phase, ~pt1,
			\mul, ~pt3,
			\lpr, 1000 * ~pt2,
			\hpr, 100 * ~pt4,
			\pt1, ~pt1,
			\pt2, ~pt2,
			\pt3, ~pt3,
			\pt4, ~pt4,
			\amp, 0.55);

	}, '/current_channel_probs', nil, 8888);

)

//check the waveform changes graphically
b.plot;

//stop drone sound
x.free;



//x.set(\pt1, 1.0, \pt2, 0.5, \pt3, 0.2, \pt4, 0.1);


//////////////////////////////////////////////////////////////////////////////

