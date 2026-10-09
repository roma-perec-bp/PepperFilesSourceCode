package funkin.submenus;

import funkin.data.WeekData;
import funkin.data.Highscore;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import funkin.menus.storymenu.StoryMenuState;
import funkin.menus.freeplay.FreeplayState;

import funkin.menus.FullScreenScaleMode;

import flixel.FlxSubState;

class ResultSubState extends MusicBeatSubstate
{
	var scoreText:FlxText;
	var rankText:FlxText;

	var song:String;
	var curScore:Int;
	var curMisses:Int;
	var curRating:Float;
	var sicks:Int;
	var goods:Int;
	var bads:Int; 
	var shits:Int; 
	var totalNotes:Int;
	var maxCombo:Int; 
	var finalRank:Int;
	
	var staticTransition:FlxSprite;

	var topBar:FlxSprite;
	var bottomBar:FlxSprite;

	public function new(song:String, curScore:Int, curMisses:Int, curRating:Float, sicks:Int, goods:Int, bads:Int, shits:Int, totalNotes:Int, maxCombo:Int, finalRank:Int)
	{
		this.song = song;
		this.curScore = curScore;
		this.curMisses = curMisses;
		this.curRating = curRating;
		this.sicks = sicks;
		this.goods = goods;
		this.bads = bads;
		this.shits = shits;

		this.totalNotes = totalNotes;
		this.maxCombo = maxCombo;
		this.finalRank = finalRank;

		super();
	}

