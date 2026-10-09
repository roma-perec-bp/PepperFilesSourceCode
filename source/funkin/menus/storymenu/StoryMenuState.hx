package funkin.menus.storymenu;

import funkin.data.*;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;

import funkin.graphics.FunkinSprite;

import funkin.audio.FunkinSound;

import funkin.objects.MenuItem;
import flixel.util.FlxStringUtil;
import funkin.menus.options.GameplayChangersSubstate;

import funkin.submenus.ResetScoreSubState;
import funkin.submenus.StoryProgressSubState;

import funkin.menus.FullScreenScaleMode;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	var zephGfx:MenuItem;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var staticTransition:FlxSprite;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	var tracksSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var backButt:FlxSprite;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;
		WeekData.reloadWeekFiles(true);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new funkin.menus.ErrorState("NO LEVELS ADDED FOR STORY MODE\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new funkin.debug.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState())));
			return;
		}

		if(curWeek >= WeekData.weeksList.length) curWeek = 0;

		scoreText = new FlxText(Math.max(FullScreenScaleMode.gameNotchSize.x, 10), 10, 0, Language.getPhrase('week_score', 'LEVEL SCORE: {1}', [lerpScore]), 36);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32);
		scoreText.color = 0xFFFF0000;

		txtWeekTitle = new FlxText(Math.max(FlxG.width * 0.7, FlxG.width - FullScreenScaleMode.gameNotchSize.x), 10, 0, "", 32);
		txtWeekTitle.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.RED, RIGHT);
		txtWeekTitle.alpha = 1;

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFF000000);
		bgSprite = new FlxSprite(0, 56);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FunkinSprite = new FunkinSprite(bgYellow.x, 0).makeSolidColor(FlxG.width, Std.int(400 + bgYellow.y), FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var num:Int = 0;
		var itemTargetY:Float = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
				weekThing.y += ((weekThing.height + 20) * num);
				weekThing.ID = num;
				weekThing.targetY = itemTargetY;
				itemTargetY += Math.max(weekThing.height, 110) + 10;
				grpWeekText.add(weekThing);

				if(FlxG.save.data.progressState == 5)
					if (i == 4) zephGfx = weekThing;

				weekThing.screenCenter(X);
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.antialiasing = ClientPrefs.data.antialiasing;
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.x += (FullScreenScaleMode.gameCutoutSize.x / 4);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		final useNotch:Bool = Math.max(35, FullScreenScaleMode.gameNotchSize.x) != 35;

		Difficulty.resetList();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefaultDifficult();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		add(bgYellow);
		add(bgSprite);
		add(grpWeekCharacters);

		var gradientShit = new FlxSprite(0, 442).loadGraphic(Paths.image('story_gradient'));
		gradientShit.antialiasing = ClientPrefs.data.antialiasing;
		gradientShit.screenCenter(X);
		add(gradientShit);

		tracksSprite = new FlxSprite(FlxG.width * 0.07 + 100, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.data.antialiasing;
		tracksSprite.x -= tracksSprite.width/2;
		add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = Paths.font("vcr.ttf");
		txtTracklist.color = 0xFFFF0000;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		backButt = new FlxSprite(FlxG.width - 200, 550).loadGraphic(Paths.image('x'));
		backButt.scale.set(2,2);
		add(backButt);

		changeWeek();
		changeDifficulty();

		super.create();

		FlxG.mouse.visible = true;

		staticTransition = new FlxSprite();
		staticTransition.frames = Paths.getSparrowAtlas('staticTV');
		staticTransition.animation.addByPrefix('idle', "static", 24);
        staticTransition.animation.play('idle');
		staticTransition.updateHitbox();
		staticTransition.screenCenter();
		staticTransition.scale.set(4,4);
		staticTransition.alpha = 0.00001;
		add(staticTransition);
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
		{
			if (controls.BACK && !movedBack && !selectedWeek)
			{
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));
				movedBack = true;

				staticTransition.alpha = 1;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
				});
			}
			super.update(elapsed);
			return;
		}

		// scoreText.setFormat(Paths.font("vcr.ttf"), 32);
		if(intendedScore != lerpScore)
		{
			lerpScore = Std.int(MathUtil.snap(MathUtil.smoothLerpPrecision(lerpScore, intendedScore, elapsed, 0.307), intendedScore, 1));
			//lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
	
			scoreText.text = Language.getPhrase('week_score', 'LEVEL SCORE: {1}', [FlxStringUtil.formatMoney(lerpScore, false, true)]);
		}

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var changeDiff = false;
			if (controls.UI_UP_P)
			{
				changeWeek(-1);
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/key_select'), 1);
				changeDiff = true;
			}

			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/key_select'), 1);
				changeDiff = true;
			}

			if(FlxG.mouse.wheel != 0)
			{
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/key_select'), 1);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, 0, curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
				selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));
			movedBack = true;

			staticTransition.alpha = 1;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
			});
		}

		if(FlxG.mouse.overlaps(backButt) && FlxG.mouse.justPressed && !movedBack && !selectedWeek)
		{
			FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));
			movedBack = true;

			staticTransition.alpha = 1;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
			});
		}

		if (zephGfx != null)
		{
			zephGfx.scale.x = 0.2 + 0.5 * Math.random();
			zephGfx.scale.y = 0.75 + 0.5 * Math.random();

			if (Math.random() > 0.5) zephGfx.scale.x *= -1;
			if (Math.random() > 0.5) zephGfx.scale.y *= -1;
			if (Math.random() > 0.9) zephGfx.scale.y *= 4;
		}

		super.update(elapsed);

		grpWeekText.forEach(function(spr:FlxSprite)
		{
			if(FlxG.mouse.overlaps(spr) && spr.ID == curWeek && FlxG.mouse.justPressed)
				selectWeek();
		});
		
		var offY:Float = grpWeekText.members[curWeek].targetY;
		for (num => item in grpWeekText.members)
			item.y = FlxMath.lerp(item.targetY - offY + 480, item.y, Math.exp(-elapsed * 10.2));

		for (num => lock in grpLocks.members)
			lock.y = grpWeekText.members[lock.ID].y + grpWeekText.members[lock.ID].height/2 - lock.height/2;
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if(curWeek == 1)
		{
			Sys.command('start assets/games/my_story/perec.exe');
		}
		else if(curWeek == 4 && FlxG.save.data.progressState == 5)
		{
			selectedWeek = true;

			if (stopspamming == false)
			{
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));
				staticTransition.alpha = 1;
		
				stopspamming = true;
			}
		
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new funkin.menus.void.VoidState());
			});
		}
		else
		{
			if (!weekIsLocked(loadedWeeks[curWeek].fileName))
			{
				// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
				var songArray:Array<String> = [];
				var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
				for (i in 0...leWeek.length) {
					songArray.push(leWeek[i][0]);
				}
		
				PlayState.firstSong = songArray[0];
		
				// Nevermind that's stupid lmao
				try
				{
					if (Progression.weekProgress.exists(loadedWeeks[curWeek].weekName))
					{
						persistentUpdate = false;
						openSubState(new StoryProgressSubState(
						function()
						{
							PlayState.totalStoryNotesHit = 0;
							PlayState.totalStoryPlayed = 0;
							PlayState.fullNotes = 0;
							PlayState.songFullHits = 0;

							PlayState.campaignSicks = 0;
							PlayState.campaignGoods = 0;
							PlayState.campaignBads = 0;
							PlayState.campaignShits = 0;
	
							PlayState.maxCombo = 0;

							PlayState.campaignAccuracy = 0;

							PlayState.campaignScore = 0;
							PlayState.campaignMisses = 0;
		
							PlayState.storyPlaylist = songArray;
						
							playWeek();
						}, 
		
						function()
						{
							var resumeInfo = Progression.weekProgress.get(loadedWeeks[curWeek].weekName);
						
							songArray = resumeInfo.song;

							PlayState.totalStoryNotesHit = resumeInfo.weekTotalHit;
							PlayState.totalStoryPlayed = resumeInfo.weekTotalPlay;
							PlayState.fullNotes = resumeInfo.weekTotalNo;
							PlayState.songFullHits = resumeInfo.songCampHits;

							PlayState.campaignSicks = resumeInfo.maxSicks;
							PlayState.campaignGoods = resumeInfo.maxGoods;
							PlayState.campaignBads = resumeInfo.maxBads;
							PlayState.campaignShits = resumeInfo.maxShits;
	
							PlayState.maxCombo = resumeInfo.maxComboLol;

							PlayState.campaignAccuracy = resumeInfo.weekAccu;
						
							PlayState.campaignMisses = resumeInfo.weekMisees;
							PlayState.campaignScore = resumeInfo.weekSocre;
				
							trace(songArray);
		
							PlayState.storyPlaylist = songArray;
						
							playWeek();
						}, 
		
							function()
							{
								return;
							}));
						}
					else
					{
						PlayState.totalStoryNotesHit = 0;
						PlayState.totalStoryPlayed = 0;
						PlayState.fullNotes = 0;
						PlayState.songFullHits = 0;

						PlayState.campaignSicks = 0;
						PlayState.campaignGoods = 0;
						PlayState.campaignBads = 0;
						PlayState.campaignShits = 0;
	
						PlayState.maxCombo = 0;

						PlayState.campaignAccuracy = 0;

						PlayState.campaignScore = 0;
						PlayState.campaignMisses = 0;
		
						PlayState.storyPlaylist = songArray;
						
						playWeek();
					}
				}
				catch(e:Dynamic)
				{
					trace('ERROR! $e');
					return;
				}
			}
			else FunkinSound.playOnce(Paths.sound('cancelMenu'));
		}
	}

	function playWeek()
	{
		PlayState.isFirstSongInCampaign = true;
		PlayState.isStoryMode = true;
		selectedWeek = true;

		FlxG.mouse.visible = false;

	
		var diffic = Difficulty.getFilePath(curDifficulty);
		if(diffic == null) diffic = '';
	
		PlayState.storyDifficulty = curDifficulty;
	
		Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());

		if (stopspamming == false)
		{
			FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));
			staticTransition.alpha = 1;
			//FlxTransitionableState.skipNextTransIn = true;
			//FlxTransitionableState.skipNextTransOut = true;

			stopspamming = true;
		}

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
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
			LoadingState.loadAndSwitchState(new PlayState(), true);
			funkin.menus.freeplay.FreeplayState.destroyFreeplayVocals();
		});
			
		#if (MODS_ALLOWED && DISCORD_ALLOWED)
		DiscordClient.loadModRPC();
		#end
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = Difficulty.getDiffString(curDifficulty, false);
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty, 0);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		if(curWeek == 1)
		{
			tracksSprite.visible = false;
			txtTracklist.visible = false;
			scoreText.visible = false;
		}
		else if(curWeek == 4 && FlxG.save.data.progressState == 5)
		{
			tracksSprite.visible = false;
			txtTracklist.visible = false;
			scoreText.visible = false;
		}
		else
		{
			tracksSprite.visible = true;
			txtTracklist.visible = true;
			scoreText.visible = true;
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = Language.getPhrase('storyname_${leWeek.fileName}', leWeek.storyName);
		txtWeekTitle.text = leName.toUpperCase();

		if(leWeek.fileName == 'weekexe' && !weekCompleted.exists('weekexe'))
			txtWeekTitle.text = 'Someone is waiting for you...?';

		if(leWeek.fileName == 'weekfinal' && !weekCompleted.exists('weekfinal'))
			txtWeekTitle.text = 'YzaiqOtGruuvRoqkGMujjgstzYrgbkCkIgtzIngtmkUaxykrlkyCkIgtzIngtmkUaxLgzkCkIgtzJuGteznotmHazIgtEUA';

		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + Math.max(10, FullScreenScaleMode.gameNotchSize.x)); // Right align.

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (num => item in grpWeekText.members)
		{
			item.alpha = 0.6;
			if (num - curWeek == 0 && unlocked)
				item.alpha = 1;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		bgSprite.screenCenter(X);
		PlayState.storyWeek = curWeek;

		Difficulty.loadFromWeek();

		if(Difficulty.list.contains(Difficulty.getDefaultDifficult()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefaultDifficult())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase(); 

		if(leWeek.fileName == 'weekexe' && !weekCompleted.exists('weekexe'))
			txtTracklist.text = '???\n???\n???';

		if(leWeek.fileName == 'weekfinal' && !weekCompleted.exists('weekfinal'))
			txtTracklist.text = '';

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty, 0);
		#end
	}
}
