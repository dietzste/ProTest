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

SetToolTip(Menu, Text, Remove){
WinGetPos , MenuX, MenuY, MenuWidth,, %Menu%
ToolTipPosX := MenuX + MenuWidth
ToolTipPosY := MenuY
CoordMode, ToolTip
ToolTip, %Text%, %ToolTipPosX% , %ToolTipPosY%, 1
SetTimer, RemoveToolTip, %Remove%
}