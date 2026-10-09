function onCreate()
    makeLuaSprite('blackscreenSlow','',0,0)
    setObjectCamera('blackscreenSlow','other')
    makeGraphic('blackscreenSlow',screenWidth,screenHeight,'000000')
    setProperty('blackscreenSlow.alpha',0.001)
    addLuaSprite('blackscreenSlow',false)

    makeLuaSprite('RedScreenSlow','',0,0)
    setObjectCamera('RedScreenSlow','other')
    makeGraphic('RedScreenSlow',screenWidth,screenHeight,'FF0000')
    setBlendMode('RedScreenSlow','add')
    setProperty('RedScreenSlow.alpha',0.001)
    addLuaSprite('RedScreenSlow',false)

    makeLuaSprite('vin', 'vin', 0, 0)
    setObjectCamera('vin', 'camoverlayhud')
    setGraphicSize('vin', screenWidth, screenHeight)
    screenCenter("vin", 'xy')
    setProperty('vin.alpha', 1) 
    addLuaSprite('vin', true)
end

function onStepHit()
    if curStep == 384 then
        setProperty('blackscreenSlow.alpha',1)

        if getProperty('opponentMode') == false then
            changeNoteskin('noteSkins/NOTE_assets-exe')
        end
    end
    if curStep == 400 then
        setProperty('RedScreenSlow.alpha',1)
        doTweenAlpha('byeRedSlow','RedScreenSlow',0,0.5,'linear')
        doTweenAlpha('byeBlackSlow','blackscreenSlow',0,0.5,'linear')
        setHealth(1)
    end
end

function changeNoteskin(texture)
    for i=0, 4 do
        setPropertyFromGroup('opponentStrums', i, 'texture', texture)
    end

    for i = 0, getProperty('notes.length')-1 do
        if not getProperty('notes.members['..i..'].noteType') == 'Static Note' then return end

        if not getProperty('notes.members['..i..'].mustPress') then
            setProperty('notes.members['..i..'].texture', texture)
        end
    end

    for i = 0, getProperty('unspawnNotes.length')-1 do
        if not getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Static Note' then return end

        if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
            setPropertyFromGroup('unspawnNotes', i, 'texture', texture)
        end
    end
end

function onSongRestartPost()
    if getProperty('opponentMode') == false then
        changeNoteskin('noteSkins/NOTE_assets-fake')
    end
end