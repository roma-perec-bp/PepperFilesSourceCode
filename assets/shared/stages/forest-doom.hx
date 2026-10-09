using StringTools;

import flixel.math.FlxBasePoint;
import funkin.graphics.shaders.AdjustColorShader;
import flixel.addons.display.FlxBackdrop;

var colorShader:AdjustColorShader;
var colorCharShader:AdjustColorShader;

function onCreatePost()
{
    if(!ClientPrefs.data.lowQuality)
    {
        colorShader = new AdjustColorShader();
        colorShader.saturation = -33;
        colorShader.contrast = -3;
        colorShader.brightness = -22;
        colorShader.hue = -39;
    
        colorCharShader = new AdjustColorShader();
        colorCharShader.saturation = -38;
        colorCharShader.contrast = 15;
        colorCharShader.brightness = -20;
        colorCharShader.hue = -29;
    
        game.dad.shader = colorCharShader;
        game.boyfriend.shader = colorCharShader;
    
        getVar('tree').shader = colorShader;
        getVar('tree_destroyed').shader = colorShader;
        getVar('floor').shader = colorShader;
    }

    gf.alpha = 0.0001;
}

function onSongRestartPost()
{
    if(!ClientPrefs.data.lowQuality)
    {
        game.dad.shader = colorCharShader;
        game.boyfriend.shader = colorCharShader;
    }

    gf.alpha = 0.0001;
}