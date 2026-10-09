package funkin.menus.credits;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import lime.utils.Assets;
import haxe.Json;
import flixel.addons.text.FlxTypeText;
import funkin.objects.VideoSprite;

/**
 * The state used to display the credits scroll.
 */
 typedef Info =
 {
   var header:String;
   var body:Array<Line>;
 }
 typedef CreditsFile =
 {
   var entries:Array<Info>;
 }
 typedef Line =
{
    var line:String;
}
class EndingState extends MusicBeatState
{
  var credits_data:CreditsFile;
  /**
   * The height the credits should start at.
   * Make this an instanced variable so it gets set by the constructor.
   */
  final STARTING_HEIGHT = FlxG.height;

  /**
   * The padding on each side of the screen.
   */
  static final SCREEN_PAD = 24;

  /**
   * The width of the screen the credits should maximally fill up.
   * Make this an instanced variable so it gets set by the constructor.
   */
  final FULL_WIDTH = FlxG.width - (SCREEN_PAD * 2);

  /**
   * The font to use to display the text.
   * To use a font from the `assets` folder, use `Paths.font(...)`.
   * Choose something that will render Unicode properly.
   */
  #if windows
  static final CREDITS_FONT = 'Consolas';
  #elseif mac
  static final CREDITS_FONT = 'Menlo';
  #else
  static final CREDITS_FONT = "Courier New";
  #end

  /**
   * The size of the font.
   */
  static final CREDITS_FONT_SIZE = 24;

  static final CREDITS_HEADER_FONT_SIZE = 32;

  /**
   * The color of the text itself.
   */
  static final CREDITS_FONT_COLOR = FlxColor.WHITE;

  /**
   * The color of the text's outline.
   */
  static final CREDITS_FONT_STROKE_COLOR = FlxColor.BLACK;

  /**
   * The speed the credits scroll at, in pixels per second.
   */
  static final CREDITS_SCROLL_BASE_SPEED = 42.0;

  /**
   * The speed the credits scroll at while the button is held, in pixels per second.
   */
  static final CREDITS_SCROLL_FAST_SPEED = CREDITS_SCROLL_BASE_SPEED * 12.0;

  /**
   * The actual sprites and text used to display the credits.
   */
  var creditsGroup:FlxSpriteGroup;

  var lyrics:FlxText;
  var drawing:FlxSprite;
  var shishi:Int = 0;

  var end:FlxSprite;

  var ended:Bool = false;

  var startedCredits:Bool = false;

  var endText:FlxText;
  var endTextAlt:FlxText;

  var txt1:FlxTypeText;
  var txt2:FlxTypeText;
  var txt3:FlxTypeText;
  var txt4:FlxTypeText;

  var txt12:FlxTypeText;
  var txt22:FlxTypeText;
  var txt32:FlxTypeText;
  var txt42:FlxTypeText;

  public var videoCutscene:VideoSprite = null;

  var lyricsTimingArray:Array<Float> = [
		0.6,  //THE END
		5.500, //PLAYING
    10.30, //MADE BY
    14.99, //fade
    22.214, //Как давно, это началось?
    26.619, //Конца не видно, всё разожглось
    31.385, //Спасибо что пришел, но хочу чтоб ты ушел
    36.214, //Хочу чтоб понимал
    38.655, //Забудь о нас!
    42.017, //Разве ты не видишь?
    44.398, //Ничего мы не хотим
    46.861, //Это уже всё
    48.279, //Прощай навсегда!
    51.403,
    54.006,
    56.243,
    58.209,
    60.595, //Here starts scroll
    65.109,
    69.906,
    74.688,
    77.111,
    80.375,
    82.808,
    85.201,
    86.716,
    90.016,
    92.398,
    94.797,
    96.601,
    99.005, //here goes whistle
    142.189,
    144.575,
    146.686,
    149.071,
    151.807,
    153.900,
    156.276,
    158.596,
    161.678,
    164.088,
    166.199,
    168.289,
    171.609,
    173.994,
    176.186,
    177.898,
    181.164,
    183.610,
    185.985,
    187.802,
    190.613,
    193.062,
    195.642,
    197.476,
    199.375, //fade
    200.369, //end
    205.957
	];

