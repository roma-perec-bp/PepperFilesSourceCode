colors = {'31A2FD', '31FD8C', 'F794F7', 'F96D63', 'FBA633'}

local curLightEvent = 0

function onCreatePost()

	--black bg
	makeLuaSprite('blammedLightsBlack', '', getPropertyFromClass('flixel.FlxG', 'width') * -0.5, getPropertyFromClass('flixel.FlxG', 'height') * -0.5)
	makeGraphic('blammedLightsBlack', getPropertyFromClass('flixel.FlxG', 'width') * 2, getPropertyFromClass('flixel.FlxG', 'height') * 2, '000000')
	
	setScrollFactor('blammedLightsBlack', 0)
	setProperty('blammedLightsBlack.scale.x', 5)
	setProperty('blammedLightsBlack.scale.y', 5)

	if getProperty('gf.visible') == true then
		setObjectOrder('blammedLightsBlack', getObjectOrder('gfGroup'))
	elseif getProperty('dad.visible') == true then
		setObjectOrder('blammedLightsBlack', getObjectOrder('dadGroup'))
	else
		setObjectOrder('blammedLightsBlack', getObjectOrder('boyfriendGroup'))
	end

	addLuaSprite('blammedLightsBlack', false)
	setProperty('blammedLightsBlack.alpha', 0)

end

function onEvent(name, value1)

	if name == 'Blammed Lights' then

		local lightId = tonumber(value1)
		if lightId == nil then lightId = 0 end

		if lightId > 0 then

			if lightId > #colors then
				lightId = getRandomInt(1, #colors, tostring(curLightEvent))
			end

			curLightEvent = lightId

			if getProperty('blammedLightsBlack.alpha') == 0 then

				doTweenAlpha('blammedLightsBlackTween', 'blammedLightsBlack', 1, 1, 'quadInOut')
				
				doTweenColor('boyfriendColorTween', 'boyfriendGroup', colors[lightId], 1, 'quadInOut')
				doTweenColor('dadColorTween', 'dadGroup', colors[lightId], 1, 'quadInOut')
				doTweenColor('gfColorTween', 'gfGroup', colors[lightId], 1, 'quadInOut')

			else

				setProperty('blammedLightsBlack.alpha', 1)
				
				doTweenColor('boyfriendColorTween', 'boyfriendGroup', colors[lightId], 0.00000001, 'quadInOut')
				doTweenColor('dadColorTween', 'dadGroup', colors[lightId], 0.00000001, 'quadInOut')
				doTweenColor('gfColorTween', 'gfGroup', colors[lightId], 0.00000001, 'quadInOut')

			end

			doTweenAlpha('byeBysh', 'bushes', 0, 1, 'quadInOut')
			doTweenAlpha('byeOver', 'overlay1', 0, 1, 'quadInOut')
			doTweenAlpha('byeOver2', 'overlay2', 0, 1, 'quadInOut')
		else

			doTweenAlpha('blammedLightsBlackTween', 'blammedLightsBlack', 0, 1, 'quadInOut')

			doTweenAlpha('byeBysh', 'bushes', 1, 1, 'quadInOut')

			doTweenAlpha('byeOver', 'overlay1', 1, 1, 'quadInOut')
			doTweenAlpha('byeOver2', 'overlay2', 1, 1, 'quadInOut')
			
			doTweenColor('boyfriendColorTween', 'boyfriendGroup', '0xffffffff', 1, 'quadInOut')
			doTweenColor('dadColorTween', 'dadGroup', '0xffffffff', 1, 'quadInOut')
			doTweenColor('gfColorTween', 'gfGroup', '0xffffffff', 1, 'quadInOut')

			curLightEvent = 0

		end

	end
end

function onSongRestartPost()
	cancelTween('byeBysh')

	cancelTween('blammedLightsBlackTween')

	cancelTween('boyfriendColorTween')
	cancelTween('dadColorTween')
	cancelTween('gfColorTween')

	doTweenAlpha('byeBysh', 'bushes', 1, 0.00000001, 'quadInOut')

	doTweenAlpha('byeOver', 'overlay1', 1, 0.00000001, 'quadInOut')
	doTweenAlpha('byeOver2', 'overlay2', 1, 000000001, 'quadInOut')

	doTweenAlpha('blammedLightsBlackTween', 'blammedLightsBlack', 0, 0.00000001, 'quadInOut')

	doTweenColor('boyfriendColorTween', 'boyfriendGroup', '0xffffffff', 0.00000001, 'quadInOut')
	doTweenColor('dadColorTween', 'dadGroup', '0xffffffff', 0.00000001, 'quadInOut')
	doTweenColor('gfColorTween', 'gfGroup', '0xffffffff', 0.00000001, 'quadInOut')
end