package funkin.menus.arg;

import funkin.graphics.shaders.DaveAndBambiGlitchShader;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;

import flixel.util.FlxSave;

import funkin.menus.storymenu.StoryMenuState;

import flixel.addons.text.FlxTypeText;

import funkin.audio.FunkinSound;

import funkin.objects.VideoSprite;

class ArgState extends MusicBeatState
{
	public var videoCutscene:VideoSprite = null;
	var her_eyes:FlxSprite;
	var her:FlxSprite;

	var curPath:String;
	var curDial:String;

	var curState:Int = 0;
	var can:Bool = false;

	var dialogueList:Array<String> = [];
	var imageInputText:PsychUIInputText;
	var dialogueLock:Array<String> =
	[
		'...',
		'...?',
		'Что ты тут делаешь?',
		'Погоди! Еще рано!',
		'Он все ещё здесь!',
		'Приходи сюда, когда его не будет',
		'У меня есть что то, что я хочу тебе показать',
		'Но лучше тебе уйти',
		'Я тебя жду'
	];

	var dialogueNotDone:Array<String> =
	[
		'...',
		'...?',
		'Ты уже здесь?',
		'Погоди! Я еще не закончила!',
		'Мне лишь нужно-',
		'...',
		'Слушай',
		'Приди сюда, когда все это, выйдет в публичный доступ',
		'раз пока еще идет бета-тестирование',
		'К этому времени, я точно буду готова',
		'Еще увидимся'
	];

	var dialogueGreet:Array<String> =
	[
		'...',
		'...?',
		'Ты уже здесь?',
		'Отлично'
	];

	var dialogueStart:Array<String> =
	[
		'Честно, не думала что ты придешь',
		'Но ты здесь',
		'И меня это радует',
		'Тем более, что нам никто не помешает',
		'Отлично!',
		'Мое имя Perec.PIZDA',
		'Но я не перец',
		'Я лишь человек в костюме',
		'Да и это имя, это просто прозвище, которое мне давали многие',
		'Можешь меня звать "Анонсером"',
		'Так будет лучше',
		'А теперь к делу',
		'Я хочу тебе кое-что показать',
		'Мой секретный проект',
		'Над которым я очень давно стараюсь',
		'Но я пока не могу ничего показать',
		'Если хочешь узнать что за проект, ты должен заслужить это знание',
		'Найди код, который я спрятала по всему этому билду',
		'Здесь всё просто',
		'Всего есть 3 части кода',
		'Первая часть, находиться разорванной в 3 разных песнях',
		'В основном рядом с игроком',
		'Найди все 3 символа кода, и расставь по правильному порядку',
		'Знай, что в интернете ты не найдешь правильный ответ',
		'Ведь этот код сгенерирован каждый раз, когда впервые начинаешь играть в этот мод',
		'2 часть находиться уже вокруг нашего мира',
		'Вне этого билда',
		'В файлах билда ты можешь найти подсказки',
		'Дальше думаю ты поймешь что делать',
		'3 код находиться в одной особой игре',
		'SlendyPeppers',
		'Тебе нужно её просто пройти и получить код',
		'Игра находиться там же, где и билды которые ты играл в прошлые разы',
		'Знай, что даже если ты будешь знать ответ на 3 код',
		'Ты все равно должен пройти игру',
		'Ты ведь должен заслужить знания, а не просто у кого списать',
		'Ладно, удачи тебе с этим',
		'Ещё увидимся'
	];

