package funkin.menus;

import flixel.FlxSubState;

import funkin.menus.title.TitleState;
import funkin.audio.FunkinSound;
import flixel.effects.FlxFlicker;
import lime.app.Application;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var isYes:Bool = true;
	var texts:FlxTypedSpriteGroup<FlxText>;
	var bg:FlxSprite;

	override function create()
	{
		FlxG.mouse.visible = false;

		super.create();

		FlxG.mouse.visible = false;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		texts = new FlxTypedSpriteGroup<FlxText>();
		texts.alpha = 0.0;
		add(texts);

		var warnText:FlxText = new FlxText(0, 0, 850,
			"Warning!\nThis Mod is not what you think it supposed to be!\nYou're gonna experience non-standart adventure with features of your pc (which is safe though)\nAnd also you will deal with multiple EXE files rather than this one\nEnjoy The Show...");
		warnText.setFormat(Paths.font("scary.otf"), 32, 0xFF660000, CENTER);
		warnText.screenCenter();
		texts.add(warnText);

		FunkinSound.playOnce(Paths.sound('comatose'), 1);

		FlxTween.tween(texts, {alpha: 1.0}, 1, {
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(texts, {alpha: 0}, 3, {
					startDelay: 3,
					onComplete: function(twn:FlxTween)
					{
						leftState = true;
						ClientPrefs.data.flashing = true;
						ClientPrefs.saveSettings();
						MusicBeatState.switchState(new TitleState());
					}
				});
			}
		});
	}
}
