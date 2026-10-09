function onCreatePost()
    makeLuaSprite('blackFlash', nil, 0, 0)
    makeGraphic('blackFlash', screenWidth, screenHeight, '000000')
    setObjectCamera('blackFlash', 'camhud')
    addLuaSprite('blackFlash', false)
end