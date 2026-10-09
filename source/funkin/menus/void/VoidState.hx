package funkin.menus.void;

import funkin.graphics.shaders.DaveAndBambiGlitchShader;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;

import flixel.util.FlxSave;

import funkin.menus.storymenu.StoryMenuState;

import flixel.addons.text.FlxTypeText;

import funkin.audio.FunkinSound;

class VoidState extends MusicBeatState
{
	var dnbShader:DaveAndBambiGlitchShader = null;
	var bg:FlxSprite;
	var eye:FlxSprite;

	var trailEvil:FlxSprite;

	var curPath:String;
	var curDial:String;

	var multAlpha:Float = 0;

	var dialogueList:Array<String> = [];

	var stateAfter:String;

	var talkVoice:Null<FunkinSound> = null;

	var curDialogue:Int = 0;

	var curCharacter:String = '';
	var curMusic:String = '';

	var swagDialogue:FlxTypeText;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	public var ambience:FunkinSound;

	var curRandom:Bool = false;
	var curRandomInt:Int = 0;

	//CHOISE VAR
	var texts:FlxTypedSpriteGroup<FlxText>;
	var inChoise:Bool = false;
	var isYes:Bool = true;

	//SECOND SECTION
	var blackBox:FlxSprite;
	var changeModeText:FlxText;

	var in_hub:Bool = false;
	var curSelectedMain:Int = 0;
	var choise_normal:Array<String> = [
		'Напомнить о текущем задании',
		'Интересный Факт'
		//'О BP V6',
		//'О BP Wokeless Edition',
		//"О Pepper's Case",
		//"Отдать части"
	];
	private var grpMain:FlxTypedGroup<FlxText>;

	var isMainHub:Bool = true;

	var blocked:Bool = false;

	var leftArrows:FlxSprite;
	var rightArrows:FlxSprite;
	
	var curSelectedQna:Int = 0;
	var choise_qna:Array<String> = [
		'Кто ты?',
		'Что ты думаешь о БП?',
		'Почему ты перец? Ты же холопенье!',
		'Какое у тебя отношение к ХВАВУ?',
		'Почему ты выбрал именно оболочку зомби перца с конусом?',
		'Почему файл формата .HUI?',
		'Что за таинственный оживитель?',
		'Что ты получал при убийстве людей?',
		'Почему у тебя глаз IRIS?',
		'Что ты думаешь о других модах?',
		'Из чего ты и твои существа сделаны?',
		'Чтобы ты делал, если бы убил всех?',
		'Как ты делаешь музыку?',
		"It's Time To Drink Water?",
		'Почему у тебя именно конус на голове? Есть же много других головных уборов?',
		'Какого быть в пустоте?',
		'О Дасте',
		'Убил бы даста?',
		'Wanna work on my fnf mod?',
		'Делал ли ты существ из своих жертв?',
		'Были ли тут еще существа, помимо твоих?',
		'Правда ли что у Саики Кусуо были зеленые очки?',
		'Какие игры помимо фнф тебе нравятся?',
		'Как ты такой появился',
		'Когда первая авторская песня?',
		'Как ты бы мучал своих жертв, которые как-то относились к пвз/бп?',
		'Как относишься к другим EXE существам?',
		'Оказавшись перед Путиным, что ты ему скажешь?',
		'Любимый вид змей?',
		'Ты ел перец?',
		'Какой внутренний орган человека тебе больше всего понравился по вкусу?',
		'Твой любимый музыкальный инструмент'
	];
	private var grpQna:FlxTypedGroup<FlxText>;

	var goodMenu:FlxSound;
	var badMenu:FlxSound;
	var musicPlaying = false;
	var musicIsGood = true;

	var tweenUp:FlxTween;
	var tweenUp2:FlxTween;

