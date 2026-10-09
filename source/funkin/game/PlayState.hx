package funkin.game;

import funkin.debug.editors.StageEditorState;
import funkin.debug.editors.ChartingState;
import funkin.debug.editors.CharacterEditorState;

import lime.app.Application;
import lime.graphics.Image;

import haxe.io.Path;
import lime.app.Application;

import haxe.Int64;

import sys.io.Process;

import funkin.audio.FunkinSound;

import funkin.data.*;
import funkin.data.StageData;

import funkin.graphics.FunkinSprite;

import funkin.game.notes.*;
import funkin.game.notes.Note;
import funkin.game.cutscenes.DialogueBoxPsych;
import funkin.game.cutscenes.*;
import funkin.game.objects.*;

import funkin.objects.Bar;
import funkin.objects.AttachedSprite;

import haxe.ds.ObjectMap;

import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;

import flixel.ui.FlxBar;

import funkin.menus.FullScreenScaleMode;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import haxe.Json;

import funkin.graphics.FunkinCamera;

import funkin.menus.storymenu.StoryMenuState;
import funkin.menus.freeplay.FreeplayState;

import funkin.submenus.pause.*;
import funkin.submenus.ResultSubState;
import funkin.submenus.gameover.GameOverSubstate;

#if !flash
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import funkin.graphics.shaders.Shaders; //idk why but that worked
import funkin.graphics.shaders.*;
import flixel.addons.display.FlxRuntimeShader;
#end

import funkin.graphics.shaders.ErrorHandledShader;

import funkin.objects.VideoSprite;

import funkin.game.stages.*;
import funkin.game.stages.objects.*;
import funkin.game.stages.game_stages.*;

#if LUA_ALLOWED
import funkin.psychlua.*;
#else
import funkin.psychlua.LuaUtils;
import funkin.psychlua.HScript;
#end

#if HSCRIPT_ALLOWED
import funkin.psychlua.HScript.HScriptInfos;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end

using funkin.utils.tools.IteratorTools;

