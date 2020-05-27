;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;   (F4) Advanced SEARCH     ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F4::
SetTitleMatchMode, 3
If WinExist(GuiF4)
	WinActivate, %GuiF4%
else
	Goto F4Routine
return

F4Routine:
SetTitleMatchMode, 2
4GuiReset := false

4GuiSetControls:
if (4GuiReset = true)
	{
	DeleteIniSection(ProjectFile, AdvancedSearchMenu)
	4GuiReset := false
	}

loop, 5 {
e_fnN%A_Index% := GetIniValue(ProjectFile,AdvancedSearchMenu, "e_fnN" . A_Index, A_Space)
e_fnV%A_Index% := GetIniValue(ProjectFile,AdvancedSearchMenu, "e_fnV" . A_Index, A_Space)
}
c_XModul := GetIniValue(ProjectFile, AdvancedSearchMenu, "c_XModul", 1)


;;;;;; GUI Menü ;;;;;
; EDIT-FIELDs
Gui, 4:+AlwaysOnTop ToolWindow
Gui, 4:Add, Groupbox, x10 y14 w247 h160 cNavy Center, Werte für fn(s) vergeben...
Gui, 4:Add, Groupbox, x17 y35 w77 h130 Center, fn
Gui, 4:Add, Groupbox, x99 y35 w150 h130 Center , Wert
Gui, 4:Add, Edit, x25  y50 w62  h20 Center Limit%fnLimit% 	ve_fnN1, %e_fnN1%
Gui, 4:Add, Edit, x106 y50 w135 h20 Center	   		   		ve_fnV1, %e_fnV1%
Gui, 4:Add, Edit, x25  y72 w62  h20 Center Limit%fnLimit% 	ve_fnN2, %e_fnN2%
Gui, 4:Add, Edit, x106 y72 w135 h20 Center   	   		   	ve_fnV2, %e_fnV2%
Gui, 4:Add, Edit, x25  y94 w62  h20 Center Limit%fnLimit% 	ve_fnN3, %e_fnN3%
Gui, 4:Add, Edit, x106 y94 w135 h20 Center		   	   		ve_fnV3, %e_fnV3%
Gui, 4:Add, Edit, x25  y116 w62  h20 Center Limit%fnLimit% 	ve_fnN4, %e_fnN4%
Gui, 4:Add, Edit, x106 y116 w135 h20 Center	   		   		ve_fnV4, %e_fnV4%
Gui, 4:Add, Edit, x25  y138 w62  h20 Center Limit%fnLimit% 	ve_fnN5, %e_fnN5%
Gui, 4:Add, Edit, x106 y138 w135 h20 Center		   	   		ve_fnV5, %e_fnV5%
; CheckBoxes
Gui, 4:Add, CheckBox, x17 y180  w140  h20 Checked%c_XModul% vc_XModul, X-Prüfmodul überspringen 
Gui, 4:Add, CheckBox, x17 y202  w140  h20 Disabled, Adresstool überspringen 
; Buttons
Gui, 4:Add, Button, x10 y238 w60 h25 g4GuiResetControls, Reset
Gui, 4:Add, Button, x75 y238 w60 h25 g4GuiHelp, Hilfe
Gui, 4:Add, Button, x178 y238 w80 h25 Default g4GuiSave, Speichern
Gui, 4:Show, Center Autosize, %GuiF4%
return

4GuiClose:
4GuiEscape:
Gui 4:Destroy
return

4GuiSave:
GoSub 4GuiSaveInput
Gui 4:Destroy
return

4GuiHelp:
ShowHelpWindow(GuiF4)
return 

4GuiResetControls:
MsgBox, 4132, Reset?, Reset %GuiF4%?
IfMsgBox, YES
	{
	Gui 4:Destroy
	4GuiReset := true
	Goto 4GuiSetControls
	}
return

4GuiSaveInput:
Gui, 4:Submit, NoHide
UpcomingControlArray := ["e_fnN", "e_fnV"]
for i, control in UpcomingControlArray
	{
	loop, 5 {
	UpcomingName := control . A_Index
	UpcomingValue := % %UpcomingName%
	if (%UpcomingName% = "")
		DeleteIniValue(ProjectFile, AdvancedSearchMenu, UpcomingName) 
	else if (UpcomingValue != "")
		SaveIniValue(ProjectFile, AdvancedSearchMenu, UpcomingName, UpcomingValue)
	} ; ende loop
} ; ende for loop

SaveIniValue(ProjectFile, AdvancedSearchMenu, "c_XModul", c_XModul)
return
