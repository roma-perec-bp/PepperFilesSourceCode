
-- MESSY ASS FUCKING SCRIPT INCOMING !!!!!!!!

function onCreate()
    makeLuaSprite('vin', 'vin', 0, 0)
    setObjectCamera('vin', 'camOther')
    setGraphicSize('vin', screenWidth, screenHeight)
    screenCenter("vin", 'xy')
    setProperty('vin.alpha', 1) 
    addLuaSprite('vin', true)
end

function onStepHit()
	if curStep == 1056 then
	setProperty('boyfriendGroup.visible', false);
	setProperty('dadGroup.visible', false);
	setProperty('gf.alpha', 1);
	setProperty('dark.visible', false)
	setProperty('stage1.alpha', 1)
	end 
	if curStep == 1312 then
	setProperty('boyfriendGroup.visible', true);
	setProperty('dadGroup.visible', true);
	setProperty('gf.alpha', 0.001);
	setProperty('dark.visible', true)
	setProperty('stage1.alpha', 0.00001)
	end 	
	if curStep == 1572 then
	triggerEvent('Screen Shake', '2, 0.012', '2, 0.008')
	setProperty('overlay.alpha', 0.42)
	setProperty('dark.alpha', 0.3)
	setProperty('tree_destroyed.alpha', 1)
	setProperty('tree.alpha', 0.0001)
	end 
	if curStep == 2336 then
	setProperty('boyfriendGroup.visible', false);
	setProperty('dadGroup.visible', false);
	setProperty('guy.alpha', 1);
	setProperty('overlay.visible', false)
	setProperty('dark.visible', false)
	setProperty('stage2.alpha', 1)
	end 
	if curStep == 2456 then
		playAnim('guy','look',true)
	end
	if curStep == 2464 then
	setProperty('guy.alpha', 0.0001);
	setProperty('boyfriendGroup.visible', true);
	setProperty('dadGroup.visible', true);
	setProperty('overlay.visible', true)
	setProperty('dark.visible', true)
	setProperty('stage2.alpha', 0.0001)
	end 

	if curStep == 2744 then
	triggerEvent('Screen Shake', '2, 0.012', '2, 0.008')
	setProperty('overlay.alpha', 0.00001)
	setProperty('dark.alpha', 0.8)
	setProperty('tree_destroyed.alpha', 0.00001)
	setProperty('tree.alpha', 1)
	end
	if curStep > 2464 and curStep < 2520 then
	triggerEvent('Screen Shake', '1, 0.012', '1, 0.008')
	end
end

function onSongRestartPost()
	setProperty('overlay.alpha', 0.00001)
	setProperty('dark.alpha', 0.8)
	setProperty('tree_destroyed.alpha', 0.00001)
	setProperty('tree.alpha', 1)

	setProperty('gf.alpha', 0.0001);
	setProperty('boyfriendGroup.visible', true);
	setProperty('dadGroup.visible', true);
	setProperty('overlay.visible', true)
	setProperty('dark.visible', true)
	setProperty('stage2.alpha', 0.0001)
	setProperty('stage1.alpha', 0.0001)
	setProperty('guy.alpha', 0.0001);
end