	override function create()
	{
		super.create();

		FlxG.mouse.visible = true;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the VOID", null);
		#end

		WindowUtil.setTitle("The VOID");

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		switch(FlxG.save.data.progressState)
		{
			case 4:
				firstSequence();

			default:
				blocked = true;
				switch(FlxG.save.data.voidStat)
				{
					case 1:
						disagreeSequence();
					case 2:
						defaultSequence();
				}
		}

		dnbShader = new DaveAndBambiGlitchShader();

		bg = new FlxSprite().loadGraphic(Paths.image('void/bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(FlxG.width * 1.1));
		bg.shader = dnbShader;
		add(bg);
		bg.screenCenter();

		eye = new FlxSprite();
		eye.frames = Paths.getSparrowAtlas('void/talking_eye');
		eye.animation.addByPrefix('default', 'default', 24, true);
		eye.animation.addByPrefix('angry', 'angry', 24, true);
		eye.animation.addByPrefix('frown', 'frown', 24, true);
		eye.animation.addByPrefix('happy', 'happy', 24, true);
		eye.animation.addByPrefix('kill', 'kill', 24, true);
		eye.animation.addByPrefix('left', 'left', 24, true);
		eye.animation.addByPrefix('look', 'look', 24, true);
		eye.animation.addByPrefix('sad', 'sad', 24, true);
		eye.animation.play('default');

		eye.centerOffsets();
		eye.antialiasing = ClientPrefs.data.antialiasing;
		eye.updateHitbox();

		eye.screenCenter();
		eye.y -= 50;

		FlxTween.tween(eye, {y: eye.y + 50}, 1, {ease: FlxEase.quadInOut, type: PINGPONG});

		trailEvil = new FlxTrail(eye, null, 4, 0.1, 0.3, 0.069);

		add(trailEvil);
		add(eye);

		swagDialogue = new FlxTypeText(0, 520, Std.int(FlxG.width * 0.85), "", 24);
		swagDialogue.font = Paths.font("vcr.ttf");
		swagDialogue.alignment = CENTER;
		swagDialogue.color = 0xFFFF0000;
		swagDialogue.screenCenter(X);
		//swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.4)];
		add(swagDialogue);

		// avoids lagspikes while scrolling through menus!
		grpMain = new FlxTypedGroup<FlxText>();
		add(grpMain);

		grpQna = new FlxTypedGroup<FlxText>();
		add(grpQna);

		var v6:Bool = getV6save();
		var wc:Bool = getWCsave();
		var caseGet:Bool = getCaseSave();

		var curNumL:Int = 2;

		if(v6) 
		{
			choise_normal.insert(curNumL, 'О BP V6');
			curNumL++;
		}
		if(wc)
		{
			choise_normal.insert(curNumL, 'О BP Wokeless Edition');
			curNumL++;
		}
		if(caseGet)
		{
			choise_normal.insert(curNumL, 'О BP Pepper\'s Case');
			curNumL++;
		}

		if(v6 && wc && caseGet) 
		{
			choise_normal.insert(curNumL, 'Отдать части');
		}

		var maincurID:Int = -1;
		for (i in 0...choise_normal.length)
		{
			var optionText:FlxText = new FlxText(-500, 10, 0, choise_normal[i]);
			optionText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.RED, LEFT);
			maincurID += 1;
			optionText.ID = maincurID;
			grpMain.add(optionText);
		}
		
		var qnacurID:Int = -1;
		for (i in 0...choise_qna.length)
		{
			var optionText:FlxText = new FlxText(FlxG.width + 500, 10, 500, choise_qna[i]);
			optionText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT);
			qnacurID += 1;
			optionText.ID = qnacurID;
			grpQna.add(optionText);
		}

		blackBox = new FlxSprite(0, -40).makeGraphic(FlxG.width, 40, FlxColor.BLACK);
		blackBox.scrollFactor.set();
		blackBox.alpha = 1;
		add(blackBox);

		changeModeText = new FlxText(0, -44, FlxG.width, "MAIN HUB", 32);
		changeModeText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		changeModeText.scrollFactor.set();
		add(changeModeText);

		texts = new FlxTypedSpriteGroup<FlxText>();
		texts.alpha = 0.0;
		add(texts);

		goodMenu = new FlxSound().loadEmbedded(Paths.music('void/void_room-happy'));
		goodMenu.looped = true;
		goodMenu.volume = 0;

		badMenu = new FlxSound().loadEmbedded(Paths.music('void/void_room-weird'));
		badMenu.looped = true;
		badMenu.volume = 0;

		if (leftArrows == null){
			leftArrows = new FlxSprite(20, 300);
			leftArrows.antialiasing = ClientPrefs.data.antialiasing;
			leftArrows.frames = Paths.getSparrowAtlas('void/arrow');
			leftArrows.animation.addByPrefix('idle', "button");
			leftArrows.animation.addByPrefix('press', "press");
			leftArrows.animation.play('idle');
			leftArrows.screenCenter(Y);
			leftArrows.y += 250;
			leftArrows.visible = false;
		}
		add(leftArrows);

		if (rightArrows == null){
			rightArrows = new FlxSprite(FlxG.width * 0.94, leftArrows.y);
			rightArrows.antialiasing = ClientPrefs.data.antialiasing;
			rightArrows.frames = Paths.getSparrowAtlas('void/arrow');
			rightArrows.screenCenter(Y);
			rightArrows.animation.addByPrefix('idle', "button");
			rightArrows.animation.addByPrefix('press', "press");
			rightArrows.flipX = true;
			rightArrows.animation.play('idle');
			rightArrows.y += 250;
			rightArrows.visible = false;
		}
		add(rightArrows);
	}