  var lyricsArray:Array<String> = 
  [
    'THE END',
    'Playing now: Forget About Me',
    'Made by: PEREC.HUI',
    '',
    'Как давно, это началось?',
    'Конца не видно, всё разожглось',
    'Спасибо что пришел, но хочу чтоб ты ушел',
    'Хочу чтоб понимал',
    'Забудь о нас!',
    'Разве ты не видишь?',
    'Ничего мы не хотим',
    'Это уже всё',
    'Прощай навсегда!',
    'Оставь все это в прошлом',
    'Это нам не нужно',
    'Не скучай по нам',
    'Навсегда!',
    'Весело, нам всем было',
    'Отчасти только мне, прости всех нас',
    'Эпоха прошла, хоть перцом не был я',
    'Запомни это раз',
    'Забудь про нас!',
    'Ты так и не понял?',
    'Ничего не осознал?',
    'Опять мне сказать',
    'Прощай навсегда!',
    'Нужно идти дальше',
    'Там где нас всех меньше',
    'Нас не будет там',
    'Навсегда!',
    '',
    'Расстаться',
    'Больно нам',
    'Но нужно всем',
    'Уйти всем нам',
    'Просто пойми',
    'Мне здесь места нет',
    'Еще раз скажу',
    'Забудь о нас',
    'Спасибо за игру',
    'Спасибо за встречу',
    'Но, теперь на всем пора',
    'Уйти навсегда!',
    'Это было классно',
    'Может и не всем, но',
    'Веселью пора',
    'Уйти навсегда!',
    'Хоть я еще живой',
    'Это для меня ничто',
    'Твоя реальность',
    'Твоя!',
    'Хочу чтоб ты исчезнул',
    'Из всей моей жизни',
    'Буду я скучать',
    'Навсегда',
    'Навсегда',
    'За этим миром...',
    'За этим миром...',
  ];

  public function new()
  {
    super();
  }

