package funkin.game.stages.game_stages;

import funkin.game.stages.objects.*;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import funkin.submenus.gameover.GameOverSubstate;
import funkin.game.objects.Character;

import funkin.audio.FunkinSound;
import flixel.addons.display.FlxBackdrop;

import funkin.graphics.shaders.RainShader;
import funkin.graphics.shaders.AdjustColorShader;
import funkin.graphics.shaders.DropShadowShader;

import openfl.filters.ShaderFilter;

class Roof extends BaseStage
{
	public var lavaEmitter:FlxTypedEmitter<LavaParticle>;

	public var flames:FlxSprite;
	public var smoke:FlxSprite;

	public var fire:Bool = false;

	var canRain:Bool = false;

	var bg:BGSprite;
	var roof:BGSprite;

	var rimDad = new DropShadowShader();
	var rimBf = new DropShadowShader();
	var rimGf = new DropShadowShader();

	var colorShader:AdjustColorShader;

	var rainShader:RainShader;
	var rainShaderStartIntensity:Float = 0;
	var rainShaderEndIntensity:Float = 0;

	var lightning:BGSprite;
	var nword:FlxSprite;
	var lightningTimer:Float = 3.0;
	var additionalLighten:FlxSprite;

	var toogledLight:Bool = false;

	var phillyLightsColors:Array<FlxColor>;
	var curLight:Int = -1;

	var bottomSmokeAdd:FlxBackdrop;
    var blueL:FlxSprite;
    var houseL:FlxSprite;

	override function create()
	{

		function setupScale(spr:BGSprite)
		{
			spr.scale.set(4.75, 4.75);
			spr.updateHitbox();
		}

		bg = new BGSprite('sky', 0, 0, 0.75, 0.75);
		bg.setGraphicSize(Std.int(bg.width * 3));
		add(bg);

		if(PlayState.SONG.song == 'Too Fire Gone')
		{
			if(!ClientPrefs.data.lowQuality)
			{
				lightning = new BGSprite('lightning', -50, -550, 0.75, 0.75, ['lightning0'], false);
				setupScale(lightning);
				lightning.visible = false;
				add(lightning);
			}
		}

		if(!ClientPrefs.data.lowQuality)
		{		
			additionalLighten = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
			additionalLighten.scrollFactor.set();
			additionalLighten.updateHitbox();
			additionalLighten.blend = ADD;
			additionalLighten.visible = false;
			additionalLighten.scale.set(5, 5);
			add(additionalLighten);
		}

		flames = new FlxSprite(200, 3000);
		flames.frames = Paths.getSparrowAtlas('Starman_BG_Fire_Assets');
		flames.animation.addByPrefix('flames', 'fire', 24);
		flames.animation.play('flames');
		flames.setGraphicSize(Std.int(flames.width * 3));
		flames.alpha = 0.001;
		add(flames);

		smoke = new FlxSprite(0, 0).loadGraphic(Paths.image('smoke'));
		smoke.setGraphicSize(FlxG.width, FlxG.height);
		smoke.screenCenter();
		smoke.alpha = 0.001;
		smoke.cameras = [camOverlayHUD];
		add(smoke);

		roof = new BGSprite('home', 0, 0);
		roof.setGraphicSize(Std.int(roof.width * 3));
		add(roof);

		blueL = new FlxSprite().loadGraphic(Paths.image('erect/blueLight'));
		blueL.setPosition(0, -900);
		blueL.scrollFactor.set(1, 1);
        blueL.scale.set(3, 3);
        blueL.alpha = 0.5;
		blueL.antialiasing = ClientPrefs.data.antialiasing;
		blueL.zIndex = 1000;
		blueL.blend = SCREEN;

        houseL = new FlxSprite().loadGraphic(Paths.image('erect/houseLight'));
		houseL.setPosition(0, 1600);
		houseL.scrollFactor.set(1, 1);
        houseL.scale.set(3, 3);
        houseL.alpha = 0.5;
		houseL.zIndex = 1100;
		houseL.antialiasing = ClientPrefs.data.antialiasing;
		houseL.blend = ADD;

        add(blueL);
        add(houseL);

        bottomSmokeAdd = new FlxBackdrop(Paths.image('erect/bottomSmokeAdd'), X);
		bottomSmokeAdd.scrollFactor.set(1.2, 1);
		bottomSmokeAdd.zIndex = 1150;
		bottomSmokeAdd.y = 800;
		bottomSmokeAdd.antialiasing = ClientPrefs.data.antialiasing;
		bottomSmokeAdd.blend = ADD;
		bottomSmokeAdd.velocity.x = 200;

		add(bottomSmokeAdd);

		if(!ClientPrefs.data.lowQuality)
		{
			colorShader = new AdjustColorShader();

			colorShader.brightness = -80;
			colorShader.hue = -30;
			colorShader.contrast = -20;
			colorShader.saturation = -32;
	
			bg.shader = colorShader;
			roof.shader = colorShader;
		}

		if(PlayState.SONG.song == 'Too Fire Gone')
		{
			if(!ClientPrefs.data.lowQuality)
			{
				for (i in 1...4)
				{
					//trace('Lightning$i');
					Paths.sound('Lightning$i');
				}
			}
		}
	}

