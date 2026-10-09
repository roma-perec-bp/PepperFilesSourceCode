local canDrain = false

local Meow1 = 0
local Meow2 = 112
local Meow3 = 112 * 2
local Meow4 = 112 * 3

local cutout = 0
local ogCut = 0

function onCreate()
   luaDebugMode = true
    ogCut = getPropertyFromClass('funkin.menus.FullScreenScaleMode', 'gameCutoutSize.x')
    cutout = ogCut / 2

    makeAnimatedLuaSprite('bf', 'end/hitStatic', -2600, -1500);
    addAnimationByPrefix('bf', 'bg', 'staticANIMATION', 24, true)
    playAnim('bf', 'bg', true)
    setScrollFactor('bf', 0, 0)
    scaleObject('bf', 6, 6)
    updateHitbox('bf')
    addLuaSprite('bf', false);
    setProperty('bf.visible', false)
    setProperty('bf.antialiasing', false)

    makeFlxAnimateSprite('lyric_state', 500, -1140, 'end/LYRIC_SEQUENCE', 'bf_mix')
    addAnimationByFrameLabel('lyric_state', 'intro', 'intro', 24, false)
    addAnimationByFrameLabel('lyric_state', 'lyrics', 'lyrics', 24, false)
    addAnimationByFrameLabel('lyric_state', 'second', 'second', 24, false)
    addAnimationByFrameLabel('lyric_state', 'laugh', 'laugh', 24, true)
    --playAnim('lyric_state', 'intro', true)
    setProperty('lyric_state.alpha', 0.0001)
    addLuaSprite('lyric_state', false);

    makeFlxAnimateSprite('crowd', -330, 650, 'end/dance_crowd', 'bf_mix') --250
    addAnimationBySymbol('crowd', 'dance', 'dance_crowd', 24, false)
    --playAnim('crowd', 'dance', true)
    addLuaSprite('crowd', false);

    makeAnimatedLuaSprite('hud_crowd', 'end/hud_bopper')
    addAnimationByPrefix('hud_crowd', 'dance', 'boppers', 24, false)
    addLuaSprite('hud_crowd', false);
    setObjectCamera('hud_crowd', 'camvid')
    screenCenter('hud_crowd', 'x')
    setProperty('hud_crowd.y', screenHeight)

    makeLuaSprite('roofFa', 'end/home', -2600, -1500);
    scaleObject('roofFa', 3, 3)
    updateHitbox('roofFa')
    addLuaSprite('roofFa', false);

    makeLuaSprite('death', 'end/home_dead', -2600, -1500);
    scaleObject('death', 3, 3)
    updateHitbox('death')
    addLuaSprite('death', false);
    setProperty('death.visible', false)

    makeLuaSprite('grass', 'end/day', -550, -170);
    scaleObject('grass', 2, 2)
    updateHitbox('grass')
    addLuaSprite('grass', false);
    setProperty('grass.visible', false)

    makeLuaSprite('hell', 'end/sky', 0.2, 0.2);
    scaleObject('hell', 4, 4)
    screenCenter('hell', 'xy')
    setScrollFactor('hell', 0, 0)
    addLuaSprite('hell', false);
    setProperty('hell.visible', false)

    makeLuaSprite('pied', 'end/shit', defaultBoyfriendX - 50, defaultBoyfriendY + 600);
    addLuaSprite('pied', false);
    setProperty('pied.visible', false)

    makeLuaSprite('pied2', 'end/shit',  defaultOpponentX - 225, defaultOpponentY);
    addLuaSprite('pied2', false);
    scaleObject('pied2', 1.5, 1.5)
    setProperty('pied2.visible', false)

    createCharacter('perbg1','perecexe',100,200,false,false)
    createCharacter('perbg2','perecexe',400,150,false,false)
    createCharacter('perbg3','perecexe',800,100,false,false)
    createCharacter('perbg4','perecexe',1400,100,true,false)
    createCharacter('perbg5','perecexe',1800,150,true,false)
    createCharacter('perbg6','perecexe',2400,200,true,false)

    setProperty('perbg1.visible', false)
    setProperty('perbg2.visible', false)
    setProperty('perbg3.visible', false)
    setProperty('perbg4.visible', false)
    setProperty('perbg5.visible', false)
    setProperty('perbg6.visible', false)

    createCharacter('per1','perecexe',600,400,false,false)
    setNotes('per1','perNoteLuigi',{true,true,'',''}) 
    createCharacter('per2','perecexe',100,400,false,false)
    setNotes('per2','perNoteWario',{true,true,'',''}) 
    createCharacter('per3','perecexe',350,600,false,false)
    setNotes('per3','perNoteYoshi',{true,true,'',''}) 

    setNotes('per1','perTogether',{true,true,'',''}) 
    setNotes('per2','perTogether',{true,true,'',''}) 
    setNotes('per3','perTogether',{true,true,'',''}) 

    setProperty('per1.visible', false)
    setProperty('per2.visible', false)
    setProperty('per3.visible', false)
