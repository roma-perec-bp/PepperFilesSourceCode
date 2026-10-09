package funkin.menus.extra;

import funkin.graphics.shaders.WiggleEffectRuntime;
import funkin.audio.FunkinSound;
import flxgif.FlxGifSprite;
import funkin.objects.VideoSprite;

class ExtraState extends MusicBeatState
{
    var wiggleBack:WiggleEffectRuntime = null;
    var bg:FlxSprite;
    var bg2:FlxSprite;
    public var videoCutscene:VideoSprite = null;
    private var grpMain:FlxTypedGroup<FlxText>;
    
    var categories:Array<String> = [
        'Characters',
        'Concepts',
        'Dev-screenshots',
        'Arts',
        'Memes',
        'Audio'
    ];

    var images:Array<Array<String>> = [
        [                                               //RENDERS
            'perechui',
            'perecjson',
            'michael',
            'smalltroop',
            'bigtroop',
            'zomb',
            'iconofsin',
            'user',
            'kate',
            'rom',
            'px',
            'px-frenzy',
            'assyst',
            'peps',
            'perechui-frenzy',
            'exe',
            'xeno',
            'xeno-doom',
            'eye',
            'pep-demo',
            'pep-fire-demo',
            'pea-demo',
            'pea-angry-demo',
            'squash-demo',
            'ghost-demo',
            'hwaw',
            'christmas',
            'agent',
            'stif',
            'umbra',
            'thing',
            'omega',
            'mimic',
            'perechui-2',
            'perecjson-2',
            'rom-2',
            'dust'
        ],
        [
            'firstDesign',                             //CONCEPTS
            'firstSketch',
            'perechui-hd',
            'accidentalSketch',
            'main_hd',
            'fnfDesign',
            'hellvalley1',
            'hellvalley2',
            'unusedDark',
            'window',
            'weekp-concept',
            'hui-concept',
            'weekpbf-concept',
            'weekexe-concept',
            'hdrom',
            'perec-concept',
            'perechui-concept',
            'perechui-hellvalley-concept',
            'perechui-hellvalley-concept2',
            'theend1',
            'theend2',
            'bannercut',
            'banner-concept',
            'ost-concept',
            'freeplay-concept',
            'bg-bp',
            'toofire',
            'toofire-sketch',
            'youcantfire',
            'youcantfire-sketch',
            'elkaproto',
            'hellroof-proto',
            'fog-sketch',
            'night',
            'pea-sketch',
            'sex',
            'sex-poses',
            'sex-remnant',
            'xeno-paper',
            'xeno-cute',
            'hui-renders-concept',
            'hui-renders-sketch',
            'discovery-jumpscare1',
            'discovery-jumpscare2',
            'christmas-raldman',
            'stif-raldman',
            'creation',
            'christmas-concept',
            'christmas-concept1',
            'agent-concept1',
            'agent-concept2',
            'stif-concept1',
            'stif-concept2',
            'stif-concept3',
            'creation-concept',
            'creation-concept2',
            'umbra-concept',
            'umbra-prototype',
            'nighterect',
            'exeend',
            'void-concept',
            'together-concept',
            'doom-concept',
            'hwaw-concept',
            'katehd',
            'altsquash',
            'hui-render-concept',
            'hui-render-lineart',
            'omega-concept',
            'legacy',
            'user',
            'end1',
            'end2',
            'end3',
            'end4',
            'demopep-concept',
            'demopep-fire-concept',
            'demopea-concept',
            'demopea-angry-concept',
            'demosquash-concept',
            'demoghost-concept',
            'eye-cut',
            'ghost-rom-concept',
            'render-zomb',
            'hell-line',
            'deadxemo',
            'stand-noeffects',
            'small-hand',
            'redrawn-concept'
        ],
        [
            'eyeless',                                                            //DEV-SCREENSHOTS
            'smear',
            'ai',
            'goner',
            'ishowspeed',
            'ishowspeed-romix',
            'heady',
            'legs',
            'atlas',
            'zoom',
            'dark',
            'trans',
            'bodies',
            'reference',
            'piss',
            'behind',
            'wtf',
            'darnell'
        ],
        [
            'banner1',
            'banner2',
            '0',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '11',
            '12',
            '13',
            '14',
            '15',
            '16',
            'end',
            '17',
            '18',
            '19',
            '20',
            '21',
            '22',
            '23',
            '24',
            '25',
            '26',
            '27',
            '28',
            '29',
            '30',
            '31',
            'solar',
            'ourple',
            'ourple-case',
            'fuck',
            '32',
            '33',
            '34',
            '35',
            '36',
            '37',
            '38',
            '39',
            '40',
            '41',
            '42',
            '43',
            '44',
            '45',
            '46',
            '47',
            '475',
            '48',
            'shoe',
            '49',
            '50',
            '51',
            '52',
            '53',
            '54',
            '55',
            '56',
            '57',
            '58',
            'tadc',
            'pirate',
            '59',
            '61',
            '62',
            '63',
            '64',
            '65',
            '66',
            '67',
            '68',
            '69',
            '70',
            'daughter',
            'slow',
            'die',
            '71',
            '72',
            '73',
            '74',
            '75',
            '76',
            '77',
            '78',
            '79',
            '80',
            '81',
            '82',
            '83',
            'treasure',
            'pizdec',
            'seeyousoon',
            '84',
            '85',
            '86',
            '87',
            '88',
            '89',
            '90',
            '91',
            '92',
            'jason',
            'lol_spooky',
            'spook',
            'whotf',
            'scared',
            'fudge',
            'wrong',
            'collect',
            'father',
            'hell',
            'the-end'
        ],
        [
            '0',                                                        //MEMES
            '1',
            'goon',
            '2',
            '3',
            '4',
            '5',
            '6',
            'doomsday',
            '7',
            '8',
            '9',
            '10',
            '11',
            '12',
            '13',
            '14',
            'chimera',
            'zalgo',
            'cool',
            '15',
            '16',
            '17',
            '18',
            '19',
            '20',
            '21',
            '22',
            '23',
            '24',
            'badpea',
            'next',
            '25',
            '26',
            '27',
            'chances',
            '28',
            '29',
            '30',
            'bptadc',
            'nya',
            'pain',
            '31',
            '32',
            'crash',
            'sad',
            'twitter',
            'bald'
        ],
        [
            'the-end-lyrics',
            '3-2hd',
            '3-2hd2',
            'timetodiehd',
            'neverforgetushd',
            'cannotoutrunmidi',
            'quizhappy',
            'quizweird',
            'voidprototype',
            'void_room-happy-old',
            'void_room-weird-old',
            'highpiano',
            'rest-prototype',
            'rest-og',
            'withconewip1',
            'withconewip2',
            'withconewip3',
            'withconewip4',
            'withconewip5',
            'piano',
            'tt-replanted',
            'empty',
            'holocaust'
        ]
    ];

