package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

import flixel.system.debug.log.LogStyle;
import openfl.display.BitmapData;

import funkin.menus.FullScreenScaleMode;

import funkin.menus.storymenu.StoryMenuState;
import funkin.menus.FlashingState;

import lime.app.Application;
import lime.graphics.Image;

#if (cpp && windows)
import hxwindowmode.WindowColorMode;
#end

class InitState extends FlxState
{
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
    public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
    public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    public final song:Array<String> = ['fire-thoser', 'too-fire-gone', 'obrutality', 'triple-trouble', 'the-end', 'too-fire', 'you-cant-fire', 'doomsday', 'last-stand', 'hell-valley', 'games-are-over'];
    public final allowedKeys:Array<String> = ['A','B','C','D','E','F','G','H','I','J','L','M','N','P','Q','R','S','U','V','W','Y','Z'];

    override public function create():Void
    {
        //Paths.clearStoredMemory();
        //Paths.clearUnusedMemory();

        FlxG.save.bind('funkin', CoolUtil.getSavePath());

        Language.reloadPhrases();

        //FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;

        Controls.instance = new Controls();
        ClientPrefs.loadDefaultKeys();
        ClientPrefs.loadPrefs();

        #if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
	
        Highscore.load();
        Progression.load();
        
        #if VIDEOS_ALLOWED
        hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
        #end

        FlxG.fixedTimestep = false;
        FlxG.signals.postGameReset.add(() -> FlxG.fixedTimestep = false);
        FlxG.game.focusLostFramerate = 30;
        FlxG.keys.preventDefaultKeys = [TAB];

        FlxG.plugins.drawOnTop = true;

        //FlxG.inputs.resetOnStateSwitch = false;

        #if LUA_ALLOWED
        Mods.pushGlobalMods();
        #end
        Mods.loadTopMod();

        //if(FlxG.save.data != null && FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;
        if (FlxG.save.data.weekCompleted != null) StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

        if (FlxG.save.data.playedSongs == null) FlxG.save.data.playedSongs = [];
        if (FlxG.save.data.completedSongs == null) FlxG.save.data.completedSongs = [];
        if (FlxG.save.data.completedPerfectSongs == null) FlxG.save.data.completedPerfectSongs = [];
        if (FlxG.save.data.completedGoldenSongs == null) FlxG.save.data.completedGoldenSongs = [];
        if (FlxG.save.data.gotLoss == null) FlxG.save.data.gotLoss = false;

        if (FlxG.save.data.progressState == null) FlxG.save.data.progressState = 0;
        if (FlxG.save.data.voidStat == null) FlxG.save.data.voidStat = 0;
        if (FlxG.save.data.doesHeKnow == null) FlxG.save.data.doesHeKnow = false;

        if (FlxG.save.data.introduction == null) FlxG.save.data.introduction = false;
        if (FlxG.save.data.chapter1Complete == null) FlxG.save.data.chapter1Complete = false;
        if (FlxG.save.data.completedGame == null) FlxG.save.data.completedGame = false;

        if (FlxG.save.data.startedArg == null) FlxG.save.data.startedArg = false;
        if (FlxG.save.data.finishedArg == null) FlxG.save.data.finishedArg = false;

        if (FlxG.save.data.rubySkin == null) FlxG.save.data.rubySkin = false;

        #if html5
        FlxG.autoPause = false;
        #end
        FlxG.mouse.visible = false;

        #if DISCORD_ALLOWED
        DiscordClient.prepare();
        #end

        //untyped FlxG.sound.music = new funkin.audio.FlxSoundEx();
        //FlxG.sound.music.persist = true;

        FlxG.signals.focusLost.add(onLostFocus);
        FlxG.signals.focusGained.add(onGainFocus);

        // Sets the window to dark mode or white, depends.
        #if (cpp && windows)
		    WindowColorMode.setWindowColorMode(ClientPrefs.data.windowDarkMode);
		    WindowColorMode.redrawWindowHeader();
        cpp.Windows.setDpiAware();
		    #end

        #if FEATURE_DEBUG_TRACY
		    funkin.utils.WindowUtil.initTracy();
		    #end

        #if debug
        setupFlixelDebug();
        #end

        FlxG.scaleMode = new FullScreenScaleMode();

        FlxG.signals.preStateSwitch.add(FullScreenScaleMode.instance.onMeasurePostAwait);

        super.create();

        switch(FlxG.save.data.progressState)
        {
          case 0:
            generateCode();
            if (FlxG.save.data.introduction)
            {
              WindowUtil.setTitle('BP V2');
              Application.current.window.setIcon(Image.fromFile(Paths.getPath("images/pc_icons/icon_fake.png", IMAGE)));
              FlxG.switchState(new funkin.menus.IntroState());
            }
            else
            {
              WindowUtil.setTitle('...');
              FlxG.switchState(new funkin.menus.IntroductionState()); 
            }
          case 1 | 2:
            WindowUtil.setTitle('...');
            Application.current.window.setIcon(Image.fromFile(Paths.getPath("images/pc_icons/icon_reveal.png", IMAGE)));
            FlxG.switchState(new funkin.menus.lore.AccessCheckState());
          case 3:
            WindowUtil.setTitle('...');
            FlxG.switchState(new funkin.menus.lore.ChapterTwoStartState());
          case 6:
            WindowUtil.setTitle('...');
            FlxG.switchState(new funkin.menus.lore.ChapterTwoFinaleState());
          default:
            WindowUtil.setTitle("Pepper's Files");
            FlxG.switchState(new funkin.menus.IntroState());
        }

        //final nextState:Class<FlxState> = Main.startMeta.skipSplash || !ClientPrefs.toggleSplashScreen ? Main.startMeta.initialState : Splash;
		    // final nextState:Class<FlxState> = WIPNoteSkinEditor;
		    //FlxG.switchState(() -> Type.createInstance(nextState, []));
  }

