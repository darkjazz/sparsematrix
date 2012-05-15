~name = ~name ? {|i, chr="p"| (chr++i.asString.padLeft(2, "0")).asSymbol };

~makedef = {|name, func|
	SynthDef(name, {|out, efx, dur = 0.1, amp = 1.0, emp = 0.0, rotx = 0.0, roty = 0.0, rotz = 0.0| 
		var sig;
		sig = SynthDef.wrap(func) 
			* EnvGen.kr(EnvControl.kr, timeScale: dur, doneAction: 2);
		Out.ar(efx, sig * emp);
		Out.ar(out, FoaTransform.ar(
			FoaEncode.ar(sig * amp, FoaEncoderMatrix.newDirection), 'rtt', rotx, roty, rotz)
		)
	}).add;
};

~deffuncs = [
{ Mix(SinOsc.ar([40, 51, 63], 0.5pi)) },
{ Impulse.ar(1, 10, 10).clip(-0.9, 0.9) },
{ PinkNoise.ar.clip(-0.9, 0.9) },
{ Mix(LFSaw.ar([20, 31] + LFSaw.ar([1, 8]).range(20, 40))).clip(-0.9, 0.9) },
{ RLPF.ar(BrownNoise.ar(10).softclip, 320, 0.5, 1) },
{ VarSaw.ar(IRand(60, 180).round(10), 0.25, 0.01, 20).clip(-0.5, 0.5) },
{ LFPulse.ar(20 + LFPulse.ar(10)).distort },
{ Dust2.ar(1000, 2, SinOsc.ar(Rand(8000, 16000).round(2**(1/5)))) },
{ LFGauss.ar(1/60, XLine.kr(0.1, 0.01, 0.2)) },
{ LFNoise0.ar(1000 + LFNoise0.ar(2500, 10).range(50, 200), 200).tanh * 0.8 },
{ Mix(SinOsc.ar([20, 25, 30, 35], 0.5pi)) },
{ Mix(SinOsc.ar(SinOsc.ar([1000, 100]).range(20, 200), 0.5pi)) },
{ Mix(SinOsc.ar(SinOsc.ar([51, 50]).range(20, 80), 0.5pi)) },
{ Impulse.ar(1, 100, 10).clip(-0.9, 0.9) + Dust2.ar(10000, 2).tanh },
{ LFSaw.ar(32, 0.5, LFNoise0.ar(10000).range(10, 100)).distort },
{ Blip.ar(10, 100, 10).clip(-0.9, 0.9) },
{ LFTri.ar(64, 0, LFNoise0.ar(200).range(100, 200)).clip(-0.9, 0.9).distort },
{ SinOsc.ar(2**13*1.5) },
{ Crackle.ar(1.6, 35).softclip },
{ Logistic.ar(VarSaw.kr(pi**2).range(3.57, 3.8), 2**14) },
{ Osc.ar(LocalBuf.newFrom((64.fib.mirror2.normalizeSum - 0.1) * [-1, 1].lace(128)), 100, 0, 5).softclip },
{ Pluck.ar(SinOsc.ar(LFNoise0.ar(999).range(40, 80), 0, 10), Impulse.kr(2), 0.1, 0.1, 4).tanh },
{ LFSaw.ar(LFNoise0.ar(999).range(40, 80), 0, 10).softclip },
{ Decimator.ar(Impulse.ar(64, 10, 10).softclip, 48000, 24, 2) }, 
{ SineShaper.ar(SinOsc.ar(10, 0, 10), 0.8) },
{ SineShaper.ar(SinOsc.ar(20, 0, 10), 0.5) },
{ SineShaper.ar(SinOsc.ar(20, 0, 200), 0.5) },
{ SineShaper.ar(SinOsc.ar(8, 0, 1000), 0.7) },
{ CrossoverDistortion.ar(SinOsc.ar(LFNoise2.ar(1000).range(180, 200).round(10), 0, 2).softclip, 0.4, 0.2) },
{ Disintegrator.ar(SinOsc.ar(LFSaw.ar(20).range(200, 300).round(10), 0, 2).clip, 0.5, 0.5) },
{ Gendy1.ar(2, 2, 1, 1, 40, 80) },
{ Gendy1.ar(6, 6, 0.01, 0.01, 40, 160, 1, 1, 24, 24) },

{ LFSaw.ar(LFSaw.ar(16).range(pi**pi, pi**pi*2), LFSaw.ar(15).range(0, 2), LFPulse.ar(16).range(0.5, 1.0)) },
{ StkPluck.ar(pi**pi, 1.0, 10).clip(-0.9, 0.9) },
{ StkSaxofony.ar(pi**pi*2, 20, 40, XLine.kr(30, 10, 0.2), 10, 16, 10, 64, 1, 64).clip(-0.9, 0.9) },
{ Oregonator.ar(Impulse.kr(16), 4, 0.5).clip(-0.9, 0.9) },
{ Brusselator.ar(0, 0.5, 2.0).tanh },
{ SpruceBudworm.ar(0,0.1,25.45,1.5,0.5,5.0, initx:0.7, inity: 0.4).tanh },
{ Mix(MdaPiano.ar(16000,1,127,1,1,1,0,1,1,0.5,0.1,0.5,mul:20).softclip) },
{ (Perlin3.ar(LFSaw.kr(220), SinOsc.ar(440), LFTri.ar(500))*10).distort }

].rotate(32).collect({|fnc, i|
	~makedef.(~name.(i, "d"), fnc)
});

