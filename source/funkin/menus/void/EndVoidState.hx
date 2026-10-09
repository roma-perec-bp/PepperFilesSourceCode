package funkin.menus.void;

import funkin.graphics.shaders.DaveAndBambiGlitchShader;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;

import flixel.util.FlxSave;

import funkin.menus.storymenu.StoryMenuState;

import flixel.addons.text.FlxTypeText;

import funkin.audio.FunkinSound;

import funkin.objects.VideoSprite;

class EndVoidState extends MusicBeatState
{
	public var videoCutscene:VideoSprite = null;
	var pep:FlxSprite;

	var curPath:String;
	var curDial:String;

	var loadedWeeks:Array<WeekData> = [];

	var dialogueList:Array<String> = [];

	var talkVoice:Null<FunkinSound> = null;

	var curDialogue:Int = 0;

	var swagDialogue:FlxTypeText;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	var songArray:Array<String> = [];
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		super.create();
		FlxTransitionableState.skipNextTransOut = true; //skip the original transition fade


		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("...", null);
		#end

		WindowUtil.setTitle("...");

		pep = new FlxSprite();
		pep.frames = Paths.getSparrowAtlas('void/pep_stay');
		pep.animation.addByPrefix('back', 'back', 24, true);
		pep.animation.addByPrefix('front', 'front', 24, true);
		pep.animation.play('back');

		pep.centerOffsets();
		pep.antialiasing = ClientPrefs.data.antialiasing;
		pep.updateHitbox();

		pep.screenCenter();
		add(pep);

		swagDialogue = new FlxTypeText(0, 650, Std.int(FlxG.width * 0.85), "", 24);
		swagDialogue.font = Paths.font("vcr.ttf");
		swagDialogue.alignment = CENTER;
		swagDialogue.color = 0xFFFFFFFF;
		swagDialogue.screenCenter(X);
		//swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.4)];
		add(swagDialogue);

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
		var leWeek:Array<Dynamic> = loadedWeeks[4].songs;
		for (i in 0...leWeek.length) {
			songArray.push(leWeek[i][0]);
		}
		PlayState.firstSong = songArray[0];

		var foundFile:Bool = false;
		var fileName:String = Paths.video('alive');

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			videoCutscene = new VideoSprite(fileName, false, false, false);

			function onVideoEnd()
			{
				FlxG.camera.flash(FlxColor.WHITE, 3, true);

				FlxG.save.data.progressState = 6;
				FlxG.save.flush();

				new FlxTimer().start(3, function(timer:FlxTimer)
				{
					FlxG.sound.playMusic(Paths.music('void/post-script'), 0);
					FlxG.sound.music.fadeIn(3, 0, 0.6);
					FlxG.sound.music.pitch = 0.8;
					initDialog('end', 'end_state');
				});
			}

			videoCutscene.finishCallback = onVideoEnd;
			videoCutscene.onSkip = onVideoEnd;

            add(videoCutscene);

            videoCutscene.play();
		}
	}

	var chooseb:Bool = false;
	var songTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			if(dialogueOpened)
			{
				if(dialogueEnded)
				{
					if (dialogueList[1] == null && dialogueList[0] != null)
					{
						swagDialogue.alpha = 0;
						if(talkVoice != null) talkVoice.stop();

						dialogueOpened = false;
						dialogueStarted = false;
					}
					else
					{
						dialogueList.remove(dialogueList[0]);
						startDialogue();
					}
				}
				else if (dialogueStarted)
				{
					swagDialogue.skip();
				}
			}

		}

		super.update(elapsed);
	}

	function startDialogue():Void
	{
		swagDialogue.alpha = 1;
		swagDialogue.resetText(dialogueList[0]);

		if (talkVoice != null) talkVoice.stop();

		talkVoice = FunkinSound.load(Paths.sound('void_pep/'+curPath+'/'+curDial+'/'+curDialogue), 0.8, false, false, true);

		if(curDialogue == 3)
		{
			pep.animation.play('front');
			pep.centerOffsets();
			pep.screenCenter();
		}

		if(curDialogue == 19)
		{
			dialogueOpened = false;

			new FlxTimer().start(0.8, function(timer:FlxTimer)
			{
				swagDialogue.visible = false;
				pep.visible = false;
				talkVoice.stop();
				FlxG.sound.music.stop();

				new FlxTimer().start(3, function(timer:FlxTimer)
				{
					FunkinSound.playOnce(Paths.sound('hui_final/speech_first'));
            		new FlxTimer().start(6, function(tmr:FlxTimer)
            		{
						PlayState.campaignScore = 0;
						PlayState.campaignMisses = 0;
	
						PlayState.storyPlaylist = songArray;

						generateTextFile('Такс... Он что то очень медлит...\nТы разбирайся пока с ним\nЯ скоро приду\n\n\n\n\n                 -Таинственный незнакомец', 'Сообщение_для_тебя');
					
						playWeek();
            		});
				});
			});
		}

		curDialogue++;

		swagDialogue.start(0.05, true);
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		};
	
		dialogueEnded = false;
	}

	function initDialog(dialogue:String, path:String):Void
	{
		curDialogue = 0;
		dialogueList = [];

		var file:String = Paths.txt('void_text/'+path+'/'+dialogue); //Checks for vanilla/Senpai dialogue
		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			file = Paths.txt('void_text/'+path+'/'+dialogue);
		}

		curPath = path;
		curDial = dialogue;

		dialogueList = CoolUtil.coolTextFile(file);

		dialogueOpened = true;
		dialogueStarted = true;

		startDialogue();
	}

	override public function onFocus():Void
	{
		super.onFocus();
		if(talkVoice != null) talkVoice.resume();
	}

	override public function onFocusLost():Void
	{
		super.onFocusLost();
		if(talkVoice != null) talkVoice.pause();
	}

	public static function generateTextFile(fileContent:String, fileName:String)
	{
		#if desktop
		var path = getTempPath() + "/" + fileName + ".txt";

		File.saveContent(path, fileContent);
		#if windows
		Sys.command("start " + path);
		#elseif linux
		Sys.command("xdg-open " + path);
		#else
		Sys.command("open " + path);
		#end
		
		#end
	}

	public static function getTempPath():String
	{
		// gets appdata temp folder lol
		#if windows
		return Sys.getEnv("TEMP");
		#else
		// most non-windows os dont have a temp path, or if they do its not 100% compatible, so the user folder will be a fallback
		return Sys.getEnv("HOME");
		#end
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
}