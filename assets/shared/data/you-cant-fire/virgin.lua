function onCreate()
    makeLuaSprite('vin', 'vin', 0, 0)
    setObjectCamera('vin', 'camoverlayhud')
    setGraphicSize('vin', screenWidth, screenHeight)
    screenCenter("vin", 'xy')
    setProperty('vin.alpha', 1) 
    addLuaSprite('vin', true)
    
    makeLuaSprite('vg', 'RedVG');
    setObjectCamera('vg', 'hud');
    setGraphicSize('vg', screenWidth, screenHeight)
    setProperty('vg.alpha', 0)
    addLuaSprite('vg', true);

    makeAnimatedLuaSprite('creep', 'screenstatic', 0, 0);
	setObjectCamera('creep', 'other');
	setScrollFactor('creep', 0, 0);
	addAnimationByPrefix('creep', 'tssssssss', 'screenSTATIC', 40, true)
	setProperty('creep.visible', false)
    setGraphicSize('creep', screenWidth, screenHeight)
	addLuaSprite('creep',true)
end

function onUpdate()
    if getProperty('vg.alpha') == 1 then
        doTweenAlpha('dothetweenvg', 'vg', 0, 1, 'quadInOut');
    end
end

function onTweenCompleted(tag)
    if tag == 'dothetweenvg' then
        doTweenAlpha('dothetweenvgagain', 'vg', 1, 1, 'quadInOut');
    end
end

function onStepHit()
    if curStep == 1 then 
        setProperty('vg.visible', false);
        setProperty('vin.visible', true);
    end 
    if curStep == 78 then 
        setProperty('vg.visible', true);
        doTweenAlpha('fuckyou', 'vg', 1, 1, 'quadInOut');
    end 
    if curStep == 528 then
        setProperty('vg.visible', false);
        setProperty('vin.visible', false);
    end
    if curStep == 784 then
        setProperty('vg.visible', true);
        setProperty('vin.visible', true);
    end
end 

function onSongRestartPost()
    cancelTween('dothetweenvg')
    setProperty('vg.alpha', 0)
    etProperty('vg.visible', true);
    setProperty('vin.visible', true);
    setProperty('vin.alpha', 1)
end

function onSkipIntro()
    setProperty('vg.visible', true);
    setProperty('vin.visible', true);
    doTweenAlpha('fuckyou', 'vg', 1, 1, 'quadInOut');
end

function onEvent(event, value1, value2, strumTime)
    if event == 'You Cant Fire Events' then
        setProperty('creep.alpha', 1);
		setProperty('creep.visible', true)
		runTimer('stat', 0.4);
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'stat' then
		setProperty('creep.visible', false)
	end
end