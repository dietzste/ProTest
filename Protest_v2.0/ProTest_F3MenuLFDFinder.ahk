;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;   (F3) LFD_Finder    ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F3::
ListLines Off
If WinExist(GuiF3)
	WinActivate, %GuiF3%
else
	Goto F3Routine
return

F3Routine:
3GuiReset := false
; Fenster mit/ohne LFD
if (CurrentLFD != "")
	F3MenuName := "LFD Finder Menu - LFD: " . CurrentLFD
else
	F3MenuName := GuiF3

3GuiSetControls:
if (3GuiReset = true)
	{
	DeleteIniSection(ProjectFile, LFDFinderMenu)
	3GuiReset := false
	}

Loop, 8 {
e_LFD_PLN%A_Index% := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLN" . A_Index, A_Space)
e_LFD_PLR%A_Index% := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLR" . A_Index, "-")
e_LFD_PLE%A_Index% := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLE" . A_Index, "-")
} ; ende loop

; Other 
3GuiControlArray := ["c_CheckAgain", "c_AbortSearch", "e_AbortSearch", "cb_StartLFD", "e_CheckAgain", "c_CheckTempFileFirst"]
for i, control in 3GuiControlArray
	{
	%control% := GetIniValue(ProjectFile, LFDFinderMenu, control)
	If (%control% = "ERROR")
		%control% := GetIniValue(BasicFile, LFDFinderMenu, control)
	}
	
; Start LFD_List
cb_StartLFDList := CreateLFDList("F3")

;;;;;; GUI Menü ;;;;;

Gui, 3:+AlwaysOnTop ToolWindow
Gui, 3:Add, Groupbox, x9 y9 w130 h205 cNavy, Name Preload
Gui, 3:Add, Groupbox, x145 y9 w74 h205 cNavy, Wunschwert
Gui, 3:Add, Groupbox, x226 y9 w102 h205 cNavy, Ausschluss
Gui, 3:Add, Edit, x13 y30 w120 h20  ve_LFD_PLN1, % e_LFD_PLN1
Gui, 3:Add, Edit, x152 y30 w60 h20  ve_LFD_PLR1, %  e_LFD_PLR1
Gui, 3:Add, Edit, x232 y30 w90 h20  ve_LFD_PLE1, %  e_LFD_PLE1
Gui, 3:Add, Edit, x13 y52 w120 h20 ve_LFD_PLN2, % e_LFD_PLN2
Gui, 3:Add, Edit, x152 y52 w60 h20 ve_LFD_PLR2, %  e_LFD_PLR2
Gui, 3:Add, Edit, x232 y52 w90 h20 ve_LFD_PLE2, %  e_LFD_PLE2
Gui, 3:Add, Edit, x13 y74 w120 h20 ve_LFD_PLN3, % e_LFD_PLN3
Gui, 3:Add, Edit, x152 y74 w60 h20 ve_LFD_PLR3, %  e_LFD_PLR3
Gui, 3:Add, Edit, x232 y74 w90 h20 ve_LFD_PLE3, %  e_LFD_PLE3
Gui, 3:Add, Edit, x13 y96 w120 h20 ve_LFD_PLN4, % e_LFD_PLN4
Gui, 3:Add, Edit, x152 y96 w60 h20 ve_LFD_PLR4, %  e_LFD_PLR4
Gui, 3:Add, Edit, x232 y96 w90 h20 ve_LFD_PLE4, %  e_LFD_PLE4
Gui, 3:Add, Edit, x13 y118 w120 h20 ve_LFD_PLN5, % e_LFD_PLN5
Gui, 3:Add, Edit, x152 y118 w60 h20 ve_LFD_PLR5, %  e_LFD_PLR5
Gui, 3:Add, Edit, x232 y118 w90 h20 ve_LFD_PLE5, %  e_LFD_PLE5
Gui, 3:Add, Edit, x13 y140 w120 h20 ve_LFD_PLN6, % e_LFD_PLN6
Gui, 3:Add, Edit, x152 y140 w60 h20 ve_LFD_PLR6, %  e_LFD_PLR6
Gui, 3:Add, Edit, x232 y140 w90 h20 ve_LFD_PLE6, %  e_LFD_PLE6
Gui, 3:Add, Edit, x13 y162 w120 h20 ve_LFD_PLN7, % e_LFD_PLN7
Gui, 3:Add, Edit, x152 y162 w60 h20 ve_LFD_PLR7, %  e_LFD_PLR7
Gui, 3:Add, Edit, x232 y162 w90 h20 ve_LFD_PLE7, %  e_LFD_PLE7
Gui, 3:Add, Edit, x12 y184 w120 h20 ve_LFD_PLN8, % e_LFD_PLN8
Gui, 3:Add, Edit, x152 y184 w60 h20 ve_LFD_PLR8, %  e_LFD_PLR8
Gui, 3:Add, Edit, x232 y184 w90 h20 ve_LFD_PLE8, %  e_LFD_PLE8
;OPTIONEN
Gui, 3:Add, Groupbox, x8 y220 w321 h125 cNavy, Optionen
Gui, 3:Add, CheckBox, x15 y240 w16 h20 Checked%c_CheckAgain%  vc_CheckAgain, 
Gui, 3:Add, CheckBox, x15 y262 w16 h20 Checked%c_AbortSearch% vc_AbortSearch, 
Gui, 3:Add, Text, x35 y242 w30 h20 , nach
Gui, 3:Add, Text, x35 y264 w40 h20 , nach
Gui, 3:Add, Edit, x75 y240 w30 h18 ve_CheckAgain, %e_CheckAgain%
Gui, 3:Add, Edit, x75 y262 w30 h18 ve_AbortSearch, %e_AbortSearch%
Gui, 3:Add, Text, x115 y242 w170 h20 , erfolglosen Suchen erneut fragen
Gui, 3:Add, Text, x115 y264 w170 h20 , erfolglosen Suchen abbrechen
Gui, 3:Add, CheckBox, x15 y285 w250 h20 Checked%c_CheckTempFileFirst% vc_CheckTempFileFirst, %A_Tab%%A_Space% Zuerst LFD's im TempFile durchsuchen 