  function generateCode()
  {
    var num1:Int = FlxG.random.int(0, 10);
    var num2:Int = FlxG.random.int(0, 10, [num1]);
    var num3:Int = FlxG.random.int(0, 10, [num1, num2]);

    ClientPrefs.data.codes[0][0] = song[num1];
    ClientPrefs.data.codes[1][0] = song[num2];
    ClientPrefs.data.codes[2][0] = song[num3];

    ClientPrefs.data.codes[0][1] = FlxG.random.getObject(allowedKeys);
    ClientPrefs.data.codes[1][1] = FlxG.random.getObject(allowedKeys);
    ClientPrefs.data.codes[2][1] = FlxG.random.getObject(allowedKeys);

    trace(ClientPrefs.data.codes);
  }

    @:noCompletion var _lastFocusVolume:Null<Float>;

    function onLostFocus():Void
    {
      if (FlxG.sound.muted || FlxG.sound.volume == 0 || FlxG.autoPause) return;
      _lastFocusVolume = FlxG.sound.volume;
      FlxG.sound.volume *= 0.5;
    }
  
    function onGainFocus():Void
    {
      #if !mobile
      if (ClientPrefs.data.unlockedFramerate)
      {
        FlxG.updateFramerate = 0;
        FlxG.drawFramerate = 0;
      }
      else
      {
        FlxG.updateFramerate = ClientPrefs.data.framerate;
        FlxG.drawFramerate = ClientPrefs.data.framerate;
      }
      #end

      if (FlxG.sound.muted || FlxG.sound.volume == 0 || FlxG.autoPause) return;
      if (_lastFocusVolume != null) FlxG.sound.volume = _lastFocusVolume;
    }

    #if debug
    function setupFlixelDebug():Void
    {
        #if !debug
        // Make errors less annoying on release builds.
        LogStyle.ERROR.openConsole = false;
        LogStyle.ERROR.errorSound = null;
        #end

        // Make errors and warnings less annoying.
        LogStyle.WARNING.openConsole = false;
        LogStyle.WARNING.errorSound = null;


        FlxG.debugger.toggleKeys = [F2];

        // Adds a red button to the debugger.
        // This pauses the game AND the music! This ensures the Conductor stops.
        FlxG.debugger.addButton(CENTER, new BitmapData(20, 20, true, 0xFFCC2233), function() {
        if (FlxG.vcr.paused)
        {
            FlxG.vcr.resume();
      
            for (snd in FlxG.sound.list)
            {
                snd.resume();
            }
      
            FlxG.sound.music.resume();
        }
        else
        {
            FlxG.vcr.pause();
      
            for (snd in FlxG.sound.list)
            {
                snd.pause();
            }
      
            FlxG.sound.music.pause();
        }
        });
  
        // Adds a blue button to the debugger.
        // This skips forward in the song.
        FlxG.debugger.addButton(CENTER, new BitmapData(20, 20, true, 0xFF2222CC), function() {
        FlxG.game.debugger.vcr.onStep();
  
        for (snd in FlxG.sound.list)
        {
          snd.pause();
          snd.time += FlxG.elapsed * 1000;
        }
  
        FlxG.sound.music.pause();
        FlxG.sound.music.time += FlxG.elapsed * 1000;
        });
    }
    #end
}