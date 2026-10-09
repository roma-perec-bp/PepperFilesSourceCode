package funkin.menus.lore;

import funkin.menus.title.TitleState;
import funkin.objects.VideoSprite;

import funkin.audio.FunkinSound; 

class ChapterTwoStartState extends MusicBeatState
{
	var bg:FlxSprite;
	override function create()
	{
		super.create();

		bg = new FlxSprite().loadGraphic(Paths.image('chapter_titles/chapter_2'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.alpha = 0;
		bg.scale.set(0.7, 0.7);
		add(bg);
		bg.screenCenter();

		TitleState.initialized = true;
		FlxG.mouse.visible = false;

        startVideo('waiting', false, false, false, true);
	}

	public var videoCutscene:VideoSprite = null;
	public function startVideo(name:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, playOnLoad:Bool = true)
	{
		FlxG.mouse.visible = false;
		#if VIDEOS_ALLOWED
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
			videoCutscene = new VideoSprite(fileName, forMidSong, canSkip, loop);

			// Finish callback
			if (!forMidSong)
			{
				function onVideoEnd()
				{
					videoCutscene = null;

					FlxG.save.data.progressState = 4;
					FlxG.save.flush();

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FunkinSound.playOnce(Paths.sound('chapter_titles/chapter_2'));
				
						FlxTween.tween(bg.scale, {x: 1, y: 1}, 10);
				
						FlxTween.tween(bg, {alpha: 1}, 4, {onComplete:
							function(twn:FlxTween) {
								FlxTween.tween(bg, {alpha: 0}, 4, {startDelay: 1, onComplete:
									function(twn:FlxTween) 
									{
										new FlxTimer().start(1, function(tmr:FlxTimer)
										{
											WindowUtil.setTitle("Pepper's Files");
											FlxG.switchState(new funkin.menus.mainmenu.MainMenuState());
										});
									}
								});
							}
						});
					});
				}
				videoCutscene.finishCallback = onVideoEnd;
				videoCutscene.onSkip = onVideoEnd;
			}
			add(videoCutscene);

			if (playOnLoad)
				videoCutscene.play();
			return videoCutscene;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		#end
		return null;
	}
}