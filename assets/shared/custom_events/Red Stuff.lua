function onCreate()
    precacheImage('RedVG');
	makeLuaSprite('sussyred','RedVG',0,0)
	setObjectCamera('sussyred', 'camnotes');
	setScrollFactor('sussyred', 0, 0)
	setProperty('sussyred.alpha', 0);
	addLuaSprite('sussyred',true)
end

function onEvent(name, value1, value2)
    if name == "Red Stuff" then
		setProperty('sussyred.alpha', value2);
		doTweenAlpha('sussyredAlpha', 'sussyred', value1, 1, 'linear')
	end
end