; LFD Check
Gui, 3:Add, Text, x15 y315 w60 h20 , Start LFD:
Gui, 3:Add, ComboBox, x75 y312 w75 h120 Limit%LFDLimit% vcb_StartLFD, % cb_StartLFDList
Gui, 3:Add, Button, x170 y312 w75 h20 g3GuiShowLFDValues, LFD Werte

; BUTTONS
Gui, 3:Add, Button, x08 y350 w60 h25 g3GuiResetControls, Reset
Gui, 3:Add, Button, x73 y350 w60 h25 g3GuiHelp, Hilfe
Gui, 3:Add, Button, x170 y350 w75 h25 g3GuiAutoEdit, AutoEdit
Gui, 3:Add, Button, x250 y350 w75 h25 Default g3GuiSave, Speichern
Gui, 3:Show, Center Autosize, % F3MenuName
if (AddOns = false)
	Control, Disable ,, AutoEdit, %GuiF3% 
Return

3GuiClose:
3GuiEscape:
Gui 3:Destroy
Gui 5:Destroy
return

3GuiHelp:
ShowHelpWindow(GuiF3)
return

3GuiResetControls:
MsgBox, 4132, Reset?, Reset %GuiF3%?
IfMsgBox, YES
	{
	Gui 3:Destroy
	3GuiReset := true
	Goto 3GuiSetControls
	}
return


3GuiShowLFDValues:
ShowSelectedLFDValues("cb_StartLFD")
return 

3GuiSave:
GoSub 3GuiSaveInput
;WARNINGS
if (cb_StartLFD != "")
	{
	if (StrLen(cb_StartLFD) != LFDLimit)
		{
		MsgBox, 4096, Zu wenig Stellen!, Diese LFD hat zu wenig Stellen!
		return
		}
	}
Gui 3:Destroy
Gui 5:Destroy
return

3GuiSaveInput:
ListLines Off
Gui, 3:Submit, NoHide
; Edit Array
3GuiEditArray := ["e_LFD_PLN", "e_LFD_PLR", "e_LFD_PLE"]
for i, Edit in 3GuiEditArray
	{
	Loop, 8 {
	EditName := Edit . A_Index
	EditValue := % %EditName%
	if (Edit = "e_LFD_PLN")
		{
		if (EditValue = "" Or EditValue = "-")
			DeleteIniValue(ProjectFile, LFDFinderMenu, EditName)
		else
			SaveIniValue(ProjectFile,LFDFinderMenu, EditName, EditValue)
		}
	if (Edit = "e_LFD_PLR" OR Edit = "e_LFD_PLE")
		{
		if (EditValue = "-")
			DeleteIniValue(ProjectFile, LFDFinderMenu, EditName)
		else 
			SaveIniValue(ProjectFile,LFDFinderMenu, EditName, EditValue)
		}
	} ; ende loop
} ; ende for loop

;Menu Options
; 3GuiControlArray := ["c_CheckAgain", "c_AbortSearch", "e_AbortSearch", "cb_StartLFD", "e_CheckAgain", "c_CheckTempFileFirst"]
for i, control in 3GuiControlArray
	{
	If (%control% = GetIniValue(BasicFile, LFDFinderMenu, control))
		DeleteIniValue(ProjectFile, LFDFinderMenu, control)
	else
		SaveIniValue(ProjectFile, LFDFinderMenu, control, %control%)
	}
