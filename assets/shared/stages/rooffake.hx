import funkin.graphics.shaders.AdjustColorShader;

var colorShader:AdjustColorShader;
var bgShader:AdjustColorShader;
var finalColor:AdjustColorShader;

function onCreatePost()
{
    if(!ClientPrefs.data.lowQuality)
    {
        colorShader = new AdjustColorShader();
        colorShader.saturation = -42;
        colorShader.contrast = -15;
        colorShader.brightness = -51;
        colorShader.hue = -8;
    
        bgShader = new AdjustColorShader();
        bgShader.saturation = -33;
        bgShader.contrast = -20;
        bgShader.brightness = -82;
        bgShader.hue = -26;
    
        finalColor = new AdjustColorShader();
        finalColor.contrast = -12;
        finalColor.brightness = -40;
        finalColor.hue = 0;
        finalColor.saturation = -66;
    }
}

function onBeatHit()
{
    if(!ClientPrefs.data.lowQuality)
    {
        switch(curBeat)
        {
            case 300:
                game.dad.shader = colorShader;
                game.boyfriend.shader = colorShader;
    
                getVar('grass').shader = bgShader;
    
            case 485:
                game.dad.shader = finalColor;
                game.boyfriend.shader = finalColor;
    
            case 584:
                FlxTween.num(-12, 0, 10, {ease: FlxEase.linear}, function(thr:Float) 
                { 
                    finalColor.contrast = thr;
                });
    
                FlxTween.num(-40, 0, 10, {ease: FlxEase.linear}, function(thr:Float) 
                { 
                    finalColor.brightness = thr;
                });
    
                FlxTween.num(-66, 0, 10, {ease: FlxEase.linear}, function(thr:Float) 
                { 
                    finalColor.saturation = thr;
                });
                
            case 585:
                game.dad.shader = null;
        }
    }
}