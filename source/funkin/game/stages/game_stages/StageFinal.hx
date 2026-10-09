package funkin.game.stages.game_stages;

import funkin.game.stages.objects.*;

import funkin.game.objects.Character;
import funkin.game.notes.Note;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import funkin.graphics.shaders.AdjustColorShader;
import funkin.graphics.shaders.DropShadowShader;

import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;
import funkin.graphics.shaders.BloomedShader;

class StageFinal extends BaseStage
{
	var rimDad = new DropShadowShader();
	var rimBf = new DropShadowShader();

	var vin:FlxSprite;

	var bloomShader:BloomedShader = null;

	var colorShader:AdjustColorShader;

	var platfrom_fake1:BGSprite;
	var platfrom_fake2:BGSprite;

	var platfrom1:BGSprite;
	var platfrom2:BGSprite;

	var gates:BGSprite;
	var fire:FlxSprite;

	var backFog:FlxBackdrop;
	var midFog:FlxBackdrop;
	var frontFog:FlxBackdrop;

	var boppers:FlxSprite;
	var staticLol:FlxSprite;

	var clock:FlxSprite;
	var doodBf:Character = null;
	var doodDad:Character = null;

	var ghostRom:Character = null;
	var ghostColor:AdjustColorShader;
	override function create()
	{
		gates = new BGSprite('end/stairs', 112, -417);
		gates.scale.set(1.4, 1.4);
		gates.updateHitbox();
		gates.scrollFactor.set(0.7, 0.7);
		add(gates);

		gates.alpha = 0.0001;

		if (!ClientPrefs.data.lowQuality)
		{
			fire = new FlxSprite(-705, 92);
			fire.frames = Paths.getSparrowAtlas('end/Fyre');
			fire.animation.addByPrefix('fire', "Penis instance 1", 24, true);
			fire.animation.play('fire');
			fire.antialiasing = ClientPrefs.data.antialiasing;
			fire.scale.set(2, 2);
			fire.updateHitbox();
			fire.scrollFactor.set(0.5, 0.5);
			add(fire);
	
			fire.alpha = 0.0001;
	
			backFog = new FlxBackdrop(Paths.image('end/back_fog'), X);
			backFog.scrollFactor.set(0.8, 1);
			backFog.x = -823;
			backFog.y = 29;
			backFog.antialiasing = ClientPrefs.data.antialiasing;
			backFog.blend = ADD;
			backFog.velocity.x = 100;
			add(backFog);
	
			backFog.alpha = 0.0001;
		}

		platfrom_fake1 = new BGSprite('end/pillar_red', -363, 600);
		platfrom_fake1.scale.set(1.4, 1.4);
		platfrom_fake1.updateHitbox();
		add(platfrom_fake1);

		platfrom_fake2 = new BGSprite('end/pillar_red', 1023, 610);
		platfrom_fake2.scale.set(1.4, 1.4);
		platfrom_fake2.updateHitbox();
		add(platfrom_fake2);

		platfrom1 = new BGSprite('end/pillar', -309, 682);
		platfrom1.scale.set(1.4, 1.4);
		platfrom1.updateHitbox();
		add(platfrom1);

		platfrom1.alpha = 0.0001;

		platfrom2 = new BGSprite('end/pillar', 1080, 671);
		platfrom2.scale.set(1.4, 1.4);
		platfrom2.updateHitbox();
		add(platfrom2);

		platfrom2.alpha = 0.0001;

		if (!ClientPrefs.data.lowQuality)
		{
			colorShader = new AdjustColorShader();

			colorShader.brightness = 9;
			colorShader.hue = 3;
			colorShader.contrast = 4;
			colorShader.saturation = -45;

			fire.shader = colorShader;

			ghostColor = new AdjustColorShader();

			ghostColor.brightness = -40;
			ghostColor.hue = -20;
			ghostColor.contrast = -16;
			ghostColor.saturation = -18;

			midFog = new FlxBackdrop(Paths.image('end/mid_fog'), X);
			midFog.scrollFactor.set(1, 1);
			midFog.x = -854;
			midFog.y = 37;
			midFog.antialiasing = ClientPrefs.data.antialiasing;
			midFog.blend = ADD;
			midFog.velocity.x = 200;
			add(midFog);
	
			midFog.alpha = 0.0001;
		}

		doodBf = new Character(0, 250, 'bf-dood', true);
		doodBf.cameras = [game.camPreHUD];
		doodBf.screenCenter(X);
		doodBf.x += 450;
		doodBf.alpha = 0.0001;
		add(doodBf);

		doodDad = new Character(0, 0, 'jap-dood', false);
		doodDad.cameras = [game.camPreHUD];
		doodDad.screenCenter(X);
		doodDad.x -= 350;
		doodDad.alpha = 0.0001;
		add(doodDad);

		ghostRom = new Character(game.BF_X + 200, game.BF_Y + 50, 'rom-ghost', true);
		ghostRom.alpha = 0.0001;
		if (!ClientPrefs.data.lowQuality) ghostRom.shader = ghostColor;
		add(ghostRom);

		if(Main.raldman)
			ghostRom.y += 200;

		if(Main.darnellMode)
			ghostRom.y += 200;

		clock = new FlxSprite(0, 0);
		clock.frames = Paths.getSparrowAtlas('end/time');
		clock.animation.addByIndices('danceLeft', "time_seq", [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20], "", 24, false);
		clock.animation.addByIndices('danceRight', "time_seq", [21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42], "", 24, false);
		clock.animation.play('danceLeft');
		clock.antialiasing = ClientPrefs.data.antialiasing;
		clock.cameras = [game.camPreHUD];
		clock.screenCenter();
		clock.alpha = 0.0001;
		add(clock);
	}