ListLines On
return 


;; MINI - AUTO EDIT
3GuiAutoEdit:
; Fenster richtig darstellen
if WinExist(GuiF3) OR WinExist(GuiF8)
	{
	if WinExist(GuiF3)
		WinGetPos,MenuPosX, MenuPosY, MenuWidth, MenuHeight, %GuiF3%
	else if WinExist(GuiF8)
		WinGetPos,MenuPosX, MenuPosY, MenuWidth, MenuHeight, %GuiF8%
	FineTuneX := Ceil((ScreenWidth * 5)/StandardWidth)
	AutoEditX := MenuPosX + MenuWidth + FineTuneX
	AutoEditY := MenuPosY
	5GuiCenter := ""
	}
else
	{
	5GuiCenter := "Center"
	AutoEditX := 0
	AutoEditY := 0
	}
; PreloadList laden
if !FileExist(PreloadListPath)
	{
	PreloadListBox := ""
	PreloadList := ""
	5GuiDis := DisON
	}
else
	{
	PreloadListBox := ""
	5GuiDis := DisOFF
	Loop, Read, %PreloadListPath%
		PreloadListBox .= A_LoopReadLine . "|"
	FileRead, PreloadList , %PreloadListPath%
	}

Gui, 5:+AlwaysOnTop ToolWindow
Gui, 5:Add, Groupbox, x9 y10 w322 h180 cNavy, Hinterlegte Preloads durchsuchen
Gui, 5:Add, Edit, x16 y30 w120 h20 %5GuiDis% ve_SearchEdit g5GuiSearchEdit
Gui, 5:Add, Button, x28 y55 w100 h20 %5GuiDis% g5GuiAddPreload, Hinzuf%ue%gen
Gui, 5:Add, Button, x28 y77 w100 h20 g5GuiLoadPreloadList, Lade Preloadliste
Gui, 5:Add, Listbox, x152 y30 w170 h150  %5GuiDis% Sort vAutoEditResult , % PreloadListBox
Gui, 5:Add, Text, x50 y195 w280 h20, Hinweis: Preloadliste abh%ae%ngig von LFD-Eingabe
Gui, 5:Show, x%AutoEditX% y%AutoEditY% %5GuiCenter% Autosize, AutoEdit
return 

5GuiClose:
5GuiEscape:
if WinActive(GuiF3)
	WinActivate, %GuiF3%
else if WinActive(GuiF8)
	WinActivate, %GuiF8%
Gui 5:Destroy
return

5GuiLoadPreloadList:
CheckWorkWindow()
FileGetSize, FileSize , %PreloadListPath%
if (FileSize != 0 AND FileSize != "")
	{
	MsgBox, 4132, PreloadList vorhanden, Neue Liste Laden und alte Liste (%PreloadListName%) l%oe%schen?
	IfMsgBox, YES
		{
		FileDelete, %PreloadListPath%
		}
	else
		Exit
	}
L_LoadPreloadList()
Gui 5:Destroy
Goto 3GuiAutoEdit
return 

5GuiSearchEdit:
gui 5:Submit, Nohide
GuiControl, ChooseString, AutoEditResult, %e_SearchEdit%
return 

; Adding Preload to F3 or F8
5GuiAddPreload:
gui 5:Submit, Nohide
AddComplete := false
if WinExist(GuiF3)
	{
	gui 3:Submit, Nohide
	GoSub 3GuiSaveInput
	Gui 3:Destroy
	GoSub 3GuiSetControls
	Loop, 8 {
	ControlValue := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLN" . A_Index)
	if (ControlValue = "ERROR" OR ControlValue = "")
		{
		SaveIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLN" . A_Index,  AutoEditResult)
		AddComplete := true
		Gui 3:Destroy
		Goto 3GuiSetControls
		Exit
		}
	} ; ende loop
	} ; ende GuiF3
else if WinExist(GuiF8)
	{
	gui 8:Submit, Nohide
	GoSub 8GuiSaveInput
	Gui 8:Destroy
	GoSub 8GuiSetControls
	Loop, 5 {
	ControlValue := GetIniValue(ProjectFile, PreloadReaderMenu, "e_PLN" . A_Index)
	if (ControlValue = "ERROR" OR ControlValue = "")
		{
		SaveIniValue(ProjectFile, PreloadReaderMenu, "e_PLN" . A_Index,  AutoEditResult)
		AddComplete := true
		Gui 8:Destroy
		Goto 8GuiSetControls
		Exit
		}
	} ; ende loop
	} ; ende GuiF8
if (AddComplete = false)
	{
	MsgBox, 4096, Kein Platz mehr, Edits sind schon voll :(!
	Exit
	}
return 