function onCreate()
    precacheImage('exe_redfade');
	makeLuaSprite('whoosh','Angel-Island/exe_redfade',0,0)
	setObjectCamera('whoosh', 'camnotes');
	setScrollFactor('whoosh', 0, 0)
	addLuaSprite('whoosh',true)
	setProperty('whoosh.alpha', 0)
end

function onEvent(name, value1, value2)
    if name == "Red Fade" then
		setProperty('whoosh.alpha', value1)
		doTweenAlpha('whoosh', 'whoosh', 0, value2, 'linear')
	end
end