end

function onSongStart()
    runHaxeCode([[
		game.updateTime = false;
	]]);
	setTimeBarColors('000000', '000000')
	setProperty('timeTxt.text', 'THE END')
end

function onCreatePost()
   makeLuaSprite('vin', 'darkerVG', 0, 0)
    setObjectCamera('vin', 'camoverlayhud')
    setGraphicSize('vin', screenWidth, screenHeight)
    screenCenter("vin", 'xy')
    setProperty('vin.alpha', 1) 
    addLuaSprite('vin', true)

    makeAnimatedLuaSprite('light', 'end/Act_4_FINALE_Lightingmcqueen', 0, 0)
    addAnimationByPrefix('light', 'light', 'line', 24, true)
    playAnim('light', 'light', true)
    screenCenter('light', 'xy')
    setProperty('light.alpha', 0) 
    setProperty('light.x', getProperty('light.x') + 200)
    setObjectCamera("light", 'camprehud')
    addLuaSprite('light', false);
    setObjectOrder('light', 25)

    makeLuaSprite('freddy', 'end/overlay', 0 ,0);
    setObjectCamera('freddy', 'camNotes')
    screenCenter('freddy', 'xy')
    setBlendMode('freddy', 'overlay')
    setProperty('freddy.alpha', 0) 
    addLuaSprite('freddy', true);
end

