package funkin.game.stages.game_stages;

import funkin.game.stages.objects.*;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import funkin.submenus.gameover.GameOverSubstate;
import funkin.game.objects.Character;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import funkin.objects.AnekdotNote;
import funkin.game.notes.Note;

import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import flixel.system.FlxAssets.FlxShader;

import funkin.graphics.shaders.*;
import funkin.graphics.shaders.LastStandShaders;

import funkin.audio.FunkinSound;
import flixel.addons.display.FlxBackdrop;

import openfl.filters.ShaderFilter;

import funkin.vis.dsp.SpectralAnalyzer;
import flixel.addons.display.FlxRuntimeShader;

class StageFollowed extends BaseStage
{
	public var gameShaders:Array<BitmapFilter> = [];
	public var hudShaders:Array<BitmapFilter> = [];

	var curColor:FlxColor = 0xFFFF0000;

	var stage1Hell:BGSprite;
	var stage2Hell:BGSprite;

	var bars:Array<FlxSprite> = [];
	var analyzer:SpectralAnalyzer = null;
	var barHeights:Array<Float> = [];
	static inline var NUM_BARS:Int = 67;
	static var BURST_SIZES:Array<Float> = [1.0, 1.3, 0.7, 0.8, 0.6, 1.5];
	var soundwaveOn:Bool = false;
	var swKhz:Float = 0; var swCh:Int = 0; var swBts:Dynamic = null;
	var roof:BGSprite;
	var bg:BGSprite;
	var vin:FlxSprite;

	var die:FlxSprite;

	var shockLook:Bool = false;

	var stars:FlxBackdrop;
	var cloud:FlxBackdrop;
	var scanlines:BGSprite;

	var particles:FlxSprite;
	var hwawTime:Bool = false;
	var phase:Int = 0;

	public var followedTween:FlxTween;
	public var followedTween2:FlxTween;

	public var notesString:Array<String> = ['left', 'down', 'up', 'right'];

	var eyeCenter:FlxSprite;
	var aethosNotes:Bool = true;
	var notesFly:Bool = false;

	var notesCamGroup:FlxTypedGroup<FlxSprite>;
	
	var titleTextColors:Array<FlxColor> = [0xffFFFFFF, 0xFF666666];

	public var glitchShader:GlitchShaderA;
	public var glitchShader2:FollowedGlitch;
	public var glitchShader3:Glitch2;
	public var followedGlitchShader3:GlitchShader2;
	public var followedIntenseChromaticAbb:CabinetGlitchChrom;

	public var updateiTime:Array<FlxRuntimeShader> = [];
	public var updateiTimeHARD:Array<Dynamic> = [];

