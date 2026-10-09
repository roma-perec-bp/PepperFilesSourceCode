using StringTools;

import Main;
import funkin.graphics.shaders.AdjustColorShader;
import flixel.addons.display.FlxBackdrop;

var colorShader:AdjustColorShader;

var bfLegs:Character;
var legs:Character;
var bfAnchorPoint:Array<Float> = [0, 0];
var legPosY = [7, 7, 4, 4, -5, -5, -7, -7, -3, -3, 7, 7, 4, 4, -5, -5, -7, -7, -3, -3];

var clouds:FlxBackdrop;

var end:Bool = false;
var chase:Bool = false;
var gfDrive:Bool = false;

var grass_chase:FlxBackdrop;
var fence_chase:FlxBackdrop;
var this_chase:FlxBackdrop;


//SKIN MM
var leg:FlxSprite;
var arm:FlxSprite;
var singing:Bool = false;

//SKIN BAD
var bfLegsBad:Character;

//SKIN THAT NO RUNNERS
var car:FlxSprite;

function onCreatePost()
{
    clouds = new FlxBackdrop(Paths.image('p1/clouds'), 0x01);
    clouds.scale.set(2,2);
    clouds.updateHitbox();
    clouds.scrollFactor.set(0.3, 0.3);
    clouds.velocity.set(-10, 0);
    clouds.antialiasing = ClientPrefs.data.antialiasing;
    clouds.y = -651;
    insert(members.indexOf(getVar('this')), clouds);

    this_chase = new FlxBackdrop(Paths.image('p1/this_chase'), 0x01, -16);
    this_chase.scale.set(2,2);
    this_chase.updateHitbox();
    this_chase.scrollFactor.set(0.6, 0.6);
    this_chase.velocity.set(-1500, 0);
    this_chase.antialiasing = ClientPrefs.data.antialiasing;
    this_chase.y = 67;
    insert(members.indexOf(gfGroup), this_chase);

    fence_chase = new FlxBackdrop(Paths.image('p1/fences_chase'), 0x01);
    fence_chase.scale.set(2,2);
    fence_chase.updateHitbox();
    fence_chase.scrollFactor.set(0.75, 0.75);
    fence_chase.velocity.set(-2500, 0);
    fence_chase.antialiasing = ClientPrefs.data.antialiasing;
    fence_chase.y = -68;
    insert(members.indexOf(gfGroup), fence_chase);

    grass_chase = new FlxBackdrop(Paths.image('p1/floor_run'), 0x01, -3);
    grass_chase.scale.set(2,2);
    grass_chase.updateHitbox();
    grass_chase.scrollFactor.set(1, 1);
    grass_chase.velocity.set(-3000, 0);
    grass_chase.antialiasing = ClientPrefs.data.antialiasing;
    grass_chase.y = 520;
    insert(members.indexOf(gfGroup), grass_chase);

    fence_chase.alpha = 0.0001;
    grass_chase.alpha = 0.0001;
    this_chase.alpha = 0.0001;

    if(!ClientPrefs.data.lowQuality)
    {
        colorShader = new AdjustColorShader();
        colorShader.saturation = -39;
        colorShader.contrast = -17;
        colorShader.brightness = -29;
        colorShader.hue = 11;
    
        game.dad.shader = colorShader;
        game.boyfriend.shader = colorShader;
        game.gf.shader = colorShader;
    }

    switch(ClientPrefs.data.activeBfSkin)
    {
        case 'mm':
            leg = new FlxSprite(boyfriend.x, boyfriend.y);
            leg.frames = Paths.getSparrowAtlas('characters/Demise_BF_Assets');
            leg.animation.addByPrefix('exist', "Bottom", 24, true);
            leg.animation.play('exist');
            leg.antialiasing = ClientPrefs.data.antialiasing;
            leg.updateHitbox();
            leg.offset.set(50, -230);

            arm = new FlxSprite(boyfriend.x, boyfriend.y);
            arm.frames = Paths.getSparrowAtlas('characters/Demise_BF_Assets');
            arm.animation.addByPrefix('exist2', "BF Right Arm", 24, true);
            arm.animation.play('exist2');
            arm.antialiasing = ClientPrefs.data.antialiasing;
            arm.updateHitbox();
            arm.offset.set(-13, -155);

            boyfriendGroup.insert(0, arm);
            boyfriendGroup.insert(0, leg);

            if(!ClientPrefs.data.lowQuality) arm.shader = colorShader;
            if(!ClientPrefs.data.lowQuality) leg.shader = colorShader;

            arm.flipX = true;
            leg.flipX = true;
            leg.alpha = 0.0001;
            arm.alpha = 0.0001;

        case 'badtime':
            bfLegsBad = new Character(0, 0, 'bf-badtime-run-legs', true);
            if(!ClientPrefs.data.lowQuality)  bfLegsBad.shader = colorShader;
            bfLegsBad.alpha = 0.0001;
            boyfriendGroup.insert(0, bfLegsBad);

        case 'minus1':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);

         case 'minus2':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);
            
        case 'minus3':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);

        case 'ourple':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality)  car.shader = colorShader;
            boyfriendGroup.insert(0, car);

        case 'pixel':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);

        case 'encore':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);

        case 'romfriend':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);          
            
        case 'bad':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);    

        case 'gold':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);    

        case 'bp':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);   

        case 'ruby':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);
            
        case 'bp-dlc':
            car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
            car.frames = Paths.getSparrowAtlas('characters/car_thing');
            car.animation.addByPrefix('car', "car", 24, true);
            car.animation.play('car');
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.updateHitbox();
            car.alpha = 0.0001;

            if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
            boyfriendGroup.insert(0, car);    

        default:
            bfLegs = legs = new Character(0, 0, 'bf-running', true);
            if(!ClientPrefs.data.lowQuality) bfLegs.shader = colorShader;
            bfLegs.alpha = 0.0001;
            legs.alpha = 0.0001;
            boyfriendGroup.insert(0, legs);
        
            bfAnchorPoint[0] = legs.x = boyfriend.x;
            bfAnchorPoint[1] = legs.y = boyfriend.y;

            if(Main.darnellMode)
            {
                bfLegs.visible = false;
                legs.visible = false;

                car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
                car.frames = Paths.getSparrowAtlas('characters/car_thing');
                car.animation.addByPrefix('car', "car", 24, true);
                car.animation.play('car');
                car.antialiasing = ClientPrefs.data.antialiasing;
                car.updateHitbox();
                car.alpha = 0.0001;

                if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
                boyfriendGroup.insert(0, car);    
            }

            if(Main.raldman)
            {
                bfLegs.visible = false;
                legs.visible = false;

                car = new FlxSprite(boyfriend.x - 50, boyfriend.y);
                car.frames = Paths.getSparrowAtlas('characters/car_thing');
                car.animation.addByPrefix('car', "car", 24, true);
                car.animation.play('car');
                car.antialiasing = ClientPrefs.data.antialiasing;
                car.updateHitbox();
                car.alpha = 0.0001;

                if(!ClientPrefs.data.lowQuality) car.shader = colorShader;
                boyfriendGroup.insert(0, car);    
            }
    }
}
function onSongRestartPost()
{
    end = false;
    chase = false;

    if(!ClientPrefs.data.lowQuality)
    {
        game.dad.shader = colorShader;
        game.boyfriend.shader = colorShader;
        game.gf.shader = colorShader;
    }

    switch(ClientPrefs.data.activeBfSkin)
    {
        case 'mm':
            leg.alpha = 0.0001;
            arm.alpha = 0.0001;
        case 'minus1':
            car.alpha = 0.0001;
        case 'minus2':
            car.alpha = 0.0001;
        case 'minus3':
            car.alpha = 0.0001;
        case 'ourple':
            car.alpha = 0.0001;
        case 'pixel':
            car.alpha = 0.0001;
        case 'encore':
            car.alpha = 0.0001;
        case 'romfriend':
            car.alpha = 0.0001;
        case 'bad':
            car.alpha = 0.0001;
        case 'gold':
            car.alpha = 0.0001;
        case 'bp':
            car.alpha = 0.0001;
        case 'bp-dlc':
            car.alpha = 0.0001;
        case 'ruby':
            car.alpha = 0.0001;
         case 'badtime':
            bfLegsBad.alpha = 0.0001;
        default:
            bfLegs.alpha = 0.0001;
            legs.alpha = 0.0001;

            if(Main.darnellMode)
            {
                car.alpha = 0.0001;
            }

            if(Main.raldman)
            {
                car.alpha = 0.0001;
            }
    }

    fence_chase.alpha = 0.0001;
    grass_chase.alpha = 0.0001;
    this_chase.alpha = 0.0001;

    getVar('this').alpha = 1;
    getVar('grass').alpha = 1;
    getVar('fence').alpha = 1;
    if(!ClientPrefs.data.lowQuality) getVar('bushes').alpha = 1;

    clouds.velocity.set(-10, 0);

    FlxTween.cancelTweensOf(dadGroup);

    FlxTween.cancelTweensOf(this_chase.velocity);
    FlxTween.cancelTweensOf(fence_chase.velocity);
    FlxTween.cancelTweensOf(grass_chase.velocity);

    gf.velocity.x = 0;
    gf.x = GF_X;

    this_chase.velocity.set(-1500, 0);
    fence_chase.velocity.set(-2500, 0);
    grass_chase.velocity.set(-3000, 0);
}