function onBeatHit()
    if curBeat % 2 == 0 then
        playAnim('crowd', 'dance', true)
        playAnim('hud_crowd', 'dance', true)
    end

    if curBeat == 72 then
        setProperty('bf.visible', true)
        cameraFlash('camGame', 'ff0000', 0.6, true)
    end

    if curBeat == 200 then
        doTweenAlpha('bgbye', 'bf', 0, 1)
    end

    if curBeat == 232 or curBeat == 236 or curBeat == 240 or curBeat == 244 or curBeat == 248 or curBeat == 252 or curBeat == 256 or curBeat == 260 then
        setProperty('bf.alpha', 1)
        doTweenAlpha('bgbye', 'bf', 0, 0.6)
    end

    if curBeat == 268 then
        setProperty('grass.visible', true)
    end
    if curBeat == 330 then
        cameraFlash('camGame', 'ff0000', 1, true)
    end

    if curBeat == 332 then
        cameraFlash('camGame', 'ff0000', 0.6, true)
        setProperty('perbg1.visible', true)
        setProperty('perbg2.visible', true)
        setProperty('perbg3.visible', true)
        setProperty('perbg4.visible', true)
        setProperty('perbg5.visible', true)
        setProperty('perbg6.visible', true)
    end

    if curBeat == 396 then
        cameraFlash('camGame', 'ff0000', 0.6, true)
        setProperty('per1.visible', true)
        setProperty('dad.visible', false)
    end

    if curBeat == 412 then
        setProperty('per2.visible', true)
    end

    if curBeat == 428 then
        setProperty('per3.visible', true)
    end

    if curBeat == 472 then
        cameraFlash('camGame', 'ff0000', 1, true)
    end

    if curBeat == 568 then
        setProperty('perbg1.visible', false)
        setProperty('perbg2.visible', false)
        setProperty('perbg3.visible', false)
        setProperty('perbg4.visible', false)
        setProperty('perbg5.visible', false)
        setProperty('perbg6.visible', false)

        setProperty('per1.visible', false)
        setProperty('per2.visible', false)
        setProperty('per3.visible', false)

        setProperty('dad.visible', true)

        setProperty('grass.visible', false)
        setProperty('roofFa.visible', false)
        setProperty('death.visible', true)

        --setCharacterX('dad', -200)
         setCharacterY('dad', 340)
     end

     if curBeat == 728 then
         playAnim('lyric_state', 'intro', true)
         setProperty('lyric_state.alpha', 1)
     end

      if curBeat == 744 then
         playAnim('lyric_state', 'lyrics', true)
     end

     if curBeat == 806 then
        doTweenY('hanup', 'crowd', 250, 10, 'quadInOut')
        doTweenY('hudup', 'hud_crowd', screenHeight - 400, 10, 'quadInOut')
     end

     if curBeat == 808 then
        playAnim('lyric_state', 'second', true)
     end

     if curBeat == 868 then
        doTweenAlpha('crowd_death', 'crowd', 0, 1)
        doTweenAlpha('hud_crowd_death', 'hud_crowd', 0, 1)
     end

     if curBeat == 872 then
        playAnim('lyric_state', 'laugh', true)
     end

     if curBeat == 876 then
         setProperty('lyric_state.alpha', 0)
        cameraFlash('camHUD', 'FFFFFF', 2)
     end

     if curBeat == 887 then
        setCharacterX('dad', defaultOpponentX)
        setCharacterY('dad', defaultOpponentY - 400)

        setProperty('pied.visible', true)
        setProperty('pied2.visible', true)
        setProperty('hell.visible', true)

        setProperty('boyfriend.color', 0xFF0000)
     end

     if curBeat == 905 then
        setProperty('boyfriend.color', 0xFF0000)
     end

     if curBeat == 1004 then
        doTweenAlpha('uhoh', 'freddy', 1, 1, 'expoOut')
     end

     if curBeat == 1068 then
        doTweenAlpha('uhoh', 'freddy', 0, 6, 'expoOut')
     end

     if curBeat == 1136 then
        setProperty('pied.visible', false)
        setProperty('pied2.visible', false)

        for i = 0, 3 do
            noteTweenAlpha("note"..i, i, 0, 1, "backOut")
        end

        if not middlescroll then
            noteTweenX('foxTween1', 4, 415 + Meow1 + cutout, 1, 'backOut');
            noteTweenX('foxTween2', 5, 415 + Meow2 + cutout, 1, 'backOut');
            noteTweenX('foxTween3', 6, 415 + Meow3 + cutout, 1, 'backOut');
            noteTweenX('foxTween4', 7, 415 + Meow4 + cutout, 1, 'backOut');
        end
     end

     if curBeat == 1200 then
        setObjectCamera('dadGroup', 'camvid')
        setObjectCamera('boyfriendGroup', 'camvid')
        setCharacterX('dad', defaultOpponentX - 200)
        setCharacterY('dad', defaultOpponentY - 100)
        setCharacterX('bf', defaultOpponentX + 500)
        if boyfriendName == 'bf_ultrafinale3' then
            setCharacterY('bf', defaultBoyfriendY - 300)
        else
            setCharacterY('bf', defaultBoyfriendY - 460)
        end

        setProperty('boyfriend.color', 0xFF0000)
        setProperty('light.alpha', 1) 
     end

     if curBeat == 1260 then
        if getProperty('opponentMode') == false then
            startTween("healthTween", "game", {health = 0.00001}, stepCrochet * 16 / 1000, {ease = "expoIn"})
        end
     end
end