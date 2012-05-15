(
~buffers = "/Users/alo/sounds/funkt/frag*".pathMatch.collect({|path| Buffer.read(s, path)  });

~decoder = FoaDecoder();

~envs = (
	sine00: Env.sine,
	sine01: Env([0, 1, 1, 0], [0.2, 0.6, 0.2], \sine),
	sine02: Env([0, 1, 1, 0], [0.3, 0.4, 0.3], \sine),
	perc00: Env.perc,
	perc01: Env.perc(0.1, 0.9, 1, 4),
	perc02: Env.perc(0.005, 1, 1, -16),
	perc03: Env.perc(curve: 0),
	lin00: Env([0, 1, 1, 0], [0.3, 0.4, 0.3]),
	lin01: Env([0, 1, 1, 0], [0, 1, 0]),
	step00: Env([0, 1, 0.3, 0.8, 0], (1/4!4), \step),
	step01: Env([0, 1, 0.5, 1, 0.5, 1, 0], (1/6!6), \step),
	wlch00: Env([0.001, 0.5, 0.4, 1.0, 0.001], [0.2, 0.3, 0.3, 0.2], \welch),
	wlch01: Env([0.001, 1, 0.3, 0.8, 0.001], [0.3, 0.3, 0.1, 0.3], \welch),
	gate00: Env([0, 1, 1, 0], [0, 1, 0], \lin, 2, 1),
	default: Env([1, 1, 0], [1, 0])
).collect(_.asArray).collect(_.bubble);

SynthDef(\frag00, {|out, gate = 1, buf, rate, loop=0, dur, ffrq, fflo, ffhi, amp=1, rotx, roty, rotz, done=2|
	var sig, enc, env;
	env = EnvGen.kr(EnvControl.kr, gate, timeScale: dur, levelScale: amp, doneAction: done);
	sig = PlayBuf.ar(1, buf, rate, loop: loop, doneAction: done) * LocalIn.ar * LFPulse.kr(ffrq).range(fflo, ffhi) * env;
	LocalOut.ar(sig);
	enc = FoaEncode.ar(sig, FoaEncoderMatrix.newDirection);
	enc = FoaTransform.ar(enc, 'rtt', rotx, roty, rotz );
	Out.ar(out, enc);
}).add;

SynthDef(\frag01, {|out, gate = 1, buf, rate, loop=0, ffrq, fwid, fflo, ffhi, walo, wahi, dur, amp, rotx, roty, rotz, done=2|
	var env, sig, fft, enc;
	env = EnvGen.kr(EnvControl.kr, gate, timeScale: dur, levelScale: amp, doneAction: done);
	sig = PlayBuf.ar(1, buf, rate, loop: loop) * LFPulse.kr(ffrq, 0, fwid).range(fflo, ffhi) * env;
	fft = FFT(LocalBuf(1024), sig);
	fft = PV_Freeze(fft, LFPulse.kr(ffrq, 0, fwid).range(0, 1));
	fft = PV_BrickWall(fft, Line.kr(walo, wahi, dur));
	enc = FoaEncode.ar(IFFT.ar(sig), FoaEncoderMatrix.newDirection);
	enc = FoaTransform.ar(enc, 'rtt', rotx, roty, rotz );
	Out.ar(out, enc)
}).add;

SynthDef(\frag02, {|out, gate = 1, buf, rate, warp, wisz, genv, wrnd, dens, intr, ffrq, fwid, fflo, ffhi, amp=1, dur, rotx, roty, rotz, done=2|
	var env, sig, fft, enc;
	env = EnvGen.kr(EnvControl.kr, timeScale: dur, levelScale: amp, doneAction: done);
	sig = Warp1.ar(1, buf, LFSaw.kr(warp, 1).range(0, 1), rate, wisz, genv, dens, wrnd, intr) 
		* LFPulse.kr(ffrq, 0, fwid).range(fflo, ffhi) * env;
	enc = FoaEncode.ar(sig, FoaEncoderMatrix.newDirection);
	enc = FoaTransform.ar(enc, 'rtt', rotx, roty, rotz );
	Out.ar(out, enc);
}).add;

SynthDef(\frag03, {|out, buf, rate, loop=0, ffrq, fwid, fflo, ffhi, rmsz, revt, scsl=0, walo, wahi, amp=1, dur, rotx, roty, rotz, done=2|
	var env, sig, dwt, enc;
	env = EnvGen.kr(EnvControl.kr, timeScale: dur, levelScale: amp, doneAction: done);
	sig = PlayBuf.ar(1, buf, rate, loop: loop) * LFPulse.kr(ffrq, 0, fwid).range(fflo, ffhi) * env;
	sig = Mix(GVerb.ar(sig, rmsz, revt));
	dwt = WT_Freeze(DWT(LocalBuf(1024), sig), LFPulse.kr(ffrq, 0, fwid).range(0, 1), scsl);
	dwt = WT_FilterScale(dwt, Line.kr(walo, wahi, dur));
	enc = FoaEncode.ar(IDWT(dwt), FoaEncoderMatrix.newDirection);
	enc = FoaTransform.ar(enc, 'rtt', rotx, roty, rotz );
	Out.ar(out, enc);
}).add;

)

~player = Ppar(
	8.collect({|i|
		Pbind(\instrument, \frag00, \buf, ~buffers[i], )
	})
).play;

