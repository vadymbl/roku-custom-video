sub init()
    ' disable default video ui
    m.top.enableUI = false
    ' timers
    m.holdTimer = m.top.FindNode("holdTimer")
    m.holdRewind = m.top.FindNode("holdRewind")
    m.holdRewind.ObserveFieldScoped("fire", "onHoldRewind")
    m.holdTimer.ObserveFieldScoped("fire", "onHoldDetection")

    m.forwardCount = invalid
    m.rewindCount = invalid
    m.top.ObserveFieldScoped("position", "OnPositionChanged")
end sub

function GetVideoNode()
    return m.top
end function

sub OnPositionChanged(event as Object)
    if m.direction = invalid
        m.top.progressPosition = fix(event.GetData())
    end if
end sub

function IsDoingSeek() as Boolean
    return (GetVideoNode().seek = m.top.progressPosition)
end function

sub StopRewFF(doSeek = false as Boolean)
    m.forwardCount = invalid
    m.rewindCount = invalid
    m.top.FFRewCount = 0
    m.top.activeButton = ""
    m.holdRewind.control = "stop"
    if doSeek
        GetVideoNode().seek = m.top.progressPosition
        GetVideoNode().control = "resume"
        m.direction = invalid
    end if
end sub

sub onHoldRewind()
    GetVideoNode().control = "pause"
    if m.direction = "fastforward"
        newPosition = m.top.progressPosition + m.forwardCount * 4
        if newPosition < m.top.duration
            m.top.progressPosition = newPosition
        else
            m.top.progressPosition = m.top.duration
        end if
    end if
    if m.direction = "rewind"
        newPosition = m.top.progressPosition - m.rewindCount * 4
        if newPosition > 0
            m.top.progressPosition = newPosition
        else
            m.top.progressPosition = 0
        end if
    end if
end sub

sub onHoldDetection()
    GetVideoNode().control = "pause"
    if m.direction = "left"
        newPosition = m.top.progressPosition - m.top.seekdelta
        if newPosition > 0
            m.top.progressPosition = newPosition
        else
            m.top.progressPosition = 0
        end if
    else if m.direction = "right"
        newPosition = m.top.progressPosition + m.top.seekdelta
        if newPosition < m.top.duration
            m.top.progressPosition = newPosition
        else
            m.top.progressPosition = m.top.duration
        end if
    end if
end sub

sub checkRewindingCount(rewindingType as String)
    if m[rewindingType] = invalid or m[rewindingType] = 8
        m[rewindingType] = 2
    else
        m[rewindingType] *= 2
    end if
    m.top.FFRewCount = m[rewindingType]
end sub

function handleRightKey(key as String) as Boolean
    StopRewFF()
    m.top.activeButton = key
    m.direction = key
    onHoldDetection()
    m.holdTimer.control = "start"
    return true
end function

function handleLeftKey(key as String) as Boolean
    StopRewFF()
    m.top.activeButton = key
    m.direction = key
    onHoldDetection()
    m.holdTimer.control = "start"
    return true
end function

function handleFastforwardKey(key as String) as Boolean
    m.rewindCount = invalid
    checkRewindingCount("forwardCount")
    m.top.activeButton = key
    m.direction = key
    onHoldRewind()
    m.holdRewind.control = "start"
    return true
end function

function handleRewindKey(key as String) as Boolean
    m.forwardCount = invalid
    checkRewindingCount("rewindCount")
    m.top.activeButton = key
    m.direction = key
    onHoldRewind()
    m.holdRewind.control = "start"
    return true
end function

function handleReplayKey(key as String) as Boolean
    m.top.activeButton = key
    m.top.progressPosition -= 20
    if m.top.progressPosition < 0 then m.top.progressPosition = 0
    StopRewFF(true)
    return true
end function

function handleOkAndPlayKey(key as String) as Boolean
    m.direction = invalid
    m.top.activeButton = ""
    if m.top.progressPosition <> fix(GetVideoNode().position)
        StopRewFF(true)
        return true
    end if
    return false
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false

    if press = true
        ' block user interactions during loading of video
        handled = IsDoingSeek()
        if key = "right" and not handled
            handled = handleRightKey(key)
        else if key = "left" and not handled
            handled = handleLeftKey(key)
        else if key = "fastforward" and not handled
            handled = handleFastforwardKey(key)
        else if key = "rewind" and not handled
            handled = handleRewindKey(key)
        else if key = "replay"
            handled = handleReplayKey(key)
        else if key = "play" or key = "OK"
            handled = handleOkAndPlayKey(key)
        end if
    else if press = false
        if key = "right" or key = "left"
            m.holdTimer.control = "stop"
            if not IsDoingSeek()
                if m.direction = invalid
                    ' user release button to fast and needed logic is not invoked
                    m.direction = key
                    onHoldDetection()
                end if
                StopRewFF(true)
            end if
            handled = true
        end if
    end if

    return handled
end function
