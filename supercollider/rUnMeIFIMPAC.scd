(
// options 'uhj', 'stereo', 'binaural', 'quad', 'hex', 'octo'
~decoderType = 'stereo';

(Document.current.dir +/+ "init.scd").load;

)

~decoder.numChannels

~decoder.type

~decoder.test

~decoder.stopTest

(

~combined = Array();

[\kpanilogo, \yole, \diansa, \sorsornet].do({|name|
	~combined = ~combined ++ SparsePattern(~allPatterns[name]).makeSparse.patterns;
});

~patterns = ();

~groups = [];

~combined.keep(~deffuncs.size ? 32).do({|seq, i|
	~patterns[~name.(i)] = seq;
	~groups = ~groups.add(~name.(i));
});

~groups = ~groups.clump(4);

~bitname = {|i| ("b"++i.asString.padLeft(2, "0")).asSymbol};

~bitcombined = Array();

[\kpanilogo, \yole, \diansa, \kokou, \kakilambe, \soli, \mandiani].do({|name|
	~bitcombined = ~bitcombined ++ SparsePattern(~allPatterns[name]).makeSparse.patterns;
});

~bitpatterns = ();

~bitgroups = [];

~bitcombined.do({|seq, i|
	~bitpatterns[~bitname.(i)] = seq;
	~bitgroups = ~bitgroups.add(~bitname.(i));
});

~bitgroups = ~bitgroups.clump(8);

~combined01 = Array();

[\sokou, \cassa].do({|name|
	~combined01 = ~combined01 ++ ~sparsePatterns[name]
});

~combined01 = ~combined01 ++ ~sparseObjects[\sokou].makeSubPatterns(1).subpatterns.first;

~combined01 = ~combined01 ++ ~sparseObjects[\cassa].makeSubPatterns(1).subpatterns.first;

~patterns01 = ();

~groups01 = [];

~combined01.keep(32).do({|seq, i|
	~patterns01[~name.(i, "q")] = seq;
	~groups01 = ~groups01.add(~name.(i, "q"));
});

~groups01 = ~groups01.clump(4);

~combined02 = Array();

[\rumba, \tiriba].do({|name|
	~combined02 = ~combined02 ++ ~sparsePatterns[name];
	~sparseObjects[name].makeSubPatterns(2).subpatterns.do({|seq|
		~combined02 = ~combined02 ++ seq
	});
});

~patterns02 = ();
~groups02 = [];
~bufs02 = ();

~combined02.do({|seq, i|
	~patterns02[~name.(i, "x")] = seq;
	~groups02 = ~groups02.add(~name.(i, "x"));
	~bufs02[~name.(i, "x")] = ~frags[i]
});

~groups02 = ~groups02.clump(4);


~combined03 = Array();

[\diansa, \liberte, \macrou].do({|name|
	~combined03 = ~combined03 ++ SparsePattern(~allPatterns[name]).makeSparse.patterns;
});

~patterns03 = ();

~groups03 = [];

~combined03.keep(32).do({|seq, i|
	~patterns03[~name.(i)] = seq;
	~groups03 = ~groups03.add(~name.(i));
});

~groups03 = ~groups03.clump(6);



~frag00patterns = ();
~frag00bufs = ();

~sparsePatterns[\kokou].do({|seq, i|
	var name = ~name.(i, "f0");
	~frag00patterns[name] = seq;
	~frag00bufs[name] = ~frags[0];
});

~frag00controls = ~frag00patterns.collect({ ( active: 0, amp: 0 ) });

~frag01patterns = ();
~frag01bufs = ();

~sparsePatterns[\soli].do({|seq, i|
	var name = ~name.(i, "f1");
	~frag01patterns[name] = seq;
	~frag01bufs[name] = ~frags[i+~frag00bufs.size];
});

~frag01controls = ~frag01patterns.collect({ ( active: 0, amp: 0 ) });

~frag02patterns = ();
~frag02bufs = ();

~sparsePatterns[\macrou].do({|seq, i|
	var name = ~name.(i, "f2");
	~frag02patterns[name] = seq;
	~frag02bufs[name] = ~frags[i+(~frag00bufs.size+~frag01bufs.size)];
});

~frag02controls = ~frag02patterns.collect({ ( active: 0, amp: 0 ) });

~frag03patterns = ();
~frag03bufs = ();

4.do({|i|
	var name = ~name.(i, "f3");
	~frag03patterns[name] = (0 ! 16).put(0, 1);
	~frag03bufs[name] = Pseq(~bits[(i*3..i*3+2)], inf);
});

~frag03controls = ~frag03patterns.collect({ ( active: 0, amp: 0 ) });

~setBPM.(130);

MasterEQ(~decoder.numChannels);

~ciapp = FunktApp(800, 600, mode: 0).open

)