~player.stop

SynthDef(\nz, {|fr, am, gate=1|
	Out.ar(0, BPF.ar(Reverb.ar(Dust2.ar(fr, am)), fr, 10/fr, 10) * EnvGen.kr(Env([0, 1, 1, 0], [0, 1, 0], \lin, 2, 1), gate, doneAction: 2))
}).add;

x = Synth(\nz, [\fr, 200, \am, 0.5])
x.set(\gate, -3)

Pdef(\nz01, 
	Plambda(
		Pbind(\instrument, \nz, \delta, 1, \seq, Pseq([1, 0, 0, 0], inf),
			\type, Pget(\status, \rest, inf), \fr, Pseq([250, 500, 1000], inf), \aha, Plet(\status),
			\am, 0.5, \id, s.nextNodeID 
		)
	)
).play

Pdef(\nz01).stop
Pdef(\nz01).clear

x=Pchain(Pbind(\frq, Pseq([100, 200, 300], inf)), Penvir((status: \off, tag: \envir01),
	Pbind(\seq, Pseq([1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0], inf), \name, Pfunc({ ~tag }),
		\type, Pfunc({|ev| 
			if (ev.seq == 1) { if (~status == \off) { ~status = \on } { ~status = \off }  } { \rest } 
		})
	)
)).asStream


a=Pchain(
	Pbind(\name, \a, \freq, Pseq((1..4)*100, inf), \delta, 0.5),
	Penvir((status: \off, tag: \envir01),
		Pbind(\seq, Pseq([0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0], inf), \tag, Pfunc({ ~tag }),
			\type, Pfunc({|ev| 
				if (ev.seq == 1) { if (~status == \off) { ~status = \on } { ~status = \off }  } { \rest } 
			})
		)
	)
);

b=Pchain(
	Pbind(\name, \b, \freq, Pseq((1..4)*1000, inf), \delta, 0.5),
	Penvir((status: \off, tag: \envir02),
		Pbind(\seq, Pseq([1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0], inf), \tag, Pfunc({ ~tag }),
			\type, Pfunc({|ev| 
				if (ev.seq == 1) { if (~status == \off) { ~status = \on } { ~status = \off }  } { \rest } 
			})
		)
	)
);

x = Ppar([b, a])

t = x.asStream

t.next(Event.default)

(
~frag = Pdef(\frag00, 
Ppar([	
	~fragPatterns.collect({|args, name|
		Pchain(
			Pbind(\instrument, \frag00, \out, ~decoder.bus, \group, ~grp, \addAction, \addToHead, 
				\delta, Pfunc({ ~beatdur / 4 }), \buf, ~fragBufs[name], \env, ~envs.gate00, 
				\amp, Pfunc({ ~fragControls[name].amp }), \delta, Pfunc({ ~beatdur }),
				\rate, 1.0, \loop, 1, \dur, 1, \ffhi, 1, 
				\fflo, Pseg(Pseq([0.2, 0.5, 0.2], 1), Pseq([2, 4, 2, 3], inf), \linear, inf),
				\ffrq, Pseq([2, 4, 6], inf) * Pfunc({ ~beatdur.reciprocal * 4 }),
				\rotx, ~rDB.r06, \roty, ~rDB.r06, \rotz, ~rDB.r06
			),
			Penvir((status: \off), Pbind(
				\seq, Pseq(~fragPatterns[name], inf), 
				\type, Pfunc({|ev| 
					if (ev.seq == 1)  { 
						if (~status == \off) 
							{ ~status = \on } 
							{ ~status = \off }  
					} { \rest }  
				}))
			)
		)
	}).values
]).trace
)
)

~fragControls[\p00].active = 1

~fragControls[\p00].amp = 1.0

Pdef(\player, Ppar([Pdef(\frag00)])).play

Pdef(\player).stop
Pdef(\player).clear

x = ~frag.asStream

x.next(Event.default)

~fkey = \p00;

~frag = Pchain(
	Pbind(\instrument, \frag00, \out, ~decoder.bus, \group, ~grp, \addAction, \addToHead, 
		\delta, Pfunc({ ~beatdur / 4 }), \buf, ~fragBufs[~fkey], \env, ~envs.gate00, 
		\amp, Pfunc({ ~fragControls[~fkey].amp }), \delta, Pfunc({ ~beatdur }),
		\rate, 1.0, \loop, 1, \dur, 1, \ffhi, 1, 
		\fflo, Pseg(Pseq([0.2, 0.5, 0.2], 1), Pseq([2, 4, 2, 3], inf), \linear, inf),
		\ffrq, Pseq([2, 4, 6], inf) * Pfunc({ ~beatdur.reciprocal * 4 }),
		\rotx, ~rDB.r06, \roty, ~rDB.r06, \rotz, ~rDB.r06
	).trace,
	Penvir((status: \off), Pbind(
		\seq, Pseq(~fragPatterns[~fkey], inf), 
		\type, Pfunc({|ev| 
			if (ev.seq == 1)  { 
				if (~status == \off) 
					{ ~status = \on } 
					{ ~status = \off }  
			} { \rest }  
		}))
	)
)	

Pdef(\player, ~frag).play


s.queryAllNodes

s.sendMsg("/n_free", 1005)
