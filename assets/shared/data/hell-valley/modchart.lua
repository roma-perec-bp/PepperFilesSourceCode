local noteScale = 0.694

local Meow1 = 0
local Meow2 = 112
local Meow3 = 112 * 2
local Meow4 = 112 * 3

local cutout = 0
local ogCut = 0

function hideNotes(time)
	time = time or 0.5
	for i = 0, 7 do
		noteTweenY("noteStatusTwn" .. i, i, (defaultPlayerStrumY0 + (downscroll and 250 or -250)),
			time + (((time / 0.5) / 10) * i), "backIn")
	end
end

function showNotes(time)
	time = time or 0.5
	for i = 0, 7 do
		noteTweenY("noteStatusTwn" .. i, i, defaultPlayerStrumY0, time + (((time / 0.5) / 10) * i), "backOut")
	end
end

function onStepHit()
	if curStep == 1340 then
		hideNotes(1)
	end
	if curStep == 1420 then
		showNotes()
	end

	if curStep == 1640 then

        for i = 0, 3 do
            noteTweenAlpha("note"..i, i, 0, 1, "backOut")
        end

        if not middlescroll then
			noteTweenX('foxTween12', 0, 415 + Meow1 + cutout, 1, 'backOut');
            noteTweenX('foxTween22', 1, 415 + Meow2 + cutout, 1, 'backOut');
            noteTweenX('foxTween32', 2, 415 + Meow3 + cutout, 1, 'backOut');
            noteTweenX('foxTween42', 3, 415 + Meow4 + cutout, 1, 'backOut');
            noteTweenX('foxTween1', 4, 415 + Meow1 + cutout, 1, 'backOut');
            noteTweenX('foxTween2', 5, 415 + Meow2 + cutout, 1, 'backOut');
            noteTweenX('foxTween3', 6, 415 + Meow3 + cutout, 1, 'backOut');
            noteTweenX('foxTween4', 7, 415 + Meow4 + cutout, 1, 'backOut');
        end
    end
end

function onBeatHit()
	if curStep >= 1504 and curStep < 1635 then
		for i = 0, 7 do
			setNoteScale(i, "xy", 1.15 * noteScale)
			noteTweenScale("noteScaleTwn" .. i, i, "xy", noteScale, 0.3, "sineOut")
		end
	end
end

--made by KyoEnomoto (discord : kyo_loves_cats)
--modified by misty (and added sustain support :O **THANK YOU**)
-- noteScaleTween v.1.1
local scaleUpdates = false
function onCreate()
	addHaxeLibrary("Type")
	for i = 0, 7 do
		makeLuaSprite(i, '', 0, 0)
		scaleObject(i, noteScale, noteScale) -- default scale of notes is 0.7 ( actually for some reason it is 0.694... when i checked with debug, but...thats a pain in the ass, so no :D )
		--wait i didnt know that lol, lemme make it work with 0.694 without having it be a pain in the ass lol - flez
	end

	ogCut = getPropertyFromClass('funkin.menus.FullScreenScaleMode', 'gameCutoutSize.x')
	cutout = ogCut / 2
end

function onUpdatePost(elasped)
	if scaleUpdates then --updates the scale (optimization)
		updateScale(true)
	end
end

function onTimerCompleted(tag, loops, loopsLeft) --to turn off updating the scale (optimization [no touchy])
	if tag == 'stopUpdatingScale' then
		scaleUpdates = false
	end
end

--tag:string, note:0-7, scale:float, axis:string ('x', 'y', 'xy'), duration:float, ease:string
function noteTweenScale(tag, note, axis, scale, duration, ease)
	scaleUpdates = true
	if axis == 'x' or axis == 'X' then
		if note >= 0 and note <= 7 then
			doTweenX(tag .. note, note .. '.scale', scale, duration, ease)
		end
	elseif axis == 'y' or axis == 'Y' then
		if note >= 0 and note <= 7 then
			doTweenY(tag .. note, note .. '.scale', scale, duration, ease)
		end
	elseif axis == 'xy' or axis == 'XY' then
		if note >= 0 and note <= 7 then
			doTweenX(tag .. 'X' .. note, note .. '.scale', scale, duration, ease)
			doTweenY(tag .. 'Y' .. note, note .. '.scale', scale, duration, ease)
		end
	end
	runTimer('stopUpdatingScale', duration, 1)
end

--note:0-7, axis:string ('x', 'y', 'xy'), scale:float
function setNoteScale(note, axis, scale) -- works like setProperty() but to scale notes, use this so it enables the updateScale() function and actually scales up the notes
	scaleUpdates = true
	if axis == 'x' or axis == 'X' then
		if note >= 0 and note <= 7 then
			setProperty(note .. '.scale.x', scale)
		end
	elseif axis == 'y' or axis == 'Y' then
		if note >= 0 and note <= 7 then
			setProperty(note .. '.scale.y', scale)
		end
	elseif axis == 'xy' or axis == 'XY' then
		if note >= 0 and note <= 7 then
			setProperty(note .. '.scale.x', scale)
			setProperty(note .. '.scale.y', scale)
		end
	end
	runTimer('stopUpdatingScale', 0.01, 1)
end

function updateScale(scaleNotes) --no touchy, unless u wanna change some shit or mess around ( or break it entirely :D )
	if scaleNotes then
		for i = 0, 7 do
			setPropertyFromGroup('strumLineNotes', i, 'scale.x', getProperty(i .. '.scale.x'))
			setPropertyFromGroup('strumLineNotes', i, 'scale.y', getProperty(i .. '.scale.y'))
		end
		--i really dont wanna apply it to every fucking note
		--[[for nn = 0,getProperty('notes.length')-1 do
         mustHitNote = getPropertyFromGroup('notes', nn, 'mustPress')
         direction = getPropertyFromGroup('notes', nn, 'noteData')
         susss = getPropertyFromGroup('notes', nn, 'isSustainNote')
         if mustHitNote then
             if not susss then
                 for ii = 0,3 do
                     if direction == ii then
                         setPropertyFromGroup('notes', nn, 'scale.x', getProperty(4+ii..'.scale.x'))
                         setPropertyFromGroup('notes', nn, 'scale.y', getProperty(4+ii..'.scale.y'))
                     end
                     setPropertyFromGroup('grpNoteSplashes', ii, 'scale.x', (getPropertyFromGroup('playerStrums', ii, 'scale.x')+0.3))
                     setPropertyFromGroup('grpNoteSplashes', ii, 'scale.y', (getPropertyFromGroup('playerStrums', ii, 'scale.y')+0.3))
                 end
             else
               for ii = 0,3 do
                   if direction == ii then
                      setPropertyFromGroup('notes', nn, 'scale.x', getProperty(4+ii..'.scale.x'))
                   end
               end
             end
         else
             if not susss then
                 setPropertyFromGroup('notes', nn, 'scale.x', getProperty(direction..'.scale.x'))
                 setPropertyFromGroup('notes', nn, 'scale.y', getProperty(direction..'.scale.y'))
             else
                 setPropertyFromGroup('notes', nn, 'scale.x', getProperty(direction..'.scale.x'))
             end
         end
      end]]
	end
end
