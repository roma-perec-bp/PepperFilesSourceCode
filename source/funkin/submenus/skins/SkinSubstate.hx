package funkin.submenus.skins;

import funkin.data.WeekData;
import funkin.data.Highscore;
import funkin.data.Song;

import flixel.util.FlxStringUtil;
import funkin.audio.FunkinSound;
import flixel.input.keyboard.FlxKey;

import funkin.menus.storymenu.StoryMenuState;
import funkin.menus.freeplay.FreeplayState;
import funkin.menus.real_options.RealOptionsState;

import openfl.utils.Assets;

class SkinSubstate extends MusicBeatSubstate
{
	var grpSkins:FlxTypedGroup<FlxSprite>;
	var curSelected:Int = 0;

	var leftArrows:FlxSprite;
	var rightArrows:FlxSprite;

	var bfSkin:Array<String> =
	[
		'default', //done
		'classic', //done
		'mm', //done
		'sonic-legacy', //done 
		'indie-cross', //done
		'minus1', //done
		'zero', //done
		'badtime',
		'basement', //done
		'ourple', //done
		'pixel', //done
		'romstyle', //done
		'spaghetti', //done
		'downtown', //done
		'encore', //done
		'romfriend', //done
		'minus2', //done
		'minus3', //done
		'bad', //done
		'ruby',
		'gold', //done
		'bp', //done
		'bp-dlc', //done
		'legacy' //done
	];

	var plates:Array<String> =
	[
		'DEFAULT BF',
		'CLASSIC BF',
		'MARIO MADNESS BF',
		'SONIC LEGACY BF',
		'INDIE CROSS BF',
		'MINUS BOYFRIEND (BLUE)',
		'ZEO ANIMATION BF',
		'BADTIME BOYFRIEND',
		'BASEMENT SHOW BOYFRIEND',
		'OURPLE BOYFRIEND',
		'PIXEL BOYFRIEND',
		'BOYFRIEND IN ROM-STYLE',
		'REDRAWN BOYFRIEND',
		'ONESHOT MANIA BOYFRIEND',
		'ENCORE BOYFRIEND',
		'ROMFRIEND',
		'MINUS BOYFRIEND (YELLOW)',
		'MINUS BOYFRIEND (RED HAT)',
		'BAD BOYFRIEND',
		'RUBY BOYFRIEND',
		'GOLDEN BOYFRIEND',
		'FUN-SIZE PEPPERFRIEND',
		'3D BOYFRIEND',
		'BOYFRIEND IN ROM-STYLE OLD'
	];

	var unlocks:Array<Bool> =
	[
		true,
		true,
		true,
		true,
		true,
		true,
		StoryMenuState.weekCompleted.exists('weekexe'),
		getV6save(),
		getWCsave(),
		getWCsave(),
		getCaseSave(),
		StoryMenuState.weekCompleted.exists('weekfinal'),
		FlxG.save.data.completedGame,
		getFCcomplete(),
		getFCEXEcomplete(),
		FlxG.save.data.finishedArg,
		getFCWEEKPcomplete(),
		getFCWEEKPBFcomplete(),
		FlxG.save.data.gotLoss,
		FlxG.save.data.rubySkin,
		FlxG.save.data.completedGoldenSongs.length >= 6,
		getOGsave(),
		getDLCsave(),
		getLegacysave()
	];

