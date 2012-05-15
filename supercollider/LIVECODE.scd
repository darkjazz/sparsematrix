
(
~setBPM.(130);
Pdef(\player).play;

~mfccResp = OSCresponderNode(Server.default.addr, '/mfcc', {|ti, re, ms|
	~ciapp.sendWeights(*ms[3..11]);
}).add;

)

~ciapp.initWorld(32, 32, 8, 2000, 0.1);

~ciapp.sendPresetRule(\faders);

~ciapp.changeSetting(\rule, 1);

(
~sectionFuncs = (
	a: {|bpm|
		~setBPM.(bpm);
		Pdef(\player, Ppar([ Pdef(\rhythm02), Pdef(\frag01), Pdef(\frag02) ]));

		~ctrls02.do({|ctr|
			ctr['active'] = [0, 1].wchoose([0.3, 0.7]); 
			ctr['amp'] = exprand(0.01, 2.0); 
			ctr['dur'] = exprand(0.01, 0.5)
		});
		
		~ciapp.setPattern(19, 1, 1.0, 0, 0);
	},

 	b: {|bpm|
		~setBPM.(bpm);
		
		Pdef(\player, Ppar([ Pdef(\rhythm), Pdef(\rhythm01), Pdef(\bits32) ]));
		
		~groups01.flat.do({|name|
			~ctrls01[name].active = [0, 1].wchoose([0.3, 0.7]);
			~ctrls01[name].dur = rrand(0.01, 0.4);
			~ctrls01[name].amp = rrand(0.1, 0.9);
		});
					
		~ciapp.sendPresetRule(\snake);
		
		~ciapp.setPattern(18, 0, 1.0, 0, 0);
		~ciapp.setPattern(19, 0, 1.0, 0, 0);
		~ciapp.setPattern(10, 1, 1.0, 0, 0);
		~ciapp.setPattern(11, 1, 1.0, 0, 0);	
		
	},


	c: {|bpm|
	
		~groups.drop(6).flat.do({|name|
			~ctrls[name].active = 0;
		});
				
		~bitgroups.keep(4).flat.do({|name|
			~bitctrls[name].active = 0;
		});
		
		~setBPM.(bpm);
		Pdef(\player, Ppar([ Pdef(\rhythm) ]));
	
		~groups.keep(4).flat.do({|name|
			~ctrls[name].active = 1;
			~ctrls[name].amp = rrand(0.1, 0.5);	
			~ctrls[name].dur = rrand(0.01, 0.1);	
		});
		
		~ciapp.sendPresetRule(\bloomerang);
		
		~ciapp.setPattern(10, 0, 1.0, 0, 0);
		~ciapp.setPattern(11, 0, 1.0, 0, 0);
		~ciapp.setPattern(12, 1, 1.0, 1, 1);
		~ciapp.setPattern(13, 1, 1.0, 0, 0);
		~ciapp.setPattern(14, 1, 1.0, 1, 1);		
		
	},

	d: {|bpm|

		~groups.keep(4).flat.do({|name|
			~ctrls[name].active = 0;
		});

		~setBPM.(bpm);

		Pdef(\player, Ppar([ Pdef(\rhythm03) ]));
	
		~groups03.flat.do({|name|
			~ctrls03[name].active = [0, 1].wchoose([0.5, 0.5]);
			~ctrls03[name].dur = rrand(0.06, 0.2);
			~ctrls03[name].amp = rrand(0.06, 0.4);
		});
		
		~ciapp.sendPresetRule(\ebbandflow);
		
		~ciapp.setPattern(12, 0, 1.0, 0, 0);
		~ciapp.setPattern(13, 0, 1.0, 0, 0);
		~ciapp.setPattern(14, 0, 1.0, 0, 0);			
		~ciapp.setPattern(15, 1, 1.0, 1, 1);
		~ciapp.setPattern(16, 1, 1.0, 0, 0);	
		
	},

	e: {|bpm|
		~groups[(4..9)].flat({|name|
			~ctrls[name].active = 0;
		});		
		~setBPM.(bpm);
		Pdef(\player, Ppar([ Pdef(\rhythm), Pdef(\efx) ]));

		~groups.flat.do({|name|
			~ctrls[name].active = [0, 1].wchoose([0.2, 0.8]);
			~ctrls[name].dur = rrand(0.02, 0.3);
			~ctrls[name].amp = rrand(0.06, 0.7);		
		});
		
		~efxamps.keys.do({|name|
			~efxamps[name] = 0.4
		});
		
		~ciapp.sendPresetRule(\xtasy);		
		
		~ciapp.setPattern(15, 0, 1.0, 0, 0);
		~ciapp.setPattern(16, 0, 1.0, 0, 0);
		~ciapp.setPattern(10, 1, 1.0, 1, 1);
		~ciapp.setPattern(17, 1, 1.0, 0, 0);	
		
		
	},
	
	f: {|bpm|
		
		~setBPM.(bpm);
		
		Pdef(\player, Ppar([ Pdef(\rhythm) ]));
				
		~efxamps.keys.do({|name|
			~efxamps[name] = 0
		});
		
		~groups.flat.do({|name|
			~ctrls[name].active = [0, 1].wchoose([0.5, 0.5]);
			~ctrls[name].dur = rrand(0.005, 0.009);
			~ctrls[name].amp = rrand(0.001, 0.7);		
		});
		
		~ciapp.sendPresetRule(\cooties);		
		
		~ciapp.setPattern(10, 0, 1.0, 0, 0);
	
	}

);

)

