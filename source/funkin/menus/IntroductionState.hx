package funkin.menus;

import flixel.FlxSubState;
import funkin.audio.FunkinSound;
import funkin.menus.title.TitleState;
import funkin.objects.VideoSprite;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;
import funkin.graphics.shaders.WiggleEffectRuntime;
import flixel.addons.text.FlxTypeText;
import funkin.graphics.shaders.BloomedShader;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;

class IntroductionState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var isYes:Bool = true;
	var texts:FlxTypedSpriteGroup<FlxText>;
	var bg:FlxSprite;
	var star:BGSprite;
	var star2:BGSprite;

	var introductor:FlxTypeText;
	var inChoise:Bool = false;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	var curDil:Int = -1;
	var state:Int = 0;
	var curSet:Int = -1;

	var wiggleBack:WiggleEffectRuntime = null;
	var bloomShader:BloomedShader = null;
	override function create()
	{
		super.create();

		MusicBeatState.changeCursor(true);

		wiggleBack = new WiggleEffectRuntime(2, 4, 0.017, WiggleEffectType.FLAG);

		star = new BGSprite('star');
		star.setGraphicSize(Std.int(FlxG.width * 1.1));
		star.screenCenter();
		star.antialiasing = false;
		star.shader = wiggleBack;
		add(star);
		star.alpha = 0.5;

		star2 = new BGSprite('star');
		star2.setGraphicSize(Std.int(FlxG.width * 1.1));
		star2.screenCenter();
		star2.antialiasing = false;
		star2.shader = wiggleBack;
		add(star2);
		star2.angle = 180;
		star2.alpha = 0.5;

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		introductor = new FlxTypeText(0, 520, Std.int(FlxG.width * 0.85), "", 21);
		introductor.font = Paths.font('pixel-latin.ttf');
		introductor.alignment = CENTER;
		introductor.color = 0xFFFFFFFF;
		introductor.screenCenter();
		add(introductor);

		texts = new FlxTypedSpriteGroup<FlxText>();
		texts.alpha = 0.0;
		add(texts);

		new FlxTimer().start(2, function(timer:FlxTimer)
		{
			start();
		});

		bloomShader = new BloomedShader();
	}

	function start()
	{
		curDil++;

		switch(curDil)
		{
			case 0:
				dialogueOpened = true;
				dialogueStarted = true;
				FlxG.mouse.visible = false;
				FlxG.sound.playMusic(Paths.music('contact'), 0.6);
				introductor.resetText('Hello?');
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 1:
				introductor.resetText('Are you there?');
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};
			case 2:
				introductor.resetText('Can you hear me?');
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};
			case 3:
				introductor.resetText('Excellent...');
				introductor.alpha = 1;
				introductor.start(0.1, true);
	

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};
			case 4:
				introductor.resetText('We can now start the process.');
				introductor.alpha = 1;
				introductor.start(0.1, true);
				state = 1;

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};
			case 5:
				introductor.resetText('You are now\nParticipating a special program\nThat will change your life entirely.');
				introductor.alpha = 1;
				introductor.start(0.1, true);
				state = 0;

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 6:
				introductor.resetText("This experience\nWon't be forgetable for you.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 7:
				introductor.resetText("But before we start\nWe need to boot your program.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 8:
				introductor.resetText("We do this\nSo there won't be any problems in program in a mean time.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 9:
				introductor.resetText("Don't worry\nYou can still set up your program later\nin the options menu.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 10:
				introductor.resetText("Now\nlet's start with something simple.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 11:
				introductor.resetText("This program will have many flashing lights and flickering objects\nAre you okay with that?");
				introductor.alpha = 1;
				introductor.start(0.075, true);

				dialogueOpened = false;

				new FlxTimer().start(5, function(timer:FlxTimer)
				{
					final keys = ["I'm okay\nwith that", "Disable\nFlashing Lights"];
					for (i in 0...keys.length) {
						final button = new FlxText(0, 0, FlxG.width, keys[i]);
						button.setFormat(Paths.font("pixel-latin.ttf"), 17, FlxColor.WHITE, CENTER);
						button.y = 550;
						button.screenCenter(X);
						if(i == 0)
							button.x -= 300;
						else
							button.x += 300;

						button.alpha = 0.6;
						texts.add(button);
					}

					new FlxTimer().start(1, function(timer:FlxTimer)
					{
						inChoise = true;
					});

					texts.alpha = 0;

					FlxTween.tween(texts, {alpha: 0.6}, 1, {
						onComplete: (_) -> updateItems()
					});
				});

			case 12:
				introductor.resetText("This program might be heavy for you pc\nIs your pc okay with that?");
				introductor.alpha = 1;
				introductor.start(0.075, true);

				new FlxTimer().start(5, function(timer:FlxTimer)
				{
					final keys = ["It can\nhandle it", "Make it\nlow quality"];
					for (i in 0...keys.length) {
						final button = new FlxText(0, 0, FlxG.width, keys[i]);
						button.setFormat(Paths.font("pixel-latin.ttf"), 17, FlxColor.WHITE, CENTER);
						button.y = 550;
						button.screenCenter(X);
						if(i == 0)
							button.x -= 300;
						else
							button.x += 300;
						button.alpha = 0.6;
						texts.add(button);
					}

					new FlxTimer().start(1, function(timer:FlxTimer)
					{
						inChoise = true;
					});

					texts.alpha = 0;

					FlxTween.tween(texts, {alpha: 0.6}, 1, {
						onComplete: (_) -> updateItems()
					});
				});

			case 13:
				introductor.resetText("If you need some boost on your pc, we can run images in gpu\nYou want to do that?\n(Warning, PC with no videocard might have issues with program)");
				introductor.alpha = 1;
				introductor.start(0.075, true);

				new FlxTimer().start(5, function(timer:FlxTimer)
				{
					final keys = ["Sure, why not", "Nope"];
					for (i in 0...keys.length) {
						final button = new FlxText(0, 0, FlxG.width, keys[i]);
						button.setFormat(Paths.font("pixel-latin.ttf"), 17, FlxColor.WHITE, CENTER);
						button.y = 550;
						button.screenCenter(X);
						if(i == 0)
							button.x -= 300;
						else
							button.x += 300;
						button.alpha = 0.6;
						texts.add(button);
					}

					new FlxTimer().start(1, function(timer:FlxTimer)
					{
						inChoise = true;
					});

					texts.alpha = 0;

					FlxTween.tween(texts, {alpha: 0.6}, 1, {
						onComplete: (_) -> updateItems()
					});
				});

			case 14:
				introductor.resetText("What is your most favourite key bind setting for rhythm games like this?\nDo you prefer WASD or DFJK?\n(You can set your own keybinds in options later)");
				introductor.alpha = 1;
				introductor.start(0.075, true);

				new FlxTimer().start(5, function(timer:FlxTimer)
				{
					final keys = ["DFJK", "WASD"];
					for (i in 0...keys.length) {
						final button = new FlxText(0, 0, FlxG.width, keys[i]);
						button.setFormat(Paths.font("pixel-latin.ttf"), 17, FlxColor.WHITE, CENTER);
						button.y = 550;
						button.screenCenter(X);
						if(i == 0)
							button.x -= 300;
						else
							button.x += 300;
						button.alpha = 0.6;
						texts.add(button);
					}

					new FlxTimer().start(1, function(timer:FlxTimer)
					{
						inChoise = true;
					});

					texts.alpha = 0;

					FlxTween.tween(texts, {alpha: 0.6}, 1, {
						onComplete: (_) -> updateItems()
					});
				});

			case 15:
				introductor.resetText("Do you prefer notes going from up?\nOr down?");
				introductor.alpha = 1;
				introductor.start(0.075, true);

				new FlxTimer().start(3, function(timer:FlxTimer)
				{
					final keys = ["downscroll", "upscroll"];
					for (i in 0...keys.length) {
						final button = new FlxText(0, 0, FlxG.width, keys[i]);
						button.setFormat(Paths.font("pixel-latin.ttf"), 17, FlxColor.WHITE, CENTER);
						button.y = 550;
						button.screenCenter(X);
						if(i == 0)
							button.x -= 300;
						else
							button.x += 300;
						button.alpha = 0.6;
						texts.add(button);
					}

					new FlxTimer().start(1, function(timer:FlxTimer)
					{
						inChoise = true;
					});

					texts.alpha = 0;

					FlxTween.tween(texts, {alpha: 0.6}, 1, {
						onComplete: (_) -> updateItems()
					});
				});

			case 16:
				introductor.resetText("What about middle side?\nDo you want to see your strumlines on the middle of the screen?");
				introductor.alpha = 1;
				introductor.start(0.075, true);

				new FlxTimer().start(3, function(timer:FlxTimer)
				{
					final keys = ["Sure\nmiddlescroll", "I want to see\ntwo strumlines"];
					for (i in 0...keys.length) {
						final button = new FlxText(0, 0, FlxG.width, keys[i]);
						button.setFormat(Paths.font("pixel-latin.ttf"), 17, FlxColor.WHITE, CENTER);
						button.y = 550;
						button.screenCenter(X);
						if(i == 0)
							button.x -= 300;
						else
							button.x += 300;
						button.alpha = 0.6;
						texts.add(button);
					}

					new FlxTimer().start(1, function(timer:FlxTimer)
					{
						inChoise = true;
					});

					texts.alpha = 0;

					FlxTween.tween(texts, {alpha: 0.6}, 1, {
						onComplete: (_) -> updateItems()
					});
				});

			case 17:
				introductor.resetText('This program requires from you\nAn experience playing 2 mods like\n"Brutal Pizdec" and "Brutal Pizdec DLC"\nsince this program mostly based on these mods\nHave you played them? (This won\'t affect anything)');
				introductor.alpha = 1;
				introductor.start(0.075, true);

				new FlxTimer().start(13, function(timer:FlxTimer)
				{
					final keys = ["Yes", "No"];
					for (i in 0...keys.length) {
						final button = new FlxText(0, 0, FlxG.width, keys[i]);
						button.setFormat(Paths.font("pixel-latin.ttf"), 17, FlxColor.WHITE, CENTER);
						button.y = 550;
						button.screenCenter(X);
						if(i == 0)
							button.x -= 300;
						else
							button.x += 300;
						button.alpha = 0.6;
						texts.add(button);
					}

					new FlxTimer().start(1, function(timer:FlxTimer)
					{
						inChoise = true;
					});

					texts.alpha = 0;

					FlxTween.tween(texts, {alpha: 0.6}, 1, {
						onComplete: (_) -> updateItems()
					});
				});

			case 18:
				dialogueEnded = false;
				dialogueOpened = true;
				introductor.resetText("Interesting.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 19:
				introductor.resetText("Very\nInteresting.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 20:
				introductor.resetText("We're almost\ndone.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 21:
				introductor.resetText("Now it's time\nfor the\nfinal test.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 22:
				introductor.resetText("Let's take a little test\nTo see how good you are.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 23:
				introductor.resetText("After that\nWe can finally\nBegin.");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 24:
				introductor.resetText("Hope you ready...");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

			case 25:
				introductor.resetText("Test\nStarts...\nNOW!");
				introductor.alpha = 1;
				introductor.start(0.1, true);

				introductor.completeCallback = function() {
					dialogueEnded = true;
				};

				state = 2;
				ClientPrefs.saveSettings();
		}
	}

	function updateItems() {
		// it's clunky but it works.
		texts.members[0].alpha = isYes ? 1.0 : 0.6;
		texts.members[1].alpha = isYes ? 0.6 : 1.0;
	}

	override function update(elapsed:Float)
	{
		if(inChoise)
		{
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				isYes = !isYes;
				updateItems();
			}

			if (controls.ACCEPT)
			{
				FlxTween.tween(introductor, {alpha: 0}, 1, {onComplete:
					function(twn:FlxTween) {
						start();
					}
				});
				
				inChoise = false;
				texts.remove(texts.members[0]);
				texts.remove(texts.members[1]);
				texts.alpha = 0;
				curSet++;
				switch(curSet)
				{
					case 0:
						ClientPrefs.data.flashing = isYes;
					case 1:
						ClientPrefs.data.lowQuality = !isYes;
					case 2:
						ClientPrefs.data.cacheOnGPU = isYes;
					case 3:
						if(isYes)
						{
							ClientPrefs.keyBinds.set('note_left', [FlxKey.D, FlxKey.LEFT]);
							ClientPrefs.keyBinds.set('note_down', [FlxKey.F, FlxKey.DOWN]);
							ClientPrefs.keyBinds.set('note_up', [FlxKey.J, FlxKey.UP]);
							ClientPrefs.keyBinds.set('note_right', [FlxKey.K, FlxKey.RIGHT]);
						}
					case 4:
						ClientPrefs.data.downScroll = isYes;
					case 5:
						ClientPrefs.data.middleScroll = isYes;
				}
			}
		}

		if (controls.ACCEPT)
		{
			if(dialogueOpened)
			{
				if(!inChoise)
				{
					if(dialogueEnded)
					{
						dialogueEnded = false;
						switch(state)
						{
							case 0:
								FlxTween.tween(introductor, {alpha: 0}, 1, {onComplete:
									function(twn:FlxTween) {
										dialogueEnded = false;
										start();
									}
								});
							case 1:
								FlxG.sound.music.fadeOut(2);
								FlxTween.tween(introductor, {alpha: 0}, 3, {onComplete:
									function(twn:FlxTween) {
										FlxG.camera.filters = [new ShaderFilter(bloomShader)];
										FlxG.sound.playMusic(Paths.music('aNewFate'), 0);
										FlxG.sound.music.fadeIn(4.0, 0.0, 1.0);
										introductor.borderStyle = SHADOW;
										introductor.borderColor = 0xFF270f39;
										introductor.shadowOffset.set(2, 2);
										FlxTween.tween(bg, {alpha: 0}, 5, {onComplete:
											function(twn:FlxTween) {
												dialogueEnded = false;
												start();
											}
										});
									}
								});

							case 2:
								FlxG.sound.music.fadeOut(3);

								FlxG.camera.fade(FlxColor.BLACK, 3);

								ClientPrefs.data.noteSkin = 'Classic';
								ClientPrefs.data.splashSkin = 'vanilla';

								new FlxTimer().start(4, function(timer:FlxTimer)
								{
									FlxG.mouse.visible = false;
									var poop = Highscore.formatSong('boot', 1, 0);
									Song.loadFromJson(poop, 'boot');
									PlayState.storyDifficulty = 1;
									PlayState.variation = 0;
									FlxG.state.persistentUpdate = false;
									LoadingState.loadAndSwitchState(new PlayState(), false, false);
								});
						}
					}
				}
			}

		}

		if (wiggleBack != null) wiggleBack.update(elapsed);

		super.update(elapsed);
	}
}