	var unlocks_text:Array<String> =
	[
		"Default Player\nWon't change any initial Boyfriend Appearence",
		'All favourite classic!\nUnlocked by Default',
		'Mario Madness is the nest mod ever\nUnlocked by Default',
		'I guess you got caught by "RodenTrap"\nUnlocked by Default',
		'Our lovely tweenie boi\nUnlocked by Default',
		'Ah... So nostalgic, can\'t believe it died\nUnlocked by Default',
		'Remember when this was used almost everywhere?\nUnlocked by completing Week EXE',
		'You\'re gonna have a BAD TIME (get it?)\nUnlocked by completing BP V6 Build',
		'This mod sucks ngl, but it\'s also funny\nUnlocked by completing BP Wokeless Edition Build',
		'WHO ARE YOU? AND WHY ARE YOU AN OURPLE!?\nUnlocked by completing BP Wokeless Edition Build',
		'SoRetro\nUnlocked by completing Pepper\'s Case Build',
		'Style is finally stylized and finalized!\nUnlocked by completing Week Finale',
		'This is the hot spot\nUnlocked by completing the whole mod',
		'Wdym they call him also "DownTowm Philly" BF?\nUnlocked by P-ranking all songs in THIS Build',
		'Not again...\nUnlocked by P-ranking all song from Week EXE',
		'What the fuck is that\nUnlocked by finding something interesting',
		'I wonder why there is more of him?\nUnlocked by P-ranking all songs from Week P 2',
		'Does that means all 3 of them fucks GF at the same time?\nUnlocked by P-ranking all songs from Week P (BF Mix)',
		'Oh god, are we doing this again?\nUnlocked by getting L-rank',
		'How this one got here!?\nUnlocked by playing any song with "special" noteskin',
		'I\'m GOLD\nUnlocked by Gold P-ranking 6 songs from THIS Build',
		'Just like in 2021\nUnlocked by having save file of Original Brutal Pizdec',
		'YOU CANNOT FUCK US\nUnlocked by having save file of Brutal Pizdec Impotence DLC',
		'You\'re so OLD\nUnlocked by having save file of Pepper\'s Files Legacy'
	];

	var titleText:FlxText;
	var descText:FlxText;
	var backButt:FlxSprite;

	override function create()
	{
		FlxG.mouse.visible = true;

		var num:Int = bfSkin.indexOf(getValue());
		curSelected = num;

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);
		
