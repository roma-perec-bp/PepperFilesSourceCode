function onCreate()
    makeLuaSprite('TopBar', nil, 0, -350)
	makeGraphic('TopBar', 1280, 350, '000000')
	setObjectCamera('TopBar', 'prehud')
	addLuaSprite('TopBar', true)

    makeLuaSprite('BottomBar', nil, 0, 720)
	makeGraphic('BottomBar', 1280, 350, '000000')
	setObjectCamera('BottomBar', 'prehud')
	addLuaSprite('BottomBar', true)

    TopY = getProperty('TopBar.y')
	BotY = getProperty('BottomBar.y')
end
function onEvent(n,v1,v2)
    if n == 'Black Bars' then
        doTweenY('TopBar', 'TopBar', TopY + v2 * 2, v1, 'quintOut')
		doTweenY('BottomBar', 'BottomBar', BotY - v2 * 2, v1, 'quintOut')
    end
end

function onSongRestartPost()
    cancelTween('TopBar')
	cancelTween('BottomBar')
	setProperty('topBar.y', -350)
	setProperty('BottomBar.y', 720)
end
