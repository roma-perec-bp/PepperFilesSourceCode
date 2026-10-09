local lyrictimer = 0
function onCreate()
	setScrollFactor('Lyricalandhysterical', 0, 0);
	makeLuaText('Lyricalandhysterical', 'based', 1000, 140, 600)
	setObjectCamera('Lyricalandhysterical', 'camnotes')
	setTextFont('Lyricalandhysterical', 'sonic-hud-font.ttf')
	setTextSize('Lyricalandhysterical', 45.0)
	setTextBorder('Lyricalandhysterical', 2.25, '000000')
	setTextAlignment('Lyricalandhysterical', 'center')
	addLuaText('Lyricalandhysterical')
end

function onCreatePost()
	setProperty('Lyricalandhysterical.antialiasing', false)
	setProperty('Lyricalandhysterical.alpha', 0)
end

function onEvent(name, value1, value2)
	if name == "Lyrics" then
		if songName == 'Prey' then
			if value2 == "3.7" or value2 == "8.9" then 
				setTextColor('Lyricalandhysterical', 'FF0000')
			else
				setTextColor('Lyricalandhysterical', '4053B3')
			end
		end
		lyrictimer = value2-0.3
		setTextString('Lyricalandhysterical', ''..value1)
		doTweenAlpha('bienvenidos', 'Lyricalandhysterical', 1, 0.15, 'linear')
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'ElHuevo' then
		doTweenAlpha('adios', 'Lyricalandhysterical', 0, 0.15, 'linear')
	end
end

function onTweenCompleted(tag)
	if tag == 'bienvenidos' then
		runTimer('ElHuevo', lyrictimer)
	end
end