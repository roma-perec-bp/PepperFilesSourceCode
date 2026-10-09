package funkin.menus.mainmenu;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import funkin.debug.editors.MasterEditorMenu;
import funkin.menus.options.OptionsState;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import flixel.input.keyboard.FlxKey;
import funkin.graphics.FunkinCamera;
import funkin.audio.FunkinSound;

class MainMenuState extends MusicBeatState
{
	public static var goldFunkVersion:String = '1.1.0'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var sunAdd:FlxSprite;

	var menuItems:FlxTypedGroup<FlxText>;
	var menuItemsShd:FlxTypedGroup<FlxText>;

	var objectsGroup:FlxTypedGroup<FlxSprite>;

	var staticTransition:FlxSprite;

	var lockMovement:Bool = false;
	var mouseMode:Bool = false;

	public var camGame:FunkinCamera;
	public var camHUD:FunkinCamera;

	var bg:FlxSprite;

	//Centered/Text options
	var optionFinal:Array<String> = [
		'story_mode',
		'freeplay',
		'options',
		'extra',
		'credits',
		'quit'
	];

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options',
		'quit'
	];

	public static var introActive:Bool = false;
	public static var playedIntro:Bool = false;

	public static var playSongAfterEnd:Bool = false;

	final easterEggKeys:Array<String> = [
		'DARNELL', 'BEEDAY', 'HUI', 'CTL', 'WATER', 'ITTDW', 'FIRE', 'PROTECTME', 'RALDMAN'
	];
	final allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	var entered:Bool = false;

	override function create()
	{
		funkin.menus.title.TitleState.initialized = true;

		MusicBeatState.changeCursor(true);
		FlxG.mouse.visible = true;

		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'), 0);
			FlxG.sound.music.fadeIn(4.0, 0.0, 1.0);
		}

		if(playSongAfterEnd) 
		{
			FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'), 1);
			playSongAfterEnd = false;
		}

		super.create();

		camGame = initPsychCamera('MainMenuCam');
		camHUD = new FunkinCamera('HudCam');
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("main_menu", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('mainmenu/HomeStatic');
		bg.animation.addByPrefix('idle', 'HomeStatic', 24, true);
		bg.animation.play('idle');
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		bg.scrollFactor.set(0.2, 0.2);

		var gay = new FlxSprite(0,0).loadGraphic(Paths.image('mainmenu/gay'));
		gay.antialiasing = ClientPrefs.data.antialiasing;
		gay.updateHitbox();
		gay.screenCenter();
		gay.blend = ADD;
		add(gay);

		gay.scrollFactor.set(0.2, 0.2);

		var sun:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('mainmenu/sun'));
		sun.antialiasing = ClientPrefs.data.antialiasing;
		sun.updateHitbox();
		sun.screenCenter();
		add(sun);

		sun.scrollFactor.set(0.2, 0.2);

		if(!ClientPrefs.data.lowQuality)
		{
			sunAdd = new FlxSprite(0, 0).loadGraphic(Paths.image('mainmenu/sun_glow'));
			sunAdd.antialiasing = ClientPrefs.data.antialiasing;
			sunAdd.updateHitbox();
			sunAdd.blend = ADD;
			sunAdd.screenCenter();
			add(sunAdd);
	
			sunAdd.scrollFactor.set(0.2, 0.2);
		}

		objectsGroup = new FlxTypedGroup<FlxSprite>();
		add(objectsGroup);

		var bg_ripple:FlxSprite = new FlxSprite(0, FlxG.height * 0.25);
		bg_ripple.frames = Paths.getSparrowAtlas('mainmenu/bg ripple');
		bg_ripple.animation.addByPrefix('idle', 'bg ripple', 24, true);
		bg_ripple.animation.play('idle');
		bg_ripple.antialiasing = ClientPrefs.data.antialiasing;
		bg_ripple.setGraphicSize(Std.int(bg_ripple.width * 1.2));
		bg_ripple.updateHitbox();
		bg_ripple.screenCenter(X);
		add(bg_ripple);

		bg_ripple.scrollFactor.set(0.45, 0.45);

		var bg_menu:FlxSprite = new FlxSprite(-42, -39);
		bg_menu.frames = Paths.getSparrowAtlas('mainmenu/bg_menu');
		bg_menu.animation.addByPrefix('idle', 'Symbol 1', 24, true);
		bg_menu.animation.play('idle');
		bg_menu.antialiasing = ClientPrefs.data.antialiasing;
		add(bg_menu);

		var name_logo:FlxText = new FlxText(35, 95, 0, "Pepper's\nFiles");
		name_logo.setFormat(Paths.font("vcr.ttf"), 78, FlxColor.RED, LEFT);
		add(name_logo);

		var name_logo_dark:FlxText = new FlxText(40, 100, 0, "Pepper's\nFiles");
		name_logo_dark.setFormat(Paths.font("vcr.ttf"), 78, 0xFF990000, LEFT);
		add(name_logo_dark);

		menuItemsShd = new FlxTypedGroup<FlxText>();
		add(menuItemsShd);

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		if(FlxG.save.data.completedGame) optionShit = optionFinal;

		for (num => option in optionShit)
		{
			var item:FlxText = createMenuItem(option, 40, (num * 60) + 300);
			var item:FlxText = createMenuDarkItem(option, 40, (num * 60) + 300);
		}

		var static_lol:FlxSprite = new FlxSprite();
		static_lol.frames = Paths.getSparrowAtlas('mainmenu/static');
		static_lol.animation.addByPrefix('idle', "static play", 24);
        static_lol.animation.play('idle');
		static_lol.setGraphicSize(Std.int(FlxG.width * 1.1));
		static_lol.updateHitbox();
		static_lol.screenCenter();
		static_lol.alpha = 0.5;
		static_lol.blend = OVERLAY;
		static_lol.scrollFactor.set();
		add(static_lol);

		if(!ClientPrefs.data.lowQuality)
		{
			var bgPizdec:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/overlay_bp'), Y);
			bgPizdec.blend = OVERLAY;
			bgPizdec.velocity.y = 100;
			add(bgPizdec);
		}

		var dark:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('mainmenu/dark'));
		dark.setGraphicSize(FlxG.width, FlxG.height);
		dark.screenCenter();
		dark.alpha = 1;
		add(dark);

		dark.cameras = [camHUD];

		var ver:FlxText = new FlxText(12, FlxG.height - 34, 0, "Pepper's Files v" + Application.current.meta.get('version'), 24);
		ver.scrollFactor.set();
		ver.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(ver);
		changeItem();

		ver.cameras = [camHUD];

		if(!ClientPrefs.data.lowQuality)
		{
			for (i in 0...30)
				createFloatObj(true);
	
			for (i in 0...6)
				createFloatObj();
		}

		staticTransition = new FlxSprite();
		staticTransition.frames = Paths.getSparrowAtlas('staticTV');
		staticTransition.animation.addByPrefix('idle', "static", 24);
        staticTransition.animation.play('idle');
		staticTransition.updateHitbox();
		staticTransition.screenCenter();
		staticTransition.scale.set(4,4);
		staticTransition.alpha = 0.00001;
		add(staticTransition);

		staticTransition.cameras = [camHUD];

		if(!playedIntro)
		{
			introActive = true;
			FlxG.camera.scroll.x -= 250;
			FlxG.camera.scroll.y += 100;
			FlxG.camera.zoom = 2;
			FlxTween.tween(FlxG.camera.scroll, {x: 0, y: 0}, 3, {ease: FlxEase.quadInOut});

			FlxTween.tween(FlxG.camera, {zoom: 1}, 3, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
				playedIntro = true;
				introActive = false;
			}});
		}
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxText
	{
		var menuItem:FlxText = new FlxText(x - 5, y - 5, 0, name.toUpperCase());
		menuItem.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.RED, LEFT);
		menuItem.scale.y = 1.2;

		menuItemsShd.add(menuItem);
		return menuItem;
	}

	function createMenuDarkItem(name:String, x:Float, y:Float):FlxText
	{
		var menuItemDark:FlxText = new FlxText(x, y, 0, name.toUpperCase());
		menuItemDark.setFormat(Paths.font("vcr.ttf"), 42, 0xFF990000, LEFT);
		menuItemDark.scale.y = 1.2;

		menuItems.add(menuItemDark);
		return menuItemDark;
	}

	var selectedSomethin:Bool = false;
	override function update(elapsed:Float)
	{
		if(introActive == false)
		{
			var mouse = FlxG.mouse.getScreenPosition(camGame);
			FlxG.camera.scroll.set(FlxMath.lerp(FlxG.camera.scroll.x, (mouse.x / 60) - 20, elapsed * 3), FlxMath.lerp(FlxG.camera.scroll.y, (mouse.y / 60) - 20, elapsed * 3));
		}

		if (FlxG.sound.music.volume < 0.8 && !entered)
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

		if (FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) mouseMode = true;

		var dist:Float = -1;
		var distItem:Int = -1;
		if (!selectedSomethin && introActive == false && mouseMode)
		{
			var selectedItem:FlxSprite;
			selectedItem = menuItems.members[curSelected];

			for (i in 0...optionShit.length)
			{
				var memb:FlxSprite = menuItems.members[i];
				if (FlxG.mouse.overlaps(memb))
				{
					var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
					if (dist < 0 || distance < dist)
					{
						dist = distance;
						distItem = i;
					}

					if(FlxG.mouse.justPressed && mouseMode)
						select();
				}
			}

			if(distItem != -1 && selectedItem != menuItems.members[distItem])
			{
				curSelected = distItem;
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/key_select'), 1);
				changeItem();
			}
		}

		if (!selectedSomethin && introActive == false)
		{
			if (controls.UI_UP_P)
			{
				changeItem(-1);
				mouseMode = false;
			}

			if (controls.UI_DOWN_P)
			{
				changeItem(1);
				mouseMode = false;
			}

			if (controls.ACCEPT && !mouseMode)
			{
				select();
			}
		}

		super.update(elapsed);

		if(FlxG.random.bool(1) && !ClientPrefs.data.lowQuality)
			createFloatObj();

		if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
		{
			var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
			var keyName:String = Std.string(keyPressed);
			if(allowedKeys.contains(keyName)) {
				easterEggKeysBuffer += keyName;
				if(easterEggKeysBuffer.length >= 32) easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
				//trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

				for (wordRaw in easterEggKeys)
				{
					var word:String = wordRaw.toUpperCase(); //just for being sure you're doing it right
					if (easterEggKeysBuffer.contains(word))
					{
						//trace('YOOO! ' + word);
						switch(word)
						{
							case 'WATER' | 'ITTDW':
								FunkinSound.playOnce(Paths.sound('ittdw'));
							case 'HUI':
								FunkinSound.playOnce(Paths.sound('games'));
							case 'FIRE':
								FunkinSound.playOnce(Paths.sound('hahaha'));
							case 'CTL':
								FunkinSound.playOnce(Paths.sound('ctl'));
							case 'PROTECTME':
								FunkinSound.playOnce(Paths.sound('protectme'));
							case 'DARNELL':
								Main.raldman = false;
								Main.darnellMode = !Main.darnellMode;

								if(Main.darnellMode)
									FunkinSound.playOnce(Paths.sound('darnell_activate'));
								else
									FunkinSound.playOnce(Paths.sound('darnell_deactivate'));
							case 'RALDMAN':
								Main.darnellMode = false;
								Main.raldman = !Main.raldman;

								if(Main.raldman)
									FunkinSound.playOnce(Paths.sound('raldman'));
								else
									FunkinSound.playOnce(Paths.sound('raldman_off'));

							case 'BEEDAY':
								selectedSomethin = true;
								
								FlxG.sound.play(Paths.sound('secret'));

								var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
								black.scale.set(FlxG.width, FlxG.height);
								black.updateHitbox();
								black.alpha = 0;
								black.cameras = [camHUD];
								entered = true;
								add(black);
		
								FlxTween.tween(black, {alpha: 1}, 3, {onComplete:
									function(twn:FlxTween) {
										FlxTransitionableState.skipNextTransIn = true;
										FlxTransitionableState.skipNextTransOut = true;
										MusicBeatState.switchState(new funkin.menus.arg.ArgState());
									}
								});
								FlxG.sound.music.fadeOut();			
						}
						easterEggKeysBuffer = '';
					}
				}
			}
		}
	}

	function select()
	{
		FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));
		selectedSomethin = true;
		//FlxG.mouse.visible = false;

		var item:FlxSprite;
		var option:String;

		option = optionShit[curSelected];
		item = menuItems.members[curSelected];

		staticTransition.alpha = 1;
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			switch (option)
			{
				case 'story_mode':
					MusicBeatState.switchState(new funkin.menus.storymenu.StoryMenuState());
				case 'freeplay':
					MusicBeatState.switchState(new funkin.menus.freeplay.FreeplayState());
				case 'credits':
					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;
					MusicBeatState.switchState(new funkin.menus.credits.SecondEndingState());
				case 'options':
					MusicBeatState.switchState(new funkin.menus.real_options.RealOptionsState());
					OptionsState.onPlayState = false;
					if (PlayState.SONG != null)
					{
						PlayState.SONG.arrowSkin = null;
						PlayState.SONG.splashSkin = null;
						PlayState.stageUI = 'normal';
					}
				case 'extra':
					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;
					MusicBeatState.switchState(new funkin.menus.extra.ExtraState());	
				case 'quit':
					openfl.Lib.application.window.close();
				default:
					trace('Menu Item ${option} doesn\'t do anything');
					selectedSomethin = false;
					item.visible = true;
			}
		});
	}

	function createFloatObj(random_X:Bool = false)
	{
		var objsize:Float = FlxG.random.float(0.1, 0.3);

		var act4Obj:FlxSprite = new FlxSprite(FlxG.width + 200, FlxG.random.int(-250, FlxG.height));
		act4Obj.frames = Paths.getSparrowAtlas("mainmenu/objects_flying");
		act4Obj.animation.addByPrefix('0', 'obj_0', 24, true);
		act4Obj.animation.addByPrefix('1', 'obj_1', 24, true);
		act4Obj.animation.addByPrefix('2', 'obj_2', 24, true);
		act4Obj.animation.addByPrefix('3', 'obj_3', 24, true);
		act4Obj.animation.addByPrefix('4', 'obj_4', 24, true);
		act4Obj.animation.addByPrefix('5', 'obj_5', 24, true);
		act4Obj.animation.addByPrefix('6', 'obj_6', 24, true);
		act4Obj.animation.play(FlxG.random.int(0,6) + '', true);
		act4Obj.angle = FlxG.random.int(0,360);
		act4Obj.scale.set(objsize, objsize);
		objectsGroup.add(act4Obj);

		act4Obj.scrollFactor.set(0.7, 0.7);

		if(random_X)
			act4Obj.x = FlxG.random.float(0,FlxG.width);

		var tweenspeed:Float = FlxG.random.int(95, 220) / (7 + (1 * 3));

		if (FlxG.random.bool(50))
			FlxTween.tween(act4Obj, {angle: act4Obj.angle + FlxG.random.int(90, 360)}, tweenspeed);
		else
			FlxTween.tween(act4Obj, {angle: act4Obj.angle - FlxG.random.int(90, 360)}, tweenspeed);
										
		FlxTween.tween(act4Obj, {x: -450}, tweenspeed, {onComplete: function(twn:FlxTween)
		{
			act4Obj.destroy();
		}});
	}

	function changeItem(change:Int = 0)
	{
		var prevEntry:Int = curSelected;

		curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);

		if (curSelected != prevEntry)
			FunkinSound.playOnce(Paths.sound('real_menu_sounds/key_select'), 1);

		for (item in menuItems)
			item.alpha = 0.4;

		for (item in menuItemsShd)
			item.alpha = 0.4;

		var selectedItem:FlxSprite;
		selectedItem = menuItems.members[curSelected];
		var selectedItem2:FlxSprite;
		selectedItem2 = menuItemsShd.members[curSelected];

		selectedItem.alpha = 1;
		selectedItem2.alpha = 1;
	}
}