(

~efx = (
	rev00: (rtime: Pn(10), hf: Pn(0.5)),
	rev01: (room: Pn(50), rtime: Pn(10), damp: Pn(0.5), bw: Pn(0.5), spr: Pn(20), 
		dry: Pn(0), early: Pseq([0.7, 1.0, 0.0], inf), tail: Pseq([0.7, 0, 1.0], inf)
	),
	rev02: (room: Pn(100), rtime: Pn(20), damp: Pn(0.1), bw: Pn(0.1), spr: Pn(10), dry: Pn(0), 
		early: Pn(0.7), tail: Pn(0.5), wsz: Pbrown(0.01, 0.1, 0.01, inf), pch: Pxrand([0.5, 0.25, 0.125], inf), pds: Pwhite(0.0, 0.2, inf), 
		tds: Pwhite(0.0, 0.3, inf)
	),
	del00: (del: Pfunc({~bps / 4 }), dec: Pfunc({ ~beatdur }), rmp: Pn(0.3), rt: Pn(6)),
	del01: (del: Pxrand([0.04, 0.02, 0.05, 0.08, 0.1], inf), grw: Pn(1.618), 
		rmp: Pseq([0.05, 0.07, 0.09, 0.07], inf), rt: Prand([10, 5], inf)
	),
	res00: (frqs: (Array.series(7, 36, 36)).bubble,
		amps: Array.geom(7, 0.1, 1.618.reciprocal).bubble, rngs: Array.geom(7, 0.2, 1.618).bubble
	),
	hgv00: (rtime: 10, dry: 0, ear: 0.7, tail: 1.0, hf: 6000.0)
).keysValuesDo({|name, ev|
	ev[\delta] = Pfunc({ ~beatdur });
	ev[\in] = Bus.audio;
	ev[\addAction] = \addToHead;
	ev[\group] = ~efxgrp;
	ev[\amp] = Pfunc({ ~efxamps[name] });
	ev[\out] = ~decoder.bus;
});

~efxamps = ~efx.collect({ 0.0 });

~ctrls = ~patterns.collect({  (active: 0, amp: 0, dur: rrand(0.01, 0.1)) });

~bitctrls = ~bitpatterns.collect({ (active: 1, amp: 0) });

~argproto = (
	p00: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r00, roty: ~rDB.r00, rotz: ~rDB.r00, env: ~envs.perc01),
	p03: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r01, roty: ~rDB.r01, rotz: ~rDB.r01, env: ~envs.perc00),
	p03: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r02, roty: ~rDB.r02, rotz: ~rDB.r02, env: ~envs.step00 ),
	p04: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r03, roty: ~rDB.r03, rotz: ~rDB.r03, env: ~envs.perc00 ),
	p05: (efx: ~efx.rev00.in, emp: 0.1, rotx: ~rDB.r04, roty: ~rDB.r04, rotz: ~rDB.r04, env: ~envs.perc02 ),
	p07: (efx: ~nofxbus, emp: Pseq([0.01, 0.02, 0.01, 0, 0], inf), rotx: ~rDB.r06, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.sine00 ),
	p08: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r05, roty: ~rDB.r05, rotz: ~rDB.r05, env: ~envs.perc00 ),
	p13: (efx: ~efx.del00.in, emp: 0.3, rotx: ~rDB.r06, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.perc00 ),
	p14: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r02, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.perc00 ),
	p15: (efx: ~nofxbus, emp: Pseq([0.05, 0.1, 0, 0], inf), rotx: 0, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.perc00 ),
	p16: (efx: ~efx.rev01.in, emp: 0.1, rotx: ~rDB.r09, roty: ~rDB.r05, rotz: ~rDB.r03, env: ~envs.perc00 ),
	p17: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r07, roty: ~rDB.r07, rotz: ~rDB.r07, env: ~envs.perc00 ),
	p18: (efx: ~nofxbus, rotx: ~rDB.r06, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.perc00 ),
	p19: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r03, roty: ~rDB.r03, rotz: ~rDB.r03, env: ~envs.perc00 ),
	p20: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r09, roty: ~rDB.r09, rotz: ~rDB.r09, env: ~envs.perc00  ),
	p22: (efx: ~efx.del01.in, emp: Pseq([0, 0, 0.2, 0], inf), rotx: ~rDB.r10, roty: ~rDB.r10, rotz: ~rDB.r10, env: ~envs.perc00),
	p24: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r12, roty: ~rDB.r11, rotz: ~rDB.r12, env: ~envs.perc00 ),
	p25: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r13, roty: ~rDB.r12, rotz: ~rDB.r11, env: ~envs.perc00 ),
	p26: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r14, roty: ~rDB.r14, rotz: ~rDB.r14, env: ~envs.perc00 ),
	p27: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r15, roty: ~rDB.r15, rotz: ~rDB.r10, env: ~envs.perc00 ),
	p28: (efx: ~efx.res00.in, emp: 0.3, rotx: ~rDB.r06, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.perc00  ),
	p29: (efx: ~efx.del01.in, emp: 0.1, rotx: ~rDB.r06, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.perc00  ),
	p30: (efx: ~efx.rev02.in, emp: 0.1, rotx: ~rDB.r06, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs.perc00  ),
	p31: (efx: ~nofxbus, emp: 0, rotx: ~rDB.r06, roty: ~rDB.r07, rotz: ~rDB.r07, env: ~envs.perc00 ),
	default: ( efx: ~nofxbus, emp: 0, rotx: ~rDB.r06, roty: ~rDB.r06, rotz: ~rDB.r06, env: ~envs[\default] )
);