	var dialogueRemind:Array<String> =
	[
		'Напомню твое задание',
		'Тебе нужно найти КОД чтобы узнать что то о моем проекте',
		'Здесь всё просто',
		'Всего есть 3 части кода',
		'Первая часть, находиться разорванной в 3 разных песнях',
		'В основном рядом с игроком',
		'Найди все 3 символа кода, и расставь по правильному порядку',
		'Знай, что в интернете ты не найдешь правильный ответ',
		'Ведь этот код сгенерирован каждый раз, когда впервые начинаешь играть в этот мод',
		'2 часть находиться уже вокруг нашего мира',
		'Вне этого билда',
		'В файлах билда ты можешь найти подсказки',
		'Дальше думаю ты поймешь что делать',
		'3 код находиться в одной особой игре',
		'SlendyPeppers',
		'Тебе нужно её просто пройти и получить код',
		'Игра находиться там же, где и билды которые ты играл в прошлые разы',
		'Знай, что даже если ты будешь знать ответ на 3 код',
		'Ты все равно должен пройти игру',
		'Ты ведь должен заслужить знания, а не просто у кого списать',
		'Ладно, удачи тебе с этим',
		'Ещё увидимся'
	];

	var dialogueAccept:Array<String> =
	[
		'Ты это сделал',
		'Ты действительно это сделал!',
		'Я... я...'
	];

	var dialogueEnd:Array<String> =
	[
		'Я поражена',
		'Ты проделал весь этот путь, чтобы узнать о моем проекте?',
		'Это...',
		'Я даже не знаю...',
		'Этот проект, является для меня самым важным в этой жизни',
		'Он про моих знакомых, которых я очень давно не видела',
		'Я очень сильно по ним скучаю',
		'Это было так давно',
		'Надеюсь я их увижу вновь снова...',
		'...',
		'Ладно',
		'Думаю пора показать то, зачем ты проделал весь этот путь',
		'Спасибо, тебе',
		'Еще увидимся...'
	];

	var dialogueDone:Array<String> =
	[
		'...?',
		'Мне больше нечего показать',
		'Еще увидимся...'
	];

	var curDialogue:Int = 0;

	var swagDialogue:FlxTypeText;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	var bg:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		super.create();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("???", null);
		#end

		WindowUtil.setTitle("???");

		bg = new FlxSprite().loadGraphic(Paths.image('chapter_3', 'embed', false));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.alpha = 0.0001;
		add(bg);
		bg.screenCenter();

		her_eyes = new FlxSprite().loadGraphic(Paths.image('her_eyes2', 'embed', false));
		her_eyes.alpha = 0.0001;
		her_eyes.antialiasing = false;
		her_eyes.scale.set(1.3, 1.3);
		her_eyes.screenCenter();
		add(her_eyes);

		her = new FlxSprite().loadGraphic(Paths.image('her', 'embed', false));
		her.alpha = 0.0001;
		her.antialiasing = false;
		her.scale.set(1.3, 1.3);
		her.screenCenter();
		add(her);