function onEvent(ev,v1,v2,strumtime)
{
    switch(ev)
    {
        case 'Change Character':
            if(!ClientPrefs.data.lowQuality)
            {
                game.dad.shader = colorShader;
                game.boyfriend.shader = colorShader;
                game.gf.shader = colorShader;
            }

        case 'Too Fire Events':
            switch(v1)
            {
                case 'chase':
                    switch(ClientPrefs.data.activeBfSkin)
                    {
                        case 'mm':
                            leg.alpha = 1;
                            arm.alpha = 1;

                        case 'minus1':
                            car.alpha = 1;

                        case 'minus2':
                            car.alpha = 1;

                        case 'minus3':
                            car.alpha = 1;

                        case 'ourple':
                            car.alpha = 1;

                        case 'pixel':
                            car.alpha = 1;

                        case 'encore':
                            car.alpha = 1;

                        case 'romfriend':
                            car.alpha = 1;

                        case 'bad':
                            car.alpha = 1;

                        case 'gold':
                            car.alpha = 1;

                        case 'bp':
                            car.alpha = 1;

                        case 'bp-dlc':
                            car.alpha = 1;

                        case 'ruby':
                            car.alpha = 1;

                        case 'badtime':
                            bfLegsBad.alpha = 1;

                        default:
                            bfLegs.alpha = 1;
                            legs.alpha = 1;

                            if(Main.darnellMode)
                            {
                                car.alpha = 1;
                            }

                            if(Main.raldman)
                            {
                                car.alpha = 1;
                            }
                    }

                    chase = true;

                    fence_chase.alpha = 1;
                    grass_chase.alpha = 1;
                    this_chase.alpha = 1;
                
                    getVar('this').alpha = 0.0001;
                    getVar('grass').alpha = 0.0001;
                    getVar('fence').alpha = 0.0001;
                    if(!ClientPrefs.data.lowQuality) getVar('bushes').alpha = 0.0001;
                
                    clouds.velocity.set(-100, 0);

                    switch(ClientPrefs.data.activeBfSkin)
                    {
                        case 'mm':
                            bfAnchorPoint[0] = leg.x = arm.x = boyfriend.x;
                            bfAnchorPoint[1] = leg.y = arm.y = boyfriend.y;

                            leg.animation.play('exist', true);
                            arm.animation.play('exist2', true);

                        case 'minus1':
                            car.x = boyfriend.x - 150;
                            car.y = boyfriend.y + 375;

                        case 'minus2':
                            car.x = boyfriend.x - 150;
                            car.y = boyfriend.y + 375;

                        case 'minus3':
                            car.x = boyfriend.x - 150;
                            car.y = boyfriend.y + 375;

                        case 'ourple':
                            car.x = boyfriend.x - 500;
                            car.y = boyfriend.y + 200;

                        case 'pixel':
                            car.x = boyfriend.x - 350;
                            car.y = boyfriend.y + 175;

                        case 'encore':
                            car.x = boyfriend.x - 150;
                            car.y = boyfriend.y + 460;

                        case 'romfriend':
                            car.x = boyfriend.x - 150;
                            car.y = boyfriend.y + 420;

                        case 'bad':
                            car.x = boyfriend.x - 150;
                            car.y = boyfriend.y + 375;

                        case 'gold':
                            car.x = boyfriend.x - 150;
                            car.y = boyfriend.y + 420;

                        case 'bp':
                            car.x = boyfriend.x - 150;
                            car.y = boyfriend.y + 420;

                        case 'bp-dlc':
                            car.x = boyfriend.x - 150;
                            car.y = boyfriend.y + 375;

                        case 'ruby':
                            car.x = boyfriend.x - 50;
                            car.y = boyfriend.y + 500;

                        case 'badtime':
                            setBadLegsAnim('idle');
                            bfLegsBad.x = boyfriend.x - 135;
                            bfLegsBad.y = boyfriend.y + 350;                

                       /* case 'minus2' | 'minus3' | 'ourple' | 'pixel' | 'encore' | 'romfriend' | 'bad' | 'gold' | 'bp' | 'bp-dlc':
                            //nothing*/

                        default:
                            legs.animation.pause();
                            setLegsAnim('legs');
        
                            bfAnchorPoint[0] = legs.x = boyfriend.x;
                            bfAnchorPoint[1] = legs.y = boyfriend.y;

                            if(Main.darnellMode)
                            {
                                car.x = boyfriend.x + 100;
                                car.y = boyfriend.y + 475;
                            }

                            if(Main.raldman)
                            {
                                car.x = boyfriend.x - 100;
                                car.y = boyfriend.y + 425;
                            }
                    }

                    FlxTween.tween(dadGroup, {x: DAD_X - 50}, 0.2, {ease: FlxEase.quadInOut, type: 4});
                    FlxTween.tween(dadGroup, {y: DAD_Y + 100}, 0.4, {ease: FlxEase.quadInOut, type: 4});

                    resetFastCar();

                case 'end':
                    FlxTween.cancelTweensOf(dadGroup);
                    FlxTween.cancelTweensOf(dadGroup.x);
                    FlxTween.cancelTweensOf(dadGroup.y);
                    
                    FlxTween.tween(fence_chase.velocity, {x: 0}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.expoOut});
                    FlxTween.tween(grass_chase.velocity, {x: 0}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.expoOut});
                    FlxTween.tween(this_chase.velocity, {x: 0}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.expoOut});

                    FlxTween.tween(gf.velocity, {x: 0}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.expoOut});

                    FlxTween.tween(boyfriend, {x: 3000}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.expoOut});

                    switch(ClientPrefs.data.activeBfSkin)
                    {
                        case 'mm':
                            FlxTween.tween(leg, {x: 3000}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.expoOut});
                            FlxTween.tween(arm, {x: 3000}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.expoOut});
                    }

                    if(legs != null)
                        FlxTween.tween(legs, {x: 3000}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.expoOut});

                    if(bfLegsBad != null)
                        FlxTween.tween(bfLegsBad, {x: 3000}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.expoOut});

                    if(car != null)
                        FlxTween.tween(car, {x: 3000}, Conductor.stepCrochet * 8 / 1000, {ease: FlxEase.expoOut});

                    end = true;
                    chase = false;
            }
    }
}