	override function create()
	{
		for (i in 0...5)
			Paths.image('noteAnekdot/note_' + i);

		bg = new BGSprite('follow/ahuetSTATIC', -200, -100, 0.3, 0.3, ['staticBackground'], true);
		bg.setGraphicSize(Std.int(bg.width * 3));
		bg.zIndex = 1;
		add(bg);

		stars = new FlxBackdrop(Paths.image('follow/stars'));
		stars.setGraphicSize(Std.int(stars.width * 3));
		stars.zIndex = 2;
		stars.alpha = 0.0001;
		stars.scrollFactor.set(0.3, 0.3);
		stars.velocity.set(200, -100);
		add(stars);

		scanlines = new BGSprite('follow/scanline', 0, 0, 0, 0);
		scanlines.setGraphicSize(Std.int(scanlines.width * 3));
		scanlines.zIndex = 3;
		scanlines.alpha = 0.0001;
		add(scanlines);

		die = new BGSprite('follow/die', 0, 0, 0, 0);
		die.setGraphicSize(Std.int(die.width * 3));
		die.zIndex = 4;
		die.alpha = 0.0001;
		add(die);

		cloud = new FlxBackdrop(Paths.image('follow/clouds'));
		cloud.setGraphicSize(Std.int(cloud.width * 3));
		cloud.zIndex = 5;
		cloud.alpha = 0.0001;
		cloud.scrollFactor.set(0.1, 0.1);
		cloud.velocity.set(2000, 0);
		add(cloud);

		if(!ClientPrefs.data.lowQuality)
		{
			buildBars();

			notesCamGroup = new FlxTypedGroup<FlxSprite>();
			notesCamGroup.zIndex = 25;
			add(notesCamGroup);
		}

		roof = new BGSprite('follow/home', 0, 0);
		roof.setGraphicSize(Std.int(roof.width * 3));
		roof.color = 0xFFFF0000;
		roof.zIndex = 50;
		add(roof);

		stage1Hell = new BGSprite('follow/shit');
		stage1Hell.alpha = 0.001;
		add(stage1Hell);

		stage2Hell = new BGSprite('follow/shit');
		stage2Hell.alpha = 0.001;
		add(stage2Hell);

		stage2Hell.zIndex = 55;
		stage1Hell.zIndex = 55;

		eyeCenter = new FlxSprite(game.GF_X - 365, game.GF_Y);
		eyeCenter.frames = Paths.getSparrowAtlas('follow/eyes_center');
		eyeCenter.animation.addByPrefix('lookLeft', "eye_look_left", 24, false);
		eyeCenter.animation.addByPrefix('lookRight', "eye_look_right", 24, false);
		eyeCenter.animation.addByPrefix('center', "eye_look_centered", 24, true);
		eyeCenter.animation.play('lookLeft');
		eyeCenter.antialiasing = ClientPrefs.data.antialiasing;
		eyeCenter.color = 0xFFFF0000;
		eyeCenter.updateHitbox();
		eyeCenter.scrollFactor.set(1, 1);
		eyeCenter.zIndex = 60;
		add(eyeCenter);

		if(!ClientPrefs.data.lowQuality)
		{
			particles = new FlxSprite(game.DAD_X - 150, game.DAD_Y);
			particles.frames = Paths.getSparrowAtlas('follow/Particles');
			particles.animation.addByPrefix('splash', "Anim", 24, false);
			particles.animation.play('splash');
			particles.antialiasing = ClientPrefs.data.antialiasing;
			particles.color = 0xFFFF0000;
			particles.updateHitbox();
			particles.scrollFactor.set(1, 1);
			particles.scale.set(2,2);
			particles.zIndex = 560;
			add(particles);
			particles.alpha = 0.00001;
	
			particles.animation.finishCallback = function(pog:String)
			{
				particles.alpha = 0.00001;
			}
		}
	}

	override function createPost()
	{
		vin = new FlxSprite().loadGraphic(Paths.image('darkerVG'));
		vin.updateHitbox();
		vin.setGraphicSize(FlxG.width, FlxG.height);
		vin.screenCenter();
		vin.cameras = [camOther];
		vin.alpha = 1;
		add(vin);

		dadGroup.zIndex = 500;
		secondGroup.zIndex = 550;
		boyfriendGroup.zIndex = 600;
		gfGroup.zIndex = 40;

		dad.color = 0xFFFF0000;
		second.color = 0xFFFF0000;
		boyfriend.color = 0xFFFF0000;
		gf.color = 0xFFFF0000;

		camHUD.alpha = 0;
		camNotes.alpha = 0;

		stage1Hell.x = game.DAD_X - 65;
		stage1Hell.y = game.DAD_Y + 550;

		stage2Hell.x = game.BF_X - 65;
		stage2Hell.y = game.BF_Y + 550;

		if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality) {
			glitchShader = new GlitchShaderA();
			glitchShader2 = new FollowedGlitch();
			glitchShader3 = new Glitch2();
			glitchShader3.glitchy = 0;
			followedGlitchShader3 = new GlitchShader2();
			followedIntenseChromaticAbb = new CabinetGlitchChrom();
			followedIntenseChromaticAbb.amount = 0;
			followedIntenseChromaticAbb.speed = 0;

			updateiTimeHARD.push(followedIntenseChromaticAbb);
			updateiTimeHARD.push(glitchShader);	
			updateiTimeHARD.push(followedGlitchShader3);
			updateiTimeHARD.push(glitchShader3);
			followedGlitchShader3.amount = 0.0;
			glitchShader.glitchEffect = 0.00001;

			// chromaticShaderCash = new ChromaticAbb();
			// chromaticShaderCash.strength = 0;
			//game.addShader(chromaticShaderCash);

			dad.shader = glitchShader;

			camGame.filters = gameShaders;
			camHUD.filters = hudShaders;
		}

