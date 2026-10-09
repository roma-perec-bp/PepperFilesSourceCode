function onCreate()
	makeLuaSprite('tailjump', 'Xenostage/P3_Tails', -100, -50);
	setScrollFactor('tailjump', 0, 0);
	setObjectCamera('tailjump', 'camprehud');
	setGraphicSize('tailjump', screenWidth, screenHeight)
    screenCenter("tailjump", 'xy')
	addLuaSprite('tailjump',true)
	setProperty('tailjump.visible', false)
	setBlendMode('tailjump', 'difference')
end

function onCreatePost()
	setObjectOrder('tailjump', getObjectOrder('creep') - 1)
end

function onEvent(name, value1)
    if name == "Tails Jump" then
		playSound('TailsScreamLOL', 0.05)
		setSoundVolume('TailsScreamLOL', 0.05)
		setProperty('tailjump.visible', true)
		doTweenAlpha('byeT', 'tailjump', 0, 2)
	end
end