		var topBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 170, FlxColor.BLACK);
		add(topBar);
		var bottomBar:FlxSprite = new FlxSprite(0, 550).makeGraphic(FlxG.width, 170, FlxColor.BLACK);
		add(bottomBar);

		grpSkins = new FlxTypedGroup<FlxSprite>();
		add(grpSkins);

		for (i in 0...24)
		{
			var bf:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bf_skins/'+i));
			bf.antialiasing = ClientPrefs.data.antialiasing;
			bf.ID = i;
			bf.screenCenter();
			grpSkins.add(bf);

			if(unlocks[i] == false) bf.color = 0xFF000000;
		}

		final ui_tex = Paths.getSparrowAtlas('bf_skins/arrows');

		if (leftArrows == null){
			leftArrows = new FlxSprite(20, 300);
			leftArrows.antialiasing = ClientPrefs.data.antialiasing;
			leftArrows.frames = ui_tex;
			leftArrows.animation.addByPrefix('idle', "leftIdle");
			leftArrows.animation.addByPrefix('press', "leftConfirm");
			leftArrows.animation.play('idle');
			leftArrows.screenCenter(Y);
		}
		add(leftArrows);

		if (rightArrows == null){
			rightArrows = new FlxSprite(FlxG.width * 0.94, leftArrows.y);
			rightArrows.antialiasing = ClientPrefs.data.antialiasing;
			rightArrows.frames = ui_tex;
			rightArrows.screenCenter(Y);
			rightArrows.animation.addByPrefix('idle', "rightIdle");
			rightArrows.animation.addByPrefix('press', "rightConfirm");
			rightArrows.animation.play('idle');
		}
		add(rightArrows);

		titleText = new FlxText(0, 50, FlxG.width, 'BF', 80);
        titleText.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleText.screenCenter(X);
		titleText.borderSize = 1.25;
        add(titleText);

		descText = new FlxText(0, 600, FlxG.width, 'BF', 80);
        descText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.screenCenter(X);
		descText.borderSize = 1.25;
        add(descText);

		var titleText:FlxText = new FlxText(0, 100, 0,'Choose Your BOYFRIEND', 80);
        titleText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleText.screenCenter(X);
		titleText.borderSize = 1.25;
        add(titleText);

		changeSelection();

		backButt = new FlxSprite(FlxG.width - 100, FlxG.height - 100).loadGraphic(Paths.image('x'));
		backButt.scale.set(2,2);
		add(backButt);

		super.create();
	}

	dynamic public function getValue():Dynamic
	{
		var value = ClientPrefs.data.activeBfSkin;
		return value;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(controls.BACK)
		{
			close();
			return;
		}

		if(FlxG.mouse.overlaps(backButt) && FlxG.mouse.justPressed)
		{
			close();
			return;
		}

		grpSkins.forEach(function(spr:FlxSprite)
		{
			var centX = (FlxG.width/2) - (spr.width /2);
			var centY = (FlxG.height/2) - (spr.height /2);

			spr.x = FlxMath.lerp(spr.x, centX - (curSelected-spr.ID) * 500, FlxMath.bound(elapsed * 10, 0, 1));

			spr.scale.set(
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 1, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.7, FlxMath.bound(elapsed * 10.2, 0, 1)),
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 1, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.7, FlxMath.bound(elapsed * 10.2, 0, 1))
            );
	
			if(spr.ID == curSelected)
				spr.alpha = 1;
			else
				spr.alpha = 0.6;
		});

		if (controls.UI_RIGHT || FlxG.mouse.wheel < 0)
			rightArrows.animation.play('press')
		else
			rightArrows.animation.play('idle');

		if (controls.UI_LEFT || FlxG.mouse.wheel > 0)
			leftArrows.animation.play('press');
		else
			leftArrows.animation.play('idle');

		if (controls.UI_LEFT_P || FlxG.mouse.wheel > 0)
		{
			changeSelection(-1);
		}
		if (controls.UI_RIGHT_P || FlxG.mouse.wheel < 0)
		{
			changeSelection(1);
		}

		grpSkins.forEach(function(spr:FlxSprite)
		{
			if(FlxG.mouse.overlaps(spr) && spr.ID == curSelected && FlxG.mouse.justPressed)
			{
				if(unlocks[curSelected] == false)
				{
					FunkinSound.playOnce(Paths.sound('wrong_buzz'), 1);
					return;
				}
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'), 1);
				select();
				close();
				return;
			}
		});

		if (controls.ACCEPT)
		{
			if(unlocks[curSelected] == false)
			{
				FunkinSound.playOnce(Paths.sound('wrong_buzz'), 1);
				return;
			}

			FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'), 1);
			select();
			close();
			return;
		}
	}

	public function select()
	{
		ClientPrefs.data.activeBfSkin = bfSkin[curSelected];
		ClientPrefs.saveSettings();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, bfSkin.length - 1);
		titleText.text = plates[curSelected];
		descText.text = unlocks_text[curSelected];
		FlxG.sound.play(Paths.sound('real_menu_sounds/key_select'), 0.4);
	}

	inline public static function getOGsave():Bool
	{
		return getFlixelSave('PeaTV_Basement', "BrutalPizdec", 'PeaTV_Basement', 'funkin');
	}

	inline public static function getDLCsave():Bool
	{
		return getFlixelSave('PeaTV_Basement', "BrutalPizdec-Impotence-DLC", 'PeaTV_Basement', 'funkin');
	}

	inline public static function getLegacysave():Bool
	{
		return getFlixelSave('BRUTALPIZDECV2', "BRUTAL-PIZDEC-V2", 'BRUTALPIZDECV2', 'funkin');
	}

	inline public static function getV6save():Bool
	{
		return getFlixelSave('OgreCrew', "BP-v6", 'OgreCrew', 'unlock');
	}

	inline public static function getWCsave():Bool
	{
		return getFlixelSave('OgreCrew', "Brutal-Pizdec-WC", 'OgreCrew', 'unlock');
	}

	public static function getCaseSave():Bool
	{
		var path = Sys.getEnv("userprofile") + '\\AppData\\Roaming\\Godot\\app_userdata\\Case- -Perec.HUI-\\unlock.dat';
		return FileSystem.exists(path);
	}

	public static function test():Bool
	{
		var tellMe:Bool = (FlxG.save.data.completedSongs.contains('fire-thoser') && FlxG.save.data.completedSongs.contains('too-fire-gone'));

		trace(tellMe);
		return tellMe;
	}


	public static function getFCEXEcomplete():Bool
	{
		var tellMe:Bool = (FlxG.save.data.completedPerfectSongs.contains('too-fire')
		&& FlxG.save.data.completedPerfectSongs.contains('you-cant-fire') && FlxG.save.data.completedPerfectSongs.contains('doomsday'));

		trace('Week exe: ' + tellMe);
		trace(FlxG.save.data.completedPerfectSongs);

		return tellMe;
	}

	public static function getFCWEEKPcomplete():Bool
	{
		var tellMe:Bool = (FlxG.save.data.completedPerfectSongs.contains('fire-thoser') && FlxG.save.data.completedPerfectSongs.contains('too-fire-gone'));

		trace('Week exe: ' + tellMe);
		trace(FlxG.save.data.completedPerfectSongs);

		return tellMe;
	}

	public static function getFCWEEKPBFcomplete():Bool
	{
		var tellMe:Bool = (FlxG.save.data.completedPerfectSongs.contains('obrutality') && FlxG.save.data.completedPerfectSongs.contains('triple-trouble') && FlxG.save.data.completedPerfectSongs.contains('the-end'));

		trace('Week exe: ' + tellMe);
		trace(FlxG.save.data.completedPerfectSongs);

		return tellMe;
	}

	public static function getFCcomplete():Bool
	{
		var tellMe:Bool = (FlxG.save.data.completedPerfectSongs.contains('fire-thoser') && FlxG.save.data.completedPerfectSongs.contains('too-fire-gone') && FlxG.save.data.completedPerfectSongs.contains('obrutality')
		&& FlxG.save.data.completedPerfectSongs.contains('triple-trouble') && FlxG.save.data.completedPerfectSongs.contains('the-end') && FlxG.save.data.completedPerfectSongs.contains('too-fire')
		&& FlxG.save.data.completedPerfectSongs.contains('you-cant-fire') && FlxG.save.data.completedPerfectSongs.contains('doomsday') && FlxG.save.data.completedPerfectSongs.contains('last-stand')
		&& FlxG.save.data.completedPerfectSongs.contains('hell-valley') && FlxG.save.data.completedPerfectSongs.contains('games-are-over'));

		return tellMe;
	}

	public static function getFlixelSave(company:String, title:String, localPath:String = 'ninjamuffin99', name:String = 'funkin', newPath:Bool = false):Bool
	{
		// before anyone asks, this is copy-pasted from FlxSave
		var invalidChars = ~/[ ~%&\\;:"',<>?#]+/;

		// Avoid checking for .sol files directly in AppData
		if (localPath == "")
		{
			var path = company;

			if (path == null || path == "")
			{
				path = "HaxeFlixel";
			}
			else
			{
				#if html5
				// most chars are fine on browsers
				#else
				path = invalidChars.split(path).join("-");
				#end
			}

			localPath = path;
		}

		var directory = lime.system.System.applicationStorageDirectory;
		var path = '';

		if (newPath)
			path = haxe.io.Path.normalize('$directory/../../../$localPath') + "/";
		else
			path = haxe.io.Path.normalize('$directory/../../../$company/$title') + "/";

		name = StringTools.replace(name, "//", "/");
		name = StringTools.replace(name, "//", "/");

		if (StringTools.startsWith(name, "/"))
		{
			name = name.substr(1);
		}

		if (StringTools.endsWith(name, "/"))
		{
			name = name.substring(0, name.length - 1);
		}

		if (name.indexOf("/") > -1)
		{
			var split = name.split("/");
			name = "";

			for (i in 0...(split.length - 1))
			{
				name += "#" + split[i] + "/";
			}

			name += split[split.length - 1];
		}

		//trace(path + name + ".sol");

		return FileSystem.exists(path + name + ".sol");
	}
}
