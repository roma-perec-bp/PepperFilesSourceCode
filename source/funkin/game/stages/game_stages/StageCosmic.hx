package funkin.game.stages.game_stages;

import funkin.game.stages.objects.*;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import funkin.graphics.shaders.AdjustColorShader;
import funkin.graphics.shaders.ExtraDropShadowShader;

import funkin.menus.FullScreenScaleMode;

import funkin.backend.FlxTransWindow;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

import openfl.Lib;

import funkin.graphics.shaders.LastStandShaders;

import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;
import funkin.graphics.shaders.BloomedShader;

import funkin.utils.PlatformUtil;

class StageCosmic extends BaseStage
{
	var sad:FlxSprite;
	var _emitter:FlxEmitter;

	var dontFull:Bool = false;

	var bg:BGSprite;
	var ground:BGSprite;

	public var grad:FlxSprite;
	var curLight:Int = -1;

	var canGlow:Bool = false;

	public var originalY:Float;
	public var originalHeight:Int = 1400;
	public var intendedAlpha:Float = 1;

	var phillyLightsColors:Array<FlxColor>;

	var dadShade = new AdjustColorShader();
	var bfShade = new AdjustColorShader();
	var bgShade = new AdjustColorShader();

	public var updateiTimeHARD:Array<Dynamic> = [];

	var bfShadow:ExtraDropShadowShader;
	var dadShadow:ExtraDropShadowShader;

	var nword:FlxSprite;

	var vin:FlxSprite;
	var windowsShit:FlxSprite;

	var artefact:FlxSprite;

	public var followedGlitchShader3:GlitchShader2;

	var bloomShader:BloomedShader = null;
	override function create()
	{
		windowsShit = new FlxSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeGraphic(Std.int(FlxG.width * 5), Std.int(FlxG.height * 5), FlxColor.fromRGB(1, 1, 1));
		windowsShit.scrollFactor.set();
		add(windowsShit);

		bg = new BGSprite('cosmic/bg', -1648, -1000, 0.15, 0.15);
		bg.updateHitbox();
		add(bg);

		grad = new FlxSprite(-1000, -300).loadGraphic(Paths.image('cosmic/gradient'));
		grad.scrollFactor.set(0, 1);
		grad.setGraphicSize(3000, originalHeight);
		grad.updateHitbox();
		grad.visible = false;
		grad.color = 0xFF44145f;
		add(grad);

		ground = new BGSprite('cosmic/grasswalk', -1348, -336);
		ground.scale.set(2,2);
		ground.updateHitbox();
		add(ground);

		nword = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		nword.scrollFactor.set(0, 0);
		nword.alpha = 1;
		nword.scale.set(5, 5);
		add(nword);

		artefact = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		artefact.loadGraphic(Paths.image('cosmic/artefact'), true, 100, 100);
		artefact.animation.add('idle', [0, 1, 2, 3], 12, true);
		artefact.animation.play('idle');
		artefact.antialiasing = false;
		artefact.scrollFactor.set(0.7, 0.7);

		artefact.x -= 450;
		artefact.y -= 250;
		artefact.color = 0xFF000000;

		artefact.setGraphicSize(Std.int(artefact.width * 6));
		artefact.updateHitbox();
		add(artefact);
		artefact.alpha = 0.0001;

		// Here we actually initialize out emitter
		// The parameters are X, Y and Size (Maximum number of particles the emitter can store)
		// This emitter will start right in the middle of the screen.

		_emitter = new FlxEmitter(FlxG.width / 2, FlxG.height / 2, 1000);
		_emitter.x -= 150;

		// All we need to do to start using it is give it some particles. makeParticles() makes this easy!

		_emitter.makeParticles(50, 50, FlxColor.WHITE, 5000);

		// Now let's add the emitter to the state.

		add(_emitter);

		_emitter.alpha.set(1, 1, 0, 0);
		_emitter.lifespan.set(10, 10);
		_emitter.speed.set(500, 1000);

		originalY = grad.y;
		phillyLightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];

