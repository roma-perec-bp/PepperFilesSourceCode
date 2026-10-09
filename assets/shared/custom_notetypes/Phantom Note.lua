function onSpawnNote()
	if getProperty('notes.members[0].noteType') == 'Phantom Note' then
    	setProperty("notes.members[0].rgbShader.enabled", false)
		setProperty("notes.members[0].missHealth", 0)
		setProperty("notes.members[0].offsetX", -20)
		setProperty("notes.members[0].hitCausesMiss", true)
		callMethod('notes.members[0].reloadNote',{'PhantomNote'})
		setProperty("notes.members[0].ignoreNote", true)
		setProperty("notes.members[0].lowPriority", true)
	end
end

local healthDrain = 0;
local TSH = 0;
local PHits = 0;
function noteMiss(id, noteData, noteType)
	if noteType == 'Phantom Note' then
		healthDrain = healthDrain + 0.6;
		TSH = 0
		PHits = PHits + 1
	end
end

function onStepHit(elapsed)
	--i forgor how work
	TSH = TSH + 1
	if healthDrain > 0 then
		healthDrain = healthDrain - 0.2 * TSH/1000;
		setProperty('health', getProperty('health') - (0.1 * PHits/50));
		if healthDrain < 0 then
			healthDrain = 0;
		end
	end
end

function onSongRestartPost()
    healthDrain = 0
	TSH = 0
	PHits = 0
end
