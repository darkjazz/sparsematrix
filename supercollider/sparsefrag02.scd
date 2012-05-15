(Document.current.dir +/+ "initfunkt.scd").load;

(

~combined = Array();

[\sokou, \cassa].do({|name|
	~combined = ~combined ++ ~sparsePatterns[name]
});

~combined = ~combined ++ ~sparseObjects[\sokou].makeSubPatterns(1).subpatterns.first;

~combined = ~combined ++ ~sparseObjects[\cassa].makeSubPatterns(1).subpatterns.first;

~patterns = ();

~groups = [];

~combined.keep(32).do({|seq, i|
	~patterns[~name.(i)] = seq;
	~groups = ~groups.add(~name.(i));
});

~groups = ~groups.clump(4);

~setBPM.(125)

)

(

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

~efxamps = ~efx.collect({ 0.0 });

~ctrls = ~patterns.collect({ 
	(active: [1, 0].wchoose([0.5, 0.5]), amp: rrand(0.5, 1.0), dur: rrand(0.05, 0.1), 
		aspec: FaderWarp(), dspec: ControlSpec(0.01, 1.0, step: 0.01)) 
});

~argproto = (
	p00: (
		efx: ~nofxbus, emp: 0, rot: Pseq([
			Pseq([pi/6, pi/6.neg, pi/4.neg, pi/4], 4),
			Pseq([0, 1, 1, 0, 0.5, -0.5, -0.5, 0.5], 2),
			Pseq([pi/8, 5pi/8, pi/8.neg, 5pi/8.neg], 4),
			Pn(0, 8)
		], inf), env: ~envs.perc01
	),
	p03: (efx: ~efx.del01.in, emp: 0, rot: Prand((0,0.25..2)*pi, inf), env: ~envs.perc00),
	p03: (efx: ~nofxbus, emp: 0, rot: Pxrand((0,0.2..1.8)*pi, inf), env: ~envs.step00 ),
	p04: (efx: ~nofxbus, emp: 0, rot: Pbrown(0, 2pi, pi/24, inf), env: ~envs.perc00 ),
	p05: (efx: ~efx.rev00.in, emp: 0.1, rot: Pstutter(2, Pseq((0,pi/6..2pi).mirror2, inf)), env: ~envs.perc02 ),
	p07: (efx: ~nofxbus, emp: Pseq([0.01, 0.02, 0.01, 0, 0], inf), rot: 0, env: ~envs.sine00 ),
	p08: (efx: ~nofxbus, emp: 0, rot: Prand((0,0.3..2)*pi, inf), env: ~envs.perc00 ),
	p13: (efx: ~efx.del00.in, emp: 0.3, rot: Pwhite(0, 2pi, inf), env: ~envs.perc00 ),
	p14: (efx: ~efx.res00.in, emp: 0.1, rot: Pxrand((0,0.2..1.8)*pi, inf), env: ~envs.perc00 ),
	p15: (efx: ~nofxbus, emp: Pseq([0.05, 0.1, 0, 0], inf), rot: 0, env: ~envs.perc00 ),
	p16: (efx: ~efx.rev01.in, emp: 0.1, rot: Pbrown(0, 2pi, pi/8, inf), env: ~envs.perc00 ),
	p17: (efx: ~efx.rev02.in, emp: 0.1, rot: Pstutter(Pseq([2, 3, 2], inf), Pxrand( (0,0.3..2)*pi, inf )), env: ~envs.perc00 ),
	p18: (efx: ~nofxbus, rot: Pwhite(0, 2pi, inf), env: ~envs.perc00 ),
	p19: (efx: ~nofxbus, emp: 0, rot: Pbrown(0, 2pi, pi/6, inf), env: ~envs.perc00 ),
	p20: (efx: ~nofxbus, emp: 0, rot: Pwrand( (0.5.neg,0.4.neg..0.5)*pi, (0.5,0.4..0).mirror.normalizeSum, inf ), env: ~envs.perc00  ),
	p22: (efx: ~efx.del01.in, emp: Pseq([0, 0, 0.2, 0], inf), 
		rot: Pwrand( (0.5,0.6..1.5)*pi, (0.5,0.4..0).mirror.normalizeSum, inf ), env: ~envs.perc00
	),
	p24: (efx: ~nofxbus, emp: 0, rot: Pbrown(0, 0.5pi, 0.5pi/6, inf), env: ~envs.perc00 ),
	p25: (efx: ~nofxbus, emp: 0, rot: Pbrown(0.5pi, pi, 0.5pi/6, inf), env: ~envs.perc00 ),
	p26: (efx: ~nofxbus, emp: 0, rot: Pbrown(pi, 1.5pi, 0.5pi/6, inf), env: ~envs.perc00 ),
	p27: (efx: ~nofxbus, emp: 0, rot: Pbrown(1.5pi, 2pi, 0.5pi/6, inf), env: ~envs.perc00 ),
	p28: (efx: ~nofxbus, emp: 0.3, rot: Pwhite(0, pi, inf), env: ~envs.perc00  ),
	p29: (efx: ~efx.del01.in, emp: 0.1, rot: Pwhite(pi, 2pi, inf), env: ~envs.perc00  ),
	p30: (efx: ~efx.rev02.in, emp: 0.1, rot: Pwhite(0, 2pi, inf), env: ~envs.perc00  ),
	p31: (efx: ~nofxbus, emp: 0, rot: Pwhite(0, 2pi, inf), env: ~envs.perc00 ),
	default: ( efx: ~nofxbus, emp: 0, rot: 0, env: ~envs[\default] )
);

~args = ~patterns.collect({|pat, key| ~argproto[key] ? ~argproto[\default] });
~bitbufs = ();
(32..64).do({|num, i| ~bitbufs[~name.(i)] = ~bits.wrapAt(num) });

Pdef(\rhythm, Ppar(
	~args.collect({|args, name|  
		Pbind(\instrument, \bit01, \group, ~grp, \addAction, \addToHead, \delta, Pfunc({ ~beatdur / 8 }), 
			\amp, Pfunc({ ~ctrls[name].amp }), \out, ~decoder.bus, \buf, ~bitbufs[name],
			\dur, Pfunc({ ~ctrls[name].dur }), \pat, ~makePdefn.(name, ~patterns[name]),
			\type, Pfunc({|ev| if (~ctrls[name].active.booleanValue) { ev.pat } { \rest } }),
			\off, 0, \rate, 1,
			*args.asKeyValuePairs
		)
	}).values
));

Pdef(\efx, Ppar(
	~efx.collect({|efx, name| Pmono(name, *efx.asKeyValuePairs) }).values
));

)

s.queryAllNodes

s.record

~player = Ppar([Pdef(\rhythm), Pdef(\efx)]).play

~player.stop

~efxamps[\rev00] = 0.2
~efxamps[\rev00] = 0
~ctrls[\p05].amp = 1

~efxamps[\rev01] = 0.2
~efxamps[\rev01] = 0
~ctrls[\p16].amp = 1

~efxamps[\rev02] = 0.2
~efxamps[\rev02] = 0
~ctrls[\p30].amp = 0.8

~efxamps[\del00] = 0.4
~efxamps[\del00] = 0
~ctrls[\p13].amp = 1

~efxamps[\del01] = 0.4
~efxamps[\del01] = 0
~ctrls[\p29].amp = 0.5

~efxamps[\res00] = 0.3
~efxamps[\res00] = 0
~ctrls[\p17].amp = 0.7

~ctrls = ~patterns.collect({ 
	(active: [1, 0].wchoose([0.5, 0.5]), amp: rrand(0.5, 2.0), dur: rrand(0.001, 0.1), 
		aspec: FaderWarp(), dspec: ControlSpec(0.01, 1.0, step: 0.01)) 
});

s.queryAllNodes

s.stopRecording