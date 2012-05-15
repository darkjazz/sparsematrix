~app = FunktApp(800, 600, mode: 0);

~app.open;

~app.initWorld(24, 24, 8, 2000, 0.1)

~app.setPattern(8, 1, 1.0, 1, 1);
~app.setPattern(10, 0, 1.0, 1, 1);


~app.setPattern(8, 1, 1.0, 0, 0);

~app.setPattern(0, alphamap: 1, colormap: 1);
~app.setPattern(0, 0, 1.0, 0, 0);

~app.changeSetting(\add, 0.01)

~app.changeSetting(\symmetry, 4)

~app.setPattern(1, 0, 1.0, 1, 1);


~app.quit

~app.changeSetting(\interp, [2, 2])


(
{
200.do({
	~app.sendWeights(*Array.rand(8, 0.0, 1.0));
	0.2.wait;
});
"finished".postln
}.fork
)


~app.initWorld(32, 32, 8, 2000, 0.1)


~app.sendPresetRule(\xtasy)

~app.changeSetting(\rule, 1)

~app.setPattern(14, 1, 1.0, 0, 0);
~app.setPattern(8, alphamap: 0, colormap: 0);

