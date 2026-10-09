function onStepHit()
    if curStep == 1888 then
        setPropertyFromGroup('strumLineNotes', 0, 'y', _G['defaultOpponentStrumY0'] - 35)
        setPropertyFromGroup('strumLineNotes', 4, 'y', _G['defaultPlayerStrumY0'] - 35)
    end

    if curStep == 1890 then
        setPropertyFromGroup('strumLineNotes', 0, 'y', _G['defaultOpponentStrumY0'])
        setPropertyFromGroup('strumLineNotes', 4, 'y', _G['defaultPlayerStrumY0'])

        setPropertyFromGroup('strumLineNotes', 1, 'y', _G['defaultOpponentStrumY1'] - 35)
        setPropertyFromGroup('strumLineNotes', 5, 'y', _G['defaultPlayerStrumY1'] - 35)
    end

    if curStep == 1892 then
        setPropertyFromGroup('strumLineNotes', 1, 'y', _G['defaultOpponentStrumY1'])
        setPropertyFromGroup('strumLineNotes', 5, 'y', _G['defaultPlayerStrumY1'])

        setPropertyFromGroup('strumLineNotes', 2, 'y', _G['defaultOpponentStrumY2'] - 35)
        setPropertyFromGroup('strumLineNotes', 6, 'y', _G['defaultPlayerStrumY2'] - 35)
    end

    if curStep == 1894 then
        setPropertyFromGroup('strumLineNotes', 2, 'y', _G['defaultOpponentStrumY2'])
        setPropertyFromGroup('strumLineNotes', 6, 'y', _G['defaultPlayerStrumY2'])

        setPropertyFromGroup('strumLineNotes', 3, 'y', _G['defaultOpponentStrumY3'] - 35)
        setPropertyFromGroup('strumLineNotes', 7, 'y', _G['defaultPlayerStrumY3'] - 35)
    end

    if curStep == 1896 then
        setPropertyFromGroup('strumLineNotes', 0, 'y', _G['defaultOpponentStrumY0'] - 35)
        setPropertyFromGroup('strumLineNotes', 4, 'y', _G['defaultPlayerStrumY0'] - 35)
        setPropertyFromGroup('strumLineNotes', 2, 'y', _G['defaultOpponentStrumY2'] - 35)
        setPropertyFromGroup('strumLineNotes', 6, 'y', _G['defaultPlayerStrumY2'] - 35)
    end

    if curStep == 1898 then
        setPropertyFromGroup('strumLineNotes', 0, 'y', _G['defaultOpponentStrumY0'])
        setPropertyFromGroup('strumLineNotes', 4, 'y', _G['defaultPlayerStrumY0'])
        setPropertyFromGroup('strumLineNotes', 2, 'y', _G['defaultOpponentStrumY2'])
        setPropertyFromGroup('strumLineNotes', 6, 'y', _G['defaultPlayerStrumY2'])

        setPropertyFromGroup('strumLineNotes', 1, 'y', _G['defaultOpponentStrumY1'] - 35)
        setPropertyFromGroup('strumLineNotes', 5, 'y', _G['defaultPlayerStrumY1'] - 35)
        setPropertyFromGroup('strumLineNotes', 3, 'y', _G['defaultOpponentStrumY3'] - 35)
        setPropertyFromGroup('strumLineNotes', 7, 'y', _G['defaultPlayerStrumY3'] - 35)
    end

    if curStep == 1899 then
        setPropertyFromGroup('strumLineNotes', 0, 'y', _G['defaultOpponentStrumY0'])
        setPropertyFromGroup('strumLineNotes', 4, 'y', _G['defaultPlayerStrumY0'])

        setPropertyFromGroup('strumLineNotes', 1, 'y', _G['defaultOpponentStrumY1'])
        setPropertyFromGroup('strumLineNotes', 5, 'y', _G['defaultPlayerStrumY1'])

        setPropertyFromGroup('strumLineNotes', 2, 'y', _G['defaultOpponentStrumY2'])
        setPropertyFromGroup('strumLineNotes', 6, 'y', _G['defaultPlayerStrumY2'])

        setPropertyFromGroup('strumLineNotes', 3, 'y', _G['defaultOpponentStrumY2'])
        setPropertyFromGroup('strumLineNotes', 7, 'y', _G['defaultPlayerStrumY2'])

        setPropertyFromGroup('strumLineNotes', 0, 'x', _G['defaultOpponentStrumX0'] - 35)
        setPropertyFromGroup('strumLineNotes', 4, 'x', _G['defaultPlayerStrumX0'] - 35)

        setPropertyFromGroup('strumLineNotes', 1, 'X', _G['defaultOpponentStrumX1'])
        setPropertyFromGroup('strumLineNotes', 5, 'X', _G['defaultPlayerStrumX1'])

        setPropertyFromGroup('strumLineNotes', 2, 'X', _G['defaultOpponentStrumX2'])
        setPropertyFromGroup('strumLineNotes', 6, 'X', _G['defaultPlayerStrumX2'])

        setPropertyFromGroup('strumLineNotes', 3, 'X', _G['defaultOpponentStrumX3'] + 35)
        setPropertyFromGroup('strumLineNotes', 7, 'X', _G['defaultPlayerStrumX3'] + 35)
    end

    if curStep == 1900 then
        setPropertyFromGroup('strumLineNotes', 0, 'y', _G['defaultOpponentStrumY0'])
        setPropertyFromGroup('strumLineNotes', 4, 'y', _G['defaultPlayerStrumY0'])

        setPropertyFromGroup('strumLineNotes', 1, 'y', _G['defaultOpponentStrumY1'] + 35)
        setPropertyFromGroup('strumLineNotes', 5, 'y', _G['defaultPlayerStrumY1'] + 35)

        setPropertyFromGroup('strumLineNotes', 2, 'y', _G['defaultOpponentStrumY2'] - 35)
        setPropertyFromGroup('strumLineNotes', 6, 'y', _G['defaultPlayerStrumY2'] - 35)

        setPropertyFromGroup('strumLineNotes', 3, 'y', _G['defaultOpponentStrumY2'])
        setPropertyFromGroup('strumLineNotes', 7, 'y', _G['defaultPlayerStrumY2'])

        setPropertyFromGroup('strumLineNotes', 0, 'x', _G['defaultOpponentStrumX0'])
        setPropertyFromGroup('strumLineNotes', 4, 'x', _G['defaultPlayerStrumX0'])

        setPropertyFromGroup('strumLineNotes', 1, 'X', _G['defaultOpponentStrumX1'])
        setPropertyFromGroup('strumLineNotes', 5, 'X', _G['defaultPlayerStrumX1'])

        setPropertyFromGroup('strumLineNotes', 2, 'X', _G['defaultOpponentStrumX2'])
        setPropertyFromGroup('strumLineNotes', 6, 'X', _G['defaultPlayerStrumX2'])

        setPropertyFromGroup('strumLineNotes', 3, 'X', _G['defaultOpponentStrumX3'])
        setPropertyFromGroup('strumLineNotes', 7, 'X', _G['defaultPlayerStrumX3'])
    end

    if curStep == 1902 then
        setPropertyFromGroup('strumLineNotes', 0, 'y', _G['defaultOpponentStrumY0'])
        setPropertyFromGroup('strumLineNotes', 4, 'y', _G['defaultPlayerStrumY0'])

        setPropertyFromGroup('strumLineNotes', 1, 'y', _G['defaultOpponentStrumY1'])
        setPropertyFromGroup('strumLineNotes', 5, 'y', _G['defaultPlayerStrumY1'])

        setPropertyFromGroup('strumLineNotes', 2, 'y', _G['defaultOpponentStrumY2'])
        setPropertyFromGroup('strumLineNotes', 6, 'y', _G['defaultPlayerStrumY2'])

        setPropertyFromGroup('strumLineNotes', 3, 'y', _G['defaultOpponentStrumY2'])
        setPropertyFromGroup('strumLineNotes', 7, 'y', _G['defaultPlayerStrumY2'])

        setPropertyFromGroup('strumLineNotes', 0, 'x', _G['defaultOpponentStrumX0'])
        setPropertyFromGroup('strumLineNotes', 4, 'x', _G['defaultPlayerStrumX0'])

        setPropertyFromGroup('strumLineNotes', 1, 'X', _G['defaultOpponentStrumX1'])
        setPropertyFromGroup('strumLineNotes', 5, 'X', _G['defaultPlayerStrumX1'])

        setPropertyFromGroup('strumLineNotes', 2, 'X', _G['defaultOpponentStrumX2'])
        setPropertyFromGroup('strumLineNotes', 6, 'X', _G['defaultPlayerStrumX2'])

        setPropertyFromGroup('strumLineNotes', 3, 'X', _G['defaultOpponentStrumX3'])
        setPropertyFromGroup('strumLineNotes', 7, 'X', _G['defaultPlayerStrumX3'])
    end
end
