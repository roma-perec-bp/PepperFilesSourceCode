package funkin.game.stages.game_stages;

import funkin.game.stages.objects.*;
import funkin.game.objects.Character;

import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import flixel.system.FlxAssets.FlxShader;
import funkin.graphics.shaders.LastStandShaders;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;

class StageWeek1 extends BaseStage
{
	public var gameShaders:Array<BitmapFilter> = [];
	public var hudShaders:Array<BitmapFilter> = [];

	var glitching:Bool = false;

	public var glitchShader2:FollowedGlitch;
	public var followedIntenseChromaticAbb:CabinetGlitchChrom;

	public var updateiTime:Array<FlxRuntimeShader> = [];
	public var updateiTimeHARD:Array<Dynamic> = [];

	public var bg:BGSprite;
	public var stageFront:BGSprite;
	public var stageCurtains:BGSprite;

	public var err:BGSprite;
	public var err2:BGSprite;

	public var logo:FlxSprite;
	override function create()
	{
		bg = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		add(bg);

		stageFront = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		add(stageFront);
		if(!ClientPrefs.data.lowQuality) {
			stageCurtains = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			add(stageCurtains);
		}

		err = new BGSprite('glitch/'+FlxG.random.int(0,5), -600, -200, 0.9, 0.9);
		err.visible = false;
		add(err);

		err2 = new BGSprite('glitch/'+FlxG.random.int(0,5), -600, -200, 0.9, 0.9);
		err2.visible = false;
		add(err2);

		if (ClientPrefs.data.shaders) {
			glitchShader2 = new FollowedGlitch();
			followedIntenseChromaticAbb = new CabinetGlitchChrom();
			followedIntenseChromaticAbb.amount = 0;
			followedIntenseChromaticAbb.speed = 0;

			updateiTimeHARD.push(followedIntenseChromaticAbb);
		}

		logo = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.x = 400;
		logo.y = 300;
		logo.alpha = 0;
		logo.cameras = [game.camOther];
		add(logo);

		camGame.filters = gameShaders;
		camHUD.filters = hudShaders;
		camNotes.filters = hudShaders;

		for (i in 0...5)
			Paths.image('glitch/'+i);
	}
	
	public function addShader(shader:FlxShader, ?camera:String = 'game'):ShaderFilter
	{
		var filter:ShaderFilter = null;
		if (!ClientPrefs.data.shaders) return filter;

		gameShaders.push(filter = new ShaderFilter(shader));
		hudShaders.push(filter = new ShaderFilter(shader));

		return filter;
	}

	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Glitch":
				game.inCutscene = true;

				glitching = true;
				addShader(glitchShader2);
				addShader(followedIntenseChromaticAbb);

				FlxTween.num(followedIntenseChromaticAbb.amount, 0.15, 2, {ease: FlxEase.sineIn}, function(v)
				{
					followedIntenseChromaticAbb.amount = v;
				});

				FlxTween.num(followedIntenseChromaticAbb.speed, 0.6, 2, {ease: FlxEase.sineIn}, function(v)
				{
					followedIntenseChromaticAbb.speed = v;
				});

			case 'text_logo':
				FlxTween.tween(logo, {alpha: 1}, 3);
		}
	}

	var shakeValue:Float = 0;
	var glitchValue:Float = 0;
	var glitchTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (ClientPrefs.data.shaders) {
			var trueElapsed:Float = (elapsed / (1 / 60));
			for (i in updateiTime) i.setFloat('iTime', i.getFloat('iTime') + elapsed);
			for (i in updateiTimeHARD) i.update(elapsed);
		}

		if(glitching)
		{
			glitchValue += 0.001;
			glitchShader2.squareAmount = glitchValue;
			glitchTime += 0.001;
			glitchShader2.iTime = glitchValue*5;
			shakeValue += 0.0001;
			camGame.shake(shakeValue);
			camNotes.shake(shakeValue);
			camHUD.shake(shakeValue);

			logo.x = 300 + FlxG.random.int(-10, 10);
			logo.y = 275 + FlxG.random.int(-10, 10);
			logo.angle = FlxG.random.int(-6, 6);
		}
	}

	override function stepHit()
	{
		if(glitching)
		{
			if(FlxG.random.bool(85))
			{
				bg.x =  -600 + FlxG.random.int(-50, 50);
				bg.y =  -200 + FlxG.random.int(-50, 50);
			}

			if(FlxG.random.bool(50))
			{
				if(FlxG.random.bool(50))
				{
					bg.loadGraphic(Paths.image('glitch/'+FlxG.random.int(0,5)));
				}
				else
				{
					bg.loadGraphic(Paths.image('stageback'));
				}
			}

			if(FlxG.random.bool(85))
			{
				stageFront.x =  -650 + FlxG.random.int(-50, 50);
				stageFront.y =  600 + FlxG.random.int(-50, 50);
			}

			if(FlxG.random.bool(50))
			{
				if(FlxG.random.bool(50))
				{
					stageFront.loadGraphic(Paths.image('glitch/'+FlxG.random.int(0,5)));
				}
				else
				{
					stageFront.loadGraphic(Paths.image('stagefront'));
				}
			}

			if(!ClientPrefs.data.lowQuality) {
				if(FlxG.random.bool(85))
				{
					stageCurtains.x =  -650 + FlxG.random.int(-50, 50);
					stageCurtains.y =  600 + FlxG.random.int(-50, 50);
				}

				if(FlxG.random.bool(50))
				{
					if(FlxG.random.bool(50))
					{
						stageCurtains.loadGraphic(Paths.image('glitch/'+FlxG.random.int(0,5)));
					}
					else
					{
						stageCurtains.loadGraphic(Paths.image('stagecurtains'));
					}
				}
			}

			if(FlxG.random.bool(50))
			{
				err.x =  dad.x;
				err.y =  dad.y;

				if(FlxG.random.bool(50))
				{
					err.loadGraphic(Paths.image('glitch/'+FlxG.random.int(0,5)));
					err.visible = true;
				}
				else
				{
					err.visible = false;
				}
			}

			if(FlxG.random.bool(50))
			{
				err2.x =  boyfriend.x;
				err2.y =  boyfriend.y;

				if(FlxG.random.bool(50))
				{
					err2.loadGraphic(Paths.image('glitch/'+FlxG.random.int(0,5)));
					err2.visible = true;
				}
				else
				{
					err2.visible = false;
				}
			}
		}
	}
}