	override function createPost()
	{
		if (!ClientPrefs.data.lowQuality)
		{
			boppers = new FlxSprite(-1205, 800);
			boppers.frames = Paths.getSparrowAtlas('end/boppers');
			boppers.animation.addByPrefix('idle', "boppers", 24, false);
			boppers.animation.play('idle');
			boppers.antialiasing = ClientPrefs.data.antialiasing;
			boppers.updateHitbox();
			boppers.scrollFactor.set(1.4, 1);
			add(boppers);
	
			boppers.alpha = 0.0001;
	
			frontFog = new FlxBackdrop(Paths.image('end/front_fog'), X);
			frontFog.scrollFactor.set(1.6, 1);
			frontFog.x = -1159;
			frontFog.y = -349;
			frontFog.antialiasing = ClientPrefs.data.antialiasing;
			frontFog.blend = ADD;
			frontFog.velocity.x = 300;
			add(frontFog);
	
			frontFog.alpha = 0.0001;
		}

		camHUD.alpha = 0;
		camNotes.alpha = 0;

		if (!ClientPrefs.data.lowQuality)
		{
			rimDad = new DropShadowShader();
			rimDad.setAdjustColor(-40, -16, -18, -20);
			rimDad.color = 0xFFFFFFFF;
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
			rimBf.setAdjustColor(-40, -16, -18, -20);
			rimBf.color = 0xFFFFFFFF;
			rimBf.attachedSprite = boyfriend;
			rimBf.angle = 140;
	
			boyfriend.animation.onFrameChange.add(function(anim, frame, index)
			{
				if (boyfriend != null)
				{
					rimBf.updateFrameInfo(boyfriend.frame);
				}
			});
		}

		vin = new FlxSprite().loadGraphic(Paths.image('darkerVG'));
		vin.updateHitbox();
		vin.setGraphicSize(FlxG.width, FlxG.height);
		vin.screenCenter();
		vin.cameras = [camOther];
		vin.alpha = 1;
		add(vin);

		staticLol = new FlxSprite();
		staticLol.frames = Paths.getSparrowAtlas('end/static');
        staticLol.animation.addByPrefix('static', "static", 24);
        staticLol.animation.play('static');
        staticLol.antialiasing = false;
        staticLol.cameras = [camOverlayHUD];
        staticLol.alpha = 0.0001;
		staticLol.setGraphicSize(FlxG.width, FlxG.height);
        staticLol.updateHitbox();
        staticLol.screenCenter();
        add(staticLol);
	}

	override function beatHit()
	{
		if (!ClientPrefs.data.lowQuality) boppers.animation.play('idle', true);

		if (ghostRom != null && curBeat % ghostRom.danceEveryNumBeats == 0 && !ghostRom.getAnimationName().startsWith('sing') && !ghostRom.stunned)
			ghostRom.dance(ghostRom.idleForce);
	}

	var danceLol:Bool = false;
	override function sectionHit()
	{
		danceLol = !danceLol;
		if(danceLol)
		{
			clock.animation.play('danceLeft');
		}
		else
		{
			clock.animation.play('danceRight');
		}
	}

	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	override function goodNoteHit(note:Note)
	{
		if(!game.opponentMode)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];
			if (!note.isSustainNote) doodBf.playAnim(animToPlay, true);
			doodBf.holdTimer = 0;
	