SynthDef(\bit00, {|out, efx, amp, emp, buf, rate, rotx, roty, rotz|
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, doneAction: 2);
	Out.ar(efx, sig * emp);
	Out.ar(out, FoaTransform.ar(
		FoaEncode.ar(sig * amp, FoaEncoderMatrix.newDirection), 'rtt', rotx, roty, rotz)
	)
}).add;

SynthDef(\bit01, {|out, efx, amp, emp, buf, dur, off, rate, rotx, roty, rotz|
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, 1, off) 
		* EnvGen.kr(EnvControl.kr, timeScale: dur, doneAction: 2);
	Out.ar(efx, sig * emp);
	Out.ar(out, FoaTransform.ar(
		FoaEncode.ar(sig * amp, FoaEncoderMatrix.newDirection), 'rtt', rotx, roty, rotz)
	)
}).add;

SynthDef(\rev00, {|out, in, amp, rtime, hf|
	var input, sig;
	input = In.ar(in);
	sig = Reverb.ar(input, rtime, hf) * amp;
	Out.ar(out, FoaEncode.ar(sig, FoaEncoderMatrix.newOmni))
}).add;

SynthDef(\rev01, {|out, in, amp, room, rtime, damp, bw, spr, dry, early, tail|
	var input, sig;
	input = In.ar(in);
	sig = GVerb.ar(input, room, rtime, damp, bw, spr, dry, early, tail) * amp;
	Out.ar(out, FoaEncode.ar(sig, FoaEncoderMatrix.newStereo))
}).add;

SynthDef(\rev02, {|out, in, amp, room, rtime, damp, bw, spr, dry, early, tail, wsz, pch, pds, tds|
	var input, sig;
	input = In.ar(in);
	sig = GVerb.ar(input, room, rtime, damp, bw, spr, dry, early, tail) * amp;
	sig = PitchShift.ar(sig, wsz, pch, pds, tds) + sig;
	Out.ar(out, FoaEncode.ar(sig, FoaEncoderMatrix.newStereo))
}).add;

SynthDef(\del00, {|out, in, amp, del, dec, rmp, rt|
	var input, sig;
	input = In.ar(in);
	sig = CombC.ar(input, del, del, dec) * amp;
	sig = (Reverb.ar(sig * rmp, rt) + sig) * LFPulse.kr(1/del*2).range(0.2, 1.0);
	Out.ar(out, FoaEncode.ar(sig, FoaEncoderMatrix.newOmni))
}).add;

SynthDef(\del01, {|out, in, amp, del, grw, rmp, rt|
	var input, sig, n = 5;
	input = In.ar(in) * amp;
	sig = Mix.fill(n, {|i|
		DelayC.ar(input, del*(grw**n-1), del*(grw**i))
	});
	sig = Reverb.ar(sig * rmp, rt) + sig;
	Out.ar(out, FoaEncode.ar(sig, FoaEncoderMatrix.newOmni))
}).add;

