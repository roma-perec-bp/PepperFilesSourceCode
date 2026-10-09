local canDrain = false
local glitch = false
local glitchNoteShit = 6
local bfGlitch = false

set = false
power = 0.0
chromo = 0.0
initLuaShader('vignetteGlitch')

function onCreate()
    makeLuaSprite('blackFlash', nil, 0, 0)
    makeGraphic('blackFlash', screenWidth, screenHeight, '000000')
    setObjectCamera('blackFlash', 'camhud')
    addLuaSprite('blackFlash', false)
    setProperty("blackFlash.alpha", 0)

    makeLuaSprite('vin', 'vin', 0, 0)
    setGraphicSize("vin", screenWidth, screenHeight)
    screenCenter("vin", 'xy')
    setObjectCamera('vin', 'camoverlayhud')
    addLuaSprite('vin', true)
    setProperty('vin.visible', false)
end

function onSongRestart()
    setProperty('gfGroup.visible', true)
    setShaderFloat('gf', 'time', 0)
	setShaderFloat('gf', 'prob', 0)
	setShaderFloat('gf', 'vignetteIntensity', 0)
	setShaderFloat('gf', 'glitchScale', 0)
    removeSpriteShader('gf')
end

function onSongRestartPost()
    setProperty('vin.visible', false)
    glitch = false
    canDrain = false
    bfGlitch = false
    glitchNoteShit = 6
    setProperty("blackFlash.alpha", 0)

    for i = 0,3 do
        noteTweenX("blyaDad"..i, i, _G["curOpponentStrumX"..i], 0.1, "quadOut")
        noteTweenY("pizdecDad"..i, i, _G["curOpponentStrumY"..i], 0.1, "quadOut")
        noteTweenX("blyaDVf"..i, i+4, _G["curPlayerStrumX"..i], 0.1, "quadOut")
        noteTweenY("pizdecDadBg"..i, i+4, _G["curPlayerStrumY"..i], 0.1, "quadOut")
    end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if canDrain == true then
        if getHealth() >= 0.5 then addHealth(-0.015) end
    end
end

function onStepHit()
    if canDrain then
	    randomizeShader()
    end
end

function randomizeShader()
	if getRandomBool(25) then
		setShaderFloat('gf', 'time', math.random(0.8, 1))
		setShaderFloat('gf', 'prob', math.random(0.5, 0.7))
		setShaderFloat('gf', 'vignetteIntensity', math.random(1, 1.5))
	else
		setShaderFloat('gf', 'time', math.random(0.8, 1))
		setShaderFloat('gf', 'prob', math.random(0.2, 1))
		setShaderFloat('gf', 'vignetteIntensity', math.random(1, 3))
		setShaderFloat('gf', 'glitchScale', math.random(0.2, 0.5))
	end
end

function onUpdate(elapsed)
    if glitch then
        funni(glitchNoteShit)
    end
end

function onBeatHit()
    if curBeat == 48 then
        cameraFlash("game", "0xFFFFFFFF", 0.5, true)
    end

    if curBeat == 528 then
        cameraFlash("game", "0xFFFFFFFF", 0.5, true)
    end

    if curBeat == 592 then
        cameraFlash("game", "0xFFFFFFFF", 0.5, true)
        setSpriteShader('gf', 'vignetteGlitch')
	    setShaderFloat('gf', 'glitchScale', 0.4)
        setProperty('vin.visible', true)
        canDrain = true

        glitch = true
    end

    if curBeat == 628 then
        glitchNoteShit = 16
        bfGlitch = true
    end

    if curBeat == 687 then
        canDrain = false
        setShaderFloat('gf', 'time', 0)
	    setShaderFloat('gf', 'prob', 0)
	    setShaderFloat('gf', 'vignetteIntensity', 0)
	    setShaderFloat('gf', 'glitchScale', 0)
        removeSpriteShader('gf')
        setProperty('gfGroup.visible', false)
        glitch = false
        bfGlitch = false
        runHaxeCode([[
            for (strum in game.opponentStrums) strum.shader = null;
        ]])
    end

    if curBeat == 704 then
        setProperty("blackFlash.alpha", 1)
    end

end

function funni(intense)
    for i = 0,3 do
        setPropertyFromGroup('opponentStrums', i, 'x',  _G["curOpponentStrumX"..i] + getRandomFloat(-intense, intense))

        setPropertyFromGroup('opponentStrums', i, 'y', _G["curOpponentStrumY"..i] + getRandomFloat(-intense, intense))

        noteTweenX("blyaDad"..i, i, _G["curOpponentStrumX"..i], 0.1, "quadOut")
        noteTweenY("pizdecDad"..i, i, _G["curOpponentStrumY"..i], 0.1, "quadOut")
    end

    if bfGlitch == true then
        for i = 0,3 do
            setPropertyFromGroup('playerStrums', i, 'x',  _G["curPlayerStrumX"..i] + getRandomFloat(-6, 6))
    
            setPropertyFromGroup('playerStrums', i, 'y', _G["curPlayerStrumY"..i] + getRandomFloat(-6, 6))

            noteTweenX("blyaDVf"..i, i+4, _G["curPlayerStrumX"..i], 0.1, "quadOut")
            noteTweenY("pizdecDadBg"..i, i+4, _G["curPlayerStrumY"..i], 0.1, "quadOut")
        end
    end
end