	override function createPost()
	{
		if(PlayState.SONG.song == 'Too Fire Gone')
		{
			nword = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			nword.scrollFactor.set(0, 0);
			nword.alpha = 0.0001;
			nword.scale.set(5, 5);
			nword.zIndex = 1500;
			add(nword);

			if(!ClientPrefs.data.lowQuality) {
				lavaEmitter = new FlxTypedEmitter<LavaParticle>(FlxG.width * -0.5, 3400);
				lavaEmitter.particleClass = LavaParticle;
				lavaEmitter.launchMode = FlxEmitterMode.SQUARE;
				lavaEmitter.width = Std.int(FlxG.width * 2);
				lavaEmitter.velocity.set(0, -150, 0, -300, 0, -10, 0, -50);
				lavaEmitter.alpha.set(1, 0);
				lavaEmitter.zIndex = 1600;
				add(lavaEmitter);
				lavaEmitter.start(false);
			}

			game.tweenCameraZoom(1, 0, true);
			game.requiredZoom = 1;
		}

		if(!ClientPrefs.data.lowQuality)
		{
			rimDad = new DropShadowShader();
			rimDad.setAdjustColor(-80, -30, -20, -32);
			rimDad.color = 0xFF7c89c9;
			rimDad.attachedSprite = dad;
			rimDad.angle = 45;
	
			dad.animation.onFrameChange.add(function(anim, frame, index)
			{
				if (dad != null)
				{
					rimDad.updateFrameInfo(dad.frame);
				}
			});
	
			rimBf = new DropShadowShader();
			rimBf.setAdjustColor(-80, -30, -20, -32);
			rimBf.color = 0xFF7c89c9;
			rimBf.attachedSprite = boyfriend;
			rimBf.angle = 140;
	
			if (boyfriend.curCharacter == 'bf_ourple')
			{
				rimBf.altMaskImage = Paths.image("characters/ourplebf-mask").bitmap;
				  rimBf.maskThreshold = 1;
				  rimBf.useAltMask = true;
				rimBf.distance = 5;
			}
	
			if (boyfriend.curCharacter == 'bf-pixel')
			{
				rimBf.altMaskImage = Paths.image("characters/bfPixel-mask").bitmap;
				  rimBf.maskThreshold = 1;
				 rimBf.useAltMask = true;
				rimBf.distance = 3;
			}
	
			boyfriend.animation.onFrameChange.add(function(anim, frame, index)
			{
				if (boyfriend != null)
				{
					rimBf.updateFrameInfo(boyfriend.frame);
				}
			});
	
			rimGf = new DropShadowShader();
			rimGf.setAdjustColor(-80, -30, -20, -32);
			rimGf.color = 0xFF7c89c9;
			rimGf.attachedSprite = gf;
			rimGf.angle = 140;
	
			if (gf.curCharacter == 'gf-pixel')
			{
				rimGf.altMaskImage = Paths.image("characters/gfPixel_mask").bitmap;
				rimGf.maskThreshold = 1;
				rimGf.useAltMask = true;
				rimGf.distance = 3;
			}

			if (gf.curCharacter == 'gf_ourple')
			{
				rimGf.altMaskImage = Paths.image("characters/ourpgf-mask").bitmap;
				rimGf.maskThreshold = 1;
				rimGf.useAltMask = true;
				rimGf.distance = 3;
			}
	
			gf.animation.onFrameChange.add(function(anim, frame, index)
			{
				if (gf != null)
				{
					rimGf.updateFrameInfo(gf.frame);
				}
			});
	
			dad.shader = rimDad;
			boyfriend.shader = rimBf;
			gf.shader = rimGf;
		}
	}

