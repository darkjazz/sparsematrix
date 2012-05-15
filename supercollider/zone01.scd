SynthDef(\rwarpfld, {|out, efx, amp, aamp, eamp, dur, buf, str, end, wrp, frq, wsz, dns, rnd, xfoc, yfoc, zfoc, xang, yang, zang, doneAction = 2|
	var ptr, sig, env, bf, del, a, b, c, d;
	env = Env([0.001,1.0,1.0,0.001],[0.001,1.0,0.001],\sine,2,1);
	del = [0.0, 0.001, 0.002, 0.003];		
	ptr = LFSaw.kr(wrp).range(str, end);
	sig = LeakDC.ar(Warp1.ar(1, buf, ptr, frq, wsz, -1, dns, rnd)) * 
		EnvGen.kr(env, timeScale: dur, doneAction: doneAction);
	sig = LeakDC.ar(sig ** 0.5);
	Out.ar(efx, sig * eamp);
	sig = Array.fill(4, {|i|
		DelayC.ar(sig, delaytime: del@i)
	});
	a = BLowShelf.ar(FoaEncode.ar(sig@0, FoaEncoderMatrix.newDirection), 100.0, 0.65, 0.0);
	b = BPeakEQ.ar(FoaEncode.ar(sig@1, FoaEncoderMatrix.newDirection), 600.0, 2.0, 0.0 );
	c = BPeakEQ.ar(FoaEncode.ar(sig@2, FoaEncoderMatrix.newDirection), 2000.0, 2.0, 0.0 );
	d = BHiShelf.ar(FoaEncode.ar(sig@3, FoaEncoderMatrix.newDirection), 7500.0, 1, 0.0 );
	bf = FoaTransform.ar(Array.with(a, b, c, d), 'focus', xfoc, yfoc, zfoc);
	Out.ar(out, FoaTransform.ar(bf, 'rtt', xang, yang, zang) * aamp * amp)
}).add;


~zone01bufs = "/Users/alo/sounds/fx_loops/det*".pathMatch.collect({|path|
	Buffer.read(Server.default, path)
});

~zone01ctrls = 8.collect({ (amp: 0) });

~zone01specs = (
	\aamp: ControlSpec(0.1, 5.0, \lin),
	\str: ControlSpec(0.0, 0.5),
	\end: ControlSpec(0.5, 1.0),
	\eamp: ControlSpec(8.0, 1.0),
	\frq: ControlSpec((35/36)**2, (35/36)**2, 'lin', 36/35),
	\xang: ControlSpec(-pi, pi),
	\yang: ControlSpec(-pi, pi),
	\zang: ControlSpec(-pi, pi), 
	\xfoc: ControlSpec(pi/4, -pi/4),
	\yfoc: ControlSpec(pi/4, -pi/4),
	\zfoc: ControlSpec(pi/4, -pi/4)
);

~decoder = FoaDecoder(false, 'stereo');
~grp = Group()


~decoder.start(~decoder.synth, \addAfter)

~synth = Synth.head(~grp, \rwarpfld, [\out, ~decoder.bus, \amp, 1, \dur, 8, \buf, ~zone01bufs[0],
			\wsz, 0.1, \dns, rrand(2, 10), \rnd, 0.01, \gate, 1.0,
		 	\aamp, 0.5, \str, 0, \end, 1.0, \eamp, 0, \frq, 1, 
			\xang, 0, \yang, 0, \zang, 0, \xfoc, 0, \yfoc, 0, \zfoc, 0,
			\doneAction, 2]
			
			
)
~synth.free

(
Pdef(\zone01, Ppar(
	8.collect({|i|
		Pbind(\instrument, \rwarpfld, \out, ~decoder.bus, \group, ~grp, \addAction, \addToHead, 
			\amp, 1.0, \dur, 8, \buf, ~zone01bufs[i],
			\wsz, 0.1, \dns, rrand(2, 10), \rnd, 0.01, \gate, 1.0, \wrp, 0.1,
			\delta, 4, \aamp, 0.5, \str, 0, \end, 1.0, \eamp, 0, \frq, 1, 
			\xang, 0, \yang, 0, \zang, 0, \xfoc, 0, \yfoc, 0, \zfoc, 0,
			\doneAction, 2
		)	
	})
))

)


Pdef(\player, Ppar([Pdef(\zone01)])).play

~zone01ctrls.do({|ev|
	ev.amp = 1
});


Pdef(\player).stop

s.queryAllNodes

~grp.free

~decoder.free