    var player:SoundPlayer;

    var curSelectedCat:Int = 0;
    var curSelectedContent:Array<Int> = [0, 0, 0, 0, 0, 0];

    var backButt:FlxSprite;

    var nameText:FlxText;
    var creditText:FlxText;
    var descText:FlxText;

    var pressEnter:FlxText;
    var pressSpace:FlxText;

    var leftArrows:FlxSprite;
	var rightArrows:FlxSprite;

    var contentImage:FlxSprite;
    var contentGif:FlxGifSprite;

    var watchingVid:Bool = false;

    var black:FlxSprite;
    var holdTime:Float = 0;

    var bottomString:String;
	var bottomText:FlxText;
    var bottomBG:FlxSprite;
    override function create()
	{
		super.create();

        FlxG.sound.playMusic(Paths.music('museum'), 0.7);

        wiggleBack = new WiggleEffectRuntime(2, 4, 0.017, WiggleEffectType.FLAG);

        bg = new BGSprite('extra');
		bg.setGraphicSize(Std.int(FlxG.width * 1.1));
		bg.screenCenter();
		bg.antialiasing = false;
		bg.shader = wiggleBack;
		add(bg);
		bg.alpha = 0.25;

		bg2 = new BGSprite('extra');
		bg2.setGraphicSize(Std.int(FlxG.width * 1.1));
		bg2.screenCenter();
		bg2.antialiasing = false;
		bg2.shader = wiggleBack;
		add(bg2);
		bg2.angle = 180;
		bg2.alpha = 0.25;

        var grad:FlxSprite = new FlxSprite().loadGraphic(Paths.image('extra/grad'));
        add(grad);

        var desc:FlxSprite = new FlxSprite(FlxG.width - 350, 0).makeGraphic(450, FlxG.height, FlxColor.BLACK);
        desc.updateHitbox();
        desc.alpha = 0.6;
        add(desc);

        nameText = new FlxText(-25, 50, FlxG.width, "TEST NAME", 24);
		nameText.scrollFactor.set();
		nameText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(nameText);

        creditText = new FlxText(-25, 100, FlxG.width, "By CreCCC", 18);
		creditText.scrollFactor.set();
		creditText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(creditText);

        descText = new FlxText(FlxG.width - 325, 150, 300, "wawawawawawaawwwawawawawaaaawawawawawawawawawawawawawawawawawawawawawawawa\nawawawawawawawawawawawawawawawaawaw\nwawawawawawawawawawawawawawawawawawawawa", 24);
		descText.scrollFactor.set();
        descText.antialiasing = true;
		descText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(descText);

        pressEnter = new FlxText(0, FlxG.height - 150, FlxG.width, "Press ACCEPT to watch video", 16);
		pressEnter.scrollFactor.set();
		pressEnter.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(pressEnter);
        pressEnter.alpha = 0.0001;
        pressEnter.x -= 50;

        pressSpace = new FlxText(0, FlxG.height - 150, FlxG.width, "Press SPACE to play the audio", 16);
		pressSpace.scrollFactor.set();
		pressSpace.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(pressSpace);
        pressSpace.alpha = 0.0001;
        pressSpace.x -= 50;
        // avoids lagspikes while scrolling through menus!
		grpMain = new FlxTypedGroup<FlxText>();
		add(grpMain);

        var maincurID:Int = -1;
		for (i in 0...categories.length)
		{
			var optionText:FlxText = new FlxText(50, 10, 0, categories[i]);
			optionText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
			maincurID += 1;
			optionText.ID = maincurID;
			grpMain.add(optionText);
		}

        contentImage = new FlxSprite();
        contentImage.scale.set(0.5, 0.5);
        contentImage.updateHitbox();
        contentImage.screenCenter();
        contentImage.antialiasing = true;
        contentImage.alpha = 0.0001;
        add(contentImage);

        contentGif = new FlxGifSprite();
        contentGif.scale.set(0.5, 0.5);
        contentGif.updateHitbox();
        contentGif.screenCenter();
        contentGif.alpha = 0.0001;
        contentGif.antialiasing = true;
        add(contentGif);

        final ui_tex = Paths.getSparrowAtlas('freeplay_menu/buttons');

		if (leftArrows == null){
			leftArrows = new FlxSprite(250, 300);
			leftArrows.antialiasing = ClientPrefs.data.antialiasing;
			leftArrows.frames = ui_tex;
			leftArrows.animation.addByPrefix('idle', "butt_default");
			leftArrows.animation.addByPrefix('press', "butt_press");
			leftArrows.animation.play('idle');
            leftArrows.scale.set(0.5, 0.5);
			leftArrows.screenCenter(Y);
		}
		add(leftArrows);

		if (rightArrows == null){
			rightArrows = new FlxSprite(FlxG.width - 400, leftArrows.y);
			rightArrows.antialiasing = ClientPrefs.data.antialiasing;
			rightArrows.frames = ui_tex;
			rightArrows.screenCenter(Y);
			rightArrows.animation.addByPrefix('idle', "butt_default");
			rightArrows.animation.addByPrefix('press', "butt_press");
			rightArrows.flipX = true;
            rightArrows.scale.set(0.5, 0.5);
			rightArrows.animation.play('idle');
		}
        add(rightArrows);

        backButt = new FlxSprite(FlxG.width - 100, FlxG.height - 100).loadGraphic(Paths.image('x'));
		backButt.scale.set(2,2);
		add(backButt);

        bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.0001;
		add(bottomBG);

        bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, '', 16);
		bottomText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
        bottomText.alpha = 0.0001;
		add(bottomText);