function onBeatHit()
{
    if (FlxG.random.bool(50) && gfDrive && chase) fastCarDrive();
}

function fastCarDrive()
{
    gf.x = 2000;
    gf.velocity.x = -3000;
    gfDrive = false;

    if(chase)
    {
        new FlxTimer().start(3, function(tmr:FlxTimer)
        {
            if(chase)
                resetFastCar();
        });
    }
}

function resetFastCar()
{
    gf.x = -12600;
    gf.velocity.x = 0;
    gfDrive = true;
}

function onUpdatePost(elapsed)
{
    if(boyfriend.curCharacter == 'bf-running')
    {
        var name:String = boyfriend.getAnimationName();
        
        if (!boyfriend.getAnimationName().contains('miss') && legs.getAnimationName() == 'legs-miss') setLegsAnim('legs');

        legs.anim.curAnim.curFrame = Math.floor(FlxMath.mod(curDecBeat, 2) / 2 * legs.animation.curAnim.numFrames);
        
	    if (boyfriend.isAnimationFinished() && boyfriend.hasAnimation('$name-loop'))
	    {
		    boyfriend.animation.curAnim.pause();
		    boyfriend.anim.curAnim.curFrame = legs.anim.curAnim.curFrame;
	    }

        if(!end) bfAnchorPoint[0] = legs.x = boyfriend.x;
	
	    boyfriend.y = (bfAnchorPoint[1] + legPosY[legs.anim.curAnim.curFrame]);
	    if(!end) legs.setPosition(bfAnchorPoint[0], bfAnchorPoint[1]);
    }

    if(boyfriend.curCharacter == 'bf-badtime-run')
    {
        var name:String = boyfriend.getAnimationName();
        
        if (!boyfriend.getAnimationName().contains('miss') && bfLegsBad.getAnimationName() == 'idle-miss') setBadLegsAnim('idle');

        bfLegsBad.anim.curAnim.curFrame = Math.floor(FlxMath.mod(curDecBeat, 2) / 2 * bfLegsBad.animation.curAnim.numFrames);
        
	    if (boyfriend.isAnimationFinished() && boyfriend.hasAnimation('$name-loop'))
	    {
		    boyfriend.animation.curAnim.pause();
		    boyfriend.anim.curAnim.curFrame = bfLegsBad.anim.curAnim.curFrame;
	    }

        if(!end) bfLegsBad.x = boyfriend.x - 115;
    }

    if(boyfriend.curCharacter == 'bf_demise')
    {
        if (boyfriend.animation.curAnim.name == 'idle' && singing)
        {
            arm.alpha = 1; 
            arm.animation.curAnim.curFrame = 0; 
            singing = false;
        }
        if(!end) bfAnchorPoint[0] = leg.x = arm.x = boyfriend.x;
	
	    boyfriend.y = (bfAnchorPoint[1]);
	    if(!end) leg.setPosition(bfAnchorPoint[0], bfAnchorPoint[1]);
        if(!end) arm.setPosition(bfAnchorPoint[0], bfAnchorPoint[1]);
    }
}

