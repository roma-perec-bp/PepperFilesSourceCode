package funkin.menus.extra;

import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxStringUtil;

/**
 * Music player used for Freeplay
 */
@:access(funkin.menus.extra.ExtraState)
class SoundPlayer extends FlxGroup 
{
	public var instance:ExtraState;
	public var controls:Controls;

	public var playing(get, never):Bool;

	public var playingMusic:Bool = false;
	public var curTime:Float;

	var songTxt:FlxText;
	var timeTxt:FlxText;

	var wasPlaying:Bool;

	public function new(instance:ExtraState)
	{
		super();

		this.instance = instance;
		this.controls = instance.controls;

		var xPos:Float = FlxG.width * 0.7;

		songTxt = new FlxText(0, 5, FlxG.width, "", 32);
		songTxt.x -= 50;
		songTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		add(songTxt);

		timeTxt = new FlxText(0, songTxt.y + 60, FlxG.width, "", 32);
		timeTxt.x -= 50;
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		add(timeTxt);

		switchPlayMusic();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!playingMusic)
		{
			return;
		}

		if (playing && !wasPlaying)
			songTxt.text = 'PLAYING'
		else
			songTxt.text = 'PAUSED';

		if (controls.UI_LEFT_P)
		{
			if (playing)
				wasPlaying = true;

			pauseOrResume();

			curTime = FlxG.sound.music.time - 1000;
			instance.holdTime = 0;

			if (curTime < 0)
				curTime = 0;

			FlxG.sound.music.time = curTime;
		}
		if (controls.UI_RIGHT_P)
		{
			if (playing)
				wasPlaying = true;

			pauseOrResume();

			curTime = FlxG.sound.music.time + 1000;
			instance.holdTime = 0;

			if (curTime > FlxG.sound.music.length)
				curTime = FlxG.sound.music.length;

			FlxG.sound.music.time = curTime;
		}

		if(controls.UI_LEFT || controls.UI_RIGHT)
		{
			instance.holdTime += elapsed;
			if(instance.holdTime > 0.5)
			{
				curTime += 40000 * elapsed * (controls.UI_LEFT ? -1 : 1);
			}

			var difference:Float = Math.abs(curTime - FlxG.sound.music.time);
			if(curTime + difference > FlxG.sound.music.length) curTime = FlxG.sound.music.length;
			else if(curTime - difference < 0) curTime = 0;

			FlxG.sound.music.time = curTime;
		}

		if(controls.UI_LEFT_R || controls.UI_RIGHT_R)
		{
			FlxG.sound.music.time = curTime;

			if (wasPlaying)
			{
				pauseOrResume(true);
				wasPlaying = false;
			}
		}
	
		if (controls.RESET)
		{
			FlxG.sound.music.time = 0;
		}

		updateTimeTxt();
	}

	public function pauseOrResume(resume:Bool = false) 
	{
		if (resume)
		{
			if(!FlxG.sound.music.playing)
				FlxG.sound.music.resume();
		}
		else 
		{
			FlxG.sound.music.pause();
		}
	}

	public function switchPlayMusic()
	{
		FlxG.autoPause = (!playingMusic && ClientPrefs.data.autoPause);
		active = visible = playingMusic;

		songTxt.visible = timeTxt.visible = playingMusic; //Show Music Player texts and boxes if playingMusic is true
		
		instance.holdTime = 0;

		if (playingMusic)
		{
			instance.bottomText.text = Language.getPhrase('musicplayer_tip', 'Press SPACE to Pause / Press ESCAPE to Exit / Press R to Reset the Song');
			instance.bottomText.alpha = 1;
			instance.bottomBG.alpha = 0.6;

			updateTimeTxt();
		}
		else
		{

			instance.bottomText.alpha = 0.0001;
			instance.bottomText.text = '';
			instance.bottomBG.alpha = 0.0001;
		}
	}

	function updateTimeTxt()
	{
		var text = FlxStringUtil.formatTime(FlxG.sound.music.time / 1000, false) + ' / ' + FlxStringUtil.formatTime(FlxG.sound.music.length / 1000, false);
		timeTxt.text = '< ' + text + ' >';
	}

	function get_playing():Bool 
	{
		return FlxG.sound.music.playing;
	}
}