~argproto01 = ();
~argproto.keysValuesDo({|key, val| 
	var newkey = key.asString.replace("p", "q").asSymbol;
	~argproto01[newkey] = val
});

~args = ~patterns.collect({|pat, key| ~argproto[key] ? ~argproto[\default] });

~instr = ().putPairs(~args.size.collect({|i| [~name.(i, "p"), ~name.(i, "d")]  }).flat);

Pdef(\rhythm, Ppar(
	~args.collect({|args, name|  
		Pbind(\instrument, ~instr[name], \group, ~grp, \addAction, \addToHead, \delta, Pfunc({ ~beatdur / 8 }), 
			\amp, Pfunc({ ~ctrls[name].amp }), \out, ~decoder.bus,
			\dur, Pfunc({ ~ctrls[name].dur }), \pat, ~makePattern.(name, ~patterns[name].bubble),
			\type, Pfunc({|ev| if (~ctrls[name].active.booleanValue) { ev.pat } { \rest } }),
			*args.asKeyValuePairs
		)
	}).values
));

Pdef(\efx, Ppar(
	~efx.collect({|efx, name| Pmono(name, *efx.asKeyValuePairs) }).values
));

~bitbufs = ();
(32..64).do({|num, i| ~bitbufs[~name.(i, "q")] = ~bits.wrapAt(num) });


~ctrls01 = ~patterns01.collect({ 
	(active: [1, 0].wchoose([0.5, 0.5]), amp: rrand(0.5, 1.0), dur: rrand(0.05, 0.1) )
});

~args01 = ~patterns01.collect({|pat, key| ~argproto01[key] ? ~argproto01[\default] });

