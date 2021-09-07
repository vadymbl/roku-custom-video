Function GetDurationStringStandard(totalSeconds = 0 As Integer, pad = True As Boolean, showEmptyHours = false as Boolean) As String
    remaining = totalSeconds
    hours = Int(remaining / 3600).ToStr()
    remaining = remaining Mod 3600
    minutes = Int(remaining / 60).ToStr()
    remaining = remaining Mod 60
    seconds = remaining.ToStr()

    If hours <> "0" OR showEmptyHours Then
        Return IIf(pad, PadLeft(hours, "0", 2), hours) + ":" + PadLeft(minutes, "0", 2) + ":" + PadLeft(seconds, "0", 2)
    Else
        Return IIf(pad, PadLeft(minutes, "0", 2), minutes) + ":" + PadLeft(seconds, "0", 2)
    End If
End Function

Function IIf(condition As Boolean, result1 As Dynamic, result2 As Dynamic) As Dynamic
    If condition Then
        Return result1
    Else
        Return result2
    End If
End Function

Function PadLeft(value As String, padChar As String, totalLength As Integer) As String
    While value.Len() < totalLength
        value = padChar + value
    End While
    Return value
End Function
