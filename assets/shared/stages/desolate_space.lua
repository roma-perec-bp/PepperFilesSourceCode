local xx = 100;
local yy = 575;
local xx2 = 850;
local yy2 = 620;
local ofs = 25;
local ofs2 = 25;
local followchars = true;
local del = 0;
local del2 = 0;

function onCreate()
	-- with addLuaSprite, the farther up it is on the script is how far back it is in layers
	luaDebugMode = true

	initLuaShader("dropShadow-tt")

	makeAnimatedLuaSprite('p3_Glitch', 'Xenostage/p3_glitch', -700, 0);
	addAnimationByPrefix('p3_Glitch','batic','Glitch static', 24, true)
	makeAnimatedLuaSprite('p3_Stats', 'Xenostage/P3_SonicStat', -600, 0);
	addAnimationByPrefix('p3_Stats','busk','TitleMenuSSBG instance 1',24,true)
	makeAnimatedLuaSprite('batic1', 'Xenostage/P3_Stat', 0, 0);
	addAnimationByPrefix('batic1', 'lanlubber', 'Phase3Static instance 1', 36, false);
	makeLuaSprite('p3_floor', 'Xenostage/p3_Grass', -700, -100)
	makeLuaSprite('p3_trs', 'Xenostage/p3_Trees2', -700, 0)
	makeLuaSprite('p3_tree', 'Xenostage/p3_Trees', -700, 0)
	makeLuaSprite('nonos', '', 0, 0);
	makeGraphic('nonos', screenWidth, screenHeight, '000000');
	scaleObject('nonos', 6.0, 6.0);
	screenCenter('nonos')
	scaleObject('p3_Stats', 5.5, 5.5);
	scaleObject('batic1', 5.0, 5.0);
	scaleObject('p3_Glitch', 1.01, 1.01);
	setObjectCamera('nonos', 'camprehud');
	setObjectCamera('batic1', 'camprehud');
	setScrollFactor('p3_Glitch', 0.9, 0.9);
	setScrollFactor('p3_tree', 1.05, 1.0);
	setScrollFactor('p3_trs', 1.05, 1.0);
	setScrollFactor('batic1', 0, 0);

	makeAnimatedLuaSprite('eyes', 'Xenostage/eye', -700, 0);
	addAnimationByPrefix('eyes','eye','eye', 24, true)
	playAnim('eyes', 'eye')
	screenCenter('eyes')
	setGraphicSize('eyes', screenWidth)
	setProperty('eyes.alpha', 0.0001)
	addLuaSprite('eyes')
	setObjectCamera('eyes', 'prehud')

	addLuaSprite('p3_Glitch', false)
	addLuaSprite('p3_Stats', false)
	addLuaSprite('p3_trs', false)
	addLuaSprite('p3_tree', false)
	addLuaSprite('p3_floor', false)
	addLuaSprite('batic1',true)
	addLuaSprite('nonos', true);
	setProperty('batic1.visible', false)
	setProperty('p3_Stats.visible', false)
end

function onCreatePost(id, noteData, noteType)
	setObjectOrder('batic1', getObjectOrder('creep') - 2)
	setObjectOrder('nonos', getObjectOrder('creep') + 1)

	precacheImage('Xenostage/P3_SonicStat')
	precacheImage('Xenostage/p3_glitch')

	makeLuaSprite('vin', 'darkerVG', 0, 0)
    setObjectCamera('vin', 'camoverlayhud')
    setGraphicSize('vin', screenWidth, screenHeight)
    screenCenter("vin", 'xy')
    setProperty('vin.alpha', 1) 
    addLuaSprite('vin', true)

	if lowQuality then
		setSpriteShader("dad", "dropShadow-tt")
		setSpriteShader("boyfriend", "dropShadow-tt")

		setShaderFloat("boyfriend", "_disx", -7)
		setShaderFloat("boyfriend", "_disy", 17)
		setShaderFloat("boyfriend", "_alpha", 0.6)
		setShaderBool("boyfriend", "inner", true)
		setShaderBool("boyfriend", "inverted", true)
		setShaderBool("boyfriend", "knockout", false)

		setShaderFloat("dad", "_disx", -7)
		setShaderFloat("dad", "_disy", 17)
		setShaderFloat("dad", "_alpha", 0.6)
		setShaderBool("dad", "inner", true)
		setShaderBool("dad", "inverted", true)
		setShaderBool("dad", "knockout", false)
	end
end

function onSongStart()
	setProperty('batic1.alpha', 0.66);
	doTweenAlpha('graphicAlpha', 'nonos', 0, 0.4, 'linear');
	runTimer('savespace',5)

	runHaxeCode([[
		game.updateTime = false;
	]]);
	setTimeBarColors('000000', '000000', '000000')
	setProperty('timeTxt.text', 'IT\'S TIME TO DIE')
end

function onStartCountdown()
	setProperty('batic1.alpha', 0.66);
	runTimer('weeb1',2.1)
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'weeb1' then
		doTweenAlpha('graphicAlpha', 'nonos', 0, 0.4, 'linear');
		runTimer('savespace',5)
	end
	if tag == 'statfin' then
		setProperty('batic1.visible', false)
	end
	if tag == 'savespace' then
		removeLuaSprite('nonos', true)
	end
end

