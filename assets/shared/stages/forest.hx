using StringTools;

import flixel.math.FlxBasePoint;
import funkin.graphics.shaders.AdjustColorShader;
import flixel.addons.display.FlxBackdrop;

var colorShader:AdjustColorShader;
var colorCharShader:AdjustColorShader;

var pixelaz:FlxRuntimeShader;
var filterArray:Array<ShaderFilter>;
var pixelBF:FlxRuntimeShader;

var pixelHui:Bool = false;
var pixelCheck:Bool = false;
var actualCameraPosition:FlxBasePoint = new FlxBasePoint(game.camGame.scroll.x, game.camGame.scroll.y);

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
        game.gf.shader = colorCharShader;
    
        getVar('tree').shader = colorShader;
        getVar('floor').shader = colorShader;
    }

    game.initLuaShader('pixel');
    pixelaz = game.createRuntimeShader('pixel');
    pixelBF = game.createRuntimeShader('pixel');

    filterArray = [for (f in [pixelaz]) {new ShaderFilter(f);}];
}
function onSongRestartPost()
{
    if(!ClientPrefs.data.lowQuality)
    {
        game.dad.shader = colorCharShader;
        game.boyfriend.shader = colorCharShader;
        game.gf.shader = colorCharShader;
    }

    FlxTween.cancelTweensOf(gf.alpha);
    gf.alpha = 1;

    getVar('roof').alpha = 0.0001;

    game.camNotes.filters = [];

    getVar('dark').visible = true;
    getVar('shade0').visible = true;
    getVar('shade1').visible = true;
    getVar('shade2').visible = true;
    getVar('floor').visible = true;
    getVar('tree').visible = true;
    getVar('bg').visible = true;

    pixelHui = false;
    FlxG.camera.pixelPerfectRender = false;

}

function onEvent(ev,v1,v2,strumtime)
{
    switch(ev)
    {
        case 'Change Character':
            if(!ClientPrefs.data.lowQuality)
            {
                game.boyfriend.shader = colorCharShader;
                game.dad.shader = colorCharShader;
                game.gf.shader = colorCharShader;
            }

        case 'You Cant Fire Events':
            switch(v1)
            {
                case 'pixel':
                    getVar('roof').alpha = 1;

                    getVar('dark').visible = false;
                    getVar('shade0').visible = false;
                    getVar('shade1').visible = false;
                    getVar('shade2').visible = false;
                    getVar('floor').visible = false;
                    getVar('tree').visible = false;
                    getVar('bg').visible = false;

                    game.boyfriend.shader = null;
                    game.dad.shader = null;

                    pixelHui = true;

                    pixelaz.setFloatArray('uBlocksize', [6,6]);
                    pixelaz.setFloat('mult', 0);
                    pixelaz.setFloatArray('r', [0,0,0]);
                    pixelaz.setFloatArray('g', [0,0,0]);
                    pixelaz.setFloatArray('b', [0,0,0]);

                    game.camNotes.filters = filterArray;
                    FlxG.camera.pixelPerfectRender = true;

                    if(boyfriend.curCharacter == 'bf-pixel')
                        pixelCheck = true;

                    if(boyfriend.curCharacter == 'bf-pixel-classic')
                        pixelCheck = true;

                    if(boyfriend.curCharacter == 'bf-pixel-sonic')
                        pixelCheck = true;

                    if(boyfriend.curCharacter == 'bf-bad-pixel')
                        pixelCheck = true;

                    if(boyfriend.curCharacter == 'bf-badtime-pixel')
                        pixelCheck = true;

                    if(boyfriend.curCharacter == 'bf-badtime-pixel')
                        pixelCheck = true;

                    if(boyfriend.curCharacter == 'bf_ourple')
                        pixelCheck = true;

                    if(!pixelCheck)
                    {
                        boyfriend.shader = pixelBF;
                        boyfriend.pixelPerfectRender = true;
                        boyfriend.pixelPerfectPosition = true;
                    }
                
                case 'unpixel':
                    getVar('roof').alpha = 0.0001;

                    getVar('dark').visible = true;
                    getVar('shade0').visible = true;
                    getVar('shade1').visible = true;
                    getVar('shade2').visible = false;
                    getVar('floor').visible = true;
                    getVar('tree').visible = true;
                    getVar('bg').visible = true;

                    pixelHui = false;

                    game.camNotes.filters = [];
                    FlxG.camera.pixelPerfectRender = false;

                    boyfriend.pixelPerfectRender = false;
                    boyfriend.pixelPerfectPosition = false;
            }
    }
}