		sad = new FlxSprite(0, 0).loadGraphic(Paths.image('cosmic/sad'));
		sad.antialiasing = ClientPrefs.data.antialiasing;
		sad.setGraphicSize(Std.int(FlxG.width));
		sad.updateHitbox();
		sad.cameras = [game.camVideoMid];
		sad.alpha = 0.0001;
		add(sad);
	}

	override function createPost()
	{
		dadShade = new AdjustColorShader();
		dadShade.brightness = -39;
    	dadShade.hue = -43;
    	dadShade.contrast = -45;
		dadShade.saturation = -22;

		bfShade = new AdjustColorShader();
		bfShade.brightness = -39;
    	bfShade.hue = -43;
    	bfShade.contrast = -45;
		bfShade.saturation = -22;

		bgShade = new AdjustColorShader();
		bgShade.brightness = -39;
    	bgShade.hue = 43;
    	bgShade.contrast = -45;
		bgShade.saturation = -22;

		//dad.shader = dadShade;
		//boyfriend.shader = bfShade;
		ground.shader = bgShade;

		vin = new FlxSprite().loadGraphic(Paths.image('darkerVG'));
		vin.updateHitbox();
		vin.setGraphicSize(FlxG.width, FlxG.height);
		vin.screenCenter();
		vin.cameras = [camOther];
		vin.alpha = 1;
		add(vin);

		dad.animSuffix = '-dark';
		dad.recalculateDanceIdle();

		bfShadow = new ExtraDropShadowShader();
	
		bfShadow.threshold = .03;
		bfShadow.setHollowColorMatrix([
			0, 0, 0, 0, 255,
			0, 0, 0, 0, 255,
			0, 0, 0, 0, 255,
			0, 0, 0, 1, 0
		]);
		bfShadow.setColorMatrix([
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 1, 0
		]);
		bfShadow.antialiasStages = 4;

		bfShadow.addLayer([
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 1, 0
		], -70, 22, 0);
		bfShadow.addLayer([
			0, 0, 0, 0, 255,
			0, 0, 0, 0, 255,
			0, 0, 0, 0, 255,
			0, 0, 0, 1, 0
		], 140, 10, 0);
		bfShadow.addLayer([
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 1, 0
		], -32, 12, 0);

		dadShadow = new ExtraDropShadowShader();
	
		dadShadow.threshold = .03;
		dadShadow.setHollowColorMatrix([
			0, 0, 0, 0, 255,
			0, 0, 0, 0, 255,
			0, 0, 0, 0, 255,
			0, 0, 0, 1, 0
		]);
		dadShadow.setColorMatrix([
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 1, 0
		]);
		dadShadow.antialiasStages = 4;

		dadShadow.addLayer([
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 1, 0
		], -70, 22, 0);
		dadShadow.addLayer([
			0, 0, 0, 0, 255,
			0, 0, 0, 0, 255,
			0, 0, 0, 0, 255,
			0, 0, 0, 1, 0
		], 140, 10, 0);
		dadShadow.addLayer([
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 1, 0
		], -32, 12, 0);

		bfShadow.attachedSprite = boyfriend;
		dadShadow.attachedSprite = dad;

		boyfriend.shader = bfShadow;
		dad.shader = dadShadow;

		FlxTransWindow.getWindowsTransparent();
		FlxTransWindow.getWindowsbackward();

		if (!ClientPrefs.data.lowQuality)
		{
			if(ClientPrefs.data.flashing && ClientPrefs.data.shaders)
				bloomShader = new BloomedShader();
		}

		if (ClientPrefs.data.shaders) {
			followedGlitchShader3 = new GlitchShader2();
			updateiTimeHARD.push(followedGlitchShader3);
			followedGlitchShader3.amount = 0.0;
		}
	}

	var titleTimer:Float = 0;
	override function update(elapsed:Float)
	{
		if(canGlow)
		{
			var newHeight:Int = Math.round(grad.height - 1000 * elapsed);
			if(newHeight > 0)
			{
				grad.alpha = intendedAlpha;
				grad.setGraphicSize(3000, newHeight);
				grad.updateHitbox();
				grad.y = originalY + (originalHeight - grad.height);
			}
			else
			{
				grad.alpha = 0;
				grad.y = -5000;
			}
		}

		if(dontFull && openfl.Lib.application.window.fullscreen && !Lib.application.window.maximized) 
		{
			openfl.Lib.application.window.fullscreen = false;
			Lib.application.window.maximized = true;
		}

		if (ClientPrefs.data.shaders) {
			var trueElapsed:Float = (elapsed / (1 / 60));
			for (i in updateiTimeHARD) i.update(elapsed);
		}
	}

	override function beatHit()
	{
		if(!ClientPrefs.data.lowQuality)
		{
			if(canGlow)
			{
				grad.setGraphicSize(3000, originalHeight);
				grad.updateHitbox();
				grad.y = originalY;
				grad.alpha = intendedAlpha;
	
				curLight = FlxG.random.int(0, phillyLightsColors.length - 1, [curLight]);
				grad.color = phillyLightsColors[curLight];
			}
		}
	}

	var lastFull:Bool = openfl.Lib.application.window.fullscreen;
	var lastMax:Bool = Lib.application.window.maximized;

	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Hell Valley Events':
				switch(value1)
				{
					case 'light':
						canGlow = !canGlow;
						grad.visible = !grad.visible;

					case 'start':
						dad.shader = dadShade;
						boyfriend.shader = bfShade;
						nword.alpha = 0.0001;
						dad.animSuffix = '-reverse';
						dad.recalculateDanceIdle();
					
					case 'transparent':
						openfl.Lib.application.window.fullscreen = false;
						Lib.application.window.maximized = true;
						dontFull = true;
						FlxTransWindow.getWindowsTransparent();
						game.topBar.visible = false;
						game.bottomBar.visible = false;

						vin.visible = false;
						artefact.alpha = 1;

					case 'back trans':
						dontFull = false;
						Lib.application.window.maximized = lastMax;
						openfl.Lib.application.window.fullscreen = lastFull;
						FlxTransWindow.getWindowsbackward();
						game.topBar.visible = true;
						game.bottomBar.visible = true;

					case 'stage bye':
						bg.visible = false;
						ground.visible = false;

					case 'showtime':
						PlatformUtil.sendWindowsNotification("Perec.HUI", "It's SHOWTIME!");

					case 'peak':
						artefact.color = 0xFFFFFFFF;
						if (!ClientPrefs.data.lowQuality)
						{
							_emitter.start(false, 0.01);
							if(ClientPrefs.data.flashing && ClientPrefs.data.shaders)
							{
								camGame.filters = [new ShaderFilter(bloomShader)];
							}
						}

					case 'last':
						game.camVideoMid.shake(0.01, 0.2);
						sad.alpha = 1;
						FlxTween.tween(sad, {alpha: 0}, 0.6, {startDelay: 0.2});
						FlxTween.tween(sad.scale, {x: 1.2, y: 1.2}, 0.2, {ease:FlxEase.expoOut});
						artefact.alpha = 0.0001;
						_emitter.visible = false;
						camGame.filters = [];
						windowsShit.visible = false;

					case 'bye':
						FlxTween.tween(dad, {alpha: 0}, 3, {ease: FlxEase.expoIn});

						if (ClientPrefs.data.shaders) {
							dad.shader = followedGlitchShader3;

							FlxTween.num(0, 10, 3, {ease: FlxEase.expoIn}, function(thr:Float) 
							{ 
								followedGlitchShader3.amount = thr;
							});
						}
				}	
		}
	}

	override function destroy()
	{
		FlxTransWindow.getWindowsTransparent();
		FlxTransWindow.getWindowsbackward();
	}

	override function onGameOver()
	{
		FlxTransWindow.getWindowsTransparent();
		FlxTransWindow.getWindowsbackward();
	}
}