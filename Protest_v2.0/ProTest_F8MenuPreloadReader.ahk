;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; (F8)READ/UPDATE PRELOADS  ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F8::
ListLines Off
If WinExist(GuiF8)
	WinActivate, %GuiF8%
else
	Goto F8Routine
return

F8Routine:
8GuiReset := false

8GuiSetControls:
if (8GuiReset = true)
	{
	DeleteIniSection(ProjectFile, PreloadReaderMenu)
	8GuiReset := false
	}

loop, 5 {
e_PLN%A_Index% := GetIniValue(ProjectFile, PreloadReaderMenu, "e_PLN" . A_Index, A_Space)
e_PLU%A_Index% := GetIniValue(ProjectFile, PreloadReaderMenu, "e_PLU" . A_Index, "-")
c_PL%A_Index% := GetIniValue(ProjectFile, PreloadReaderMenu, "c_PL" . A_Index, 0)
} ; ende loop
c_LoadSavedValues := GetIniValue(ProjectFile, PreloadReaderMenu, "c_LoadSavedValues", 0)

; Show Current LFD
if (CurrentLFD != "")
	CurrentLFDComment := "(LFD: " . CurrentLFD . ")"
else
	CurrentLFDComment := ""

;;;;;; GUI Menü ;;;;;
; EDIT-FIELDs
Gui, 8:+AlwaysOnTop
Gui, 8:Add, Groupbox, x30 y20 w150 h135 cNavy, Preload(s) auslesen
Gui, 8:Add, Groupbox, x182 y20 w75 h135 cNavy, Neuer Wert
Gui, 8:Add, Edit, x34 	y40  w140  h20 ve_PLN1, %e_PLN1%
Gui, 8:Add, Edit, x190  y40  w60   h20 ve_PLU1, %e_PLU1%
Gui, 8:Add, Edit, x34 	y62  w140  h20 ve_PLN2, %e_PLN2%
Gui, 8:Add, Edit, x190  y62  w60   h20 ve_PLU2, %e_PLU2%
Gui, 8:Add, Edit, x34 	y84 w140   h20 ve_PLN3, %e_PLN3%
Gui, 8:Add, Edit, x190  y84 w60    h20 ve_PLU3, %e_PLU3%
Gui, 8:Add, Edit, x34   y106 w140  h20 ve_PLN4, %e_PLN4%
Gui, 8:Add, Edit, x190  y106 w60   h20 ve_PLU4, %e_PLU4%
Gui, 8:Add, Edit, x34   y128 w140  h20 ve_PLN5, %e_PLN5%
Gui, 8:Add, Edit, x190  y128 w60   h20 ve_PLU5, %e_PLU5%
Gui, 8:Add, CheckBox, x12 y40  w13  h20 Checked%c_PL1% vc_PL1
Gui, 8:Add, CheckBox, x12 y62  w13  h20 Checked%c_PL2% vc_PL2
Gui, 8:Add, CheckBox, x12 y84 w13  h20 Checked%c_PL3% vc_PL3
Gui, 8:Add, CheckBox, x12 y106 w13	 h20 Checked%c_PL4% vc_PL4
Gui, 8:Add, CheckBox, x12 y128 w13  h20 Checked%c_PL5% vc_PL5
; weitere Checkboxen
Gui, 8:Add, CheckBox, x30 y195  w220 h20 Checked%c_LoadSavedValues% vc_LoadSavedValues, aus TempFile laden %CurrentLFDComment%
Gui, 8:Add, CheckBox, x30 y217 	w150 h20 vc_DetailsOnly g8GuiOnlyDetails, nur Preload-Details laden
; BUTTONS
Gui, 8:Add, Button,   x30  y162 w50  h25 g8GuiHelp , Hilfe
Gui, 8:Add, Button,   x85  y162 w50  h25 g8GuiResetControls, Reset
Gui, 8:Add, Button,   x178 y162 w80 h25 Default g8GuiPreloads , Ok
Gui, 8:Show, x850 y480 Autosize Center, %GuiF8%
Return

8GuiClose:
8GuiEscape:
GoSub 8GuiSaveInput
Gui 8:Destroy
if WinExist("AutoEdit")
	Gui 5:Destroy
ListLines On
return

8GuiOnlyDetails:
Gui, 8:Submit, NoHide
if (c_DetailsOnly = 1)
	{
	Control, Hide ,, aus TempFile laden, %GuiF8%
	Control, Uncheck ,, aus TempFile laden, %GuiF8%
	}
else
	Control, Show ,, aus TempFile laden, %GuiF8%
return 

8GuiSaveInput:
ListLines Off
Gui, 8:Submit, NoHide
8GuiControlArray := ["e_PLN", "e_PLU", "c_PL"]
For i, control in 8GuiControlArray
	{
	loop, 5 {
	ControlName := control . A_Index
	if (control = "e_PLN") and (%ControlName% = "")
		DeleteIniValue(ProjectFile, PreloadReaderMenu, ControlName)
	else if (control = "e_PLU") and (%ControlName% = "-")
		DeleteIniValue(ProjectFile, PreloadReaderMenu, ControlName)
	else if (control = "c_PL") and (%ControlName% = 0)
		DeleteIniValue(ProjectFile, PreloadReaderMenu, ControlName)
	else
		SaveIniValue(ProjectFile, PreloadReaderMenu, ControlName, %ControlName%)
	} ;ende loop 9
} ; ende for 
SaveIniValue(ProjectFile, PreloadReaderMenu, "c_LoadSavedValues", c_LoadSavedValues)
ListLines On
return

8GuiHelp:
ShowHelpWindow(GuiF8)
return

8GuiResetControls:
MsgBox, 4132, Reset?, Reset %GuiF8%?
IfMsgBox, YES
	{
	Gui 8:Destroy
	8GuiReset := true
	Goto 8GuiSetControls
	}
return

8GuiPreloads:
GoSub 8GuiSaveInput
loop, 5 {
PreloadCheckBox := c_PL%A_Index%
Preload := e_PLN%A_Index%
PreloadUpdateValue := e_PLU%A_Index%
; hier eventuell check, wie viele Checkboxes aktiv 
IF (Preload != "") and (PreloadCheckBox = 1)   ; Checkbox ausgewählt
	{
	; Convert if necessary
	Conversion := GetIniValue(PreloadDetailsFile, "Converter", Preload)
	if (Conversion != "ERROR")
		Preload := Conversion
	; Details abrufen
	If (c_DetailsOnly = 1) ; nur Details
		MsgBox,4096,%Preload%, % GetIniSection(PreloadDetailsFile , Preload)
	else
		{
		; schauen ob Preload in Liste
		CheckPreloadInPreloadList(Preload)
		; mit/ohne Update 
		If (PreloadUpdateValue = "-") ; read only
			{
			PreloadOriginal := L_ReadPreload(Preload)
			MsgBox, 4096 ,%Preload%, %Preload% = %PreloadOriginal%
			}
		else ; read and update
			{
			PreloadOriginal := L_UpdatePreload(Preload, PreloadUpdateValue)
			Msgbox, 4096 ,%Preload%, %Preload% wurde von %PreloadOriginal% auf %PreloadUpdateValue% umgestellt.
			}
		}
	} ;ende if
} ; ende loop
GoSub 8GuiSaveInput
return