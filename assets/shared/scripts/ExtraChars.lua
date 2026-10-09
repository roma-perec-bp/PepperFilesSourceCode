local iconsCreated = 2 
--[[
    Do not change this number and also do not create more than 1 icon for the same character 
    (except for the main characters {bf and dad})
    If you create on icon the tag is gonna iconP3 and so on
--]]

--[[
    Template usage
        createCharacter('extra','bf',0,0,true,false)
            Explanation of the Args:
                1. Tag of the new character
                2. Json name of the new character
                3,4. X and Y position of the new character
                5. Is player is gonna flip and detect the notes from the side (when is true is gonna like ur ally)
                6. Is in front of the main characters (if it's true is gonna be infront of the main characters)

        setNotes('extra','Note1',{true,true,'',''})
        setNotes('extra','Note2') 
            Explanation of the Args:
                1. Tag of the character 
                2. NoteType name
                3. Is an array but it works like this
                    Default args on case is '' or nil : {false,false,'',''}
                    3.1 If it's true is gonna be a no animation note 
                    (If it's true is not gonna play an animation boyfriend or dad characters when that note was hit.
                    If not is gonna work like a duet note)
                    3.2 If it's true is gonna be no miss animation note
                    (If it's true is not gonna play an animation boyfriend or dad characters when that note was missed.
                    If not is gonna work like a duet miss note)
                    3.3 Animation suffix is gonna make the character to play smth like singLEFT-alt or singLEFTmySuffix 
                    whenever the note was hit
                    3.4 Miss Animation suffix is gonna make the character to play smth like singLEFTmiss-alt or singLEFT-missmySuffix 
                    whenever the note was missed

        createIcon('gf',{0,0},false)
        createIcon('extra')
            Explanation of the Args:
                1. Tag of the character that is gonna be create the icon
                2. Is an array but is working like this
                    Default args on case is nil : {0,0,{false}}
                    2.1,2.2 X and Y position
                    Note: Is gonna be staying on that position unless both are empty strings or nil
                3. Is an ally icon or not (if it's an ally is gonna be following some properties of iconP1 or iconP2 depending the bool)
                4. Array about order
                    4.1 If it's true that let's u to use the the next one but if it's false is gonna be infront of the main icon 
                        Example: If it's an ally icon is gonna be infront of iconP1, if not is gonna be iconP2
                    4.2 If it's on true 4.1 is gonna be the number of order that icon

    NOTE: YOU CAN'T CREATE MORE THAN 1 ICON FOR THE SAME CHARACTER (except for the main characters {bf and dad})
    Template Usage with callScript and callOnLuas (on case u need to make it on a different script)

    callScript("scripts/ExtraChars", "createCharacter", {'extra','bf',0,0,true,false})
    callScript("scripts/ExtraChars", "setNotes", {'extra','Note1',{true,true,'',''}})
    callScript("scripts/ExtraChars", "setNotes",{'extra','Note2'})
    callScript("scripts/ExtraChars", "createIcon", {'gf'})
    callScript("scripts/ExtraChars", "createIcon", {'extra',{0,0},false,{false}})

    callOnLuas("createCharacter",{'extra','dad',0,0,false,false})
    callOnLuas("createCharacter",{'extra','boyfriend',0,0,false,true})    
    callOnLuas("setNotes",{'extra','Note1',nil})
    callOnLuas("createIcon",{'gf',nil,nil,nil})

]]--

--[[ 
    More examples of usage 
    createCharacter('sillybilly','pico',0,0,false,true)
    createCharacter('extra','bf',0,0,true,false)
    triggerEvent("Change Extra Character", 'extra', dadName)
    triggerEvent("Change Extra Character", 'extra', gfName)
    setNotes('extra','bleh') Makes it work the note bleh as duet note
    setNotes('extra','bleh',{true,true,'',''}) 
        Makes it work the note bleh as no animation note which means extra character is not gonna play any animation
        when the note was hit or missed
    setNotes('extra','bleh',{true,true,'mySuffix','myMissSuffix'})
        Mysuffix is gonna make the character to sing like anim-mySuffix whenever the note was hit or missed is gonna vary with myMissSuffix
    createIcon('extra') --Creates an icon for the extra character that follow the main character
    createIcon('gf',{0,0}) --Creates an icon for the gf character that is gonna be on position (0,0)
--]]
--Do not change this
local charactersInfo = {
    ['boyfriend'] = {},
    ['dad'] = {},
    ['gf'] = {},
}

function onCreate()
    runHaxeCode([[
        import funkin.psychlua.FunkinLua;
        FunkinLua.customFunctions.set('createCharacter', function(?tag:String,?json:String,?x:Float,?y:Float,?isPlayer:Bool,?inFront:Bool) 
        {
            parentLua.call('createCharacter', [tag,json,x,y,isPlayer,inFront]);
        }
        );
        FunkinLua.customFunctions.set('setNotes', function(?tag:String,?note:String,?options:Array<Dynamic>)
        {
            parentLua.call('setNotes',[tag,note,options]);
        }
        );
        FunkinLua.customFunctions.set('createIcon', function(?tag:String,?axe:Array<Float>,?isP:Bool,?order:Array<Dynamic>)
        {
            parentLua.call('createIcon', [tag,axe,isP,order]);
        }
        );
    ]])
end

function onCreatePost()
    for _,v in ipairs ({'Change Extra Character Alt Idle','Remove Extra Character','Change Extra Character','Change Icon Follow Setting','Change Icon Mult Scale','Change Icon OffsetX','Change Icon OffsetY','Change Icon Mult Alpha','Play Extra Character Animation'}) do
        if not checkFileExists("custom_events/"..v..'.txt') then
            if v == 'Change Extra Character' then
                saveFile("custom_events/"..v..'.txt', "V1 is the Extra Character Tag\nV2 is the Json name of the character")
            elseif v == 'Play Extra Character Animation' then
                saveFile("custom_events/"..v..'.txt', "V1 is the Extra Character Tag\nV2 is the animation name")
            elseif v == 'Change Icon Follow Setting' then
                saveFile("custom_events/"..v..'.txt', "V1 is the Extra Character Tag\nV2 is the property to change (is gonna normally do the opposite that it was doing)\nThe available properties are: active, position, visible, alpha, frame")
            elseif v == 'Remove Extra Character' then
                saveFile("custom_events/"..v..'.txt', "V1 is the Extra Character Tag")    
            elseif v == 'Change Extra Character Alt Idle' then
                saveFile("custom_events/"..v..'.txt', "V1 is the Extra Character Tag\nV2 is the suffix")
            else
                saveFile("custom_events/"..v..'.txt', "V1 is the Extra Character Tag\nV2 is the value")
            end
        end
    end
    for i = 0,getProperty('eventNotes.length') - 1 do
		if getPropertyFromGroup('eventNotes',i,'event') == 'Change Extra Character' then
			addCharacterToList(getProperty("eventNotes",i,'value2'))
		end
	end
end

function createCharacter(tag,json,x,y,isPlayer,inFront)
    if version >= '0.7' then
        createInstance(tag, 'funkin.game.objects.Character',{x,y,json, isPlayer})
        addInstance(tag,inFront)
    else
        runHaxeCode([[
            var ]]..tag..[[ = new Character(]]..(tonumber(x))..[[,]]..(tonumber(y))..[[,]]..(tostring(json))..[[,]]..(tostring(isPlayer))..[[);
            game.add(]]..tag..[[);
            setVar(']]..tag..[[', ]]..tag..[[);
        ]])
    end
    if not inFront then
        setObjectOrder(tag, 0)
    end
    charactersInfo[tag] = {x,y,nil,{isPlayer,inFront},{}}
end

function setNotes(char,type,options)
    if not checkFileExists("custom_notetypes/"..type..'.lua') and not checkFileExists("custom_notetypes/"..type..'.txt') and type ~= nil and type ~= '' then
        if version >= '0.7' then
            saveFile("custom_notetypes/"..type..'.txt', "")
        else
            saveFile("custom_notetypes/"..type..'.lua', "")
        end
    end
    if options == nil then
        options = {false,false,'',''}
    end
    charactersInfo[char][5][type] = options
    for _,v in ipairs({'unspawnNotes','notes'}) do
        for i = 0,getProperty(v..".length") do
            setPropertyFromGroup(v, i, 'noAnimation', true)
            setPropertyFromGroup(v, i, 'noMissAnimation', true)
        end
    end
end

function createIcon(char,axe,isP,order)
    iconsCreated = iconsCreated + 1
    local iconTag = 'iconP'..iconsCreated
    if isP == nil then
        isP = getProperty(char..".isPlayer") 
    end
    if order == nil then
        order = {false}
    end
    if version >= '0.7' then
        createInstance(iconTag, 'funkin.game.objects.HealthIcon',{getProperty(char..'.healthIcon'), isP})
        addInstance(iconTag)
    else
        runHaxeCode([[
            var ]]..iconTag..[[ = new HealthIcon(]]..tostring(char)..[[.healthIcon,]]..tostring(isP)..[[);
            game.add(]]..iconTag..[[);
            setVar(']]..iconTag..[[',]]..iconTag..[[);
        ]])
    end
    if axe == '' or axe == nil then
        axe = {'',''}
    end
    setProperty(iconTag..'.flipX',getProperty('iconP'..(isP and 1 or 2)..'.flipX'))
    setProperty(iconTag..'.x', axe[1])
    setProperty(iconTag..'.y', axe[2])
    if version == '1.0' then
        setProperty(iconTag..'.camera', instanceArg('camHUD'),false,true)
    else
        setObjectCamera(iconTag,'hud')
    end
    local x,y,followPos = 40,40,false
    if (axe[1] == nil or axe[1] == '') and (axe[2] == nil or axe[2] == '') then
        followPos = true
    end
    if not downscroll then
        y = -y
    end
    if not isP then
        x = -x
    end
    charactersInfo[char][6] = {iconTag, active = true,
        follow = {frame = true,position = followPos,alpha = true,scale = true,visible = true, offsetX = x, offsetY = y,multAlpha = 1,multScale = 0.8}
    }
    if version >= '0.7.2' then
        if order[1] then
            callMethod('uiGroup.insert', {order[2],instanceArg(iconTag)})
        else
            callMethod('uiGroup.insert', {callMethod('uiGroup.members.indexOf', {instanceArg('iconP'..(isP and 1 or 2))}) + (order[1] and 0 or 1),instanceArg(iconTag)})
        end
    else
        if order[1] then
            setObjectOrder(iconTag,order[2])
        else
            setObjectOrder(iconTag, getObjectOrder('iconP'..(isP and 1 or 2)) + 2)
        end
    end
end

function iconsPositions(iconInfo)
    if iconInfo.follow.position then
        iconTarget = getProperty(iconInfo[1]..".isPlayer") and 'iconP1' or 'iconP2'
        setProperty(iconInfo[1]..".x", getProperty(iconTarget..".x") + iconInfo.follow.offsetX)
        setProperty(iconInfo[1]..".y", getProperty(iconTarget..".y") + iconInfo.follow.offsetY)
    end
end

function iconsScales(iconInfo)
    if iconInfo.follow.scale then
        iconTarget = getProperty(iconInfo[1]..".isPlayer") and 'iconP1' or 'iconP2'
        setProperty(iconInfo[1]..'.origin.x',getProperty(iconTarget..'.origin.x'))
        setProperty(iconInfo[1]..'.origin.y',getProperty(iconTarget..'.origin.y'))
        setProperty(iconInfo[1]..".scale.x", getProperty(iconTarget..".scale.x") * iconInfo.follow.multScale)
        setProperty(iconInfo[1]..".scale.y", getProperty(iconTarget..".scale.y") * iconInfo.follow.multScale)
    end
end

function iconsProperties(iconInfo)
    iconTarget = getProperty(iconInfo[1]..".isPlayer") and 'iconP1' or 'iconP2'
    if iconInfo.follow.alpha then
        setProperty(iconInfo[1]..".alpha", getProperty(iconTarget..".alpha") * iconInfo.follow.multAlpha)
    end
    if iconInfo.follow.visible then
        setProperty(iconInfo[1]..".visible", getProperty(iconTarget..".visible"))
    end
    if iconInfo.follow.frame then
        if getProperty(iconInfo[1]..".animation.curAnim.numFrames") == getProperty(iconTarget..".animation.curAnim.numFrames") and (getProperty("iconsAnimations") ~= nil and not getProperty('iconsAnimations')) then
            setProperty(iconInfo[1]..".animation.curAnim.curFrame", getProperty(iconTarget..".animation.curAnim.curFrame"))
        else
            if getProperty(iconInfo[1]..".animation.curAnim.numFrames") == 3 then
                if getProperty("healthBar.percent") > 80 then
                    setProperty(iconInfo[1]..".animation.curAnim.curFrame", iconTarget == 'iconP1' and 2 or 1)
                elseif getProperty("healthBar.percent") < 20 then
                    setProperty(iconInfo[1]..".animation.curAnim.curFrame", iconTarget == 'iconP1' and 1 or 2)
                else
                    setProperty(iconInfo[1]..".animation.curAnim.curFrame", 0)
                end
            elseif getProperty(iconInfo[1]..".animation.curAnim.numFrames") == 2 then
                if getProperty("healthBar.percent") > 80 then
                    setProperty(iconInfo[1]..".animation.curAnim.curFrame", iconTarget == 'iconP1' and 0 or 1)
                elseif getProperty("healthBar.percent") < 20 then
                    setProperty(iconInfo[1]..".animation.curAnim.curFrame", iconTarget == 'iconP1' and 1 or 0)
                end
            end
        end
    end
end

controlShit = {'left','down','up','right'} 
--I did the array cuz as far as i remember it differs on 0.6.3 and 0.7 to above the keysArray
function onUpdatePost(e)
    for charName,charData in pairs(charactersInfo) do
        if (charData[6] ~= nil) then
            if charData[6].active then
                iconsPositions(charData[6])
                iconsScales(charData[6])
                iconsProperties(charData[6])
            end
        end
    end
    if version < '0.7' then
		for i,v in pairs (charactersInfo) do
            if i ~= 'dad' and i ~= 'boyfriend' and i ~= 'gf' then
			    if stringStartsWith(getProperty(i..".animation.curAnim.name"), "sing") and getProperty(i..".isPlayer") then
				    setProperty(i..'.holdTimer', getProperty(i..".holdTimer") + e)
			    end
            end
		end
	end
    if not botPlay then
        for _,v in ipairs (controlShit) do
            if keyPressed(v) then return end
        end
    end
    characterDance(nil)
end

function onBeatHit()
    characterDance(curBeat)
end

function onCountdownTick(c)
    characterDance(c)    
end

function goodNoteHit(i,d,t,s)
    if getProperty('opponentMode') == false then
        handleHit(i,d,t,s,false,true)
    else
        handleHit(i,d,t,s,false,false)
    end
end

function opponentNoteHit(i,d,t,s)
    handleHit(i,d,t,s,false,false)
end

function noteMiss(i,d,t,s)
    handleHit(i,d,t,s,true,true)
end

function onEvent(n,v1,v2)
    if n == 'Change Extra Character' then
        removeInst(v1)
        local charProps = charactersInfo[v1]
        saveNote,saveInfo = charProps[5],charProps[6]
        createCharacter(v1,v2,charProps[1],charProps[2],charProps[4][1],charProps[4][2],nil)
        charactersInfo[v1][6],charactersInfo[v1][5] = saveInfo,saveNote
        if charProps[6] ~= nil then
            if version >= '0.7' then
                callMethod(charProps[6][1]..'.changeIcon',{getProperty(v1..".healthIcon")})
            else
                runHaxeCode([[
                    game.getLuaObject(']]..charProps[6][1]..[[').changeIcon(]]..v1..[[.healthIcon);
                ]])
            end
        end
    elseif n == 'Change Character' then
        for i,v in ipairs({'boyfriend','dad','gf'}) do 
            local charProps = charactersInfo[v]
            saveInfo = charProps[6]
            if saveInfo ~= nil then
                if version >= '0.7' then
                    callMethod(charProps[6][1]..'.changeIcon',{getProperty(v..".healthIcon")})
                else
                    runHaxeCode([[
                        game.getLuaObject(']]..charProps[6][1]..[[').changeIcon(]]..v..[[.healthIcon);
                    ]])
                end
                charactersInfo[v][6] = saveInfo
            end
        end
    --[[
        XDDDDDDDDD THIS IS SO BULLSHIT
        I DIDN'T KNOW HOW TO DO THIS BETTER
        I'M SORRY
        Also i recommend to use triggerEvent("EventName", v1) 
        --V1 is the character
        --V2 is the property to change (is gonna normally do the opposite that it was doing)
        Example
        triggerEvent("Change Icon Follow Setting", 'extra', 'active')
    --]]
    elseif n == 'Change Icon Follow Setting' then
        if v2:lower() == 'active' then 
            charactersInfo[v1][6].active = not charactersInfo[v1][6].active
        elseif v2:lower() == 'position' then
            charactersInfo[v1][6].follow.position = not charactersInfo[v1][6].follow.position
        elseif v2:lower() == 'visible' then
            charactersInfo[v1][6].follow.visible = not charactersInfo[v1][6].follow.visible
        elseif v2:lower() == 'alpha' then
            charactersInfo[v1][6].follow.alpha = not charactersInfo[v1][6].follow.alpha
        elseif v2:lower() == 'frame' then
            charactersInfo[v1][6].follow.frame = not charactersInfo[v1][6].follow.frame
        end
    --[[ 
        On this apart
        --V1 is the character
        --V2 is the value
        example 
        triggerEvent("EventName", 'Change Icon Mult Scale', 'extra', '0.5')
    ]]--
    elseif n == 'Change Icon Mult Scale' then
        charactersInfo[v1][6].follow.multScale = v2
    elseif n == 'Change Icon OffsetX' then
        charactersInfo[v1][6].follow.offsetX = v2
    elseif n == 'Change Icon OffsetY' then
        charactersInfo[v1][6].follow.offsetY = v2
    elseif n == 'Change Icon Mult Alpha' then
        charactersInfo[v1][6].follow.multAlpha = v2
	elseif n == 'Play Extra Character Animation' then
        if version >= '0.7' then
            playAnim(v1, v2,true)
            setProperty(v1..".specialAnim", true)
        else 
		    runHaxeCode([[
			    getVar("]]..v1..[[").playAnim("]]..v2..[[",true);
			    getVar("]]..v1..[[").specialAnim = true;
		    ]])
        end
    elseif n == 'Remove Extra Character' then
        removeInst(v1)
        removeInst(charactersInfo[v1][6][1])
        table.remove(charactersInfo,v1)
    elseif n == 'Change Extra Character Alt Idle' then
        setProperty(v1..'.idleSuffix', v2)
	end
end

function characterDance(arg)
    for charName,data in pairs (charactersInfo) do
        if charName ~= 'dad' and charName ~= 'boyfriend' and charName ~= 'gf' then
            if arg == nil then
                if getProperty(charName..'.isPlayer') and getProperty(charName..'.holdTimer') > stepCrochet * (0.0011 / getPropertyFromClass('flixel.FlxG', 'sound.music.pitch')) * getProperty(charName..'.singDuration') and stringStartsWith(getProperty(charName..'.animation.name'), 'sing') and not stringEndsWith(getProperty(charName..'.animation.name'), 'miss') then
                    if version >= '0.7' then
                        callMethod(charName..".dance",{''})
                    else
                        runHaxeCode([[
                            getVar(']]..charName..[[').dance();
                        ]]) 
                    end
                end
            else
                if arg % getProperty(charName..".danceEveryNumBeats") == 0 and not stringStartsWith(getProperty(charName..'.animation.name'), "sing") and not getProperty(charName..".stunned") then
                    if version >= '0.7' then
                        callMethod(charName..".dance",{''})
                    else
                        runHaxeCode([[
                            getVar(']]..charName..[[').dance();
                        ]])
                    end
                end
            end
        end 
    end
end

function handleHit(i,d,t,s,m,tr)
    for charName,data in pairs (charactersInfo) do
        if charName ~= 'dad' and charName ~= 'boyfriend' and charName ~= 'gf' then
            if getProperty(charName..".isPlayer") == tr and not getProperty(charName..".stunned") and not getProperty(charName..".specialAnim") then
                for noteType,noteProps in pairs (data[5]) do
                    if t == noteType then
                        animName = version >= '0.7' and getProperty('singAnimations')[d + 1] or 'game.singAnimations['.. d ..']'
                        if m and getProperty(charName..".hasMissAnimations") then
                            animName = animName..'+ "miss"'
                            if noteProps[4] ~= '' then
                                animName = animName.. '+'..noteProps[4]
                            end
                        elseif noteProps[3] ~= '' then
                            animName = animName..'+'..noteProps[3]
                        end
                        if version >= '0.7' then
                            playAnim(charName,animName:gsub('+',''),true)
                            setProperty(charName..".holdTimer", 0)
                        else
                            runHaxeCode([[
                                getVar("]]..v..[[").playAnim(]]..animName..[[,true);
                                getVar("]]..v..[[").holdTimer = 0;
                            ]])
                        end
                    end
                end
            end
        end
    end
end

function removeInst(obj)
    if version >= '0.7' then
        callMethod(obj..'.kill', {''})
        callMethod('variables.remove', {obj})
        callMethod('remove', {instanceArg(obj)})
        callMethod(obj..'.destroy', {''})
    else
        runHaxeCode([[
		    if (!game.variables.exists("]]..arg..[[")) {
			    return;
		    }
		    getVar("]]..arg..[[").kill();
		    game.variables.remove(getVar("]]..arg..[["));
		    variables.remove(getVar("]]..arg..[["));
		    getVar("]]..arg..[[").destroy();
	    ]])
    end
end