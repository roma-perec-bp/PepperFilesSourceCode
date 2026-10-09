package funkin.submenus.gameover;

import funkin.data.WeekData;

import funkin.game.objects.Character;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import funkin.audio.FunkinSound;
import funkin.menus.storymenu.StoryMenuState;
import funkin.menus.freeplay.FreeplayState;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend_death:Character;
	var camFollow:FlxObject;

	var stagePostfix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	//extra vars
	public static var removeCameraShaders:Bool = true;
	public static var removeBfShaders:Bool = true;
	public static var bg_alpha:Float = 1;

	public static var deathDelay:Float = 0;

	public static var instance:GameOverSubstate;
	public function new(?playStateBoyfriend:Character = null)
	{
		/*if(playStateBoyfriend != null && playStateBoyfriend.curCharacter == characterName) //Avoids spawning a second boyfriend cuz animate atlas is laggy
		{
			this.boyfriend_death = playStateBoyfriend;
		}*/
		super();
	}

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		removeBfShaders = true;
		removeCameraShaders = true;
		bg_alpha = 1;
		deathDelay = 0;

		var _song = PlayState.SONG;
		if(_song != null)
		{
			if(_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) characterName = _song.gameOverChar;
			if(_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) deathSoundName = _song.gameOverSound;
			if(_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0) loopSoundName = _song.gameOverLoop;
			if(_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0) endSoundName = _song.gameOverEnd;
		}
	}

	var charX:Float = 0;
	var charY:Float = 0;

	var textEvil:Array<String> = ["It's not the time", "Don't give up", "You need to get up", "You can do it", "You should stay alive"];

	var overlay:FlxSprite;
	var overlayConfirmOffsets:FlxPoint = FlxPoint.get();

	public var camHUD:FlxCamera;
	override function create()
	{
		instance = this;

		FlxTween.tween(PlayState.instance.camHUD, {alpha: 0}, 1);

		if (GameOverSubstate.bg_alpha != 1)
		{
			// Add a black background to the screen.
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			bg.alpha = GameOverSubstate.bg_alpha;
			bg.scrollFactor.set();
			bg.screenCenter();
			add(bg);
		}

		if(!FlxG.save.data.doesHeKnow)
		{
			if(boyfriend_death == null)
			{
				boyfriend_death = new Character(PlayState.instance.boyfriend.getScreenPosition().x, PlayState.instance.boyfriend.getScreenPosition().y, characterName, true);
				boyfriend_death.x += boyfriend_death.positionArray[0] - PlayState.instance.boyfriend.positionArray[0];
				boyfriend_death.y += boyfriend_death.positionArray[1] - PlayState.instance.boyfriend.positionArray[1];
			}
			boyfriend_death.skipDance = true;
			if (removeBfShaders) boyfriend_death.shader = null;
			add(boyfriend_death);
		
			FunkinSound.playOnce(Paths.sound(deathSoundName));
			FlxG.camera.scroll.set();
			FlxG.camera.target = null;
		
			boyfriend_death.playAnim('firstDeath');
		
			camFollow = new FlxObject(0, 0, 1, 1);
			camFollow.setPosition(boyfriend_death.getGraphicMidpoint().x + boyfriend_death.cameraPosition[0], boyfriend_death.getGraphicMidpoint().y + boyfriend_death.cameraPosition[1]);
			FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
			add(camFollow);
		
			FlxG.sound.music.loadEmbedded(Paths.music(loopSoundName), true);
		}
		else
		{
			camHUD = new FlxCamera();
			camHUD.bgColor.alpha = 0;
			FlxG.cameras.add(camHUD, false);

			var bg:FlxSprite = new FlxSprite(0,0);
			bg.antialiasing = ClientPrefs.data.antialiasing;
			bg.frames = Paths.getSparrowAtlas('game_over_glitch');
			bg.screenCenter(X);
			bg.animation.addByPrefix('idle', "glitch", 30, false);
			bg.animation.play('idle');
			bg.cameras = [camHUD];
			add(bg);

			var titleText:FlxText = new FlxText(50, - 100, 0, textEvil[FlxG.random.int(0, 4)], 80);
        	titleText.setFormat(Paths.font("vcr.ttf"), 57, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			titleText.screenCenter();
			titleText.borderSize = 1.25;
			titleText.alpha = 0.0001;
			titleText.cameras = [camHUD];
       		 add(titleText);

			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				titleText.alpha = 1;

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					titleText.alpha = 0;

					PlayState.instance.camOther.fade(FlxColor.BLACK, 2, false, null); //cuz hud

				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					if(PlayState.SONG.fullRestart) 
						MusicBeatState.resetState();
					else
					{
						PlayState.instance.dad.stunned = false;
						PlayState.instance.boyfriend.stunned = false;
	
						PlayState.instance.health = 1;
						//PlayState.instance.add(PlayState.instance.boyfriend);
	
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 1);

							PlayState.instance.camGame.stopFX();
							PlayState.instance.camHUD.stopFX();
							PlayState.instance.camOverlayHUD.stopFX();
							PlayState.instance.camNotes.stopFX();
							PlayState.instance.camOther.fade(FlxColor.BLACK, 1, true, null, true); //cuz hud

							PlayState.instance.revivePlayer();
							PlayState.instance.boyfriend.playInitAnimation();
							PlayState.instance.dad.playInitAnimation();
							if(PlayState.instance.gf != null) PlayState.instance.gf.playInitAnimation();
	
							close();
						});
					}
				});
				});
			});

			FunkinSound.playOnce(Paths.sound('glitch'));
		}

		PlayState.instance.setOnScripts('inGameOver', true);
		PlayState.instance.callOnScripts('onGameOverStart', []);

		FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.expoOut}); //if camera zoom on playstate was messed up, then reset to stage zoom

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.save.data.doesHeKnow)
		{
			if (controls.ACCEPT)
			{
				if(PlayState.SONG.fullRestart) 
					MusicBeatState.resetState();
				else
				{
					PlayState.instance.dad.stunned = false;
					PlayState.instance.boyfriend.stunned = false;

					PlayState.instance.health = 1;
					//PlayState.instance.add(PlayState.instance.boyfriend);

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 1);

						PlayState.instance.camGame.stopFX();
						PlayState.instance.camHUD.stopFX();
						PlayState.instance.camOverlayHUD.stopFX();
						PlayState.instance.camNotes.stopFX();
						PlayState.instance.camOther.fade(FlxColor.BLACK, 1, true, null, true); //cuz hud

						PlayState.instance.revivePlayer();
						PlayState.instance.boyfriend.playInitAnimation();
						PlayState.instance.dad.playInitAnimation();
						if(PlayState.instance.gf != null) PlayState.instance.gf.playInitAnimation();

						close();
					});
				}
			}
		}

		if(FlxG.save.data.doesHeKnow) return;

		if(isEnding)
		{
			if(PlayState.SONG.fullRestart) 
				MusicBeatState.resetState();
			else
			{
				PlayState.instance.dad.stunned = false;
				PlayState.instance.boyfriend.stunned = false;

				PlayState.instance.health = 1;
				//PlayState.instance.add(PlayState.instance.boyfriend);

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 1);

					PlayState.instance.camGame.stopFX();
					PlayState.instance.camHUD.stopFX();
					PlayState.instance.camOverlayHUD.stopFX();
					PlayState.instance.camNotes.stopFX();
					PlayState.instance.camOther.fade(FlxColor.BLACK, 1, true, null, true); //cuz hud

					PlayState.instance.revivePlayer();
					PlayState.instance.boyfriend.playInitAnimation();
					PlayState.instance.dad.playInitAnimation();
					if(PlayState.instance.gf != null) PlayState.instance.gf.playInitAnimation();

					close();
				});
			}
		}

		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		var justPlayedLoop:Bool = false;
		if (!boyfriend_death.isAnimationNull() && boyfriend_death.getAnimationName() == 'firstDeath' && boyfriend_death.isAnimationFinished())
		{
			boyfriend_death.playAnim('deathLoop');
			if(overlay != null && overlay.animation.exists('deathLoop'))
			{
				overlay.visible = true;
				overlay.animation.play('deathLoop');
			}
			justPlayedLoop = true;
		}

		if(!isEnding)
		{
			if (controls.ACCEPT)
			{
				endBullshit();
			}
			else if (controls.BACK)
			{
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
				FlxG.camera.visible = false;
				FlxG.sound.music.stop();
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
	
				Mods.loadTopMod();

				switch(FlxG.save.data.progressState)
				{
				  	case 0:
						FlxG.switchState(new funkin.menus.mainmenu.FakeMainMenuState());
						FlxG.sound.playMusic(Paths.music('fake_game/main_menu_mus_fake'));
					case 2 | 6:
						WindowUtil.exit();
					default:
						FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
						if (PlayState.isStoryMode)
							MusicBeatState.switchState(new StoryMenuState());
						else
							MusicBeatState.switchState(new FreeplayState());
				}
				PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
			}
			else if (justPlayedLoop)
			{
				switch(PlayState.SONG.stage)
				{
					case 'night':
						coolStartDeath(0.2);

						FunkinSound.playOnce(Paths.sound('game_over/line' + FlxG.random.int(0, 7,)), function()
						{
							// Once the quote ends, fade in the game over music.
							if (!isEnding)
							{
								FlxG.sound.music.fadeIn(0.2, 1, 4);
							}
						});

					default:
						coolStartDeath();
				}
			}
			
			if (FlxG.sound.music.playing)
			{
				Conductor.songPosition = FlxG.sound.music.time;
			}
		}
		PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	var isEnding:Bool = false;
	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.music.play(true);
		FlxG.sound.music.volume = volume;
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if(boyfriend_death.hasAnimation('deathConfirm'))
				boyfriend_death.playAnim('deathConfirm', true);
			else if(boyfriend_death.hasAnimation('deathLoop'))
				boyfriend_death.playAnim('deathLoop', true);

			if(overlay != null && overlay.animation.exists('deathConfirm'))
			{
				overlay.visible = true;
				overlay.animation.play('deathConfirm');
				overlay.offset.set(overlayConfirmOffsets.x, overlayConfirmOffsets.y);
			}
			FlxG.sound.music.stop();
			FunkinSound.playOnce(Paths.music(endSoundName));

			  // confirm music length divided by 7000
      		// this is here so mods with longer confirm sounds don't have it cut off!!!
     		 final FADE_TIMER:Float = (endSoundName?.length ?? 0) / 7000;

			new FlxTimer().start(FADE_TIMER * 1000, function(tmr:FlxTimer)
			{
				PlayState.instance.camOther.fade(FlxColor.BLACK, 2, false, null); //cuz hud

				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					if(PlayState.SONG.fullRestart) 
						MusicBeatState.resetState();
					else
					{
						PlayState.instance.dad.stunned = false;
						PlayState.instance.boyfriend.stunned = false;
	
						PlayState.instance.health = 1;
						//PlayState.instance.add(PlayState.instance.boyfriend);
	
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, 1);

							PlayState.instance.camGame.stopFX();
							PlayState.instance.camHUD.stopFX();
							PlayState.instance.camOverlayHUD.stopFX();
							PlayState.instance.camNotes.stopFX();
							PlayState.instance.camOther.fade(FlxColor.BLACK, 1, true, null, true); //cuz hud

							PlayState.instance.revivePlayer();
							PlayState.instance.boyfriend.playInitAnimation();
							PlayState.instance.dad.playInitAnimation();
							if(PlayState.instance.gf != null) PlayState.instance.gf.playInitAnimation();
	
							close();
						});
					}
				});
			});
			PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
		}
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