/**
 * This is where all the Gameplay stuff happens and is managed
 *
 * here's some useful tips if you are making a mod in source:
 *
 * If you want to add your stage to the game, copy states/stages/Template.hx,
 * and put your stage code there, then, on PlayState, search for
 * "switch (curStage)", and add your stage to that list.
 *
 * If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
 *
 * "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
 * "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
 * "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
 * "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for
**/
class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var secondMap:Map<String, Character> = new Map<String, Character>();

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	var canLoop = false;
	var start = true;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeedTweenOpponent:FlxTween;
	public var songLengthTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedOpponent(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 600;
	public var missOffset:Float = 350;
	public var noteKillOffsetOppo:Float = 600;
	public var missOffsetOppo:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var secondGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var stageUI(default, set):String = "normal";
	public static var uiPrefix:String = "";
	public static var uiPostfix:String = "";
	public static var isPixelStage(get, never):Bool;

	@:noCompletion
	static function set_stageUI(value:String):String
	{
		uiPrefix = uiPostfix = "";
		if (value != "normal")
		{
			uiPrefix = value.split("-pixel")[0].trim();
			if (value == "pixel" || value.endsWith("-pixel")) uiPostfix = "-pixel";
		}
		return stageUI = value;
	}

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel" || stageUI.endsWith("-pixel");

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var variation:Int = 1;
	public static var firstSong:String = "";

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;
	public var second:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	public var cameraFollowPoint:FlxObject = new FlxObject();
    var noteCamOffset:Float = 30;

	public var curFocusedChar:String;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dchar:Array<String>;
	
	var cameraFollowTween:FlxTween;
	var cameraZoomTween:FlxTween;
	var cameraHudZoomTween:FlxTween;
	var cameraNotesZoomTween:FlxTween;

	public var requiredZoom:Float = FlxCamera.defaultZoom;

	public var currentCameraZoom:Float = 1.0;
	var cameraBopMultiplier:Float = 1.0;

	var defaultHUDCameraZoom:Float = 1.0;
	var camHudBopMult:Float = 1.0;

	var defaultNotesCameraZoom:Float = 0.95;
	var camNotesBopMult:Float = 1.0;

	var canUpdate:Bool = true;

	public var camZoomingDecay:Float = 1;
	public var camZoomingDecayHud:Float = 1;

	var cameraBopIntensity:Float = 1.015;
	var hudCameraZoomIntensity:Float = 0.015 * 2.0;
	var cameraZoomRate:Int = 4;

	public var strumLineNotes:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var opponentStrums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var playerStrums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var grpHoldSplashes:FlxTypedGroup<SustainSplash> = new FlxTypedGroup<SustainSplash>();
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash> = new FlxTypedGroup<NoteSplash>();

	private var curSong:String = "";

	var offsetX:Float = 650; // How far to the right of the player you want the combo to appear
	var offsetY:Float = 300; // How far above the player you want the combo to appear
	var playerX:Float;
	var playerY:Float;

	private var opponentHealthDrain:Bool = false;
	private var opponentHealthDrainAmount:Float = 0.023;
	private var singingShakeArray:Array<Bool> = [false, false];

	public var shakeBeat = false;
	public var shakeDec:Int = 1;

	public var goHealthDamageBeat:Bool = false;
	public var beatHealthDrain:Float = 0.023; //mb can be good???
	public var beatHealthStep:Int = 4;

	public var gfSpeed:Int = 1;

	public var health(default, set):Float = 1;
	private var lerpHealth:Float = 1;

	public var combo:Int = 0;
	public var comboGot:Int = 0;
	public var startCombo:Int = 10;
	public static var maxCombo:Int = 0;
	public var comboIsInCamGame:Bool = false;

	var missNoteSound:Null<FunkinSound> = null;
	var darnellVoice:Null<FunkinSound> = null;

	public var shaderUpdates:Array<Float->Void> = [];

	//TOO FIRE GONE
	var lagJack:Bool = false;

	//omg
	public var camGameShaders:Array<Dynamic> = [];
	public var camHUDShaders:Array<Dynamic> = [];
	public var camNotesShaders:Array<Dynamic> = [];
	public var camHudOverlayShaders:Array<Dynamic> = [];
	public var camOtherShaders:Array<Dynamic> = [];

	public var healthBar:Bar;
	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;
	var songPercent:Float = 0;

	public var healthBarBGOverlay:FlxSprite;
	public var timeBarBGOverlay:FlxSprite;

	private var fireHalapeno:FlxSprite;
	private var fireFlash:FunkinSprite;

	public var ratingsData:Array<Rating> = Rating.loadDefault();
	var currentTimingShown:FlxText;

	public static var isFirstSongInCampaign:Bool = true;
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	public var frozenCharacters:ObjectMap<Character, Bool> = new ObjectMap();

	var cacheBF:String;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;

	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;
	public var pressMissDamage:Float = 0.05;

	public var fadeNoteMod:Bool = false;
	public var onlySick:Bool = false;
	public var opponentMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camVideoMid:FunkinCamera; //does same as camHUD but for video mostly or other stuff
	public var camPreHUD:FunkinCamera; //does same as camHUD but for video mostly or other stuff
	public var camCinematic:FunkinCamera; //yeah idk
	public var camHUD:FunkinCamera;
	public var camOverlayHUD:FunkinCamera; //does same as camHUD but above notes ye
	public var camGame:FunkinCamera;
	public var camNotes:FunkinCamera;
	public var camOther:FunkinCamera;
	public var camOtherAlt:FunkinCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Float = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var rank:Int = 5;
	public var levelRank:Int = 5;

	public static var songFullHits:Int = 0;

	public var scoreTxt:FlxText;
	public var scoreTxt_BP:FlxText;
	public var subtitlesTxt:FlxText;
	var timeTxt:FlxText;

	var trailBf:FlxTrail;
	var trailDad:FlxTrail;
	var trailGf:FlxTrail;

	var topBar:FunkinSprite;
	var bottomBar:FunkinSprite;

	var ratingTxt:FlxText;
	var accuracyShit:FlxText;

	var comboTxt:FlxText;

	var scoreTxtTween:FlxTween;
	var subtitlesTxtTween:FlxTween;
	var prevTxt:String;
	var prevFont:String;
	var subTimer:FlxTimer;

	// Медальки
	public var medal:FlxSprite;
	public var medal_system:Array<Dynamic> = [
		[99.9, 100.0, 'Master'],
		[95.0, 99.8, 'Super Elite'],
		[75.0, 94.9, 'Elite'],
		[74.9, 50.0, 'Advanced'],
		[38.0, 49.9, 'Specialist'],
		[0.0, 37.9, 'Skill issue']
	];
	public var medalStatus:Int = 5;
	public var medalOldStatus:Int = 5;

	var solidColBeh:FunkinSprite;

	public var textYou:FlxText;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignAccuracy:Float = 0;

	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	private var taskDefault:SongIntroDefault;

	var curVideoTimestamp:Float;
	var playingVideo:Bool = false;
	var curVideoName:String = '';

	//LANES
	var laneP0:FunkinSprite;
	var laneP1:FunkinSprite;
	var laneP2:FunkinSprite;
	var laneP3:FunkinSprite;

	var laneE0:FunkinSprite;
	var laneE1:FunkinSprite;
	var laneE2:FunkinSprite;
	var laneE3:FunkinSprite;

	//skip values
	public var skipTime:Float = 0;
	public var canSkip:Bool = false;
	var skipText:FlxText;

	public var stageZoom:Float = 1.05;

	var controlledPlayer:Character;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if DISCORD_ALLOWED
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Int> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	#if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<funkin.psychlua.DebugLuaText>;
	#end
	public var introSoundsSuffix:String = '';

	// Cache of last values pushed to scripts every frame so that we don't pay
	// for an O(scripts) reflective set when the value hasn't actually changed.
	private var _lastSentDecStep:Float = Math.NEGATIVE_INFINITY;
	private var _lastSentDecBeat:Float = Math.NEGATIVE_INFINITY;

	// Less laggy controls
	private var keysArray:Array<String>;

	// Reverse-lookup of FlxKey -> strum index, rebuilt once per song from
	// keysArray + Controls.instance.keyboardBinds. getKeyFromEvent walks two
	// nested loops on every key event; this collapses it to a single Map.get.
	private var _keyToStrum:Map<FlxKey, Int> = null;

	public var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	private static var _lastLoadedModDirectory:String = '';
	public static var nextReloadAll:Bool = false;

	var preloadedVideoAtLeastOnce:Bool = false;
	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		_lastLoadedModDirectory = Mods.currentModDirectory;
		Paths.clearStoredMemory();
		if(nextReloadAll)
		{
			Paths.clearUnusedMemory();
			Language.reloadPhrases();
		}
		nextReloadAll = false;

		startCallback = startCountdown;
		endCallback = endSong;

		if(FlxG.save.data.progressState == 2) endCallback = huiEnd;

		if(!FlxG.save.data.introduction) endCallback = introEnd;

		// for lua
		instance = this;

		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed');

		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		rebuildKeyToStrumMap();

		// Reset Note's per-song hitsound dedupe set so the next song
		// re-precaches its own custom hitsounds (and we don't hold
		// references to last song's that might have been freed).
		Note.precachedHitsounds = new Map();

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = isStoryMode ? 1 : ClientPrefs.getGameplaySetting('healthgain');
		healthLoss = isStoryMode ? 1 : ClientPrefs.getGameplaySetting('healthloss');
		instakillOnMiss = isStoryMode ? false : ClientPrefs.getGameplaySetting('instakill');
		practiceMode = isStoryMode ? false : ClientPrefs.getGameplaySetting('practice');
		cpuControlled = isStoryMode ? false : ClientPrefs.getGameplaySetting('botplay');

		fadeNoteMod = isStoryMode ? false : ClientPrefs.getGameplaySetting('fade');
		onlySick = isStoryMode ? false : ClientPrefs.getGameplaySetting('sickmode');
		opponentMode = isStoryMode ? false : ClientPrefs.getGameplaySetting('opponentplay');

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = initPsychCamera('PlayStateCamera');
		camVideoMid = new FunkinCamera('PlayStateCameraVideo');
		camPreHUD = new FunkinCamera('PlayStateCameraPreHud');
		camCinematic = new FunkinCamera('PlayStateCameraCinematic');
		camHUD = new FunkinCamera('PlayStateCameraHud');
		camNotes = new FunkinCamera('PlayStateCameraNotes');
		camOverlayHUD = new FunkinCamera('PlayStateCameraHudOverlay');
		camOther = new FunkinCamera('PlayStateCameraOther');
		camOtherAlt = new FunkinCamera('PlayStateCameraOtherAlt');
		camVideoMid.bgColor.alpha = 0;
		camPreHUD.bgColor.alpha = 0;
		camCinematic.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camOverlayHUD.bgColor.alpha = 0;
		camNotes.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camOtherAlt.bgColor.alpha = 0;

		FlxG.cameras.add(camVideoMid, false);
		FlxG.cameras.add(camPreHUD, false);
		FlxG.cameras.add(camCinematic, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camNotes, false);
		FlxG.cameras.add(camOverlayHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.add(camOtherAlt, false);

		camVideoMid.zoom = defaultNotesCameraZoom;
		camPreHUD.zoom = 1;
		camCinematic.zoom = 1;
		camHUD.zoom = defaultNotesCameraZoom;
		camNotes.zoom = defaultNotesCameraZoom;

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		noteCamOffset = SONG.followCamOffset;

		#if DISCORD_ALLOWED
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		storyDifficultyText = Difficulty.getDiffString();

		if (isStoryMode)
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		topBar = new FunkinSprite(0, 0).makeSolidColor(FlxG.width, 100, FlxColor.BLACK);
		bottomBar = new FunkinSprite(0, 620).makeSolidColor(FlxG.width, 100, FlxColor.BLACK);

		GameOverSubstate.resetVariables();
		songName = Paths.formatToSongPath(SONG.song);
		if(SONG.stage == null || SONG.stage.length < 1)
			SONG.stage = StageData.vanillaSongStage(Paths.formatToSongPath(Song.loadedSongName));

		curStage = SONG.stage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		stageZoom = stageData.defaultZoom;

		stageUI = "normal";
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			stageUI = stageData.stageUI;
		else if (stageData.isPixelStage == true) //Backward compatibility
			stageUI = "pixel";

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		if(stageData.girlfriend != null)
		{
			GF_X = stageData.girlfriend[0];
			GF_Y = stageData.girlfriend[1];
		}
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		cameraSpeed += SONG.cameraSpeedMult;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		//boyfriendGroup.zIndex = 300;
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		//dadGroup.zIndex = 200;
		if(curStage == 'follow')
		{
			secondGroup = new FlxSpriteGroup(DAD_X - 250, DAD_Y + 50);
		}
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
		//gfGroup.zIndex = 100;

		if(!ClientPrefs.data.optimize)
		{
			switch (curStage)
			{
				case 'stage': new StageWeek1(); 			//Week 1
				case 'night': new Roof(); 				//Week P 2

				case 'rooffake' | 'desolate_space' | 'the end':
					add(topBar);
					add(bottomBar);

					topBar.cameras = [camCinematic];
					bottomBar.cameras = [camCinematic];

				case 'follow': 
					new StageFollowed(); 	//Week Finale
					add(topBar);
					add(bottomBar);

					topBar.cameras = [camCinematic];
					bottomBar.cameras = [camCinematic];

					topBar.y -= 100;
					bottomBar.y += 100;

				case 'cosmic':
					new StageCosmic(); 	//Week Finale
					add(topBar);
					add(bottomBar);

					topBar.cameras = [camCinematic];
					bottomBar.cameras = [camCinematic];

				case 'final':
					new StageFinal(); 	//Week Finale
					add(topBar);
					add(bottomBar);

					topBar.cameras = [camCinematic];
					bottomBar.cameras = [camCinematic];
			}
		}
		if(isPixelStage) introSoundsSuffix = '-pixel';

		if(SONG.countdownSuffix != null) introSoundsSuffix += SONG.countdownSuffix;

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		luaDebugGroup = new FlxTypedGroup<funkin.psychlua.DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		/*if (!stageData.hide_girlfriend)
		{
			if(SONG.gfVersion == null || SONG.gfVersion.length < 1) SONG.gfVersion = 'gf'; //Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			if(stageData.scrollFactor_girlfriend == null)
				gfGroup.scrollFactor.set(0.95, 0.95);
			else
				gfGroup.scrollFactor.set(stageData.scrollFactor_girlfriend[0], stageData.scrollFactor_girlfriend[1]);
			gfGroup.add(gf);
		}*/

		/*dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		if(stageData.scrollFactor_opponent == null) 
			dadGroup.scrollFactor.set(1, 1);
		else
			dadGroup.scrollFactor.set(stageData.scrollFactor_opponent[0], stageData.scrollFactor_opponent[1]);
		dadGroup.add(dad);*/

		var bfToChange:String = SONG.player1;
		var gfToChange:String = SONG.gfVersion;

		if(isStoryMode || opponentMode || Main.raldman || Main.darnellMode)
		{
			cacheBF = ClientPrefs.data.activeBfSkin;
			ClientPrefs.data.activeBfSkin = 'default';
		}

		switch(ClientPrefs.data.activeBfSkin)
		{
			case 'classic':
				switch(SONG.player1)
				{
					case 'bfnew' | 'coolassbf' | 'bf-zero' | 'bf-redrawn':
						bfToChange = 'bf';

					case 'bfASsad':
						bfToChange = 'bf-angry';

					case 'bf-pixel':
						bfToChange = 'bf-pixel-classic';
				}

			case 'mm':
				switch(SONG.player1)
				{
					case 'bf' | 'coolassbf' | 'bf-zero' | 'bf-redrawn' | 'bfASsad':
						bfToChange = 'bfnew';
	
					case 'P3-bf':
						bfToChange = 'bf-back';
	
					case 'P3-bf-flip':
						bfToChange = 'bf-back-flip';
	
					case 'bf-running':
						bfToChange = 'bf_demise';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-promo';
				}

			case 'sonic-legacy':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'bfASsad':
						bfToChange = 'coolassbf';
				}

			case 'indie-cross':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
						bfToChange = 'bf-ic';
				}

			case 'zero':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'coolassbf' | 'bf-redrawn' | 'bfASsad':
						bfToChange = 'bf-zero';
				}

			case 'basement':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
						bfToChange = 'bf-basement';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-basement';
				}

			case 'romstyle':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
						bfToChange = 'rom-bf';
				}

			case 'spaghetti':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'coolassbf' | 'bfASsad':
						bfToChange = 'bf-redrawn';

					case 'P3-bf':
						bfToChange = '1hbf';
	
					case 'P3-bf-flip':
						bfToChange = '1hbf-flip';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-spaghetti';
				}

			case 'downtown':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
						bfToChange = 'bf-osm';
				}

			case 'legacy':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
						bfToChange = 'bf-legacy';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-legacy';
				}

			case 'minus1':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
						bfToChange = 'bf-minus';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-minus';
				}

			case 'minus2':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
						bfToChange = 'bf-minus-beta';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-minus';
				}

			case 'minus3':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
						bfToChange = 'bf-minus-prototype';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-minus';
				}

			case 'badtime':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf':
						bfToChange = 'bf-badtime';

					case 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
						bfToChange = 'bf-badtime-scared';

					case 'P3-bf':
						bfToChange = 'bf-badtime-back';
	
					case 'P3-bf-flip':
						bfToChange = 'bf-badtime-back-flip';

					case 'bf-running':
						bfToChange = 'bf-badtime-run';

					case 'bf-pixel':
						bfToChange = 'bf-badtime-pixel';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						if(FlxG.random.bool(50))
							gfToChange = 'gf-badtime';
						else
							gfToChange = 'gf-badtime-alt';
				}

			case 'ourple':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
						bfToChange = 'bf_ourple';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf_ourple';
				}

			case 'pixel':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running':
						bfToChange = 'bf-pixel';

					case 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
						bfToChange = 'bf-pixel-pissed';

					case 'P3-bf':
						bfToChange = 'P3-bf-pixel';
	
					case 'P3-bf-flip':
						bfToChange = 'P3-bf-flip-pixel';

					case 'bf-pixel':
						bfToChange = 'bf-pixel-classic';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-pixel';
				}

			case 'encore':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
						bfToChange = 'bf-encore';

					case 'bf-pixel':
						bfToChange = 'bf-pixel-sonic';
				}

			case 'romfriend':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
						bfToChange = 'rf';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'umbra-gf';
				}

			case 'gold':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
						bfToChange = 'bf-golden';
				}

			case 'bp':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
						bfToChange = 'bp';
				}

			case 'bad':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
						bfToChange = 'bf-bad';

					case 'bf-pixel':
						bfToChange = 'bf-bad-pixel';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-bad';
				}

			case 'bp-dlc':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
						bfToChange = 'bf-3d';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-3d';
				}

			case 'ruby':
				switch(SONG.player1)
				{
					case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
						bfToChange = 'ruby-bf';
				}

				switch(SONG.gfVersion)
				{
					case 'gf':
						gfToChange = 'gf-ruby';
				}
		}

		if(Main.darnellMode && !opponentMode)
			bfToChange = 'darnell';

		if(Main.raldman && !opponentMode)
			bfToChange = 'raldeblan';

		if (!stageData.hide_girlfriend)
		{
			SONG.gfVersion = gfToChange;
			if (SONG.gfVersion == null || SONG.gfVersion.trim().length == 0) SONG.gfVersion = 'gf';
			gf = addCharacterToList(SONG.gfVersion, 2, false);
		}

		if(ClientPrefs.data.activeBfSkin == 'legacy' && curStage == 'night')
		{
			SONG.player2 = 'perec-legacy';
		}

		dad = addCharacterToList(SONG.player2, 1, false);
		if(curStage == 'follow') second = addCharacterToList('noGfLmao', 3, false);

		SONG.player1 = bfToChange;

		boyfriend = addCharacterToList(SONG.player1, 0, false);

		/*boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		if(stageData.scrollFactor_opponent == null) 
			boyfriendGroup.scrollFactor.set(1, 1);
		else
			boyfriendGroup.scrollFactor.set(stageData.scrollFactor_boyfriend[0], stageData.scrollFactor_boyfriend[1]);

		boyfriendGroup.add(boyfriend);*/
		
		if(stageData.objects != null && stageData.objects.length > 0)
		{
			if(!ClientPrefs.data.optimize)
			{
				var list:Map<String, FlxSprite> = StageData.addObjectsToState(stageData.objects, !stageData.hide_girlfriend ? gfGroup : null, dadGroup, boyfriendGroup, this);
				for (key => spr in list)
					if(!StageData.reservedNames.contains(key))
						variables.set(key, spr);
			}
		}
		else
		{
			add(gfGroup);
			add(dadGroup);
			if(curStage == 'follow') add(secondGroup);
			add(boyfriendGroup);
		}

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		// "SCRIPTS FOLDER" SCRIPTS
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		if(!ClientPrefs.data.optimize)
		{
			if(dad.curCharacter.startsWith('gf')) {
				dad.setPosition(GF_X, GF_Y);
				if(gf != null)
					gf.visible = false;
			}
		}

		resetCamera();

		if(!ClientPrefs.data.optimize)
		{
			#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
			// STAGE SCRIPTS
			#if LUA_ALLOWED startLuasNamed('stages/' + curStage + '.lua'); #end
			#if HSCRIPT_ALLOWED startHScriptsNamed('stages/' + curStage + '.hx'); #end
		}

		// CHARACTER SCRIPTS
		if(gf != null) startCharacterScripts(gf.curCharacter);
		startCharacterScripts(dad.curCharacter);
		startCharacterScripts(boyfriend.curCharacter);
		#end

		if(ClientPrefs.data.optimize)
		{
			boyfriendGroup.alpha = 0.00001;
			dadGroup.alpha = 0.00001;
			if(curStage == 'follow') secondGroup.alpha = 0.00001;
			gfGroup.alpha = 0.00001;
		}

		uiGroup = new FlxSpriteGroup();
		comboGroup = new FlxSpriteGroup();
		noteGroup = new FlxTypedGroup<FlxBasic>();
		uiPostGroup = new FlxSpriteGroup();
		countGroup = new FlxSpriteGroup();
		add(comboGroup);
		add(uiGroup);
		add(noteGroup);
		add(uiPostGroup);
		
		add(countGroup);

		createLanes();

		if (stageUI == 'bp')
		{
			timeBarBGOverlay = new FlxSprite(0, 0);
			timeBarBGOverlay.loadGraphic(Paths.image('timeBarOverlay', 'shared'));

			timeBarBGOverlay.alpha = 0;
			timeBarBGOverlay.antialiasing = false;

			if (bottomBar != null) bottomBar.visible = false;
			if (topBar != null) topBar.visible = false;
		}

		Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
		var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled' && !PlayState.SONG.disableTimeBar);
		timeTxt = new FlxText(42 + (FlxG.width / 2) - 248, 20, 400, "", 20);
		timeTxt.setFormat(Paths.font(stageUI == 'bp' ? 'HouseofTerror.ttf' : 'DS-DIGIB.ttf'), stageUI == 'bp' ? 32 : 36,  stageUI == 'bp' ? FlxColor.WHITE : FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE_FAST, stageUI == 'bp' ? FlxColor.BLACK : FlxColor.RED);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 1;
		timeTxt.visible = updateTime;
		if(ClientPrefs.data.downScroll) timeTxt.y = FlxG.height - 44;
		if(ClientPrefs.data.timeBarType == 'Song Name') timeTxt.text = SONG.song;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.screenCenter(X);
		timeBarBG.y = timeTxt.y + (timeTxt.height / 7);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;

		if(showTime) 
		{
			if (stageUI == 'bp') uiGroup.add(timeBarBGOverlay);
			uiGroup.add(timeBarBG);
			uiGroup.add(timeBar);
			uiGroup.add(timeTxt);
		}
		
		timeBarBG.sprTracker = timeBar;
		if(stageUI == 'bp') 
			timeTxt.y -= 6;
		else
			timeTxt.y -= 4;

		if(ClientPrefs.data.showMsTiming)
		{
			currentTimingShown = new FlxText(0, 0, 100, "0ms").setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			currentTimingShown.alpha = 0.0001;
			currentTimingShown.scrollFactor.set();
			noteGroup.add(currentTimingShown);
		}

		noteGroup.add(strumLineNotes);

		if(ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		generateSong();

		var now:Date = Date.now();

		if(isStoryMode && FlxG.save.data.progressState == 6)
		{
			switch (songName)
			{
				case 'last-stand':
					endCallback = lastEnd;
	
				case 'hell-valley':
					endCallback = function()
					{
						endingSong = true;
						inCutscene = true;
						canPause = false;
						FlxG.camera.visible = false;
						camHUD.visible = false;
						camPreHUD.visible = false;
						camOverlayHUD.visible = false;
						camNotes.visible = false;
						startVideo('valley-post-cutscene', false, false);
					};
			}
		}

		if(isStoryMode && !seenCutscene)
		{
			switch (songName)
			{	
				case 'too-fire':
					textIndex = 'dialogue';
					FlxG.sound.playMusic(Paths.music('dialogue_mus/last_piano'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.8);
					startCallback = schoolIntro;

				case 'you-cant-fire':
					if (now.getFullYear() <= 2023)
						textIndex = 'dialogue-ycr-early';
					else if (now.getFullYear() == 2023)
						textIndex = 'dialogue-ycr-2023';
					else
						textIndex = 'dialogue-ycr-normal';

					startCallback = schoolIntro;

				case 'doomsday':
					textIndex = 'dialogue';
					startCallback = schoolIntro;

					if(FlxG.save.data.progressState == 4)
					{
						endCallback = function()
						{
							endingSong = true;
							inCutscene = true;
							canPause = false;
							FlxTransitionableState.skipNextTransIn = true;
							FlxG.camera.visible = false;
							camHUD.visible = false;
							camPreHUD.visible = false;
							camOverlayHUD.visible = false;
							camNotes.visible = false;
							startVideo('backup', false, false);

							WindowUtil.setTitle("LOADING");
						};
					}

				case 'games-are-over':
					startCallback = function()
					{
						inCutscene = true;
						canPause = false;
						startVideo('games-cutscene');
					};
			}
		}

		//Umbra this is for you :3
		textYou = new FlxText(0, 200, 0, 'YOU', 48);
		textYou.setFormat(Paths.font("mariones.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		textYou.alpha = 0;
		textYou.borderSize = 2;
		noteGroup.add(textYou);

		noteGroup.add(grpHoldSplashes);
		noteGroup.add(grpNoteSplashes);

		FlxG.camera.snapToTarget();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		moveCameraSection();

		if (Assets.exists(Paths.txt(Paths.formatToSongPath(SONG.song.toLowerCase()) + "/info")))
		{
			taskDefault = new SongIntroDefault(0, 0, Paths.formatToSongPath(SONG.song.toLowerCase()));

			taskDefault.cameras = [camHUD];

			add(taskDefault);
		}

		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar_small', function() return isPixelStage ? health : lerpHealth, 0, 2);
		healthBar.screenCenter(X);
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		healthBar.leftToRight = PlayState.SONG.swapPlayers;

		if(opponentMode)
			healthBar.leftToRight = !healthBar.leftToRight;

		if(!ClientPrefs.data.hideHud) uiGroup.add(healthBar);

		if (stageUI == 'bp')
		{
			healthBarBGOverlay = new FlxSprite(0, 0);
			healthBarBGOverlay.scale.set(0.8, 0.8);
			healthBarBGOverlay.loadGraphic(Paths.image('healthBarOverlay', 'shared'));

			healthBarBGOverlay.visible = !ClientPrefs.data.hideHud;
			healthBarBGOverlay.alpha = ClientPrefs.data.healthBarAlpha;
			healthBarBGOverlay.antialiasing = false;
			uiGroup.add(healthBarBGOverlay);

			healthBarBGOverlay.screenCenter(X);
			healthBarBGOverlay.y = healthBar.y - 34;

			timeBarBGOverlay.x = timeBar.x - 11;
			timeBarBGOverlay.y = timeBar.y - 12;
		}

		iconP1 = new HealthIcon(boyfriend.healthIcon, true, true, boyfriend.iconOffsets, boyfriend.iconScale, boyfriend.iconFlipX, boyfriend.iconBlend, boyfriend.iconFps24);
		iconP1.y = healthBar.y - 75;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		if(!ClientPrefs.data.hideHud) uiGroup.add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false, true, dad.iconOffsets, dad.iconScale, dad.iconFlipX, dad.iconBlend, dad.iconFps24);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.data.hideHud;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		if(!ClientPrefs.data.hideHud) uiGroup.add(iconP2);

		if(ClientPrefs.data.optimize)
		{
			iconP1.visible = false;
			iconP2.visible = false;
		}

		scoreTxt = new FlxText(0, healthBar.y + 35, FlxG.width, "", 18);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.RED);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1;
		scoreTxt.visible = !ClientPrefs.data.hideHud;
		if(!ClientPrefs.data.hideHud) uiGroup.add(scoreTxt);

		comboTxt = new FlxText(0, 0, 0, '', 32);
		comboTxt.setFormat(Paths.font("5by7.ttf"), 42, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		comboTxt.borderSize = 1.25;
		comboTxt.screenCenter(X);
		comboTxt.y += 160;
		comboGroup.add(comboTxt);

		if (stageUI == 'bp')
		{
			scoreTxt.visible = false;

			scoreTxt_BP = new FlxText(10, healthBar.y - 55, FlxG.width, "", 32);
			scoreTxt_BP.setFormat(Paths.font("HouseofTerror.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
	
			scoreTxt_BP.scrollFactor.set();
			scoreTxt_BP.borderSize = 1.25;
			if (!ClientPrefs.data.hideHud) uiGroup.add(scoreTxt_BP);

			accuracyShit = new FlxText(0, healthBar.y + 30, FlxG.width, "Rating: Horny", 32);
			accuracyShit.setFormat(Paths.font("HouseofTerror.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			accuracyShit.scrollFactor.set();
			accuracyShit.borderSize = 1.25;

			ratingTxt = new FlxText(0, healthBar.y - 125, FlxG.width, "Lmao x69", 64);
			ratingTxt.setFormat(Paths.font("HouseofTerror.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			ratingTxt.scrollFactor.set();
			ratingTxt.alpha = 0.001;
			ratingTxt.borderSize = 1.5;

			uiGroup.add(accuracyShit);
			uiGroup.add(ratingTxt);

			fireHalapeno = new FlxSprite(0, scoreTxt_BP.y - 400);
			fireHalapeno.frames = Paths.getSparrowAtlas('fire_jap');
			fireHalapeno.animation.addByPrefix('idle', 'firing', 24, false);
			fireHalapeno.flipY = ClientPrefs.data.downScroll;
			fireHalapeno.antialiasing = ClientPrefs.data.antialiasing;
			fireHalapeno.scrollFactor.set();
			fireHalapeno.blend = ADD;
			fireHalapeno.alpha = 0.0001;
			fireHalapeno.updateHitbox();
			fireHalapeno.screenCenter(X);
			fireHalapeno.animation.play('idle');
			uiGroup.add(fireHalapeno);

			if(ClientPrefs.data.downScroll)
				fireHalapeno.y = -25;

			fireFlash = new FunkinSprite().makeSolidColor(FlxG.width, FlxG.height, 0xFFFF7700);
			fireFlash.alpha = 0;
			fireFlash.blend = ADD;
			uiGroup.add(fireFlash);

			// медальки
			medal = new FlxSprite(FlxG.width - 164, FlxG.height - 224).loadGraphic(Paths.image('medals/medal_6', 'shared'));
			medal.scale.set(0.3, 0.3);
			medal.origin.set(128/2, 128/2);
			medal.updateHitbox();
			medal.visible = !ClientPrefs.data.hideHud;
			if (!ClientPrefs.data.hideHud) uiGroup.add(medal);

			if (FlxG.save.data.doesHeKnow == false) MusicBeatState.changeCursor(false);
		}

		if (curStage == 'final')
		{
			fireHalapeno = new FlxSprite(0, 250);
			fireHalapeno.frames = Paths.getSparrowAtlas('fire_jap');
			fireHalapeno.animation.addByPrefix('idle', 'firing', 24, false);
			fireHalapeno.flipY = ClientPrefs.data.downScroll;
			fireHalapeno.antialiasing = ClientPrefs.data.antialiasing;
			fireHalapeno.scrollFactor.set();
			fireHalapeno.blend = ADD;
			fireHalapeno.alpha = 0.0001;
			fireHalapeno.updateHitbox();
			fireHalapeno.screenCenter(X);
			fireHalapeno.animation.play('idle');
			uiGroup.add(fireHalapeno);

			if(ClientPrefs.data.downScroll)
				fireHalapeno.y = -25;

			fireFlash = new FunkinSprite().makeSolidColor(FlxG.width, FlxG.height, 0xFFFF7700);
			fireFlash.alpha = 0;
			fireFlash.blend = ADD;
			uiGroup.add(fireFlash);
		}

		//skip feature code by KadeDev
		skipText = new FlxText(0, FlxG.height - 34, 500);
		skipText.text = "Press Space to Skip Intro";
		skipText.setFormat(Paths.font("YoureGone-Regular.otf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);

		if(ClientPrefs.data.downScroll)
			skipText.y = healthBar.y + 110;
		
		skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK, 2, 1);
		skipText.cameras = [camOther];
		skipText.alpha = 0;
		if(!ClientPrefs.data.hideHud) add(skipText);

		botplayTxt = new FlxText(400, healthBar.y - 90, FlxG.width - 800, Language.getPhrase("Botplay").toUpperCase(), 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		uiPostGroup.add(botplayTxt);
		if(ClientPrefs.data.downScroll)
			botplayTxt.y = healthBar.y + 70;

		uiGroup.cameras = [camHUD];
		noteGroup.cameras = [camNotes];
		comboGroup.cameras = [camHUD];
		countGroup.cameras = [camOverlayHUD];
		uiPostGroup.cameras = [camOverlayHUD];

		if(PlayState.SONG.comboInGameCam) comboOnCamGame(true, PlayState.SONG.comboX, PlayState.SONG.comboY);

		startingSong = true;

		#if LUA_ALLOWED
		for (notetype in noteTypes)
			startLuasNamed('custom_notetypes/' + notetype + '.lua');
		for (event in eventsPushed)
			startLuasNamed('custom_events/' + event + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');
		for (event in eventsPushed)
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end
		noteTypes = null;
		eventsPushed = null;

		// SONG SPECIFIC SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		if (!ClientPrefs.data.optimize) setupCameraToSong();
		resetCamera();

		if(eventNotes.length > 0)
		{
			for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		startCallback();
		RecalculateRating(false, false);

		if (isStoryMode)
		{
			if (firstSong != curSong) // Makes sure it isnt the first song
				setWeekProgress(storyPlaylist);

			if (Progression.weekProgress.exists(WeekData.getCurrentWeek().weekName) && firstSong == curSong) // Clear week progress if start over
			{
				Progression.weekProgress.remove(WeekData.getCurrentWeek().weekName);
				Progression.save();
			}
		}

		if (stageUI == 'bp')
		{
			medalStatus = 5; //ага...

			if (medalOldStatus != medalStatus)
			{
				medalOldStatus = medalStatus;
				uniqueMedalChange(medalStatus+1);
				medal.loadGraphic(Paths.image('medals/medal_${medalStatus+1}', 'shared'));
			}
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		//PRECACHING THINGS THAT GET USED FREQUENTLY TO AVOID LAGSPIKES
		if(ClientPrefs.data.hitsoundVolume > 0) Paths.sound("hitsounds/"+ClientPrefs.data.hitsoundType);
		if(!ClientPrefs.data.missSounds) for (i in 1...4) Paths.sound('missnote$i');
		Paths.image('alphabet');

		Paths.image('pause_real/screenstatic');
		Paths.image('pause_real/Mario_static');
		Paths.image('pause_real/stop_sign');

		if (PauseSubState.songName != null)
			Paths.music('pause_music/'+PauseSubState.songName);
		else if(Paths.formatToSongPath(ClientPrefs.data.pauseMusic) != 'none')
			Paths.music('pause_music/'+Paths.formatToSongPath(ClientPrefs.data.pauseMusic));

		if(stageUI == 'bp')
			Paths.music('pause_music/fake-pause');

		resetRPC();

		stagesFunc(function(stage:BaseStage) stage.createPost());
		callOnScripts('onCreatePost');

		if (PlayState.SONG.fadeOutStart && !ClientPrefs.data.optimize)
		{
			if(curSong == 'Fire Thoser' && opponentMode)
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.0001, false, null, true);
			}
			else
			{
				if (!PlayState.SONG.inFrontFade)
					FlxG.camera.fade(FlxColor.BLACK, 0.0001, false, null, true);
				else
					camOverlayHUD.fade(FlxColor.BLACK, 0.0001, false, null, true);
			}
		}
		
		var splash:NoteSplash = new NoteSplash();
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0001; //cant make it invisible or it won't allow precaching

		var splashHold:SustainSplash = new SustainSplash();
		grpHoldSplashes.add(splashHold);
		splashHold.alpha = 0.0001;

		super.create();
		Paths.clearUnusedMemory();

		var songTxt:String = SONG.displayName == null ? SONG.song : SONG.displayName;

		cacheCountdown();
		if(stageUI == 'bp')
		{
			cacheMedals();
			if (FlxG.save.data.doesHeKnow == false && FlxG.save.data.introduction == true) WindowUtil.setTitle("BP V2");
		}
		else
			WindowUtil.setTitle("Pepper's Files: "+ songTxt);

		if(opponentMode)
		{
			controlledPlayer = PlayState.SONG.swapPlayers ? boyfriend : dad;
		}
		else
		{
			controlledPlayer = PlayState.SONG.swapPlayers ? dad : boyfriend;
		}

		if(curSong == 'boot')
		{
			scoreTxt_BP.visible = false;
			ratingTxt.visible = false;
			healthBarBGOverlay.visible = false;
			accuracyShit.visible = false;
			medal.visible = false;
			canPause = false;
		}

		if (eventNotes.length > 0) checkEventNote();

		refresh();
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) if(note.mustPress) note.resizeByRatio(ratio);
				for (note in unspawnNotes) if(note.mustPress) note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 600 / songSpeed * playbackRate);
		missOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}

	function set_songSpeedOpponent(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeedOpponent; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) if(!note.mustPress) note.resizeByRatio(ratio);
				for (note in unspawnNotes) if(!note.mustPress) note.resizeByRatio(ratio);
			}
		}
		songSpeedOpponent = value;
		noteKillOffsetOppo = Math.max(Conductor.stepCrochet, 600 / songSpeedOpponent * playbackRate);
		missOffsetOppo = Math.max(Conductor.stepCrochet, 350 / songSpeedOpponent * playbackRate);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			vocals.pitch = value;
			opponentVocals.pitch = value;
			FlxG.sound.music.pitch = value;

			var ratio:Float = playbackRate / value; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		FlxG.animationTimeScale = value;
		Conductor.offset = Reflect.hasField(PlayState.SONG, 'offset') ? (PlayState.SONG.offset / value) : 0;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		#if VIDEOS_ALLOWED
		if(videoCutscene != null && videoCutscene.videoSprite != null) videoCutscene.videoSprite.bitmap.rate = value;
		#end
		setOnScripts('playbackRate', playbackRate);

		return playbackRate;
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor) {
		var newText:funkin.psychlua.DebugLuaText = luaDebugGroup.recycle(funkin.psychlua.DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:funkin.psychlua.DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		//Sys.println(text);
	}
	#end

	public function reloadHealthBarColors() {
		var dadCol = dad.healthColorArray;
		var bfCol = boyfriend.healthColorArray;

		if(updateTime)
		{
			if (stageUI == 'bp')
				timeBar.createFilledBar(FlxColor.BLACK, 0xffc3e942);
			else
				timeBar.createFilledBar(FlxColor.BLACK, 0xFFFF0000);
		}

		if(PlayState.SONG.originalHealthColors)
			healthBar.setColors(0xFFFF0000, 0xFF66FF33);
		else
			healthBar.setColors(
				FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]), 
				FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2])
			);

		if(ClientPrefs.data.optimize)
			healthBar.setColors(0xFF000000, 0xFFFF0000);
	}

	public function addCharacterToList(json:String, type:Int = 0, cache:Bool = true, strumEventTime:Float = 0):Character
	{
		var characterMap:Map<String, Character> = boyfriendMap;
		var characterGroup:FlxSpriteGroup = boyfriendGroup;
		var scrollFacChar:Array<Float> = [1, 1];

		var controlP:Bool = true;

		var stageData:StageFile = StageData.getStageFile(curStage);

		switch (type)
		{
			case 0:
				if(stageData.scrollFactor_boyfriend != null) scrollFacChar = [stageData.scrollFactor_boyfriend[0], stageData.scrollFactor_boyfriend[1]];

				if(PlayState.SONG.swapPlayers)
					controlP = false;

				controlP = true;

				if(opponentMode)
					controlP = !controlP;

			case 1:
				characterMap = dadMap;
				characterGroup = dadGroup;

				controlP = false;

				if(PlayState.SONG.swapPlayers)
					controlP = true;

				if(opponentMode)
					controlP = !controlP;

				if(stageData.scrollFactor_opponent != null) scrollFacChar = [stageData.scrollFactor_opponent[0], stageData.scrollFactor_opponent[1]];

			case 2:
				characterMap = gfMap;
				characterGroup = gfGroup;

				controlP = false;

				if(stageData.scrollFactor_girlfriend!= null) scrollFacChar = [stageData.scrollFactor_girlfriend[0], stageData.scrollFactor_girlfriend[1]];

			case 3:
				characterMap = secondMap;
				characterGroup = secondGroup;

				controlP = false;

				if(stageData.scrollFactor_opponent!= null) scrollFacChar = [stageData.scrollFactor_opponent[0], stageData.scrollFactor_opponent[1]];
		}

		if (characterMap.exists(json)) return characterMap[json];
		else if (cache && type == 2 && gf == null) return null;

		var character:Character = new Character(0, 0, json, type == 0);
		characterMap.set(json, character);
		character.controlledPerson = controlP;
		characterGroup.add(character);
		startCharacterPos(character);

		characterGroup.scrollFactor.set(scrollFacChar[0], scrollFacChar[1]);

		if (ClientPrefs.data.activeBfSkin == 'pixel' && character.curCharacter == 'bf-pixel')
		{
			character.pixelPerfectRender = true;
			character.pixelPerfectPosition = true;
		}

		if (ClientPrefs.data.activeBfSkin == 'pixel' && character.curCharacter == 'bf-pixel-pissed')
		{
			character.pixelPerfectRender = true;
			character.pixelPerfectPosition = true;
		}

		if (ClientPrefs.data.activeBfSkin == 'pixel' && character.curCharacter == 'P3-bf-pixel')
		{
			character.pixelPerfectRender = true;
			character.pixelPerfectPosition = true;
		}

		if (ClientPrefs.data.activeBfSkin == 'pixel' && character.curCharacter == 'P3-bf-flip-pixel')
		{
			character.pixelPerfectRender = true;
			character.pixelPerfectPosition = true;
		}

		if (ClientPrefs.data.activeBfSkin == 'pixel' && character.curCharacter == 'gf-pixel')
		{
			character.pixelPerfectRender = true;
			character.pixelPerfectPosition = true;
		}
		
		if (cache)
		{
			character.alpha = .0001;
			startCharacterScripts(character.curCharacter);

			if(!opponentMode)
			{
				for (note in unspawnNotes)
				{
					if (note.colored && note.gfNote && note.strumTime >= strumEventTime)
					{
						var arrGf:Array<String>;
						arrGf = character.opponentNoteColor[note.noteData];
								
						if (arrGf != null && note.noteData > -1 && arrGf.length >= 3)
						{
							note.rgbShader.r = CoolUtil.colorFromString(arrGf[0]);
							note.rgbShader.g = CoolUtil.colorFromString(arrGf[1]);
							note.rgbShader.b = CoolUtil.colorFromString(arrGf[2]);
			
							// splash data and colors
							note.noteSplashData.r = CoolUtil.colorFromString(arrGf[0]);
							note.noteSplashData.g = CoolUtil.colorFromString(arrGf[1]);
						}
						else
						{
							note.rgbShader.r = 0xFFFF0000;
							note.rgbShader.g = 0xFF00FF00;
							note.rgbShader.b = 0xFF0000FF;
						}
					}
				}
			}
		}
		return character;
	}

	function startCharacterScripts(name:String)
	{
		// Lua
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/$name.lua';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(replacePath))
		{
			luaFile = replacePath;
			doPush = true;
		}
		else
		{
			luaFile = Paths.getSharedPath(luaFile);
			if(FileSystem.exists(luaFile))
				doPush = true;
		}
		#else
		luaFile = Paths.getSharedPath(luaFile);
		if(Assets.exists(luaFile)) doPush = true;
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile)
				{
					doPush = false;
					break;
				}
			}
			if(doPush) new FunkinLua(luaFile);
		}
		#end

		// HScript
		#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var scriptFile:String = 'characters/' + name + '.hx';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(scriptFile);
		if(FileSystem.exists(replacePath))
		{
			scriptFile = replacePath;
			doPush = true;
		}
		else
		#end
		{
			scriptFile = Paths.getSharedPath(scriptFile);
			if(FileSystem.exists(scriptFile))
				doPush = true;
		}

		if(doPush)
		{
			if(Iris.instances.exists(scriptFile))
				doPush = false;

			if(doPush) initHScript(scriptFile);
		}
		#end
	}

	public function getLuaObject(tag:String):Dynamic
		return variables.get(tag);

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public var videoCutscene:VideoSprite = null;

	/** Videos warmed by `precacheVideo`, keyed by name, adopted on the matching `startVideo` call. */
	public var precachedVideos:Map<String, VideoSprite> = new Map<String, VideoSprite>();

	/**
	 * Warms a video ahead of time so the matching `startVideo` starts without the open/decode hitch.
	 * Pass the same `forMidSong`/`canSkip`/`loop` you'll later hand to `startVideo`; a mismatch on
	 * `forMidSong` or `loop` (which are baked in at load time) discards the warmed copy and rebuilds.
	 */
	public function precacheVideo(name:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false):Void {
		#if VIDEOS_ALLOWED
		if (precachedVideos.exists(name))
			return;

		final fileName:String = Paths.video(name);
		#if sys
		if (!FileSystem.exists(fileName))
		#else
		if (!OpenFlAssets.exists(fileName))
		#end
			return;

		precachedVideos.set(name, new VideoSprite(fileName, forMidSong, canSkip, loop, true));
		#end
	}

	public function startVideo(name:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, playOnLoad:Bool = true)
	{
		#if VIDEOS_ALLOWED
		inCutscene = !forMidSong;
		canPause = forMidSong;

		var foundFile:Bool = false;
		var fileName:String = Paths.video(name);

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			var reused:VideoSprite = precachedVideos.get(name);
			if (reused != null) {
				precachedVideos.remove(name);
				// The warmed copy is only valid if the load-time options match; otherwise rebuild.
				if (reused.waiting != forMidSong || reused.looping != loop) {
					reused.destroy();
					reused = null;
				}
			}

			videoCutscene = reused != null ? reused : new VideoSprite(fileName, forMidSong, canSkip, loop);
			videoCutscene.canSkip = canSkip;
			if(forMidSong) videoCutscene.videoSprite.bitmap.rate = playbackRate;

			// Finish callback
			if (!forMidSong)
			{
				function onVideoEnd()
				{
					if (!isDead && generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
					{
						moveCameraSection();
						FlxG.camera.snapToTarget();
					}
					videoCutscene = null;
					canPause = true;
					inCutscene = false;
					startAndEnd();
				}
				videoCutscene.finishCallback = onVideoEnd;
				videoCutscene.onSkip = onVideoEnd;
				videoCutscene.cameras = [camOtherAlt];
			}
			else videoCutscene.videoSprite.cameras = [camPreHUD];

			if (GameOverSubstate.instance != null && isDead) GameOverSubstate.instance.add(videoCutscene);
			else add(videoCutscene);

			if (playOnLoad)
				videoCutscene.play();
			return videoCutscene;
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		else addTextToDebug("Video not found: " + fileName, FlxColor.RED);
		#else
		else FlxG.log.error("Video not found: " + fileName);
		#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		#end
		return null;
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var tb_x = 60;
	var tb_y = 410;
	var tb_fx = -510 + 40;
	var tb_fy = 320;
	var tb_rx = 200 - 55;
	var jx:Int;

	var curr_char:Int;
	var curr_dial:Int;
	var dropText:FlxText;
	var tbox:FlxSprite;
	var talk:Int;
	var tb_appear:Int;
	var dcd:Int;
	var fimage:String;
	var fsprite:FlxSprite;
	var fside:Int;
	var black:FlxSprite;
	var tb_open:Bool = false;

	var afterAction:String = 'countdown';

	var textIndex = 'example';

	var vc_sfx:FlxSound;

	public static var defaultText:Array<Dynamic> = [
		[
			'sample text 1',
			'sample text 2',
			'sample text 3'
		],
		[
			'sh',
			'bf',
			'sh'
		]
	];

	public static function getText(dataIndex:String):Array<Dynamic>
	{
		var data:Array<Dynamic> = [[], []];

		var txtList = CoolUtil.coolTextFile(dataIndex);
		for (i in 0...txtList.length)
		{
			var seps:Array<String> = txtList[i].split(":");
			data[0].push(StringTools.replace(seps[1], '#', '\n'));
			data[1].push(seps[0]);
		}

		if (data == [])
		{
			data = defaultText;
		}
		return data;
	}

	//DIALOGUE CODE FROM SHAGGY MOD
	function schoolIntro():Void
	{
		inCutscene = true;

		var file:String = Paths.txt('$songName/${textIndex}'); //Checks for vanilla/Senpai dialogue
		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			file = Paths.txt('$songName/${textIndex}');
		}

		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			startCountdown();
			return;
		}

		var readFrom:Array<Dynamic> = getText(file);
		dialogue = readFrom[0];
		dchar = readFrom[1];

		black = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		black.cameras = [camOther];

		var dim:FlxSprite = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		dim.alpha = 0;
		dim.scrollFactor.set();
		add(dim);

		dim.cameras = [camOther];

		if (black.alpha == 1)
		{
			dropText = new FlxText(140, tb_y + 70, 2000, "", 64);
			curr_char = 0;
			curr_dial = 0;
			talk = 1;
			tb_appear = 0;
			tbox = new FlxSprite(tb_x, tb_y, Paths.image('TextBox'));
			fimage = dchar[0] + '_dialogue';
			faceRender();
			fsprite.alpha = 0;
			tbox.alpha = 0;
			dcd = 7;

			dropText.cameras = [camOther];
			tbox.cameras = [camOther];

			dcd = 2;
			black.alpha = 0;

			/*if (btrans == 0)
			{
				dcd = 2;
				black.alpha = 0;
			}
			else if (btrans == 2)
			{
				dcd = 11;
			}*/
		}

		if (!tb_open)
		{
			tb_open = true;
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				black.alpha -= 0.15;
				dcd --;
				if (dcd == 0)
				{
					tb_appear = 1;
				}
				tmr.reset(0.3);
			});
			if (talk == 1 || tbox.alpha >= 0)
			{
				new FlxTimer().start(0.03, function(ap_dp:FlxTimer)
				{
					
					if (tb_appear == 1)
					{
						if (tbox.alpha < 1)
						{
							tbox.alpha += 0.1;
						}
					}
					else
					{
						if (tbox.alpha > 0)
						{
							tbox.alpha -= 0.1;
						}
					}
					dropText.alpha = tbox.alpha;
					fsprite.alpha = tbox.alpha;
					dim.alpha = tbox.alpha / 2;
					ap_dp.reset(0.05);
				});
				var writing = dialogue[curr_dial];
				new FlxTimer().start(0.025, function(tmr2:FlxTimer) //0.025
				{
					if (talk == 1)
					{
						var now:Date = Date.now();

						if (textIndex == 'dialogue-ycr-normal' && curr_dial == 12)
							dialogue[curr_dial] = 'Чувак, уже как бы '+ now.getFullYear() +' год';

						if (textIndex == 'dialogue-ycr-early' && curr_dial == 12)
							dialogue[curr_dial] = 'Чувак, уже как бы '+ now.getFullYear() +' год';

						var newtxt = dialogue[curr_dial].substr(0, curr_char);

						var charat = dialogue[curr_dial].substr(curr_char - 1, 1);
						if (curr_char <= dialogue[curr_dial].length && tb_appear == 1)
						{
							if (charat != ' ')
							{
								switch(dchar[curr_dial])
								{
									case 'bf':
										FunkinSound.playOnce(Paths.sound('bf_talk'), 0.6);
									case 'gf':
										FunkinSound.playOnce(Paths.sound('gf_talk'), 0.6);
									case 'exe' | 'xeno' | 'xeno_mad' | 'xeno_doom':
										FunkinSound.playOnce(Paths.sound('exe_talk'), 0.6);
								}
							}
							curr_char ++;
						}

						//portraitLeft.loadGraphic(Paths.image('logo'), false, 500, 200, false);
						//portraitLeft.setGraphicSize(200);

						fsprite.updateHitbox();
						fsprite.scrollFactor.set();

						add(fsprite);

						tbox.updateHitbox();
						tbox.scrollFactor.set();
						add(tbox);

						dropText.text = newtxt;
						dropText.font = Paths.font("PixelImpacted-Regular.otf");
						dropText.color = 0xFFFFFFFF;
						dropText.scrollFactor.set();
						add(dropText);

						dropText.cameras = [camOther];
						tbox.cameras = [camOther];
						fsprite.cameras = [camOther];
					}
					tmr2.reset(0.025);
				});

				new FlxTimer().start(0.0001, function(prs:FlxTimer)
				{
					var skip:Bool = false;
					if (textIndex.startsWith('dialogue-ycr-') && curr_dial == 3 && curr_char >= 31)
					{
						skip = true;
					}
					else skip = false;
					
					if (controls.ACCEPT || skip)
					{
						if ((curr_char <= dialogue[curr_dial].length) && !skip)
						{
							curr_char = dialogue[curr_dial].length;
						}
						else
						{
							curr_char = 0;
							curr_dial ++;
							if (curr_dial >= dialogue.length)
							{

								switch afterAction
								{
									case 'countdown':
										prs.cancel();

										if(songName == 'too-fire') FlxG.sound.music.fadeOut(1.5, 0, (_) -> FlxG.sound.music.stop());

										new FlxTimer().start(0.1, function(tmr:FlxTimer)
										{
											startCountdown();
										});
								}
								talk = 0;
								dropText.alpha = 0;
								curr_dial = 0;
								tb_appear = 0;
							}
							else
							{
								if (fimage != "n")
								{
									fsprite.destroy();
									faceRender();
									fsprite.flipX = false;
								}

								if (textIndex.startsWith('dialogue-ycr-') && curr_dial == 4)
									FlxG.sound.playMusic(Paths.music('dialogue_mus/arson'), 0.6);

								if (textIndex.startsWith('dialogue-ycr-') && curr_dial == 7)
								{
									FunkinSound.playOnce(Paths.sound('ANGRY_TEXT_BOX'));
									FunkinSound.playOnce(Paths.sound('ANGRY'));
									FlxG.sound.music.stop();
								}
							}
						}
					}
					prs.reset(0.0001);
				});
			}
		}
	}
	function faceRender():Void
	{
		jx = tb_fx;
		if (dchar[curr_dial] == 'bf' || dchar[curr_dial] == 'gf')
		{
			jx = tb_rx;
		}
		fsprite = new FlxSprite(tb_x + Std.int(tbox.width / 2) + jx, tb_y - tb_fy + 50);

		if (dchar[curr_dial] == 'exe')
			fsprite.y -= 70;

		if (dchar[curr_dial] == 'xeno')
			fsprite.y -= 175;

		if (dchar[curr_dial] == 'xeno_mad')
			fsprite.y -= 175;

		if (dchar[curr_dial] == 'xeno_doom')
			fsprite.y -= 300;

		fsprite.frames = Paths.getSparrowAtlas('dialogue/STUFF_Dialogue');
		fsprite.animation.addByPrefix('bf', 'bf_dialogue', 24, true);
		fsprite.animation.addByPrefix('gf', 'gf_dialouge', 24, true);
		fsprite.animation.addByPrefix('exe', 'exe_dialogue', 24, true);
		fsprite.animation.addByPrefix('xeno', 'xeno_dialogue', 24, true);
		fsprite.animation.addByPrefix('xeno_mad', 'xeno_mad_dialogue', 24, true);
		fsprite.animation.addByPrefix('xeno_doom', 'doomsday_xeno_dialogue', 24, true);
		fsprite.animation.play(dchar[curr_dial]);

		//fsprite.centerOffsets(true);
		fsprite.antialiasing = ClientPrefs.data.antialiasing;
		fsprite.updateHitbox();
		fsprite.scrollFactor.set();
		add(fsprite);

		fsprite.cameras = [camOther];
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	var startTimer:FlxTimer;
	var goTimer:FlxTimer;
	var vwooshTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var introImagesArray:Array<String> = switch(stageUI) {
			case "pixel": ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel'];
			case "normal": ["ready", "set" ,"go"];
			default: ['${uiPrefix}UI/ready${uiPostfix}', '${uiPrefix}UI/set${uiPostfix}', '${uiPrefix}UI/go${uiPostfix}'];
		}
		introAssets.set(stageUI, introImagesArray);
		var introAlts:Array<String> = introAssets.get(stageUI);
		for (asset in introAlts) Paths.image(asset);

		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function reloadChars()
	{
		if(boyfriend.curCharacter != SONG.player1) {
			if(!boyfriendMap.exists(SONG.player1)) {
				addCharacterToList(SONG.player1, 0, false);
			}

			var lastAlpha:Float = boyfriend.alpha;
			boyfriend.alpha = 0.00001;
			boyfriend = boyfriendMap.get(SONG.player1);
			boyfriend.alpha = lastAlpha;
		}
		boyfriendGroup.x = BF_X;
		boyfriendGroup.y = BF_Y;
			
		boyfriend.x = boyfriendGroup.x;
		boyfriend.y = boyfriendGroup.y;
		startCharacterPos(boyfriend);

		iconP1.changeIcon(boyfriend.healthIcon, true, boyfriend.iconOffsets, boyfriend.iconScale, boyfriend.iconFlipX, boyfriend.iconBlend, boyfriend.iconFps24);
		setOnScripts('boyfriendName', boyfriend.curCharacter);


		if(dad.curCharacter != SONG.player2) {
			if(!dadMap.exists(SONG.player2)) {
				addCharacterToList(SONG.player2, 1);
			}

			var wasGf:Bool = dad.curCharacter.startsWith('gf-') || dad.curCharacter == 'gf';
			var lastAlpha:Float = dad.alpha;
			dad.alpha = 0.00001;
			dad = dadMap.get(SONG.player2);
			if(!dad.curCharacter.startsWith('gf-') && dad.curCharacter != 'gf') {
				if(wasGf && gf != null) {
					gf.visible = true;
				}
			} else if(gf != null) {
				gf.visible = false;
			}
			dad.alpha = lastAlpha;
		}
		dadGroup.x = DAD_X;
		dadGroup.y = DAD_Y;

		dad.x = dadGroup.x;
		dad.y = dadGroup.y;
		startCharacterPos(dad);

		iconP2.changeIcon(dad.healthIcon, true, dad.iconOffsets, dad.iconScale, dad.iconFlipX, dad.iconBlend, dad.iconFps24);
		setOnScripts('dadName', dad.curCharacter);

		if(gf != null)
		{
			if(gf.curCharacter != SONG.gfVersion)
			{
				if(!gfMap.exists(SONG.gfVersion)) {
					addCharacterToList(SONG.gfVersion, 2);
				}

				var lastAlpha:Float = gf.alpha;
				gf.alpha = 0.00001;
				gf = gfMap.get(SONG.gfVersion);
				gf.alpha = lastAlpha;
			}
			setOnScripts('gfName', gf.curCharacter);
		}

		gfGroup.x = GF_X;
		gfGroup.y = GF_Y;

		gf.x = gfGroup.x;
		gf.y = gfGroup.y;
		startCharacterPos(gf);

		reloadHealthBarColors();
	}
	
	var stageDataPrefs:StageFile = StageData.getStageFile(curStage);

	public function revivePlayer()
	{
		stagesFunc(function(stage:BaseStage) stage.songRestart());
		callOnScripts('onSongRestart');

		singingShakeArray = [false, false];

		shakeBeat = false;

		if (taskDefault != null) taskDefault.goBack();

		if (subtitlesTxt != null) subtitlesTxt.alpha = 0;

		//TOO FIRE GONE
		lagJack = false;

		skipTime = 0;
		canSkip = false;
		skipText.alpha = 0;

		vocals.volume = 1;
		if(!isLegacyVocals) opponentVocals.volume = 1;

		// if the sustain splash exists, KILL KIL KILL IT KILL KI L KLLK LSKD:LKLK
		for (i in grpHoldSplashes.members)
		{
			i.alpha = 0.0;
			i.visible = false;
		}

		if(!ClientPrefs.data.optimize) 
		{
			FlxTween.cancelTweensOf(dadGroup);
			FlxTween.cancelTweensOf(dadGroup.x);
			FlxTween.cancelTweensOf(dadGroup.y);

			FlxTween.cancelTweensOf(gfGroup);
			FlxTween.cancelTweensOf(gfGroup.x);
			FlxTween.cancelTweensOf(gfGroup.y);

			FlxTween.cancelTweensOf(boyfriendGroup);
			FlxTween.cancelTweensOf(boyfriendGroup.x);
			FlxTween.cancelTweensOf(boyfriendGroup.y);

			reloadChars();

			boyfriend.playInitAnimation();
			dad.playInitAnimation();
			if(gf != null) gf.playInitAnimation();

			#if VIDEOS_ALLOWED
			if(videoCutscene != null)
			{
				videoCutscene.destroy();
				videoCutscene = null;
			}
			#end
		}

		noteCamOffset = SONG.followCamOffset;

		if (PlayState.SONG.fadeOutStart && !ClientPrefs.data.optimize)
		{
			if(curSong == 'Fire Thoser' && opponentMode)
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.0001, false, null, true);
			}
			else
			{
				if (!PlayState.SONG.inFrontFade)
					FlxG.camera.fade(FlxColor.BLACK, 0.0001, false, null, true);
				else
					camOverlayHUD.fade(FlxColor.BLACK, 0.0001, false, null, true);
			}
		}

		BF_X = stageDataPrefs.boyfriend[0];
		BF_Y = stageDataPrefs.boyfriend[1];
		GF_X = stageDataPrefs.girlfriend[0];
		GF_Y = stageDataPrefs.girlfriend[1];
		DAD_X = stageDataPrefs.opponent[0];
		DAD_Y = stageDataPrefs.opponent[1];

		reloading = true;

		ratingPercent = 0;
		ratingFC = '';
		totalPlayed = 0;
		totalNotesHit = 0;
		songScore = 0.0;
		combo = 0;
		comboGot = 0;
		songMisses = 0;
		ratingsData[0].hits = 0;
		ratingsData[1].hits = 0;
		ratingsData[2].hits = 0;
		ratingsData[3].hits = 0;

		updateScoreText();

		FlxG.sound.music.pause();
		vocals.pause();
		if(!isLegacyVocals) opponentVocals.pause();

		FlxG.sound.music.time = 0;
		vocals.time = 0;
		if(!isLegacyVocals) opponentVocals.time = 0;
		Conductor.songPosition = 0;

		startingSong = true;
		startedCountdown = false;
		updateTime = false;
		timeTxt.alpha = 0;
		timeBar.alpha = 0;
		timeBarBG.alpha = 0;
		if (stageUI == 'bp') timeBarBGOverlay.alpha = 0;
		songLength = 0;
		canResync = false;

		rank = 5;

		if(stageUI == 'bp')
		{
			medalOldStatus = 5;
			medalStatus = 5;
	
			uniqueMedalChange(medalStatus+1);
			medal.loadGraphic(Paths.image('medals/medal_${medalStatus+1}', 'shared'));
		}

		isDead = false;

		songSpeed = PlayState.SONG.speed;
		songSpeedOpponent = PlayState.SONG.speed;
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
				songSpeedOpponent = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
				songSpeedOpponent = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		camGame.alpha = 1;
		camHUD.alpha = 1;
		camOverlayHUD.alpha = 1;
		camNotes.alpha = 1;
		camOther.alpha = 1;

		currentCameraZoom = 1.0;
		cameraBopMultiplier = 1.0;

		defaultHUDCameraZoom = 1.0;
		camHudBopMult = 1.0;

		defaultNotesCameraZoom = 0.95;
		camNotesBopMult = 1.0;

		camZoomingDecay = 1;
		camZoomingDecayHud = 1;

		cameraBopIntensity = 1.015;
		hudCameraZoomIntensity = 0.015 * 2.0;
		cameraZoomRate = 4;

		if(!ClientPrefs.data.optimize) setupCameraToSong();
		resetCamera();

		stagesFunc(function(stage:BaseStage) stage.songRestartPost());
		callOnScripts('onSongRestartPost');

		refresh();
		
		// so the song doesn't start too early :D
		var vwooshDelay:Float = 0.5;

		vwooshTimer = new FlxTimer().start(vwooshDelay, function(_) {
			needsToReset = true;
			updateTime = true;
			canResync = true;
			generateNotes(true);

			if(eventNotes.length > 0)
			{
				for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
				eventNotes.sort(sortByTime);
			}

			if (eventNotes.length > 0) checkEventNote();

			refresh();
			
			startCountdown();
		});
	}

	public function restartSong()
	{
		stagesFunc(function(stage:BaseStage) stage.songRestart());
		callOnScripts('onSongRestart');

		if (taskDefault != null) taskDefault.goBack();

		//TOO FIRE GONE
		lagJack = false;

		singingShakeArray = [false, false];

		shakeBeat = false;

		if (subtitlesTxt != null) subtitlesTxt.alpha = 0;

		//FlxTimer.globalManager.forEach(function(tmr:FlxTimer) tmr.cancel());
		//FlxTween.globalManager.forEach(function(twn:FlxTween) twn.cancel());

		if (vwooshTimer != null) vwooshTimer.cancel();
		if (startTimer != null) startTimer.cancel();
		if (goTimer != null) goTimer.cancel();

		// Iterate backwards: countGroup.remove() shifts members, which would skip entries on a forward iterator.
		var i:Int = countGroup.members.length;
		while (--i >= 0) {
			var spr = countGroup.members[i];
			if (spr == null)
				continue;

			FlxTween.cancelTweensOf(spr);
			FlxTween.cancelTweensOf(spr.scale);

			countGroup.remove(spr, true);
			spr.destroy();
		}

		if(!ClientPrefs.data.optimize)
		{
			#if VIDEOS_ALLOWED
			if(videoCutscene != null)
			{
				videoCutscene.destroy();
				videoCutscene = null;
			}
			#end
		}

		skipTime = 0;
		canSkip = false;
		skipText.alpha = 0;

		vocals.volume = 1;
		if(!isLegacyVocals) opponentVocals.volume = 1;

		// if the sustain splash exists, KILL KIL KILL IT KILL KI L KLLK LSKD:LKLK
		for (i in grpHoldSplashes.members)
		{
			i.alpha = 0.0;
			i.visible = false;
		}

		if(!ClientPrefs.data.optimize)
		{
			FlxTween.cancelTweensOf(dadGroup);
			FlxTween.cancelTweensOf(dadGroup.x);
			FlxTween.cancelTweensOf(dadGroup.y);

			FlxTween.cancelTweensOf(gfGroup);
			FlxTween.cancelTweensOf(gfGroup.x);
			FlxTween.cancelTweensOf(gfGroup.y);

			FlxTween.cancelTweensOf(boyfriendGroup);
			FlxTween.cancelTweensOf(boyfriendGroup.x);
			FlxTween.cancelTweensOf(boyfriendGroup.y);

			reloadChars();

			boyfriend.playInitAnimation();
			dad.playInitAnimation();
			if(gf != null) gf.playInitAnimation();
		}

		noteCamOffset = SONG.followCamOffset;
		skipText.alpha = 0;

		camGame.stopFX();
		camPreHUD.stopFX();
		camHUD.stopFX();
		camOverlayHUD.stopFX();
		camNotes.stopFX();
		camOther.stopFX();

		if (PlayState.SONG.fadeOutStart && !ClientPrefs.data.optimize)
		{
			if(curSong == 'Fire Thoser' && opponentMode)
			{
				FlxG.camera.fade(FlxColor.BLACK, 0.0001, false, null, true);
			}
			else
			{
				if (!PlayState.SONG.inFrontFade)
					FlxG.camera.fade(FlxColor.BLACK, 0.0001, false, null, true);
				else
					camOverlayHUD.fade(FlxColor.BLACK, 0.0001, false, null, true);
			}
		}

		reloading = true;

		ratingPercent = 0;
		ratingFC = '';
		totalPlayed = 0;
		totalNotesHit = 0;
		songScore = 0.0;
		combo = 0;
		comboGot = 0;
		songMisses = 0;
		ratingsData[0].hits = 0;
		ratingsData[1].hits = 0;
		ratingsData[2].hits = 0;
		ratingsData[3].hits = 0;

		BF_X = stageDataPrefs.boyfriend[0];
		BF_Y = stageDataPrefs.boyfriend[1];
		GF_X = stageDataPrefs.girlfriend[0];
		GF_Y = stageDataPrefs.girlfriend[1];
		DAD_X = stageDataPrefs.opponent[0];
		DAD_Y = stageDataPrefs.opponent[1];

		rank = 5;

		if(stageUI == 'bp')
		{
			medalOldStatus = 5;
			medalStatus = 5;
	
			uniqueMedalChange(medalStatus+1);
			medal.loadGraphic(Paths.image('medals/medal_${medalStatus+1}', 'shared'));
		}

		updateScoreText();

		FlxG.sound.music.pause();
		vocals.pause();
		if(!isLegacyVocals) opponentVocals.pause();

		FlxG.sound.music.time = 0;
		vocals.time = 0;
		if(!isLegacyVocals) opponentVocals.time = 0;
		Conductor.songPosition = 0;

		startingSong = true;
		startedCountdown = false;
		updateTime = false;
		timeTxt.alpha = 0;
		timeBar.alpha = 0;
		timeBarBG.alpha = 0;
		if (stageUI == 'bp') timeBarBGOverlay.alpha = 0;
		songLength = 0;
		canResync = false;

		health = 1;

		for (note in notes.members)
		{
			if (note == null) continue;
			if (!note.alive) continue;
		
			var targetY:Float = FlxG.height + note.y;
			if (ClientPrefs.data.downScroll) targetY = note.y - FlxG.height;
			FlxTween.tween(note, {y: targetY}, 0.5,
			{
				ease: FlxEase.expoIn
			});
		}

		songSpeed = PlayState.SONG.speed;
		songSpeedOpponent = PlayState.SONG.speed;
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
				songSpeedOpponent = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
				songSpeedOpponent = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		camGame.alpha = 1;
		camHUD.alpha = 1;
		camOverlayHUD.alpha = 1;
		camNotes.alpha = 1;
		camOther.alpha = 1;

		currentCameraZoom = 1.0;
		cameraBopMultiplier = 1.0;

		defaultHUDCameraZoom = 1.0;
		camHudBopMult = 1.0;

		defaultNotesCameraZoom = 0.95;
		camNotesBopMult = 1.0;

		camZoomingDecay = 1;
		camZoomingDecayHud = 1;

		cameraBopIntensity = 1.015;
		hudCameraZoomIntensity = 0.015 * 2.0;
		cameraZoomRate = 4;

		if(!ClientPrefs.data.optimize) setupCameraToSong();
		resetCamera();

		stagesFunc(function(stage:BaseStage) stage.songRestartPost());
		callOnScripts('onSongRestartPost');

		refresh();

		// so the song doesn't start too early :D
		var vwooshDelay:Float = 0.5;

		vwooshTimer = new FlxTimer().start(vwooshDelay, function(_) {
			needsToReset = true;
			updateTime = true;
			canResync = true;
			generateNotes(true);

			if(eventNotes.length > 0)
			{
				for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
				eventNotes.sort(sortByTime);
			}

			if (eventNotes.length > 0) checkEventNote();

			refresh();

			startCountdown();
		});
	}

	public var needsToReset:Bool = false;
	public function startCountdown()
	{
		if(startedCountdown) {
			callOnScripts('onStartCountdown');
			return false;
		}

		skipCountdown = SONG.skipCountdown;

		//when first song in week or freeplay one ALWAYS go true if data one is null
		if (isFirstSongInCampaign)
			skipArrowStartTween = true;
		else
			skipArrowStartTween = false;

		skipArrowStartTween = SONG.skipArrowTween;

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if(ret != LuaUtils.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			canPause = true;
			
			if (!needsToReset)
			{
				generateStaticArrows(0);
				generateStaticArrows(1);

				if (SONG.swapNotes)
				{
					if(!ClientPrefs.data.middleScroll && PlayState.SONG.strumOffset != 'Forced MiddleScroll')
					{
						for (i in 0...playerStrums.length) {
							var ogDadStrums = opponentStrums.members[i].x;
							var ogBfStrums = playerStrums.members[i].x;
		
							playerStrums.members[i].x = ogDadStrums;
							opponentStrums.members[i].x = ogBfStrums;
						}
					}
				}

				if(opponentMode) //do this again so it will be consisten
				{
					if(!ClientPrefs.data.middleScroll && PlayState.SONG.strumOffset != 'Forced MiddleScroll')
					{
						for (i in 0...playerStrums.length) {
							var ogDadStrums = opponentStrums.members[i].x;
							var ogBfStrums = playerStrums.members[i].x;
		
							playerStrums.members[i].x = ogDadStrums;
							opponentStrums.members[i].x = ogBfStrums;
						}
					}
				}

				for (i in 0...playerStrums.length) {
					setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
					setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y + ((!isStoryMode && !skipArrowStartTween) ? 25 : 0));
	
					//same thing but can be updated any time for modcharts so it wont override default one if needs
					setOnScripts('curPlayerStrumX' + i, playerStrums.members[i].x);
					setOnScripts('curPlayerStrumY' + i, playerStrums.members[i].y + ((!isStoryMode && !skipArrowStartTween) ? 25 : 0));
				}
				for (i in 0...opponentStrums.length) {
					setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
					setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y + ((!isStoryMode && !skipArrowStartTween) ? 25 : 0));
	
					//same thing but can be updated any time for modcharts so it wont override default one if needs
					setOnScripts('curOpponentStrumX' + i, opponentStrums.members[i].x);
					setOnScripts('curOpponentStrumY' + i, opponentStrums.members[i].y + ((!isStoryMode && !skipArrowStartTween) ? 25 : 0));
					//if(ClientPrefs.data.middleScroll) opponentStrums.members[i].visible = false;
				}
			}
			else
			{
				for (i in 0...playerStrums.length) {
					playerStrums.members[i].alpha = 1;

					playerStrums.members[i].y = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
				}
				
				for (i in 0...opponentStrums.length) {
					opponentStrums.members[i].y = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;

					if(!ClientPrefs.data.opponentStrums || PlayState.SONG.opponentDisabled)
						opponentStrums.members[i].alpha = 0
					else if(ClientPrefs.data.middleScroll || PlayState.SONG.strumOffset == 'Forced MiddleScroll')
						opponentStrums.members[i].alpha = 0.35;
				    else
						opponentStrums.members[i].alpha = 1;
				}


				persistentUpdate = true;
				persistentDraw = true;

				canPause = true;
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted');

			var swagCounter:Int = 0;
			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);

				moveCameraSection();
				reloading = false;

				if(needsToReset)
				{
					//FlxG.sound.music.play();
					@:privateAccess
					FlxG.sound.playMusic(inst._sound, 1, false);
					FlxG.sound.music.pitch = playbackRate;
					FlxG.sound.music.onComplete = finishSong.bind();

					vocals.play();
					if(!isLegacyVocals) opponentVocals.play();

					needsToReset = false;
				}

				new FlxTimer().start(0.001, function(tmr:FlxTimer) //so it can be disabled be optioned
				{
					if (FlxG.camera.zoom < 1.7 && cameraZoomRate != 999 && ClientPrefs.data.camZooms)
					{
						// Set zoom multiplier for camera bop.
						cameraBopMultiplier = cameraBopIntensity;
						// HUD camera zoom still uses old system. To change. (+3%)
						camHudBopMult += hudCameraZoomIntensity;
						camNotesBopMult += hudCameraZoomIntensity;
						
						if(shakeBeat)
						{
							camGame.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
							camHUD.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
							camOverlayHUD.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
							camNotes.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
						}
					}
				});

				if (PlayState.SONG.showYOUtext)
					textYOUappear();

				if (PlayState.SONG.fadeOutStart && curSong != 'Scam' && !ClientPrefs.data.optimize)
				{
					if(curSong == 'Fire Thoser' && opponentMode)
					{
						if(PlayState.SONG.fadeCount)
						{
							FlxG.camera.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
						}
					}
					else
					{
						if(PlayState.SONG.fadeCount)
						{
							if (!PlayState.SONG.inFrontFade)
								FlxG.camera.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
							else
								camOverlayHUD.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
						}
					}
				}

				moveCameraSection();
				reloading = false;

				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);

				moveCameraSection();
				reloading = false;

				if(needsToReset)
				{
					//FlxG.sound.music.play();
					@:privateAccess
					FlxG.sound.playMusic(inst._sound, 1, false);
					FlxG.sound.music.pitch = playbackRate;
					FlxG.sound.music.onComplete = finishSong.bind();

					vocals.play();
					if(!isLegacyVocals) opponentVocals.play();

					needsToReset = false;
				}

				new FlxTimer().start(0.001, function(tmr:FlxTimer) //so it can be disabled be optioned
				{
					if (FlxG.camera.zoom < 1.7 && cameraZoomRate != 999 && ClientPrefs.data.camZooms)
					{
						// Set zoom multiplier for camera bop.
						cameraBopMultiplier = cameraBopIntensity;
						// HUD camera zoom still uses old system. To change. (+3%)
						camHudBopMult += hudCameraZoomIntensity;
						camNotesBopMult += hudCameraZoomIntensity;
						
						if(shakeBeat)
						{
							camGame.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
							camHUD.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
							camOverlayHUD.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
							camNotes.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
						}
					}
				});

				if (PlayState.SONG.showYOUtext)
					textYOUappear();

				if (PlayState.SONG.fadeOutStart && curSong != 'Scam' && !ClientPrefs.data.optimize)
				{
					if(curSong == 'Fire Thoser' && opponentMode)
					{
						if(PlayState.SONG.fadeCount)
							FlxG.camera.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
					}
					else
					{
						if(PlayState.SONG.fadeCount)
						{
							if (!PlayState.SONG.inFrontFade)
								FlxG.camera.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
							else
								camOverlayHUD.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
						}
					}
				}

				moveCameraSection();
				reloading = false;

				return true;
			}
			moveCameraSection();

			reloading = false;

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				characterBopper(tmr.loopsLeft);

				//tbh hated that one
				iconP1.scale.set(boyfriend.iconScale + customBopOffset);
				iconP2.scale.set(dad.iconScale + customBopOffset);

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				var introImagesArray:Array<String> = switch(stageUI) {
					case "pixel": ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel'];
					case "normal": ["ready", "set" ,"go"];
					default: ['${uiPrefix}UI/ready${uiPostfix}', '${uiPrefix}UI/set${uiPostfix}', '${uiPrefix}UI/go${uiPostfix}'];
				}
				introAssets.set(stageUI, introImagesArray);

				var introAlts:Array<String> = introAssets.get(stageUI);
				var antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelStage);
				var tick:Countdown = THREE;

				switch (swagCounter)
				{
					case 0:
						tick = THREE;
					case 1:
						if (!SONG.quietCountdown)
						{
							countdownReady = createCountdownSprite(introAlts[0], antialias);
							FunkinSound.playOnce(Paths.sound('bash' + introSoundsSuffix), 0.6);
						}
						tick = TWO;
					case 2:
						if (!SONG.quietCountdown)
						{
							countdownSet = createCountdownSprite(introAlts[1], antialias);
							FunkinSound.playOnce(Paths.sound('bash' + introSoundsSuffix), 0.6);
						}
						tick = ONE;
					case 3:
						if (!SONG.quietCountdown)
						{
							countdownGo = createCountdownSprite(introAlts[2], antialias);
							FunkinSound.playOnce(Paths.sound('rap' + introSoundsSuffix), 0.6);
						}
						tick = GO;
					case 4:
						tick = START;

						if(needsToReset)
						{
							//FlxG.sound.music.play();
							@:privateAccess
							FlxG.sound.playMusic(inst._sound, 1, false);
							FlxG.sound.music.pitch = playbackRate;
							FlxG.sound.music.onComplete = finishSong.bind();

							vocals.play();
							if(!isLegacyVocals) opponentVocals.play();

							needsToReset = false;
						}

						new FlxTimer().start(0.001, function(tmr:FlxTimer) //so it can be disabled be optioned
						{
							if (FlxG.camera.zoom < 1.7 && cameraZoomRate != 999 && ClientPrefs.data.camZooms)
							{
								// Set zoom multiplier for camera bop.
								cameraBopMultiplier = cameraBopIntensity;
								// HUD camera zoom still uses old system. To change. (+3%)
								camHudBopMult += hudCameraZoomIntensity;
								camNotesBopMult += hudCameraZoomIntensity;
							
								if(shakeBeat)
								{
									camGame.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
									camHUD.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
									camOverlayHUD.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
									camNotes.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
								}
							}
						});

						if (PlayState.SONG.showYOUtext)
							textYOUappear();

						if (PlayState.SONG.fadeOutStart && curSong != 'Scam' && !ClientPrefs.data.optimize)
						{
							if(curSong == 'Fire Thoser' && opponentMode)
							{
								if(PlayState.SONG.fadeCount)
									FlxG.camera.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
							}
							else
							{
								if(PlayState.SONG.fadeCount)
								{
									if (!PlayState.SONG.inFrontFade)
										FlxG.camera.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
									else
										camOverlayHUD.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
								}
							}
						}
				}

				if(!skipArrowStartTween)
				{
					notes.forEachAlive(function(note:Note) {
						if((ClientPrefs.data.opponentStrums && !PlayState.SONG.opponentDisabled) || note.mustPress)
						{
							note.copyAlpha = false;
							note.alpha = note.multAlpha;
							if((ClientPrefs.data.middleScroll || PlayState.SONG.strumOffset == 'Forced MiddleScroll') && !note.mustPress)
								note.alpha *= 0.35;
						}
					});
				}

				stagesFunc(function(stage:BaseStage) stage.countdownTick(tick, swagCounter));
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHScript('onCountdownTick', [tick, swagCounter]);

				swagCounter += 1;
			}, 5);
		}
		return true;
	}

	// Stores Count Sprites in a group
	public var countGroup:FlxSpriteGroup;
	inline private function createCountdownSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite();

		var animToFind:String = Paths.getPath(Language.getFileTranslation('images/$image') + '.xml', TEXT);

		if (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind))
		{
			spr.frames = Paths.getSparrowAtlas(image);
			spr.animation.addByPrefix(image, image, 24, false);
			spr.animation.play(image);
		}
		else
		{
			spr.loadGraphic(Paths.image(image));
		}

		//spr.cameras = [camOther];
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (PlayState.isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		countGroup.add(spr);

		if(stageUI == 'bp')
		{
			if(image != 'bpUI/go')
			{
				spr.scale.set(0.9, 0.9);
				FlxTween.tween(spr.scale, {x: 1, y: 1}, Conductor.crochet / 1000, {
					ease: FlxEase.linear,
				});
			}
			else
				spr.scale.set(1.2, 1.2);
					
			new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				countGroup.remove(spr);
				spr.destroy();
			});
		}
		else
		{
			if (PlayState.isPixelStage)
			{
				new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
				{
					if(spr != null)
					{
						countGroup.remove(spr);
						spr.destroy();
					}
				});
			}
			else if(stageUI == "normal" && image == "go")
			{
				goTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
				{
					if(spr != null)
					{
						FlxTween.tween(spr.scale, {x: 0, y: 0}, Conductor.stepCrochet * 2 / 1000 / playbackRate, {
							ease: FlxEase.expoIn,
							onComplete: function(twn:FlxTween)
							{
								countGroup.remove(spr);
								spr.destroy();
							}
						});
					}
				});
			}
			else
			{
				if(spr != null)
				{
					FlxTween.tween(spr, {y: spr.y + 50, alpha: 0}, Conductor.crochet / 1000 / playbackRate, {
						ease: FlxEase.cubeIn,
						onComplete: function(twn:FlxTween)
						{
							countGroup.remove(spr);
							spr.destroy();
						}
					});
				}
			}
		}
		return spr;
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				if (daNote.parent == null) 
				{
					if(daNote.tail.length > 0) 
					{
						for(childNote in daNote.tail) {
							childNote.active = false;
							childNote.visible = false;
							childNote.ignoreNote = true;
						}
					}
				}

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				if (daNote.parent == null) 
				{
					if(daNote.tail.length > 0) 
					{
						for(childNote in daNote.tail) {
							childNote.active = false;
							childNote.visible = false;
							childNote.ignoreNote = true;
						}
					}
				}
				
				invalidateNote(daNote);
			}
			--i;
		}
	}

	// fun fact: Dynamic Functions can be overriden by just doing this
	// `updateScore = function(miss:Bool = false) { ... }
	// its like if it was a variable but its just a function!
	// cool right? -Crow
	public dynamic function updateScore(miss:Bool = false, scoreBop:Bool = true)
	{
		var ret:Dynamic = callOnScripts('preUpdateScore', [miss], true);
		if (ret == LuaUtils.Function_Stop)
			return;

		updateScoreText();

		callOnScripts('onUpdateScore', [miss]);
	}

	public dynamic function updateScoreText()
	{
		var str:String = '?';
		if(totalPlayed != 0)
		{
			var percent:Float = CoolUtil.floorDecimal(ratingPercent * 100, 2);
			str = '(${percent}%) - ' + Language.getPhrase(ratingFC);
		}

		var tempScore:String;
		if(!instakillOnMiss) tempScore = Language.getPhrase('score_text', 'Score: {1} | Misses: {2} | Accuracy: {3}', [FlxStringUtil.formatMoney(songScore, false, true), songMisses, str]);
		else tempScore = Language.getPhrase('score_text_instakill', 'Score: {1} | Accuracy: {2}', [FlxStringUtil.formatMoney(songScore, false, true), str]);
		scoreTxt.text = tempScore;

		if (stageUI == 'bp')
		{
			tempScore = 'Score: ' + FlxStringUtil.formatMoney(songScore, false, true)
				+ '\nAccuracy: ' + str
				+ '\nMisses: ' + songMisses;
		
			accuracyShit.text = 'Rating: ' + ratingName;
		
			scoreTxt_BP.text = tempScore;

			if(scoreTxtTween != null)scoreTxtTween.cancel();

			accuracyShit.scale.x = 1.075;
			accuracyShit.scale.y = 1.075;
		
			scoreTxtTween = FlxTween.tween(accuracyShit.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
	}

	public dynamic function fullComboFunction()
	{
		var sicks:Int = ratingsData[0].hits;
		var goods:Int = ratingsData[1].hits;
		var bads:Int = ratingsData[2].hits;
		var shits:Int = ratingsData[3].hits;

		ratingFC = "";
		if(songMisses == 0)
		{
			if (bads > 0 || shits > 0) ratingFC = 'FC';
			else if (goods > 0) ratingFC = 'GFC';
			else if (sicks > 0) ratingFC = 'SFC';
		}
		else {
			if (songMisses < 10) ratingFC = 'SDCB';
			else ratingFC = 'Clear';
		}

		//TO DO: this will be for future win screen shit
		//for now it's here for other mods and stuff

		// calculate shit
		if(stageUI == 'bp')
		{
			if(changedDifficulty) 
			{
				medalStatus = 5; //хуй а не фри мани	
		
				if (medalOldStatus != medalStatus)
				{
					medalOldStatus = medalStatus;
					uniqueMedalChange(medalStatus+1);
					medal.loadGraphic(Paths.image('medals/medal_${medalStatus+1}', 'shared'));
				}
				return;
			}
		
			if (sicks == totalNotes)
			{
				medalStatus = 0;
				if (medalOldStatus != medalStatus)
				{
					medalOldStatus = medalStatus;
					uniqueMedalChange(medalStatus+1);
					medal.loadGraphic(Paths.image('medals/medal_${medalStatus+1}', 'shared'));
				}
				return;
			}
		
			// calculate shit
			// Grade % (only good and sick), 1.00 is a full combo
			var grade = (sicks + goods - songMisses) / totalNotes;
			// Clear % (including bad and shit). 1.00 is a full clear but not a full combo
			var clear = (songHits) / totalNotes;
		
			if (grade == 1.00)
				medalStatus = 1;
			else if (grade >= 0.80)
				medalStatus = 2;
			else if (grade >= 0.60)
				medalStatus = 3;
			else if (grade >= 0.50)
				medalStatus = 4;
			else
				medalStatus = 5;
		
			if (medalOldStatus != medalStatus)
			{
				medalOldStatus = medalStatus;
				uniqueMedalChange(medalStatus+1);
				medal.loadGraphic(Paths.image('medals/medal_${medalStatus+1}', 'shared'));
			}
		}

		if (sicks == totalNotes)
		{
			rank = 0;
			return;
		}

		// Grade % (only good and sick), 1.00 is a full combo
		var grade = (sicks + goods - songMisses) / totalNotes;
		// Clear % (including bad and shit). 1.00 is a full clear but not a full combo
		var clear = (songHits) / totalNotes;

		if (grade == 1.00)
			rank = 1;
		else if (grade >= 0.80)
			rank = 2;
		else if (grade >= 0.60)
			rank = 3;
		else if (grade >= 0.50)
			rank = 4;
	}

	public function doScoreBop():Void {
		if(!ClientPrefs.data.scoreZoom)
			return;

		if (stageUI == 'bp') return;

		if(scoreTxtTween != null)
			scoreTxtTween.cancel();

		scoreTxt.scale.x = 1.075;
		scoreTxt.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});
	}

	public function doSubtitlesBop():Void {
		if(subtitlesTxtTween != null)
			subtitlesTxtTween.cancel();

		subtitlesTxt.scale.x = 1.075;
		subtitlesTxt.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(subtitlesTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				subtitlesTxtTween = null;
			}
		});
	}

	private inline static var MAX_32_PRECISION = 4294967296;

	public static function fromFloat(f:Float):Int64 { //на нах
		return Int64.make(Std.int(f/MAX_32_PRECISION), Std.int(f-(f/MAX_32_PRECISION)));
	}

	public static function toFloat(i:Int64):Float {

		return (Int64.getHigh(i) * MAX_32_PRECISION + Int64.getLow(i));
	}

	public function setSongTime(time:Float)
	{
		FlxG.sound.music.pause();
		vocals.pause();
		if(!isLegacyVocals) opponentVocals.pause();

		if(videoCutscene != null && videoCutscene.videoSprite != null && playingVideo)
		{
			var expectedVideoTime:Float = Conductor.songPosition - Conductor.offset - curVideoTimestamp;
   			var videoError:Float = toFloat(videoCutscene.videoSprite.bitmap.time) - expectedVideoTime;

			if (Math.abs(videoError) > 550)
			{
				videoCutscene.videoSprite.pause();
				videoCutscene.videoSprite.bitmap.time = fromFloat(expectedVideoTime);
				videoCutscene.videoSprite.resume();
			}
		}

		FlxG.sound.music.time = time - Conductor.offset;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition < vocals.length)
		{
			vocals.time = time - Conductor.offset;
			vocals.pitch = playbackRate;
			vocals.play();
		}
		else vocals.pause();

		if(!isLegacyVocals)
		{
			if (Conductor.songPosition < opponentVocals.length)
			{
				opponentVocals.time = time - Conductor.offset;
				opponentVocals.pitch = playbackRate;
				opponentVocals.play();
			}
			else opponentVocals.pause();
		}
	
		Conductor.songPosition = time;
	}

	public function startNextDialogue() {
		dialogueCount++;
		callOnScripts('onNextDialogue', [dialogueCount]);
	}

	public function skipDialogue() {
		callOnScripts('onSkipDialogue', [dialogueCount]);
	}

	var finishLength:Float;
	function startSong():Void
	{
		startingSong = false;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		if(!isLegacyVocals) opponentVocals.play();

		setSongTime(Math.max(0, startOnTime - 500) + Conductor.offset);
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			if(!isLegacyVocals) opponentVocals.pause();
		}

		stagesFunc(function(stage:BaseStage) stage.startSong());

		if(curSong != 'boot' && curSong != 'Scam' && curSong != 'FIRE' && curSong != 'Triple Trouble' && curSong != 'THE END' && curSong != 'Hell Valley')
			canSkip = true;

		if (!FlxG.save.data.playedSongs.contains(CoolUtil.spaceToDash(SONG.song.toLowerCase())))
		{
			canSkip = false;
			FlxG.save.data.playedSongs.push(CoolUtil.spaceToDash(SONG.song.toLowerCase()));
		}
		else if(Conductor.songPosition >= skipTime)
			canSkip = false;

		if(canSkip == true)
			FlxTween.tween(skipText, {alpha: 0.25}, 0.2);

		if (PlayState.SONG.fadeOutStart && curSong != 'Scam' && !ClientPrefs.data.optimize)
		{
			if(curSong == 'Fire Thoser' && opponentMode)
			{
				if(!PlayState.SONG.fadeCount)
					FlxG.camera.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
			}
			else
			{
				if(!PlayState.SONG.fadeCount)
				{
					if (!PlayState.SONG.inFrontFade)
						FlxG.camera.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
					else
						camOverlayHUD.fade(FlxColor.BLACK, PlayState.SONG.fadeDuration, true, null, true);
				}
			}
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		if (stageUI == 'bp') FlxTween.tween(timeBarBGOverlay, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		if (PlayState.SONG.timeBarFake != null && PlayState.SONG.timeBarFake != 0)
			songLength = PlayState.SONG.timeBarFake * 1000;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence (with Time Left)
		if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.displayName == null ? SONG.song : SONG.displayName + " (" + storyDifficultyText + ")", '', true, songLength, SONG.song.toLowerCase());
		#end
		finishLength = songLength - 1000;
		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart');
	}

	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	private var totalColumns: Int = 4;

	public var isLegacyVocals: Bool = false;

	private function generateSong():Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = PlayState.SONG.speed;
		songSpeedOpponent = PlayState.SONG.speed;
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
				songSpeedOpponent = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
				songSpeedOpponent = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		if(opponentMode)
			SONG.disableDadRGB = false;

		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;

		if(FlxG.save.data.startedArg)
		{
			if(songName == ClientPrefs.data.codes[0][0])
			{
				var text:FlxText = new FlxText(FlxG.random.float(BF_X - 100, BF_X + 400), FlxG.random.float(BF_Y + 200, BF_Y + 400), 300, ClientPrefs.data.codes[0][1], 64);
				text.color = FlxColor.RED;
				text.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, 0xFF000000);
				text.zIndex = 1100;
				add(text);
			}
	
			if(songName == ClientPrefs.data.codes[1][0])
			{
				var text:FlxText = new FlxText(FlxG.random.float(BF_X - 100, BF_X + 400), FlxG.random.float(BF_Y + 200, BF_Y + 400), 300, ClientPrefs.data.codes[1][1], 64);
				text.color = FlxColor.GREEN;
				text.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, 0xFF000000);
				text.zIndex = 1100;
				add(text);
			}
	
			if(songName == ClientPrefs.data.codes[2][0])
			{
				var text:FlxText = new FlxText(FlxG.random.float(BF_X - 100, BF_X + 400), FlxG.random.float(BF_Y + 200, BF_Y + 400), 300, ClientPrefs.data.codes[2][1], 64);
				text.color = FlxColor.BLUE;
				text.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST);
				text.zIndex = 1100;
				add(text);
			}
		}

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		try
		{
			if (songData.needsVoices)
			{
				var playerVocals = Paths.voices(songData.song, (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile, Difficulty.getDiffString().toLowerCase(), Difficulty.getVarString().toLowerCase());
				vocals.loadEmbedded(playerVocals != null ? playerVocals : Paths.voices(songData.song));
				
				var oppVocals = Paths.voices(songData.song, (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile, Difficulty.getDiffString().toLowerCase(), Difficulty.getVarString().toLowerCase());
				if(oppVocals != null && oppVocals.length > 0) 
					opponentVocals.loadEmbedded(oppVocals);
				else 
					isLegacyVocals = true;
			}
		}
		catch (e:Dynamic) {}


		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);

		inst = new FlxSound();
		try
		{
			inst.loadEmbedded(Paths.inst(songData.song, Difficulty.getDiffString().toLowerCase(), Difficulty.getVarString().toLowerCase()));
		}
		catch (e:Dynamic) {}
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		noteGroup.add(notes);

		generateNotes();
		generatedMusic = true;
	}

	public function generateNotes(reload:Bool = false)
	{
		var songData = SONG;
		Conductor.bpm = songData.bpm;

		if(reload)
		{
			/*FlxG.sound.music.play();
			vocals.play();
			opponentVocals.play();

			stepHit();
			beatHit();
			sectionHit();*/

			lastBeatHit = -1;
			lastStepHit = -1;

			KillNotes();

			noteTypes = [];
			eventsPushed = []; //TO-DO: make this not getting reset and not do FlxTimer crash

			totalNotes = 0;

			if(curSong != 'boot' && curSong != 'Scam' && curSong != 'FIRE' && curSong != 'Triple Trouble' && curSong != 'THE END')
				canSkip = true;
		}

		try
		{
			var eventsChart:SwagSong = Song.getChart('events', songName);
			if(eventsChart != null)
				for (event in eventsChart.events) //Event Notes
					for (i in 0...event[1].length)
						makeEvent(event, i);
		}
		catch(e:Dynamic) {}

		var oldNote:Note = null;
		var sectionsData:Array<SwagSection> = PlayState.SONG.notes;
		var ghostNotesCaught:Int = 0;
		var daBpm:Float = Conductor.bpm;
	
		for (section in sectionsData)
		{
			if (section.changeBPM != null && section.changeBPM && section.bpm != null && daBpm != section.bpm)
				daBpm = section.bpm;

			for (i in 0...section.sectionNotes.length)
			{
				final songNotes: Array<Dynamic> = section.sectionNotes[i];
				var spawnTime: Float = songNotes[0];
				var noteColumn: Int = Std.int(songNotes[1] % totalColumns);
				var holdLength: Float = songNotes[2];
				var noteType: String = !Std.isOfType(songNotes[3], String) ? Note.defaultNoteTypes[songNotes[3]] : songNotes[3];
				var sustainType: String = songNotes[4];
				if (Math.isNaN(holdLength))
					holdLength = 0.0;

				var altAnimSuffix: String = songNotes[5];
				var customSongDur: Float = songNotes[6];
				var altHey: String = songNotes[7];

				//same thing as in chart editor
				if(songNotes[8] == '0' || songNotes[8] == null) songNotes[8] = true;
				var lightStrumCheck: Bool = songNotes[8];

				var noAnimationCheck: Bool = songNotes[9];

				var ghostType: String = songNotes[10];

				if(songNotes[11] == '0' || songNotes[11] == null) songNotes[11] = true;
				var catchNote: Bool = songNotes[11];

				var noMissAnimationCheck: Bool = songNotes[12];
				var invisibleNote: Bool = songNotes[13];

				var gottaHitNote:Bool = (songNotes[1] < totalColumns);

				if (i != 0) {
					// CLEAR ANY POSSIBLE GHOST NOTES
					// Iterate backwards because we mutate unspawnNotes inside the
					// loop. The previous forward 'for (evilNote in unspawnNotes)'
					// pattern advanced by index, so each remove() shifted later
					// elements down and a duplicate could survive un-checked.
					var k:Int = unspawnNotes.length;
					while (--k >= 0) {
						final evilNote:Note = unspawnNotes[k];
						if (evilNote == null) continue;
						var matches: Bool = (noteColumn == evilNote.noteData && gottaHitNote == evilNote.mustPress && evilNote.noteType == noteType);
						if (matches && Math.abs(spawnTime - evilNote.strumTime) < flixel.math.FlxMath.EPSILON) {
							if (evilNote.tail.length > 0)
								for (tail in evilNote.tail)
								{
									tail.destroy();
									unspawnNotes.remove(tail);
								}

							if(!opponentMode)
								if (evilNote.mustPress == true && evilNote.lowPriority == false  && evilNote.autoplay == false && evilNote.hitCausesMiss == false && evilNote.isSustainNote == false && evilNote.noteType != 'Phantom Note')
									totalNotes -= 1;

							if(opponentMode)
								if (evilNote.mustPress == false && evilNote.lowPriority == false  && evilNote.autoplay == false && evilNote.hitCausesMiss == false && evilNote.isSustainNote == false && evilNote.noteType != 'Phantom Note')
									totalNotes -= 1;

							evilNote.destroy();
							unspawnNotes.remove(evilNote);
							ghostNotesCaught++;
						}
					}
				}

				var swagNote:Note = new Note(spawnTime, noteColumn, oldNote, false, false, null, gottaHitNote);
				var isAlt: Bool = section.altAnim && !gottaHitNote;
				swagNote.gfNote = (section.gfSection && gottaHitNote == section.mustHitSection);

				if(altAnimSuffix == '0' || altAnimSuffix == null || altAnimSuffix == '') //WHAT THE FUCK HOW IT'S FUCKING ZERO, IT TOOK ME HOURS TO FIGURE OUT WHY ANIMATIONS DIDN'T PLAYED
					swagNote.animSuffix = isAlt ? "-alt" : "";
				else
					swagNote.animSuffix = isAlt ? "-alt" : altAnimSuffix;

				swagNote.customSingTime = customSongDur;
				swagNote.heyAnim = altHey;
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = holdLength;
				swagNote.noteType = noteType;
				swagNote.sustainType = sustainType;

				if(SONG.disableDadRGB && !swagNote.mustPress) swagNote.dadRGBdisable();

				swagNote.lightStrum = lightStrumCheck;
				swagNote.noAnimation = noAnimationCheck;

				swagNote.ghostType = ghostType;

				swagNote.noMissAnimation = noMissAnimationCheck;
				swagNote.catchNote = catchNote;

				swagNote.visible = !invisibleNote;

				swagNote.isInvisible = !swagNote.visible;

				if(swagNote.isInvisible && opponentMode)
					swagNote.autoplay = true;

				if(swagNote.noteType == 'Jalapeno Note BOOM SOUND' && opponentMode)
				{
					swagNote.autoplay = true;
					swagNote.visible = false;
					swagNote.isInvisible = true;
				}
				
				swagNote.scrollFactor.set();

				if(!opponentMode)
					if (swagNote.mustPress == true && swagNote.lowPriority == false && swagNote.autoplay == false && swagNote.hitCausesMiss == false && swagNote.isSustainNote == false && swagNote.noteType != 'Phantom Note')
						totalNotes++;

				if(opponentMode)
					if (swagNote.mustPress == false && swagNote.lowPriority == false && swagNote.autoplay == false && swagNote.hitCausesMiss == false && swagNote.isSustainNote == false && swagNote.noteType != 'Phantom Note')
						totalNotes++;

				unspawnNotes.push(swagNote);

				var curStepCrochet:Float = 60 / daBpm * 1000 / 4.0;
				final roundSus:Int = Math.round(swagNote.sustainLength / curStepCrochet);
				if(roundSus > 0)
				{
					for (susNote in 0...roundSus)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(spawnTime + (curStepCrochet * susNote), noteColumn, oldNote, true, false, null, swagNote.mustPress);
						sustainNote.animSuffix = swagNote.animSuffix;
						sustainNote.customSingTime = swagNote.customSingTime;
						sustainNote.heyAnim = swagNote.heyAnim;
						sustainNote.mustPress = swagNote.mustPress;

						if(SONG.disableDadRGB && !swagNote.mustPress) sustainNote.dadRGBdisable();

						sustainNote.gfNote = swagNote.gfNote;
						sustainNote.noteType = swagNote.noteType;
						sustainNote.sustainType = swagNote.sustainType;
						sustainNote.lightStrum = swagNote.lightStrum;
						sustainNote.noAnimation = swagNote.noAnimation;
						sustainNote.ghostType = swagNote.ghostType;
						sustainNote.noMissAnimation = swagNote.noMissAnimation;
						sustainNote.catchNote = swagNote.catchNote;
						sustainNote.visible = swagNote.visible;
						sustainNote.isInvisible = swagNote.isInvisible;
						if(swagNote.isInvisible && opponentMode)
							sustainNote.autoplay = true;
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						swagNote.tail.push(sustainNote);

						sustainNote.correctionOffset = swagNote.height / 2;
						if(!PlayState.isPixelStage)
						{
							if(oldNote.isSustainNote)
							{
								oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
								oldNote.scale.y /= playbackRate;
								oldNote.resizeByRatio(curStepCrochet / Conductor.stepCrochet);
							}

							if(ClientPrefs.data.downScroll)
								sustainNote.correctionOffset = 0;
						}
						else if(oldNote.isSustainNote)
						{
							oldNote.scale.y /= playbackRate;
							oldNote.resizeByRatio(curStepCrochet / Conductor.stepCrochet);
						}

						if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
						else if(ClientPrefs.data.middleScroll || PlayState.SONG.strumOffset == 'Forced MiddleScroll')
						{
							sustainNote.x += 310;
							if(noteColumn > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.data.middleScroll || PlayState.SONG.strumOffset == 'Forced MiddleScroll')
				{
					swagNote.x += 310;
					if(noteColumn > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if(!noteTypes.contains(swagNote.noteType))
					noteTypes.push(swagNote.noteType);

				oldNote = swagNote;
			}
		}
		trace('["${SONG.song.toUpperCase()}" CHART INFO]: Ghost Notes Cleared: $ghostNotesCaught');

		if(PlayState.SONG.swapMustPlay)
		{
			for (note in unspawnNotes) 
				note.mustPress = !note.mustPress;
		}

		if(opponentMode)
		{
			for (note in unspawnNotes) 
			{
				if(note.noteType != 'Jalapeno Note BOOM SOUND')
					note.mustPress = !note.mustPress;
			}
		}

		for (event in songData.events) //Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);

		unspawnNotes.sort(sortByTime);

		if (unspawnNotes[0] != null)
		{
			for (i in unspawnNotes)
				if(!i.ignoreNote && !i.isInvisible && !i.hitCausesMiss && !i.lowPriority && i.noteType != 'Phantom Note') //sorry for hardcoding, lua sucks
				{
					skipTime = i.strumTime - Conductor.crochet * 4;
					break;
				}
		}
	}

	// called only once per different event (Used for precaching)
	//for some reason removing eventsPushed array crashes game after clear so that the current solution
	private var eventsStored1:Bool = false;
	private var eventsStored2:Bool = false;
	function eventPushed(event:EventNote) {
		eventPushedUnique(event);
		if(eventsPushed.contains(event.event)) {
			return;
		}

		switch(event.event)
		{
			case "Solid Graphic Behind Characters":
				if(ClientPrefs.data.optimize) return;
				if (eventsStored1) return;

				solidColBeh = new FunkinSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeSolidColor(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
				solidColBeh.scale.set(5,5);
				solidColBeh.alpha = 0.001;
				addBehindGF(solidColBeh);

				eventsStored1 = true;

			case 'Subtitles': //creates at event so
				if(!ClientPrefs.data.subtitles) return;
				if (eventsStored2) return;
				
				subtitlesTxt = new FlxText(0, FlxG.height * 0.75, FlxG.width - 800, "", 24);
				subtitlesTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
				subtitlesTxt.scrollFactor.set();
				subtitlesTxt.borderSize = 1.25;
				subtitlesTxt.screenCenter(X);
				subtitlesTxt.alpha = 0;
				uiPostGroup.add(subtitlesTxt); //might add another camHUD overlay or backlay or whatever :p

				eventsStored2 = true;
		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		eventsPushed.push(event.event);
	}

	// called by every event with the same name
	function eventPushedUnique(event:EventNote) {
		switch(event.event) {
			case "Change Character":
				if(ClientPrefs.data.optimize) return;

				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					case 'second' | 'bro':
						charType = 3;
					default:
						var parsed:Null<Int> = Std.parseInt(event.value1);
						charType = (parsed != null) ? parsed : 0;

						if (Main.darnellMode && !opponentMode) event.value2 = 'darnell';

						if (Main.raldman && !opponentMode) event.value2 = 'raldeblan';

						switch(ClientPrefs.data.activeBfSkin)
						{
							case 'classic':
								switch(event.value2)
								{
									case 'bfnew' | 'coolassbf' | 'bf-zero' | 'bf-redrawn':
										event.value2 = 'bf';

									case 'bfASsad':
										event.value2 = 'bf-angry';

									case 'bf-pixel':
										event.value2 = 'bf-pixel-classic';
								}

							case 'mm':
								switch(event.value2)
								{
									case 'bf' | 'coolassbf' | 'bf-zero' | 'bf-redrawn' | 'bfASsad':
										event.value2 = 'bfnew';
					
									case 'P3-bf':
										event.value2 = 'bf-back';
					
									case 'P3-bf-flip':
										event.value2 = 'bf-back-flip';
					
									case 'bf-running':
										event.value2 = 'bf_demise';
								}

							case 'sonic-legacy':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'bfASsad':
										event.value2 = 'coolassbf';
								}

							case 'indie-cross':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
										event.value2 = 'bf-ic';
								}

							case 'zero':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'coolassbf' | 'bf-redrawn' | 'bfASsad':
										event.value2 = 'bf-zero';
								}

							case 'basement':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
										event.value2 = 'bf-basement';
								}

							case 'romstyle':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
										event.value2 = 'rom-bf';
								}

							case 'spaghetti':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'coolassbf' | 'bfASsad':
										event.value2 = 'bf-redrawn';

									case 'P3-bf':
										event.value2 = '1hbf';
					
									case 'P3-bf-flip':
										event.value2 = '1hbf-flip';
								}

							case 'downtown':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
										event.value2 = 'bf-osm';
								}

							case 'legacy':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
										event.value2 = 'bf-legacy';
								}

							case 'minus1':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										event.value2 = 'bf-minus';
								}

							case 'minus2':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										event.value2 = 'bf-minus-beta';
								}

							case 'minus3':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										event.value2 = 'bf-minus-prototype';
								}

							case 'badtime':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf':
										event.value2 = 'bf-badtime';

									case 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
										event.value2 = 'bf-badtime-scared';

									case 'P3-bf':
										event.value2 = 'bf-badtime-back';
					
									case 'P3-bf-flip':
										event.value2 = 'bf-badtime-back-flip';

									case 'bf-running':
										event.value2 = 'bf-badtime-run';

									case 'bf-pixel':
										event.value2 = 'bf-badtime-pixel';
								}

							case 'ourple':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
										event.value2 = 'bf_ourple';
								}

							case 'pixel':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running':
										event.value2 = 'bf-pixel';

									case 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
										event.value2 = 'bf-pixel-pissed';

									case 'P3-bf':
										event.value2  = 'P3-bf-pixel';
	
									case 'P3-bf-flip':
										event.value2  = 'P3-bf-flip-pixel';

									case 'bf-pixel':
										event.value2 = 'bf-pixel-classic';
								}

							case 'encore':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
										event.value2 = 'bf-encore';

									case 'bf-pixel':
										event.value2 = 'bf-pixel-sonic';
								}

							case 'romfriend':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										event.value2 = 'rf';
								}

							case 'gold':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										event.value2 = 'bf-golden';
								}

							case 'bp':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										event.value2 = 'bp';
								}

							case 'bad':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
										event.value2 = 'bf-bad';

									case 'bf-pixel':
										event.value2 = 'bf-bad-pixel';
								}

							case 'bp-dlc':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										event.value2 = 'bf-3d';
								}

							case 'ruby':
								switch(event.value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										event.value2 = 'ruby-bf';
								}
					}
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType, true, event.strumTime);

				if (charType != 1) return;
				
				for (note in notes.members)
				{
					if (!note.mustPress && note.canChangeRGB && note.strumTime >= event.strumTime)
					{
						if(!opponentMode)
						{
							var newDad:Character = new Character(0, 0, newCharacter);
							var arrOpp:Array<String>;
							arrOpp = newDad.opponentNoteColor[note.noteData];
							var extra_arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[note.noteData];
				
							if (note.noteData > -1 && newDad.opponentNoteColor.length >= 3)
							{
								note.rgbShader.r = CoolUtil.colorFromString(arrOpp[0]);
								note.rgbShader.g = CoolUtil.colorFromString(arrOpp[1]);
								if (newDad.curCharacter.startsWith('perec-hui'))
									note.rgbShader.b = extra_arr[0];
								else
									note.rgbShader.b = CoolUtil.colorFromString(arrOpp[2]);
							}
							else
							{
								note.rgbShader.r = 0xFFFF0000;
								note.rgbShader.g = 0xFF00FF00;
								note.rgbShader.b = 0xFF0000FF;
							}
						}
					}
				}

				for (note in unspawnNotes)
				{
					if (!note.mustPress && note.canChangeRGB && note.strumTime >= event.strumTime)
					{
						if(!opponentMode)
						{
							var newDad:Character = new Character(0, 0, newCharacter);
							var arrOpp:Array<String>;
							arrOpp = newDad.opponentNoteColor[note.noteData];
							var extra_arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[note.noteData];
			
							if (note.noteData > -1 && newDad.opponentNoteColor.length >= 3)
							{
								note.rgbShader.r = CoolUtil.colorFromString(arrOpp[0]);
								note.rgbShader.g = CoolUtil.colorFromString(arrOpp[1]);
								if (newDad.curCharacter.startsWith('perec-hui'))
									note.rgbShader.b = extra_arr[0];
								else
									note.rgbShader.b = CoolUtil.colorFromString(arrOpp[2]);
							}
							else
							{
								note.rgbShader.r = 0xFFFF0000;
								note.rgbShader.g = 0xFF00FF00;
								note.rgbShader.b = 0xFF0000FF;
							}
						}
					}
				}

			case 'Set Opponent Notes Color':
				var split0:Array<String> = event.value1.split(',');
				var split1:Array<String> = event.value2.split(',');
				var split2:Array<String> = event.value3.split(',');
				var split3:Array<String> = event.value4.split(',');

				var noteChange:Array<Array<String>> = [split0, split1, split2, split3];

				for (note in notes.members)
				{
					if (!note.mustPress && note.strumTime >= event.strumTime)
					{
						var arrOpp:Array<String>;
						arrOpp = noteChange[note.noteData];
			
						if (note.noteData > -1 && noteChange.length >= 3)
						{
							note.rgbShader.r = CoolUtil.colorFromString(arrOpp[0]);
							note.rgbShader.g = CoolUtil.colorFromString(arrOpp[1]);
							note.rgbShader.b = CoolUtil.colorFromString(arrOpp[2]);
						}
						else
						{
							note.rgbShader.r = 0xFFFF0000;
							note.rgbShader.g = 0xFF00FF00;
							note.rgbShader.b = 0xFF0000FF;
						}
					}
				}

				for (note in unspawnNotes)
				{
					if (!note.mustPress && note.strumTime >= event.strumTime)
					{
						var arrOpp:Array<String>;
						arrOpp = noteChange[note.noteData];
		
						if (note.noteData > -1 && noteChange.length >= 3)
						{
							note.rgbShader.r = CoolUtil.colorFromString(arrOpp[0]);
							note.rgbShader.g = CoolUtil.colorFromString(arrOpp[1]);
							note.rgbShader.b = CoolUtil.colorFromString(arrOpp[2]);
						}
						else
						{
							note.rgbShader.r = 0xFFFF0000;
							note.rgbShader.g = 0xFF00FF00;
							note.rgbShader.b = 0xFF0000FF;
						}
					}
				}

				if(event.value5 == 'GF')
				{
					for (note in unspawnNotes)
					{
						if (note.colored && note.gfNote && note.strumTime >= event.strumTime)
						{
							if(!opponentMode)
							{
								var arrGf:Array<String>;
								arrGf = gf.opponentNoteColor[note.noteData];
								
								if (arrGf != null && note.noteData > -1 && arrGf.length >= 3)
								{
									note.rgbShader.r = CoolUtil.colorFromString(arrGf[0]);
									note.rgbShader.g = CoolUtil.colorFromString(arrGf[1]);
									note.rgbShader.b = CoolUtil.colorFromString(arrGf[2]);
			
									// splash data and colors
									note.noteSplashData.r = CoolUtil.colorFromString(arrGf[0]);
									note.noteSplashData.g = CoolUtil.colorFromString(arrGf[1]);
								}
								else
								{
									note.rgbShader.r = 0xFFFF0000;
									note.rgbShader.g = 0xFF00FF00;
									note.rgbShader.b = 0xFF0000FF;
								}
							}
						}
					}
				}

			case 'Play Sound':
				Paths.sound(event.value1); //Precache sound

				
			#if VIDEOS_ALLOWED
			case 'Play Video':
				if(ClientPrefs.data.optimize) return;

				precacheVideo(event.value1, true, false, false);
			#end
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushedUnique(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true);
		if(returnedValue != null && returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2],
			value3: event[1][i][3],
			value4: event[1][i][4],
			value5: event[1][i][5]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [subEvent.event, 
			subEvent.value1 != null ? subEvent.value1 : '', 
			subEvent.value2 != null ? subEvent.value2 : '', 
			subEvent.value3 != null ? subEvent.value3 : '', 
			subEvent.value4 != null ? subEvent.value4 : '', 
			subEvent.value5 != null ? subEvent.value5 : '',
			subEvent.strumTime]);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		final cutoutSize = FullScreenScaleMode.gameCutoutSize.x / 2.5;

		if (opponentMode)
			if(PlayState.SONG.strumOffset == 'Player Focus') PlayState.SONG.strumOffset = 'Opponent Focus';
		else
			if(PlayState.SONG.strumOffset == 'Opponent Focus') PlayState.SONG.strumOffset = 'Player Focus';


		switch(PlayState.SONG.strumOffset)
		{
			case 'Player Focus':
				STRUM_X = 0;
			case 'Opponent Focus':
				STRUM_X = 84;
			default:
				STRUM_X = 42;
		}

		var strumLineX:Float = (ClientPrefs.data.middleScroll || PlayState.SONG.strumOffset == 'Forced MiddleScroll') ? STRUM_X_MIDDLESCROLL : STRUM_X  + cutoutSize;
		var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.data.opponentStrums || PlayState.SONG.opponentDisabled) targetAlpha = 0;
				else if(ClientPrefs.data.middleScroll || PlayState.SONG.strumOffset == 'Forced MiddleScroll') targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(strumLineX, strumLineY, i, player);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				babyArrow.y -= 25;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 25, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if(ClientPrefs.data.middleScroll || PlayState.SONG.strumOffset == 'Forced MiddleScroll')
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.playerPosition();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				opponentVocals.pause();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = false);
			#if VIDEOS_ALLOWED
 			if(videoCutscene != null) videoCutscene.pause();
 			#end
		}

		super.openSubState(SubState);
	}

	public var canResync:Bool = true;
	override function closeSubState()
	{
		super.closeSubState();
		
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong && canResync)
			{
				resyncVocals();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = true);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = true);
			#if VIDEOS_ALLOWED
 			if(videoCutscene != null) videoCutscene.resume();
 			#end

			paused = false;
			callOnScripts('onResume');
			resetRPC(startTimer != null && startTimer.finished);
		}
	}

	#if DISCORD_ALLOWED
	override public function onFocus():Void
	{
		super.onFocus();
		if (!paused && health > 0)
		{
			resetRPC(Conductor.songPosition > 0.0);
		}
	}

	override public function onFocusLost():Void
	{
		super.onFocusLost();
		if (!paused && health > 0 && autoUpdateRPC)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.displayName == null ? SONG.song : SONG.displayName + " (" + storyDifficultyText + ")", '', SONG.song.toLowerCase());
		}
	}
	#end

	// Updating Discord Rich Presence.
	public var autoUpdateRPC:Bool = true; //performance setting for custom RPC things
	function resetRPC(?showTime:Bool = false)
	{
		#if DISCORD_ALLOWED
		if(!autoUpdateRPC) return;

		if (showTime)
			DiscordClient.changePresence(detailsText, SONG.displayName == null ? SONG.song : SONG.displayName + " (" + storyDifficultyText + ")", '', true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset, SONG.song.toLowerCase());
		else
			DiscordClient.changePresence(detailsText, SONG.displayName == null ? SONG.song : SONG.displayName + " (" + storyDifficultyText + ")", '', SONG.song.toLowerCase());
		#end
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		trace('resynced vocals at ' + Math.floor(Conductor.songPosition));

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		var checkVocals = [vocals, opponentVocals];
		for (voc in checkVocals)
		{
			if (FlxG.sound.music.time < vocals.length)
			{
				voc.time = FlxG.sound.music.time;
				voc.pitch = playbackRate;
				voc.play();
			}
			else voc.pause();
		}

		if(videoCutscene != null && videoCutscene.videoSprite != null && playingVideo)
		{
			var expectedVideoTime:Float = Conductor.songPosition - Conductor.offset - curVideoTimestamp;
   			var videoError:Float = toFloat(videoCutscene.videoSprite.bitmap.time) - expectedVideoTime;

			if (Math.abs(videoError) > 550)
			{
				videoCutscene.videoSprite.pause();
				videoCutscene.videoSprite.bitmap.time = fromFloat(expectedVideoTime);
				videoCutscene.videoSprite.resume();
			}
		}
	}

	public var paused:Bool = false;
	public var reloading:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var freezeCamera:Bool = false;
	var allowDebugKeys:Bool = true;
	var holdBonus:Float = 250;

	var char:Character;
	var charBF:Character;

	override public function update(elapsed:Float)
	{
		if(canUpdate && !paused && !freezeCamera) {
			FlxG.camera.followLerp = 0.04 * cameraSpeed * playbackRate;
			var idleAnim:Bool = (controlledPlayer.getAnimationName().startsWith('idle') || controlledPlayer.getAnimationName().startsWith('danceLeft') || controlledPlayer.getAnimationName().startsWith('danceRight'));
			if(!startingSong && !endingSong && idleAnim) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}
		else FlxG.camera.followLerp = 0;
		callOnScripts('onUpdate', [elapsed]);

		if (fireHalapeno != null)
		{
			if (fireHalapeno.alpha >= 0)
				fireHalapeno.alpha -= 0.01 * (elapsed/(1/60));
	
			if (fireFlash.alpha >= 0)
				fireFlash.alpha -= 0.01 * (elapsed/(1/60));	
		}

		if(!isPixelStage)  lerpHealth = MathUtil.smoothLerpDecay(lerpHealth, health, elapsed, 0.03 * playbackRate);

		super.update(elapsed);

		if (curDecStep != _lastSentDecStep) {
			_lastSentDecStep = curDecStep;
			setOnScripts('curDecStep', curDecStep);
		}
		if (curDecBeat != _lastSentDecBeat) {
			_lastSentDecBeat = curDecBeat;
			setOnScripts('curDecBeat', curDecBeat);
		}

		if(botplayTxt != null && botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnScripts('onPause', null, true);
			if(ret != LuaUtils.Function_Stop) {
				openPauseMenu();
			}
		}

		if(FlxG.keys.justPressed.SPACE)
			if (Conductor.songPosition < skipTime && canSkip && skipText.alpha == 0.25)
				skipIntroFunc(); //for BaseStage.hx

		if(Conductor.songPosition >= skipTime && canSkip)
		{
			FlxTween.tween(skipText, {alpha: 0}, 0.2);
			canSkip = false;
		}

		if(!endingSong && !inCutscene && allowDebugKeys)
		{
			if (controls.justPressed('debug_1') && curSong != 'boot' && curSong != 'Scam')
				openChartEditor();
		}

		if (healthBar.bounds.max != null && health > healthBar.bounds.max)
			health = healthBar.bounds.max;

		updateIconsScale(elapsed);
		updateIconsPosition();

		if (startedCountdown && !paused && !reloading)
		{
			Conductor.songPosition += elapsed * 1000 * playbackRate;
			if (Conductor.songPosition >= Conductor.offset)
			{
				Conductor.songPosition = FlxMath.lerp(FlxG.sound.music.time + Conductor.offset, Conductor.songPosition, Math.exp(-elapsed * 5));
				var timeDiff:Float = Math.abs((FlxG.sound.music.time + Conductor.offset) - Conductor.songPosition);
				if (timeDiff > 1000 * playbackRate)
					Conductor.songPosition = Conductor.songPosition + 1000 * FlxMath.signOf(timeDiff);
			}
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= Conductor.offset)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
		}
		else if (!paused && updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime);
			if(ClientPrefs.data.timeBarType == 'Time Elapsed') songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if(ClientPrefs.data.timeBarType != 'Song Name')
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
		}

		var decayRate:Float = 0.95;
		var dt:Float = elapsed * 60;
	
		if (subState == null && cameraZoomRate > 0.0)
		{
			cameraBopMultiplier = FlxMath.lerp(1.0, cameraBopMultiplier, Math.pow(decayRate * camZoomingDecay, dt));
			var zoomPlusBop:Float = currentCameraZoom * cameraBopMultiplier; // Apply camera bop multiplier.
			FlxG.camera.zoom = zoomPlusBop; // Actually apply the zoom to the camera.

			//LERP classic camera zoom by Purshake
			if (requiredZoom != currentCameraZoom
				&& (cameraZoomTween == null || !cameraZoomTween.active)) currentCameraZoom = FlxMath.lerp(requiredZoom, currentCameraZoom,
				  Math.pow(decayRate * camZoomingDecay, dt));
			  else
				requiredZoom = currentCameraZoom;
		
			camHudBopMult = FlxMath.lerp(1.0, camHudBopMult, Math.pow(decayRate * camZoomingDecayHud, dt));
			var zoomHudPlusBop:Float = defaultHUDCameraZoom * camHudBopMult; // Apply camera bop multiplier.
			camHUD.zoom = zoomHudPlusBop;  // Actually apply the zoom to the camera.
			camOverlayHUD.zoom = zoomHudPlusBop;  // ditto
			camVideoMid.zoom = zoomHudPlusBop;

			camNotesBopMult = FlxMath.lerp(1.0, camNotesBopMult, Math.pow(decayRate * camZoomingDecayHud, dt));
			var zoomNotesPlusBop:Float = defaultNotesCameraZoom * camNotesBopMult; // Apply camera bop multiplier.
			camNotes.zoom = zoomNotesPlusBop;  // Actually apply the zoom to the camera.
		}

		if (SONG.notes[curSection] != null)
		{
			if (SONG.notes[curSection].gfSection)
				charBF = gf;
			else
				charBF = boyfriend;

			if(curFocusedChar == 'bf')
			{

				if (charBF.followCharacter && canUpdate)
				{
					resetCamera(false, false, false);
					//cancelCameraFollowTween();
					cameraFollowPoint.setPosition(boyfriend.getMidpoint().x - boyfriend.cameraPosition[0] + boyfriendCameraOffset[0] - 100, boyfriend.getMidpoint().y + boyfriend.cameraPosition[1] + boyfriendCameraOffset[1] - 100);
				}

				if (charBF.getAnimationName() == "idle" || charBF.getAnimationName() == "danceLeft" || charBF.getAnimationName() == "danceRight")
				{
					FlxG.camera.targetOffset.x = 0;
					FlxG.camera.targetOffset.y = 0;
				}
			}

			if (SONG.notes[curSection].gfSection)
				char = gf;
			else
				char = dad;

			if(curFocusedChar == 'dad')
			{
				if (char.followCharacter && canUpdate)
				{
					resetCamera(false, false, false);
					//cancelCameraFollowTween();
					cameraFollowPoint.setPosition(dad.getMidpoint().x + dad.cameraPosition[0] + opponentCameraOffset[0] + 150, dad.getMidpoint().y + dad.cameraPosition[1] + opponentCameraOffset[1] - 100);
				}

				if (char.getAnimationName() == "idle" || char.getAnimationName() == "danceLeft" || char.getAnimationName() == "danceRight")
				{
					FlxG.camera.targetOffset.x = 0;
					FlxG.camera.targetOffset.y = 0;
				}
			}
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.data.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime * playbackRate;

			if(!unspawnNotes[0].mustPress)
				if(songSpeedOpponent < 1) time /= songSpeedOpponent;
			else
				if(songSpeed < 1) time /= songSpeed;

			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;

				// dunceNote was just inserted at index 0; no need to indexOf.
				callOnLuas('onSpawnNote', [0, dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, dunceNote.strumTime]);
				callOnHScript('onSpawnNote', [dunceNote]);

				// dunceNote == unspawnNotes[0]; shift is O(n) but skips an indexOf scan.
				unspawnNotes.shift();
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled)
					keysCheck();
				else
					playerDance();

				if(notes.length > 0)
				{
					if(startedCountdown)
					{
						var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
						var i:Int = 0;
						while(i < notes.length)
						{
							var daNote:Note = notes.members[i];
							if (daNote == null) {
								i++;
								continue;
							}

							var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
							if(!daNote.mustPress) strumGroup = opponentStrums;

							var strum:StrumNote = strumGroup.members[daNote.noteData];
							if(daNote.mustPress)
								daNote.followStrumNote(strum, fakeCrochet, songSpeed / playbackRate);
							else
								daNote.followStrumNote(strum, fakeCrochet, songSpeedOpponent / playbackRate);

							if(daNote.mustPress)
							{
								if((cpuControlled || daNote.autoplay) && !daNote.blockHit && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition))
									goodNoteHit(daNote);
							}
							else if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote && daNote.catchNote)
								opponentNoteHit(daNote);

							if(daNote.mustPress && !daNote.visible && !daNote.ignoreNote && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition))
								invisibleNoteHitPlayer(daNote);
							
							if (daNote.wasGoodHit && !daNote.mustPress && !daNote.catchNote && !daNote.hitByOpponent && !daNote.ignoreNote)
								opponentNoteMiss(daNote);

							if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

							// Cause misses if note is off screen
							if (daNote.mustPress && !daNote.autoplay && Conductor.songPosition - daNote.strumTime > missOffset)
							{
								if ((!cpuControlled || !daNote.autoplay) && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit) && daNote.active)
									noteMiss(daNote);

								daNote.active = false;
							}

							if (!daNote.mustPress && Conductor.songPosition - daNote.strumTime > missOffsetOppo)
								daNote.active = false;

							// Kill extremely late notes
							if (daNote.mustPress && Conductor.songPosition - daNote.strumTime > noteKillOffset / camNotes.zoom)
								invalidateNote(daNote);
							else if (!daNote.mustPress && Conductor.songPosition - daNote.strumTime > noteKillOffsetOppo / camNotes.zoom)
								invalidateNote(daNote);

							if(daNote.exists) i++;
						}
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
			checkEventNote();
		}

		if(!reloading)
		{
			for (holdNote in notes.members)
			{
				if (holdNote != null && holdNote.alive && holdNote.mustPress && holdNote.isSustainNote && holdNote.noteWasHit && !holdNote.missed)
				{
					//trace('its you!');

					health += 0.05 * healthGain * elapsed;
					//trace('holding!');
					songScore += holdBonus * elapsed;
					updateScoreText();
				}
			}
		}

		for (char in frozenCharacters.keys())
			if (frozenCharacters.get(char)) char.animPaused = true;
			else char.animPaused = false;

		if(fadeNoteMod)
		{
			for(note in notes.members){
				if(note.mustPress) note.alpha = Math.min(Math.abs(note.distance) / 500, 1);
			}
		}

		/*if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
			if(FlxG.keys.justPressed.THREE) { //Botplay enable
				cpuControlled = !cpuControlled;
				botplayTxt.visible = cpuControlled;
				botplayTxt.alpha = 1;
				botplaySine = 0;
			}
			if (FlxG.keys.justPressed.FOUR) { //perfect end song
				if (!FlxG.save.data.completedPerfectSongs.contains(Paths.formatToSongPath(SONG.song.toLowerCase())))
					FlxG.save.data.completedPerfectSongs.push(Paths.formatToSongPath(SONG.song.toLowerCase()));

				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if (FlxG.keys.justPressed.FIVE) { // gold perfect end song
				if (!FlxG.save.data.completedGoldenSongs.contains(Paths.formatToSongPath(SONG.song.toLowerCase())))
					FlxG.save.data.completedGoldenSongs.push(Paths.formatToSongPath(SONG.song.toLowerCase()));

				KillNotes();
				FlxG.sound.music.onComplete();
			}
		}*/

		if(canLoop)
		{
			addTextToDebug('ERROR', FlxColor.RED);
			setSongTime(2024);
			if(start) openScary();
		}

		setOnScripts('botPlay', cpuControlled);
		callOnScripts('onUpdatePost', [elapsed]);

		if (curSong == 'Scam' && Conductor.songPosition > finishLength)
		{
			FlxG.sound.music.stop();
			vocals.stop();
			opponentVocals.stop();

			Conductor.songPosition = 0;
			FlxG.sound.music.time = 0;
			vocals.time = 0;
			opponentVocals.time = 0;

			FlxG.sound.music.volume = 1;
			vocals.volume = 1;
			opponentVocals.volume = 1;

			FlxG.sound.music.play();
			vocals.play();
			opponentVocals.play();

			stepHit();
			beatHit();
			sectionHit();

			generateNotes(true);
		}

		if(generatedMusic && !inCutscene)
		{
			textYou.x = playerStrums.members[1].x + 35;

			if(ClientPrefs.data.laneUnderlay != 0)
			{
				laneP0.x = playerStrums.members[0].x;
				laneP1.x = playerStrums.members[1].x;
				laneP2.x = playerStrums.members[2].x;
				laneP3.x = playerStrums.members[3].x;
		
				laneE0.x = opponentStrums.members[0].x;
				laneE1.x = opponentStrums.members[1].x;
				laneE2.x = opponentStrums.members[2].x;
				laneE3.x = opponentStrums.members[3].x;
		
				laneP0.alpha = (
					playerStrums.members[0].alpha == 0 ?
						FlxMath.lerp(laneP0.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
						:
						FlxMath.lerp(laneP0.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
				);
				laneP1.alpha = (
					playerStrums.members[1].alpha == 0 ?
						FlxMath.lerp(laneP1.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
						:
						FlxMath.lerp(laneP1.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
				);
				laneP2.alpha = (
					playerStrums.members[2].alpha == 0 ?
						FlxMath.lerp(laneP2.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
						:
						FlxMath.lerp(laneP2.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
				);
				laneP3.alpha = (
					playerStrums.members[3].alpha == 0 ?
						FlxMath.lerp(laneP3.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
						:
						FlxMath.lerp(laneP3.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
				);
		
				laneE0.alpha = (
					opponentStrums.members[0].alpha == 0 ?
						FlxMath.lerp(laneE0.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
						:
						FlxMath.lerp(laneE0.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
				);
				laneE1.alpha = (
					opponentStrums.members[1].alpha == 0 ?
						FlxMath.lerp(laneE1.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
						:
						FlxMath.lerp(laneE1.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
				);
				laneE2.alpha = (
					opponentStrums.members[2].alpha == 0 ?
						FlxMath.lerp(laneE2.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
						:
						FlxMath.lerp(laneE2.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
				);
				laneE3.alpha = (
					opponentStrums.members[3].alpha == 0 ?
						FlxMath.lerp(laneE3.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
						:
						FlxMath.lerp(laneE3.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
				);
			}
		}

		for (i in shaderUpdates) i(elapsed);
	}

	public function openScary()
	{
		start = false;
		canPause = false;
		FlxG.save.flush();

		new FlxTimer().start(10, function(tmr:FlxTimer)
		{
			fate();
		});
	}

	public function fate()
	{
		var percent:Float = ratingPercent;
		if(Math.isNaN(percent)) percent = 0;
		Highscore.saveScore(Song.loadedSongName, Std.int(songScore), storyDifficulty, variation, percent, songMisses, rank);

		if (!FlxG.save.data.completedSongs.contains(Paths.formatToSongPath(SONG.song.toLowerCase())))
			FlxG.save.data.completedSongs.push(Paths.formatToSongPath(SONG.song.toLowerCase()));

		var grade = (ratingsData[0].hits + ratingsData[1].hits - songMisses) / totalNotes;

		if (grade == 1.0 && !FlxG.save.data.completedPerfectSongs.contains(Paths.formatToSongPath(SONG.song.toLowerCase())))
			FlxG.save.data.completedPerfectSongs.push(Paths.formatToSongPath(SONG.song.toLowerCase()));

		if (ratingsData[0].hits == totalNotes && !FlxG.save.data.completedGoldenSongs.contains(Paths.formatToSongPath(SONG.song.toLowerCase())))
			FlxG.save.data.completedGoldenSongs.push(Paths.formatToSongPath(SONG.song.toLowerCase()));

		FlxG.save.flush();

		if (Progression.weekProgress.exists(WeekData.getCurrentWeek().weekName))
		{
			Progression.weekProgress.remove(WeekData.getCurrentWeek().weekName);
			Progression.save();
		}

		if(!ClientPrefs.getGameplaySetting('practice')) {
			StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
			Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty, variation);

			FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
			FlxG.save.flush();
		}

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		var errMsg:String = "funkin/game/PlayState.hx (line 4741)\nfunkin/game/PlayState.hx (line 3496)\nfunkin/game/PlayState.hx (line 3249)\nflixel/FlxState.hx (line 225)\nflixel/FlxGame.hx (line 693)\nflixel/FlxGame.hx (line 628)\nflixel/FlxGame.hx (line 507)\n\nUncaught Error: Null Object Reference";

		var errMsgDoc:String = "funkin/game/PlayState.hx (line 4741)\nfunkin/game/PlayState.hx (line 3496)\nfunkin/game/PlayState.hx (line 3249)\nflixel/FlxState.hx (line 225)\nflixel/FlxGame.hx (line 693)\nflixel/FlxGame.hx (line 628)\nflixel/FlxGame.hx (line 507)\n\nUncaught Error: Null Object Reference













































































			Ох господи! Не думал что все будет так сложно...
			И что же делать!? А знаешь что? У меня есть идея получше!
		";
		var path:String;
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "GoldFunk_" + dateNow + ".txt";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsgDoc + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(vocals != null)
			vocals.pause();
		if(opponentVocals != null)
			opponentVocals.pause();

		WindowUtil.setTitle('...');

		MusicBeatState.switchState(new funkin.menus.lore.ChapterOneStartState());
	}

	// Health icon updaters
	var iconLerpScaleOffset:Float = 0.15; //if you wanna edit it, go ahead
	public dynamic function updateIconsScale(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(boyfriend.iconScale - iconLerpScaleOffset, iconP1.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(dad.iconScale - iconLerpScaleOffset, iconP2.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();
	}

	public dynamic function updateIconsPosition()
	{
		var iconOffset:Int = 26;
		iconP1.x = (healthBar.barCenter) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = (healthBar.barCenter) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if(opponentMode)
		{
			if(PlayState.SONG.swapPlayers)
			{
				if(iconP1.animated)
					iconP1.updateHealthIcon(healthBar.percent);
				else
					iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : (healthBar.percent > 80 && iconP1.hasThirdIcon) ? 2 : 0;
		
				if(iconP2.animated)
					iconP2.updateHealthIcon(100 - healthBar.percent);
				else
					iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : (healthBar.percent < 20 && iconP2.hasThirdIcon) ? 2 : 0;
			}
			else
			{
				if(iconP2.animated)
					iconP2.updateHealthIcon(healthBar.percent);
				else
					iconP2.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : (healthBar.percent > 80 && iconP2.hasThirdIcon) ? 2 : 0;
		
				if(iconP1.animated)
					iconP1.updateHealthIcon(100 - healthBar.percent);
				else
					iconP1.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : (healthBar.percent < 20 && iconP1.hasThirdIcon) ? 2 : 0;
			}
		}
		else
		{
			if(PlayState.SONG.swapPlayers)
			{
				if(iconP2.animated)
					iconP2.updateHealthIcon(healthBar.percent);
				else
					iconP2.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : (healthBar.percent > 80 && iconP2.hasThirdIcon) ? 2 : 0;
		
				if(iconP1.animated)
					iconP1.updateHealthIcon(100 - healthBar.percent);
				else
					iconP1.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : (healthBar.percent < 20 && iconP1.hasThirdIcon) ? 2 : 0;
			}
			else
			{
				if(iconP1.animated)
					iconP1.updateHealthIcon(healthBar.percent);
				else
					iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : (healthBar.percent > 80 && iconP1.hasThirdIcon) ? 2 : 0;
		
				if(iconP2.animated)
					iconP2.updateHealthIcon(100 - healthBar.percent);
				else
					iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : (healthBar.percent < 20 && iconP2.hasThirdIcon) ? 2 : 0;
			}
		}
	}

	var iconsAnimations:Bool = true;
	function set_health(value:Float):Float // You can alter how icon animations work here
	{
		value = FlxMath.roundDecimal(value, 5); //Fix Float imprecision
		if(!iconsAnimations || healthBar == null || !healthBar.enabled || healthBar.valueFunction == null)
		{
			health = value;
			return health;
		}

		// update health bar
		health = value;
		var newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		return health;
	}

	function openPauseMenu()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}
		/*if(!cpuControlled)
		{
			for (note in playerStrums)
				if(note.animation.curAnim != null && note.animation.curAnim.name != 'static')
				{
					note.playAnim('static');
					note.resetAnim = 0;
				}
		}*/

		if(chartingMode)
			openSubState(new PauseSubState());
		else if (FlxG.save.data.progressState == 0)
			openSubState(new BpPauseSubState());
		else
			if (FlxG.save.data.progressState == 2 && stageUI == 'bp') 
				openSubState(new BpPauseSubState());
			else
				openSubState(new PauseRealSubState());

		#if DISCORD_ALLOWED
		if(autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.displayName == null ? SONG.song : SONG.displayName + " (" + storyDifficultyText + ")", '', SONG.song.toLowerCase());
		#end
	}

	function openResults()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		if(isStoryMode)
		{
			// Grade % (only good and sick), 1.00 is a full combo
			var grade = (campaignSicks + campaignGoods - campaignMisses) / fullNotes;
			// Clear % (including bad and shit). 1.00 is a full clear but not a full combo
			var clear = (songFullHits) / fullNotes;
		
			if (grade == 1.00)
				levelRank = 1;
			else if (grade >= 0.80)
				levelRank = 2;
			else if (grade >= 0.60)
				levelRank = 3;
			else if (grade >= 0.50)
				levelRank = 4;

			if (campaignSicks == totalNotes)
			{
				levelRank = 0;
			}

			openSubState(new ResultSubState(WeekData.getCurrentWeek().storyName, campaignScore, campaignMisses, campaignAccuracy, campaignSicks, campaignGoods, campaignBads, campaignShits, songFullHits, maxCombo, levelRank));
		}
		else
		{
			if (combo > comboGot) comboGot = combo;
			if (comboGot > maxCombo) maxCombo = comboGot;

			openSubState(new ResultSubState(SONG.displayName == null ? SONG.song : SONG.displayName, Std.int(songScore), songMisses, ratingPercent, ratingsData[0].hits, ratingsData[1].hits, ratingsData[2].hits, ratingsData[3].hits, songHits, maxCombo, rank));
		}

		#if DISCORD_ALLOWED
		if(isStoryMode)
		{
			if(autoUpdateRPC) DiscordClient.changePresence("Results - " + WeekData.getCurrentWeek().storyName, 'Rank: ' + levelRank, '', SONG.song.toLowerCase());
		}
		else
		{
			if(autoUpdateRPC) DiscordClient.changePresence("Results - " + SONG.displayName == null ? SONG.song : SONG.displayName, 'Rank: ' + rank, '', SONG.song.toLowerCase());
		}
		#end
	}

	public function skipIntroFunc()
	{
		FunkinSound.playOnce(Paths.sound('confirmMenu'));
		camOther.flash(0x55FFFFFF, Conductor.crochet * 0.001, null, true);
		setSongTime(skipTime);
		FlxTween.cancelTweensOf(skipTime);
		skipText.alpha = 0;
		canSkip = false;
		stagesFunc(function(stage:BaseStage) stage.skipIntroFunc());
		resyncVocals();
		callOnLuas('onSkipIntro', []);
	}

	function openChartEditor()
	{
		canResync = false;
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		//chartingMode = true;
		paused = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(vocals != null)
			vocals.pause();
		if(opponentVocals != null)
			opponentVocals.pause();

		var poop = Highscore.formatSong('scam', 1, 0);
		Song.loadFromJson(poop, 'scam');
		PlayState.storyDifficulty = 1;
		PlayState.variation = 0;

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
	}

	function openCharacterEditor()
	{
		canResync = false;
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(vocals != null)
			vocals.pause();
		if(opponentVocals != null)
			opponentVocals.pause();

		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
	}

	function openStageEditor()
	{
		canResync = false;
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(vocals != null)
			vocals.pause();
		if(opponentVocals != null)
			opponentVocals.pause();

		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		MusicBeatState.switchState(new StageEditorState(curStage, null, true));
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	public var gameOverTimer:FlxTimer;
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && (instakillOnMiss || onlySick)) || health <= 0) && !practiceMode && !isDead && gameOverTimer == null && curSong != 'boot' && curSong != 'Scam')
		{
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if(ret != LuaUtils.Function_Stop)
			{
				FlxG.animationTimeScale = 1;

				stagesFunc(function(stage:BaseStage) stage.onGameOver());

				deathCounter++;

				if (vwooshTimer != null) vwooshTimer.cancel();
				if (startTimer != null) startTimer.cancel();
				if (goTimer != null) goTimer.cancel();

				skipTime = 0;
				canSkip = false;
				skipText.alpha = 0;

				//FlxTimer.globalManager.forEach(function(tmr:FlxTimer) tmr.cancel());
				//FlxTween.globalManager.forEach(function(twn:FlxTween) twn.cancel());

				camGame.stopFX();
				camHUD.stopFX();
				camOverlayHUD.stopFX();
				camNotes.stopFX();
				camOther.stopFX();

				cancelAllCameraTweens();

				canResync = false;
				canPause = false;
				#if VIDEOS_ALLOWED
				if(videoCutscene != null)
				{
					videoCutscene.destroy();
					videoCutscene = null;
				}
				#end

				// Iterate backwards: comboGroup.remove() shifts members, which would skip entries on a forward iterator.
				var i:Int = countGroup.members.length;
				while (--i >= 0) {
					var spr = countGroup.members[i];

					if (spr == null)
						continue;

					FlxTween.cancelTweensOf(spr);
					FlxTween.cancelTweensOf(spr.scale);

					countGroup.remove(spr, true);
					spr.destroy();
				}

				//FlxTimer.globalManager.clear();
				//FlxTween.globalManager.clear();

				if (GameOverSubstate.removeCameraShaders) FlxG.camera.filters = [];

				persistentUpdate = false;
				if (GameOverSubstate.bg_alpha == 1) persistentDraw = false;

				if(GameOverSubstate.deathDelay > 0)
				{
					gameOverTimer = new FlxTimer().start(GameOverSubstate.deathDelay, function(_)
					{
						controlledPlayer.stunned = true;

						FlxG.sound.music.pause();
						vocals.pause();
						opponentVocals.pause();

						FlxG.sound.music.time = 0;
						vocals.time = 0;
						opponentVocals.time = 0;
						Conductor.songPosition = 0;

						openSubState(new GameOverSubstate(boyfriend));
						gameOverTimer = null;
					});
				}
				else
				{
					controlledPlayer.stunned = true;

					FlxG.sound.music.pause();
					vocals.pause();
					opponentVocals.pause();

					FlxG.sound.music.time = 0;
					vocals.time = 0;
					opponentVocals.time = 0;
					Conductor.songPosition = 0;

					openSubState(new GameOverSubstate(boyfriend));
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if DISCORD_ALLOWED
				// Game Over doesn't get his its variable because it's only used here
				if(autoUpdateRPC) DiscordClient.changePresence("Game Over - " + detailsText, SONG.displayName == null ? SONG.song : SONG.displayName + " (" + storyDifficultyText + ")", '', SONG.song.toLowerCase());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			var value3:String = '';
			if(eventNotes[0].value3 != null)
				value3 = eventNotes[0].value3;

			var value4:String = '';
			if(eventNotes[0].value4 != null)
				value4 = eventNotes[0].value4;

			var value5:String = '';
			if(eventNotes[0].value5 != null)
				value5 = eventNotes[0].value5;

			triggerEvent(eventNotes[0].event, value1, value2, value3, value4, value5, leStrumTime);
			eventNotes.shift();
		}
	}

	//most of the new events are from that one fnf trollge mod and ddto bad ending
	public function triggerEvent(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, strumTime:Float) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		var flValue3:Null<Float> = Std.parseFloat(value3);
		var flValue4:Null<Float> = Std.parseFloat(value4);
		var flValue5:Null<Float> = Std.parseFloat(value5);
		if(Math.isNaN(flValue1)) flValue1 = null;
		if(Math.isNaN(flValue2)) flValue2 = null;
		if(Math.isNaN(flValue3)) flValue3 = null;
		if(Math.isNaN(flValue4)) flValue4 = null;
		if(Math.isNaN(flValue5)) flValue5 = null;

		switch(eventName) {
			case 'CountDown':
				final introAlts:Array<String> = switch(stageUI)
				{
					case "pixel":  ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
					case "normal": ["ready", "set" ,"go"];
					default:       ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
				};
				final antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelStage);
	
				switch(value1.toLowerCase().trim()) {
					case 'pre-ready': 
						if(value2 == 'true' || value2 == 'True') FunkinSound.playOnce(Paths.sound('intro3' + introSoundsSuffix), 0.6);
					case 'ready': 
						countdownReady = createCountdownSprite(introAlts[0], antialias); 
						if(value2 == 'true' || value2 == 'True') FunkinSound.playOnce(Paths.sound('intro2' + introSoundsSuffix), 0.6);
					case 'set':
						countdownSet = createCountdownSprite(introAlts[1], antialias);
						if(value2 == 'true' || value2 == 'True') FunkinSound.playOnce(Paths.sound('intro1' + introSoundsSuffix), 0.6);
					case 'go':
						countdownGo = createCountdownSprite(introAlts[2], antialias);
						if(value2 == 'true' || value2 == 'True') FunkinSound.playOnce(Paths.sound('introGo' + introSoundsSuffix), 0.6);
				}

			case 'Hey!':
				if(ClientPrefs.data.optimize) return;

				var value:Int = 2;
				var char:Character = boyfriend;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
						char = boyfriend;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
						char = gf;
					case 'dad' | 'opponent' | '2':
						value = 2;
						char = dad;
					default:
						value = 3;
				}

				if(flValue2 == null || flValue2 <= 0) flValue2 = 0.6;

				if(value == 3)
				{
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					}

					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = flValue2;
				}
				else
				{
					var animToPlay:String = value3;

					if (animToPlay == null || value3 == '') animToPlay = char != gf ? 'hey' : 'cheer';

					if(dad.curCharacter.startsWith('gf') && value == 2) 
					{
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					}
					else
					{
						char.playAnim('hey', true);
						char.specialAnim = true;
						char.heyTimer = flValue2;
					}
				}

			case 'Set Character Speed':
				var char:Character = boyfriend;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend' | '1':
						char = gf;
					case 'dad' | 'opponent' | '2':
						char = dad;
					default:
						char = boyfriend;
				}

				if(flValue2 == null || flValue2 < 1) flValue2 = 1;

				if(char == gf)
					gfSpeed = Math.round(flValue2);
				else
					char.danceEveryNumBeats = Math.round(flValue2);

				char.idleForce = value2 == 'true' ? true : false;

			case 'Add Camera Zoom':
				if(ClientPrefs.data.camZooms && FlxG.camera.zoom < 1.7) {
					if(flValue1 == null) flValue1 = 0.015;
					if(flValue2 == null) flValue2 = 0.03;

					cameraBopMultiplier += flValue1;
					camHudBopMult += flValue2;
					camNotesBopMult += flValue2;
				}

			case 'Play Animation':
				if(ClientPrefs.data.optimize) return;
				
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'gf' | 'girlfriend' | '1':
						char = gf;
					case 'dad' | 'opponent' | '2':
						char = dad;
					default:
						char = boyfriend;
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.uninterruptableAnim = value3 == 'true' ? true : false;
					char.specialAnim = true;
				}

				if(value1 == 'hurt')
				{
					if(!char.hasAnimation('hurt'))
					{
						if(char.hasAnimation('singLEFTmiss'))
							char.playAnim('singLEFTmiss', true);
						else
							char.playAnim('singLEFT', true);

						var initX:Float = char.x;

						char.x -= 20;
						char.color = 0xFFFF0000;
						new FlxTimer().start(0.02, function(tmr:FlxTimer)
						{
							char.x = initX;
							char.x += 20;
							new FlxTimer().start(0.02, function(tmr:FlxTimer)
							{
								char.x = initX;
								char.x -= 10;
								char.color = 0xFFFFFFFF;
								new FlxTimer().start(0.02, function(tmr:FlxTimer)
								{
									char.x = initX;
									char.x += 10;
									new FlxTimer().start(0.02, function(tmr:FlxTimer)
									{
										char.x = initX;
									});
								});
							});
						});
					}
				}

			case 'Change Icon':
				if(ClientPrefs.data.optimize) return;
				var iconToSwitch:HealthIcon = 
				switch(value1.toLowerCase().trim())
				{
					case 'dad' | 'opponent' | 'p2':
						iconP2;
					default:
						iconP1;
				}

				var charSwitching:Character = 
				switch(value1.toLowerCase().trim())
				{
					case 'dad' | 'opponent' | 'p2':
						dad;
					default:
						boyfriend;
				}

				var playerFlip:Bool = 
				switch(value1.toLowerCase().trim())
				{
					case 'dad' | 'opponent' | 'p2':
						false;
					default:
						true;
				}

				if(value1 == 'bf' && Main.darnellMode && !opponentMode) value2 = 'darnell'; 

				if(value1 == 'bf' && Main.raldman && !opponentMode) value2 = 'raldeblan'; 

				var split:Array<String> = value3.split(',');
				var iconFlipX:String = '';
				var scaleIcon:Float = 1;
				var iconOffsetX:Float = 0;
				var iconOffsetY:Float = 0;
				var iconBlend:String = '';
				var fpsIcon:Int = 24;

				var iconFlipBool:Bool = false;

				if(split[0] != null) iconFlipX = split[0].trim();
				if(split[1] != null) scaleIcon = Std.parseFloat(split[1].trim());
				if(split[2] != null) iconOffsetX = Std.parseFloat(split[2].trim());
				if(split[3] != null) iconOffsetY = Std.parseFloat(split[3].trim());
				if(split[4] != null) iconBlend = split[4].trim();
				if(split[5] != null) fpsIcon = Std.parseInt(split[5].trim());

				if(iconFlipX == null || iconFlipX == '')
					iconFlipBool = charSwitching.iconFlipX;
				else
					iconFlipBool = iconFlipX == 'true' ? true : false;

				if(Math.isNaN(scaleIcon)) scaleIcon = charSwitching.iconScale;
				if(Math.isNaN(iconOffsetX)) iconOffsetX = charSwitching.iconOffsets[0];
				if(Math.isNaN(iconOffsetY)) iconOffsetY = charSwitching.iconOffsets[1];
				if(iconBlend == null || iconBlend == '') iconBlend = charSwitching.iconBlend;
				if(Math.isNaN(fpsIcon)) fpsIcon = charSwitching.iconFps24;

				var splitRGB:Array<String> = value4.split(',');
				var iconR:Int = 0;
				var iconG:Int = 0;
				var iconB:Int = 0;

				if(splitRGB[0] != null) iconR = Std.parseInt(splitRGB[0].trim());
				if(splitRGB[1] != null) iconG = Std.parseInt(splitRGB[1].trim());
				if(splitRGB[2] != null) iconB = Std.parseInt(splitRGB[2].trim());

				if(Math.isNaN(iconR)) iconR = charSwitching.healthColorArray[0];
				if(Math.isNaN(iconG)) iconG = charSwitching.healthColorArray[1];
				if(Math.isNaN(iconB)) iconB = charSwitching.healthColorArray[2];
				
				charSwitching.healthColorArray[0] = iconR;
				charSwitching.healthColorArray[1] = iconG;
				charSwitching.healthColorArray[2] = iconB;

				iconToSwitch.changeIcon(value2, playerFlip, [iconOffsetX, iconOffsetY], scaleIcon, iconFlipBool, iconBlend, fpsIcon);
				reloadHealthBarColors();

			case 'Change Combo Camera':
				var args:Array<String> = value2.split(",");
				var bools:Bool = false;

				var xTarg:Float = Std.parseFloat(args[0]);
				var yTarg:Float = Std.parseFloat(args[1]);

				switch(value1)
				{
					case 'camHUD' | 'hud' | 'camhud':
						bools = false;
					default:
						bools = true;
				}

				comboOnCamGame(bools, xTarg, yTarg);

			case "Focus Camera":
				if(ClientPrefs.data.optimize) return;
				var coordsStr:Array<String> = value4.split(",");
					
				var char:String = value1 ?? "dad";
		
				var duration:Float = flValue2;
				if (flValue2 == null)
					duration = 4.0;
		
				var ease:String = value3 ?? "CLASSIC";
		
				var targetX:Float = Std.parseFloat(coordsStr[0]);
				var targetY:Float = Std.parseFloat(coordsStr[1]);
		
				if (Math.isNaN(targetX))
					targetX = 0;
				if (Math.isNaN(targetY))
					targetY = 0;
		
				switch (char.toLowerCase())
				{
					case "origin":
						trace("Chose origin");
					case "bf":
						targetX += boyfriend.getMidpoint().x - boyfriend.cameraPosition[0] + boyfriendCameraOffset[0] - 100;
						targetY += boyfriend.getMidpoint().y + boyfriend.cameraPosition[1] + boyfriendCameraOffset[1] - 100;
						curFocusedChar = 'bf';
					case "gf":
						targetX += gf.getMidpoint().x + gf.cameraPosition[0] + girlfriendCameraOffset[0];
						targetY += gf.getMidpoint().y + gf.cameraPosition[1] + girlfriendCameraOffset[1];

						if(!SONG.notes[curSection].mustHitSection)
							curFocusedChar = 'dad';
						else
							curFocusedChar = 'bf';
					default:
						targetX += dad.getMidpoint().x + dad.cameraPosition[0] + opponentCameraOffset[0] + 150;
						targetY += dad.getMidpoint().y + dad.cameraPosition[1] + opponentCameraOffset[1] - 100;
						curFocusedChar = 'dad';
				}
		
				switch (ease)
				{
					case 'CLASSIC': // Old-school. No ease. Just set follow point.
						resetCamera(false, false, false);
						cancelCameraFollowTween();
						cameraFollowPoint.setPosition(targetX, targetY);
					case 'INSTANT': // Instant ease. Duration is automatically 0.
						tweenCameraToPosition(targetX, targetY, 0);
					default:
						var durSeconds:Float = Conductor.stepCrochet * duration / 1000;
						tweenCameraToPosition(targetX, targetY, durSeconds, LuaUtils.getTweenEaseByString(ease));
				}

			case 'Change Object zIndex layer':
				if(ClientPrefs.data.optimize) return;
				var leObj:FlxBasic = LuaUtils.getObjectDirectly(value1);
				if(leObj != null)
				{
					var layer:Int = Std.parseInt(value2);
					if(Math.isNaN(layer)) layer = 0;
					leObj.zIndex = layer;

					refresh();

					return;

					/*var groupOrArray:Dynamic = CustomSubstate.instance != null ? CustomSubstate.instance : LuaUtils.getTargetInstance();
					groupOrArray.remove(leObj, true);
					groupOrArray.insert(Std.parseInt(value2), leObj);
					return;*/
				}
				addTextToDebug('Change Object Layer event: Object $value3 doesn\'t exist!', FlxColor.RED);

			case 'Update Strum Position Variable':
				for (i in 0...playerStrums.length) {
					setOnScripts('curPlayerStrumX' + i, playerStrums.members[i].x);
					setOnScripts('curPlayerStrumY' + i, playerStrums.members[i].y);
				}
				for (i in 0...opponentStrums.length) {
					setOnScripts('curOpponentStrumX' + i, opponentStrums.members[i].x);
					setOnScripts('curOpponentStrumY' + i, opponentStrums.members[i].y);
					//if(ClientPrefs.data.middleScroll) opponentStrums.members[i].visible = false;
				}

			case "Set Camera Bop":
				var rate:Int = Std.parseInt(value1);
				var intensity:Float = flValue2;

				if (flValue3 == null) flValue3 = 1;

				cameraBopIntensity = 0.015 * intensity + 1.0;
				hudCameraZoomIntensity = 0.015 * intensity * 2.0;

				camZoomingDecay = flValue3;
				camZoomingDecayHud = flValue3;

				if(rate == 0)
					cameraZoomRate = 999;
				else
					cameraZoomRate = rate;

			case "Zoom Camera":	
				if(ClientPrefs.data.optimize) return;

				var zoom:Float = flValue2 ?? 1.0;
				var duration:Float = flValue3 ?? 4.0;
					
				var mode:String = value4 ?? "direct";
				var isDirectMode:Bool = mode == "direct";
		
				if (value1 == "")
					value1 = "CLASSIC";
		
				switch(value1)
				{
					case 'CLASSIC':
						var targetZoom = zoom * (isDirectMode ? FlxCamera.defaultZoom : stageZoom);
						PlayState.instance.cancelCameraZoomTween();
						requiredZoom = targetZoom;
					case "INSTANT":
						var targetZoom = zoom * (isDirectMode ? FlxCamera.defaultZoom : stageZoom);
						tweenCameraZoom(zoom, 0, isDirectMode);
						requiredZoom = targetZoom;
					default:
						var durSeconds:Float = Conductor.stepCrochet * duration / 1000;
						tweenCameraZoom(zoom, durSeconds, isDirectMode, LuaUtils.getTweenEaseByString(value1));
				}

			case "Zoom Hud Camera":
				if(ClientPrefs.data.optimize) return;

				var durSeconds:Float = Conductor.stepCrochet * flValue2 / 1000;

				if (cameraHudZoomTween != null)
					cameraHudZoomTween.cancel();

				if (value3 == 'INSTANT')
					// Instant zoom. No tween needed.
				    defaultHUDCameraZoom = flValue1;
				else
					// Zoom tween! Caching it so we can cancel/pause it later if needed.
					cameraHudZoomTween = FlxTween.num(
						defaultHUDCameraZoom,
						flValue1,
						durSeconds / playbackRate,
						{ease: LuaUtils.getTweenEaseByString(value3)},
						function(num:Float) {defaultHUDCameraZoom = num;}
					);

			case "Zoom Notes Camera":
				if(ClientPrefs.data.optimize) return;

				var durSeconds:Float = Conductor.stepCrochet * flValue2 / 1000;
				
				if (cameraNotesZoomTween != null)
					cameraNotesZoomTween.cancel();

				if (value3 == 'INSTANT')
					// Instant zoom. No tween needed.
				    defaultNotesCameraZoom = flValue1;
				else
					// Zoom tween! Caching it so we can cancel/pause it later if needed.
					cameraNotesZoomTween = FlxTween.num(
						defaultNotesCameraZoom,
						flValue1,
						durSeconds / playbackRate,
						{ease: LuaUtils.getTweenEaseByString(value3)},
						function(num:Float) {defaultNotesCameraZoom = num;}
					);

			case "Camera Angle":
				if(ClientPrefs.data.optimize) return;

				var angleChange:Float = flValue2 ?? 0;
				var duration:Float = flValue3 ?? 4.0;
		
				if (value1 == "")
					value1 = "linear";

				var durSeconds:Float = Conductor.stepCrochet * duration / 1000;

				var cameraChange:FunkinCamera;

				switch(value4)
				{
					case 'camhud' | 'camHUD' | 'hud':
						cameraChange = camHUD;
					case 'camnotes' | 'camNotes' | 'notes':
						cameraChange = camNotes;
					case 'camoverlayhud' | 'camOverlayHUD' | 'overlay':
						cameraChange = camOverlayHUD;
					case 'camOther' | 'camother' | 'other':
						cameraChange = camOther;
					default:
						cameraChange = camGame;
				}

				FlxTween.cancelTweensOf(cameraChange.scrollAngle);
				FlxTween.tween(cameraChange, {scrollAngle: angleChange}, durSeconds / playbackRate, {ease: LuaUtils.getTweenEaseByString(value1)});

			case 'Change Note Camera Move Offset':
				noteCamOffset = flValue1 ?? 0;

			case 'Alt Idle Animation':
				if(ClientPrefs.data.optimize) return;
				var char:Character = boyfriend;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend' | '1':
						char = gf;
					case 'dad' | 'opponent' | '2':
						char = dad;
					default:
						char = boyfriend;
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					if (!char.hasAnimation('idle' + value2)) char.idleSuffix = '';
					char.recalculateDanceIdle();
				}

			case 'Change Suffix Anim':
				if(ClientPrefs.data.optimize) return;
				var char:Character = boyfriend;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend' | '1':
						char = gf;
					case 'dad' | 'opponent' | '2':
						char = dad;
					default:
						char = boyfriend;
				}

				if (char != null)
				{
					char.animSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Shake Beat':
				if(!ClientPrefs.data.flashing) return;

				shakeBeat = !shakeBeat;
				shakeDec = Std.parseInt(value2);

			case 'Subtitles':
				if(!ClientPrefs.data.subtitles) return;

				var duration:Float = flValue2 ?? 4.0;
				var durSeconds:Float = Conductor.stepCrochet * duration / 1000;
				var textCache:FlxText = subtitlesTxt; 
				var colorCache:FlxColor = subtitlesTxt.color;
				var sizeCache:Int = subtitlesTxt.size;
				var alphaCache:Float = subtitlesTxt.alpha;
				var fontCache:String = subtitlesTxt.font;
				
				var metadata:Array<String> = value5.split(',');
				var sizes:Array<String> = value4.split(',');

				var size:Int = Std.parseInt(sizes[0]);
				var outlineSize:Float = Std.parseFloat(sizes[1]);

				var intro:String = metadata[0];
				var fade:String = metadata[1];
				var font:String = metadata[2];

				if (subtitlesTxt != null) {
					if (value1.length > 0) {
						subtitlesTxt.text = value1;
						subtitlesTxt.alpha = 1;
						FlxTween.cancelTweensOf(subtitlesTxt);
						FlxTween.cancelTweensOf(subtitlesTxt.alpha);
						if(font != null)
							subtitlesTxt.font = Paths.font(font);
						else
							subtitlesTxt.font = Paths.font('vcr.ttf');

						if(subTimer != null) subTimer.cancel();
						
						if(fade == 'true' || fade == 'fadeOut' || fade == 'fade out' || fade == 'fade') //WE FADING WITH THIS ONE
						{
							FlxTween.tween(subtitlesTxt, {alpha: 0}, 1, {
								startDelay: durSeconds / playbackRate,
								onComplete:
									function (twn:FlxTween)
									{
										subtitlesTxt.text = '';
										prevTxt = '';
									}
							});
						}
						else
						{
							subTimer = new FlxTimer().start(durSeconds / playbackRate, function(tmr:FlxTimer) {
								subtitlesTxt.text = '';
								prevTxt = '';
								subtitlesTxt.alpha = 0;
							});
						}
					} else {
						subtitlesTxt.text = null;
						subtitlesTxt.alpha = 0;
					}
				}
	
				if (value3 == null || value3 == '')
					subtitlesTxt.color = 0xFFFFFFFF;
				else
				{
					switch(value3)
					{
						case 'dad':
							subtitlesTxt.color = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
						case 'gf':
							subtitlesTxt.color = FlxColor.fromRGB(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]);
						case 'bf':
							subtitlesTxt.color = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
						default:
							subtitlesTxt.color = Std.parseInt(value3);
					}
				}

				if (sizes[0] == null || sizes[0] == '')
					size = 24;

				if (sizes[1] == null || sizes[1] == '')
					outlineSize = 1.25;

				subtitlesTxt.size = size;
				subtitlesTxt.borderSize = outlineSize;
			
				switch(intro)
				{
					case 'bop':
						doSubtitlesBop();
					case 'fade in':
						var subtitlesCache:FlxText = new FlxText(0, FlxG.height * 0.75, FlxG.width - 800, prevTxt, sizeCache);
						subtitlesCache.setFormat(Paths.font(prevFont), 24, colorCache, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
						subtitlesCache.scrollFactor.set();
						subtitlesCache.borderSize = 1.25;
						subtitlesCache.screenCenter(X);
						subtitlesCache.alpha = alphaCache;
						uiPostGroup.add(subtitlesCache);

						prevFont = font;

						FlxTween.tween(subtitlesCache, {alpha: 0}, 1, {
							ease: FlxEase.circOut,
							onComplete:
							function (twn:FlxTween)
							{			
								subtitlesCache.destroy();
							}
						});

						subtitlesTxt.alpha = 0;
						FlxTween.tween(subtitlesTxt, {alpha: 1}, 1 / playbackRate, {ease: FlxEase.circOut});

						prevTxt = subtitlesTxt.text;
					case 'fly away':
						subtitlesTxt.alpha = 0;
						FlxTween.cancelTweensOf(subtitlesTxt);

						var subtitlesCache:FlxText = new FlxText(0, FlxG.height * 0.75, FlxG.width - 800, prevTxt, sizeCache);
						subtitlesCache.setFormat(Paths.font(prevFont), 24, colorCache, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
						subtitlesCache.scrollFactor.set();
						subtitlesCache.borderSize = 1.25;
						subtitlesCache.screenCenter(X);
						subtitlesCache.alpha = alphaCache;
						uiPostGroup.add(subtitlesCache);

						prevFont = font;

						FlxTween.tween(subtitlesCache, {alpha: 0, y: subtitlesCache.y - 100}, 1, {
							ease: FlxEase.expoOut,
							onComplete:
							function (twn:FlxTween)
							{
								subtitlesCache.destroy();
							}
						});

						prevTxt = subtitlesTxt.text;

						subtitlesTxt.y = FlxG.height;
						FlxTween.tween(subtitlesTxt, {alpha: 1, y: FlxG.height * 0.75}, 1, {
							ease: FlxEase.expoOut,
						});
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2, value3];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD, camNotes];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, Conductor.stepCrochet * duration / 1000);
					}
				}

			case 'Change Character':
				if(ClientPrefs.data.optimize) return;
				var type:Int = switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend': 2;
					case 'dad' | 'opponent': 1;
					case 'second': 3;
					default:
						Std.parseInt(value1) ?? 0;
				}

				var characterName:String = 'boyfriend';
				var character:Character = boyfriend;
				var characterMap:Map<String, Character> = boyfriendMap;
				var icon:HealthIcon = iconP1;

				switch (type)
				{
					case 0:
						if (Main.darnellMode && !opponentMode) value2 = 'darnell';

						if (Main.raldman && !opponentMode) value2 = 'raldeblan';

						switch(ClientPrefs.data.activeBfSkin)
						{
							case 'classic':
								switch(value2)
								{
									case 'bfnew' | 'coolassbf' | 'bf-zero' | 'bf-redrawn':
										value2 = 'bf';

									case 'bfASsad':
										value2 = 'bf-angry';

									case 'bf-pixel':
										value2 = 'bf-pixel-classic';
								}

							case 'mm':
								switch(value2)
								{
									case 'bf' | 'coolassbf' | 'bf-zero' | 'bf-redrawn' | 'bfASsad':
										value2 = 'bfnew';
					
									case 'P3-bf':
										value2 = 'bf-back';
					
									case 'P3-bf-flip':
										value2 = 'bf-back-flip';
					
									case 'bf-running':
										value2 = 'bf_demise';
								}

							case 'sonic-legacy':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'bfASsad':
										value2 = 'coolassbf';
								}

							case 'indie-cross':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
										value2 = 'bf-ic';
								}

							case 'zero':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'coolassbf' | 'bf-redrawn' | 'bfASsad':
										value2 = 'bf-zero';
								}

							case 'basement':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
										value2 = 'bf-basement';
								}

							case 'romstyle':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
										value2 = 'rom-bf';
								}

							case 'spaghetti':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'coolassbf' | 'bfASsad':
										value2 = 'bf-redrawn';

									case 'P3-bf':
										value2 = '1hbf';
					
									case 'P3-bf-flip':
										value2 = '1hbf-flip';
								}

							case 'downtown':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
										value2 = 'bf-osm';
								}

							case 'legacy':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bfASsad':
										value2 = 'bf-legacy';
								}

							case 'minus1':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										value2 = 'bf-minus';
								}

							case 'minus2':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										value2 = 'bf-minus-beta';
								}

							case 'minus3':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										value2 = 'bf-minus-prototype';
								}

							case 'badtime':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf':
										value2 = 'bf-badtime';
				
									case 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
										value2 = 'bf-badtime-scared';
				
									case 'P3-bf':
										value2 = 'bf-badtime-back';
					
									case 'P3-bf-flip':
										value2 = 'bf-badtime-back-flip';

									case 'bf-running':
										value2 = 'bf-badtime-run';

									case 'bf-pixel':
										value2 = 'bf-badtime-run';
								}

							case 'ourple':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										value2 = 'bf_ourple';
								}

							case 'pixel':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running':
										value2 = 'bf-pixel';

									case 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
										value2 = 'bf-pixel-pissed';

									case 'P3-bf':
										value2  = 'P3-bf-pixel';
	
									case 'P3-bf-flip':
										value2  = 'P3-bf-flip-pixel';

									case 'bf-pixel':
										value2 = 'bf-pixel-classic';
								}

							case 'encore':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
										value2 = 'bf-encore';

									case 'bf-pixel':
										value2 = 'bf-pixel-sonic';
								}

							case 'romfriend':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										value2 = 'rf';
								}

							case 'gold':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										value2 = 'bf-golden';
								}

							case 'bp':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										value2 = 'bp';
								}

							case 'bad':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3':
										value2 = 'bf-bad';

									case 'bf-pixel':
										value2 = 'bf-bad-pixel';
								}

							case 'bp-dlc':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										value2 = 'bf-3d';
								}

							case 'ruby':
								switch(value2)
								{
									case 'bf' | 'bfnew' | 'bf-zero' | 'bf-redrawn' | 'coolassbf' | 'bf-running' | 'bfASsad' | 'bf_ultrafinale' | 'bf_ultrafinale3' | 'bf-pixel':
										value2 = 'ruby-bf';
								}
						}
					case 1:
						characterName = 'dad';
						character = dad;
						characterMap = dadMap;
						icon = iconP2;
					case 2:
						characterName = 'gf';
						character = gf;
						characterMap = gfMap;
						icon = null;
					case 3:
						characterName = 'second';
						character = second;
						characterMap = secondMap;
						icon = iconP2;
				}

				if (character != null)
				{
					character.shader = null;
					character.color = 0xFFFFFFFF;
					if (character.curCharacter != value2)
					{
						if (!characterMap.exists(value2))
							addCharacterToList(value2, type);

						var newCharacter:Character = characterMap[value2];
						newCharacter.alpha = 1;

						var lastAlpha:Float = character.alpha;
						character.alpha = .0001;

						var wasGf:Bool = character.curCharacter.startsWith('gf-') || character.curCharacter == 'gf';

						switch (type)
						{
							case 0:
								boyfriend = newCharacter;

								icon?.changeIcon(newCharacter.healthIcon, true, newCharacter.iconOffsets, newCharacter.iconScale, newCharacter.iconFlipX, newCharacter.iconBlend, newCharacter.iconFps24);

							case 1:
								dad = newCharacter;
								if (!newCharacter.curCharacter.startsWith('gf-') && newCharacter.curCharacter != 'gf')
								{
									if (wasGf && gf != null)
										gf.visible = false;
								}
								else if (gf != null)
									gf.visible = false;

								icon?.changeIcon(newCharacter.healthIcon, false, newCharacter.iconOffsets, newCharacter.iconScale, newCharacter.iconFlipX, newCharacter.iconBlend, newCharacter.iconFps24);

							case 2:
								gf = newCharacter; // character != null which would already be this.gf

							case 3:
								second = newCharacter;
						}
						reloadHealthBarColors();

						setOnScripts('${characterName}Name', newCharacter.curCharacter);
					}
				}

				if(opponentMode) //reload it so playable char will idle after input
				{
					controlledPlayer = PlayState.SONG.swapPlayers ? boyfriend : dad;
				}
				else
				{
					controlledPlayer = PlayState.SONG.swapPlayers ? dad : boyfriend;
				}

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 4;

					var ease = LuaUtils.getTweenEaseByString(value3);

					if(value4 == null) value4 = 'Both';

					switch(value4)
					{
						case 'player' | 'Player' | 'bf':
							var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
							if(flValue2 <= 0)
								songSpeed = newValue;
							else
								songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, Conductor.stepCrochet * flValue2 / 1000 / playbackRate, {ease: ease, onComplete:
									function (twn:FlxTween)
									{
										songSpeedTween = null;
									}
								});

						case 'opponent' | 'Opponent' | 'dad':
							var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
							if(flValue2 <= 0)
								songSpeedOpponent = newValue;
							else
								songSpeedTweenOpponent = FlxTween.tween(this, {songSpeedOpponent: newValue}, Conductor.stepCrochet * flValue2 / 1000 / playbackRate, {ease: ease, onComplete:
									function (twn:FlxTween)
									{
										songSpeedTweenOpponent = null;
									}
								});
						
						default:
							var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
							if(flValue2 <= 0)
								songSpeed = newValue;
							else
								songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, Conductor.stepCrochet * flValue2 / 1000 / playbackRate, {ease: ease, onComplete:
									function (twn:FlxTween)
									{
										songSpeedTween = null;
									}
								});

							var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
							if(flValue2 <= 0)
								songSpeedOpponent = newValue;
							else
								songSpeedTweenOpponent = FlxTween.tween(this, {songSpeedOpponent: newValue}, Conductor.stepCrochet * flValue2 / 1000 / playbackRate, {ease: ease, onComplete:
									function (twn:FlxTween)
									{
										songSpeedTweenOpponent = null;
									}
								});
					}
				}

			case 'Change Visual Time Length':
				if(flValue1 == null) 
					flValue1 = FlxG.sound.music.length;
				else
					flValue1 *= 1000;

				if(flValue2 == null) flValue2 = 0;

				var ease = LuaUtils.getTweenEaseByString(value3);

				if(flValue2 <= 0)
					songLength = flValue1;
				else
					songLengthTween = FlxTween.tween(this, {songLength: flValue1}, Conductor.stepCrochet * flValue2 / 1000 / playbackRate, {ease: ease, onComplete:
						function (twn:FlxTween)
						{
							songLengthTween = null;
						}
					});

			case 'Flash Camera':
				if(ClientPrefs.data.optimize) return;

				var color:FlxColor = 0xFFFFFFFF;
	
				if (value1 == null || value1 == '')
					color = 0xFFFFFFFF;

				color = Std.parseInt(value1);

				if (flValue2 == null) flValue2 = 4;

				if(!ClientPrefs.data.flashing && value1 != '0xFF000000') return;

				var cameraChange:FunkinCamera;
	
				switch(value3.toLowerCase().trim()) 
				{
					case 'camhud' | 'camHUD' | 'hud':
						cameraChange = camHUD;
					case 'camprehud' | 'camPreHUD' | 'prehud':
						cameraChange = camPreHUD;
					case 'camnotes' | 'camNotes' | 'notes':
						cameraChange = camNotes;
					case 'camoverlayhud' | 'camOverlayHUD' | 'overlay':
						cameraChange = camOverlayHUD;
					case 'camOther' | 'camother' | 'other':
						cameraChange = camOther;
					default:
						cameraChange = camGame;
				}

				cameraChange.flash(color, Conductor.stepCrochet * flValue2 / 1000, null, true);

			case 'Fade Camera':
				if(ClientPrefs.data.optimize) return;

				//if(!ClientPrefs.data.flashing) return;

				var color:FlxColor = 0xFFFFFFFF;
	
				if (value1 == null || value1 == '')
					color = 0xFFFFFFFF;

				color = Std.parseInt(value1);

				if (flValue2 == null) flValue2 = 4;

				var cameraChange:FunkinCamera;

				switch(value3.toLowerCase().trim()) 
				{
					case 'camhud' | 'camHUD' | 'hud':
						cameraChange = camHUD;
					case 'camprehud' | 'camPreHUD' | 'prehud':
						cameraChange = camPreHUD;
					case 'camnotes' | 'camNotes' | 'notes':
						cameraChange = camNotes;
					case 'camoverlayhud' | 'camOverlayHUD' | 'overlay':
						if(curSong == 'Fire Thoser' && opponentMode) //im so sorry for this hardcode
							cameraChange = camGame;
						else
							cameraChange = camOverlayHUD;
					case 'camOther' | 'camother' | 'other':
						cameraChange = camOther;
					default:
						cameraChange = camGame;
				}

				cameraChange.fade(color, Conductor.stepCrochet * flValue2 / 1000, value4 == 'true' ? true : false, null, true);

			case "Solid Graphic Behind Characters": //BLAMMED LI-
			if(ClientPrefs.data.optimize) return;
				var color:FlxColor = 0xFF000000;
	
				if (value3 == null || value3 == '')
					color = 0xFF000000;

				color = Std.parseInt(value3);

				if (flValue1 == null)
					flValue1 = 0;

				if(flValue2 == 0 || flValue2 == null)
					solidColBeh.alpha = flValue1
				else
					FlxTween.tween(solidColBeh, {alpha: flValue1}, Conductor.stepCrochet * flValue2 / 1000);

				solidColBeh.color = color;

			case 'Set Health':
				if(flValue3 == 0 || flValue3 != null)
				{
					health = flValue1;
				}
				else
				{
					var ease = LuaUtils.getTweenEaseByString(value2);
					FlxTween.tween(this, {health: flValue1}, Conductor.stepCrochet * flValue3 / 1000, {ease: ease});
				}

			case 'Add Health':
				var newhealth:Float = (health + flValue1);

				if(flValue3 == 0 || flValue3 != null)
				{
					health += newhealth;
				}
				else
				{
					var ease = LuaUtils.getTweenEaseByString(value2);
					FlxTween.tween(this, {health: newhealth}, Conductor.stepCrochet * flValue3 / 1000, {ease: ease});
				}

			case 'Singing Shakes':
				if (!ClientPrefs.data.flashing) return;
				
				var charType:Int = 0;
				switch(value2.toLowerCase().trim())
				{
					case 'dad' | 'opponent':
						charType = 1;
					default:
						var parsed:Null<Int> = Std.parseInt(value1);
						charType = (parsed != null) ? parsed : 0;
				}
				switch (value1.toLowerCase().trim())
				{
					case 'on' | 'true':
						singingShakeArray[charType] = true;
					case 'off' | 'false':
						singingShakeArray[charType] = false;
				}

			case 'Opponent Drain':
				switch (value1.toLowerCase().trim())
				{
					case 'on' | 'true':
						opponentHealthDrain = true;
					case 'off' | 'false':
						opponentHealthDrain = false;
				}

				var drain:Float = flValue2;
				if (Math.isNaN(drain) || value2 == null)
					drain = 0.023;
				
				opponentHealthDrainAmount = drain;

			case 'Beat Drain':
				if(flValue3 == null || flValue3 < 1) flValue3 = 8;
				switch (value1.toLowerCase().trim())
				{
					case 'on' | 'true':
						goHealthDamageBeat = true;
					case 'off' | 'false':
						goHealthDamageBeat = false;
				}

				var drain:Float = flValue2;
				if (Math.isNaN(drain) || value2 == null)
					drain = 0.023;

				beatHealthStep = Math.round(flValue3);
				
				beatHealthDrain = drain;

			case 'Set Character Position':
				if(ClientPrefs.data.optimize) return;
				var split:Array<String> = value2.split(',');
				var xMove:Float = Std.parseFloat(split[0]);
				var yMove:Float = Std.parseFloat(split[1]);

				var char:FlxSpriteGroup = boyfriendGroup;
				var defaultX:Float = BF_X;
				var defaultY:Float = BF_Y;

				switch (value1)
				{
					case 'dad' | 'Dad' | 'DAD':
						char = dadGroup;
						defaultX = DAD_X;
						defaultY = DAD_Y;
					case 'gf' | 'GF' | 'girlfriend' | 'Girlfriend':
						char = gfGroup;
						defaultX = GF_X;
						defaultY = GF_Y;
					default:
						char = boyfriendGroup;
						defaultX = BF_X;
						defaultY = BF_Y;
				}

				var ease = LuaUtils.getTweenEaseByString(value4);

				FlxTween.cancelTweensOf(char.x);
				FlxTween.cancelTweensOf(char.y);

				if (flValue3 == 0 || flValue3 == null)
				{
					if(Math.isNaN(xMove)) char.x = defaultX;
					else char.x = xMove;

					if(Math.isNaN(yMove)) char.y = defaultY;
					else char.y = yMove;
				}
				else
				{
					if(Math.isNaN(xMove)) xMove = defaultX;
					if(Math.isNaN(yMove)) yMove = defaultY;

					FlxTween.tween(char, {x: xMove, y: yMove}, Conductor.stepCrochet * flValue3 / 1000, {ease: ease});
				}

			case 'Set Character Color':
				if(ClientPrefs.data.optimize) return;
				var char:Character = boyfriend;
				var ease = LuaUtils.getTweenEaseByString(value4);
				var colorTo:FlxColor;
				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'dad':
						char = dad;
					default:
						char = boyfriend;
				}

				if (value2 == null)
					value2 = '0xFFFFFFFF';

				colorTo = CoolUtil.colorFromString(value2);

				FlxTween.cancelTweensOf(char.color);

				if(flValue3 == 0 || flValue3 == null)
				{
					char.color = colorTo;
				}
				else
				{
					var curColor:FlxColor = char.color;
					curColor.alphaFloat = char.alpha;

					FlxTween.color(char, Conductor.stepCrochet * flValue3 / 1000, curColor, colorTo, {ease: ease});
				}

			case 'Set Character Color Transform':
				if(ClientPrefs.data.optimize) return;
				var char:Character = boyfriend;

				var split:Array<String> = value2.split(',');
				var splitAlpha:Array<String> = value3.split(',');
				var redOff:Int = 0;
				var greenOff:Int = 0;
				var blueOff:Int = 0;
				var alphaOff:Int = 0;
				var redMult:Int = 0;
				var greenMult:Int = 0;
				var blueMult:Int = 0;
				var alphaMult:Int = 0;
				if(split[0] != null) redOff = Std.parseInt(split[0].trim());
				if(split[1] != null) greenOff = Std.parseInt(split[1].trim());
				if(split[2] != null) blueOff = Std.parseInt(split[2].trim());
				if(split[3] != null) alphaOff = Std.parseInt(split[3].trim());
				if(splitAlpha[0] != null) redMult = Std.parseInt(splitAlpha[0].trim());
				if(splitAlpha[1] != null) greenMult = Std.parseInt(splitAlpha[1].trim());
				if(splitAlpha[2] != null) blueMult = Std.parseInt(splitAlpha[2].trim());
				if(splitAlpha[3] != null) alphaMult = Std.parseInt(splitAlpha[3].trim());

				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'dad':
						char = dad;
					default:
						char = boyfriend;
				}

				var ease = LuaUtils.getTweenEaseByString(value5);

				FlxTween.cancelTweensOf(char.colorTransform);

				if(flValue4 == 0 || flValue4 == null)
				{
					char.colorTransform.redOffset = redOff;
					char.colorTransform.greenOffset = greenOff;
					char.colorTransform.blueOffset = blueOff;
					char.colorTransform.alphaOffset = alphaOff;
	
					char.colorTransform.redMultiplier = redMult;
					char.colorTransform.greenMultiplier = greenMult;
					char.colorTransform.blueMultiplier = blueMult;
					char.colorTransform.alphaMultiplier = alphaMult;
				}
				else
				{
					FlxTween.tween(char.colorTransform, 
						{
							redOffset: redOff, greenOffset: greenOff, blueOffset: blueOff, alphaOffset: alphaOff, 
							redMultiplier: redMult, greenMultiplier: greenMult, blueMultiplier: blueMult, alphaMultiplier: alphaMult
						}, Conductor.stepCrochet * flValue4 / 1000, {ease: ease});
				}

			case 'Add trail':
				if(ClientPrefs.data.optimize) return;
				var charType:Int = 0;
				var val3:Int = Std.parseInt(value3);

				var split:Array<String> = value1.split(',');
				var length:Int = 0;
				var delay:Float = 0;
				var alpha:Float = 0;
				var diff:Float = 0;

				if(split[0] != null) length = Std.parseInt(split[0].trim());
				if(split[1] != null) delay = Std.parseFloat(split[1].trim());
				if(split[2] != null) alpha = Std.parseFloat(split[2].trim());
				if(split[3] != null) diff = Std.parseFloat(split[3].trim());
				if(Math.isNaN(length)) length = 4;
				if(Math.isNaN(delay)) delay = 0.4;
				if(Math.isNaN(alpha)) alpha = 0.3;
				if(Math.isNaN(diff)) diff = 0.069;

				switch (value2)
				{
					case 'dad' | 'Dad' | 'DAD':
						charType = 1;
					case 'gf' | 'GF' | 'girlfriend' | 'Girlfriend':
						charType = 2;
					default:
						charType = 0;
				}

				var blendValue = LuaUtils.blendModeFromString(value4);

				switch (charType)
				{
					case 1:
						//if(trailDad != null) return;

						trailDad = new FlxTrail(dad, null, length, delay, alpha, diff);
						trailDad.blend = blendValue;
						if (!Math.isNaN(val3)) trailDad.color = val3;
						addBehindDad(trailDad);
					case 2:
						//if(trailGf != null) return;

						trailGf = new FlxTrail(gf, null, length, delay, alpha, diff);
						trailGf.blend = blendValue;
						if (!Math.isNaN(val3)) trailGf.color = val3;
						addBehindGF(trailGf);
					default:
						//if(trailBf != null) return;

						trailBf = new FlxTrail(boyfriend, null, length, delay, alpha, diff);
						trailBf.blend = blendValue;
						if (!Math.isNaN(val3)) trailBf.color = val3;
						addBehindBF(trailBf);
				}

			case 'Remove trail':
				if(ClientPrefs.data.optimize) return;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						if(trailGf == null) return;

						remove(trailGf);
						trailGf.destroy();
					case 'dad' | 'opponent':
						if(trailDad == null) return;

						remove(trailDad);
						trailDad.destroy();
					default:
						if(trailBf == null) return;

						remove(trailBf);
						trailBf.destroy();
				}
			case 'Update Vocals Volume':
				vocals.volume = flValue1;
				opponentVocals.volume = flValue2;

			case 'Show YOU text under strums':
				if(ClientPrefs.data.optimize) return;

				if (ClientPrefs.data.middleScroll || PlayState.SONG.strumOffset == 'Enable MiddleScroll')
					return;

				textYOUappear();

			case 'Set Character Visibility':
				if(ClientPrefs.data.optimize) return;

				var char:Character = boyfriend;

				var ease = LuaUtils.getTweenEaseByString(value4);
				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'dad':
						char = dad;
					case 'second':
						char = second;
					default:
						char = boyfriend;
				}

				FlxTween.cancelTweensOf(char.alpha);

				if (flValue3 == 0 || flValue3 == null)
					char.alpha = flValue2;
				else
					FlxTween.tween(char, {alpha: flValue2}, Conductor.stepCrochet * flValue3 / 1000, {ease: ease});

			case 'Strumline Visibility':
				var strum:FlxTypedGroup<StrumNote>;

				var ease = LuaUtils.getTweenEaseByString(value4);
						
				switch (value1)
					{
						case 'dad' | 'opponent':
						{
							strum = opponentStrums;
						
							if (ClientPrefs.data.middleScroll || PlayState.SONG.strumOffset == 'Enable MiddleScroll')
								flValue2 *= 0.35;
						}
						default:
							strum = playerStrums;
					}

				for (i in 0...strum.members.length)
					FlxTween.cancelTweensOf(strum.members[i].alpha);

				if (flValue3 == 0 || flValue3 == null)
				{
					for (i in 0...strum.members.length)
						strum.members[i].alpha = flValue2;
				}
				else
				{
					for (i in 0...strum.members.length)
						FlxTween.tween(strum.members[i], {alpha: flValue2}, Conductor.stepCrochet * flValue3 / 1000, {ease: ease});
				}

			case 'UI visibilty':
				if (flValue2 == 0 || flValue2 == null)
				{
					camHUD.alpha = flValue1;
				}
				else
				{
					var ease = LuaUtils.getTweenEaseByString(value3);
					FlxTween.tween(camHUD, {alpha: flValue1}, Conductor.stepCrochet * flValue2 / 1000, {ease: ease, onComplete: function(twn:FlxTween){}});
				}

			case 'Notes visibilty':
				if (flValue2 == 0 || flValue2 == null)
				{
					camNotes.alpha = flValue1;
				}
				else
				{
					var ease = LuaUtils.getTweenEaseByString(value3);
					FlxTween.tween(camNotes, {alpha: flValue1}, Conductor.stepCrochet * flValue2 / 1000, {ease: ease, onComplete: function(twn:FlxTween){}});
				}

			case 'Overlay visibilty':
				if (flValue2 == 0 || flValue2 == null)
				{
					camOverlayHUD.alpha = flValue1;
				}
				else
				{
					var ease = LuaUtils.getTweenEaseByString(value3);
					FlxTween.tween(camOverlayHUD, {alpha: flValue1}, Conductor.stepCrochet * flValue2 / 1000, {ease: ease, onComplete: function(twn:FlxTween){}});
				}

			case 'Force Dance':
				if(ClientPrefs.data.optimize) return;
				var char:Character = dad;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
				}

				if(!char.stunned)
				{
					char.specialAnim = false;
					char.dance(true);		
				}
			
			#if VIDEOS_ALLOWED
			case 'Play Video':
				if(ClientPrefs.data.optimize) return;
				curVideoTimestamp = Conductor.songPosition;
				playingVideo = true;
				startVideo(value1, true, false);	
				curVideoName = value1;

			#end
	
			case 'Hide Video':
				if(ClientPrefs.data.optimize) return;
				videoCutscene.alpha = 0.0001;
				playingVideo = false;

				if(videoCutscene != null) //crash safety
				{
					videoCutscene.destroy();
					videoCutscene = null;
				}

				var delete:VideoSprite = precachedVideos.get(curVideoName);
				if (delete != null) {
					precachedVideos.remove(curVideoName);
					delete.destroy();
					delete = null;
				}

			case 'Set Property':
				try
				{
					var trueValue:Dynamic = value2.trim();
					if (trueValue == 'true' || trueValue == 'false') trueValue = trueValue == 'true';
					else if (flValue2 != null) trueValue = flValue2;
					else trueValue = value2;

					var split:Array<String> = value1.split('.');
					if(split.length > 1) {
						LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1], trueValue);
					} else {
						LuaUtils.setVarInArray(this, value1, trueValue);
					}
				}
				catch(e:Dynamic)
				{
					trace('There is NO '+value1);
				}

			case 'Play Sound':
				if(FlxG.save.data.progressState == 2)
				{
					if(flValue2 == null) flValue2 = 1;
					FunkinSound.playOnce(Paths.sound(value1), flValue2);
					canPause = false;
				}

			case 'Show Song Default':
				if(ClientPrefs.data.optimize) return;
				if (taskDefault != null) taskDefault.start(); //если хочешь то вот

			//TOO FIRE GONE EVENTS
			case 'rain stop':
				if(ClientPrefs.data.optimize) return;
				lagJack = true;

			case 'Debug Trace':
				if(ClientPrefs.data.optimize) return;
				if (value2 == 'true')
					addTextToDebug(value1, FlxColor.YELLOW);
				else
					addTextToDebug(value1, FlxColor.RED);

			case 'Change Display Name':
				SONG.displayName = value1;

			case 'Hud Transition':
				healthBarBGOverlay.visible = false;
				timeBarBGOverlay.visible = false;
				ratingTxt.visible = false;
				scoreTxt_BP.visible = false;
				medal.visible = false;
				accuracyShit.visible = false;
				scoreTxt.visible = true;
				stageUI = 'normal';

				var songTxt:String = SONG.displayName == null ? SONG.song : SONG.displayName;

				if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.displayName == null ? SONG.song : SONG.displayName + " (" + storyDifficultyText + ")", '', true, songLength, SONG.song.toLowerCase());

				if (bottomBar != null) bottomBar.visible = true;
				if (topBar != null) topBar.visible = true;

				WindowUtil.setTitle("Pepper's Files: "+ songTxt);

				if (FlxG.save.data.doesHeKnow == false)
				{
					MusicBeatState.changeCursor(true);

					FlxG.save.data.doesHeKnow = true;
					FlxG.save.flush();
				}
		}

		// inline stagesFunc to avoid closure allocation in event hot path
		for (stage in stages)
			if (stage != null && stage.exists && stage.active)
				stage.eventCalled(eventName, value1, value2, value3, value4, value5, flValue1, flValue2, flValue3, flValue4, flValue5, strumTime);

		callOnScripts('onEvent', [eventName, value1, value2, value3, value4, value5, strumTime]);
	}

	public function moveCameraSection(?sec:Null<Int>):Void {
		if(sec == null) sec = curSection;
		if(sec < 0) sec = 0;

		if(SONG.notes[sec] == null) return;

		moveCamera();

		if (gf != null && SONG.notes[sec].gfSection)
		{
			callOnScripts('onMoveCamera', ['gf']);
			return;
		}

		var isDad:Bool = (SONG.notes[sec].mustHitSection != true);
		if (isDad)
			callOnScripts('onMoveCamera', ['dad']);
		else
			callOnScripts('onMoveCamera', ['boyfriend']);
	}

	public function moveCamera()
	{
		if(ClientPrefs.data.optimize) return;

		var targetX:Float = SONG.notes[curSection].followX;
		var targetY:Float = SONG.notes[curSection].followY;

		if (SONG.notes[curSection].followCam)
		{
			switch (SONG.notes[curSection].charFollow.toLowerCase())
			{
				case "bf":
					targetX += boyfriend.getMidpoint().x - boyfriend.cameraPosition[0] + boyfriendCameraOffset[0] - 100;
					targetY += boyfriend.getMidpoint().y + boyfriend.cameraPosition[1] + boyfriendCameraOffset[1] - 100;
					curFocusedChar = 'bf';
				case "gf":
					targetX += gf.getMidpoint().x + gf.cameraPosition[0] + girlfriendCameraOffset[0];
					targetY += gf.getMidpoint().y + gf.cameraPosition[1] + girlfriendCameraOffset[1];

					if(!SONG.notes[curSection].mustHitSection)
						curFocusedChar = 'dad';
					else
						curFocusedChar = 'bf';
				default:
					targetX += dad.getMidpoint().x + dad.cameraPosition[0] + opponentCameraOffset[0] + 150;
					targetY += dad.getMidpoint().y + dad.cameraPosition[1] + opponentCameraOffset[1] - 100;
					curFocusedChar = 'dad';
			}
	
			var ease:String = SONG.notes[curSection].tweenFollow;
			
			switch (ease)
			{
				case 'CLASSIC': // Old-school. No ease. Just set follow point.
					resetCamera(false, false, false);
					cancelCameraFollowTween();
					cameraFollowPoint.setPosition(targetX, targetY);
				case 'INSTANT': // Instant ease. Duration is automatically 0.
					tweenCameraToPosition(targetX, targetY, 0);
				default:
					var durSeconds:Float = Conductor.stepCrochet * SONG.notes[curSection].followTime / 1000;
					tweenCameraToPosition(targetX, targetY, durSeconds, LuaUtils.getTweenEaseByString(ease));
			}
		}

		if (SONG.notes[curSection].zoomCam)
		{
			var ease:String = SONG.notes[curSection].tweenZoom;

			switch(ease)
			{
				case "CLASSIC":
					var targetZoom = SONG.notes[curSection].zoom * (SONG.notes[curSection].stgZoom ? FlxCamera.defaultZoom : stageZoom);
					PlayState.instance.cancelCameraZoomTween();
					requiredZoom = targetZoom;
				case "INSTANT":
					var targetZoom = SONG.notes[curSection].zoom * (SONG.notes[curSection].stgZoom ? FlxCamera.defaultZoom : stageZoom);
					tweenCameraZoom(SONG.notes[curSection].zoom, 0, SONG.notes[curSection].stgZoom);
					requiredZoom = targetZoom;
				default:
					var durSeconds:Float = Conductor.stepCrochet * SONG.notes[curSection].zoomTime / 1000;
					tweenCameraZoom(SONG.notes[curSection].zoom, durSeconds, SONG.notes[curSection].stgZoom, LuaUtils.getTweenEaseByString(ease));
			}
		}
	}	

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		updateTime = false;
		FlxG.sound.music.volume = 0;

		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();

		if(ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong()
	{
		//Should kill you if you tried to cheat
		if(!startingSong)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset)
					health -= 0.05 * healthLoss;
			});
			for (daNote in unspawnNotes)
			{
				if(daNote != null && daNote.strumTime < songLength - Conductor.safeZoneOffset)
					health -= 0.05 * healthLoss;
			}

			if(doDeathCheck()) {
				return false;
			}
		}

		if(ClientPrefs.data.noteSkin == 'Ruby')
		{
			FlxG.save.data.rubySkin = true;
			FlxG.save.flush();
		}

		timeBar.visible = false;
		timeBarBG.visible = false;
		if (stageUI == 'bp') timeBarBGOverlay.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		var weekNoMiss:String = WeekData.getWeekFileName() + '_nomiss';
		checkForAchievement([weekNoMiss, 'ur_bad', 'ur_good', 'hype', 'two_keys', 'toastie' #if BASE_GAME_FILES, 'debugger' #end]);
		#end

		var ret:Dynamic = callOnScripts('onEndSong', null, true);
		if(ret != LuaUtils.Function_Stop && !transitioning)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(Song.loadedSongName, Std.int(songScore), storyDifficulty, variation, percent, songMisses, rank);
			#end

			if (!FlxG.save.data.completedSongs.contains(Paths.formatToSongPath(SONG.song.toLowerCase())))
				FlxG.save.data.completedSongs.push(Paths.formatToSongPath(SONG.song.toLowerCase()));

			var grade = (ratingsData[0].hits + ratingsData[1].hits - songMisses) / totalNotes;

			if (grade == 1.0 && !FlxG.save.data.completedPerfectSongs.contains(Paths.formatToSongPath(SONG.song.toLowerCase())))
				FlxG.save.data.completedPerfectSongs.push(Paths.formatToSongPath(SONG.song.toLowerCase()));

			if (ratingsData[0].hits == totalNotes && !FlxG.save.data.completedGoldenSongs.contains(Paths.formatToSongPath(SONG.song.toLowerCase())))
				FlxG.save.data.completedGoldenSongs.push(Paths.formatToSongPath(SONG.song.toLowerCase()));

			FlxG.save.flush();

			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return false;
			}

			if (isStoryMode)
			{
				totalStoryNotesHit += totalNotesHit;
				totalStoryPlayed += totalPlayed;
				fullNotes += totalNotes;
				songFullHits += songHits;

				campaignSicks += ratingsData[0].hits;
				campaignGoods += ratingsData[1].hits;
				campaignBads += ratingsData[2].hits;
				campaignShits += ratingsData[3].hits;
				
				if (combo > comboGot) comboGot = combo;

				if (comboGot > maxCombo) maxCombo = comboGot;

				campaignAccuracy = Math.min(1, Math.max(0, totalStoryNotesHit / totalStoryPlayed));

				campaignScore += Std.int(songScore);
				campaignMisses += songMisses;

				isFirstSongInCampaign = false;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxTransitionableState.skipNextTransIn = false;			
					FlxTransitionableState.skipNextTransOut = false;

					Mods.loadTopMod();
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

					canResync = false;

					if (Progression.weekProgress.exists(WeekData.getCurrentWeek().weekName))
					{
						Progression.weekProgress.remove(WeekData.getCurrentWeek().weekName);
						Progression.save();
					}

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty, variation);

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;

					if(curSong == 'Games Are Over' && FlxG.save.data.progressState == 6)
					{
						MusicBeatState.switchState(new funkin.menus.credits.EndingState());
						return true;
					}

					if(curSong == 'Doomsday' && FlxG.save.data.progressState == 4)
					{
						WindowUtil.setTitle("The VOID");
						MusicBeatState.switchState(new funkin.menus.void.VoidState());
						return true;
					}

					if(curSong == 'THE END' && FlxG.save.data.progressState == 2)
					{
						FlxG.save.data.chapter1Complete = true;
						FlxG.save.flush();
						WindowUtil.setTitle("...");
						MusicBeatState.switchState(new funkin.menus.lore.ChapterOneEndState());
						return true;
					}

					openResults();
				}
				else
				{
					var difficulty:String = Difficulty.getFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = SONG.toggleTransIn;			
					FlxTransitionableState.skipNextTransOut = SONG.toggleTransOut;

					Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					canResync = false;
					LoadingState.prepareToSong();
					LoadingState.loadAndSwitchState(new PlayState(), false, SONG.toggleTransIn);
				}
			}
			else
			{
				FlxTransitionableState.skipNextTransIn = false;			
				FlxTransitionableState.skipNextTransOut = false;

				trace('WENT BACK TO FREEPLAY??');
				Mods.loadTopMod();
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

				WindowUtil.setTitle("Pepper's Files");

				canResync = false;
				openResults();
				changedDifficulty = false;
			}
			transitioning = true;
		}
		return true;
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;
			invalidateNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public static var totalStoryPlayed:Int = 0;
	public static var totalStoryNotesHit:Float = 0.0;

	public var totalNotes:Int = 0;
	public static var fullNotes:Int = 0;

	public var showMiss:Bool = true;
	public var showCombo:Bool = true;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	// Stores Ratings and Combo Sprites in a group
	public var comboGroup:FlxSpriteGroup;
	// Stores HUD Objects in a Group
	public var uiGroup:FlxSpriteGroup;
	// Stores Note Objects in a Group
	public var noteGroup:FlxTypedGroup<FlxBasic>;
	// Stores HUD Objects after notes in a Group
	public var uiPostGroup:FlxSpriteGroup;

	private function cacheMedals()
	{
		for (i in 1...6)
			Paths.image('medals/medal_' + i);
	}

	var c_PBOT1_MISS = 160;
	var c_PBOT1_PERFECT = 5;
	var c_PBOT1_SCORING_OFFSET = 54.99;
	var c_PBOT1_SCORING_SLOPE = .08;
	var c_PBOT1_MAX_SCORE = 500;
	var c_PBOT1_MIN_SCORE = 5;
	private function popUpScore(note:Note = null):Void
	{
		var texture:String = 'miss';
		var lastCombo:Int = combo;

		if(note != null) 
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);

			//tryna do MS based judgment due to popular demand
			var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);
			var score:Int = c_PBOT1_MIN_SCORE;

			totalNotesHit += daRating.ratingMod;
			note.ratingMod = daRating.ratingMod;
			if(!note.ratingDisabled) daRating.hits++;
			note.rating = daRating.name;
			note.hitHealth = daRating.bonusHealth;

			if (noteDiff < c_PBOT1_PERFECT) score = c_PBOT1_MAX_SCORE;
			else if (noteDiff < c_PBOT1_MISS) {
				var factor:Float = 1.0 - (1.0 / (1.0 + Math.exp(-c_PBOT1_SCORING_SLOPE * (noteDiff - c_PBOT1_SCORING_OFFSET))));
				score = Std.int(c_PBOT1_MAX_SCORE * factor + c_PBOT1_MIN_SCORE);
			}

			if (onlySick && (noteDiff > ClientPrefs.data.sickWindow || noteDiff < -ClientPrefs.data.sickWindow))
				doDeathCheck(true);

			if(daRating.noteSplash && !note.noteSplashData.disabled && !PlayState.SONG.disableSplash) spawnNoteSplashOnNote(note);

			if(daRating.grayNote)
			{
				grayNoteEarly(note);
				killCombo();

				if(comboGot < 10)
				{
					if (lastCombo > startCombo) comboGot = lastCombo;
				}
				else
					if (lastCombo > comboGot) comboGot = lastCombo;

				gfComboBreak(lastCombo);
			}
			else
			{
				combo++;
				if(combo > 9999) combo = 9999;
			}

			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}

			texture = daRating.image;

			if(ClientPrefs.data.showMsTiming)
			{
				switch (note.rating)
				{
					case 'shit': currentTimingShown.color = FlxColor.RED;
					case 'bad': currentTimingShown.color = FlxColor.YELLOW;
					case 'good': currentTimingShown.color = FlxColor.CYAN;
					case 'sick': currentTimingShown.color = FlxColor.LIME;
				}
				FlxTween.cancelTweensOf(currentTimingShown);
				FlxTween.cancelTweensOf(currentTimingShown.alpha);
		
				currentTimingShown.text =  Math.round(Conductor.songPosition - note.strumTime) + "ms";
				currentTimingShown.antialiasing = ClientPrefs.data.antialiasing;
				currentTimingShown.alpha = 1;
			
				FlxTween.tween(currentTimingShown, {alpha: 0.00001},  Conductor.crochet * 0.002 / playbackRate);
			}
		}

		if(stageUI == 'bp')
		{
			FlxTween.cancelTweensOf(ratingTxt);
			FlxTween.cancelTweensOf(ratingTxt.alpha);
			ratingTxt.alpha = 1;
			ratingTxt.text = texture.toUpperCase() + ' x' + combo;
			ratingTxt.y = healthBar.y - 100;
			FlxTween.tween(ratingTxt, {y: healthBar.y - 125}, Conductor.crochet * 0.002, {ease: FlxEase.quadOut});
			FlxTween.tween(ratingTxt, {alpha: 0}, 0.2 / playbackRate, {startDelay: Conductor.crochet * 0.001 / playbackRate});
		}

		if(!ClientPrefs.data.hideHud && showRating)
		{
			if(stageUI == 'bp') return;
			FlxTween.cancelTweensOf(comboTxt);
			FlxTween.cancelTweensOf(comboTxt.alpha);
			comboTxt.alpha = 1;
			comboTxt.text = texture.toUpperCase();
			comboTxt.screenCenter(X);

			FlxTween.tween(comboTxt, {alpha: 0}, 0.2 / playbackRate, {
				startDelay: Conductor.crochet * 0.001 / playbackRate
			});
		}

		if(note != null) 
		{
			if(stageUI == 'bp') return;

			if(!ClientPrefs.data.hideHud)
				if (combo >= 10)
					displayCombo(comboGot);
		}
	}

	function displayCombo(?comboGet:Int):Void
	{
		if(stageUI == 'bp') return;

		if(showComboNum)
			comboTxt.text += '\n$combo';

		if (combo >= comboGet)
			if (showCombo)
				comboTxt.text += '\nCOMBO';

		comboTxt.screenCenter(X);
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getStrumFromKey(eventKey);

		if (!controls.controllerMode)
		{
			#if debug
			//Prevents crash specifically on debug without needing to try catch shit
			@:privateAccess if (!FlxG.keys._keyListMap.exists(eventKey)) return;
			#end

			if(FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
		}
	}

	private function keyPressed(key:Int)
	{
		if(cpuControlled || paused || inCutscene || key < 0 || key >= playerStrums.length || !generatedMusic || endingSong || controlledPlayer.stunned) return;

		var ret:Dynamic = callOnScripts('onKeyPressPre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		// more accurate hit time for the ratings?
		var lastTime:Float = Conductor.songPosition;
		if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		// obtain notes that the player can hit
		var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = n != null && !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit && n.visible;
			return canHit && !n.isSustainNote && n.noteData == key;
		});
		plrInputNotes.sort(sortHitNotes);

		if (plrInputNotes.length != 0) { // slightly faster than doing `> 0` lol
			var funnyNote:Note = plrInputNotes[0]; // front note

			if (plrInputNotes.length > 1) {
				var doubleNote:Note = plrInputNotes[1];

				if (doubleNote.noteData == funnyNote.noteData) {
					// if the note has a 0ms distance (is on top of the current note), kill it
					if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0)
						invalidateNote(doubleNote);
					else if (doubleNote.strumTime < funnyNote.strumTime)
					{
						// replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
						funnyNote = doubleNote;
					}
				}
			}
			goodNoteHit(funnyNote);
		}
		else
		{
			if (ClientPrefs.data.ghostTapping)
				callOnScripts('onGhostTap', [key]);
			else
				noteMissPress(key);
		}

		// Needed for the  "Just the Two of Us" achievement.
		//									- Shadow Mario
		if(!keysPressed.contains(key)) keysPressed.push(key);

		//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
		Conductor.songPosition = lastTime;

		var spr:StrumNote = playerStrums.members[key];
		if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
		{
			spr.playAnim('pressed');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyPress', [key]);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		if (a.isSustainNote || b.isSustainNote)
			if (a == null || b == null) return 0;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getStrumFromKey(eventKey);
		if(!controls.controllerMode && key > -1) keyReleased(key);
	}

	private function keyReleased(key:Int)
	{
		if(cpuControlled || !startedCountdown || paused || key < 0 || key >= playerStrums.length) return;

		var ret:Dynamic = callOnScripts('onKeyReleasePre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		var spr:StrumNote = playerStrums.members[key];
		if(spr != null)
		{
			spr.playAnim('static');
			spr.resetAnim = 0;
		}

		callOnScripts('onKeyRelease', [key]);
	}

	public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...arr.length)
			{
				var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
				for (noteKey in note)
					if(key == noteKey)
						return i;
			}
		}
		return -1;
	}

	// Build / refresh the FlxKey -> strum-index map from the current keysArray
	// and Controls bindings. Call this if the player rebinds keys mid-song.
	public function rebuildKeyToStrumMap():Void {
		final map:Map<FlxKey, Int> = new Map();
		final binds = Controls.instance.keyboardBinds;
		final keys = keysArray;
		final len = keys.length;
		for (i in 0...len) {
			final bound:Array<FlxKey> = binds[keys[i]];
			if (bound == null) continue;
			for (j in 0...bound.length) {
				final k = bound[j];
				if (k != NONE && !map.exists(k))
					map.set(k, i);
			}
		}
		_keyToStrum = map;
	}

	inline function getStrumFromKey(eventKey:FlxKey):Int {
		if (eventKey == NONE || _keyToStrum == null) return -1;
		final v = _keyToStrum.get(eventKey);
		return v == null ? -1 : v;
	}

	// Reusable per-frame buffers for keysCheck. Sized to keysArray once.
	private var _holdArray:Array<Bool> = null;
	private var _pressArray:Array<Bool> = null;
	private var _releaseArray:Array<Bool> = null;

	// Hold notes
	private function keysCheck():Void
	{
		final keys = keysArray;
		final klen = keys.length;

		var holdArray = _holdArray;
		var pressArray = _pressArray;
		var releaseArray = _releaseArray;
		if (holdArray == null || holdArray.length != klen) {
			holdArray = _holdArray = [for (_ in 0...klen) false];
			pressArray = _pressArray = [for (_ in 0...klen) false];
			releaseArray = _releaseArray = [for (_ in 0...klen) false];
		}

		final ctrl = controls;
		var anyHeld:Bool = false;
		var anyPressed:Bool = false;
		var anyReleased:Bool = false;
		for (i in 0...klen) {
			final k = keys[i];
			final h = ctrl.pressed(k);
			final p = ctrl.justPressed(k);
			final r = ctrl.justReleased(k);
			holdArray[i] = h;
			pressArray[i] = p;
			releaseArray[i] = r;
			if (h) anyHeld = true;
			if (p) anyPressed = true;
			if (r) anyReleased = true;
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ctrl.controllerMode && anyPressed)
			for (i in 0...klen)
				if(pressArray[i] && strumsBlocked[i] != true)
					keyPressed(i);

		if (startedCountdown && !inCutscene && !controlledPlayer.stunned && generatedMusic)
		{
			if (notes.length > 0) {
				final members = notes.members;
				final mlen = members.length;
				for (mi in 0...mlen) {
					final n = members[mi];
					if (n == null) continue;
					if (strumsBlocked[n.noteData] || !n.canBeHit || !n.mustPress || n.tooLate || n.wasGoodHit || n.blockHit) continue;
					if ((n.parent == null || !n.parent.wasGoodHit)) continue;
					if(n.isSustainNote)
					{
						if (holdArray[n.noteData])
							goodNoteHit(n);
						else
						{
							if (!n.released && n.active)
							{
								noteMiss(n);
								n.missed = true;
								n.released = true;
								n.active = false;
								n.canBeHit = false;
								n.ignoreNote = true;
								n.tooLate = true;
								n.alpha = 0;
								n.multAlpha = 0;
								popUpScore(null);
								killCombo();
							}
						}
					}
				}
			}

			if (!anyHeld || endingSong)
				playerDance();

			#if ACHIEVEMENTS_ALLOWED
			else checkForAchievement(['oversinging']);
			#end
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (anyReleased && (ctrl.controllerMode || anyStrumBlocked()))
			for (i in 0...klen)
				if(releaseArray[i] || strumsBlocked[i] == true)
					keyReleased(i);
	}

	function anyStrumBlocked():Bool {
		final sb = strumsBlocked;
		final len = sb.length;
		for (i in 0...len) if (sb[i] == true) return true;
		return false;
	}

	function createLanes()
	{
		if(ClientPrefs.data.laneUnderlay == 0) return;

		laneE0 = new FunkinSprite(0, -400).makeSolidColor(Std.int(Note.swagWidth) - 5, FlxG.height * 5, FlxColor.BLACK);
		laneE0.alpha = 0;
		laneE1 = new FunkinSprite(0, -400).makeSolidColor(Std.int(Note.swagWidth) - 5, FlxG.height * 5, FlxColor.BLACK);
		laneE1.alpha = 0;
		laneE2 = new FunkinSprite(0, -400).makeSolidColor(Std.int(Note.swagWidth) - 5, FlxG.height * 5, FlxColor.BLACK);
		laneE2.alpha = 0;
		laneE3 = new FunkinSprite(0, -400).makeSolidColor(Std.int(Note.swagWidth) - 5, FlxG.height * 5, FlxColor.BLACK);
		laneE3.alpha = 0;

		laneP0 = new FunkinSprite(0, -400).makeSolidColor(Std.int(Note.swagWidth) - 5, FlxG.height * 5, FlxColor.BLACK);
		laneP0.alpha = 0;
		laneP1 = new FunkinSprite(0, -400).makeSolidColor(Std.int(Note.swagWidth) - 5, FlxG.height * 5, FlxColor.BLACK);
		laneP1.alpha = 0;
		laneP2 = new FunkinSprite(0, -400).makeSolidColor(Std.int(Note.swagWidth) - 5, FlxG.height * 5, FlxColor.BLACK);
		laneP2.alpha = 0;
		laneP3 = new FunkinSprite(0, -400).makeSolidColor(Std.int(Note.swagWidth) - 5, FlxG.height * 5, FlxColor.BLACK);
		laneP3.alpha = 0;

		noteGroup.add(laneE0);
		noteGroup.add(laneE1);
		noteGroup.add(laneE2);
		noteGroup.add(laneE3);

		noteGroup.add(laneP0);
		noteGroup.add(laneP1);
		noteGroup.add(laneP2);
		noteGroup.add(laneP3);
	}

	function playMissSound():Void{
		if(missNoteSound != null) missNoteSound.stop();
		missNoteSound = FunkinSound.load(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2), false, false, true);
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
				invalidateNote(note);
		});

		// if the sustain splash exists, KILL KIL KILL IT KILL KI L KLLK LSKD:LKLK
		for (i in grpHoldSplashes.members)
		{
			if (i.data == daNote.noteData)
			{
				// actually.. no need to kill it.. itll kill itself anwyays
				i.alpha = 0.0;
				i.visible = false;
			}
		}

		noteMissCommon(daNote.noteData, daNote);

		// inline stagesFunc -- per-miss hot path
		for (stage in stages)
			if (stage != null && stage.exists && stage.active)
				stage.noteMiss(daNote);

		var result:Dynamic = callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('noteMiss', [daNote]);

		var charMiss:Character = daNote.gfNote ? gf : boyfriend;
		if(PlayState.SONG.swapPlayers)
		{
			if(opponentMode)
			{
				char = boyfriend;
			}
			else
			{
				char = dad;
			}
		}
		else
		{
			if(opponentMode)
			{
				char = dad;
			}
			else
			{
				char = boyfriend;
			}
		}
		if (charMiss != null) frozenCharacters.set(charMiss, false);
	}

	function opponentNoteMiss(daNote:Note):Void {
		daNote.hitByOpponent = true;

		// play character anims
		var char:Character = dad;
		if(PlayState.SONG.swapPlayers)
		{
			if(opponentMode)
			{
				char = dad;
			}
			else
			{
				char = boyfriend;
			}
		}
		else
		{
			if(opponentMode)
			{
				char = boyfriend;
			}
			else
			{
				char = dad;
			}
		}
		if((daNote != null && daNote.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;

		if(char != null && (daNote == null || !daNote.noMissAnimation) && char.hasMissAnimations)
		{
			var postfix:String = '';
			if(daNote != null) postfix = daNote.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, daNote.noteData)))] + 'miss' + postfix;
			if (!daNote.isSustainNote) char.playAnim(animToPlay, true);
			char.holdTimer = 0;
		}

		var result:Dynamic = callOnLuas('opponentNoteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteMiss', [daNote]);
	}

	function invisibleNoteHitPlayer(note:Note):Void
	{
		// play character anims
		var char:Character = boyfriend;
		if(PlayState.SONG.swapPlayers)
		{
			if(opponentMode)
			{
				char = boyfriend;
			}
			else
			{
				char = dad;
			}
		}
		else
		{
			if(opponentMode)
			{
				char = dad;
			}
			else
			{
				char = boyfriend;
			}
		}
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;

		if(char != null && (note == null || !note.noAnimation))
		{
			var suffix:String = '';
			if(note != null) suffix = note.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + suffix;

			if(!note.isSustainNote) char.playAnim(animToPlay, true); //sustain shit later im lazy zzzzzzzzzzzzz
			char.holdTimer = 0;
		}

		var result:Dynamic = callOnLuas('playerInvisibleNoteHit', [notes.members.indexOf(note), note.noteData, note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('playerInvisibleNoteHit', [note]);

		if (!note.isSustainNote) invalidateNote(note);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.data.ghostTapping) return; //fuck it

		noteMissCommon(direction, null);

		for (stage in stages)
			if (stage != null && stage.exists && stage.active)
				stage.noteMissPress(direction);

		callOnScripts('noteMissPress', [direction]);

		frozenCharacters.set(controlledPlayer, false);
	}

	function noteMissCommon(direction:Int, note:Note = null)
	{
		// score and data
		var subtract:Float = pressMissDamage;
		if(note != null) subtract = note.missHealth;

		// GUITAR HERO SUSTAIN CHECK LOL!!!!
		if (note != null && note.parent == null) {
			if(note.tail.length > 0) {
				note.alpha = 0.35;
				note.multAlpha = 0.35;
				for(childNote in note.tail) {
					childNote.alpha = note.alpha;
					childNote.multAlpha = note.alpha;
					childNote.missed = true;
					childNote.canBeHit = false;
					childNote.ignoreNote = true;
					childNote.tooLate = true;
				}
				note.missed = true;
				note.canBeHit = false;

				//subtract += 0.385; // you take more damage if playing with this gameplay changer enabled.
				// i mean its fair :p -Crow
				subtract *= note.tail.length + 1;
				// i think it would be fair if damage multiplied based on how long the sustain is -[REDACTED]
			}

			if (note.missed)
				return;
		}
		if (note != null && note.parent != null && note.isSustainNote) {
			if (note.missed)
				return;

			var parentNote:Note = note.parent;
			if (parentNote.wasGoodHit && parentNote.tail.length > 0) {
				parentNote.alpha = 0;
				parentNote.multAlpha = 0;
				for (child in parentNote.tail) if (child != note) {
					child.missed = true;
					child.alpha = parentNote.alpha;
					child.multAlpha = parentNote.multAlpha;
					child.canBeHit = false;
					child.ignoreNote = true;
					child.tooLate = true;
				}
			}
		}

		if(instakillOnMiss || onlySick)
		{
			vocals.volume = 0;
			opponentVocals.volume = 0;
			doDeathCheck(true);
		}

		var lastCombo:Int = combo;
		if(note != null)
		{
			if(showMiss /*&& !note.isSustainNote*/) popUpScore(null);
			killCombo();
			if(!endingSong) songMisses++;

			totalPlayed++;
		}

		if(comboGot < 10)
		{
			if (lastCombo > startCombo)
				comboGot = lastCombo;
		}
		else
		{
			if (lastCombo > comboGot)
				comboGot = lastCombo;
		}

		health -= subtract * healthLoss;
		if(!practiceMode) 
		{
			if(note != null)
				songScore -= 100;
			else
				songScore -= 10;
		}

		if(!practiceMode) RecalculateRating(true);

		if(ClientPrefs.data.missSounds) playMissSound();

		var noteTypeName:String = '';

		if(note != null)
			noteTypeName = note.noteType;

		// play character anims
		var char:Character = boyfriend;
		if(PlayState.SONG.swapPlayers)
		{
			if(opponentMode)
			{
				char = boyfriend;
			}
			else
			{
				char = dad;
			}
		}
		else
		{
			if(opponentMode)
			{
				char = dad;
			}
			else
			{
				char = boyfriend;
			}
		}
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;

		if(char != null && (note == null || !note.noMissAnimation) && char.hasMissAnimations)
		{
			switch(noteTypeName) { //wip for future notes idk
				default:
					var postfix:String = '';
					if(note != null)
					{
						postfix = note.animSuffix;

						if (!boyfriend.hasAnimation(singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + 'miss' + postfix))
							postfix = '';
					}

					var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + postfix;
					char.playAnim(animToPlay, true);
			}

			if(char != gf && note != null)
				gfComboBreak(lastCombo);
		}

		if(isLegacyVocals)
			vocals.volume = 0; 
		else
		{
			if(opponentMode)
				opponentVocals.volume = 0;
			else
				vocals.volume = 0; 
		}
	}

	/*function findCountAnimations(prefix:String):Array<Int>
	{
		var animNames:Array<String> = gf.animation.getNameList();
	  
		var result:Array<Int> = [];
	  
		for (anim in animNames)
		{
			if (anim.startsWith(prefix))
			{
				var comboNum:Null<Int> = Std.parseInt(anim.substring(prefix.length));
				if (comboNum != null)
					result.push(comboNum);
			}
		}
	  
		  // Sort numerically.
		  result.sort((a, b) -> a - b);
		  return result;
	}*/

	function gfComboBreak(comboBreak:Int)
	{
		var dropAnim:Null<String> = null;

		if (gf != null)
		{
			// Choose the combo drop anim to play.
    		// If there are several (for example, drop10 and drop50) the highest one will be used.
    			// If the combo count is too low, no animation will be played.
    		for (count in gf.dropNoteCounts)
			{
			  	if (comboBreak >= count)
			  	{
					dropAnim = 'drop$count';

					if (gf.hasAnimation(dropAnim))
					{
						gf.playAnim(dropAnim, true);
						gf.specialAnim = true;
					}
			  	}
			}
		}
	}

	function killCombo():Void
	{
		if (combo != 0)
		{
			combo = 0;
			displayCombo();
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		var result:Dynamic = callOnLuas('opponentNoteHitPre', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) result = callOnHScript('opponentNoteHitPre', [note]);

		if(result == LuaUtils.Function_Stop) return;

		var charPlay:Character = note.gfNote ? gf : dad;
		if(PlayState.SONG.swapPlayers)
		{
			if(opponentMode)
			{
				charPlay = dad;
			}
			else
			{
				charPlay = boyfriend;
			}
		}
		else
		{
			if(opponentMode)
			{
				charPlay = boyfriend;
			}
			else
			{
				charPlay = dad;
			}
		}
		if (charPlay != null) preNoteHitCheck(note, charPlay);

		if(songName == 'fire')
		{
			if(FlxG.save.data.progressState == 0)
				canLoop = true;
			else
			{
				FlxG.sound.music.onComplete();
			}
		}

		if(note.noteType == 'Jalapeno Note BOOM SOUND') {
			if(opponentMode)
				health +=  0.1;
			else
				if (health >= 1) health -=  0.1;

			fireHalapeno.alpha = 0.5;
			fireHalapeno.animation.play('idle', true);
			
			if (ClientPrefs.data.flashing)
				fireFlash.alpha = 0.2;

			if(ClientPrefs.data.camZooms)
			{
				cameraBopMultiplier += 0.02;
				camHudBopMult += 0.02;
				camNotesBopMult += 0.02;
			}
		}

		if(opponentMode) //compability for bf spaghetti
			if (note.animSuffix == '-alt2' && !boyfriend.hasAnimation(singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + '-alt2'))
				note.animSuffix = '-alt';

		if(opponentMode)
			if (!boyfriend.hasAnimation(singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix))
				note.animSuffix = '';

		var heyAnimation:String = 'hey';
		var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix;
		var char:Character = dad;
		if(PlayState.SONG.swapPlayers)
		{
			if(opponentMode)
			{
				char = dad;
			}
			else
			{
				char = boyfriend;
			}
		}
		else
		{
			if(opponentMode)
			{
				char = boyfriend;
			}
			else
			{
				char = dad;
			}
		}
		if(note.gfNote) char = gf;

		if(note.heyAnim != '0' && note.heyAnim != '' && note.heyAnim != null)
			heyAnimation = note.heyAnim;

		if(note.noteType == 'Hey!' && charPlay.hasAnimation(heyAnimation))
		{
			charPlay.playAnim(heyAnimation, true);
			charPlay.specialAnim = true;
			charPlay.heyTimer = 0.6;
		}
		
		if(!note.noAnimation)
		{
			if(char != null)
			{
				if(note.customSingTime == 0)
					char.singDuration = char.jsonDuration;
				else
					char.singDuration = note.customSingTime;

				var holdAnim:String = animToPlay + '-hold';
				if(note.sustainLength != 0 && char.hasAnimation(holdAnim)) 
					animToPlay = holdAnim;

				if(char == gf && lagJack)
				{
					if(FlxG.random.bool(60))
						animToPlay = animToPlay + '-old';

					if(FlxG.random.bool(40))
						animToPlay = animToPlay + '-boner';
				}

				if(!note.isSustainNote) char.playAnim(animToPlay, true);
				if(!note.isSustainNote && curStage == 'follow' && second.curCharacter != 'mimic-box' && char != gf) 
				{
					second.playAnim(animToPlay, true);
					second.holdTimer = 0;
				}

				if(note.isSustainNote && note.sustainType == 'stutter') //mm optimized way to do this?
					char.playAnim(animToPlay, true);

				char.holdTimer = 0;
			}
		}

		if(!note.isSustainNote && note.ghostType != '' && note.ghostType != null && note.ghostType != '0')
			doGhostAnim('dad', animToPlay + char.animSuffix, note.ghostType, note.noteData);

		if(isLegacyVocals) 
			vocals.volume = 1;
		else
			opponentVocals.volume = 1;

		if(!note.noAnimation)
		{
			var canMoveCam:Bool = false;

			if(PlayState.SONG.swapPlayers)
			{
				if(opponentMode)
				{
					if(curFocusedChar == 'dad') canMoveCam = true;
					else canMoveCam = false;
				}
				else
				{
					if(curFocusedChar == 'dad') canMoveCam = false;
					else canMoveCam = true;
				}
			}
			else
			{
				if(opponentMode)
				{
					if(curFocusedChar == 'dad') canMoveCam = false;
					else canMoveCam = true;
				}
				else
				{
					if(curFocusedChar == 'dad') canMoveCam = true;
					else canMoveCam = false;
				}
			}

			if(SONG.notes[curSection] != null && canMoveCam)
			{
				FlxG.camera.targetOffset.set(0,0);
				switch(note.noteData)
				{
					case 0:
						FlxG.camera.targetOffset.x = -noteCamOffset;
						FlxG.camera.targetOffset.y = 0;
					case 1:
						FlxG.camera.targetOffset.y = noteCamOffset;
						FlxG.camera.targetOffset.x = 0;
					case 2:
						FlxG.camera.targetOffset.y = -noteCamOffset;
						FlxG.camera.targetOffset.x = 0;
					case 3:
						FlxG.camera.targetOffset.x = noteCamOffset;
						FlxG.camera.targetOffset.y = 0;
				}
			}
		}

		if(opponentMode)
		{
			if(note.lightStrum) strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
		}
		else if((curSong != 'Too Fire' && curSong != "You Can't Fire" && curSong != 'Doomsday'))
		{
			if(note.lightStrum) strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
		}
		note.hitByOpponent = true;

		if(opponentMode)
		{
			if(note.visible && note.lightStrum) 
				if((ClientPrefs.data.opponentStrums && !PlayState.SONG.opponentDisabled) && !PlayState.SONG.disableHoldCover)
					spawnSusSplash(note, false);
		}
		else if((curSong != 'Too Fire' && curSong != "You Can't Fire" && curSong != 'Doomsday'))
		{
			if(note.visible && note.lightStrum) 
				if((ClientPrefs.data.opponentStrums && !PlayState.SONG.opponentDisabled) && !PlayState.SONG.disableHoldCover)
					spawnSusSplash(note, false);
		}

		if (opponentHealthDrain && health >= opponentHealthDrainAmount && !note.gfNote && note.noteType != 'GF Sing')
			health -= opponentHealthDrainAmount;

		if (singingShakeArray[1])
		{
			camGame.shake(0.005, 0.2);
			camHUD.shake(0.005, 0.2);
			camOverlayHUD.shake(0.005, 0.2);
			camNotes.shake(0.005, 0.2);
		}
		
		for (stage in stages)
			if (stage != null && stage.exists && stage.active)
				stage.opponentNoteHit(note);

		var result:Dynamic = callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHit', [note]);

		var charSus:Character = note.gfNote ? gf : dad;

		if(PlayState.SONG.swapPlayers)
		{
			if(opponentMode)
			{
				charSus = dad;
			}
			else
			{
				charSus = boyfriend;
			}
		}
		else
		{
			if(opponentMode)
			{
				charSus = boyfriend;
			}
			else
			{
				charSus = dad;
			}
		}

		if (charSus != null) noteHitCheck(note, charSus);

		if (!note.isSustainNote) invalidateNote(note);
	}

	function uniqueMedalChange(medalInt:Int) //почему не LERP? потому что Ease
	{
		FlxTween.cancelTweensOf(medal);
		FlxTween.cancelTweensOf(medal.scale);
		FlxTween.cancelTweensOf(medal.color);
		FlxTween.cancelTweensOf(medal.colorTransform);
		medal.scale.set(0.3, 0.3);
		medal.angle = 0;
		medal.colorTransform.redOffset = 0;
		medal.colorTransform.blueOffset = 0;
		medal.colorTransform.greenOffset = 0;
		medal.colorTransform.blueMultiplier = 1;
		medal.colorTransform.greenMultiplier = 1;
		medal.colorTransform.redMultiplier = 1;
		medal.color = 0xFFFFFFFF;
		switch(medalInt)
		{
			case 6:
				//вообще нихуя сосите
				//дебил?
			case 5:
				FlxTween.tween(medal.scale, {x: 0.4, y: 0.4}, Conductor.crochet * 0.002, {ease: FlxEase.quadOut, type: BACKWARD});
			case 4:
				FlxTween.tween(medal.scale, {x: 0.5, y: 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.backOut, type: BACKWARD});
			case 3:
				FlxTween.tween(medal.scale, {x: 0.5, y: 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.bounceOut, type: BACKWARD});
				FlxTween.tween(medal, {angle: 7}, Conductor.crochet * 0.002, {ease: FlxEase.backOut, type: BACKWARD});
			case 2:
				medal.color = 0xff7400ff;
				FlxTween.tween(medal.scale, {x: 0.6, y: 0.6}, Conductor.crochet * 0.002, {ease: FlxEase.expoOut, type: BACKWARD});
				FlxTween.tween(medal, {angle: 12}, Conductor.crochet * 0.002, {ease: FlxEase.bounceOut, type: BACKWARD});
				FlxTween.color(medal, Conductor.crochet * 0.002, medal.color, 0xffFFFFFF);
			case 1:
				medal.colorTransform.redOffset = 134;
				medal.colorTransform.greenOffset = 248;
				medal.colorTransform.blueOffset = 255;

				medal.colorTransform.redMultiplier = 0;
				medal.colorTransform.greenMultiplier = 0;
				medal.colorTransform.blueMultiplier = 0;

				FlxTween.tween(medal.scale, {x: 0.7, y: 0.7}, Conductor.crochet * 0.002, {ease: FlxEase.elasticOut, type: BACKWARD});
				FlxTween.tween(medal, {angle: 23}, Conductor.crochet * 0.002, {ease: FlxEase.expoOut, type: BACKWARD});
				FlxTween.tween(medal.colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0, redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1}, Conductor.crochet * 0.002);

				medal.x -= 50; //ТЫ ЧЕ ОХУЕЛ
		}
	}

	public function goodNoteHit(note:Note):Void
	{
		if(note.wasGoodHit) return;

		var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;

		var result:Dynamic = callOnLuas('goodNoteHitPre', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) result = callOnHScript('goodNoteHitPre', [note]);

		if(result == LuaUtils.Function_Stop) return;

		var charPlay:Character = note.gfNote ? gf : boyfriend;

		if(PlayState.SONG.swapPlayers)
		{
			if(opponentMode)
			{
				charPlay = boyfriend;
			}
			else
			{
				charPlay = dad;
			}
		}
		else
		{
			if(opponentMode)
			{
				charPlay = dad;
			}
			else
			{
				charPlay = boyfriend;
			}
		}

		if(ClientPrefs.data.showMsTiming)
		{
			currentTimingShown.x = playerStrums.members[1].x + 55;
			if(ClientPrefs.data.middleScroll || PlayState.SONG.strumOffset == 'Forced MiddleScroll') currentTimingShown.screenCenter(X);
			currentTimingShown.y = (!ClientPrefs.data.downScroll ? 20 : 510);
		}	

		if (charPlay != null) preNoteHitCheck(note, charPlay);

		note.wasGoodHit = true;
		note.noteWasHit = true; //пиздец что эту переменную не использовали

		if(!opponentMode) //compability for bf spaghetti
			if (note.animSuffix == '-alt2' && !boyfriend.hasAnimation(singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + '-alt2'))
				note.animSuffix = '-alt';

		if(!opponentMode)
			if (!boyfriend.hasAnimation(singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix))
				note.animSuffix = '';

		var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix;

		var char:Character = boyfriend;
		if(PlayState.SONG.swapPlayers)
		{
			if(opponentMode)
			{
				char = boyfriend;
			}
			else
			{
				char = dad;
			}
		}
		else
		{
			if(opponentMode)
			{
				char = dad;
			}
			else
			{
				char = boyfriend;
			}
		}

		var animCheck:String = 'hey';

		if (note.hitsoundVolume > 0 && !note.hitsoundDisabled)
			FunkinSound.playOnce(Paths.sound(note.hitsound), note.hitsoundVolume);

		if(!note.hitCausesMiss) //Common notes
		{
			if(!note.noAnimation)
			{
				if(note.gfNote)
				{
					char = gf;
					animCheck = 'cheer';
				}

				if(note.heyAnim != '0' && note.heyAnim != '' && note.heyAnim != null)
					animCheck = note.heyAnim;

				if(char != null)
				{
					if(note.customSingTime == 0)
						char.singDuration = char.jsonDuration;
					else
						char.singDuration = note.customSingTime;

					var holdAnim:String = animToPlay + '-hold';
					if(note.sustainLength != 0 && char.hasAnimation(holdAnim)) 
						animToPlay = holdAnim;
					
					if(!note.isSustainNote) char.playAnim(animToPlay, true);
					
					if(note.isSustainNote && note.sustainType == 'stutter') //mm optimized way to do this?
						char.playAnim(animToPlay, true);
				
					char.holdTimer = 0;

					if(note.noteType == 'Hey!')
					{
						if(char.hasAnimation(animCheck))
						{
							char.playAnim(animCheck, true);
							char.specialAnim = true;
							char.heyTimer = 0.6;
						}
					}
				}
			}

			if(!note.isSustainNote && note.ghostType != '' && note.ghostType != null && note.ghostType != '0')
				doGhostAnim((char == gf ? 'gf': 'bf'), animToPlay + char.animSuffix, note.ghostType, note.noteData);

			if(note.lightStrum)
			{
				if(!cpuControlled && !note.isInvisible)
				{
					var spr = playerStrums.members[note.noteData];
					if(spr != null && !note.isSustainNote) spr.playAnim('confirm', true, [note.rgbShader.r, note.rgbShader.g, note.rgbShader.b]);
					spr.holdTimer = 0;
				}
				else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
			}
			
			if(!Main.darnellMode && !opponentMode)
			{
				if(isLegacyVocals)
					vocals.volume = 1; 
				else
				{
					if(opponentMode)
						opponentVocals.volume = 1;
					else
						vocals.volume = 1; 
				}
			}

			if(Main.darnellMode && !opponentMode)
			{
				vocals.volume = 0;

				if(!note.isSustainNote)
				{
					if(darnellVoice != null) darnellVoice.stop();

					switch(note.noteData)
					{
						case 0:
							if(note.tail.length > 0)
							{
								darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/ah-long', 0, 1), false, false, true);
							}
							else
							{
								if(FlxG.random.bool(50))
								{
									if(FlxG.random.bool(50))
										darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/ah', 0, 1), false, false, true);
									else
										darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/chud', 0, 5), false, false, true);
								}
								else
								{
									if(FlxG.random.bool(50))
										darnellVoice = FunkinSound.load(Paths.sound('darnell/am0'), false, false, true);
									else
										darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/a', 0, 1), false, false, true);
								}
							}
						case 1:
							if(note.tail.length > 0)
							{
								darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/um', 0, 3), false, false, true);
							}
							else
							{
								if(FlxG.random.bool(50))
									darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/chud', 0, 5), false, false, true);
								else
								{
									if(FlxG.random.bool(50))
										darnellVoice = FunkinSound.load(Paths.sound('darnell/u0'), false, false, true);
									else
										darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/uh', 0, 1), false, false, true);
								}
							}
						case 2:
							if(note.tail.length > 0)
							{
								darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/ah-long', 0, 1), false, false, true);
							}
							else
							{
								if(FlxG.random.bool(50))
									darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/ah', 0, 1), false, false, true);
								else
								{
									if(FlxG.random.bool(50))
										darnellVoice = FunkinSound.load(Paths.sound('darnell/am0'), false, false, true);
									else
										darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/a', 0, 1), false, false, true);
								}
							}
						case 3:
							if(FlxG.random.bool(50))
							{
								if(FlxG.random.bool(50))
									darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/e', 0, 3), false, false, true);
								else
									darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/chud', 0, 5), false, false, true);
							}
							else
							{
								if(FlxG.random.bool(50))
									darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/ah', 0, 1), false, false, true);
								else
									darnellVoice = FunkinSound.load(Paths.soundRandom('darnell/pow', 0, 1), false, false, true);
							}
					}
				}
			}

			if(note.lightStrum && !PlayState.SONG.disableHoldCover && !note.isInvisible) spawnSusSplash(note, true);
			if (!note.isSustainNote && !note.autoplay)
			{
				var whichAnim:String = '';
				popUpScore(note);

				if(!opponentMode)
				{
					if (gf != null && gf.hasAnimation('combo$combo'))
					{
						gf.playAnim('combo$combo', true);
						gf.specialAnim = true;
					}

					if(boyfriend.curCharacter == 'bf-golden')
						doGhostAnim('bf', animToPlay + char.animSuffix, 'Ascend Ghost', note.noteData);
				}

				health += note.hitHealth * healthGain;
			}

			if(isPixelStage) if (note.isSustainNote) health += note.hitHealth * healthGain; //so it wont be smooth in week 6

		}
		else //Notes that count as a miss if you hit them (Hurt notes for example)
		{
			if(!note.noMissAnimation)
			{
				var charPlay:Character = note.gfNote ? gf : boyfriend;
				if(PlayState.SONG.swapPlayers)
				{
					if(opponentMode)
					{
						charPlay = boyfriend;
					}
					else
					{
						charPlay = dad;
					}
				}
				switch(note.noteType)
				{
					case 'Hurt Note':
						if(charPlay.hasAnimation('hurt'))
						{
							charPlay.playAnim('hurt', true);
							charPlay.specialAnim = true;
						}

					case 'Jalapeno Note NEW':
						FunkinSound.playOnce(Paths.sound('boom'), 0.6);
						
						health -= 0.06;

						fireHalapeno.alpha = 0.8;
						fireHalapeno.animation.play('idle', true);

						if (ClientPrefs.data.flashing)
							fireFlash.alpha = 0.6;

						if(ClientPrefs.data.camZooms)
						{
							FlxG.camera.zoom += 0.06;
							camHUD.zoom += 0.06;
						}
				}
			}

			if(note.lightStrum)
			{
				if(!cpuControlled && !note.isInvisible)
				{
					var spr = playerStrums.members[note.noteData];
					if(spr != null) spr.playAnim('confirm', true, [note.rgbShader.r, note.rgbShader.g, note.rgbShader.b]);
				}
				else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
			}

			noteMiss(note);
			if(!note.noteSplashData.disabled && !note.isSustainNote && !note.isInvisible && !PlayState.SONG.disableSplash) spawnNoteSplashOnNote(note);
		}

		if(!note.noAnimation)
		{
			var canMoveCam:Bool = false;

			if(PlayState.SONG.swapPlayers)
			{
				if(opponentMode)
				{
					if(curFocusedChar == 'dad') canMoveCam = false;
					else canMoveCam = true;
				}
				else
				{
					if(curFocusedChar == 'dad') canMoveCam = true;
					else canMoveCam = false;
				}
			}
			else
			{
				if(opponentMode)
				{
					if(curFocusedChar == 'dad') canMoveCam = true;
					else canMoveCam = false;
				}
				else
				{
					if(curFocusedChar == 'dad') canMoveCam = false;
					else canMoveCam = true;
				}
			}

			if(SONG.notes[curSection] != null && canMoveCam)
			{
				FlxG.camera.targetOffset.set(0,0);
				switch(note.noteData)
				{
					case 0:
						FlxG.camera.targetOffset.x = -noteCamOffset;
						FlxG.camera.targetOffset.y = 0;
					case 1:
						FlxG.camera.targetOffset.y = noteCamOffset;
						FlxG.camera.targetOffset.x = 0;
					case 2:
						FlxG.camera.targetOffset.y = -noteCamOffset;
						FlxG.camera.targetOffset.x = 0;
					case 3:
						FlxG.camera.targetOffset.x = noteCamOffset;
						FlxG.camera.targetOffset.y = 0;
				}
			}
		}

		if (singingShakeArray[0])
		{
			camGame.shake(0.005, 0.2);
			camHUD.shake(0.005, 0.2);
			camOverlayHUD.shake(0.005, 0.2);
			camNotes.shake(0.005, 0.2);
		}

		for (stage in stages)
			if (stage != null && stage.exists && stage.active)
				stage.goodNoteHit(note);

		var result:Dynamic = callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHit', [note]);

		var charSus:Character = note.gfNote ? gf : boyfriend;
		if(PlayState.SONG.swapPlayers)
		{
			if(opponentMode)
			{
				charSus = boyfriend;
			}
			else
			{
				charSus = dad;
			}
		}
		else
		{
			if(opponentMode)
			{
				charSus = dad;
			}
			else
			{
				charSus = boyfriend;
			}
		}
		if (charSus != null) noteHitCheck(note, charSus);

		if(!note.isSustainNote && !note.badassed) invalidateNote(note);
	}

	public function comboOnCamGame(enable:Bool, targetX:Float = 650, targetY:Float = 300)
	{
		comboIsInCamGame = enable;

		if(enable)
		{
			comboGroup.cameras = [camGame];
			offsetX = targetX; // How far to the right of the player you want the combo to appear
			offsetY = targetY; // How far above the player you want the combo to appear
			playerX = boyfriend.x;
			playerY = boyfriend.y;
		}
		else
		{
			comboGroup.cameras = [camHUD];
			playerX = 0;
			playerY = 0;
		}
	}

	public function grayNoteEarly(note:Note):Void 
	{
		if(!PlayState.SONG.disableNoteRGB)
		{
			note.rgbShader.r = 0xFFBFBFBF;
			note.rgbShader.g = 0xFFFFFFFF;
			note.rgbShader.b = 0xFF4D4D4D;
		}
		else //all colorSwap just for this man...
		{
			note.desaturate();
		}

		note.alpha = 0.4;
		note.multAlpha = 0.4;
		note.ignoreNote = true;
		note.blockHit = true;
		note.badassed = true;
		note.active = false;
	}

	public function textYOUappear():Void 
	{
		FlxTween.cancelTweensOf(textYou); //i know where you live
		FlxTween.tween(textYou, {alpha: 1}, Conductor.stepCrochet * 4 / 1000, {
			ease: FlxEase.expoOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(textYou, {alpha: 0}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.quadInOut, startDelay: 3});
				}
		});
	}

	//so originally this was port of @vechett codename engine script, port by goat @rodney528
	function preNoteHitCheck(note:Note, char:Character):Void {
		var charAnim:String = StringTools.startsWith(char.getAnimationName(), 'sing') ? char.getAnimationName() : singAnimations[note.noteData] + note.animSuffix;

		note.extraData.set('continueAnimation', false);
	}

	function noteHitCheck(note:Note, char:Character):Void {
		var prev:Bool = note.noAnimation;
		if (note.extraData.get('continueAnimation')) {
			note.noAnimation = false;
			char.holdTimer = 0;
		}
		if (!prev) {
			if (note.isSustainNote && note.sustainType == 'freeze')
				frozenCharacters.set(char, true);
			if (StringTools.endsWith(note.animation.name, 'end'))
				frozenCharacters.set(char, false);
		}
		/*if (StringTools.endsWith(char.getAnimationName(), '-hold') || StringTools.endsWith(char.getAnimationName(), '-loop'))*/
		//frozenCharacters.set(char, false);
	}

	public function invalidateNote(note:Note):Void {
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	public function spawnSusSplash(note:Note, isPlayer:Bool = false):SustainSplash
	{
		if (note.tail.length > 0)
		{
			final strum:Null<StrumNote> = strumLineNotes.members[note.noteData + (note.mustPress ? 4 : 0)];
			if (strum != null)
			{
				final data = note.noteData;
				
				// sustain length + step length (all in ms) to time the ending of the sustain covering
				final time = ((note.sustainLength + (Conductor.stepCrochet * 1.25)) / 1000);
				
				var splash:SustainSplash = grpHoldSplashes.recycle(SustainSplash);
				splash.setupSplash(strum, note, time, isPlayer);
				grpHoldSplashes.add(splash);

				return splash;
			}
		}
		
		return null;
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null)
				spawnNoteSplash(strum.x, strum.y, note.noteData, note, strum);
		}
	}

	public function spawnNoteSplash(x:Float = 0, y:Float = 0, ?data:Int = 0, ?note:Note, ?strum:StrumNote) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.babyArrow = strum;
		splash.spawnSplashNote(x, y, data, note);
		grpNoteSplashes.add(splash);
	}

	override function destroy() {
		if (funkin.psychlua.CustomSubstate.instance != null)
		{
			closeSubState();
			resetSubState();

			if (FlxG.save.data.doesHeKnow == true) WindowUtil.setTitle("Pepper's Files");
		}

		if (FlxG.save.data.doesHeKnow == true) WindowUtil.setTitle("Pepper's Files");

		#if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = null;
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				if(script.exists('onDestroy')) script.call('onDestroy');
				script.destroy();
			}

		hscriptArray = null;
		#end
		stagesFunc(function(stage:BaseStage) stage.destroy());

		#if VIDEOS_ALLOWED
		if(videoCutscene != null)
		{
			videoCutscene.destroy();
			videoCutscene = null;
		}

		for (vid in precachedVideos)
			if (vid != null)
			{
				vid.destroy();
				vid = null;
			}

		precachedVideos.clear();
		#end

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		FlxG.camera.filters = [];

		FlxG.sound.music.pitch = 1;
		FlxG.animationTimeScale = 1;

		if(isStoryMode || opponentMode || Main.raldman || Main.darnellMode)
			ClientPrefs.data.activeBfSkin = cacheBF;

		Note.globalRgbShaders = [];
		NoteTypesConfig.clearNoteTypesData();

		NoteSplash.configs.clear();
		instance = null;
		super.destroy();
	}

	public function addShaderToCamera(cam:String,effect:ShaderEffect){//GOT FROM ANDROMEDA ENGIN
		if(!ClientPrefs.data.shaders) return;

		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud':
				camHUDShaders.push(effect);
				var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for(i in camHUDShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camHUD.filters = newCamEffects;

			case 'camnotes' | 'notes':
				camNotesShaders.push(effect);
				var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for(i in camNotesShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camNotes.filters = newCamEffects ;
				
			case 'camhudoverlay' | 'overlay':
				camHudOverlayShaders.push(effect);
				var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for(i in camHudOverlayShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camOverlayHUD.filters = newCamEffects;

			case 'camother' | 'other':
				camOtherShaders.push(effect);
				var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for(i in camOtherShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camOther.filters = newCamEffects;

			default:
				camGameShaders.push(effect);
				var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for(i in camGameShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camGame.filters = newCamEffects;
		}
	}

	public function addRuntimeShaderToCamera(cam:String,effect:String){//GOT FROM ANY HSCRIPT LMAOOOOOO
		if(!ClientPrefs.data.shaders) return;

		initLuaShader(effect);
		var newShader:FlxRuntimeShader = createRuntimeShader(effect);

		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud':
				camHUDShaders.push(newShader);
				var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for(i in camHUDShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camHUD.filters = newCamEffects;

			case 'camnotes' | 'notes':
				camNotesShaders.push(newShader);
				var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for(i in camNotesShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camNotes.filters = newCamEffects;
				
			case 'camhudoverlay' | 'overlay':
				camHudOverlayShaders.push(newShader);
				var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for(i in camHudOverlayShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camOverlayHUD.filters = newCamEffects;

			case 'camother' | 'other':
				camOtherShaders.push(newShader);
				var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for(i in camOtherShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camOther.filters = newCamEffects;

			default:
				camGameShaders.push(newShader);
				var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
				for(i in camGameShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camGame.filters = newCamEffects;
		}
	}

	public function removeShaderFromCamera(cam:String,effect:ShaderEffect){
		if(!ClientPrefs.data.shaders) return;

		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': 
                camHUDShaders.remove(effect);
                var newCamEffects:Array<BitmapFilter>=[];
                for(i in camHUDShaders) newCamEffects.push(new ShaderFilter(i.shader));
                camHUD.filters = newCamEffects;

			case 'camnotes' | 'notes': 
                camNotesShaders.remove(effect);
                var newCamEffects:Array<BitmapFilter>=[];
                for(i in camNotesShaders) newCamEffects.push(new ShaderFilter(i.shader));
                camNotes.filters = newCamEffects;

			case 'camhudoverlay' | 'overlay': 
                camHudOverlayShaders.remove(effect);
                var newCamEffects:Array<BitmapFilter>=[];
                for(i in camHudOverlayShaders) newCamEffects.push(new ShaderFilter(i.shader));
                camOverlayHUD.filters = newCamEffects;

			case 'camother' | 'other': 
				camOtherShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camOtherShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camOther.filters = newCamEffects;

			default: 
				camGameShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camGameShaders) newCamEffects.push(new ShaderFilter(i.shader));
				camGame.filters = newCamEffects;
		}
	}

	public function clearShaderFromCamera(cam:String){
		if(!ClientPrefs.data.shaders) return;

		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': 
				camHUDShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camHUD.filters = newCamEffects;
			case 'camnotes' | 'notes': 
				camNotesShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camNotes.filters = newCamEffects;
			case 'camhudoverlay' | 'overlay': 
				camHudOverlayShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camOverlayHUD.filters = newCamEffects;
			case 'camother' | 'other': 
				camOtherShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camOther.filters = newCamEffects;
			default: 
				camGameShaders = [];
				var newCamEffects:Array<BitmapFilter>=[];
				camGame.filters = newCamEffects;
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();

		if (goHealthDamageBeat && curStep % Math.round(beatHealthStep) == 0) // :3 fuck my ass
			if (health >= beatHealthDrain)
				health -= beatHealthDrain;

		if(curStep == lastStepHit) {
			return;
		}

		if (boyfriend.curCharacter == 'bf-golden' && FlxG.random.bool(25))
		{
			var sparkle:FlxSprite = new FlxSprite(FlxG.random.float(boyfriendGroup.x, boyfriendGroup.x + 350), FlxG.random.float(boyfriendGroup.y + 400, boyfriendGroup.y + 600));
			sparkle.frames = Paths.getSparrowAtlas('characters/sparkle_gold');
			sparkle.animation.addByPrefix('idle', 'sparkle', 24, false);
			sparkle.animation.play('idle');
			sparkle.antialiasing = ClientPrefs.data.antialiasing;
			add(sparkle);

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				sparkle.kill();
				remove(sparkle, true);
				sparkle.destroy();
			});
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	var lastBeatHit:Int = -1;
	var customBopOffset:Float = 0.1; //if you wanna edit it then here you go
	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		iconP1.scale.set(boyfriend.iconScale + customBopOffset);
		iconP2.scale.set(dad.iconScale + customBopOffset);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		characterBopper(curBeat);

		if (FlxG.camera.zoom < 1.7 && cameraZoomRate > 0 && curBeat % cameraZoomRate == 0 && ClientPrefs.data.camZooms)
		{
			// Set zoom multiplier for camera bop.
			cameraBopMultiplier += cameraBopIntensity - 1;
			// HUD camera zoom still uses old system. To change. (+3%)
			camHudBopMult += hudCameraZoomIntensity;
			camNotesBopMult += hudCameraZoomIntensity;

			if(shakeBeat)
			{
				camGame.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
				camHUD.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
				camOverlayHUD.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
				camNotes.shake(0.003 * shakeDec, 1 / (Conductor.bpm / 60));
			}
		}

		super.beatHit();
		lastBeatHit = curBeat;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

	public function characterBopper(beat:Int):Void
	{
		if (gf != null && beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.getAnimationName().startsWith('sing') && !gf.stunned)
			gf.dance(gf.idleForce);

		if (boyfriend != null && beat % boyfriend.danceEveryNumBeats == 0 && !boyfriend.getAnimationName().startsWith('sing') && !boyfriend.stunned)
		{
			if(boyfriend.curCharacter == 'bf-zero')
			{
				if(FlxG.random.bool(20))
				{
					boyfriend.idleSuffix = '-alt';
					boyfriend.recalculateDanceIdle();
				}
				else
				{
					boyfriend.idleSuffix = '';
					boyfriend.recalculateDanceIdle();
				}
			}

			boyfriend.dance(boyfriend.idleForce);
		}


		if (dad != null && beat % dad.danceEveryNumBeats == 0 && !dad.getAnimationName().startsWith('sing') && !dad.stunned)
			dad.dance(dad.idleForce);
	}

	public function playerDance():Void
	{
		var anim:String = controlledPlayer.getAnimationName();
		if(controlledPlayer.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * controlledPlayer.singDuration && anim.startsWith('sing') && !anim.endsWith('miss'))
			controlledPlayer.dance();
	}

	override function sectionHit()
	{
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = SONG.notes[curSection].bpm;
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}
			setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnScripts('altAnim', SONG.notes[curSection].altAnim);
			setOnScripts('gfSection', SONG.notes[curSection].gfSection);
		}
		super.sectionHit();

		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	function introEnd()
	{
		var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
		black.scale.set(FlxG.width, FlxG.height);
		black.updateHitbox();
		black.alpha = 1;
		black.cameras = [camOther];
		add(black);

		ClientPrefs.data.noteSkin = 'Default';
		ClientPrefs.data.splashSkin = 'Default';

		var textEnd:FlxText = new FlxText(0, -44, FlxG.width, "Process is over\nThank you for participating\n\nBooting Up BP V2.exe Program...", 32);
		textEnd.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		textEnd.y = FlxG.height * 0.6;
		textEnd.scrollFactor.set();
		textEnd.cameras = [camOther];
		add(textEnd);

		FlxG.save.data.introduction = true;
		FlxG.save.flush();

		new FlxTimer().start(5, function(tmr:FlxTimer) {
			textEnd.visible = false;

			new FlxTimer().start(2, function(tmr:FlxTimer) {
				WindowUtil.setTitle('BP V2');
				Application.current.window.setIcon(Image.fromFile(Paths.getPath("images/pc_icons/icon_fake.png", IMAGE)));
				FlxG.switchState(new funkin.menus.IntroState());
			});
		});
	}

	public static var programList:Array<String> = [
		'obs32',
		'obs64',
		'streamlabs obs',
		'bdcam',
		'fraps',
		'xsplit',
		'hycam2',
		'twitchstudio'
	];

	function lastEnd()
	{
		FunkinSound.playOnce(Paths.sound('hui_final/speech_second'));

		//camOverlayHUD.fade(0xFF000000, 1, false, null, true);

		inCutscene = true;
		canPause = false;

		new FlxTimer().start(17, function(tmr:FlxTimer) {
			var taskList:Process = new Process('tasklist', []);
			var readableList:String = taskList.stdout.readAll().toString().toLowerCase();
			for (i in 0...programList.length)
			{
				if (readableList.contains(programList[i]))
				{
					Application.current.window.alert('Hey!\nI see you recording it!\nI recommend you to record the WHOLE screen on the next song\nbecause your program might not record something interesting, that is in the song\nOkie cya', "Warning!");
				}
			}

			taskList.close();
       		readableList = '';

			endSong();
		});

		return;
	}

	function huiEnd()
	{
		if(PlayState.storyPlaylist[1] == null)
		{
			WindowUtil.setTitle("...");
			FunkinSound.playOnce(Paths.sound('Lights_Shut_off'));
			FunkinSound.playOnce(Paths.sound('untitled_3854'));

			camOther.fade(0xFF000000, 0.0001, false, null, true);

			inCutscene = true;
			canPause = false;

			new FlxTimer().start(45, function(tmr:FlxTimer) {
				endSong();
			});

			return;
		}

		var nextSong:String = Paths.formatToSongPath(PlayState.storyPlaylist[1]);
		if(nextSong == 'triple-trouble')
		{
			FunkinSound.playOnce(Paths.sound('hui_voices/speech_obituary'));

			//camOther.fade(0xFF000000, 1, false, null, true);

			inCutscene = true;
			canPause = false;

			var lorkIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('tt-sequence/lork'));
			lorkIcon.screenCenter();
			lorkIcon.x -= 200;
			lorkIcon.alpha = 0.00001;
			lorkIcon.cameras = [camOther];
			add(lorkIcon);

			var shortIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('tt-sequence/short'));
			shortIcon.screenCenter();
			shortIcon.x -= 100;
			shortIcon.alpha = 0.00001;
			shortIcon.cameras = [camOther];
			add(shortIcon);

			var hwawIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('tt-sequence/hwaw'));
			hwawIcon.screenCenter();
			hwawIcon.x += 100;
			hwawIcon.alpha = 0.00001;
			hwawIcon.cameras = [camOther];
			add(hwawIcon);

			var bfIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('tt-sequence/bf'));
			bfIcon.screenCenter();
			bfIcon.x += 200;
			bfIcon.alpha = 0.00001;
			bfIcon.cameras = [camOther];
			add(bfIcon);

			bfIcon.scale.set(1.5, 1.5);
			hwawIcon.scale.set(1.5, 1.5);
			shortIcon.scale.set(1.5, 1.5);
			lorkIcon.scale.set(1.5, 1.5);

			//forgive me father, i failed you
			new FlxTimer().start(17, function(tmr:FlxTimer) {
				lorkIcon.alpha = 1;
				FunkinSound.playOnce(Paths.sound('cuts/blip_0'));
				new FlxTimer().start(0.1, function(tmr:FlxTimer) {
					shortIcon.alpha = 1;
					FunkinSound.playOnce(Paths.sound('cuts/blip_1'));
					new FlxTimer().start(0.1, function(tmr:FlxTimer) {
						hwawIcon.alpha = 1;
						FunkinSound.playOnce(Paths.sound('cuts/blip_2'));
						new FlxTimer().start(0.1, function(tmr:FlxTimer) {
							bfIcon.alpha = 1;
							FunkinSound.playOnce(Paths.sound('cuts/blip_3'));
							new FlxTimer().start(0.25, function(tmr:FlxTimer) {
								lorkIcon.alpha = 0;
								FunkinSound.playOnce(Paths.sound('cuts/blip_4'));
								new FlxTimer().start(0.1, function(tmr:FlxTimer) {
									shortIcon.alpha = 0;
									FunkinSound.playOnce(Paths.sound('cuts/blip_5'));
									new FlxTimer().start(0.1, function(tmr:FlxTimer) {
										hwawIcon.alpha = 0;
										FunkinSound.playOnce(Paths.sound('cuts/blip_6'));
										new FlxTimer().start(0.1, function(tmr:FlxTimer) {
											bfIcon.screenCenter();
											FunkinSound.playOnce(Paths.sound('cuts/blip_7'));
											new FlxTimer().start(1.3, function(tmr:FlxTimer) {
												bfIcon.alpha = 0;
												new FlxTimer().start(1.3, function(tmr:FlxTimer) {
													endSong();
												});
											});
										});
									});
								});
							});
						});
					});
				});
			});
		}
		else
		{
			FunkinSound.playOnce(Paths.sound('hui_voices/speech_tripletrouble'));

			//camOverlayHUD.fade(0xFF000000, 1, false, null, true);

			inCutscene = true;
			canPause = false;

			new FlxTimer().start(23, function(tmr:FlxTimer) {
				endSong();
			});
		}
	}

	public function setupCameraToSong()
	{
		if (SONG.charFocusStart == null)
		{
			if(!SONG.notes[0].mustHitSection)
			{
				cameraFollowPoint.setPosition(dad.getMidpoint().x + dad.cameraPosition[0] + opponentCameraOffset[0] + 150, dad.getMidpoint().y + dad.cameraPosition[1] + opponentCameraOffset[1] - 100);
				curFocusedChar = 'dad';
			}
			else
			{
				cameraFollowPoint.setPosition(boyfriend.getMidpoint().x + boyfriend.cameraPosition[0] + boyfriendCameraOffset[0] - 100, boyfriend.getMidpoint().y + boyfriend.cameraPosition[1] + boyfriendCameraOffset[1] - 100);
				curFocusedChar = 'bf';
			}
		}
		else
		{
			switch(SONG.charFocusStart)
			{
				case 'dad':
					cameraFollowPoint.setPosition(dad.getMidpoint().x + dad.cameraPosition[0] + opponentCameraOffset[0] + 150 + SONG.cameraOffsetX, dad.getMidpoint().y + dad.cameraPosition[1] + opponentCameraOffset[1] - 100 + SONG.cameraOffsetY);
					curFocusedChar = 'dad';

				case 'gf':
					cameraFollowPoint.setPosition(gf.getMidpoint().x + gf.cameraPosition[0] + girlfriendCameraOffset[0] + SONG.cameraOffsetX,  gf.getMidpoint().y + gf.cameraPosition[1] + girlfriendCameraOffset[1] + SONG.cameraOffsetY);

					if(!SONG.notes[curSection].mustHitSection)
						curFocusedChar = 'dad';
					else
						curFocusedChar = 'bf';

				default:
					cameraFollowPoint.setPosition(boyfriend.getMidpoint().x + boyfriend.cameraPosition[0] + boyfriendCameraOffset[0] - 100 + SONG.cameraOffsetX, boyfriend.getMidpoint().y + boyfriend.cameraPosition[1] + boyfriendCameraOffset[1] - 100 + SONG.cameraOffsetY);
					curFocusedChar = 'bf';
			}
		}
	}

	function resetCameraZoom():Void
	{
		// Apply camera zoom level from stage data.
		requiredZoom = currentCameraZoom = stageZoom;
		FlxG.camera.zoom = currentCameraZoom;
		
		// Reset bop multiplier.
		cameraBopMultiplier = 1.0;
	}
		
	public function resetCamera(?resetZoom:Bool = true, ?cancelTweens:Bool = true, ?snap:Bool = true):Void
	{
		resetZoom = resetZoom ?? true;
		cancelTweens = cancelTweens ?? true;
		
		// Cancel camera tweens if any are active.
		if (cancelTweens)
			cancelAllCameraTweens();
		
		FlxG.camera.follow(cameraFollowPoint, FlxCameraFollowStyle.LOCKON, 0.04);
		FlxG.camera.targetOffset.set();
		
		if (resetZoom)
			resetCameraZoom();
		
		// Snap the camera to the follow point immediately.
		if (snap) FlxG.camera.focusOn(cameraFollowPoint.getPosition());
	}
		
	function tweenCameraToPosition(?x:Float, ?y:Float, ?duration:Float, ?ease:Null<Float->Float>):Void
	{
		cameraFollowPoint.setPosition(x, y);
		tweenCameraToFollowPoint(duration, ease);
	}
		
	/**
	* Disables camera following and tweens the camera to the follow point manually.
	*/
	function tweenCameraToFollowPoint(?duration:Float, ?ease:Null<Float->Float>):Void
	{
		// Cancel the current tween if it's active.
		cancelCameraFollowTween();
		
		if (duration == 0)
		{
			// Instant movement. Just reset the camera to force it to the follow point.
			resetCamera(false, false);
		}
		else
		{
			// Disable camera following for the duration of the tween.
			FlxG.camera.target = null;

			canUpdate = false;
		
			// Follow tween! Caching it so we can cancel/pause it later if needed.
			var followPos:FlxBasePoint = FlxBasePoint.get(cameraFollowPoint.x - FlxG.camera.width * .5, cameraFollowPoint.y - FlxG.camera.height * .5);
			cameraFollowTween = FlxTween.tween(FlxG.camera.scroll, {x: followPos.x, y: followPos.y}, duration / playbackRate,
			{
				ease: ease,
				onComplete: function(_) {
					canUpdate = true;
					resetCamera(false, false); // Re-enable camera following when the tween is complete.
				}
			});
		}
	}
		
	function cancelCameraFollowTween()
	{
		if (cameraFollowTween != null)
			cameraFollowTween.cancel();

		canUpdate = true;
	}
		
	/**
	* Tweens the camera zoom to the desired amount.
	*/
	public function tweenCameraZoom(?zoom:Float, ?duration:Float, ?direct:Bool, ?ease:EaseFunction):Void
	{
		// Cancel the current tween if it's active.
		cancelCameraZoomTween();
		
		// Direct mode: Set zoom directly.
		// Stage mode: Set zoom as a multiplier of the current stage's default zoom.
		var targetZoom = zoom * (direct ? 1.0 : stageZoom);
		
		if (duration == 0)
			// Instant zoom. No tween needed.
			currentCameraZoom = targetZoom;
		else
			// Zoom tween! Caching it so we can cancel/pause it later if needed.
			cameraZoomTween = FlxTween.num(
				currentCameraZoom,
				targetZoom,
				duration / playbackRate,
				{ease: ease},
				function(num:Float) {currentCameraZoom = num;}
			);
	}
		
	function cancelCameraZoomTween()
	{
		if (cameraZoomTween != null)
			cameraZoomTween.cancel();
	}
		
	public function cancelAllCameraTweens()
	{
		cancelCameraFollowTween();
		cancelCameraZoomTween();
	}

	function setWeekProgress(song:Array<String>)
	{
		Progression.weekProgress.set(WeekData.getCurrentWeek().weekName, {song: song, weekMisees: campaignMisses, weekSocre: campaignScore, weekAccu:campaignAccuracy, weekTotalNo:fullNotes, weekTotalPlay:totalStoryPlayed, weekTotalHit:totalStoryNotesHit, maxSicks: campaignSicks, maxGoods: campaignGoods, maxBads: campaignBads, maxShits: campaignShits, songCampHits:songFullHits, maxComboLol: maxCombo});

		Progression.save();
	}

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getSharedPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getSharedPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad))
		{
			if (Iris.instances.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		var newScript:HScript = null;
		try
		{
			newScript = new HScript(null, file);
			if (newScript.exists('onCreate')) newScript.call('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		}
		catch(e:IrisError)
		{
			var pos:HScriptInfos = cast {fileName: file, showLine: false};
			Iris.error(Printer.errorToString(e, false), pos);
			var newScript:HScript = cast (Iris.instances.get(file), HScript);
			if(newScript != null)
				newScript.destroy();
		}
	}
	#end

	// Read-only sentinels so per-call default arguments don't allocate.
	// Anything assigned EMPTY_EXCLUSIONS / DEFAULT_EXCLUDE_VALUES must NOT
	// be mutated -- the dispatchers below treat them as immutable.
	private static final EMPTY_EXCLUSIONS:Array<String> = [];
	private static final DEFAULT_EXCLUDE_VALUES:Array<Dynamic> = [LuaUtils.Function_Continue];

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = EMPTY_EXCLUSIONS;
		if(excludeValues == null) excludeValues = DEFAULT_EXCLUDE_VALUES;

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = EMPTY_EXCLUSIONS;
		if(excludeValues == null) excludeValues = DEFAULT_EXCLUDE_VALUES;

		var arr:Array<FunkinLua> = null;
		for (script in luaArray)
		{
			if(script.closed)
			{
				if (arr == null) arr = [];
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if (script.closed) {
				if (arr == null) arr = []; 
				arr.push(script);
			}
		}

		if (arr != null)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) 
			exclusions = EMPTY_EXCLUSIONS;
		if(excludeValues == null)
			excludeValues = DEFAULT_EXCLUDE_VALUES;
		else if (!excludeValues.contains(LuaUtils.Function_Continue))
			excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;

		for(script in hscriptArray)
		{
			@:privateAccess
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var callValue = script.call(funcToCall, args);
			if(callValue != null)
			{
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
				{
					returnVal = myValue;
					break;
				}

				if(myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = EMPTY_EXCLUSIONS;
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = EMPTY_EXCLUSIONS;
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = EMPTY_EXCLUSIONS;
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	function doGhostAnim(char:String, animToPlay:String, mode:String, ?noteNum:Int)
	{
		if (ClientPrefs.data.optimize) return;
		if (ClientPrefs.data.lowQuality) return;

		//if(onlyChart) return;
		if(mode != 'Default Ghost' && mode != 'Arrow Movement Ghost' && 
			mode != 'Ascend Ghost' && mode != 'Fall Ghost' && mode != 'Left Velocity Ghost' &&
			mode != 'Right Velocity Ghost' && mode != 'Left and Right Velocity Ghost' && mode != 'Random Left and Right Velocity Ghost') return; //WTF IS A TRUE
		var player:Character = dad;

		var ghost:FlxAnimate;
	
		switch(char.toLowerCase().trim())
		{
			case 'bf' | 'boyfriend':
				if(opponentMode)
					player = dad;
				else
					player = boyfriend;
			case 'dad':
				if(opponentMode)
					player = boyfriend;
				else
					player = dad;
			case 'gf':
				player = gf;
		}

		if(!player.isAnimationNull())
		{
			var myAnim = player.animationsArray;
			var nameAnim:String = 'anim';

			for (anim in player.animationsArray)
			{
				if (anim.anim == animToPlay)
					nameAnim = anim.name;
			}

			ghost = new FlxAnimate();

			if(!player.isAnimateAtlas)
			{
				ghost.frames = Paths.getMultiAtlas(player.imageFile.split(','));
			}
			else
			{
				//TO DO: MAKE THEM EDITABLE
				ghost.applyStageMatrix = player.stageMatrix ?? false;
		
				ghost.frames = Paths.getMultiAnimateAtlas(player.imageFile.split(','));
				//frames = FlxAnimateFrames.fromAnimate(Paths.getPath('images/' + json.image));
			}

			ghost.anim.copyFrom(player.anim);

			if(player.isAnimateAtlas)
			{
				@:privateAccess
				var symbols:Array<String> = player.library.dictionary.keys().array();
				var frameLabels:Array<String> = player.listAnimations();

				if (frameLabels.contains(animToPlay))
				{
				  // Animation exists as a frame label but wasn't added, so we add it
				  ghost.anim.addByFrameLabel(animToPlay, nameAnim, ghost.library.frameRate, false);
				}
				else if (symbols.contains(animToPlay))
				{
				  // Animation exists as a symbol but wasn't added, so we add it
				  ghost.anim.addBySymbol(animToPlay, nameAnim, ghost.library.frameRate, false);
				}
			}

			ghost.flipX = player.isPlayer;

			if(player.isAnimateAtlas) 
			{
				ghost.useRenderTexture = true;
		
				var bx:Float = 0;
				var by:Float = 0;

				@:privateAccess
				if (ghost.timeline != null && ghost.timeline._bounds != null) {
					bx = ghost.timeline._bounds.x;
					by = ghost.timeline._bounds.y;
				}
				if (bx != 0 || by != 0)
					ghost.offset.set(player.offset.x - bx * player.scale.x,
						player.offset.y - by * player.scale.y);
			}

			if(!player.isAnimateAtlas)
			{
				ghost.animation.play(animToPlay, true, false);
			}
			else
			{
				ghost.anim.play(animToPlay, true, false);
			}
						
			ghost.setPosition(player.x, player.y);
			ghost.antialiasing = player.antialiasing;
			ghost.flipX = player.flipX;
		
			/*if(player.jsonScale != 1) {
				ghost.scale.set(player.scale.x, player.scale.y);
				ghost.updateHitbox();
			}*/

			ghost.scale.set(1, 1);
			ghost.updateHitbox();
		
			ghost.scale.copyFrom(player.scale);
			ghost.updateHitbox();

			if(player.curCharacter == 'bf-golden')
			{
				ghost.blend = ADD;
			}

			ghost.scrollFactor.set(player.scrollFactor.x, player.scrollFactor.y);
	
			var daOffset = player.animOffsets.get(animToPlay);

			ghost.offset.set(daOffset[0], daOffset[1]);
			ghost.visible = true;

			ghost.alpha = player.alpha - 0.3;
			//ghost.shader = player.shader; //Uncomment since some shaders are yuck with transparency
			ghost.angle = player.angle;
			ghost.visible = true;

			if(curStage == 'follow')
				ghost.color = 0xFFFF0000;
			else
				ghost.color = FlxColor.fromRGB(player.healthColorArray[0] + 50, player.healthColorArray[1] + 50, player.healthColorArray[2] + 50);

			if(player.isAnimateAtlas) ghost.useRenderTexture = true;
		}
		else
			return;

		switch (mode)
		{
			case 'Arrow Movement Ghost':
				switch(noteNum)
				{
					case 0:
						ghost.velocity.x = -140;
					case 1:
						ghost.velocity.y = 140;
					case 2:
						ghost.velocity.y = -140;
					case 3:
						ghost.velocity.x = 140;
				}
			case 'Ascend Ghost':
				ghost.velocity.y = FlxG.random.int(-240, -275);
				ghost.velocity.x = FlxG.random.int(-100, 100);

			case 'Fall Ghost':
				ghost.velocity.y = FlxG.random.int(240, 275);
				ghost.velocity.x = FlxG.random.int(-100, 100);

			case 'Left Velocity Ghost':
				ghost.velocity.x = -140;

			case 'Right Velocity Ghost':
				ghost.velocity.x = 140;

			case 'Left and Right Velocity Ghost':
				switch(noteNum)
				{
					case 0 | 1:
						ghost.velocity.x = -140;
					case 2 | 3:
						ghost.velocity.x = 140;
				}
			case 'Random Left and Right Velocity Ghost':
				ghost.velocity.x = FlxG.random.int(-140, 140);
		}

		switch(char.toLowerCase().trim())
		{
			case 'bf' | 'boyfriend':
				if(opponentMode)
					insert(members.indexOf(dadGroup), ghost);
				else
					insert(members.indexOf(boyfriendGroup), ghost);
			case 'dad':
				if(opponentMode)
					insert(members.indexOf(boyfriendGroup), ghost);
				else
					insert(members.indexOf(dadGroup), ghost);
			case 'gf':
				insert(members.indexOf(gfGroup), ghost);
		}
	
		FlxTween.tween(ghost, {alpha: 0.0001}, Conductor.crochet * 0.002, {
			ease: FlxEase.linear,
				onComplete: function(twn:FlxTween)
				{
					//ghost.kill();
					//remove(ghost, true);
					ghost.destroy();
				}
		});
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float, note:Note) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = opponentStrums.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			if(!note.isSustainNote) spr.playAnim('confirm', true, [note.rgbShader.r, note.rgbShader.g, note.rgbShader.b]);
			spr.resetAnim = time;
		}
	}

	public var ratingPercent:Float;
	public var ratingName:String = '?';
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false, scoreBop:Bool = true) {
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
		if(ret != LuaUtils.Function_Stop)
		{
			if(totalPlayed != 0) //Prevent divide by 0
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed)); // Rating Percent

			// Rating Name
			if(stageUI == 'bp')
			{
				ratingName = '?';
				ratingName = medal_system[medalStatus][2];
			}

			fullComboFunction();
		}
		setOnScripts('rating', ratingPercent);
		setOnScripts('ratingFC', ratingFC);
		setOnScripts('totalPlayed', totalPlayed);
		setOnScripts('totalNotesHit', totalNotesHit);
		updateScore(badHit, scoreBop); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null)
	{
		if(chartingMode) return;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice') || ClientPrefs.getGameplaySetting('botplay'));

		for (name in achievesToCheck) {
			if(!Achievements.exists(name)) continue;

			var unlock:Bool = false;
			if (name != WeekData.getWeekFileName() + '_nomiss') // common achievements
			{
				switch(name)
				{
					case 'ur_bad':
						unlock = (ratingPercent < 0.2 && !practiceMode);

					case 'ur_good':
						unlock = (ratingPercent >= 1 && !usedPractice);

					case 'oversinging':
						unlock = (boyfriend.holdTimer >= 10 && !usedPractice);

					case 'hype':
						unlock = (!boyfriendIdled && !usedPractice);

					case 'two_keys':
						unlock = (!usedPractice && keysPressed.length <= 2);

					case 'toastie':
						unlock = (!ClientPrefs.data.cacheOnGPU && !ClientPrefs.data.shaders && ClientPrefs.data.lowQuality && !ClientPrefs.data.antialiasing);

					#if BASE_GAME_FILES
					case 'debugger':
						unlock = (songName == 'test' && !usedPractice);
					#end
				}
			}
			else // any FC achievements, name should be "weekFileName_nomiss", e.g: "week3_nomiss";
			{
				if(isStoryMode && campaignMisses + songMisses < 1 && Difficulty.getDiffString().toUpperCase() == 'HARD'
					&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
					unlock = true;
			}

			if(unlock) Achievements.unlock(name);
		}
	}
	#end

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	#end
	public function createRuntimeShader(shaderName:String):ErrorHandledRuntimeShader
	{
		#if (!flash && sys)
		if(!ClientPrefs.data.shaders) return new ErrorHandledRuntimeShader(shaderName);

		if(!runtimeShaders.exists(shaderName) && !initLuaShader(shaderName))
		{
			FlxG.log.warn('Shader $shaderName is missing!');
			return new ErrorHandledRuntimeShader(shaderName);
		}

		var arr:Array<String> = runtimeShaders.get(shaderName);
		return new ErrorHandledRuntimeShader(shaderName, arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (!flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/'))
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else frag = null;

			if(FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else vert = null;

			if(found)
			{
				runtimeShaders.set(name, [frag, vert]);
				//trace('Found shader $name!');
				return true;
			}
		}
			#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
			addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
			#else
			FlxG.log.warn('Missing shader $name .frag AND .vert files!');
			#end
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}
}































/*
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

*/