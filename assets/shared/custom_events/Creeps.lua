function onCreate()
	precacheSound('simplejumpsound');
	makeAnimatedLuaSprite('creep', 'screenstatic', 0, 0);
	setObjectCamera('creep', 'camprehud');
	setScrollFactor('creep', 0, 0);
	setGraphicSize('creep', screenWidth, screenHeight)
    screenCenter("creep", 'xy')
	addAnimationByPrefix('creep', 'tssssssss', 'screenSTATIC', 40, true)
	setProperty('creep.visible', false)
	addLuaSprite('creep',true)
end

function onEvent(name, value1, value2)
    if name == "Creeps" then
		setProperty('creep.alpha', 0.36);
		playSound('simplejumpsound', 0.2)
		setProperty('creep.visible', true)
		doTweenAlpha('byeStat', 'creep', 0, 2)
	end
end