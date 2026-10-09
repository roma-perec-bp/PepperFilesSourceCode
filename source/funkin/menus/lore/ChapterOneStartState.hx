package funkin.menus.lore;

import funkin.audio.FunkinSound;

class ChapterOneStartState extends MusicBeatState
{
	var lyricsTimingArray:Array<Float> = [
		0, 
		4.96,
		8.9,
		15.1,
		19.22,
		21.51,
		26.51,
		29.84,
		32.30,
		35.19,
		36.96,
		39.84,
		42.74,
		47.24,
		52.75,
		57.37
	];

	var lyricsArray:Array<String> = 
	[
		'',
	  'Ладно на самом деле я не ожидал таких поворотов событий...',
	  'Не думал что игра сломается если попытаешся с ней взаимодействовать во время... собственно говоря игры.',
	  'В следующий раз надо делать какие то фиксы чтоб такое не повторилось.',
	  'Кхм так, давай ближе к сути.',
	  'На самом деле я изначально после этой песни хотел тебя убить и через твою душу забратся в реальный мир!',
	  'Охотиться на всех ну и в итоге стать самым могучим!',
	  'Но знаешь... это скучно...',
	  'Поэтому, у меня появилась идея получше!',
	  'ДАВАЙ СЫГРАЕМ В ИГРУ',
	  'Твоей главной задачей будет ВЫЖИТЬ!',
	  'Я тебе дам троих людей и ты должен их защищать.',
	  'Если они выживут, я отстану от тебя и перейду к другому человеку.',
	  'в худшем случае... вообщем увидишь...',
	  'А пока ты не пройдешь мою игру полностью, входа в мод у тебя не будет!',
	  'Желаю удачи...'
	];

	var lyrics:FlxText;
	override function create()
	{
		FlxG.save.data.progressState = 1;
		FlxG.save.flush();

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		var bg = new FlxSprite().loadGraphic(Paths.image('chapter_titles/chapter_1'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.alpha = 0;
		bg.scale.set(0.7, 0.7);
		add(bg);
		bg.screenCenter();

		lyrics = new FlxText(0, FlxG.height * 0.8, 1200, '', 32);
		lyrics.setFormat(Paths.font("scary.otf"), 28, 0xFF660000, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		lyrics.borderSize = 2;
		lyrics.screenCenter();
		add(lyrics);

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			FunkinSound.playOnce(Paths.sound('chapter_titles/chapter_1'));

			FlxTween.tween(bg.scale, {x: 1, y: 1}, 10);

			FlxTween.tween(bg, {alpha: 1}, 4, {onComplete:
				function(twn:FlxTween) {
					for(i in 0...lyricsTimingArray.length)
					{
						new FlxTimer().start(lyricsTimingArray[i], function(tmr:FlxTimer){
						lyrics.text = lyricsArray[i];
				  
						  if(lyricsArray[i] == ''){
							lyrics.visible = false;
						  }
						  else{
							lyrics.visible = true;
						  }
						});
					}
					FunkinSound.playOnce(Paths.sound('hui_voices/speech_first'));
					new FlxTimer().start(5, function(tmr:FlxTimer)
					{
						FlxG.sound.playMusic(Paths.music('hui_ost/i_wanna_play_the_game'));
					});
					FlxTween.tween(bg, {alpha: 0}, 4, {startDelay: 1, onComplete:
						function(twn:FlxTween) 
						{
							new FlxTimer().start(55, function(tmr:FlxTimer)
							{
								Sys.command('start assets/games/my_story/perec.exe');
								openfl.Lib.application.window.close();
								//WindowUtil.exit();
							});
						}
					});
				}
			});
		});

		super.create();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Chapter 1 Start", null);
		#end
	}
}