	function firstSequence()
	{
		FlxTransitionableState.skipNextTransOut = true; //skip the original transition fade
		FlxG.camera.flash(FlxColor.WHITE, 3, true);
		
		ambience = new FunkinSound();

		ambience.loadEmbedded(Paths.music('void/void_ambient'), true, true);
		ambience.volume = 0.6;
		ambience.play(false);

		FlxG.sound.list.add(ambience);

		new FlxTimer().start(3, function(timer:FlxTimer)
		{
			FlxG.sound.playMusic(Paths.music('void/void_intro'), 0);
			FlxG.sound.music.fadeIn(3, 0, 0.6);
			FlxG.sound.music.pitch = 0.6;
			initDialog('pep_intro', 'intro_state', 'choise_intro');
		});
	}

	function disagreeSequence()
	{
		ambience = new FunkinSound();

		ambience.loadEmbedded(Paths.music('void/void_ambient'), true, true);
		ambience.volume = 0.6;
		ambience.play(false);

		FlxG.sound.list.add(ambience);

		new FlxTimer().start(1, function(timer:FlxTimer)
		{
			initRandomDialog('pep_return', 'intro_state', 'choise_return', 4);
		});
	}

	function defaultSequence()
	{
		new FlxTimer().start(1, function(timer:FlxTimer)
		{
			initRandomDialog('pep_hi', 'main_state', 'activate_menu', 8);
		});
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
						if(talkVoice != null) talkVoice.stop();

						dialogueOpened = false;
						dialogueStarted = false;

						switch(stateAfter)
						{
							case 'choise_intro':
								new FlxTimer().start(1, function(timer:FlxTimer)
								{
									final keys = ["Помочь", "Отказ"];
									for (i in 0...keys.length) {
										final button = new FlxText(0, 0, FlxG.width, keys[i]);
										button.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
										button.y = 550;
										button.x += (128 * i) - 80;
										button.alpha = 0.6;
										texts.add(button);
									}

									inChoise = true;

									new FlxTimer().start(0.5, function(timer:FlxTimer)
									{
										inChoise = true;
									});

									FlxTween.tween(texts, {alpha: 0.6}, 0.5, {
										onComplete: (_) -> updateItems()
									});
								});

								FlxTween.tween(FlxG.sound.music, {pitch: 0.25}, 1, {ease: FlxEase.linear});

							case 'choise_end':
								blocked = true;
								new FlxTimer().start(0.3, function(timer:FlxTimer)
								{
									final keys = ["Отдать", "Потом"];
									for (i in 0...keys.length) {
										final button = new FlxText(0, 0, FlxG.width, keys[i]);
										button.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
										button.y = 550;
										button.x += (128 * i) - 80;
										button.alpha = 0.6;
										texts.add(button);
									}

									new FlxTimer().start(0.3, function(timer:FlxTimer)
									{
										inChoise = true;
									});

									texts.alpha = 0;

									FlxTween.tween(texts, {alpha: 0.6}, 0.3, {
										onComplete: (_) -> updateItems()
									});
								});

							case 'choise_return':
								new FlxTimer().start(1, function(timer:FlxTimer)
								{
									final keys = ["Помочь", "Отказ"];
									for (i in 0...keys.length) {
										final button = new FlxText(0, 0, FlxG.width, keys[i]);
										button.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
										button.y = 550;
										button.x += (128 * i) - 80;
										button.alpha = 0.6;
										texts.add(button);
									}
	
									inChoise = true;
	
									new FlxTimer().start(0.5, function(timer:FlxTimer)
									{
										inChoise = true;
									});
	
									FlxTween.tween(texts, {alpha: 0.6}, 0.5, {
										onComplete: (_) -> updateItems()
									});
								});

							case 'disagree_first':
								FlxTransitionableState.skipNextTransOut = false;
								FlxTransitionableState.skipNextTransIn = false;

								FlxG.save.data.progressState = 5;
								FlxG.save.data.voidStat = 1;
								FlxG.save.flush();

								generateTextFile('Хмммммм....\nСлушай, у меня есть идея\nЯ понимаю ты ему не хочешь помогать... но...\nУ меня появилась идея что поможет нам обоим\nСогласись помочь ему, я не думаю что он собирается нас убить в этот раз\nРискнуть можно попробовать...\nЯ подожду пока, удачи!\n\n\n\n\n                 -Таинственный незнакомец', 'Сообщение_для_тебя');

								ambience.stop();
								WindowUtil.setTitle("Pepper's Files");
								FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
								MusicBeatState.switchState(new StoryMenuState());

							case 'leave':
								FlxTransitionableState.skipNextTransOut = false;
								FlxTransitionableState.skipNextTransIn = false;

								ambience.stop();
								WindowUtil.setTitle("Pepper's Files");
								FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
								MusicBeatState.switchState(new StoryMenuState());

							case 'leave2':
								WindowUtil.setTitle("Pepper's Files");
								FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
								MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());

							case 'agree':
								FlxTransitionableState.skipNextTransOut = false;
								FlxTransitionableState.skipNextTransIn = false;

								var save:FlxSave = new FlxSave();
								save.bind('unlock', CoolUtil.getSavePath());
								save.data.smth = 'OYkkEua';
								save.flush();

								generateTextFile('Хммм... не так я это всё представлял...\nНо ладно, просто послушай его ладно?\nИди и проходи эти билды\nОни должны быть в пути assets/games/unused вроде бы...\nТам ещё вроде больше билдов есть, но я не думаю что они как-то важны\nПомни, просто делай то что он говорит, я думаю я знаю к чему это приведет\nЭто билет к свободе от всего!\nЛадно удачи, еще встретимся!\n\n\n\n                 -Таинственный незнакомец', 'Сообщение_для_тебя');

								FlxG.save.data.progressState = 5;
								FlxG.save.data.voidStat = 2;
								FlxG.save.flush();

								ambience.stop();
								WindowUtil.setTitle("Pepper's Files");
								FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
								MusicBeatState.switchState(new StoryMenuState());

							case 'back':
								badMenu.volume = 0;
								FlxG.sound.music.volume = 1;
								musicIsGood = true;

								eye.animation.play('default');

								grpMain.forEach(function(spr:FlxText)
								{
									spr.visible = true;
								});
				
								grpQna.forEach(function(spr:FlxText)
								{
									spr.visible = true;
								});

								rightArrows.visible = true;
								leftArrows.visible = true;
								

							case 'activate_menu':
								blocked = false;

								rightArrows.visible = true;
								leftArrows.visible = true;

								FlxG.sound.playMusic(Paths.music('void/void_room-happy'));
								FlxG.sound.music.fadeIn(0, 1, 1);

								if (goodMenu != null)
								{
									goodMenu.stop();
								}
								if (badMenu != null)
								{
									badMenu.stop();
								}

								musicPlaying = true;

								goodMenu.play();
								badMenu.play();

								changeSelection(0, false);
								in_hub = true;

								eye.animation.play('default');

								if(tweenUp != null) tweenUp.cancel();
								tweenUp = FlxTween.tween(blackBox, {y: 0}, 1, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
								{
									tweenUp = null;
								}});

