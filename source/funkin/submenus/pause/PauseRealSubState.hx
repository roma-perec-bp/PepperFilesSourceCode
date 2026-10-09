package funkin.submenus.pause;

import funkin.data.WeekData;
import funkin.data.Highscore;
import funkin.data.Song;

import flixel.util.FlxStringUtil;

import flixel.input.keyboard.FlxKey;

import funkin.menus.storymenu.StoryMenuState;
import funkin.menus.freeplay.FreeplayState;
import funkin.menus.real_options.RealOptionsState;

import openfl.utils.Assets;

class PauseRealSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart','Options', 'Exit'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var staticTransition:FlxSprite;

	var mouseMode:Bool = false;

	var canChoose:Bool = true;

	var creditsY:Int = 64;
	var creditsDelay:Float = 0.8;

	var pauseGroup:FlxSpriteGroup;

	public static var songName:String = null;

	override function create()
	{
		pauseGroup = new FlxSpriteGroup();
		add(pauseGroup);

		menuItems = menuItemsOG;

		pauseMusic = new FlxSound();

		if(FlxG.save.data.progressState == 2)
		{
			pauseMusic.loadEmbedded(Paths.music('creppy_pause'), true, true);
		}
		else
		{
			try
			{
				var pauseSong:String = getPauseSong();
				if(pauseSong != null) pauseMusic.loadEmbedded(Paths.music('pause_music/'+pauseSong), true, true);
			}
			catch(e:Dynamic) {}
		}

		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('pause_real/Mario_static');
		bg.animation.addByPrefix('idle', "static play", 24);
        bg.animation.play('idle');
		bg.setGraphicSize(Std.int(FlxG.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		pauseGroup.add(bg);

		var stp = new FlxSprite(20, 50).loadGraphic(Paths.image('pause_real/stop_sign'));
		stp.updateHitbox();
		stp.scrollFactor.set();
		pauseGroup.add(stp);

		var pausedTxt:FlxText = new FlxText(20, 50, 0, 'PAUSED', 96);
		pausedTxt.scrollFactor.set();
		pausedTxt.setFormat(Paths.font("vcr.ttf"), 96);
		pausedTxt.updateHitbox();
		pausedTxt.scrollFactor.set();
		pauseGroup.add(pausedTxt);

		var levelInfo:FlxText = new FlxText(20, 350, 0, PlayState.SONG.displayName == null ? PlayState.SONG.song : PlayState.SONG.displayName, 48);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 48);
		levelInfo.updateHitbox();
		pauseGroup.add(levelInfo);

		var blueballedTxt:FlxText = new FlxText(20, 370 + 32, 0, Language.getPhrase("blueballed", "Deaths: {1}", [PlayState.deathCounter]), 32);
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		pauseGroup.add(blueballedTxt);

		var levelArtist:FlxText = new FlxText(20, 370 + creditsY, 0, Language.getPhrase("artist", "Art: {1}", [PlayState.SONG.art]), 32);
		if (PlayState.SONG.art != null && PlayState.SONG.art != '')
		{
			levelArtist.scrollFactor.set();
			levelArtist.setFormat(Paths.font("vcr.ttf"), 32);
			levelArtist.updateHitbox();
			pauseGroup.add(levelArtist);
			creditsY += 32;
		}

		var levelMusic:FlxText = new FlxText(20, 370 + creditsY, 0, Language.getPhrase("music", "Music: {1}", [PlayState.SONG.music]), 32);
		if (PlayState.SONG.music != null && PlayState.SONG.music != '')
		{
			levelMusic.scrollFactor.set();
			levelMusic.setFormat(Paths.font("vcr.ttf"), 32);
			levelMusic.updateHitbox();
			pauseGroup.add(levelMusic);
			creditsY += 32;
		}

		var levelCode:FlxText = new FlxText(20, 370 + creditsY, 0, Language.getPhrase("code", "Code: {1}", [PlayState.SONG.code]), 32);
		if (PlayState.SONG.code != null && PlayState.SONG.code != '')
		{
			levelCode.scrollFactor.set();
			levelCode.setFormat(Paths.font("vcr.ttf"), 32);
			levelCode.updateHitbox();
			pauseGroup.add(levelCode);
			creditsY += 32;
		}

		var levelCharter:FlxText = new FlxText(20, 370 + creditsY, 0, Language.getPhrase("charter", "Chart: {1}", [PlayState.SONG.chart]), 32);
		if (PlayState.SONG.chart != null && PlayState.SONG.chart != '')
		{
			levelCharter.scrollFactor.set();
			levelCharter.setFormat(Paths.font("vcr.ttf"), 32);
			levelCharter.updateHitbox();
			pauseGroup.add(levelCharter);
			creditsY += 32;
		}

		levelArtist.scale.set(0.6, 1);
		levelMusic.scale.set(0.6, 1);
		levelCode.scale.set(0.6, 1);
		levelCharter.scale.set(0.6, 1);

		levelArtist.updateHitbox();
		levelMusic.updateHitbox();
		levelCode.updateHitbox();
		levelCharter.updateHitbox();

		stp.x = FlxG.width - (stp.width + 20);
		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		if (PlayState.SONG.art != null && PlayState.SONG.art != '') levelArtist.x = FlxG.width - (levelArtist.width + 20);
		if (PlayState.SONG.music != null && PlayState.SONG.music != '') levelMusic.x = FlxG.width - (levelMusic.width + 20);
		if (PlayState.SONG.code != null && PlayState.SONG.code != '') levelCode.x = FlxG.width - (levelCode.width + 20);
		if (PlayState.SONG.chart != null && PlayState.SONG.chart != '') levelCharter.x = FlxG.width - (levelCharter.width + 20);
		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		regenMenu();

		var overlay:FlxSprite = new FlxSprite();
		overlay.frames = Paths.getSparrowAtlas('pause_real/screenstatic');
		overlay.animation.addByPrefix('idle', "screenSTATIC", 24);
        overlay.animation.play('idle');
		overlay.setGraphicSize(Std.int(FlxG.width * 1.1));
		overlay.updateHitbox();
		overlay.screenCenter();
		overlay.alpha = 0.5;
		overlay.blend = OVERLAY;
		overlay.scrollFactor.set();
		pauseGroup.add(overlay);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		staticTransition = new FlxSprite();
		staticTransition.frames = Paths.getSparrowAtlas('staticTV');
		staticTransition.animation.addByPrefix('idle', "static", 24);
        staticTransition.animation.play('idle');
		staticTransition.updateHitbox();
		staticTransition.screenCenter();
		staticTransition.scale.set(4,4);
		staticTransition.alpha = 0.00001;
		add(staticTransition);

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
			pauseMusic.volume += 0.02 * elapsed;

		super.update(elapsed);

		if (FlxG.keys.firstJustPressed() != FlxKey.NONE) mouseMode = false;
		if (FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) mouseMode = true;

		var cam = cameras != null && cameras.length > 0 ? cameras[0] : FlxG.camera;
		var mousePos:FlxPoint = FlxG.mouse.getScreenPosition(cam);

		var dist:Float = -1;
		var distItem:Int = -1;
		if (canChoose && mouseMode)
		{
			var selectedItem:FlxSprite;
			selectedItem = grpMenuShit.members[curSelected];

			for (i in 0...menuItems.length)
			{
				var memb:FlxSprite = grpMenuShit.members[i];
				if (memb.overlapsPoint(mousePos, true, cam))
				{
					var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
					if (dist < 0 || distance < dist)
					{
						dist = distance;
						distItem = i;
					}

					if(FlxG.mouse.justPressed && mouseMode && (cantUnpause <= 0))
						select();
				}
			}

			if(distItem != -1 && selectedItem != grpMenuShit.members[distItem])
			{
				curSelected = distItem;
				changeSelection();
			}
		}

		/*if (FlxG.keys.justPressed.H)
		{
			pauseGroup.visible = !pauseGroup.visible;
			grpMenuShit.visible = !grpMenuShit.visible;
		}

		if (FlxG.keys.justPressed.G)
		{
			PlayState.instance.uiGroup.visible = !PlayState.instance.uiGroup.visible;
			PlayState.instance.comboGroup.visible = !PlayState.instance.comboGroup.visible;
			PlayState.instance.noteGroup.visible = !PlayState.instance.noteGroup.visible;
		}*/

		if(controls.BACK)
		{
			close();
			return;
		}

		if(FlxG.keys.justPressed.ESCAPE)
		{
			close();
			return;
		}

		if(FlxG.keys.justPressed.F5)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			PlayState.nextReloadAll = true;
			MusicBeatState.resetState();
		}

		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			mouseMode = false;
		}

		if (controls.UI_UP_P || FlxG.mouse.wheel > 0)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P || FlxG.mouse.wheel < 0)
		{
			changeSelection(1);
		}

		if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode) && !mouseMode)
		{
			if (!canChoose) return;
			select();
		}
	}

	public function select()
	{
		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case "Resume":
				close();
				FlxG.mouse.visible = false;
			case "Restart":
				canChoose = false;
				FlxG.mouse.visible = false;
				if(PlayState.SONG.fullRestart)
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxG.sound.play(Paths.sound('real_menu_sounds/static_sound'));
					staticTransition.alpha = 1;

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						restartSong();
					});

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
				canChoose = false;
				FlxG.sound.play(Paths.sound('real_menu_sounds/static_sound'));
				staticTransition.alpha = 1;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					PlayState.instance.paused = true; // For lua
					PlayState.instance.vocals.volume = 0;
					PlayState.instance.canResync = false;
					MusicBeatState.switchState(new RealOptionsState());
					if(ClientPrefs.data.pauseMusic != 'None')
					{
						FlxG.sound.playMusic(Paths.music('pause_music/'+Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
						FlxG.sound.music.time = pauseMusic.time;
					}
					RealOptionsState.onPlayState = true;
				});
			case "Exit":
				canChoose = false;
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;

				PlayState.instance.canResync = false;
				Mods.loadTopMod();

				FlxG.sound.play(Paths.sound('real_menu_sounds/static_sound'));
				staticTransition.alpha = 1;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
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
				});

				PlayState.changedDifficulty = false;
				PlayState.chartingMode = false;
				FlxG.camera.followLerp = 0;
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
		if (!canChoose) return;
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		for (num => item in grpMenuShit.members)
		{
			item.alpha = 0.6;
			if (item.ID == curSelected)
				item.alpha = 1;
		}
		FlxG.sound.play(Paths.sound('real_menu_sounds/key_select'), 0.4);
	}

	function regenMenu():Void {
		var curID:Int = -1;
		for (num => str in menuItems) {
			curID += 1;
			var item = new FlxText(20, (num * 100) + 320, 0, Language.getPhrase('pause_$str', str), 64);
			item.setFormat(Paths.font("vcr.ttf"), 64);
			item.ID = curID;
			item.scrollFactor.set();
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}
