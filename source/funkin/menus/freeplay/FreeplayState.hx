package funkin.menus.freeplay;

import funkin.data.*;
import haxe.io.Path;
import lime.app.Application;
import funkin.graphics.shaders.DaveAndBambiGlitchShader;

import funkin.game.objects.HealthIcon;

import funkin.audio.FunkinSound;

import funkin.menus.real_options.RealGameplayChangersSubstate;
import funkin.submenus.ResetScoreSubState;
import funkin.submenus.skins.SkinSubstate;

import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;

import openfl.utils.Assets;

import funkin.menus.storymenu.StoryMenuState;

import haxe.Json;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var leftArrows:FlxSprite;
	var rightArrows:FlxSprite;

	var staticTransition:FlxSprite;

	var dnbShader:DaveAndBambiGlitchShader = null;

	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	var curVariation:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefaultDifficult();
	private static var lastVariationName:String = Difficulty.getDefaultVariation();

	private var grpSongs:FlxTypedGroup<Capsule>;
	private var curPlaying:Bool = false;

	var bg:FlxSprite;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;

	var hitbox:FlxSprite;

	var chooseb:Bool = false;

	var backButt:FlxSprite;
	var gayButt:FlxSprite;
	var bfButt:FlxSprite;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		FlxG.mouse.visible = true;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new funkin.menus.ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new funkin.debug.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length)
		{
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			WeekData.setDirectoryFromWeek(leWeek);
		}

		addSong('Fire Thoser', 4, 200, 0);
		addSong('Too Fire Gone', 6, 160, 0);
		addSong('Obrutality', 6, 140, 1);
		addSong('Triple Trouble', 5, 146, 1);
		addSong('THE END', 6, 150, 1);

		if(StoryMenuState.weekCompleted.exists('weekexe'))
		{
			addSong('Too Fire', 8, 180, 2);
			addSong("You Can't Fire", 10, 140, 2);
			addSong('Doomsday', 7, 196, 2);
		}

		if(StoryMenuState.weekCompleted.exists('weekfinal'))
		{
			addSong('Last Stand', 7, 175, 3);
			addSong("Hell Valley", 6, 150, 3);
			addSong('Games Are Over', 12, 196, 3);
		}

		if(songs.length < 1) //check cuz THATS ACTUALLY POSSIBLE IF YOU THINK ABOUT IT
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new funkin.menus.ErrorState("NO SONGS WITH CHARTS\n\nPress ACCEPT to go to the Chart Editor Menu.\nPress BACK to return to Main Menu.",
				function() LoadingState.loadAndSwitchState(new funkin.debug.editors.ChartingState(), false),
				function() MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState())));
			return;
		}

		Mods.loadTopMod();

		dnbShader = new DaveAndBambiGlitchShader();

		bg = new FlxSprite().loadGraphic(Paths.image('freeplay_menu/background'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(FlxG.width * 1.1));
		bg.shader = dnbShader;
		add(bg);
		bg.screenCenter();

		bg.scrollFactor.set(0.45, 0.45);

		grpSongs = new FlxTypedGroup<Capsule>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Capsule = new Capsule(0, 0, songs[i].songName, songs[i].bpm, songs[i].difficulty, curDifficulty, curVariation);
			var centX = (FlxG.width/2) - (songText.width /2);
			var centY = (FlxG.height/2) - (songText.height /2);
			songText.ID = i;

			songText.y = centY;
			songText.x = centX - (curSelected-songText.ID) * 1000;

			grpSongs.add(songText);

			Mods.currentModDirectory = songs[i].folder;
		}
		WeekData.setDirectoryFromWeek();

		grpSongs.forEach(function(spr:FlxSprite)
		{
			var centX = (FlxG.width/2) - (spr.width /2);

			spr.x = centX - (curSelected-spr.ID) * 1000;
		});

		hitbox = new FlxSprite().makeGraphic(755, 481, FlxColor.BLACK);
		hitbox.setPosition((FlxG.width/2) - (hitbox.width /2), (FlxG.height/2) - (hitbox.height /2));
		hitbox.scrollFactor.set();
		hitbox.alpha = 0.001;
		add(hitbox);

		final ui_tex = Paths.getSparrowAtlas('freeplay_menu/buttons');

		if (leftArrows == null){
			leftArrows = new FlxSprite(20, 300);
			leftArrows.antialiasing = ClientPrefs.data.antialiasing;
			leftArrows.frames = ui_tex;
			leftArrows.animation.addByPrefix('idle', "butt_default");
			leftArrows.animation.addByPrefix('press', "butt_press");
			leftArrows.animation.play('idle');
			leftArrows.screenCenter(Y);
		}
		add(leftArrows);

		if (rightArrows == null){
			rightArrows = new FlxSprite(FlxG.width * 0.94, leftArrows.y);
			rightArrows.antialiasing = ClientPrefs.data.antialiasing;
			rightArrows.frames = ui_tex;
			rightArrows.screenCenter(Y);
			rightArrows.animation.addByPrefix('idle', "butt_default");
			rightArrows.animation.addByPrefix('press', "butt_press");
			rightArrows.flipX = true;
			rightArrows.animation.play('idle');
		}
		add(rightArrows);

		backButt = new FlxSprite(FlxG.width - 100, 25).loadGraphic(Paths.image('x'));
		backButt.scale.set(2,2);
		backButt.scrollFactor.set();
		add(backButt);

		gayButt = new FlxSprite(-15, FlxG.height - 225).loadGraphic(Paths.image('gameplay_butt'));
		gayButt.scale.set(0.7, 0.7);
		gayButt.scrollFactor.set();
		add(gayButt);

		bfButt = new FlxSprite(FlxG.width - 225, FlxG.height - 225).loadGraphic(Paths.image('skin_butt'));
		bfButt.scale.set(0.7, 0.7);
		bfButt.scrollFactor.set();
		add(bfButt);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		curVariation = Math.round(Math.max(0, Difficulty.defaultVariationList.indexOf(lastVariationName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = Language.getPhrase("freeplay_tip", "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.");
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.RED, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		
		player = new MusicPlayer(this);
		add(player);
		
		changeSelection();
		updateTexts();
		super.create();

		staticTransition = new FlxSprite();
		staticTransition.frames = Paths.getSparrowAtlas('staticTV');
		staticTransition.animation.addByPrefix('idle', "static", 24);
        staticTransition.animation.play('idle');
		staticTransition.updateHitbox();
		staticTransition.screenCenter();
		staticTransition.scale.set(4,4);
		staticTransition.alpha = 0.00001;
		add(staticTransition);

		staticTransition.scrollFactor.set(0, 0);
		bottomText.scrollFactor.set(0, 0);
		bottomBG.scrollFactor.set(0, 0);
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();

		for (num => item in grpSongs.members)
		{
			item.refreshScore();
		}
	}

	public function addSong(songName:String, difficulty:Int, bpm:Int, week:Int)
	{
		songs.push(new SongMetadata(songName, difficulty, bpm, week));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	var holdTime:Float = 0;

	var stopMusicPlay:Bool = false;
	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
			return;

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		var mouse = FlxG.mouse.getScreenPosition(FlxG.camera);
		FlxG.camera.scroll.set(FlxMath.lerp(FlxG.camera.scroll.x, (mouse.x / 60) - 20, elapsed * 3), FlxMath.lerp(FlxG.camera.scroll.y, (mouse.y / 60) - 20, elapsed * 3));

		if (!player.playingMusic)
		{
			if (!chooseb)
			{
				if(songs.length > 1)
				{
					if(FlxG.keys.justPressed.HOME)
					{
						curSelected = 0;
						changeSelection();
						holdTime = 0;	
					}
					else if(FlxG.keys.justPressed.END)
					{
						curSelected = songs.length - 1;
						changeSelection();
						holdTime = 0;	
					}
					if (controls.UI_LEFT_P || FlxG.mouse.overlaps(leftArrows) && FlxG.mouse.justPressed)
					{
						changeSelection(-shiftMult);
						holdTime = 0;
					}
					if (controls.UI_RIGHT_P || FlxG.mouse.overlaps(rightArrows) && FlxG.mouse.justPressed)
					{
						changeSelection(shiftMult);
						holdTime = 0;
					}
		
					if(controls.UI_LEFT || controls.UI_RIGHT)
					{
						var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
						holdTime += elapsed;
						var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
		
						if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
							changeSelection((checkNewHold - checkLastHold) * (controls.UI_LEFT ? -shiftMult : shiftMult));
					}
		
					if(FlxG.mouse.wheel != 0)
					{
						FunkinSound.playOnce(Paths.sound('real_menu_sounds/key_select'), 0.4);
						changeSelection(-shiftMult * FlxG.mouse.wheel, false);
					}
				}
			}
		}

		if(FlxG.mouse.overlaps(backButt) && FlxG.mouse.justPressed)
		{
			if (!chooseb)
			{
				if (player.playingMusic)
				{
					FlxG.sound.music.stop();
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
					instPlaying = -1;
		
					player.playingMusic = false;
					player.switchPlayMusic();
		
					FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'), 0);
					FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
				}
				else 
				{
					chooseb = true;
					
					FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));
					staticTransition.alpha = 1;
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						persistentUpdate = false;
						MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
					});
				}
			}
		}

		if (controls.BACK)
		{
			if (!chooseb)
			{
				if (player.playingMusic)
				{
					FlxG.sound.music.stop();
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
					instPlaying = -1;
		
					player.playingMusic = false;
					player.switchPlayMusic();
		
					FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'), 0);
					FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
				}
				else 
				{
					chooseb = true;
					
					FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));
					staticTransition.alpha = 1;
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						persistentUpdate = false;
						MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
					});
				}
			}
		}

		if(FlxG.mouse.overlaps(bfButt) && FlxG.mouse.justPressed)
		{
			persistentUpdate = false;
			openSubState(new SkinSubstate());
		}

		if(FlxG.mouse.overlaps(gayButt) && FlxG.mouse.justPressed)
		{
			persistentUpdate = false;
			openSubState(new RealGameplayChangersSubstate());
		}
		
		if(FlxG.keys.justPressed.TAB && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new SkinSubstate());
		}
		if(FlxG.keys.justPressed.CONTROL && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new RealGameplayChangersSubstate());
		}
		if(FlxG.keys.justPressed.SPACE)
		{
			if (!chooseb)
			{
				if(instPlaying != curSelected && !player.playingMusic)
				{
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;
		
					Mods.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty, curVariation);
					Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					if (PlayState.SONG.needsVoices)
					{
						vocals = new FlxSound();
						try
						{
							var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
							var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
							if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
								
							if(loadedVocals != null && loadedVocals.length > 0)
							{
								vocals.loadEmbedded(loadedVocals);
								FlxG.sound.list.add(vocals);
								vocals.persist = vocals.looped = true;
								vocals.volume = 0.8;
								vocals.play();
								vocals.pause();
							}
							else vocals = FlxDestroyUtil.destroy(vocals);
						}
						catch(e:Dynamic)
						{
							vocals = FlxDestroyUtil.destroy(vocals);
						}
							
						opponentVocals = new FlxSound();
						try
						{
							//trace('please work...');
							var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
							var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
								
							if(loadedVocals != null && loadedVocals.length > 0)
							{
								opponentVocals.loadEmbedded(loadedVocals);
								FlxG.sound.list.add(opponentVocals);
								opponentVocals.persist = opponentVocals.looped = true;
								opponentVocals.volume = 0.8;
								opponentVocals.play();
								opponentVocals.pause();
								//trace('yaaay!!');
							}
							else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
						}
						catch(e:Dynamic)
						{
							//trace('FUUUCK');
							opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
						}
					}
		
					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
					FlxG.sound.music.pause();
					instPlaying = curSelected;
		
					player.playingMusic = true;
					player.curTime = 0;
					player.switchPlayMusic();
					player.pauseOrResume(true);
				}
				else if (instPlaying == curSelected && player.playingMusic)
				{
					player.pauseOrResume(!player.playing);
				}
			}
		}
		else if (controls.ACCEPT && !player.playingMusic)
		{
			if (!chooseb)
			{
				selectSong();
			}
		}
		else if(controls.RESET && !player.playingMusic)
		{
			if (!chooseb)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, curVariation));
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/key_select'));
			}
		}

		if(FlxG.mouse.overlaps(hitbox) && FlxG.mouse.justPressed && !chooseb)
			selectSong();

		updateTexts(elapsed);
		super.update(elapsed);

		if (dnbShader != null) dnbShader.data.uTime.value[0] += elapsed;
	}

	function selectSong()
	{
		persistentUpdate = true;
		var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		var poop:String = Highscore.formatSong(songLowercase, curDifficulty, curVariation);
	
		try
		{
			Song.loadFromJson(poop, songLowercase);
			PlayState.isFirstSongInCampaign = true;
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.variation = curVariation;
	
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
		}
		catch(e:haxe.Exception)
		{
			trace('ERROR! ${e.message}');
	
			var errorStr:String = e.message;
			if(errorStr.contains('There is no TEXT asset with an ID of')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
			else errorStr += '\n\n' + e.stack;
	
			missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
			missingText.screenCenter(Y);
			missingText.visible = true;
			missingTextBG.visible = true;
			FunkinSound.playOnce(Paths.sound('cancelMenu'));
	
			//updateTexts(elapsed);
			//super.update(elapsed);
			return;
		}

		WeekData.setDirectoryFromWeek();

		FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));
		FlxG.mouse.visible = false;
		staticTransition.alpha = 1;
		chooseb = true;

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			var directory = StageData.forceNextDirectory;
			LoadingState.loadNextDirectory();
			StageData.forceNextDirectory = directory;

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
			#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
			stopMusicPlay = true;

			destroyFreeplayVocals();
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		});
	}
	
	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		catch (e:Dynamic) {}
		return null;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function checkIfDifficultyExist(change:Int = 0, newSong:Bool = false)
	{
		if(newSong)
		{
			var songLowercasePrev:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poopPrev:String = Highscore.formatSong(songLowercasePrev, curDifficulty, curVariation);
	
			static var _lastPathPrev:String;
			var formattedFolderPrev:String = Paths.formatToSongPath(songLowercasePrev);
			var formattedSongPrev:String = Paths.formatToSongPath(poopPrev);
			_lastPathPrev = Paths.json('$formattedFolderPrev/$formattedSongPrev');
	
			if (#if MODS_ALLOWED FileSystem.exists(_lastPathPrev) || #end Assets.exists(_lastPathPrev))
				curDifficulty += change;
			else
			{
				curDifficulty = 1;
				curVariation = 0;
			}
		}
		else
			curDifficulty += change;
		
		if (curDifficulty < 0) 
		{
			curVariation--;

			if (curVariation < 0) 
				curVariation = Difficulty.variationList.length - 1;
			if (curVariation >= Difficulty.variationList.length) 
				curVariation = 0;

			curDifficulty = Difficulty.list.length - 1;
		}

		if (curDifficulty >= Difficulty.list.length)
		{
			curVariation++;

			if (curVariation < 0) 
				curVariation = Difficulty.variationList.length - 1;
			if (curVariation >= Difficulty.variationList.length) 
				curVariation = 0;

			curDifficulty = 0;
		}

		var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		var poop:String = Highscore.formatSong(songLowercase, curDifficulty, curVariation);

		static var _lastPath:String;
		var formattedFolder:String = Paths.formatToSongPath(songLowercase);
		var formattedSong:String = Paths.formatToSongPath(poop);
		_lastPath = Paths.json('$formattedFolder/$formattedSong');

		if (#if MODS_ALLOWED FileSystem.exists(_lastPath) || #end Assets.exists(_lastPath))
			return;
		else
			checkIfDifficultyExist(change);
	}

	function changeDiff(change:Int = 0, newSong:Bool = false)
	{
		if (player.playingMusic)
			return;

		//had to use old version of difficulty things due to variations
		checkIfDifficultyExist(change, newSong);

		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic)
			return;

		if(curSelected == 5 && change == -1)
		{
			if(playSound) FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'), 1);

			if(FlxG.random.bool(0.1))
				Application.current.window.alert(errMsg, "Well, there is a man here.");
		}

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);

		if(curSelected == 5 && change == 1)
		{
			if(playSound) FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'), 1);

			if(FlxG.random.bool(0.1))
				Application.current.window.alert(errMsg, "Well, there is a man here.");
		}

		_updateSongLastDifficulty();
		if(playSound) FunkinSound.playOnce(Paths.sound('real_menu_sounds/key_select'), 1);
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		//Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if (savedDiff != null && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefaultDifficult()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefaultDifficult())));
		else
			curDifficulty = 0;

		var savedVar:String = songs[curSelected].lastVariationName;
		var lastVar:Int = Difficulty.variationList.indexOf(lastVariationName);
		if (savedVar != null && Difficulty.variationList.contains(savedVar))
			curVariation = Math.round(Math.max(0, Difficulty.variationList.indexOf(savedVar)));
		else if(lastVar > -1)
			curVariation = lastVar;
		else if(Difficulty.variationList.contains(Difficulty.getDefaultVariation()))
			curVariation = Math.round(Math.max(0, Difficulty.defaultVariationList.indexOf(Difficulty.getDefaultVariation())));
		else
			curVariation = 0;

		changeDiff(0, true);
		_updateSongLastDifficulty();
		_updateSongLastVariation();
	}

	inline private function _updateSongLastDifficulty()
		songs[curSelected].lastDifficulty = Difficulty.getDiffString(curDifficulty, false);

	inline private function _updateSongLastVariation()
		songs[curSelected].lastVariationName = Difficulty.getVarString(curVariation, false);

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		grpSongs.forEach(function(spr:FlxSprite)
		{
			var centX = (FlxG.width/2) - (spr.width /2);
			var centY = (FlxG.height/2) - (spr.height /2);

			spr.x = FlxMath.lerp(spr.x, centX - (curSelected-spr.ID) * 1000, FlxMath.bound(elapsed * 10, 0, 1));
	
			/*if(spr.ID == curSelected)
				spr.alpha = 1;
			else
				spr.alpha = 0.6;*/
		});
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing && !stopMusicPlay)
			FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'), 0);
	}	

	var errMsg:String = "
	 															‚3§ààhhhààààhààààµ7·                    
                                                            ¹hàààààààààààhhààÇó’                    
                                                            ¹hààhàààhhààààhààÇÌ˜                    
                                                            ­äÇààààÇÇÇÇÇÇššÇÇ67·                    
                                                ;öàhhhhhhhhhûààààÇõ÷··········`                     
                        ¸=TPääääääääPääääe<…    |äàààààààààààààhàšv´                                
                        ›xààààààààhhhhààààžr   ºnÿñññäààààààààhàààh¢<<<<<<<<<<<<<<<ì„               
                        ›yàààhhàààààhàààààààûû§ûšÇÇÇÇÇààààhhàààhàààààààààààààààààààÇk1`             
                        ›yàààààhààààhhààhààààààààààààààààààààààààààhààààhààààhààààààÝv`             
              `;çaaaaaü©2ššàààààààààhhààààhààhhààhhàààZáññññññááññäààààààààhààààààààÝj`             
              ‹ñÜÜÜÜÜ$DÇààààààààààhààààààààhàààààààhÇFÞÞÞÞÞÞÞÞÞÞÞÞÞáààààhhàààààhààààkv`             
              ‹ñÜÜÜÜÜ$ñààààààààààààààààààààààhààààààÇ¥ÞÞÞÞÞÞÞÞÞÞÞÞÞáààààààààààààààààûî`             
              ‹ñÜÜÜÜÜëñààààààààààààààààhààààhààhààààÇ¥ÞÞÞÞÞÞÞÞÞÞÞÞÞáhhààààààààààÇPbbbä‰}}}}}}}}}}×”´
              ‹ñÜÜÜÜÜëñààààààààààààààààhàààààààhààhààš¥ååååååååååÖñÇàààààààhàààààààhààààààààààààààûv
              ‹ñÜÜÜÜÜ$¥àààààààààààààààààààààààààààhàààààààààhàhhàààààààààhààààààààààààààààhàààààààäc
`–¬¬¬¬¬¬•1@nnn3bèëÜÜÜÜÜ$ëëëë$ë$ëëëëëýèÓÓÓÒÒbÇààààààààhàààààààààààààààààààààààààààààààhàààààààhààààšc
l§ààhàààààààààÇààšÞÚÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÚÜ$äààhhhààààààààÇhhàààààààààààààhààààààààààààààààààààààààààäî
îšààààhàààààààààààÖÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ$äààààààààààààààhàààààààààààààààààààhààààààààààààhààààààààšc
7TàààààààààààààààšÒÞÞÞÞÞÞÞèëÜÜÜÜÜÜÜÜÜÜÜÜ$äààààààhààhààààààààhàààààààààààààààààààààààààààààààhhààààšî
`‘²²²²²²¢ëëëdÓåååÖÖÞÞÞÞÞÞÞÞëÜÜÜÚÜÙýýýýýýèäàààààààààààhààààààààààhàààhààààààààààhàààààààààààààààhààäc
        ¤ÜÜÜÜýÞÞÞÞÞÞÞÞÞÞÞÞÞdÜÜÜÜÞÞÞÞÞÞÞÞÖšàààààààààààààààhhàààààààhàààààààààààààÇÇÇÇÇÇÇÇÇÇÇÇÇÇÇšààäc
        ¤ÜÜÜÜÜdÙÙÙÙÙÙÙÙÙÙÙ$ÜÜÜÜÜÞÞÞÞÞÞÞÞÖäàààààààhààhhàààààhàààààààhàààààààààààáÖÖÞÞÖÞÞÞÞÞÞÞÞÞÞÖbàž>
        ¤ÚÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÞÞÞÞÖÞÞÞÖähàààÇàààààààààààààààààhhàààààààààhdddýÞÞÞÞÞÞÞÞÞÖÞÞÞÞÞÞ6“’`
        ¤ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÞÞÞÞÞÞÞÞÿšhàààààààhàààààhààààààààhhhààààààPëÚÚÚëÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞÞ¾¨  
        ¤ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÙFááááááPPPPPPäàààààààààààààààààààààààààààààààààhäëÚÜÜdÞÞÞÞÞÞÞÞÞÞÖÞÞÞÞb©¨  
        ¤ÚÜÜÜÜÜÜÜÜÜÜÜÜÜÜ$PààààààààhhhàhhàààààPÿFàààààààààààààààààhààààààbåýÜÜÜÜÜÜ$$$$$$O„„„„„„„–    
        iäÜÜÜÜÜÜÜÜÜÜÜÜ$$ëäàààààààhààààààààààäÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ¾            
        ``¨¨¨¨¨¨¨¨¨¨¨¨¨¨¹OàààààààààààààhààààäÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜf            
                        ›yàhàààààhààààààààhàäÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜàc            
                        ´»fû§§§§§§§§ÇàÇàÇàhhÇääššššššššä$ÚÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜc                       
                                   ;5ÚÜÚÜÞPàààààààààààààšdÜÜÚÚÚÚÚÚÚÚÚÚÚÜÚÚÚT(                       
                                   `´‚‚‚‚¡4àààààààààààààPŠêÿ:‘‘‘‘‘ÏÿÿÿÿÿÿÒÿFááñáü´                  
                                         „4àhàààààààààààPÛêÒ¨   `¿ÚœXgpqœÛëÖÞy/ª²``                 
                                         “aàààààààààààààáÛÐÿ;‘‘‘’jãœXgøJì×’     `                   
                                         `ˆ|»‡ýppppppppßœœXŠÕÔÕÕÕqœœgGö’                            
                                            `†ÚXXXXXXXXœœœœXœœœœœœGýÖó;`                            
                                            `†8gXXXXXXXXÐP‰jvvvjvj—`                                
                                    ````````›yâXXXXXXXXXÐ®—`                                        
                                  `‰abÔÔÔAÔÔÕœœœXXXXXXXXg®^                                         
                                 ¨VãÐŽXXœXXXXXXXœœXœœœXœåt;                                         
                                 ¨VŠXXœãœœXXXXXœÐâøøøÜÙ%i‚                                          
                                 ¨VŠXXGêŽXXXXœŽAŸ•                                                  
                                `¡ÝêXXâgXXŠœÐGœAf                                                   
                             `•uò6ê¶ŠXâgœq¶gêðXêÿò÷`                                                
                          ÷ápmŠêß€ÔÐŽAëÐœg€ãŽqmmGâãpã6söˆ                                           
                         ¦hÐã¶¶øßqGøøGqœßã$ÙýœXœgÔ8ãAÔÐH£333ò…   
	";
}

class SongMetadata
{
	public var songName:String = "";
	public var bpm:Int = 0;
	public var difficulty:Int = 0;
	public var week:Int = 0;
	public var folder:String = "";
	public var lastDifficulty:String = null;
	public var lastVariationName:String = null;

	public function new(song:String, difficulty:Int, bpm:Int, week:Int)
	{
		this.songName = song;
		this.bpm = bpm;
		this.difficulty = difficulty;
		this.week = week;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}