        player = new SoundPlayer(this);
		add(player);

        black = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
        black.scale.set(FlxG.width, FlxG.height);
        black.updateHitbox();
        black.alpha = 0;
        add(black);

        changeSelection(0, false);
        changeContent(0, false);
    }

    var instPlaying:Int = -1;
    var exitted:Bool = false;
    override function update(elapsed:Float)
	{
        if (!player.playingMusic)
        {
            if(FlxG.mouse.wheel != 0)
            {
                changeSelection(-FlxG.mouse.wheel);
            }
    
            if (controls.UI_UP_P)
            {
                changeSelection(-1);
            }
            if (controls.UI_DOWN_P)
            {
                changeSelection(1);
            }
    
            if (controls.UI_LEFT_P || FlxG.mouse.overlaps(leftArrows) && FlxG.mouse.justPressed)
            {
                changeContent(-1);
            }
            if (controls.UI_RIGHT_P || FlxG.mouse.overlaps(rightArrows) && FlxG.mouse.justPressed)
            {
                changeContent(1);
            }
        }

        grpMain.forEach(function(spr:FlxText)
        {
            var lerpVal:Float = Math.exp(-elapsed * 12);
    
            var centY = (FlxG.height/2) - (spr.height /2);
    
            spr.y = FlxMath.lerp(spr.y, centY - 250 - (0-spr.ID) * 50, FlxMath.bound(elapsed * 10, 0, 1));
    
            spr.alpha = (
                spr.ID == curSelectedCat ?
                    FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 24, 0, 1))
                    :
                    FlxMath.lerp(spr.alpha, 0.4, FlxMath.bound(elapsed * 24, 0, 1))
            );
        });

        if(controls.ACCEPT && isVideo && !watchingVid)
        {
            watchingVid = true;
            FlxG.sound.music.fadeOut(1);
            FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
                function(twn:FlxTween) {
                    videoCutscene = new VideoSprite(Paths.video('extra/'+images[curSelectedCat][curSelectedContent[curSelectedCat]]), false, true, false, false, true);

                    function onVideoEnd()
                    {
                        FlxG.sound.music.fadeIn(1, 0.0, 1.0);
                        FlxTween.tween(black, {alpha: 0.0001}, 1);

                        new FlxTimer().start(1, function(timer:FlxTimer)
                        {
                            watchingVid = false;
                        });
                    }
        
                    videoCutscene.finishCallback = onVideoEnd;
                    videoCutscene.onSkip = onVideoEnd;
        
                    add(videoCutscene);
        
                    videoCutscene.play();
                }
            });
        }

        if (controls.BACK && !isVideo)
		{
            if (player.playingMusic)
            {
                FlxG.sound.music.stop();
                FlxG.sound.music.volume = 0;
                instPlaying = -1;
    
                player.playingMusic = false;
                player.switchPlayMusic();
    
                FlxG.sound.playMusic(Paths.music('museum'), 0);
                FlxTween.tween(FlxG.sound.music, {volume: 0.7}, 1);
            }
            else
            {
                exitted = true;

                FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
                MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
            }
        }

        if(FlxG.mouse.overlaps(backButt) && FlxG.mouse.justPressed)
		{
            if (player.playingMusic)
            {
                FlxG.sound.music.stop();
                FlxG.sound.music.volume = 0;
                instPlaying = -1;
    
                player.playingMusic = false;
                player.switchPlayMusic();
    
                FlxG.sound.playMusic(Paths.music('museum'), 0);
                FlxTween.tween(FlxG.sound.music, {volume: 0.7}, 1);
            }
            else
            {
                exitted = true;

                FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
                MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
            }
        }

        if(FlxG.keys.justPressed.SPACE && isAudio)
		{
			if (!exitted)
			{
				if(instPlaying != curSelectedContent[curSelectedCat] && !player.playingMusic)
				{
					FlxG.sound.music.volume = 0;
		
					FlxG.sound.playMusic(Paths.sound('extra/'+images[curSelectedCat][curSelectedContent[curSelectedCat]]), 0.8);
					FlxG.sound.music.pause();
					instPlaying = curSelectedContent[curSelectedCat];
		
					player.playingMusic = true;
					player.curTime = 0;
					player.switchPlayMusic();
					player.pauseOrResume(true);
				}
				else if (instPlaying == curSelectedContent[curSelectedCat] && player.playingMusic)
				{
					player.pauseOrResume(!player.playing);
				}
			}
		}

        if (wiggleBack != null) wiggleBack.update(elapsed);

		super.update(elapsed);
	}

    function changeSelection(change:Int = 0, playSound:Bool = true)
	{
        if(exitted) return;
		curSelectedCat = FlxMath.wrap(curSelectedCat + change, 0, categories.length - 1);

		if(playSound) FunkinSound.playOnce(Paths.sound('real_menu_sounds/key_select'), 1);

        changeContent(0, false);
	}

    var isVideo:Bool = false;
    var isAudio:Bool = false;
    var textArray:Array<String> = [];
    function changeContent(change:Int = 0, playSound:Bool = true)
	{
        if(exitted) return;

        curSelectedContent[curSelectedCat] += change;

        if (curSelectedContent[curSelectedCat] < 0)
			curSelectedContent[curSelectedCat] = images[curSelectedCat].length - 1;
		if (curSelectedContent[curSelectedCat] >= images[curSelectedCat].length)
			curSelectedContent[curSelectedCat] = 0;

        contentImage.alpha = 0.0001;
        contentGif.alpha = 0.0001;
        isVideo = false;
        isAudio = false;

        pressEnter.alpha = 0.0001;
        pressSpace.alpha = 0.0001;

        if (FileSystem.exists(Paths.getPath('images/extra/content/${curSelectedCat}/${images[curSelectedCat][curSelectedContent[curSelectedCat]]}-video.png')))
        {
            contentImage.loadGraphic(Paths.image('extra/content/${curSelectedCat}/${images[curSelectedCat][curSelectedContent[curSelectedCat]]}-video'));
            contentImage.scale.set(0.4, 0.4);
            contentImage.updateHitbox();
            contentImage.screenCenter();
            contentImage.alpha = 1;
            isVideo = true;
            contentImage.x -= 50;

            pressEnter.alpha = 1;
        }

        if (FileSystem.exists(Paths.getPath('images/extra/content/${curSelectedCat}/${images[curSelectedCat][curSelectedContent[curSelectedCat]]}.png')))
        {
            contentImage.loadGraphic(Paths.image('extra/content/${curSelectedCat}/${images[curSelectedCat][curSelectedContent[curSelectedCat]]}'));
            contentImage.scale.set(0.4, 0.4);
            contentImage.updateHitbox();
            contentImage.screenCenter();
            contentImage.alpha = 1;
            contentImage.x -= 50;
        }

        if (FileSystem.exists(Paths.getPath('images/extra/content/${curSelectedCat}/${images[curSelectedCat][curSelectedContent[curSelectedCat]]}.gif')))
        {
            contentGif.loadGif(File.getBytes(Paths.gif_alt('extra/content/${curSelectedCat}/${images[curSelectedCat][curSelectedContent[curSelectedCat]]}')));
            contentGif.scale.set(0.4, 0.4);
            contentGif.updateHitbox();
            contentGif.screenCenter();
            contentGif.alpha = 1;
            contentGif.x -= 50;
        }

        if (FileSystem.exists(Paths.getPath('images/extra/content/${curSelectedCat}/${images[curSelectedCat][curSelectedContent[curSelectedCat]]}-audio.txt')))
        {
            contentImage.loadGraphic(Paths.image('extra/music_icon'));
            contentImage.scale.set(0.7, 0.7);
            contentImage.updateHitbox();
            contentImage.screenCenter();
            contentImage.alpha = 1;
            contentImage.x -= 50;
            isAudio = true;

            pressSpace.alpha = 1;
        }

        textArray = CoolUtil.listFromString(Paths.getTextFromFile('images/extra/content/${curSelectedCat}/${images[curSelectedCat][curSelectedContent[curSelectedCat]]}-text.txt'));

        if(textArray != null)
        {
            nameText.text = textArray[0];
            creditText.text = textArray[1];
            if(textArray[2] != null) 
                descText.text = textArray[2];
            else
                descText.text = '';
        }
        else
        {
            nameText.text = '';
            creditText.text = '';
            descText.text = '';
        }

        var userTxt:String = getUsername();
    
        if(DiscordClient.username != 'Unknown') userTxt = DiscordClient.username;
    
        if(userTxt == 'User')
            userTxt = "Player";

        if(nameText.text == 'USERNAME') nameText.text = userTxt;

        if(nameText.text == 'Dust')
            FlxG.sound.music.pitch = 0.25;
        else
            FlxG.sound.music.pitch = 1;

		if(playSound) FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'), 1);
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
}