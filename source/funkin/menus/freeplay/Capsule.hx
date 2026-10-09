package funkin.menus.freeplay;

#if sys
import sys.io.File;
#end

import flixel.util.FlxStringUtil;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import lime.utils.Assets;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

import flixel.FlxG;
import flixel.FlxSprite;

import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

class Capsule extends FlxSpriteGroup
{
    var scoreText:FlxText;
    var textRank:FlxText;
    var name:String;
    var curDiff:Int;
    var curVar:Int;
    var difficulty:Int;
    public function new(_x:Float, _y:Float, name:String, bpm:Int, difficulty:Int, curDiff, curVar)
    {
        super(_x, _y);

        this.name = name;
        this.curDiff = curDiff;
        this.curVar = curVar;
        this.difficulty = difficulty;

        var spr:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay_menu/screen'));
        spr.antialiasing = false;
        add(spr);

        var textSong:FlxText = new FlxText(35, 15, 0, name, 52);
        textSong.setFormat(Paths.font("vcr.ttf"), 52, FlxColor.RED, LEFT);
        add(textSong);

        var textBPM:FlxText = new FlxText(35, textSong.y + 50, 250, 'BPM: '+bpm, 52);
        textBPM.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.RED, LEFT);
        add(textBPM);

        scoreText = new FlxText(475, 15, 250, '', 24);
        scoreText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.RED, RIGHT);
        add(scoreText);

        var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(Highscore.getRating(name, curDiff, curVar) * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

        scoreText.text = 'Score: '+ FlxStringUtil.formatMoney(Highscore.getScore(name, curDiff, curVar), false, true)+'\nMisses: '+ Highscore.getMisses(name, curDiff, curVar)+'\nAccuracy: '+ ratingSplit.join('.')+'%\nDifficulty: '+ difficulty;

        var screenshot:FlxSprite = new FlxSprite(35, textBPM.y + 120).loadGraphic(Paths.image('freeplay_menu/screenshots/'+Paths.formatToSongPath(name)));
        screenshot.antialiasing = ClientPrefs.data.antialiasing;
        add(screenshot);

        textRank = new FlxText(475, textBPM.y + 355, 250, 'Rank: SHIT', 52);
        textRank.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.RED, RIGHT);
        add(textRank);

        switch(Highscore.getRank(name, curDiff, curVar))
        {
            case 0:
                textRank.text = 'Rank: P';
                textRank.color = FlxColor.YELLOW;
            case 1:
                textRank.text = 'Rank: P';
            case 2:
                textRank.text = 'Rank: E';
            case 3:
                textRank.text = 'Rank: G';
            case 4:
                textRank.color = 0xFF660000;
                textRank.text = 'Rank: G';
            case 5:
                textRank.color = 0xFF660000;
                textRank.text = 'Rank: L';
            case 6:
                textRank.text = 'Rank: ?';
        }
    }

    public function refreshScore()
    {
        var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(Highscore.getRating(name, curDiff, curVar) * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

        scoreText.text = 'Score: '+ FlxStringUtil.formatMoney(Highscore.getScore(name, curDiff, curVar), false, true)+'\nMisses: '+ Highscore.getMisses(name, curDiff, curVar)+'\nAccuracy: '+ ratingSplit.join('.')+'%\nDifficulty: '+ difficulty;

        textRank.color = 0xFFFF0000;

        switch(Highscore.getRank(name, curDiff, curVar))
        {
            case 0:
                textRank.text = 'Rank: P';
                textRank.color = FlxColor.YELLOW;
            case 1:
                textRank.text = 'Rank: P';
            case 2:
                textRank.text = 'Rank: E';
            case 3:
                textRank.text = 'Rank: G';
            case 4:
                textRank.color = 0xFF660000;
                textRank.text = 'Rank: G';
            case 5:
                textRank.color = 0xFF660000;
                textRank.text = 'Rank: L';
            case 6:
                textRank.text = 'Rank: ?';
        }
    }
}