// This changes the legs from the normal version to the miss version and makes sure it starts on the same animation frame where it left off
function noteMiss(daNote:Note):Void
{
    if(boyfriend.curCharacter == 'bf-running')
    {
        setLegsAnim('legs');
	
        new FlxTimer().start(1 / 24, function() setLegsAnim('legs-miss'));
    }
}

function goodNoteHit()
{
    if(!game.opponentMode)
    {
        if(boyfriend.curCharacter == 'bf_demise' && !singing)
        {
            singing = true;
            arm.alpha = 0.0001;
        }
    }
}

function opponentNoteHit()
{
    if(game.opponentMode)
    {
        if(boyfriend.curCharacter == 'bf_demise' && !singing)
        {
            singing = true;
            arm.alpha = 0.0001;
        }
    }
}

function setLegsAnim(anim:String):Void
{
	var lastFrame:Int = legs.anim.curAnim.curFrame;
	legs.playAnim(anim, true);
	legs.anim.curAnim.curFrame = lastFrame;
}

function setBadLegsAnim(anim:String):Void
{
	var lastFrame:Int = bfLegsBad.anim.curAnim.curFrame;
	bfLegsBad.playAnim(anim, true);
	bfLegsBad.anim.curAnim.curFrame = lastFrame;
}

function setLegsAnimDemise(anim:String):Void
{
    leg.anim.curAnim.curFrame = 0;
    arm.anim.curAnim.curFrame = 0;
	leg.animation.play('exist', true);
	arm.animation.play('exist2', true);
}