import funkin.graphics.shaders.AdjustColorShader;
import funkin.graphics.shaders.DropShadowShader;

var rimDad = new DropShadowShader();
var rimBf = new DropShadowShader();

var iconA4;

var colorShader:AdjustColorShader;
var shitColor:AdjustColorShader;

var iconCount:Int = -1;

var distanceAvg:Int = 15;

function onCreatePost()
{
    iconA4 = new FlxSprite(0,0).loadGraphic(Paths.image('end/icons/0'));
    iconA4.cameras = [camHUD];
    iconA4.antialiasing = ClientPrefs.data.antialiasing;
    add(iconA4);
    iconA4.visible = false;
    iconA4.alpha = 0.4;

    iconA4.y = iconP2.y;

    if(!ClientPrefs.data.lowQuality)
    {
        colorShader = new AdjustColorShader();
        colorShader.saturation = -100;
        colorShader.contrast = 52;
        colorShader.hue = 0;
    
        shitColor = new AdjustColorShader();
        shitColor.contrast = 50;
        shitColor.brightness = -68;
        shitColor.hue = 0;
        shitColor.saturation = 0;
    
        rimDad = new DropShadowShader();
        rimDad.setAdjustColor(-19, -30, 10, -44);
        rimDad.color = 0xFFFF0000;
        rimDad.attachedSprite = game.dad;
        rimDad.distance = 15;
        rimDad.angle = 90;
    
        game.dad.animation.onFrameChange.add(function()
        {
            rimDad.updateFrameInfo(game.dad.frame);
        });
    
        rimBf = new DropShadowShader();
        rimBf.setAdjustColor(-100, -30, 36, -51);
        rimBf.color = 0xFFFF0000;
        rimBf.attachedSprite = game.boyfriend;
        distanceAvg = 15;
        rimBf.angle = 90;
    
        if (boyfriend.curCharacter == 'bf_ourple')
        {
            rimBf.altMaskImage = Paths.image("characters/ourplebf-mask").bitmap;
            rimBf.maskThreshold = 1;
            rimBf.useAltMask = true;
            distanceAvg = 5;
        }
    
        if (boyfriend.curCharacter == 'bf-pixel')
        {
            rimBf.altMaskImage = Paths.image("characters/bfPixel-mask").bitmap;
            rimBf.maskThreshold = 1;
            rimBf.useAltMask = true;
            distanceAvg = 3;
        }
    
        rimBf.distance = 0;
        rimDad.distance = 0;
    
        game.boyfriend.animation.onFrameChange.add(function()
        {
            rimBf.updateFrameInfo(game.boyfriend.frame);
        });
    
        game.dad.shader = rimDad;
        game.boyfriend.shader = rimBf;
    
        rimBf.threshold = 0.1;
        rimDad.threshold = 0.1;
    }
}

function onBeatHit()
{
    switch(curBeat)
    {
        case 72:
            if(!ClientPrefs.data.lowQuality) return;

            rimBf.distance = distanceAvg;
            rimDad.distance = 15;

        case 200:
            if(!ClientPrefs.data.lowQuality) return;

            FlxTween.num(distanceAvg, 0, 3, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimBf.distance = thr;
            });

            FlxTween.num(15, 0, 3, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimDad.distance = thr;
            });
        case 232:
            if(!ClientPrefs.data.lowQuality) return;

            FlxTween.num(distanceAvg, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimBf.distance = thr;
            });

            FlxTween.num(15, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimDad.distance = thr;
            });
        case 236:
            if(!ClientPrefs.data.lowQuality) return;

             FlxTween.num(distanceAvg, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimBf.distance = thr;
            });

            FlxTween.num(15, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimDad.distance = thr;
            });
        case 240:
            if(!ClientPrefs.data.lowQuality) return;

            FlxTween.num(distanceAvg, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimBf.distance = thr;
            });

            FlxTween.num(15, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimDad.distance = thr;
            });
        case 244:
            if(!ClientPrefs.data.lowQuality) return;

            FlxTween.num(distanceAvg, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimBf.distance = thr;
            });

            FlxTween.num(15, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimDad.distance = thr;
            });
        case 248:
            if(!ClientPrefs.data.lowQuality) return;

             FlxTween.num(distanceAvg, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimBf.distance = thr;
            });

            FlxTween.num(15, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimDad.distance = thr;
            });
        case 252:
            if(!ClientPrefs.data.lowQuality) return;

            FlxTween.num(distanceAvg, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimBf.distance = thr;
            });

            FlxTween.num(15, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimDad.distance = thr;
            });
         case 256:
            if(!ClientPrefs.data.lowQuality) return;

            FlxTween.num(distanceAvg, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimBf.distance = thr;
            });

            FlxTween.num(15, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimDad.distance = thr;
            });
        case 260:
            if(!ClientPrefs.data.lowQuality) return;
            
            FlxTween.num(distanceAvg, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimBf.distance = thr;
            });

            FlxTween.num(15, 0, 1, {ease: FlxEase.linear}, function(thr:Float) 
            { 
                rimDad.distance = thr;
            });
        case 264:
            game.dad.shader = null;
            game.boyfriend.shader = null;
        case 268:
            if(!ClientPrefs.data.lowQuality) return;
            game.boyfriend.shader = shitColor;
        case 568:
            if(!ClientPrefs.data.lowQuality) return;
            game.dad.shader = colorShader;
            game.boyfriend.shader = colorShader;
        case 1004:
            iconA4.visible = true;

            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/0'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1022:
            iconA4.visible = true;
    
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/1'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1036:
            iconA4.visible = true;
    
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/2'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1052:
            iconA4.visible = true;
        
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/3'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1084:
            iconA4.visible = true;
        
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/4'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1092:
            iconA4.visible = true;
        
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/5'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1100:
            iconA4.visible = true;
        
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/6'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1116:
            iconA4.visible = true;
        
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/7'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});

        case 1200:
            iconA4.visible = true;
        
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/8'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1204:
            iconA4.visible = true;
        
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/9'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1208:
            iconA4.visible = true;
        
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/10'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1212:
            iconA4.visible = true;
        
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/11'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1216:
            iconA4.visible = true;
        
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/12'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1224:
            iconA4.visible = true;
            
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/13'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1232:
            iconA4.visible = true;
            
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/14'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
            case 1240:
            iconA4.visible = true;
            
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/15'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1248:
            iconA4.visible = true;
            
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/16'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
        case 1256:
            iconA4.visible = true;
            
            iconCount++;
            iconA4.visible = true;
            iconA4.loadGraphic(Paths.image('end/icons/17'));
            iconA4.angle = 0;
            FlxTween.tween(iconA4, {angle: iconA4.angle + 360}, 0.25, {ease: FlxEase.backOut});
    }
}

function onUpdate(elapsed)
{
	iconA4.x = iconP2.x;
    iconA4.scale.set(iconP2.scale.x, iconP2.scale.y);
}