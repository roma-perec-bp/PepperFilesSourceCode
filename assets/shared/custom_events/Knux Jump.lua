function onCreate()
	makeLuaSprite('knuxjump', 'Xenostage/P3_Knuckles', -100, -50);
	setScrollFactor('knuxjump', 0, 0);
	setObjectCamera('knuxjump', 'camprehud');
	scaleObject('knuxjump',1.15,1.15)
	setGraphicSize('knuxjump', screenWidth, screenHeight)
    screenCenter("knuxjump", 'xy')
	addLuaSprite('knuxjump',true)
	setProperty('knuxjump.visible', false)
	setBlendMode('knuxjump', 'difference')
end

function onCreatePost()
	setObjectOrder('knuxjump', getObjectOrder('creep') - 1)
end

function onEvent(name, value1)
    if name == "Knux Jump" then
		playSound('KnucklesScreamLOL', 0.06)
		setSoundVolume('KnucklesScreamLOL', 0.06)
		setProperty('knuxjump.visible', true)
		doTweenAlpha('byeKnux', 'knuxjump', 0, 2)
	end
end