Pdef(\rhythm01, Ppar(
	~args01.collect({|args, name|  
		Pbind(\instrument, \bit01, \group, ~grp, \addAction, \addToHead, \delta, Pfunc({ ~beatdur / 8 }), 
			\amp, Pfunc({ ~ctrls01[name].amp }), \out, ~decoder.bus, \buf, ~bitbufs[name],
			\dur, Pfunc({ ~ctrls01[name].dur }), \pat, ~makePattern.(name, ~patterns01[name].bubble),
			\type, Pfunc({|ev| if (~ctrls01[name].active.booleanValue) { ev.pat } { \rest } }),
			\off, 0, \rate, 1,
			*args.asKeyValuePairs
		)
	}).values
));

~args02 = ~patterns02.collect({|pat, key|  
	(
		efx: [~nofxbus, ~efx.collect(_.in).collect(_.index).values.choose].wchoose([0.8, 0.2]),
		rate: rrand(15/16, 16/15),
		env: ~envs.perc00, rotx: ~rDB.choose.(), roty: ~rDB.choose.(), rotz: ~rDB.choose.()
	)
});

~ctrls02 = ~patterns02.collect({  (active: 0, amp: 0, dur: rrand(0.05, 0.1) ) });

Pdef(\rhythm02, Ppar(
	~args02.collect({|args, name|  
		Pbind(\instrument, \frag04, \group, ~grp, \addAction, \addToHead, \delta, Pfunc({ ~beatdur / 8 }), 
			\amp, Pfunc({ ~ctrls02[name].amp }), \out, ~decoder.bus, \buf, ~bufs02[name],
			\dur, Pfunc({ ~ctrls02[name].dur }), \pat, ~makePattern.(name, ~patterns02[name].bubble),
			\type, Pfunc({|ev| if (~ctrls02[name].active.booleanValue) { ev.pat } { \rest } }),
			*args.asKeyValuePairs
		)
	}).values
));

~args03 = ~patterns03.collect({|pat, key| ~argproto[key] ? ~argproto[\default] });

~instr03 = ().putPairs(~args03.size.collect({|i| [~name.(i, "p"), ~name.(i, "d")]  }).flat);

~ctrls03 = ~patterns03.collect({  (active: 0, amp: 0, dur: rrand(0.01, 0.1)) });

Pdef(\rhythm03, Ppar(
	~args03.collect({|args, name|  
		Pbind(\instrument, ~instr03[name], \group, ~grp, \addAction, \addToHead, \delta, Pfunc({ ~beatdur / 8 }), 
			\amp, Pfunc({ ~ctrls03[name].amp }), \out, ~decoder.bus,
			\dur, Pfunc({ ~ctrls03[name].dur }), \pat, ~makePattern.(name, ~patterns03[name].bubble),
			\type, Pfunc({|ev| if (~ctrls03[name].active.booleanValue) { ev.pat } { \rest } }),
			*args.asKeyValuePairs
		)
	}).values
));


Pdef(\bits32, Ppar(
	~bits.keep(32).collect({|buf, i|
		var name;
		name = ~bitname.(i);
		Pbind(\instrument, \bit00, \group, ~grp, \addAction, \addToHead, \delta, Pfunc({ ~beatdur / 8 }),
			\amp, Pfunc({ ~bitctrls[name].amp }), \out, ~decoder.bus, \buf, buf,
			\pat, ~makePattern.(name, ~bitpatterns[name].bubble), \rate, 1,
			\type, Pfunc({|ev| if (~bitctrls[name].active.booleanValue) { ev.pat } { \rest } }),
			\rot, Pwhite(0, 2pi, inf), \efx, ~nofxbus, \emp, 0
		)
	})
));

Pdef(\bits64, Ppar(
	~bits.drop(32).collect({|buf, i|
		var name;
		name = ~bitname.(i+32);
		Pbind(\instrument, \bit00, \group, ~grp, \addAction, \addToHead, \delta, Pfunc({ ~beatdur / 4 }),
			\amp, Pfunc({ ~bitctrls[name].amp }), \out, ~decoder.bus, \buf, buf,
			\pat, ~makePattern.(name, ~bitpatterns[name].bubble), \rate, 1,
			\type, Pfunc({|ev| if (~bitctrls[name].active.booleanValue) { ev.pat } { \rest } }),
			\rot, Pwhite(0, 2pi, inf), \efx, ~nofxbus, \emp, 0
		)
	})
));

