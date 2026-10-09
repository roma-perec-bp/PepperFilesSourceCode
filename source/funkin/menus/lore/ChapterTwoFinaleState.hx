package funkin.menus.lore;

import funkin.menus.title.TitleState;
import funkin.submenus.StoryProgressSubState;

class ChapterTwoFinaleState extends MusicBeatState
{
	var canDo:Bool = false;
	var loadedWeeks:Array<WeekData> = [];
	override function create()
	{
		super.create();

		TitleState.initialized = true;
		FlxG.mouse.visible = false;
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.mouse.visible = false;
			
		WeekData.reloadWeekFiles(true);

		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			loadedWeeks.push(weekFile);
			WeekData.setDirectoryFromWeek(weekFile);	
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[4]);
		Difficulty.resetList();

		var leWeek:WeekData = loadedWeeks[4];
		WeekData.setDirectoryFromWeek(loadedWeeks[4]);
		PlayState.storyWeek = 4;
		Difficulty.loadFromWeek();

		// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
		var songArray:Array<String> = [];
		var leWeek:Array<Dynamic> = loadedWeeks[4].songs;
		for (i in 0...leWeek.length) {
			songArray.push(leWeek[i][0]);
		}
		PlayState.firstSong = songArray[0];
		MusicBeatState.changeCursor(true);
		// Nevermind that's stupid lmao
		try
		{
			if (Progression.weekProgress.exists(loadedWeeks[4].weekName))
			{
				persistentUpdate = false;
				WindowUtil.setTitle("...");
				openSubState(new StoryProgressSubState(
				function()
				{
					PlayState.campaignScore = 0;
					PlayState.campaignMisses = 0;

					PlayState.storyPlaylist = songArray;
				
					playWeek();
				}, 

				function()
				{
					var resumeInfo = Progression.weekProgress.get(loadedWeeks[4].weekName);
				
					songArray = resumeInfo.song;
				
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
				WindowUtil.setTitle("...");
				new FlxTimer().start(6, function(tmr:FlxTimer)
				{
					PlayState.campaignScore = 0;
					PlayState.campaignMisses = 0;

					PlayState.storyPlaylist = songArray;
				
					playWeek();
				});
			}
		}
	}

	function playWeek()
	{
		FlxG.mouse.visible = false;

		PlayState.isFirstSongInCampaign = true;
		PlayState.isStoryMode = true;
	
		var diffic = Difficulty.getFilePath(1);
		if(diffic == null) diffic = '';
	
		PlayState.storyDifficulty = 0;
	
		Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());

		FlxG.sound.music.volume = 0;
		FlxG.camera.fade(FlxColor.BLACK, 0.0001, false, null, true);

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
			LoadingState.loadAndSwitchState(new PlayState(), true, false);
			funkin.menus.freeplay.FreeplayState.destroyFreeplayVocals();
		});
			
		#if (MODS_ALLOWED && DISCORD_ALLOWED)
		DiscordClient.loadModRPC();
		#end
	}

	public static function getSave():Bool
	{
		FlxG.mouse.visible = false;
		MusicBeatState.changeCursor(false);
		
		var path = Sys.getEnv("userprofile") + '\\AppData\\Roaming\\Godot\\app_userdata\\PEREC.HUI\\unlock.dat';
		return FileSystem.exists(path);
	}
}