		swagDialogue = new FlxTypeText(0, 650, Std.int(FlxG.width * 0.85), "", 24);
		swagDialogue.font = Paths.font("MP-Manga.ttf");
		swagDialogue.alignment = CENTER;
		swagDialogue.color = 0xFFFFFFFF;
		swagDialogue.screenCenter(X);
		swagDialogue.antialiasing = true;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('a'), 0.4)];
		add(swagDialogue);

		imageInputText = new PsychUIInputText(FlxG.width - 350, 400, 450, '', 64, true);
		imageInputText.alpha = 0;
		imageInputText.screenCenter();
		add(imageInputText);

		if(FlxG.save.data.finishedArg)
		{
			initDialog(dialogueDone);
		}
		else
		{
			if(!FlxG.save.data.completedGame)
			{
				FlxG.sound.playMusic(Paths.music('makeHimLeave'), 0);
				FlxG.sound.music.fadeIn(3, 0, 0.6);
	
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					initDialog(dialogueLock);
				});
			}
			else
			{
				if(!FlxG.save.data.startedArg)
				{
					FlxG.sound.playMusic(Paths.music('makeHimLeave'), 0);
					FlxG.sound.music.fadeIn(3, 0, 0.6);
		
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						curState = 1;
						initDialog(dialogueGreet);
					});	
				}
				else
				{
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						curState = 2;
						initDialog(dialogueRemind);
					});	
				}
			}
		}
	}

	var chooseb:Bool = false;
	var songTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			if(dialogueOpened)
			{
				if(dialogueEnded)
				{
					if (dialogueList[1] == null && dialogueList[0] != null)
					{
						swagDialogue.alpha = 0;

						dialogueOpened = false;
						dialogueStarted = false;

						switch(curState)
						{
							case 1:
								FlxG.sound.music.fadeOut();
								FlxTween.tween(her_eyes, {alpha: 1}, 2, {onComplete:
									function(twn:FlxTween) {
										FlxG.sound.playMusic(Paths.music('hello'));
										curState = 2;
										initDialog(dialogueStart);
									}
								});

							case 2:
								var save:FlxSave = new FlxSave();
								save.bind('arg', CoolUtil.getSavePath());
								save.data.smth = 'GoodLuck';
								save.flush();

								if(!FlxG.save.data.startedArg)
								{
									FlxG.save.data.startedArg = true;
									FlxG.save.flush();
									FlxTween.tween(bg, {alpha: 1}, 1, {onComplete:
										function(twn:FlxTween) {
											FlxTween.tween(bg, {alpha: 0}, 1, {startDelay: 3});
										}
									});
								}

								curState = 3;
								FlxG.sound.playMusic(Paths.music('myProject'));
								FlxTween.tween(her_eyes, {alpha: 0}, 1);
								FlxTween.tween(imageInputText, {alpha: 1}, 1);

								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									can = true;
								});

							case 4:
								FlxTween.tween(her, {alpha: 1}, 3, {onComplete:
									function(twn:FlxTween) {
										FlxG.sound.playMusic(Paths.music('backToSchool'));
										curState = 5;
										initDialog(dialogueEnd);
									}
								});

							case 5:
								FlxG.sound.music.fadeOut(3);

								var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
								black.scale.set(FlxG.width, FlxG.height);
								black.updateHitbox();
								black.alpha = 0;
								add(black);

								FlxTween.tween(black, {alpha: 1}, 3, {onComplete:
									function(twn:FlxTween) {
										MusicBeatState.switchState(new funkin.menus.arg.AnswerState());
									}
								});

							default:
								WindowUtil.setTitle("Pepper's Files");
								FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
								MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
						}
					}
					else
					{
						dialogueList.remove(dialogueList[0]);
						startDialogue();
					}
				}
				else if (dialogueStarted)
				{
					swagDialogue.skip();
				}
			}

		}

		if(FlxG.keys.justPressed.ESCAPE && can)
		{
			can = false;
			WindowUtil.setTitle("Pepper's Files");
			FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
			MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
		}

		if (controls.ACCEPT && can)
		{
			var txt:String = imageInputText.text.toUpperCase();
			if(txt == '' + ClientPrefs.data.codes[0][1] + '' + ClientPrefs.data.codes[1][1] + '' + ClientPrefs.data.codes[2][1] + 'OTKX' && getSlendySave())
			{
				curState = 4;
				FlxG.sound.music.stop();
				FunkinSound.playOnce(Paths.sound('access_granted'), 1);
				new FlxTimer().start(7, function(tmr:FlxTimer)
				{
					initDialog(dialogueAccept);
				});
				can = false;
				imageInputText.alpha = 0;
			}
			else
			{
				FunkinSound.playOnce(Paths.sound('access_denied'), 1);
			}
		}

		super.update(elapsed);

		if(PsychUIInputText.focusOn != null)
		{
			ClientPrefs.toggleVolumeKeys(false);
			return;
		}
		ClientPrefs.toggleVolumeKeys(true);
	}

	public static function getSlendySave():Bool
	{
		var path = Sys.getEnv("userprofile") + '\\AppData\\Roaming\\Godot\\app_userdata\\SlendyPeppers\\unlock.dat';
		return FileSystem.exists(path);
	}

	function startDialogue():Void
	{
		swagDialogue.alpha = 1;
		swagDialogue.resetText(dialogueList[0]);

		curDialogue++;

		swagDialogue.start(0.05, true);
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		};
	
		dialogueEnded = false;
	}

	function initDialog(arrayThingie:Array<String>):Void
	{
		dialogueList = arrayThingie;

		dialogueOpened = true;
		dialogueStarted = true;

		startDialogue();
	}
}