Pdef(\frag00, 
	Ppar(	
		~frag00patterns.collect({|seq, name|
			Pbind(\instrument, \frag00, \out, ~decoder.bus, \group, ~grp, \addAction, \addToHead, 
				\delta, Pfunc({ ~beatdur / 4 }), \buf, ~frag00bufs[name], \env, ~envs.default, 
				\amp, Pfunc({ ~frag00controls[name].amp }),
				\rate, 1.0, \loop, 1, \dur, ~frag00bufs[name].duration.round(~beatdur), \ffhi, 1, 
				\fflo, Pseg(Pseq([0.2, 0.5, 0.2], 1), Pseq([2, 4, 2, 3], 1), \linear, inf),
				\ffrq, Pseq([2, 4, 6], inf) * Pfunc({ ~beatdur.reciprocal * 4 }),
				\rotx, ~rDB.r06, \roty, ~rDB.r06, \rotz, ~rDB.r06,
				\pat, ~makePattern.(name, seq.bubble), 
				\type, Pfunc({|ev| if (~frag00controls[name].active.booleanValue) { ev.pat } { \rest }  })
			)
		}).values
	)
);
Pdef(\frag01, 
	Ppar(	
		~frag01patterns.collect({|seq, name|
			Pbind(\instrument, \frag01, \out, ~decoder.bus, \group, ~grp, \addAction, \addToHead, 
				\delta, Pfunc({ ~beatdur / 2 }), \buf, ~frag01bufs[name], \env, ~envs.sine00, 
				\amp, Pfunc({ ~frag01controls[name].amp }), \grate, 10,
				\gdlo, 0.01, \gdhi, 0.2,
				\rate, 1.0, \loop, 1, \dur, ~frag01bufs[name].duration * 2, \ffhi, 1, 
				\fflo, Pseg(Pseq([0.0, 0.3, 0.0], 1), Pseq([2, 4, 2, 3], 1), \linear, inf),
				\ffrq, Pseq([2, 4, 6], inf) * Pfunc({ ~beatdur.reciprocal * 4 }),
				\fwid, Pseq([0.25, 0.5, 0.5], inf), \rmz, 100, \rev, 10, \ear, 0.2, \tai, 0.5,
				\rotx, ~rDB.r06, \roty, ~rDB.r06, \rotz, ~rDB.r06,
				\pat, ~makePattern.(name, seq.bubble), 
				\type, Pfunc({|ev| if (~frag01controls[name].active.booleanValue) { ev.pat } { \rest }  })
			)
		}).values
	)
);
Pdef(\frag02, 
	Ppar(	
		~frag02patterns.collect({|seq, name|
			Pbind(\instrument, \frag02, \out, ~decoder.bus, \group, ~grp, \addAction, \addToHead, 
				\delta, Pfunc({ ~beatdur / 8 }), \buf, ~frag02bufs[name], \env, ~envs.lin01, 
				\amp, Pfunc({ ~frag02controls[name].amp }), 
				\rate, 0.125, \warp, Pxrand((2..6).reciprocal, inf), 
				\dur, Pfunc({ ~beatdur }) * Prand([1, 2, 4], inf), \wisz, 0.1, \genv, -1, 
				\ffhi, 1, \wrnd, 0.01, \dens, 8, \intr, 4, \fwid, Pseq([0.75, 0.5], inf),
				\fflo, Pseg(Pseq([0.2, 0.5, 0.2], 1), Pseq([2, 4, 2, 3], 1), \linear, inf),
				\ffrq, Pseq([2, 4, 6], inf) * Pfunc({ ~beatdur.reciprocal * 4 }),
				\rotx, ~rDB.r06, \roty, ~rDB.r06, \rotz, ~rDB.r06,
				\pat, ~makePattern.(name, seq.bubble), 
				\type, Pfunc({|ev| if (~frag02controls[name].active.booleanValue) { ev.pat } { \rest }  })
			)
		}).values
	)
);

