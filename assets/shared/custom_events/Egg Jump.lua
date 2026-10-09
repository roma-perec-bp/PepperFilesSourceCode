function onCreate()
	makeLuaSprite('eggjump', 'Xenostage/P3_Eggman', -115, -50);
	setScrollFactor('eggjump', 0, 0);
	setObjectCamera('eggjump', 'camprehud');
	scaleObject('eggjump',1.15,1.15)
	setGraphicSize('eggjump', screenWidth, screenHeight)
    screenCenter("eggjump", 'xy')
	addLuaSprite('eggjump',true)
	setProperty('eggjump.visible', false)
	setBlendMode('eggjump', 'difference')
end

function onCreatePost()
	setObjectOrder('eggjump', getObjectOrder('creep') - 1)
end

function onEvent(name, value1)
    if name == "Egg Jump" then
		playSound('EggmanScreamLOL', 0.03)
		setSoundVolume('EggmanScreamLOL', 0.03)
		setProperty('eggjump.visible', true)
		doTweenAlpha('byeEggnore', 'eggjump', 0, 2)
	end
end