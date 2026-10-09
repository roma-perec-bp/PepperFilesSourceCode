function onCreate()
	makeAnimatedLuaSprite('note_static','hitStatic',-100,-100)
	addAnimationByPrefix('note_static','static_anim','staticANIMATION',30,true)
	setScrollFactor('note_static', 0, 0);
	scaleObject('note_static', 1.25, 1.25);
	setObjectCamera('note_static', 'other')
	setProperty('note_static.alpha', 0.0001)
	addLuaSprite('note_static',true)

	precacheSound('hitStatic1')
end

function onSpawnNote()
	if getProperty('notes.members[0].noteType') == 'Static Note' then
    	setProperty("notes.members[0].rgbShader.enabled", false)
		setProperty("notes.members[0].missHealth", 0.2)
		callMethod('notes.members[0].reloadNote',{'STATICNOTE_assets'})

		if getProperty('notes.members[0].mustPress') == true and getProperty('opponentMode') == false then
			setProperty("notes.members[0].animSuffix", '-alt')
		end

		if getProperty('notes.members[0].mustPress') == false and getProperty('opponentMode') == true then
			setProperty("notes.members[0].animSuffix", '-alt')
		end
	end
end

function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'Static Note' then
		playSound('hitStatic1', 1)
		--playSound('ring', 1)
		setProperty('note_static.alpha', 1)
		runTimer('deletestatic', 0.5)
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'deletestatic' then
		setProperty('note_static.alpha', 0.0001)
	end
end