Pdef(\frag03, 
	Ppar(	
		~frag03patterns.collect({|seq, name|
			Pbind(\instrument, \frag03, \out, ~decoder.bus, \group, ~grp, \addAction, \addToHead, 
				\buf, ~frag03bufs[name], \env, ~envs.default, \delta, Pfunc({ ~beatdur }),
				\dur, Pfunc({ ~beatdur * 16 }), \env, ~envs.lin01,
				\amp, Pfunc({ ~frag03controls[name].amp }), \beatdur, Pfunc({ ~beatdur }),
				\ffhi, 1, \fwid, 0.5, \fflo, 0.5, \ffrq, Pfunc({ ~beatdur.reciprocal * 4 }),
				\rotx, ~rDB.r09, \roty, ~rDB.r10, \rotz, ~rDB.r11,
				\pat, ~makePattern.(name, seq.bubble), 
				\type, Pfunc({|ev| if (~frag03controls[name].active.booleanValue) { ev.pat } { \rest }  })
			)
		}).values
	)
);


)

~frag03bufs = ();

8.do({|seq, i|
	var name = ~name.(i, "f3");
	~frag03bufs[name] = ~bits[i];
});


~ciapp.setPattern(0, 0, 1.0, 1, 1)

~ciapp.setPattern(3, 1, 1.0, 0, 1)

~ciapp

Pdef(\player, Ppar([Pdef(\frag00), Pdef(\frag03), Pdef(\rhythm)]))

Pdef(\player, Ppar([ Pdef(\rhythm), Pdef(\bits32), Pdef(\efx) ]))

Pdef(\player, Ppar([ Pdef(\rhythm), Pdef(\efx), Pdef(\bits32)]))

Pdef(\player, Ppar([ Pdef(\rhythm02), Pdef(\efx) ]))

Pdef(\player, Ppar([ Pdef(\rhythm), Pdef(\rhythm02), Pdef(\efx) ]))


Pdef(\player, Ppar([Pdef(\frag00), Pdef(\frag01), Pdef(\frag02), Pdef(\frag03)]))

(
Pdef(\player).play;
~ciapp.setPattern(0, 1, 1.0, 0, 1)
)


Pdef(\player).play;

Pdef(\player).stop

Pdef(\player).clear

~decoder

~frag00controls.do({|ctrl| ctrl.amp = rrand(0.4,0.8); ctrl.active = [0, 1].wchoose([0.5, 0.5])  })

~frag01controls.do({|ctrl| ctrl.amp = rrand(0.1,0.4); ctrl.active = [0, 1].wchoose([1.0, 0.0])  })

~frag02controls.do({|ctrl| ctrl.amp = rrand(0.7,1.0); ctrl.active = [0, 1].wchoose([1.0, 0.0])  })

~frag03controls.do({|ctrl| ctrl.amp = rrand(0.5,0.8); ctrl.active = [0, 1].wchoose([0.0, 1.0])  })

~frag03controls['f303'].amp = 1;
~frag03controls['f302'].active = 1;

~frag03controls['f302'].active = 0;


~groups[0].do({|name| ~ctrls[name].active = 1 })

~groups[4].do({|name| ~ctrls[name].active = 0 })

~ctrls.do({|ctr|
	ctr['amp'] = rrand(0.1, 0.5); ctr['dur'] = rrand(0.01, 0.3) 
});

~ctrls.do({|ctr|
	ctr['active'] = [0, 1].wchoose([0.7, 0.3]); ctr['amp'] = rrand(0.01, 0.7); ctr['dur'] = rrand(0.01, 0.1) 
});


(
~ctrls.do({|ctr|
	ctr.active = [0, 1].wchoose([0.2, 0.8]); ctr.amp = rrand(0.1, 0.5); ctr['dur'] = rrand(0.01, 0.1) 
});
~frag03controls.do({|ctrl| ctrl.amp = rrand(0.5,1.0); ctrl.active = [0, 1].wchoose([1.0, 0.0])  })

)

