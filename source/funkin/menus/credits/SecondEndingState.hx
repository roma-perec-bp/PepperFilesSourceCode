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
 typedef Info2 =
 {
   var header:String;
   var body:Array<Line2>;
 }
 typedef CreditsFile2 =
 {
   var entries:Array<Info2>;
 }
 typedef Line2 =
{
    var line:String;
}
class SecondEndingState extends MusicBeatState
{
  var credits_data:CreditsFile2;
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
  static var CREDITS_SCROLL_BASE_SPEED = 16.0;

  /**
   * The speed the credits scroll at while the button is held, in pixels per second.
   */
  static final CREDITS_SCROLL_FAST_SPEED = CREDITS_SCROLL_BASE_SPEED * 12.0;

  /**
   * The actual sprites and text used to display the credits.
   */
  var creditsGroup:FlxSpriteGroup;

  var ended:Bool = false;
  var curSong:Int = -1;
  var endText:FlxText;

  var backButt:FlxSprite;

  public function new()
  {
    super();
  }

  public override function create():Void
  {
    super.create();

    for (i in 0...7) Paths.music('credit_music/'+i);

    #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Credits", null);
		#end

    credits_data = findJson();

    FlxG.camera.bgColor = 0xFF000000;

    // TODO: Once we need to display Kickstarter backers,
    // make this use a recycled pool so we don't kill peformance.
    creditsGroup = new FlxSpriteGroup();
    creditsGroup.x = SCREEN_PAD;
    creditsGroup.y = STARTING_HEIGHT;

    buildCreditsGroup();

    add(creditsGroup);

    endText = new FlxText(0, FlxG.height * 0.7, 1200, 'Playing now:', 32);
    endText.setFormat(Paths.font("vcr.ttf"), 24, 0xffffffff, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    endText.borderSize = 2;
    add(endText);

    FlxTween.tween(endText, {alpha: 0}, 3, {startDelay: 5});

    var music:Int = FlxG.random.int(0,9, [curSong]);

    curSong = music;

    FlxG.sound.playMusic(Paths.music('credit_music/'+music), 1, false);
    FlxG.sound.music.onComplete = finishSong.bind();

    switch(music)
    {
      case 0:
        endText.text += ' Still Alive - Portal OST';
      case 1:
        endText.text += ' Want You Gone - Portal 2 OST';
      case 2:
        endText.text += ' Your Reality - Doki Doki Literature Club OST';
      case 3:
        endText.text += ' Time Pavement - Azumanga Daioh Osaka Single';
      case 4:
        endText.text += " The Heart is a Girl's Parachute - Azumanga Daioh Sakaki Single";
      case 5:
        endText.text += " Random - Friday Night Funkin OST";
      case 6:
        endText.text += " Hypochondriac - Kawai Sprite Chuckie Finster Album";
      case 7:
        endText.text += " Philly - Kawai Sprite Chuckie Finster Album";
      case 8:
        endText.text += ' Third Sanctuary - Deltarune OST';
      case 9:
        endText.text += ' Explorers - Geometry Dash (By Hinkik)';
    }
  }

  static function findJson():CreditsFile2
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
      var stupid:Info2 = credits_data.entries[entry];
      if (stupid.header != null)
      {
        var header = buildCreditsLine(stupid.header, y, true, CreditsSide2.Center);
        header.bold = true;
        creditsGroup.add(header);
        y += CREDITS_HEADER_FONT_SIZE + (header.textField.numLines * CREDITS_HEADER_FONT_SIZE);
      }

      for (line in stupid?.body ?? [])
      {
        var entry = buildCreditsLine(line.line, y, false, CreditsSide2.Center);
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

    var entryEND = buildCreditsLine(userNameEnd, y, false, CreditsSide2.Center);
    creditsGroup.add(entryEND);

    backButt = new FlxSprite(FlxG.width - 100, FlxG.height - 100).loadGraphic(Paths.image('white_x'));
		backButt.scale.set(2,2);
		add(backButt);
  }

  function buildCreditsLine(text:String, yPos:Float, header:Bool, side:CreditsSide2 = CreditsSide2.Center):FlxText
  {
    // CreditsSide.Center: Full screen width
    // CreditsSide.Left: Left half of screen
    // CreditsSide.Right: Right half of screen
    var xPos = (side == CreditsSide2.Right) ? (FULL_WIDTH / 2) : 0;
    var width = (side == CreditsSide2.Center) ? FULL_WIDTH : (FULL_WIDTH / 2);
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

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.pressed.ENTER || FlxG.keys.pressed.SPACE)
    {
        // Move the whole group by the base scroll speed.
        creditsGroup.y -= CREDITS_SCROLL_FAST_SPEED * elapsed;
    }

    // Move the whole group.
    creditsGroup.y -= CREDITS_SCROLL_BASE_SPEED * elapsed;

    if (hasEnded())
    {
      creditsGroup.y = STARTING_HEIGHT;
    }

    if(FlxG.mouse.overlaps(backButt) && FlxG.mouse.justPressed)
		{
      exit();
		}

    if (controls.BACK)
    {
      exit();
    }
  }

  public function finishSong():Void
	{
    new FlxTimer().start(1, function(tmr:FlxTimer)
		{
      endText.alpha = 1;
      FlxTween.tween(endText, {alpha: 0}, 3, {startDelay: 5});
  
      var music:Int = FlxG.random.int(0,8, [curSong]);
  
      curSong = music;
  
      FlxG.sound.playMusic(Paths.music('credit_music/'+music), 1, false);
      FlxG.sound.music.volume = 1;
      FlxG.sound.music.onComplete = finishSong.bind();
  
      endText.text = 'Playing now: ';
  
      switch(music)
      {
        case 0:
          endText.text += ' Still Alive - Portal OST';
        case 1:
          endText.text += ' Want You Gone - Portal 2 OST';
        case 2:
          endText.text += ' Your Reality - Doki Doki Literature Club OST';
        case 3:
          endText.text += ' Time Pavement - Azumanga Daioh Osaka Single';
        case 4:
          endText.text += " The Heart is a Girl's Parachute - Azumanga Daioh Sakaki Single";
        case 5:
          endText.text += " Random - Friday Night Funkin OST";
        case 6:
          endText.text += " Hypochondriac - Kawai Sprite Chuckie Finster Album";
        case 7:
          endText.text += " Philly - Kawai Sprite Chuckie Finster Album";
        case 8:
          endText.text += ' Third Sanctuary - Deltarune OST';
      }
    });
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

    FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
		MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
  }

  public override function destroy():Void
  {
    super.destroy();
  }
}

enum CreditsSide2
{
  Left;
  Center;
  Right;
}