function onStepHit()
	if curStep == 4 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.16)
		playAnim('batic1', 'lanlubber', true);
	end
	if curStep == 1024 then
		if getProperty('opponentMode') == false then
			startTween("healthTween", "game", {health = 0.00001}, stepCrochet * 15.6 / 1000, {ease = "expoIn"})
		end
	end
	if curStep == 1029 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.15)
		playAnim('batic1', 'lanlubber', false);
	end
	if curStep == 1039 then
		removeSpriteShader('dad')
		removeSpriteShader('boyfriend')
	end
	if curStep == 1040 then
		setProperty('p3_Stats.visible', true)
		setProperty('timeTxt.text', 'HERE I COME')
		setHealth(1)
	end
	if curStep == 1094 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.15)
		playAnim('batic1', 'lanlubber', false);
	end
	if curStep == 1118 then
		doTweenAlpha('eye_appear', 'eyes', 0.6, 5)
	end
	if curStep == 1160 then
		doTweenAlpha('nah_fuck', 'eyes', 0.0001, 1)
	end
	if curStep == 1221 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.15)
		playAnim('batic1', 'lanlubber', false);
	end
	if curStep == 1285 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.15)
		playAnim('batic1', 'lanlubber', false);
	end
	if curStep == 1296 then
		setProperty('p3_Stats.visible', false)
		setHealth(1)
		setProperty('timeTxt.text', 'TOO LATE TO RUN')

		if lowQuality then
			setSpriteShader("dad", "dropShadow-tt")
			setSpriteShader("boyfriend", "dropShadow-tt")

			setShaderFloat("boyfriend", "_disx", -7)
			setShaderFloat("boyfriend", "_disy", 17)
			setShaderFloat("boyfriend", "_alpha", 0.6)
			setShaderBool("boyfriend", "inner", true)
			setShaderBool("boyfriend", "inverted", true)
			setShaderBool("boyfriend", "knockout", false)

			setShaderFloat("dad", "_disx", -7)
			setShaderFloat("dad", "_disy", 17)
			setShaderFloat("dad", "_alpha", 0.6)
			setShaderBool("dad", "inner", true)
			setShaderBool("dad", "inverted", true)
			setShaderBool("dad", "knockout", false)
		end
	end
	if curStep == 2304 then
		if getProperty('opponentMode') == false then
			startTween("healthTween", "game", {health = 0.00001}, stepCrochet * 15.6 / 1000, {ease = "quadIn"})
		end
	end
	if curStep == 2308 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.15)
		playAnim('batic1', 'lanlubber', false);
	end
	if curStep == 2319 then
		removeSpriteShader('dad')
		removeSpriteShader('boyfriend')
	end
	if curStep == 2320 then
		setProperty('p3_Stats.visible', true)
		setProperty('timeTxt.text', 'STILL ALIVE YEAH?')
		setHealth(1)
	end
	if curStep == 2820 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.15)
		playAnim('batic1', 'lanlubber', false);
	end
	if curStep == 2824 then
		setHealth(1)
		setProperty('p3_Stats.visible', false)
		setProperty('timeTxt.text', 'I HATE YOU')

		if lowQuality then
			setSpriteShader("dad", "dropShadow-tt")
			setSpriteShader("boyfriend", "dropShadow-tt")

			setShaderFloat("boyfriend", "_disx", -7)
			setShaderFloat("boyfriend", "_disy", 17)
			setShaderFloat("boyfriend", "_alpha", 0.6)
			setShaderBool("boyfriend", "inner", true)
			setShaderBool("boyfriend", "inverted", true)
			setShaderBool("boyfriend", "knockout", false)

			setShaderFloat("dad", "_disx", -7)
			setShaderFloat("dad", "_disy", 17)
			setShaderFloat("dad", "_alpha", 0.6)
			setShaderBool("dad", "inner", true)
			setShaderBool("dad", "inverted", true)
			setShaderBool("dad", "knockout", false)
		end
	end
	if curStep == 3200 then
		if getProperty('opponentMode') == false then
			startTween("healthTween", "game", {health = 0.00001}, stepCrochet * 15.6 / 1000, {ease = "expoIn"})
		end
	end
	if curStep == 3204 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.15)
		playAnim('batic1', 'lanlubber', false);
	end
	if curStep == 3216 then
		startTween("healthTween", "game", {health = 1}, stepCrochet * 15.9 / 1000, {ease = "expoOut"})
	end
	if curStep == 3456 then
		if getProperty('opponentMode') == false then
			startTween("healthTween", "game", {health = 0.00001}, stepCrochet * 15.6 / 1000, {ease = "expoIn"})
		end
	end
	if curStep == 3460 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.15)
		playAnim('batic1', 'lanlubber', false);
	end
	if curStep == 3472 then
		startTween("healthTween", "game", {health = 1}, stepCrochet * 15.6 / 1000, {ease = "expoOut"})
	end
	if curStep == 3704 then
		if getProperty('opponentMode') == false then
			startTween("healthTween", "game", {health = 0.6}, stepCrochet * 15.6 / 1000, {ease = "expoIn"})
		end
	end
	if curStep == 4096 then
		if getProperty('opponentMode') == false then
			startTween("healthTween", "game", {health = 0.00001}, stepCrochet * 15.6 / 1000, {ease = "expoIn"})
		end
	end
	if curStep == 4100 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.15)
		playAnim('batic1', 'lanlubber', false);
	end
	if curStep == 4111 then
		removeSpriteShader('dad')
		removeSpriteShader('boyfriend')
	end
	if curStep == 4112 then
		setProperty('p3_Stats.visible', true)
		setHealth(1)
		setProperty('timeTxt.text', 'ACCEPT IT, THIS IS IT')
	end
	if curStep == 5125 then
		setProperty('batic1.visible', true)
		runTimer('statfin',1.15)
		playAnim('batic1', 'lanlubber', false);
	end
end

function onEvent(name, value1, value2)
    if name == 'Invert Strum Position' then
        xx = 900
		xx2 = 560
    end
    if name == 'Reset Strum Position' then
        xx = 500
		xx2 = 850
    end
end