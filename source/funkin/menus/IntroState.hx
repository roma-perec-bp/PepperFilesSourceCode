package funkin.menus;

import flixel.FlxSubState;
import funkin.audio.FunkinSound;
import funkin.menus.title.TitleState;
import funkin.objects.VideoSprite;
import flixel.effects.FlxFlicker;
import lime.app.Application;

class IntroState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var isYes:Bool = true;
	var texts:FlxTypedSpriteGroup<FlxText>;
	var bg:FlxSprite;

    public var videoCutscene:VideoSprite = null;

	override function create()
	{
		FlxG.mouse.visible = false;
		
		super.create();

		FlxG.mouse.visible = false;

		MusicBeatState.changeCursor(true);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		texts = new FlxTypedSpriteGroup<FlxText>();
		texts.alpha = 0.0;
		add(texts);

		var warnText:FlxText = new FlxText(0, 0, 850,
			"Warning!\n\nThis Mod is not what you think it supposed to be!\nYou're gonna experience non-standart adventure with some features of your pc (which is safe though)\nYou gotta deal with multiple application files rather than this one\nAnd also this mod contains jumpscares and flashing lights\n\nI Warned You...");
		warnText.setFormat(Paths.font("vcr.ttf"), 24, 0xFFFF0000, CENTER);
		warnText.screenCenter();
		texts.add(warnText);

        var foundFile:Bool = false;
		var fileName:String = Paths.video(FlxG.save.data.doesHeKnow ? 'haxe-bad': 'haxe-good');

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			videoCutscene = new VideoSprite(fileName, false, false, false);
			FlxG.mouse.visible = false;

			function onVideoEnd()
			{
				FunkinSound.playOnce(Paths.sound('comatose'), 1);

				FlxTween.tween(texts.scale, {x: 1.2, y: 1.2}, 6);

                FlxTween.tween(texts, {alpha: 1.0}, 1, {
                    onComplete: function(twn:FlxTween)
                    {
                        FlxTween.tween(texts, {alpha: 0}, 3, {
                            startDelay: 3,
                            onComplete: function(twn:FlxTween)
                            {
                                leftState = true;
                                ClientPrefs.saveSettings();

                                switch(FlxG.save.data.progressState)
                                {
                                    case 0:
                                        FlxG.switchState(new funkin.menus.title.TitleState());
                                    default:
                                        FlxG.switchState(new funkin.menus.mainmenu.MainMenuState());
                                }
                            }
                        });
                    }
                });
			}

			videoCutscene.finishCallback = onVideoEnd;
			videoCutscene.onSkip = onVideoEnd;

            add(videoCutscene);

            videoCutscene.play();
		}
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			leftState = true;
			ClientPrefs.saveSettings();

			switch(FlxG.save.data.progressState)
			{
				case 0:
					FlxG.switchState(new funkin.menus.title.TitleState());
				default:
					FlxG.switchState(new funkin.menus.mainmenu.MainMenuState());
			}
		}
	}

	override function destroy()
	{
		if(videoCutscene != null)
		{
			videoCutscene.destroy();
			videoCutscene = null;
		}
	}
}
