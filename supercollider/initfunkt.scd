{
~frags = "/Users/alo/sounds/funkt/frag*".pathMatch.collect({|path| Buffer.read(s, path)  });

~bits = "/Users/alo/sounds/funkt/bit*".pathMatch.collect({|path| Buffer.read(s, path)  });

~decoder = FoaDecoder(~localDecoder ? true, ~decoderType ? 'quad');

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

(Document.current.dir +/+ "funktdefs.scd").load;

Server.default.sync;

~grp = Group();
~efxgrp = Group.after(~grp);
~nofxbus = Server.default.options.numAudioBusChannels-1;

~decoder.start(~efxgrp, \addAfter);

Server.default.sync;

~mfcc = Synth.before(~decoder.synth, \mfcc, [\in, ~decoder.bus, \th, -6.dbamp]);

//~makePdefn = {|name, seq| Pdefn(name, Pseq(seq.replace(0, \rest).replace(1, \note), inf)).count(seq.size)  };

~makePattern = {|name, seq, rpt|  
	rpt = rpt ? [1];
	Pdefn(name, 
		Pseq(seq.collect({|arr, i| Pseq(arr.replace(0, \rest).replace(1, \note), rpt.wrapAt(i)) }), inf)
	).count(seq.size * seq.first.size)
};

~setBPM = {|bpm|
	~bpm = bpm;
	~bps = ~bpm/60;
	~beatdur = ~bps.reciprocal;
};

~quant = 2;
~allPatterns = DjembeLib.convertAll(~quant);
~patterns16 = ~allPatterns.select({|pat| pat.first.size /  ~quant == 16  });
~patterns12 = ~allPatterns.select({|pat| pat.first.size /  ~quant == 12  });
~sparseObjects = ~allPatterns.collect(SparsePattern(_)).collect(_.makeSparse);
~sparsePatterns = ~sparseObjects.collect(_.patterns);

~patterns16.collect(_.size).postln;
~patterns16.size.postln;
"-----".postln;
~patterns12.collect(_.size).postln;
~patterns12.size.postln;

~sparsePatterns.collect({|pat| pat.first.size }).postln;

~rDB = (
	r00: { Pseq([
			Pseq([pi/6, pi/6.neg, pi/4.neg, pi/4], 4),
			Pseq([0, 1, 1, 0, 0.5, -0.5, -0.5, 0.5], 2),
			Pseq([pi/8, 5pi/8, pi/8.neg, 5pi/8.neg], 4),
			Pn(0, 8)
		], inf) },
	r01: { Prand((0,0.25..2)*pi-pi, inf) },
	r02: { Pxrand((0,0.2..1.8)*pi-pi, inf) },
	r03: { Pbrown(pi.neg, pi, pi/24, inf) },
	r04: { Pstutter(Pxrand((1..3), inf), Pseq((0,pi/6..2pi).mirror2-pi, inf)) },
	r05: { Prand((0,0.3..2)*pi-pi, inf) },
	r06: { Pwhite(pi.neg, pi, inf) },
	r07: { Pstutter(Pseq([2, 3, 2], inf), Pxrand( (0,0.3..2)*pi-pi, inf )) },
	r08: { Pbrown(pi.neg, pi, pi/6, inf) },
	r09: { Pwrand( (0.5.neg,0.4.neg..0.5)*pi, (0.5,0.4..0).mirror.normalizeSum, inf ) },
	r10: { Pwrand( (0.5,0.4..0.5.neg)*pi, (0.5,0.4..0).mirror.normalizeSum, inf ) },
	r11: { Pwrand( (0.5,0.6..1.5)*pi, (0.5,0.4..0).mirror.normalizeSum, inf ) },
	r12: { Pbrown(0, 0.5pi, 0.5pi/6, inf) },
	r13: { Pbrown(0, 0.5pi.neg, 0.5pi/6, inf) },
	r14: { Pbrown(pi, 0.5pi, 0.5pi/8, inf) },
	r15: { Pbrown(pi.neg, 0.5pi.neg, 0.5pi/8, inf) },
	default: 0
);

~efx = (
	rev00: (rtime: Pn(10), hf: Pn(0.5)),
	rev01: (room: Pn(50), rtime: Pn(10), damp: Pn(0.5), bw: Pn(0.5), spr: Pn(20), 
		dry: Pn(0), early: Pseq([0.7, 1.0, 0.0], inf), tail: Pseq([0.7, 0, 1.0], inf)
	),
	rev02: (room: Pn(100), rtime: Pn(20), damp: Pn(0.1), bw: Pn(0.1), spr: Pn(10), dry: Pn(0), 
		early: Pn(0.7), tail: Pn(0.5), wsz: Pbrown(0.01, 0.1, 0.01, inf), pch: Pxrand([0.5, 0.25, 0.125], inf), 
		pds: Pwhite(0.0, 0.2, inf), 
		tds: Pwhite(0.0, 0.3, inf)
	),
	del00: (del: Pfunc({~bps / 4 }), dec: Pfunc({ ~beatdur }), rmp: Pn(0.3), rt: Pn(6)),
	del01: (del: Pxrand([0.04, 0.02, 0.05, 0.08, 0.1], inf), grw: Pn(1.618), 
		rmp: Pseq([0.05, 0.07, 0.09, 0.07], inf), rt: Prand([10, 5], inf)
	),
	res00: (frqs: (Array.series(7, 36, 36)).bubble,
		amps: Array.geom(7, 0.1, 1.618.reciprocal).bubble, rngs: Array.geom(7, 0.2, 1.618).bubble
	)
).keysValuesDo({|name, ev|
	ev[\delta] = Pfunc({ ~beatdur });
	ev[\in] = Bus.audio;
	ev[\addAction] = \addToHead;
	ev[\group] = ~efxgrp;
	ev[\amp] = Pfunc({ ~efxamps[name] });
	ev[\out] = ~decoder.bus;
});

~rhytproto = (
	p00: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r00, roty: ~rDB.default, rotz: ~rDB.r06, env: ~envs.perc01),
	p03: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r01, roty: ~rDB.r06, rotz: ~rDB.default, env: ~envs.perc00),
	p03: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r02, roty: ~rDB.default, rotz: ~rDB.r06, env: ~envs.step00 ),
	p04: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r03, roty: ~rDB.r06, rotz: ~rDB.default, env: ~envs.perc00 ),
	p05: (efx: ~efx.rev00.in, emp: 0.1, rotx: ~rDB.r05, roty: ~rDB.default, rotz: ~rDB.r06, env: ~envs.perc02 ),
	p07: (efx: ~nofxbus, emp: Pseq([0.01, 0.02, 0.01, 0, 0], inf), 
		rotx: ~rDB.default, roty: ~rDB.default, rotz: ~rDB.default, env: ~envs.sine00 ),
	p08: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r05, roty: ~rDB.default, rotz: ~rDB.r06, env: ~envs.perc00 ),
	p13: (efx: ~efx.del00.in, emp: 0.3, rotx: ~rDB.r06, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.perc00 ),
	p14: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r00, roty: ~rDB.default, rotz: ~rDB.r06, env: ~envs.perc00 ),
	p15: (efx: ~nofxbus, emp: Pseq([0.05, 0.1, 0, 0], inf), 
		rotx: ~rDB.default, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.perc00 ),
	p16: (efx: ~efx.rev01.in, emp: 0.1, rotx: ~rDB.r03, roty: ~rDB.r03, rotz: ~rDB.r03, env: ~envs.perc00 ),
	p17: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r07, roty: ~rDB.r12, rotz: ~rDB.r13, env: ~envs.perc00 ),
	p18: (efx: ~nofxbus, rotx: ~rDB.r06, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.perc00 ),
	p19: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r08, roty: ~rDB.r08, rotz: ~rDB.r08, env: ~envs.perc00 ),
	p20: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r09, roty: ~rDB.r09, rotz: ~rDB.r09, env: ~envs.perc00  ),
	p22: (efx: ~efx.del01.in, emp: Pseq([0, 0, 0.2, 0], inf), 
		rotx: ~rDB.r10, roty: ~rDB.r06, rotz: ~rDB.default, env: ~envs.perc00
	),
	p24: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r12, roty: ~rDB.r13, rotz: ~rDB.r14, env: ~envs.perc00 ),
	p25: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r13, roty: ~rDB.r14, rotz: ~rDB.r15, env: ~envs.perc00 ),
	p26: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r14, roty: ~rDB.r15, rotz: ~rDB.r12, env: ~envs.perc00 ),
	p27: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r15, roty: ~rDB.r12, rotz: ~rDB.r13, env: ~envs.perc00 ),
	p28: (efx: ~efx.res00.in, emp: 0.3, rotx: ~rDB.r06, roty: ~rDB.default, rotz: ~rDB.r07, env: ~envs.perc00  ),
	p29: (efx: ~efx.del01.in, emp: 0.1, rotx: ~rDB.r08, roty: ~rDB.r08, rotz: ~rDB.r06, env: ~envs.perc00  ),
	p30: (efx: ~efx.rev02.in, emp: 0.1, rotx: ~rDB.r06, roty: ~rDB.r06, rotz: ~rDB.r08, env: ~envs.perc00  ),
	p31: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r06, roty: ~rDB.default, rotz: ~rDB.default, env: ~envs.perc00 ),
	default: ( efx: ~nofxbus, emp: 0, rotx: ~rDB.default, roty: ~rDB.default, rotz: ~rDB.default, env: ~envs[\default] )
);
	
}.fork(AppClock);