~ctrls01.do({|ctr|
	ctr.active = [0, 1].wchoose([0.5, 0.5]); ctr.amp = rrand(0.7, 1.5); ctr['dur'] = rrand(0.01, 0.2) 
});


(
~ctrls01.do({|ctr|
	ctr.active = [0, 1].wchoose([0.3, 0.7]); ctr.amp = rrand(0.7, 1.5); ctr['dur'] = rrand(0.01, 0.3) 
});
~ciapp.setPattern(1, 0, 1.0, 1, 1)
)


~ciapp.changeSetting(\symmetry, 3)

~ciapp.sendPresetRule(\xtasy);

~ciapp.changeSetting(\rule, 1)

(
~ctrls.do({|ctr|
	ctr.active = [0, 1].wchoose([0.9, 0.1]); ctr.amp = rrand(0.01, 0.7); ctr['dur'] = rrand(0.001, 0.1) 
});
~bitctrls.do({|ctr|
	ctr['active'] = [0, 1].wchoose([0.8, 0.2]); ctr.amp = rrand(0.5, 1.0); 
});

~ciapp.setPattern(15, 0, 0.8, 1, 0);
~ciapp.setPattern(8, 0, 1.0, 1, 1);
)


(
~bitctrls.do({|ctr|
	ctr.active = [0, 1].wchoose([0.5, 0.5]); ctr.amp = rrand(0.05, 0.2); 
});
~ciapp.setPattern(6, 0, 1.0, 1, 1);
~ciapp.setPattern(7, 0, 1.0, 1, 1)
	
)

~efxamps[\rev00] = 0.5
~efxamps[\rev00] = 0

~efxamps[\rev01] = 0.6
~efxamps[\rev01] = 0

~efxamps[\rev02] = 0.5
~efxamps[\rev02] = 0

~efxamps[\del00] = 0.4
~efxamps[\del00] = 0

~efxamps[\del01] = 0.3
~efxamps[\del01] = 0

~efxamps[\res00] = 0.5
~efxamps[\res00] = 0

(

~combined = Array();

//[\mandiani, \diansa, \tiriba, \diansa].do({|name|
//	~combined = ~combined ++ SparsePattern(~allPatterns[name]).makeSparse.patterns;
//});

[\kpanilogo, \yole, \diansa].do({|name|
	~combined = ~combined ++ SparsePattern(~allPatterns[name]).makeSparse.patterns;
});

~patterns = ();

~groups = [];

~combined.keep(32).do({|seq, i|
	~patterns[~name.(i)] = seq;
	~groups = ~groups.add(~name.(i));
});

~groups = ~groups.clump(4);

Pdef(\rhythm, Ppar(
	~args.collect({|args, name|  
		Pbind(\instrument, ~instr[name], \group, ~grp, \addAction, \addToHead, \delta, Pfunc({ ~beatdur / 8 }), 
			\amp, Pfunc({ ~ctrls[name].amp }), \out, ~decoder.bus,
			\dur, Pfunc({ ~ctrls[name].dur }), \pat, ~makePattern.(name, ~patterns[name].bubble),
			\type, Pfunc({|ev| if (~ctrls[name].active.booleanValue) { ev.pat } { \rest } }),
			*args.asKeyValuePairs
		)
	}).values
));

)

s.queryAllNodes


~ctrls01.do({|ctr|
	ctr.active = [0, 1].wchoose([0.4, 0.6]); ctr.amp = rrand(0.5, 0.7); ctr['dur'] = rrand(0.1, 0.2) 
});

~mfccResp.remove;
~mfccResp = nil;

~ciapp.quit

~setBPM.(130);

~ctrls03.do({|ctr|
	ctr['active'] = [0, 1].wchoose([0.5, 0.5]); ctr['amp'] = rrand(0.05, 0.5); ctr['dur'] = rrand(0.01, 0.3) 
});


~ctrls02.do({|ctr|
	ctr['active'] = [0, 1].wchoose([0.3, 0.7]); ctr['amp'] = exprand(0.01, 2.0); ctr['dur'] = exprand(0.01, 0.5)
});

