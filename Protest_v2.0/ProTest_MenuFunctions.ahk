;;;;;;;;;;;;;;;;;;;;;;
;;;;  ToolTips    ;;;;
;;;;;;;;;;;;;;;;;;;;;;

RemoveToolTip:
ToolTip 
return

GetCurrentEditFieldNumber(Menu){
local
ControlGetFocus, FocusVar, %Menu%
return CurrentEditFieldNumber := Substr(FocusVar, 5)
}

GetCurrentEditFieldText(Menu){
local
CurrentEditFieldNumber := GetCurrentEditFieldNumber(Menu)
ControlGetText, CurrentEditFieldText, Edit%CurrentEditFieldNumber%
return CurrentEditFieldText
}

SetCurrentEditFieldText(Menu, NewEditFieldText){
local
CurrentEditFieldNumber := GetCurrentEditFieldNumber(Menu)
ControlSetText, Edit%CurrentEditFieldNumber%, %NewEditFieldText%, %Menu%
}

SetToolTip(Menu, Text, Remove){
WinGetPos , MenuX, MenuY, MenuWidth,, %Menu%
ToolTipPosX := MenuX + MenuWidth
ToolTipPosY := MenuY
CoordMode, ToolTip
ToolTip, %Text%, %ToolTipPosX% , %ToolTipPosY%, 1
SetTimer, RemoveToolTip, %Remove%
}

ShowPreloadListVariables(Menu){
local
global PreloadList
if (PreloadList != "")
	{
	CurrentEditFieldText := GetCurrentEditFieldText(Menu)
	CurrentEditFieldTextLength := StrLen(CurrentEditFieldText)
	if (CurrentEditFieldTextLength > 0)
		{
		MatchingVarsCount := 0
		Loop, Parse, PreloadList, "`n"
			{
			MatchText := Substr(A_LoopField, 1, CurrentEditFieldTextLength)
			if (CurrentEditFieldText = MatchText)
				{
				++MatchingVarsCount
				if (MatchingVarsCount <= 20)
					{
					if (MatchingVarsCount = 1)
						MatchingVars := "Suche passende Preload-Variablen:`n" . A_LoopField
					else
						MatchingVars .= "`n" . A_LoopField
					}
				else
					break
				} ; ende if
			} ; ende loop
		LinesCount := StrSplit(MatchingVars, "`n").maxindex()
		if (LinesCount = 2)
			{
			PressTabInfo := " (Drücke Tab...)"
			MatchingVars .= PressTabInfo
			}
		SetToolTip(Menu, MatchingVars, -10000)
		}
	} ; ende if
MatchingVars := StrReplace(MatchingVars, PressTabInfo)
return MatchingVars
}