		game.refresh();
	}

	var titleTimer:Float = 0;
	override function update(elapsed:Float)
	{
		if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality) {
			var trueElapsed:Float = (elapsed / (1 / 60));
			for (i in updateiTime) i.setFloat('iTime', i.getFloat('iTime') + elapsed);
			for (i in updateiTimeHARD) i.update(elapsed);
		}

		if(!ClientPrefs.data.lowQuality)
		{
			@:privateAccess
			if (soundwaveOn && bars.length > 0) {
				var swSm:Float = 1 - Math.pow(0.9, elapsed * 60);
				try {
				  var snd = FlxG.sound.music;
				  if (swBts == null && snd != null && snd._sound != null && snd._sound.__buffer != null && snd._sound.__buffer.data != null) {
					var buf0 = snd._sound.__buffer;
					swKhz = buf0.sampleRate / 1000;
					swCh = buf0.channels;
					swBts = buf0.data.buffer;
				  }
				  if (swBts != null && snd != null) {
					var khz:Float = swKhz;
					var channels:Int = swCh;
					var bts = swBts;
					var index:Int = Std.int(snd.time * khz);
					var i2:Int = 0;
					while (i2 < bars.length) {
					  var sampleIndex:Int = index + ((i2 + 1) * 100);
					  var pos:Int = sampleIndex * channels * 2;
					  var byte:Float = 0;
					  if (pos >= 0 && pos < bts.length - 2) byte = bts.getUInt16(pos);
					  if (byte > 32767) byte = byte - 65535;
					  if (byte < 0) byte = -byte;
					  var targetHeight:Float = byte / 32767 * 1.5 * 2000;
					  if (targetHeight < 0) targetHeight = 0;
					  barHeights[i2] += (targetHeight - barHeights[i2]) * swSm;
					  var finalScale:Float = barHeights[i2];
					  if (finalScale < 0.001) finalScale = 0.001;
					  bars[i2].scale.y = finalScale / 40 + 1;
					  i2++;
					}
				  }
				} catch (e:Dynamic) {}
			}
		}
		
		super.update(elapsed);

		titleTimer += FlxMath.bound(elapsed, 0, 3);
		if (titleTimer > 2) titleTimer -= 2;

		var timer:Float = titleTimer;
		if (timer >= 1)
			timer = (-timer) + 2;
			
		timer = FlxEase.quadInOut(timer);
			
		bg.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
	}

	var lookingLeft:Bool = true;
	override function sectionHit()
	{
		if(!shockLook)
		{
			if(game.curFocusedChar == 'bf' && lookingLeft)
			{
				lookingLeft = false;
				eyeCenter.animation.play('lookRight');
			}
			else if(game.curFocusedChar == 'dad' && !lookingLeft)
			{
				lookingLeft = true;
				eyeCenter.animation.play('lookLeft');
			}
			else if(game.curFocusedChar == 'gf' && !lookingLeft)
			{
				lookingLeft = true;
				eyeCenter.animation.play('lookLeft');
			}
		}

		if(!ClientPrefs.data.lowQuality)
		{
			if(notesFly)
			{
				for (i in 0...8) notesAppearAlt(FlxG.random.int(0,3));
			}
		}
	}

	var danceLeft:Bool = false;
	override function beatHit()
	{
		if (curBeat % game.cameraZoomRate == 0 && ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality) {
			followedGlitchShader3.amount = 0.05;
			if (followedTween != null) followedTween.cancel();
			followedTween = FlxTween.num(0.05, game.dad.curCharacter == 'mimic-hwaw' ? 0.002 : 0.004, 0.5, {ease: FlxEase.backOut}, function(thr:Float) 
			{ 
				followedGlitchShader3.amount = thr;
			});
		}

		if(hwawTime == true && ClientPrefs.data.flashing)
		{
			if(danceLeft == true)
			{
				danceLeft = false;
				dad.colorTransform.redOffset = 255;
				dad.colorTransform.greenOffset = 0;
				dad.colorTransform.blueOffset = 255;

				dad.colorTransform.redMultiplier = 0;
				dad.colorTransform.greenMultiplier = 0;
				dad.colorTransform.blueMultiplier = 0;

				boyfriend.colorTransform.redOffset = 255;
				boyfriend.colorTransform.greenOffset = 0;
				boyfriend.colorTransform.blueOffset = 255;

				boyfriend.colorTransform.redMultiplier = 0;
				boyfriend.colorTransform.greenMultiplier = 0;
				boyfriend.colorTransform.blueMultiplier = 0;

				roof.color = 0xFFFF00FF;
				eyeCenter.color = 0xFFFF00FF;
				die.alpha = 0.0001;
			}
			else
			{
				danceLeft = true;
				die.alpha = 1;
				dad.colorTransform.redOffset = 255;
				dad.colorTransform.greenOffset = 0;
				dad.colorTransform.blueOffset = 0;

				dad.colorTransform.redMultiplier = 0;
				dad.colorTransform.greenMultiplier = 0;
				dad.colorTransform.blueMultiplier = 0;

				boyfriend.colorTransform.redOffset = 255;
				boyfriend.colorTransform.greenOffset = 0;
				boyfriend.colorTransform.blueOffset = 0;

				boyfriend.colorTransform.redMultiplier = 0;
				boyfriend.colorTransform.greenMultiplier = 0;
				boyfriend.colorTransform.blueMultiplier = 0;

				eyeCenter.color = 0xFFFF0000;
				roof.color = 0xFFFF0000;
			}
		}
	}

	var eventCounter:Int = 0;
	var followedGlitch:FlxTween; //this like sucsk to do but im trying to be fast so sorry mb
	var followedShaderTween:FlxTween;
	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Change Character':
				switch(value2)
				{
					case 'mimic-rokkie':
						dad.colorTransform.redOffset = 255;
						dad.colorTransform.greenOffset = 92;
						dad.colorTransform.blueOffset = 0;
		
						dad.colorTransform.redMultiplier = 0;
						dad.colorTransform.greenMultiplier = 0;
						dad.colorTransform.blueMultiplier = 0;

						boyfriend.colorTransform.redOffset = 255;
						boyfriend.colorTransform.greenOffset = 92;
						boyfriend.colorTransform.blueOffset = 0;
		
						boyfriend.colorTransform.redMultiplier = 0;
						boyfriend.colorTransform.greenMultiplier = 0;
						boyfriend.colorTransform.blueMultiplier = 0;

						if(!ClientPrefs.data.lowQuality) dad.shader = followedGlitchShader3;

						eyeCenter.color = 0xFFff5c00;
						roof.color = 0xFFff5c00;
						curColor = 0xFFff5c00;
						notesFly = true;

						stars.alpha = 1;
						scanlines.alpha = 0.3;
						stars.color = 0xFFff5c00;
						scanlines.color = 0xFFff5c00;
					case 'mimic-random-alt':
						dad.colorTransform.redOffset = 53;
						dad.colorTransform.greenOffset = 9;
						dad.colorTransform.blueOffset = 52;
		
						dad.colorTransform.redMultiplier = 0;
						dad.colorTransform.greenMultiplier = 0;
						dad.colorTransform.blueMultiplier = 0;

						boyfriend.colorTransform.redOffset = 53;
						boyfriend.colorTransform.greenOffset = 9;
						boyfriend.colorTransform.blueOffset = 52;
		
						boyfriend.colorTransform.redMultiplier = 0;
						boyfriend.colorTransform.greenMultiplier = 0;
						boyfriend.colorTransform.blueMultiplier = 0;

						if(!ClientPrefs.data.lowQuality) dad.shader = followedGlitchShader3;

						eyeCenter.color = 0xFF350934;
						roof.color = 0xFF350934;
						curColor = 0xFF350934;
						stars.color = 0xFF350934;
						scanlines.color = 0xFF350934;
					case 'mimic-lork':
						dad.colorTransform.redOffset = 89;
						dad.colorTransform.greenOffset = 255;
						dad.colorTransform.blueOffset = 0;
		
						dad.colorTransform.redMultiplier = 0;
						dad.colorTransform.greenMultiplier = 0;
						dad.colorTransform.blueMultiplier = 0;

						boyfriend.colorTransform.redOffset = 89;
						boyfriend.colorTransform.greenOffset = 255;
						boyfriend.colorTransform.blueOffset = 0;
		
						boyfriend.colorTransform.redMultiplier = 0;
						boyfriend.colorTransform.greenMultiplier = 0;
						boyfriend.colorTransform.blueMultiplier = 0;

						if(!ClientPrefs.data.lowQuality) dad.shader = followedGlitchShader3;

						eyeCenter.color = 0xFF59ff00;
						roof.color = 0xFF59ff00;
						curColor = 0xFF59ff00;
						stars.color = 0xFF59ff00;
						scanlines.color = 0xFF59ff00;
					case 'mimic-hwaw':
						dad.colorTransform.redOffset = 255;
						dad.colorTransform.greenOffset = 0;
						dad.colorTransform.blueOffset = 0;
		
						dad.colorTransform.redMultiplier = 0;
						dad.colorTransform.greenMultiplier = 0;
						dad.colorTransform.blueMultiplier = 0;

						boyfriend.colorTransform.redOffset = 255;
						boyfriend.colorTransform.greenOffset = 0;
						boyfriend.colorTransform.blueOffset = 0;
		
						boyfriend.colorTransform.redMultiplier = 0;
						boyfriend.colorTransform.greenMultiplier = 0;
						boyfriend.colorTransform.blueMultiplier = 0;

						if(!ClientPrefs.data.lowQuality) dad.shader = followedGlitchShader3;

						eyeCenter.color = 0xFFFF0000;
						roof.color = 0xFFFF0000;

						hwawTime = true;
						notesFly = false;
						aethosNotes = true;

						stars.visible = false;
						scanlines.visible = false;

						shockLook = true;

						eyeCenter.animation.play('center');
					default:
						if (phase == 0)
						{
							dad.color = 0xFFFF0000;
							boyfriend.color = 0xFFFF0000;
							gf.color = 0xFFFF0000;
							second.color = 0xFFFF0000;
						}
						else
						{
							dad.color = 0xFF666666;
							boyfriend.color = 0xFF666666;
							gf.color = 0xFF666666;
							second.color = 0xFF666666;
						}

						if(!ClientPrefs.data.lowQuality) dad.shader = glitchShader;
						//dad.filters = [followedGlitchShader3Filter];
				}

			case 'followedGlitchTrans':
				if (Std.parseInt(value1) != 8) return;
				if (!ClientPrefs.data.shaders) return;
				if (ClientPrefs.data.lowQuality) return;
				
				switch (Std.parseInt(value1)) {
					case 0: //apply shader 
						addShader(glitchShader2);
					case 1: //remove shader
						removeShader(glitchShader2);
					case 2: //edit shader value
						glitchShader2.squareAmount = Std.parseFloat(value2);
						glitchShader2.iTime = Std.parseFloat(value2)*5;
					case 3:
						game.cameraZoomRate = Std.parseInt(value2);
					case 4: 
						removeShader(followedGlitchShader3);
					case 5:
						addShader(followedIntenseChromaticAbb);
					case 6:
						removeShader(followedIntenseChromaticAbb);	
					case 7:
						FlxTween.num(followedIntenseChromaticAbb.amount, 0.15, Std.parseFloat(value2.split(',')[2]), {ease: FlxEase.sineIn}, function(v)
						{
							followedIntenseChromaticAbb.amount = v;
						});

						FlxTween.num(followedIntenseChromaticAbb.speed, 0.6, Std.parseFloat(value2.split(',')[2]), {ease: FlxEase.sineIn}, function(v)
						{
							followedIntenseChromaticAbb.speed = v;
						});

					case 8:
						if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality) {
							var mosaic = new MosiacShader();
							mosaic.pixelSize = Std.parseFloat(value2.split(',')[0]);
							addShader(mosaic);

							FlxTween.num(mosaic.pixelSize, Std.parseFloat(value2.split(',')[1]), Std.parseFloat(value2.split(',')[2]), {ease: FlxEase.sineIn, 
							onComplete: function (f:FlxTween)
							{
								removeShader(mosaic);
								mosaic = null;
							}}, function(v)
							{
								mosaic.pixelSize = v;
							});
						}

				}

				case 'followedCamShake' | 'camShakeTween':
				@:privateAccess {
					if (value1.split(',')[1] == null) {
						camGame._fxShakeDuration = Std.parseFloat(value1);
						camGame._fxShakeIntensity = 0;
						FlxTween.tween(camGame, {_fxShakeIntensity: Std.parseFloat(value2)}, Std.parseFloat(value1), {ease: FlxEase.sineInOut, onComplete: function (f:FlxTween) {
							camGame._fxShakeIntensity = 0;
						}});
					}
				}

				case 'followedGlitch':
					if (!ClientPrefs.data.shaders) return;
					if (ClientPrefs.data.lowQuality) return;

					if (followedGlitch != null) followedGlitch.cancel();
					var val:Float = Std.parseFloat(value1);
					if (Math.isNaN(val)) val = 0.5;
					glitchShader.glitchEffect = val;

					followedGlitch = FlxTween.num(val, 0.00001, 1, {ease: FlxEase.sineOut}, function(v)
					{
						glitchShader.glitchEffect = v;
					});
	
				case 'followedFlicker' | 'toggleCamVisible':
					if (eventName == 'followedFlicker' && !ClientPrefs.data.flashing) return; 
					camGame.visible = !camGame.visible;

				case 'followedBack':
					camGame.flash(FlxColor.BLACK);

					camGame.visible = true;
					
					if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality) {
						addShader(followedIntenseChromaticAbb);
						followedIntenseChromaticAbb.amount = 0.0;
						followedIntenseChromaticAbb.speed = 0.6;
						if (ClientPrefs.data.flashing) 
							FlxTween.num(followedIntenseChromaticAbb.amount, 0.02, 12, function(v)
							{
								followedIntenseChromaticAbb.amount = v;
							});

						glitchShader2.squareAmount = 0;
						glitchShader2.glowAmount = 0;		
						updateiTimeHARD.push(glitchShader2);

						FlxTween.num(glitchShader2.squareAmount, 0.04, 5, {startDelay: 5}, function(v)
						{
							glitchShader2.squareAmount = v;
						});
					}

				case 'last stand events':
					switch(value1)
					{
						case 'bars':
							FlxTween.tween(game.topBar, {y: game.topBar.y + 100}, 3, {ease: FlxEase.expoOut});
							FlxTween.tween(game.bottomBar, {y: game.bottomBar.y - 100}, 3, {ease: FlxEase.expoOut});
						
						case 'viz':
							soundwaveOn = !soundwaveOn;

						case 'notes':
							aethosNotes = !aethosNotes;

						case 'transition_1':
							FlxTween.tween(bg, {alpha: 0}, 3);

						case 'splash':
							if(ClientPrefs.data.lowQuality) return;

							particles.alpha = 1;
							particles.animation.play('splash');

							particles.animation.finishCallback = function(pog:String)
							{
								particles.alpha = 0.00001;
							}

						case 'eye_dissapear':
							FlxTween.tween(eyeCenter, {alpha: 0}, 1);

						case 'eye_appear':
							FlxTween.tween(eyeCenter, {alpha: 1}, 1);

						case 'pizdec':
							notesFly = false;

						case 'clouds':
							cloud.alpha = 1;

						case 'dark':
							FlxTween.tween(cloud, {alpha: 0}, 1);
						
						case 'end':
							aethosNotes = false;
							stage1Hell.alpha = 0.0001;
							stage2Hell.alpha = 0.0001;
							dad.color = 0xFFFFFFFF;
					}

				case 'followedScenes': //this is poopy but whatever
					switch (eventCounter) {
						case 1: //fancy bump
							if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality) {
								var shader = new FollowedGlitch();
								addShader(shader);
								shader.glowAmount = 0;

								FlxTween.num(shader.glowAmount, 0.5, 1.4, {ease: FlxEase.sineInOut, onComplete: function (f:FlxTween)
								{
									removeShader(shader);
								}}, function(v)
								{
									shader.glowAmount = v;
								});
							}
	
						case 3: //into the second phase
							if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality) {
								var shader = new FollowedGlitch();
								addShader(shader);
								shader.glowAmount = 0;
								FlxTween.num(shader.glowAmount, 0.3, 0.5, {ease: FlxEase.sineInOut, onComplete: function (f:FlxTween)
								{
									removeShader(shader);
								}}, function(v)
								{
									shader.glowAmount = v;
								});
							}

						case 10: //end foxy go black
							phase++;
							camGame.visible = false;
							hwawTime = false;
							roof.alpha = 0;
							die.alpha = 0.0001;
							eyeCenter.alpha = 0;

							stage1Hell.alpha = 1;
							stage2Hell.alpha = 1;

							if(!ClientPrefs.data.lowQuality)
							{
								for (b in bars)
								{
									b.alpha = 0.0001;
								}
							}

							dad.colorTransform.redOffset = 0;
							dad.colorTransform.greenOffset = 0;
							dad.colorTransform.blueOffset = 0;
			
							dad.colorTransform.redMultiplier = 1;
							dad.colorTransform.greenMultiplier = 1;
							dad.colorTransform.blueMultiplier = 1;

							boyfriend.colorTransform.redOffset = 0;
							boyfriend.colorTransform.greenOffset = 0;
							boyfriend.colorTransform.blueOffset = 0;
			
							boyfriend.colorTransform.redMultiplier = 1;
							boyfriend.colorTransform.greenMultiplier = 1;
							boyfriend.colorTransform.blueMultiplier = 1;
							
						case 11:
							if (ClientPrefs.data.shaders && ClientPrefs.data.flashing && !ClientPrefs.data.lowQuality) {
								FlxTween.num(followedIntenseChromaticAbb.amount, 0.08, 2, function(v)
								{
									followedIntenseChromaticAbb.amount = v;
								});
							}
	 
						case 14:
							if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality) {
								addShader(glitchShader3);
								glitchShader3.glitchy = ClientPrefs.data.flashing ? 0.04 : 0.02;
							}

						case 15:
							if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality) {
								FlxTween.num(followedIntenseChromaticAbb.amount, 0.01, 2, function(v)
								{
									followedIntenseChromaticAbb.amount = v;
								});

								FlxTween.num(glitchShader3.glitchy, 0.01, 2, {ease:FlxEase.sineInOut}, function(v)
								{
									glitchShader3.glitchy = v;
								});
							}
								
						case 18:
							if (ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality) {
								FlxTween.num(glitchShader3.glitchy, 0, 0.3, {ease: FlxEase.sineInOut, onComplete: function (f:FlxTween)
								{
									removeShader(glitchShader3);
								}}, function(v)
								{
									glitchShader3.glitchy = v;
								});

								FlxTween.num(followedIntenseChromaticAbb.amount, 0, 0.3, {ease: FlxEase.sineInOut, onComplete: function (f:FlxTween)
								{
									removeShader(followedIntenseChromaticAbb);
								}}, function(v)
								{
									followedIntenseChromaticAbb.amount = v;
								});
	
								var shader = new FollowedGlitch();
								addShader(shader);
								shader.glowAmount = 0;
								FlxTween.num(shader.glowAmount, 0.3, 0.3, {ease: FlxEase.circIn, onComplete: function (f:FlxTween)
								{
									FlxTween.num(shader.glowAmount, 0, 0.2, {ease: FlxEase.circIn, onComplete: function (f:FlxTween)
									{
										removeShader(shader);
									}}, function(v)
									{
										shader.glowAmount = v;
									});
								}}, function(v)
								{
									shader.glowAmount = v;
								});
							}
					}

					eventCounter++;
		}
	}

	override function opponentNoteHit(note:Note)
	{
		if(game.opponentMode) return;

		if(!ClientPrefs.data.lowQuality)
		{
			if(aethosNotes)
				notesAppear(note.noteData);
		}

		if(second.curCharacter == 'mimic-box' && note.noteType != 'GF Sing')
			if(!note.isSustainNote) anekdotHit(note);
	}

	override function goodNoteHit(note:Note)
	{
		if(!game.opponentMode) return;

		if(!ClientPrefs.data.lowQuality)
		{
			if(aethosNotes)
				notesAppear(note.noteData);

			if(second.curCharacter == 'mimic-box' && note.noteType != 'GF Sing')
				if(!note.isSustainNote) anekdotHit(note);
		}
	}

	function anekdotHit(note:Note)
	{
		var player:Character = second;
		var boxNote:AnekdotNote = new AnekdotNote(player, note.noteData);
		
		boxNote.x = player.x - 250;
		boxNote.y = player.y - 250;
		boxNote.scale.set(0.6, 0.6);
		boxNote.updateHitbox();

		boxNote.blend = ADD;

		boxNote.acceleration.y = -550;
		boxNote.velocity.y = FlxG.random.int(-100, -150);
		boxNote.velocity.x = FlxG.random.int(-140, -175);

		boxNote.zIndex = 560;

		add(boxNote);

		game.refresh();
		
		FlxTween.tween(boxNote, {alpha: 0}, Conductor.crochet * 0.004, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				boxNote.destroy();
			}
		});
	}

	public function addShader(shader:FlxShader, ?camera:String = 'game'):ShaderFilter
	{
		var filter:ShaderFilter = null;
		if (!ClientPrefs.data.shaders && ClientPrefs.data.lowQuality) return filter;
		if (camera == 'game') 
			gameShaders.push(filter = new ShaderFilter(shader));
		else 
			hudShaders.push(filter = new ShaderFilter(shader));

		return filter;
	}

	public function removeShader(shader:FlxShader, ?camera:String = 'game'):Bool //cool utility to remove and apply shaders
	{
		if (!ClientPrefs.data.shaders && ClientPrefs.data.lowQuality) return false;
		if (camera == 'game') {
			for (f in gameShaders)
			{
				if (f is ShaderFilter)
				{
					var sf = cast(f, ShaderFilter);
					if (sf.shader == shader)
					{
						gameShaders.remove(f);
						return true;
					}
				}
			}
		}
		else {
			for (f in hudShaders)
			{
				if (f is ShaderFilter)
				{
					var sf = cast(f, ShaderFilter);
					if (sf.shader == shader)
					{
						hudShaders.remove(f);
						return true;
					}
				}
			}
		}
		return false;
	}

	public function notesAppear(intData:Int)
	{
		var noteShitties:String = notesString[Std.int(Math.abs(Math.min(notesString.length-1, intData)))];

		var notes:FlxSprite = new FlxSprite(FlxG.random.float(roof.x - 150, roof.width + 150), roof.y + 250);
		notes.frames = Paths.getSparrowAtlas('follow/notes');
		notes.animation.addByPrefix('idle', noteShitties, 24, true);
		notes.animation.play('idle');
		notes.antialiasing = ClientPrefs.data.antialiasing;
		notes.updateHitbox();
		notes.scrollFactor.set(0.6, 0.6);
		var randomScale:Float = FlxG.random.float(1.5, 3);
		notes.scale.set(randomScale, randomScale);
		notes.alpha = 1;
		notes.angle = FlxG.random.float(-90, 90);
		notesCamGroup.add(notes);

		FlxTween.tween(notes, {y: FlxG.random.float(100, 200), alpha: 0, angle: 0}, Conductor.stepCrochet * 16 / 1000, {ease: FlxEase.expoOut,
			onComplete: function(tween:FlxTween)
			{
				notes.kill();
				notesCamGroup.remove(notes, true);
				notes.destroy();
			}
		});
	}

	public function notesAppearAlt(intData:Int)
	{
		var noteShitties:String = notesString[Std.int(Math.abs(Math.min(notesString.length-1, intData)))];

		var notes:FlxSprite = new FlxSprite(FlxG.random.float(roof.x - 150, roof.width + 150), roof.y + 600);
		notes.frames = Paths.getSparrowAtlas('follow/notes');
		notes.animation.addByPrefix('idle', noteShitties, 24, true);
		notes.animation.play('idle');
		notes.antialiasing = ClientPrefs.data.antialiasing;
		notes.updateHitbox();
		notes.scrollFactor.set(0.6, 0.6);
		var randomScale:Float = FlxG.random.float(1, 1.5);
		notes.scale.set(randomScale, randomScale);
		notes.alpha = 1;
		notes.angle = FlxG.random.float(-90, 90);
		notesCamGroup.add(notes);

		notes.color = curColor;

		FlxTween.tween(notes, {y: FlxG.random.float(100, 200), alpha: 0, angle: 0}, Conductor.stepCrochet * 64 / 1000, {ease: FlxEase.expoOut,
			onComplete: function(tween:FlxTween)
			{
				notes.kill();
				notesCamGroup.remove(notes, true);
				notes.destroy();
			}
		});
	}

	function buildBars():Void {
		var baseX:Float = -800;
		var baseY:Float = 2500;
		bars.splice(0, bars.length);
		barHeights.splice(0, barHeights.length);
		for (i in 0...NUM_BARS) {
		  var bx:Float = baseX + i * (0.8 + 50);
		  var bar = new FlxSprite(bx, baseY);
		  try { bar.loadGraphic(Paths.image('follow/circle')); } catch (e:Dynamic) {
			try { bar.makeGraphic(20, 200, FlxColor.RED); } catch (ee:Dynamic) {}
		  }
		  bar.scale.x = 0.8;
		  bar.scale.y = 0.001;
		  bar.angle = 180;
		  bar.origin.y = 1;
		  bar.scrollFactor.x = 0.4; bar.scrollFactor.y = 0.4;
		  bar.visible = true;
		  bar.zIndex = 10;
		  add(bar);
		  bars.push(bar);
		  barHeights.push(0);
		}
	  }
}