			if (!note.isSustainNote) ghostRom.playAnim(animToPlay, true);
			ghostRom.holdTimer = 0;
		}
		else
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];
			if (!note.isSustainNote) doodDad.playAnim(animToPlay, true);
			doodDad.holdTimer = 0;
		}
	}

	override function opponentNoteHit(note:Note)
	{
		if(!game.opponentMode)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];
			if (!note.isSustainNote) doodDad.playAnim(animToPlay, true);
			doodDad.holdTimer = 0;
		}
		else
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];
			if (!note.isSustainNote) doodBf.playAnim(animToPlay, true);
			doodBf.holdTimer = 0;
	
			if (!note.isSustainNote) ghostRom.playAnim(animToPlay, true);
			ghostRom.holdTimer = 0;
		}
	}

	override function noteMiss(note:Note)
	{
		if(game.opponentMode) return;

		var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + 'miss';
		if (!note.isSustainNote) ghostRom.playAnim(animToPlay, true);
		ghostRom.holdTimer = 0;
	}

	override function noteMissPress(direction:Int)
	{
		if(game.opponentMode) return;
		
		var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss';
		ghostRom.playAnim(animToPlay, true);
		ghostRom.holdTimer = 0;
	}

	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Buds Events':
				switch(value1)
				{
					case 'start':
						platfrom_fake1.alpha = 0.0001;
						platfrom_fake2.alpha = 0.0001;

						platfrom1.alpha = 1;
						platfrom2.alpha = 1;
						gates.alpha = 1;

						if (!ClientPrefs.data.lowQuality)
						{
							backFog.alpha = 1;
							midFog.alpha = 1;
							frontFog.alpha = 1;
	
							boppers.alpha = 1;

							dad.animation.onFrameChange.add(function(anim, frame, index)
							{
								if (dad != null)
								{
									rimDad.updateFrameInfo(dad.frame);
								}
							});
	
							boyfriend.animation.onFrameChange.add(function(anim, frame, index)
							{
								if (boyfriend != null)
								{
									rimBf.updateFrameInfo(boyfriend.frame);
								}
							});
	
							dad.shader = rimDad;
							boyfriend.shader = rimBf;
						}

					case 'fire':
						if (!ClientPrefs.data.lowQuality) fire.alpha = 1;

					case 'clocks':
						clock.y += 200;
						FlxTween.tween(clock, {alpha: 1}, 3);
						FlxTween.tween(clock, {y: clock.y - 200}, 12, {ease: FlxEase.quadOut});

					case 'pep_dood':
						doodDad.y += 200;
						FlxTween.tween(doodDad, {alpha: 1}, 1);
						FlxTween.tween(doodDad, {y: doodDad.y - 200}, 2, {ease: FlxEase.quadOut});

					case 'bf_dood':
						doodBf.y += 200;
						FlxTween.tween(doodBf, {alpha: 1}, 1);
						FlxTween.tween(doodBf, {y: doodBf.y - 200}, 2, {ease: FlxEase.quadOut});

					case 'gone':
						FlxTween.tween(clock, {alpha: 0}, 1);
						FlxTween.tween(doodDad, {alpha: 0}, 1);
						FlxTween.tween(doodBf, {alpha: 0}, 1);

					case 'static':
						staticLol.alpha = 1;

					case 'cinema off':
						FlxTween.tween(game.topBar, {y: game.topBar.y - 100}, 3, {ease: FlxEase.expoOut});
							FlxTween.tween(game.bottomBar, {y: game.bottomBar.y + 100}, 3, {ease: FlxEase.expoOut});

					case 'cinema on':
						FlxTween.tween(game.topBar, {y: game.topBar.y + 100}, 3, {ease: FlxEase.expoOut});
						FlxTween.tween(game.bottomBar, {y: game.bottomBar.y - 100}, 3, {ease: FlxEase.expoOut});

					case 'rom ghost':
						ghostRom.alpha = 0.8;

						boyfriend.animation.onFrameChange.add(function(anim, frame, index)
							{
								if (boyfriend != null)
								{
									rimBf.updateFrameInfo(boyfriend.frame);
								}
							});
	
						if (!ClientPrefs.data.lowQuality) boyfriend.shader = rimBf;
				}	
		}
	}
}