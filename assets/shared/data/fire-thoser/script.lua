function onCreate()
    makeLuaSprite('blackFlash', nil, 0, 0)
    makeGraphic('blackFlash', screenWidth, screenHeight, '000000')
    setObjectCamera('blackFlash', 'camhud')
    addLuaSprite('blackFlash', false)
end

function onSongRestartPost()
    setProperty("blackFlash.alpha", 1)
    cancelTween('sex')
end

function onBeatHit()
    if curBeat == 16 then
        setProperty("blackFlash.alpha", 0)
        cameraFlash("game", "0xFFFFFFFF", 0.5, true)
    end

    if curBeat == 136 then
        doTweenAlpha("sex", "blackFlash", 1, 2)
    end

    if curBeat == 144 then
        doTweenAlpha("sex", "blackFlash", 0, 20)
    end

    if curBeat == 208 then
        cameraFlash("game", "0xFFFFFFFF", 0.5, true)
    end
end