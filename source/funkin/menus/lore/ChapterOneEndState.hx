package funkin.menus.lore;

import funkin.menus.title.TitleState;
import funkin.objects.VideoSprite;

class ChapterOneEndState extends MusicBeatState
{
	override function create()
	{
		super.create();

		FlxG.save.data.progressState = 3;
		FlxG.save.flush();

        startVideo('end', false, false, false, true);
	}

	public var videoCutscene:VideoSprite = null;
	public function startVideo(name:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, playOnLoad:Bool = true)
	{
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
					generateTextFile('Погоди... Всё не так должно было закончиться!\nДолжно было быть всё по другому!\nСлушай, у меня есть кое какой план\nНо для этого нужно твое вмешательство\nНужно чтоб ты вернул доступ к моду!\nПопробуй войти в мод и подождать там минуту наверное, возможно это существо убившее перца заметит тебя, договорись с ним чтобы он вернул мод в норму\nПотом когда он откроет мод, войди в стори мод в САМУЮ последнюю неделю там\nДальше просто делай то что тебя просят, НИКАК НЕ ОТКАЗЫВАЙСЯ\nКак только всё будет готово как надо, я приду и мы завершим следующий этап...\nУДАЧИ!\n\n\n\n                 -Таинственный незнакомец', 'Сообщение_для_тебя');
					openfl.Lib.application.window.close();
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
}