								if(tweenUp2 != null) tweenUp2.cancel();
								tweenUp2 = FlxTween.tween(changeModeText, {y: 4}, 1, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
								{
									tweenUp2 = null;
								}});
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
			else if(!inChoise)
			{
				if(!blocked)
				{
					grpMain.forEach(function(spr:FlxText)
					{
						spr.visible = false;
					});
	
					grpQna.forEach(function(spr:FlxText)
					{
						spr.visible = false;
					});

					rightArrows.visible = false;
					leftArrows.visible = false;
	
					if(isMainHub)
					{
						var daSelected:String = choise_normal[curSelectedMain];
						switch(daSelected)
						{
							case 'Напомнить о текущем задании':
								initDialog('pep_remind', 'main_state', 'back');
							case 'Интересный Факт':
								initDialog('facts/pep_fact'+FlxG.random.int(0,6), 'main_state', 'back');
							case 'О BP V6':
								initDialog('pep_v6', 'main_state', 'back');
							case 'О BP Wokeless Edition':
								initDialog('pep_wc', 'main_state', 'back');
							case 'О BP Pepper\'s Case':
								initDialog('pep_case', 'main_state', 'back');
							case "Отдать части":
								initDialog('pep_end', 'main_state', 'choise_end');
						}
					}
					else
					{
						initDialog('question_'+curSelectedQna, 'question_state', 'back');
					}
				}
			}
		}

		if(inChoise)
		{
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				isYes = !isYes;
				updateItems();
			}

			if (controls.ACCEPT) {
				inChoise = false;
				texts.remove(texts.members[0]);
				texts.remove(texts.members[1]);

				if(!in_hub)
				{
					ambience.stop();

					if(FlxG.sound.music != null)
						FlxG.sound.music.stop();
				}

				switch(stateAfter)
				{
					case 'choise_intro':
						if(isYes)
						{
							initDialog('pep_agree', 'intro_state', 'agree');
							FlxG.sound.playMusic(Paths.music('void/void_room-accept'), 0.6);
							FlxG.sound.music.pitch = 0.6;
						}
						else
						{
							initDialog('pep_disagree', 'intro_state', 'disagree_first');
						}

					case 'choise_end':
						if(isYes)
						{
							FlxG.sound.music.fadeOut();
							goodMenu.fadeOut();
							badMenu.fadeOut();

							chooseb = true;

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
							black.scale.set(FlxG.width, FlxG.height);
							black.updateHitbox();
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									FlxTransitionableState.skipNextTransIn = true;
									MusicBeatState.switchState(new funkin.menus.void.EndVoidState());
								}
							});
						}
						else
						{
							blocked = false;
							initDialog('pep_end_later', 'main_state', 'back');
						}

					case 'choise_return':
						if(isYes)
						{
							initDialog('pep_agree', 'intro_state', 'agree');

							FlxG.sound.playMusic(Paths.music('void/void_room-accept'), 0.8);
							FlxG.sound.music.pitch = 0.6;
						}
						else
						{
							initRandomDialog('pep_disagree_two', 'intro_state', 'leave', 3);
						}
				}
			}
		}

		if (in_hub && !inChoise)
		{
			if(!dialogueOpened)
			{
				if (controls.UI_LEFT_P || FlxG.mouse.overlaps(leftArrows) && FlxG.mouse.justPressed) {
					isMainHub = !isMainHub;
					changeModeText.text = isMainHub ? 'MAIN HUB' : 'QNA HUB';
				}

				if (controls.UI_RIGHT_P || FlxG.mouse.overlaps(rightArrows) && FlxG.mouse.justPressed) {
					isMainHub = !isMainHub;
					changeModeText.text = isMainHub ? 'MAIN HUB' : 'QNA HUB';
				}

				if (controls.UI_RIGHT || FlxG.mouse.overlaps(rightArrows) && FlxG.mouse.justPressed)
					rightArrows.animation.play('press')
				else
					rightArrows.animation.play('idle');
	
				if (controls.UI_LEFT || FlxG.mouse.overlaps(leftArrows) && FlxG.mouse.justPressed)
					leftArrows.animation.play('press');
				else
					leftArrows.animation.play('idle');

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

				if (controls.BACK)
				{
					if (!chooseb)
					{
						FlxG.sound.music.stop();
						goodMenu.stop();
						badMenu.stop();
						chooseb = true;
						initRandomDialog('pep_bye', 'main_state', 'leave2', 3);

						grpMain.forEach(function(spr:FlxText)
						{
							spr.visible = false;
						});
		
						grpQna.forEach(function(spr:FlxText)
						{
							spr.visible = false;
						});
	
						rightArrows.visible = false;
						leftArrows.visible = false;
					}
				}
			}

			grpMain.forEach(function(spr:FlxText)
			{
				var lerpVal:Float = Math.exp(-elapsed * 12);
		
				var centY = (FlxG.height/2) - (spr.height /2);
		
				spr.y = FlxMath.lerp(spr.y, centY - 250 - (0-spr.ID) * 50, FlxMath.bound(elapsed * 10, 0, 1));
		
				spr.alpha = (
					spr.ID == curSelectedMain ?
						FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 24, 0, 1))
						:
						FlxMath.lerp(spr.alpha, 0.4, FlxMath.bound(elapsed * 24, 0, 1))
				);

				spr.x = (
					isMainHub ?
						FlxMath.lerp(spr.x, 50, FlxMath.bound(elapsed * 24, 0, 1))
						:
						FlxMath.lerp(spr.x, -500, FlxMath.bound(elapsed * 24, 0, 1))
				);
			});

			grpQna.forEach(function(spr:FlxText)
			{
				var lerpVal:Float = Math.exp(-elapsed * 12);
		
				var centY = (FlxG.height/2) - (spr.height /2);
		
				spr.y = FlxMath.lerp(spr.y, centY - 250 - (curSelectedQna-spr.ID) * 50, FlxMath.bound(elapsed * 10, 0, 1));
		
				spr.alpha = (
					spr.ID == curSelectedQna ?
						FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 24, 0, 1))
						:
						FlxMath.lerp(spr.alpha, 0.4, FlxMath.bound(elapsed * 24, 0, 1))
				);

				spr.x = (
					isMainHub ?
						FlxMath.lerp(spr.x, FlxG.width + 500, FlxMath.bound(elapsed * 24, 0, 1))
						:
						FlxMath.lerp(spr.x, FlxG.width - 525, FlxMath.bound(elapsed * 24, 0, 1))
				);
			});

			if (musicPlaying && badMenu != null && goodMenu != null)
			{
				if (musicIsGood)
				{
					badMenu.time = FlxG.sound.music.time;
				}
			}

			if (goodMenu != null)
			{
				songTime += elapsed * 1000;
				songTime %= goodMenu.length;
			}
		}

		super.update(elapsed);

		if (dnbShader != null) dnbShader.data.uTime.value[0] += elapsed;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (isMainHub)
			curSelectedMain = FlxMath.wrap(curSelectedMain + change, 0, choise_normal.length - 1);
		else
			curSelectedQna = FlxMath.wrap(curSelectedQna + change, 0, choise_qna.length - 1);

		if(playSound) FunkinSound.playOnce(Paths.sound('real_menu_sounds/key_select'), 1);
	}

	function updateItems() {
		// it's clunky but it works.
		texts.members[0].alpha = isYes ? 1.0 : 0.6;
		texts.members[1].alpha = isYes ? 0.6 : 1.0;
	}

	function startDialogue():Void
	{
		cleanDialog();

		swagDialogue.alpha = 1;
		swagDialogue.resetText(dialogueList[0]);

		eye.animation.play(curCharacter);
		eye.centerOffsets();

		if (talkVoice != null) talkVoice.stop();

		if(curRandom)
			talkVoice = FunkinSound.load(Paths.sound('void_pep/'+curPath+'/'+curDial+'/'+curDialogue + '_' + curRandomInt), 0.8, false, false, true);
		else
			talkVoice = FunkinSound.load(Paths.sound('void_pep/'+curPath+'/'+curDial+'/'+curDialogue), 0.8, false, false, true);

		if (musicPlaying && badMenu != null && goodMenu != null)
		{
			if(curMusic == 'weird')
			{
				badMenu.volume = 1;
				FlxG.sound.music.volume = 0;
				musicIsGood = false;
			}
			else
			{
				badMenu.volume = 0;
				FlxG.sound.music.volume = 1;
				musicIsGood = true;
			}
		}

		curDialogue++;

		swagDialogue.start(0.03, true);
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		};
	
		dialogueEnded = false;
	}

	function cleanDialog():Void
	{
		if(in_hub)
		{
			var splitName:Array<String> = dialogueList[0].split(':');
			curCharacter = splitName[1];
			curMusic = splitName[2];
			dialogueList[0] = splitName[3];
		}
		else
		{
			var splitName:Array<String> = dialogueList[0].split(':');
			curCharacter = splitName[1];
			dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
		}
	}

	function initDialog(dialogue:String, path:String, state:String):Void
	{
		curRandom = false;
		curDialogue = 0;
		dialogueList = [];

		var file:String = Paths.txt('void_text/'+path+'/'+dialogue); //Checks for vanilla/Senpai dialogue
		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			file = Paths.txt('void_text/'+path+'/'+dialogue);
		}

		stateAfter = state;

		curPath = path;
		curDial = dialogue;

		dialogueList = CoolUtil.coolTextFile(file);

		dialogueOpened = true;
		dialogueStarted = true;

		startDialogue();
	}

	var oneDialogue:Array<String> = [];
	function initRandomDialog(dialogue:String, path:String, state:String, maxNum:Int):Void
	{
		curRandom = true;
		curDialogue = 0;
		dialogueList = [];

		var randomNum:Int = FlxG.random.int(0, maxNum);
		curRandomInt = randomNum;

		var file:String = Paths.txt('void_text/'+path+'/'+dialogue); //Checks for vanilla/Senpai dialogue
		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			file = Paths.txt('void_text/'+path+'/'+dialogue);
		}

		stateAfter = state;

		curPath = path;
		curDial = dialogue;

		oneDialogue = CoolUtil.coolTextFile(file);
		dialogueList[0] = oneDialogue[randomNum];

		dialogueOpened = true;
		dialogueStarted = true;

		startDialogue();
	}

	override public function onFocus():Void
	{
		super.onFocus();
		/*if(talkVoice != null) talkVoice.resume();

		if (musicPlaying && badMenu != null)
		{
			if (!musicIsGood)
			{
				badMenu.volume = 1;
			}
			badMenu.time = FlxG.sound.music.time;
		}*/
	}

	override public function onFocusLost():Void
	{
		super.onFocusLost();
		//if(talkVoice != null) talkVoice.pause();
		//if (badMenu != null) badMenu.volume = 0;
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

	inline public static function getV6save():Bool
	{
		return getFlixelSave('OgreCrew', "BP-v6", 'OgreCrew', 'unlock');
	}

	inline public static function getWCsave():Bool
	{
		return getFlixelSave('OgreCrew', "Brutal-Pizdec-WC", 'OgreCrew', 'unlock');
	}

	public static function getCaseSave():Bool
	{
		var path = Sys.getEnv("userprofile") + '\\AppData\\Roaming\\Godot\\app_userdata\\Case- -Perec.HUI-\\unlock.dat';
		return FileSystem.exists(path);
	}

	public static function getFlixelSave(company:String, title:String, localPath:String = 'ninjamuffin99', name:String = 'funkin', newPath:Bool = false):Bool
	{
		// before anyone asks, this is copy-pasted from FlxSave
		var invalidChars = ~/[ ~%&\\;:"',<>?#]+/;

		// Avoid checking for .sol files directly in AppData
		if (localPath == "")
		{
			var path = company;

			if (path == null || path == "")
			{
				path = "HaxeFlixel";
			}
			else
			{
				#if html5
				// most chars are fine on browsers
				#else
				path = invalidChars.split(path).join("-");
				#end
			}

			localPath = path;
		}

		var directory = lime.system.System.applicationStorageDirectory;
		var path = '';

		if (newPath)
			path = haxe.io.Path.normalize('$directory/../../../$localPath') + "/";
		else
			path = haxe.io.Path.normalize('$directory/../../../$company/$title') + "/";

		name = StringTools.replace(name, "//", "/");
		name = StringTools.replace(name, "//", "/");

		if (StringTools.startsWith(name, "/"))
		{
			name = name.substr(1);
		}

		if (StringTools.endsWith(name, "/"))
		{
			name = name.substring(0, name.length - 1);
		}

		if (name.indexOf("/") > -1)
		{
			var split = name.split("/");
			name = "";

			for (i in 0...(split.length - 1))
			{
				name += "#" + split[i] + "/";
			}

			name += split[split.length - 1];
		}

		//trace(path + name + ".sol");

		return FileSystem.exists(path + name + ".sol");
	}
}