	override function create()
	{
		Paths.sound('results/confirm');

		Paths.music('results_theme/perfect_gold');
		Paths.music('results_theme/perfect');
		Paths.music('results_theme/excellent');
		Paths.music('results_theme/great');
		Paths.music('results_theme/good');
		Paths.music('results_theme/loss');

		var solidColBeh:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		solidColBeh.alpha = 0.001;
		solidColBeh.blend = ADD;
		add(solidColBeh);

		topBar = new FlxSprite(0, -170).makeGraphic(FlxG.width, 170, FlxColor.BLACK);
		bottomBar = new FlxSprite(0, 720).makeGraphic(FlxG.width, 170, FlxColor.BLACK);

		add(topBar);
		add(bottomBar);

		FlxTween.tween(topBar, {y: 0}, 2, {ease: FlxEase.expoOut});
		FlxTween.tween(bottomBar, {y: 550}, 2, {ease: FlxEase.expoOut});

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(curRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x99000000, 0x66000000));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		var titleText:FlxText = new FlxText(50, - 100, 0, song + ' - Results!', 80);
        titleText.setFormat(Paths.font("vcr.ttf"), 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleText.screenCenter(X);
		titleText.borderSize = 1.25;
        add(titleText);

		FlxTween.tween(titleText, {y: 50}, 2, {ease: FlxEase.expoOut});

		scoreText = new FlxText(50, 175, 0, '', 36);
        scoreText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 1.25;
        add(scoreText);

		rankText = new FlxText(FlxG.width * 0.7, 600, 0, '', 60);
        rankText.setFormat(Paths.font("vcr.ttf"), 60, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rankText.borderSize = 1.25;
        add(rankText);

		var curTime:Float = 0;
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			switch(curTime)
			{
				case 0:
					scoreText.text = 'Total Notes: ${totalNotes}';
					FlxG.sound.play(Paths.sound('results/check'), 1);
				case 1:
					scoreText.text = 'Total Notes: ${totalNotes}\nMax Combo: ${maxCombo}';
					FlxG.sound.play(Paths.sound('results/check'), 1);
				case 2:
					scoreText.text = 'Total Notes: ${totalNotes}\nMax Combo: ${maxCombo}\n\nSicks: ${sicks}';
					FlxG.sound.play(Paths.sound('results/check'), 1);
				case 3:
					scoreText.text = 'Total Notes: ${totalNotes}\nMax Combo: ${maxCombo}\n\nSicks: ${sicks}\nGoods: ${goods}';
					FlxG.sound.play(Paths.sound('results/check'), 1);
				case 4:
					scoreText.text = 'Total Notes: ${totalNotes}\nMax Combo: ${maxCombo}\n\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}';
					FlxG.sound.play(Paths.sound('results/check'), 1);
				case 5:
					scoreText.text = 'Total Notes: ${totalNotes}\nMax Combo: ${maxCombo}\n\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}';
					FlxG.sound.play(Paths.sound('results/check'), 1);
				case 6:
					scoreText.text = 'Total Notes: ${totalNotes}\nMax Combo: ${maxCombo}\n\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n\nScore: ${curScore}';
					FlxG.sound.play(Paths.sound('results/check'), 1);
				case 7:
					scoreText.text = 'Total Notes: ${totalNotes}\nMax Combo: ${maxCombo}\n\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n\nScore: ${curScore}\nMisses: ${curMisses}';
					FlxG.sound.play(Paths.sound('results/check'), 1);
				case 8:
					scoreText.text = 'Total Notes: ${totalNotes}\nMax Combo: ${maxCombo}\n\nSicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\n\nScore: ${curScore}\nMisses: ${curMisses}\nTotal Accuracy: '+ ratingSplit +'%';
					FlxG.sound.play(Paths.sound('results/check'), 1);

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('results/confirm'), 1);
						solidColBeh.alpha = 0.5;
						FlxTween.tween(solidColBeh, {alpha: 0}, 0.5);

						if(finalRank == 5)
						{
							FlxG.save.data.gotLoss = true;
							FlxG.save.flush();
						}

						switch(finalRank)
						{
							case 0:
								rankText.text = 'Rank: PERFECT';
								rankText.color = FlxColor.YELLOW;
								FlxG.sound.playMusic(Paths.music('results_theme/perfect_gold'));
							case 1:
								rankText.text = 'Rank: PERFECT';
								FlxG.sound.playMusic(Paths.music('results_theme/perfect'));
							case 2:
								rankText.text = 'Rank: EXCELLENT';
								FlxG.sound.playMusic(Paths.music('results_theme/excellent'));
							case 3:
								rankText.text = 'Rank: GREAT';
								FlxG.sound.playMusic(Paths.music('results_theme/great'));
							case 4:
								rankText.color = 0xFF666666;
								rankText.text = 'Rank: GOOD';
								FlxG.sound.playMusic(Paths.music('results_theme/good'));
							case 5:
								rankText.color = 0xFF666666;
								rankText.text = 'Rank: LOSS';
								FlxG.sound.playMusic(Paths.music('results_theme/loss'));
							case 6:
								rankText.text = 'Rank: ?';
						}
						rankText.x = FlxG.width * 0.85 - (rankText.width + Math.max(10, FullScreenScaleMode.gameNotchSize.x)); // Right align.
					});
			}
			curTime++;
		}, 9);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();

		staticTransition = new FlxSprite();
		staticTransition.frames = Paths.getSparrowAtlas('staticTV');
		staticTransition.animation.addByPrefix('idle', "static", 24);
        staticTransition.animation.play('idle');
		staticTransition.updateHitbox();
		staticTransition.screenCenter();
		staticTransition.scale.set(4,4);
		staticTransition.alpha = 0.00001;
		add(staticTransition);
	}

	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		super.update(elapsed);

		if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode))
		{
			FlxG.sound.music.stop();
			#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			PlayState.instance.canResync = false;
			Mods.loadTopMod();

			FlxG.sound.play(Paths.sound('real_menu_sounds/static_sound'));
			staticTransition.alpha = 1;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				switch(FlxG.save.data.progressState)
				{
					case 0:
						FlxG.switchState(new funkin.menus.mainmenu.FakeMainMenuState());
						FlxG.sound.playMusic(Paths.music('fake_game/main_menu_mus_fake'));
					case 2:
						WindowUtil.exit();
					default:
						FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
						if (PlayState.isStoryMode)
							MusicBeatState.switchState(new StoryMenuState());
						else
							MusicBeatState.switchState(new FreeplayState());
				}
			});

			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			FlxG.camera.followLerp = 0;
		}
	}
}