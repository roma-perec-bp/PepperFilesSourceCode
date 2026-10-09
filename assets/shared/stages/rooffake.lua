local canDrain = false
local ending = false

function onCreate()
    makeLuaSprite('bf', 'roofexe/sky', -2600, -1500);
    setScrollFactor('bf', 0.75, 0.75)
    scaleObject('bf', 3, 3)
    updateHitbox('bf')
    addLuaSprite('bf', false);

    makeAnimatedLuaSprite('fire', 'roofexe/Starman_BG_Fire_Assets', -1200, 3000)
    addAnimationByPrefix('fire', 'fire', 'fire', 24, true)
    playAnim('fire', 'fire')
    scaleObject('fire', 3, 3)
    updateHitbox('fire')
    setProperty('fire.alpha', 0) 
    addLuaSprite('fire', false);

    makeLuaSprite('roofFa', 'roofexe/home', -2600, -1500);
    scaleObject('roofFa', 3, 3)
    updateHitbox('roofFa')
    addLuaSprite('roofFa', false);

    makeLuaSprite('roofReal', 'roofexe/hell', -2600, -1500);
    scaleObject('roofReal', 3, 3)
    updateHitbox('roofReal')
    addLuaSprite('roofReal', false);
    setProperty('roofReal.visible', false)

    makeLuaSprite('grass', 'roofexe/day', -550, -170);
    scaleObject('grass', 2, 2)
    updateHitbox('grass')
    addLuaSprite('grass', false);
    setProperty('grass.visible', false)

    makeLuaSprite('dad_shade', 'shade', defaultOpponentX - 70, defaultOpponentY + 500, 0);
    addLuaSprite('dad_shade', false)

    makeLuaSprite('bf_shade', 'shade', defaultBoyfriendX - 70, defaultBoyfriendY + 550, 0);
    addLuaSprite('bf_shade', false)

    setProperty('dad_shade.visible', false)
    setProperty('bf_shade.visible', false)
end

function onCreatePost()
    makeLuaSprite('dark', 'roofexe/darkness', 0, 0)
    setObjectCamera('dark', 'hud')
    setGraphicSize('dark', screenWidth * 2)
    screenCenter("dark", 'xy')
    setProperty('dark.y', getProperty('dark.y') - 150)
    setProperty('dark.x', getProperty('dark.x') + 124)
    setProperty('dark.alpha', 0) 
    addLuaSprite('dark', false)

    makeLuaSprite('vin', 'darkerVG', 0, 0)
    setObjectCamera('vin', 'camoverlayhud')
    setGraphicSize('vin', screenWidth, screenHeight)
    screenCenter("vin", 'xy')
    setProperty('vin.alpha', 0) 
    addLuaSprite('vin', true)

    makeLuaSprite('vg', 'roofexe/RedVG', 0, 0);
    scaleObject('vg', 1, 1);
    setObjectCamera('vg', 'camprehud');
    setGraphicSize('vg', screenWidth, screenHeight)
    screenCenter("vg", 'xy')
    setProperty('vg.alpha', 0) 
    addLuaSprite('vg', true)

    makeLuaSprite('smoke', 'roofexe/smoke', 0, 0);
    scaleObject('smoke', 1, 1);
    setObjectCamera('smoke', 'camprehud');
    setGraphicSize('smoke', screenWidth, screenHeight)
    screenCenter("smoke", 'xy')
    setProperty('smoke.alpha', 0) 
    addLuaSprite('smoke', true)

    makeLuaSprite('what', 'roofexe/funny', 0, 0);
    setObjectCamera('what', 'camoverlayhud');
    setGraphicSize('what', screenWidth)
    screenCenter('what', 'xy')
    setProperty('what.visible', false)
    addLuaSprite('what', true)
end

function onBeatHit()
    if curBeat == 300 then
        setProperty('grass.visible', true)
        setProperty('dad_shade.visible', true)
        setProperty('bf_shade.visible', true)
        setProperty('vin.alpha', 1)
        runHaxeCode([[
            game.updateTime = false;
        ]]);
        setTimeBarColors('000000', '000000', '000000')
        setProperty('timeTxt.text', 'WELCOME BACK')
        setProperty('timeTxt.size', 36)
        setTextFont('timeTxt', 'DS-DIGIB.ttf')
        setProperty('timeTxt.color', getColorFromHex('0xFF000000'))
        setProperty('timeTxt.y', getProperty('timeTxt.y') + 2)
        setTextBorder('timeTxt', 1, 'FF0000')
    end

    if curBeat == 315 then
        setHealth(0.6)
    end

    if curBeat == 414 then
        setProperty('what.visible', true)
    end

    if curBeat == 416 then
        setProperty('what.visible', false)
        setProperty('timeTxt.text', 'YOUR LIFE MAKES ME SICK')
    end

    if curBeat == 482 then
        setProperty('grass.visible', false)
        setProperty('bf.visible', false)
        setProperty('roofFa.visible', false)
        setProperty('roofReal.visible', true)
    end

    if curBeat == 485 then
        setProperty('timeTxt.text', 'IT\'S TOO LATE NOW')
        canDrain = true
        setProperty('dark.alpha', 1) 
    end

    if curBeat == 584 then
        doTweenAlpha('fireGoes', 'fire', 1, 10)
        doTweenAlpha('smoking', 'smoke', 1, 10)
        doTweenY('fireGoesUp', 'fire', -500, 10, 'sineOut')

        doTweenColor('dadGay', 'dad', 'ff0000', 10)
        doTweenColor('bfGay', 'boyfriend', 'ff0000', 10)
        doTweenColor('roofReaEXE', 'roofReal', 'ff0000', 10)

        tweenNumber(0, 0, 10, {onUpdate = 'updateHue'})
        tweenNumber(-66, 0, 10, {onUpdate = 'updateSat'})
        tweenNumber(-40, 0, 10, {onUpdate = 'updateBright'})
        tweenNumber(-12, 0, 10, {onUpdate = 'updateContrast'})
    end

    if curBeat == 585 then
        setProperty('dark.alpha', 0) 
        setProperty('timeTxt.text', 'DIE')
        cameraFlash('other', 'FF0000',1)
        setProperty('vg.alpha', 1) 
    end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if canDrain == true then
        if getHealth() >= 0.5 then addHealth(-0.015) end
    end
end

function onDestroy()
    if not ending then
        setPropertyFromClass('states.PlayState', 'SONG.song', songName) -- dont change this
    end
end

function onStepHit()
    if curStep == 2899 then
        setProperty('smoke.alpha', 0) 
        setProperty('vg.alpha', 0) 
        ending = true
    end
end

function tweenNumber(startValue, endValue, duration, options)
    options = callMethodFromClass('funkin.psychlua.LuaUtils', 'getLuaTween', {options})
    runHaxeCode([[
        var options = luaOptions;
        FlxTween.num(startValue, endValue, duration, {
            type: options.type,
            ease: options.ease,
            startDelay: options.startDelay,
            loopDelay: options.loopDelay,

            onUpdate: function(twn:FlxTween) {
                if (options.onUpdate != null) game.callOnLuas(options.onUpdate, [twn.value]);
            },
            onStart: function(twn:FlxTween) {
                if (options.onStart != null) game.callOnLuas(options.onStart, [twn.value]);
            },
            onComplete: function(twn:FlxTween) {
                if (options.onComplete != null) game.callOnLuas(options.onComplete, [twn.value]);
            }   
        });
    ]], {startValue = startValue, endValue = endValue, duration = duration, luaOptions = options})
end