////////     START     ////////

Pdef(\player, Ppar([ Pdef(\frag02), Pdef(\frag01) ]));

~ciapp.setPattern(18, 1, 0.5, 0, 0);

~frag02controls.do({|ctrl| ctrl.amp = rrand(0.1,0.2); ctrl.active = [0, 1].wchoose([0.5, 0.5])  })


~frag01controls.do({|ctrl| ctrl.amp = rrand(0.1,0.5); ctrl.active = [0, 1].wchoose([0.5, 0.5])  })


////////     A     ////////

~sectionFuncs['a'].(135);


(
~ctrls02.do({|ctr|
	ctr['active'] = [0, 1].wchoose([0.1, 0.9]); 
	ctr['amp'] = exprand(0.05, 2.0); 
	ctr['dur'] = exprand(0.01, 0.5)
});

~frag02controls.do({|ctrl| ctrl.amp = rrand(0.3,0.5); ctrl.active = 0 })

~frag01controls.do({|ctrl| ctrl.amp = rrand(0.1,0.3); ctrl.active = 0 })

~ciapp.setPattern(18, 1, 1.0, 1, 1);
~ciapp.setPattern(19, 1, 1.0, 1, 1);


)

////////     B     ////////

~sectionFuncs['b'].(130);


(
~groups01.flat.do({|name|
	~ctrls01[name].active = [0, 1].wchoose([0.2, 0.8]);
	~ctrls01[name].dur = rrand(0.01, 0.3);
	~ctrls01[name].amp = rrand(0.1, 0.6);
});
)

(
~groups.keep(4).flat.do({|name|
	~ctrls[name].active = [0, 1].wchoose([0.3, 0.7]);
	~ctrls[name].dur = rrand(0.01, 0.1);
	~ctrls[name].amp = rrand(0.1, 0.6);	
})
)

(
~bitgroups.keep(4).flat.do({|name|
	~bitctrls[name].active = [0, 1].wchoose([0.3, 0.7]);;
	~bitctrls[name].amp = rrand(0.05, 0.2);
});

~ciapp.setPattern(10, 1, 1.0, 0, 0);
~ciapp.setPattern(11, 1, 1.0, 0, 0);


)



////////     C     ////////

~sectionFuncs['c'].(130);


(
~frag00controls.do({|ctrl| 
	ctrl.amp = rrand(0.2,0.5); 
	ctrl.active = [0, 1].wchoose([1.0, 0.0])
})
)

(
~groups.keep(4).flat.do({|name|
	~ctrls[name].active = [0, 1].wchoose([0.4, 0.6]);
	~ctrls[name].amp = rrand(0.1, 0.6);	
	~ctrls[name].dur = rrand(0.01, 0.2);	
});

)

(
~groups.keep(4).flat.do({|name|
	~ctrls[name].active = 0;
})


~ciapp.setPattern(12, 0, 1.0, 0, 0);
~ciapp.setPattern(13, 0, 1.0, 1, 1);		

~ciapp.setPattern(14, 1, 1.0, 0, 1);		


)





////////     D     ////////

~sectionFuncs['d'].(130);


~groups03.flat.do({|name|
	~ctrls03[name].active = [0, 1].wchoose([0.3, 0.7]);
	~ctrls03[name].dur = rrand(0.005, 0.01);
	~ctrls03[name].amp = rrand(0.06, 0.6);
});


~ciapp.setPattern(12, 1, 1.0, 0, 0);			
~ciapp.setPattern(13, 1, 1.0, 0, 0);
~ciapp.setPattern(14, 1, 1.0, 0, 0);

~ciapp.sendPresetRule(\faders);

////////     E     ////////

~sectionFuncs['e'].(140);


(
~groups.flat.do({|name|
	~ctrls[name].active = [0, 1].wchoose([0.3, 0.7]);
	~ctrls[name].dur = rrand(0.01, 0.1);
	~ctrls[name].amp = rrand(0.01, 0.6);
});
)

~ciapp.setPattern(15, 0, 1.0, 1, 1);
~ciapp.setPattern(16, 0, 1.0, 1, 1);


////////     F     ////////

~sectionFuncs['f'].(140);

(
~groups.flat.do({|name|
	~ctrls[name].active = [0, 1].wchoose([0.9, 0.1]);
	~ctrls[name].dur = rrand(0.005, 0.01);
	~ctrls[name].amp = rrand(0.01, 0.5);
});
)


~groups.flat.do({|name|
	~ctrls[name].active = 0;
	~ctrls[name].dur = rrand(0.005, 0.008);
	~ctrls[name].amp = rrand(0.01, 0.7);		
});




////////     KILL     ////////

~ciapp.setPattern(17, 1, 1.0, 1, 1);

Pdef(\player).stop

~ciapp.quit
