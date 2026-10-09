package funkin.submenus.pause;

import funkin.menus.mainmenu.MainMenuState;
import funkin.data.WeekData;
import funkin.data.Highscore;
import funkin.data.Song;

import flixel.util.FlxStringUtil;
import funkin.menus.storymenu.StoryMenuState;
import funkin.menus.freeplay.FreeplayState;
import funkin.menus.options.OptionsState;

import funkin.menus.FullScreenScaleMode;

class BpPauseSubState extends MusicBeatSubstate
{
	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];

	var menuItemsGroup:FlxTypedGroup<FlxSprite>;

	var menuItemsAdvanced:Dynamic = [
		["resume", 426, 575],
		["restart", 544, 362],
		["options", 544, 414],
		["exit", 544, 467]
	];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var bpText:FlxText;
	//var botplayText:FlxText;

	var dragDropObj:FlxSprite;
	var bg2:FlxSprite;

	var desc:FlxText;

	var selected:Bool = false;
	
	var curTime:Float = Math.max(0, Conductor.songPosition);

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	public static var songName:String = null;

	override function create()
	{
		menuItems = menuItemsOG;

		pauseMusic = new FlxSound();
		pauseMusic.loadEmbedded(Paths.music('pause_music/fake-pause'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		FlxG.sound.play(Paths.sound("bp_aah_sounds/buzzer"));

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		bpText = new FlxText(20, 15, 0, "BOTPLAY ON", 32);
		bpText.scrollFactor.set();
		bpText.setFormat(Paths.font('vcr.ttf'), 32);
		bpText.x = FlxG.width - (bpText.width + 20);
		bpText.updateHitbox();
		bpText.visible = PlayState.instance.cpuControlled;
		add(bpText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		changeSelection();

		// new stuff
		bg2 = new FlxSprite(0, 0).loadGraphic(Paths.image("pause_pvz_menu/background"));
		bg2.screenCenter();
		bg2.scrollFactor.set();
		bg2.updateHitbox();
		add(bg2);

		FlxG.mouse.visible = true;

		menuItemsGroup = new FlxTypedGroup<FlxSprite>();
		add(menuItemsGroup);

		for(i in 0...menuItemsAdvanced.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0,0);
			menuItem.frames = Paths.getSparrowAtlas('pause_pvz_menu/button_' + menuItemsAdvanced[i][0]);
			menuItem.animation.addByPrefix('idle', "button_" + menuItemsAdvanced[i][0] + "_idle", 24);
			menuItem.animation.addByPrefix('selected', "button_" + menuItemsAdvanced[i][0] + "_selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItemsGroup.add(menuItem);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.scrollFactor.set();
			menuItem.updateHitbox();

			menuItem.x = menuItemsAdvanced[i][1] + (FullScreenScaleMode.gameCutoutSize.x / 2);
			menuItem.y = menuItemsAdvanced[i][2] + (FullScreenScaleMode.gameCutoutSize.x / 2);
		}

		desc = new FlxText(20, 15 + 64, 0, "", 25);
		desc.text = "Song: " + Std.string(PlayState.SONG.displayName == null ? PlayState.SONG.song : PlayState.SONG.displayName)
		+ "\nBlueballed: " + Std.string(PlayState.deathCounter);
		desc.scrollFactor.set();
		desc.setFormat(Paths.font("serio.ttf"), 26, 0xFF6B6D91, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		desc.borderSize = 3;
		desc.screenCenter();
		desc.y -= 85;
		desc.updateHitbox();
		add(desc);

		dragDropObj = new FlxSprite(0, 0).loadGraphic(Paths.image("pause_pvz_menu/hitbox"));
		dragDropObj.setPosition(bg2.x, bg2.y);
		dragDropObj.screenCenter(X);
		dragDropObj.scrollFactor.set();
		dragDropObj.updateHitbox();
		dragDropObj.visible = false;
		add(dragDropObj);

		changeButtons();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}
	
	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if(formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;

		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var accepted = controls.ACCEPT;
		var mousePosX:Float = FlxG.mouse.getScreenPosition(camera).x;
		var mousePosY:Float = FlxG.mouse.getScreenPosition(camera).y;

		changeButtons();

		if (FlxG.mouse.overlaps(dragDropObj, camera) && FlxG.mouse.pressed)
		{
			dragDropObj.x = mousePosX - (142/2);
			dragDropObj.y = mousePosY - (79/2);
		}

		bg2.offset.set(-(dragDropObj.x - 569) + (FullScreenScaleMode.gameCutoutSize.x / 2), -(dragDropObj.y - 38));

		desc.offset.set(0 - (dragDropObj.x - 569) + (FullScreenScaleMode.gameCutoutSize.x / 2), 0 - (dragDropObj.y - 38));

		menuItemsGroup.forEach(function(spr:FlxSprite)
		{
			// spr.offset.x = 0 - (dragDropObj.x - 569);
			// spr.offset.y = 0 - (dragDropObj.y - 38);

			if(selected) return;

			spr.x = menuItemsAdvanced[spr.ID][1]+(dragDropObj.x - 569);
			spr.y = menuItemsAdvanced[spr.ID][2]+(dragDropObj.y - 38);

			if (FlxG.mouse.overlaps(spr, camera) && FlxG.mouse.justPressed)
			{
				var daSelected:String = menuItems[curSelected];

				switch (daSelected)
				{
					case "Resume":
						FlxG.mouse.visible = false;
						close();
					case "Restart Song":
						FlxG.mouse.visible = false;
						if(PlayState.SONG.fullRestart)
						{
							restartSong();
						}
						else
						{
							PlayState.instance.canResync = false;
		
							@:privateAccess
							PlayState.instance.startedCountdown = false;
								
							PlayState.instance.restartSong();
							close();
						}
					case 'Options':
						FlxG.mouse.visible = false;

						PlayState.instance.paused = true; // For lua
						PlayState.instance.vocals.volume = 0;
						PlayState.instance.canResync = false;
						MusicBeatState.switchState(new OptionsState());
						if(ClientPrefs.data.pauseMusic != 'None')
						{
							FlxG.sound.playMusic(Paths.music('pause_music/fake-pause'), pauseMusic.volume);
							FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
							FlxG.sound.music.time = pauseMusic.time;
						}
						OptionsState.onPlayState = true;
					case "Exit to menu":
						FlxTransitionableState.skipNextTransIn = false;
						FlxTransitionableState.skipNextTransOut = false;

						FlxG.sound.playMusic(Paths.music('fake_game/main_menu_mus_fake'));

						FlxG.mouse.visible = false;
						selected = true;

						var cam:FlxCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

						if(FlxG.save.data.progressState == 2)
							WindowUtil.exit();

						cam.fade(FlxColor.BLACK, 0.5, false, function()
						{
							#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
							PlayState.deathCounter = 0;
							PlayState.seenCutscene = false;
	
							PlayState.instance.canResync = false;
							Mods.loadTopMod();
	
							switch(FlxG.save.data.progressState)
							{
				  				case 0:
									FlxG.switchState(new funkin.menus.mainmenu.FakeMainMenuState());
									FlxG.sound.playMusic(Paths.music('fake_game/main_menu_mus_fake'));
								case 2:
									WindowUtil.exit();
								default:
									FlxG.sound.playMusic(Paths.music('freakyMenu'));
									if (PlayState.isStoryMode)
										MusicBeatState.switchState(new StoryMenuState());
									else
										MusicBeatState.switchState(new FreeplayState());
							}
	
							PlayState.changedDifficulty = false;
							PlayState.chartingMode = false;
							FlxG.camera.followLerp = 0;
						});
				}
			}
		});

		if(accepted)
		{
			FlxG.mouse.visible = false;
			close();
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	override function destroy()
	{
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		FlxG.sound.play(Paths.sound('bp_aah_sounds/scrollMenu'), 0.4);
	}

	function changeButtons()
	{
		menuItemsGroup.forEach(function(spr:FlxSprite)
		{
			if(FlxG.mouse.overlaps(spr, camera))
			{
				curSelected = spr.ID;

				@:privateAccess
				if(PlayState.instance.curSong == 'Holy Hell' && curSelected == 1) return;
					
				spr.animation.play('selected');
			} else {
				spr.animation.play('idle');
			}
		});
	}
}