SynthDef(\res00, {|out, in, amp|
	var input, sig, frqs, amps, rngs, n = 7;
	input = In.ar(in);
	frqs = ArrayControl.kr(\frqs, n, 0);
	amps = ArrayControl.kr(\amps, n, 0);
	rngs = ArrayControl.kr(\rngs, n, 0);
	sig = DynKlank.ar(`[frqs, amps, rngs], input) * amp;
	Out.ar(out, FoaEncode.ar(sig, FoaEncoderMatrix.newOmni))
}).add;

SynthDef(\hgv00, {|out, in, amp, rtime, dry, ear, tail, hf|
	var input, sig, fft;
	input = In.ar(in) * amp;
	sig = HPF.ar(GVerb.ar(input, 100, rtime, drylevel: dry, earlyreflevel: ear, taillevel: tail), hf);
	fft = FFT(LocalBuf(1024), sig);
	fft = PV_Diffuser(fft, Dust.ar(Array.rand(4, 10.0, 20.0)));
	Out.ar(out, FoaEncode.ar(IFFT(fft) * [(3/2).sqrt, 1, 1, 1], FoaEncoderMatrix.newAtoB));
}).add;

SynthDef(\frag00, {|out, buf, rate, loop=0, dur, ffrq, fwid, fflo, ffhi, amp=1, rotx, roty, rotz, done=2|
	var sig, enc, env;
	env = EnvGen.kr(EnvControl.kr, timeScale: dur, levelScale: amp, doneAction: 2);
	sig = PlayBuf.ar(1, buf, rate, loop: loop, doneAction: done) ** 0.5 * LFPulse.kr(ffrq, 0, fwid).range(fflo, ffhi) * env;
	enc = FoaEncode.ar(sig, FoaEncoderMatrix.newDirection);
	enc = FoaTransform.ar(enc, 'rtt', rotx, roty, rotz );
	Out.ar(out, enc);
}).add;

SynthDef(\frag01, {|out, buf, grate, gdlo, gdhi, rate, ffrq, fwid, fflo, ffhi, rmz, rev, ear, tai, dur, amp, rotx, roty, rotz, done=2|
	var env, sig, fft, enc, trg;
	trg = Impulse.kr(grate);
	env = EnvGen.kr(EnvControl.kr, timeScale: dur, levelScale: amp, doneAction: 2);
	sig = BufGrain.ar(trg, LFSaw.kr(grate).range(gdlo, gdhi), buf, rate, TRand.kr(0.0, 1.0, trg), 1);
	sig = GVerb.ar(sig, rmz, rev, earlyreflevel: ear, taillevel: tai) * env;
	enc = FoaEncode.ar(sig, FoaEncoderMatrix.newStereo);
	enc = FoaTransform.ar(enc, 'rtt', rotx, roty, rotz );
	Out.ar(out, enc)
}).add;

SynthDef(\frag02, {|out, buf, rate, warp, wisz, genv, wrnd, dens, intr, ffrq, fwid, fflo, ffhi, amp=1, dur, rotx, roty, rotz, done=2|
	var env, sig, fft, enc;
	env = EnvGen.kr(EnvControl.kr, timeScale: dur, levelScale: amp, doneAction: 2);
	sig = Warp1.ar(1, buf, LFSaw.kr(warp, 1).range(0, 1), rate, wisz, genv, dens, wrnd, intr) 
		* LFPulse.kr(ffrq, 0, fwid).range(fflo, ffhi) * env;
	enc = FoaEncode.ar(sig, FoaEncoderMatrix.newDirection);
	enc = FoaTransform.ar(enc, 'rtt', rotx, roty, rotz );
	Out.ar(out, enc);
}).add;

SynthDef(\frag03, {|out, buf, ffrq=1, fwid=0.5, fflo=0.5, ffhi=1, beatdur=0.5, amp=0.5, dur, rotx, roty, rotz, done=2|
	var env, sig, frq, n = 5, rate, fft, enc;
	env = EnvGen.kr(EnvControl.kr, timeScale: dur, doneAction: 2);
	frq = Array.geom(n, 1/n, 2);
	dur = BufDur.kr(buf);
	rate = dur/dur.round(beatdur).clip(beatdur/4, beatdur*4);
	sig = Mix(PlayBuf.ar(1, buf, frq * BufRateScale.kr(buf) * rate, loop: 1) * (-3.dbamp ! n))
		* LFPulse.kr(ffrq, 0, fwid).range(fflo, ffhi);
	fft = FFT(LocalBuf(1024), sig);
	enc = Array.fill(4, { IFFT(PV_Diffuser(fft, Dust.kr(1/beatdur))) }) * [(3/2).sqrt, 1, 1, 1];
	enc = FoaTransform.ar(enc * amp, 'rtt', rotx, roty, rotz );
	Out.ar(out, enc * env)
}).add;

SynthDef(\frag04, {|out, in, efx, amp, dur, rate, emp, buf, rotx, roty, rotz|
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate)
		* EnvGen.kr(EnvControl.kr, timeScale: dur, doneAction: 2);
	Out.ar(efx, sig * emp);
	Out.ar(out, FoaTransform.ar(
		FoaEncode.ar(sig * amp, FoaEncoderMatrix.newDirection), 'rtt', rotx, roty, rotz)
	)
}).add;

SynthDef(\mfcc, {|in, th|
	var fft, mfcc, onsets;
	fft = FFT(LocalBuf(1024), In.ar(in));
	mfcc = MFCC.kr(fft, 8);
	onsets = Onsets.kr(fft, th);
	SendReply.kr(onsets, '/mfcc', mfcc);
}).add;

