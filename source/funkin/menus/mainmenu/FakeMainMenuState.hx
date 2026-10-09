package funkin.menus.mainmenu;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import funkin.debug.editors.MasterEditorMenu;
import funkin.menus.options.OptionsState;
import funkin.graphics.FunkinCamera;
import funkin.submenus.StoryProgressSubState;

import funkin.audio.FunkinSound;
class FakeMainMenuState extends MusicBeatState
{
	public static var goldFunkVersion:String = '1.0.2'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	//Centered/Text options
	var optionShit:Array<String> = [
		'start',
		'options',
		'credits'
	];

	var bg:FlxSprite;
	var tree:FlxSprite;
	var logoBl:FlxSprite;
	var camFollow:FlxObject;

	private var camGame:FunkinCamera;
	private var camHUD:FunkinCamera;
	override function create()
	{
		Conductor.bpm = 136;
		super.create();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = initPsychCamera('FakeMenuCam');
		camHUD = new FunkinCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = 0.15;
		bg = new FlxSprite().loadGraphic(Paths.image('fake_main_menu/bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll - 0.1);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		tree = new FlxSprite(-46, -58).loadGraphic(Paths.image('fake_main_menu/tree_bg'));
		tree.antialiasing = ClientPrefs.data.antialiasing;
		tree.scrollFactor.set(0, yScroll);
		tree.updateHitbox();
		add(tree);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var item0:FlxSprite = createMenuItem('start', 45, 28);
		var item1:FlxSprite = createMenuItem('options', 32, 250);
		var item2:FlxSprite = createMenuItem('credits', 35, 397);

		logoBl = new FlxSprite(650 + (FullScreenScaleMode.gameCutoutSize.x / 2.5), 0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.scrollFactor.set(0, 0);
		logoBl.scale.set(0.8, 0.8);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl); //FNF Logo

		var overlay:FlxSprite = new FlxSprite(-84, -81).loadGraphic(Paths.image('fake_main_menu/overlay'));
		overlay.antialiasing = ClientPrefs.data.antialiasing;
		overlay.updateHitbox();
		overlay.blend = OVERLAY;
		overlay.scrollFactor.set(0, yScroll);
		overlay.alpha = 0.5;
		add(overlay);

		var ver:FlxText = new FlxText(12, FlxG.height - 34, 0, "Brutal Pizdec V2", 24);
		ver.scrollFactor.set();
		ver.cameras = [camHUD];
		ver.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(ver);
		changeItem();

		FlxG.camera.follow(camFollow, null, 0.15);

		FlxG.camera.zoom = 1.1;

		WeekData.reloadWeekFiles(true);

		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			loadedWeeks.push(weekFile);
			WeekData.setDirectoryFromWeek(weekFile);	
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		Difficulty.resetList();

		var leWeek:WeekData = loadedWeeks[0];
		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		PlayState.storyWeek = 0;
		Difficulty.loadFromWeek();
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite(x, y);
		menuItem.frames = Paths.getSparrowAtlas('fake_main_menu/button_$name');
		menuItem.animation.addByPrefix('idle', 'buttom_'+name+'_default', 24, true);
		menuItem.animation.addByPrefix('selected', 'buttom_'+name+'_selected', 24, true);
		menuItem.animation.play('idle');
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.data.antialiasing;
		menuItem.scrollFactor.set(0, 0.15);
		menuItems.add(menuItem);
		return menuItem;
	}

	var selectedSomethin:Bool = false;
	var loadedWeeks:Array<WeekData> = [];
	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				FunkinSound.playOnce(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new funkin.menus.title.TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;

				var item:FlxSprite;
				var option:String;

				option = optionShit[curSelected];
				item = menuItems.members[curSelected];

				if(option == 'start')
				{
					camHUD.alpha = 0;
					// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
					var songArray:Array<String> = [];
					var leWeek:Array<Dynamic> = loadedWeeks[0].songs;
					for (i in 0...leWeek.length) {
						songArray.push(leWeek[i][0]);
					}

					PlayState.firstSong = songArray[0];

					// Nevermind that's stupid lmao
					try
					{
						PlayState.campaignScore = 0;
						PlayState.campaignMisses = 0;

						PlayState.storyPlaylist = songArray;
			
						playWeek();
					}
					catch(e:Dynamic)
					{
						trace('ERROR! $e');
						return;
					}
				}
				else
				{
					FunkinSound.playOnce(Paths.sound('bp_aah_sounds/confirmMenu'));
					FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						switch (option)
						{
							case 'credits':
								MusicBeatState.switchState(new funkin.menus.credits.CreditsState());
							case 'options':
								MusicBeatState.switchState(new funkin.menus.options.OptionsState());
								OptionsState.onPlayState = false;
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									PlayState.stageUI = 'normal';
								}
							default:
								trace('Menu Item ${option} doesn\'t do anything');
								selectedSomethin = false;
								item.visible = true;
						}
					});
						
					for (memb in menuItems)
					{
						if(memb == item)
							continue;
		
						FlxTween.tween(memb, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
					}
				}
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(ClientPrefs.data.camZooms)
			FlxTween.tween(FlxG.camera, {zoom:1.13}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
	}

	override function closeSubState() {
		persistentUpdate = true;
		selectedSomethin = false;
		super.closeSubState();
	}

	function changeItem(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
		FunkinSound.playOnce(Paths.sound('bp_aah_sounds/scrollMenu'));

		for (item in menuItems)
		{
			item.animation.play('idle');
			item.centerOffsets();
		}

		var selectedItem:FlxSprite;
		selectedItem = menuItems.members[curSelected];
		selectedItem.animation.play('selected');
		selectedItem.centerOffsets();
		camFollow.y = selectedItem.getGraphicMidpoint().y;
	}

	function playWeek()
	{
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