  public override function create():Void
  {
    super.create();

    FlxG.save.data.progressState = 7;
    FlxG.save.data.completedGame = true;
    FlxG.save.flush();

    WindowUtil.setTitle("Thank You");

    Paths.music('forgetAboutMe');

    #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("The end", null);
		#end

    credits_data = findJson();

    // Background
    drawing = new FlxSprite().loadGraphic(Paths.image('ending/0'));
    drawing.updateHitbox();
    drawing.x = 770;
    drawing.y = 100;
    drawing.alpha = 0.001;
    add(drawing);

    end = new FlxSprite().loadGraphic(Paths.image('ending/end'));
    end.updateHitbox();
    end.screenCenter();
    end.alpha = 0.001;
    add(end);

    FlxG.camera.bgColor = 0xFF000000;

    Conductor.bpm = 99.999;

    // TODO: Once we need to display Kickstarter backers,
    // make this use a recycled pool so we don't kill peformance.
    creditsGroup = new FlxSpriteGroup();
    creditsGroup.x = SCREEN_PAD;
    creditsGroup.y = STARTING_HEIGHT;

    buildCreditsGroup();

    add(creditsGroup);

    lyrics = new FlxText(0, FlxG.height * 0.8, 1200, 'THE END', 32);
    lyrics.setFormat(Paths.font("Roscherk SHA_6.otf"), 32, 0xffffffff, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    lyrics.borderSize = 2;
    lyrics.alpha = 0.0001;
    lyrics.screenCenter(X);
    lyrics.antialiasing = true;
    add(lyrics);

    endText = new FlxText(0, FlxG.height * 0.8, 1200, 'THE END', 64);
    endText.setFormat(Paths.font("DS-DIGI.TTF"), 32, 0xffffffff, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    endText.borderSize = 2;
    endText.visible = false;
    endText.screenCenter();
    add(endText);

    endTextAlt = new FlxText(0, FlxG.height * 0.8, 1200, 'THE END', 64);
    endTextAlt.setFormat(Paths.font("Roscherk SHA_6.otf"), 32, 0xffffffff, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    endTextAlt.borderSize = 2;
    endTextAlt.visible = true;
    endTextAlt.alpha = 0.0001;
    endTextAlt.screenCenter();
    endTextAlt.antialiasing = true;
    add(endTextAlt);

    txt1 = new FlxTypeText(0, 650, Std.int(FlxG.width * 0.85), "", 32);
		txt1.font = Paths.font("Roscherk SHA_6.otf");
		txt1.alignment = CENTER;
		txt1.color = 0xFFFFFFFF;
		txt1.screenCenter();
    txt1.y -= 100;
    txt1.antialiasing = true;
		add(txt1);

    txt2 = new FlxTypeText(0, 650, Std.int(FlxG.width * 0.85), "", 32);
		txt2.font = Paths.font("Roscherk SHA_6.otf");
		txt2.alignment = CENTER;
		txt2.color = 0xFFFFFFFF;
		txt2.screenCenter();
    txt2.y -= 50;
    txt2.antialiasing = true;
		add(txt2);

    txt3 = new FlxTypeText(0, 650, Std.int(FlxG.width * 0.85), "", 32);
		txt3.font = Paths.font("Roscherk SHA_6.otf");
		txt3.alignment = CENTER;
		txt3.color = 0xFFFFFFFF;
		txt3.screenCenter();
    txt3.antialiasing = true;
		add(txt3);

    txt4 = new FlxTypeText(0, 650, Std.int(FlxG.width * 0.85), "", 32);
		txt4.font = Paths.font("Roscherk SHA_6.otf");
		txt4.alignment = CENTER;
		txt4.color = 0xFFFFFFFF;
		txt4.screenCenter();
    txt4.antialiasing = true;
    txt4.y += 50;
		add(txt4);

    for (i in 0...16) Paths.image('ending/'+i);

    var foundFile:Bool = false;
		var fileName:String = Paths.video('ending');

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			videoCutscene = new VideoSprite(fileName, false, false, false);

			function onVideoEnd()
			{
        startSong();
			}

			videoCutscene.finishCallback = onVideoEnd;

      add(videoCutscene);

      videoCutscene.play();
		}
  }

  static function findJson():CreditsFile
  {
    var rawFile:String = null;
    var path:String = Paths.getSharedPath('data/credits.json');
        
		if(Assets.exists(path)) {
			rawFile = Assets.getText(path);
		}
		else
		{
			return null;
		}
		return cast Json.parse(rawFile);
  }

  function buildCreditsGroup():Void
  {
    var y:Float = 0;

    for (entry in 0...credits_data.entries.length)
    {
      var stupid:Info = credits_data.entries[entry];
      if (stupid.header != null)
      {
        var header = buildCreditsLine(stupid.header, y, true, CreditsSide.Center);
        header.bold = true;
        creditsGroup.add(header);
        y += CREDITS_HEADER_FONT_SIZE + (header.textField.numLines * CREDITS_HEADER_FONT_SIZE);
      }

      for (line in stupid?.body ?? [])
      {
        var entry = buildCreditsLine(line.line, y, false, CreditsSide.Center);
        creditsGroup.add(entry);
        y += CREDITS_FONT_SIZE * entry.textField.numLines;
      }

      // Padding between each role.
      y += CREDITS_FONT_SIZE * 2.5;
    }

    var userNameEnd:String = '';
    var userTxt:String = getUsername();

    if(DiscordClient.username != 'Unknown') userTxt = DiscordClient.username;

    if(userTxt != 'User')
      userNameEnd = "\n\nand of course YOU " + userTxt + "!";
    else
      userNameEnd = "\n\nand of course YOU... Why your username is still \"User\"? It's been like 2 years goddammit";

    var entryEND = buildCreditsLine(userNameEnd, y, false, CreditsSide.Center);
    creditsGroup.add(entryEND);
  }

  function buildCreditsLine(text:String, yPos:Float, header:Bool, side:CreditsSide = CreditsSide.Center):FlxText
  {
    // CreditsSide.Center: Full screen width
    // CreditsSide.Left: Left half of screen
    // CreditsSide.Right: Right half of screen
    var xPos = (side == CreditsSide.Right) ? (FULL_WIDTH / 2) : 0;
    var width = (side == CreditsSide.Center) ? FULL_WIDTH : (FULL_WIDTH / 2);
    var size = header ? CREDITS_HEADER_FONT_SIZE : CREDITS_FONT_SIZE;

    var creditsLine:FlxText = new FlxText(xPos, yPos, width, text);
    creditsLine.setFormat(CREDITS_FONT, size, CREDITS_FONT_COLOR, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, CREDITS_FONT_STROKE_COLOR, true);
    creditsLine.antialiasing = true;

    return creditsLine;
  }

  public static function getUsername():String
  {
      // uhh this one is self explanatory
      #if windows
      return Sys.getEnv("USERNAME");
      #else
      return Sys.getEnv("USER");
      #end
  }

  var lyricCount:Int = -1;
  public function startSong()
  {
    // Music
    FlxG.sound.playMusic(Paths.music('forgetAboutMe'), 1, false);

    for(i in 0...lyricsTimingArray.length){ //пришлось так, так как курбеат насрал десинком жёстким
      new FlxTimer().start(lyricsTimingArray[i], function(tmr:FlxTimer){
        lyricCount++;
        switch(lyricCount)
        {
          case 0:
            endText.visible = true;
            endText.text = lyricsArray[i];

          case 1:
            endText.text = lyricsArray[i];

          case 2:
            endText.text = lyricsArray[i];

          case 3:
            FlxTween.tween(endText, {alpha: 0}, 1);

          case 4:
		        txt1.resetText(lyricsArray[i]);
            txt1.start(0.06, true);

          case 5:
		        txt2.resetText(lyricsArray[i]);
            txt2.start(0.06, true);

          case 6:
            txt3.resetText(lyricsArray[i]);
            txt3.start(0.06, true);

          case 7:
            txt4.resetText(lyricsArray[i]);
            txt4.start(0.06, true);

          case 8:
            endTextAlt.text = lyricsArray[i];
            FlxTween.tween(endTextAlt, {alpha: 1}, 2);

            FlxTween.tween(txt1, {alpha: 0}, 1);
            FlxTween.tween(txt2, {alpha: 0}, 1);
            FlxTween.tween(txt3, {alpha: 0}, 1);
            FlxTween.tween(txt4, {alpha: 0}, 1);
          case 9:
            FlxTween.tween(endTextAlt, {alpha: 0}, 2);
            txt1.resetText(lyricsArray[i]);
            txt1.start(0.06, true);
            txt1.alpha = 1;
          case 10:
            txt2.resetText(lyricsArray[i]);
            txt2.start(0.06, true);
            txt2.alpha = 1;
          case 11:
            txt3.resetText(lyricsArray[i]);
            txt3.start(0.06, true);
            txt3.alpha = 1;
          case 12:
            txt4.resetText(lyricsArray[i]);
            txt4.start(0.06, true);
            txt4.alpha = 1;

            FlxTween.tween(txt2, {alpha: 0}, 0.4, {startDelay: 2});
            FlxTween.tween(txt1, {alpha: 0}, 0.4, {startDelay: 2});
            FlxTween.tween(txt3, {alpha: 0}, 0.4, {startDelay: 2});
            FlxTween.tween(txt4, {alpha: 0}, 0.4, {startDelay: 2});

          case 13:
            txt1.resetText(lyricsArray[i]);
            txt1.start(0.06, true);
            txt1.alpha = 1;
          case 14:
            txt2.resetText(lyricsArray[i]);
            txt2.start(0.06, true);
            txt2.alpha = 1;
          case 15:
            txt3.resetText(lyricsArray[i]);
            txt3.start(0.06, true);
            txt3.alpha = 1;
          case 16:
            txt4.resetText(lyricsArray[i]);
            txt4.start(0.06, true);
            txt4.alpha = 1;

            FlxTween.tween(txt2, {alpha: 0}, 0.4, {startDelay: 2});
            FlxTween.tween(txt1, {alpha: 0}, 0.4, {startDelay: 2});
            FlxTween.tween(txt3, {alpha: 0}, 0.4, {startDelay: 2});
            FlxTween.tween(txt4, {alpha: 0}, 0.4, {startDelay: 2});
          case 17:
            startScroll();
            lyrics.text = lyricsArray[i];

            if(lyricsArray[i] == ''){
              lyrics.alpha = 0.0001;
            }
            else{
              lyrics.alpha = 1;
            }

          case 30:
            FlxTween.tween(lyrics, {alpha: 0}, 3, {onComplete:
              function(twn:FlxTween) {
                lyrics.text = lyricsArray[i];
              }
            });

          case 55:
            lyrics.text = lyricsArray[i];
            FlxTween.tween(lyrics, {alpha: 0}, 1);

          case 56:
            lyrics.text = lyricsArray[i];
            FlxTween.tween(lyrics, {alpha: 1}, 3);

          case 57:
            FlxTween.tween(lyrics, {alpha: 0}, 3);

          default:
            lyrics.text = lyricsArray[i];

            if(lyricsArray[i] == ''){
              lyrics.alpha = 0.0001;
            }
            else{
              lyrics.alpha = 1;
            }
        }
      });
    }
  }

  public function startScroll()
  {
    startedCredits = true;
    FlxTween.tween(drawing, {alpha: 1}, 3.5, {type: PINGPONG, onComplete:
        function (twn:FlxTween)
        {
          if(drawing.alpha != 1)
          {
            if(shishi == 18)
            {
              FlxTween.cancelTweensOf(drawing);
              return;
            }

            shishi++;

            drawing.loadGraphic(Paths.image('ending/'+shishi));
          }
        }
    });
  }

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    /*if (FlxG.keys.pressed.ENTER || FlxG.keys.pressed.SPACE)
    {
        // Move the whole group by the base scroll speed.
        creditsGroup.y -= CREDITS_SCROLL_FAST_SPEED * elapsed;
    }*/

    if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

    // Move the whole group.
    if(startedCredits)
      creditsGroup.y -= CREDITS_SCROLL_BASE_SPEED * elapsed;

    if (hasEnded())
    {
      exit();
    }
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

  function hasEnded():Bool
  {
    return creditsGroup.y < -creditsGroup.height;
  }

  function exit():Void
  {
    if(ended) return;
    FlxTween.cancelTweensOf(drawing);
    FlxTween.tween(drawing, {alpha: 0}, 1);
    FlxTween.tween(lyrics, {alpha: 0}, 1);
    FlxG.sound.music.fadeOut(3);
    ended = true;
    lyrics.text = '';
    FlxTween.tween(end, {alpha: 1}, 3, {onComplete:
      function (twn:FlxTween)
      {
        FlxTween.tween(end, {alpha: 0}, 5, {startDelay: 6, onComplete:
          function (twn:FlxTween)
          {
            funkin.menus.mainmenu.MainMenuState.introActive = false;
            funkin.menus.mainmenu.MainMenuState.playedIntro = false;
            funkin.menus.mainmenu.MainMenuState.playSongAfterEnd = true;
            WindowUtil.setTitle("Pepper's Files");
            FlxG.switchState(new funkin.menus.IntroState());
          }
        });
      }
    });
  }

  public override function destroy():Void
  {
    super.destroy();
  }
}

enum CreditsSide
{
  Left;
  Center;
  Right;
}
