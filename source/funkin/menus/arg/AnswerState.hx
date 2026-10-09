package funkin.menus.arg;

import funkin.graphics.shaders.VCRMario85;

import openfl.filters.ShaderFilter;
import openfl.filters.BlurFilter;

import funkin.audio.FunkinSound;

class AnswerState extends MusicBeatState
{
	public var vcr:VCRMario85;

	override public function create():Void
    {
        super.create();
        FlxTransitionableState.skipNextTransOut = true;


        var staticHome:FlxSprite = new FlxSprite();
        staticHome.frames = Paths.getSparrowAtlas('HomeStatic');
        staticHome.animation.addByPrefix('idle', "HomeStatic", 24, true);
        staticHome.animation.play('idle');
        staticHome.antialiasing = false;
        staticHome.alpha = 0.6;
        staticHome.setGraphicSize(FlxG.width, FlxG.height);
        staticHome.updateHitbox();
        staticHome.screenCenter();
        add(staticHome);

        vcr = new VCRMario85();
        FlxG.camera.filters = [new ShaderFilter(vcr)];

        var love = new FlxSprite().loadGraphic(Paths.image('logo_arg', 'embed', false));
        love.antialiasing = false;
        love.scale.set(0.6, 0.6);
        add(love);
        love.screenCenter();
        love.alpha = 0.0001;

        var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 3, FlxColor.BLACK);
        black.scale.set(FlxG.width, FlxG.height);
        black.updateHitbox();
        black.alpha = 1;
        add(black);

        var titleText:FlxText = new FlxText(50, - 100, 0, "Coming Soon\nNow in Development\nalong with other project\ntogether", 48);
        titleText.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        titleText.screenCenter();
        titleText.borderSize = 1.25;
        titleText.alpha = 0.0001;
        add(titleText);

        FlxTween.tween(black, {alpha: 0}, 1);

        FunkinSound.playOnce(Paths.sound('z'), 1);
	
		FlxTween.tween(love, {alpha: 1}, 3, {startDelay: 3, onComplete:
			function(twn:FlxTween) {
                FlxTween.tween(black, {alpha: 1}, 6, {startDelay: 20});
				FlxTween.tween(titleText, {alpha: 1}, 6, {startDelay: 20, onComplete:
					function(twn:FlxTween) {
                        new FlxTimer().start(6, function(tmr:FlxTimer)
                        {
                            FlxG.save.data.startedArg = false;
                            FlxG.save.data.finishedArg = true;
                            FlxG.save.flush();
                            FlxTransitionableState.skipNextTransOut = false;

                            WindowUtil.setTitle("Pepper's Files");
                            FlxG.sound.playMusic(Paths.music('real_menu/pepper_files'));
                            MusicBeatState.switchState(new funkin.menus.mainmenu.MainMenuState());
                        });
					}
				});
			}
		});
    }

    override function update(elapsed:Float)
	{
		super.update(elapsed);

		vcr.update(elapsed);
	}
}