	override function update(elapsed:Float)
	{
		if(fire)
			if (game.health >= 0.4)
				game.health -= 0.001 * (elapsed/(1/60));

		if(canRain)
		{
			lightningTimer -= elapsed;
			if (lightningTimer <= 0)
			{
				applyLightning();
				lightningTimer = FlxG.random.float(7, 15);
			}

			if(rainShader != null)
			{
				var remappedIntensityValue:Float = FlxMath.remapToRange(Conductor.songPosition, 0, (FlxG.sound.music != null ? FlxG.sound.music.length : 0), rainShaderStartIntensity, rainShaderEndIntensity);
				rainShader.intensity = remappedIntensityValue;
				rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
				rainShader.update(elapsed);
			}
		}

		super.update(elapsed);
	}

	function setupRainShader()
	{
		rainShader = new RainShader();
		rainShader.scale = FlxG.height / 200;

		rainShaderStartIntensity = 0.2;
		rainShaderEndIntensity = 0.4;

		rainShader.intensity = rainShaderStartIntensity;
		FlxG.camera.filters = [new ShaderFilter(rainShader)];
	}

	function applyLightning():Void
	{
		if(ClientPrefs.data.lowQuality || game.endingSong) return;

		final LIGHTNING_FULL_DURATION = 1.5;
		final LIGHTNING_FADE_DURATION = 0.3;

		nword.alpha = 0;
		FlxTween.tween(nword, {alpha: 0.4}, LIGHTNING_FULL_DURATION, {onComplete: function(_)
		{
			lightning.visible = false;
			additionalLighten.visible = false;
		}});

		additionalLighten.visible = true;
		additionalLighten.alpha = 0.3;
		FlxTween.tween(additionalLighten, {alpha: 0.0}, LIGHTNING_FADE_DURATION);

		lightning.visible = true;
		lightning.animation.play('lightning0', true);

		if(FlxG.random.bool(65))
			lightning.x = FlxG.random.int(-250, 280);
		else
			lightning.x = FlxG.random.int(780, 900);

		// Sound
		FunkinSound.playOnce(Paths.soundRandom('Lightning', 1, 3));
	}

	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Change Character':
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						gf.animation.onFrameChange.add(function(anim, frame, index)
						{
							if (gf != null)
							{
								rimGf.updateFrameInfo(gf.frame);
							}
						});
						if(!ClientPrefs.data.lowQuality) gf.shader = rimGf;
				}

			case 'burn with cone':
				FlxG.camera.flash(ClientPrefs.data.flashing ? 0xffff4d00 : 0x4cff4d00, 1, null, true);
				FunkinSound.playOnce(Paths.sound('boom'), 0.6);
				game.health -= 0.5;
				fire = !fire;
			
			case 'fire boom':
				FlxTween.tween(flames, {y: 800}, 10, {ease: FlxEase.sineOut});

				FlxTween.tween(smoke, {alpha: 1}, 10);
				FlxTween.tween(flames, {alpha: 1}, 10);
				FlxTween.tween(bg, {alpha: 0}, 10);
				FlxTween.tween(blueL, {alpha: 0}, 10);

				if(PlayState.SONG.song == 'Too Fire Gone')
				{
					FlxTween.color(roof, 10, 0xFFFFFFFF, 0xffff6300);
					FlxTween.color(dadGroup, 10, 0xFFFFFFFF, 0xffff6300);
					FlxTween.color(boyfriendGroup, 10, 0xFFFFFFFF, 0xffff6300);
					if(!ClientPrefs.data.lowQuality) FlxTween.tween(lavaEmitter, {y: 1200}, 6, {ease: FlxEase.sineOut});
				}

			case 'rain':
				nword.alpha = 0.4;
				if(ClientPrefs.data.lowQuality) return;

				if(ClientPrefs.data.shaders)
					setupRainShader();
					
				canRain = true;

			case 'rain stop':
				dad.shader = null;
				boyfriend.shader = null;
				gf.shader = null;
				roof.shader = null;
				bg.shader = null;

				nword.alpha = 0.6;
				
				if(ClientPrefs.data.lowQuality) return;
					
				//rain.visible = false;
				//splash.visible = false;
				canRain = false;

				if(!ClientPrefs.data.shaders) return; 
				FlxG.camera.filters = [];

			case "end":
				smoke.alpha = 0;
				if(!ClientPrefs.data.lowQuality) lavaEmitter.y = 5000;
		}
	}

	override function songRestartPost()
	{
		dad.shader = null;
		boyfriend.shader = null;
		gf.shader = null;

		canRain = false;

		FlxG.camera.filters = [];

		if(PlayState.SONG.song == 'Too Fire Gone')
		{
			FlxTween.cancelTweensOf(nword);
			
			nword.alpha = 0.0001;
			nword.visible = true;

			if(!ClientPrefs.data.lowQuality)
			{
				FlxTween.cancelTweensOf(additionalLighten);
				FlxTween.cancelTweensOf(lightning);

				additionalLighten.visible = false;
				lightning.visible = false;
			}
		}

		
		FlxTween.cancelTweensOf(bg);
		FlxTween.cancelTweensOf(roof);
		FlxTween.cancelTweensOf(bg.color);
		FlxTween.cancelTweensOf(roof.color);
		FlxTween.cancelTweensOf(dadGroup.color);
		FlxTween.cancelTweensOf(dadGroup);
		FlxTween.cancelTweensOf(boyfriendGroup.color);
		FlxTween.cancelTweensOf(boyfriendGroup);
		FlxTween.cancelTweensOf(gfGroup.color);
		FlxTween.cancelTweensOf(gfGroup);
		FlxTween.cancelTweensOf(dad.color);
		FlxTween.cancelTweensOf(boyfriend.color);
		FlxTween.cancelTweensOf(dad);
		FlxTween.cancelTweensOf(boyfriend);
		FlxTween.cancelTweensOf(gf.color);

		blueL.alpha = 0.5;
		bg.alpha = 1;

		bg.color = 0xFFFFFFFF;
		roof.color = 0xFFFFFFFF;
		boyfriendGroup.color = 0xFFFFFFFF;
		gfGroup.color = 0xFFFFFFFF;
		dadGroup.color = 0xFFFFFFFF;
		boyfriend.color = 0xFFFFFFFF;
		gf.color = 0xFFFFFFFF;
		dad.color = 0xFFFFFFFF;

		if(PlayState.SONG.song == 'Too Fire Gone')
		{
			FlxTween.cancelTweensOf(flames);
			FlxTween.cancelTweensOf(smoke);
			flames.alpha = 0.001;
			flames.y = 3000;

			if(!ClientPrefs.data.lowQuality)
			{
				FlxTween.cancelTweensOf(lavaEmitter);
				lavaEmitter.y = 3400;
			}
			smoke.alpha = 0;

			game.tweenCameraZoom(1, 0, true);
			game.requiredZoom = 1;
		}

		if(!ClientPrefs.data.lowQuality)
		{
			rimGf.attachedSprite = gf;
			rimBf.attachedSprite = boyfriend;
	
			if (boyfriend.curCharacter == 'bf_ourple')
			{
				rimBf.altMaskImage = Paths.image("characters/ourplebf-mask").bitmap;
				  rimBf.maskThreshold = 1;
				  rimBf.useAltMask = true;
				rimBf.distance = 5;
			}
	
			if (boyfriend.curCharacter == 'bf-pixel')
			{
				rimBf.altMaskImage = Paths.image("characters/bfPixel-mask").bitmap;
				  rimBf.maskThreshold = 1;
				 rimBf.useAltMask = true;
				rimBf.distance = 3;
			}
	
			boyfriend.animation.onFrameChange.add(function(anim, frame, index)
			{
				if (gf != null)
				{
					rimBf.updateFrameInfo(boyfriend.frame);
				}
			});
	
			gf.animation.onFrameChange.add(function(anim, frame, index)
			{
				if (gf != null)
				{
					rimGf.updateFrameInfo(gf.frame);
				}
			});
	
			dad.shader = rimDad;
			boyfriend.shader = rimBf;
			gf.shader = rimGf;
	
			roof.shader = colorShader;
			bg.shader = colorShader;
		}
	}
}