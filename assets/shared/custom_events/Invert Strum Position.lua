function onEvent(name, value1, value2)
    if name == 'Invert Strum Position' then
        if not middlescroll then
            if getProperty('opponentMode') == false then
                setPropertyFromGroup('playerStrums', 0, 'x', defaultOpponentStrumX0 + 84)
                setPropertyFromGroup('playerStrums', 1, 'x', defaultOpponentStrumX1 + 84)
                setPropertyFromGroup('playerStrums', 2, 'x', defaultOpponentStrumX2 + 84)
                setPropertyFromGroup('playerStrums', 3, 'x', defaultOpponentStrumX3 + 84)
        
                setPropertyFromGroup('opponentStrums', 0, 'x', defaultPlayerStrumX0 + 84)
                setPropertyFromGroup('opponentStrums', 1, 'x', defaultPlayerStrumX1 + 84)
                setPropertyFromGroup('opponentStrums', 2, 'x', defaultPlayerStrumX2 + 84)
                setPropertyFromGroup('opponentStrums', 3, 'x', defaultPlayerStrumX3 + 84)
            else
                setPropertyFromGroup('playerStrums', 0, 'x', defaultOpponentStrumX0 - 84)
                setPropertyFromGroup('playerStrums', 1, 'x', defaultOpponentStrumX1 - 84)
                setPropertyFromGroup('playerStrums', 2, 'x', defaultOpponentStrumX2 - 84)
                setPropertyFromGroup('playerStrums', 3, 'x', defaultOpponentStrumX3 - 84)
        
                setPropertyFromGroup('opponentStrums', 0, 'x', defaultPlayerStrumX0 - 84)
                setPropertyFromGroup('opponentStrums', 1, 'x', defaultPlayerStrumX1 - 84)
                setPropertyFromGroup('opponentStrums', 2, 'x', defaultPlayerStrumX2 - 84)
                setPropertyFromGroup('opponentStrums', 3, 'x', defaultPlayerStrumX3 - 84)
            end
        end
        
		setProperty('boyfriend.x', -200)
        setProperty('dad.x', 800)
    end
end