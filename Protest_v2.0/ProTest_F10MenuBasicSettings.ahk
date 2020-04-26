;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;   (F10) BASIC SETTINGS    ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F10::
ListLines Off
If WinExist(GuiF10)
	WinActivate, %GuiF10%
else
	Goto F10Routine
return

F10Routine:
PermanentSave := ""
10GuiReset := false
10GuiChange := false

10GuiSetControls:
if (10GuiReset = true)
	{
	DeleteIniSection(ProjectFile, BasicSettingsMenu)
	10GuiReset := false
	10GuiChange := false
	}
	
10GuiControlArray := [
, "c_dependent", "e_scale"
, "e_Input1", "e_Input2", "e_Input3"
, "e_BirthDay", "e_BirthMonth", "e_BirthYear"
, "e_sex" ]
for i, control in 10GuiControlArray
	{
	%control% := GetIniValue(ProjectFile, BasicSettingsMenu, control)
	If (%control% = "ERROR")
		%control% := GetIniValue(BasicFile, BasicSettingsMenu, control)
	}
10GuiOCRPositions := ["e_fnStartPosX", "e_fnStartPosY", "e_fnEndPosX", "e_fnEndPosY"]
for i, control in 10GuiOCRPositions
	{
	%control% := GetIniValue(ProjectFile, BasicSettingsMenu, control)
	If (%control% = "ERROR")
		%control% := GetIniValue(BasicFile, BasicSettingsMenu, control, 0)
	}

	
; Change Button
if (10GuiChange = false)
	{
	BasicSettingsDis := DisON
	PRELoadsDis := DisON
	ChangeButtonName := ae . "ndern"
	GoButtonDis	:= DisOFF
	PositionsDis := DisON
	}
else
	{
	if (GetIniValue(ProjectFile, "QuickSetupMenu", "c_StudyWithLFDs", 1) = 1)
		PRELoadsDis := DisOFF
	else
		PRELoadsDis := DisON
	BasicSettingsDis := DisOFF
	ChangeButtonName := "Speichern"
	GoButtonDis	:= DisON
	if (c_dependent = 1)
		PositionsDis := DisON
	if (c_dependent = 0)
		PositionsDis := DisOFF
	}

; CACLCULATE POSITIONS
if (c_dependent = 1)
	Gosub CalculatePositions


Gui, 10:+AlwaysOnTop
; INI Files
Gui, 10:Add, Groupbox, x10 y10 w260 h73 cNavy, Ini Files
Gui, 10:Add, Text, x20 y32  w92  h20 , Project File:
Gui, 10:Add, Edit, x85 	y29  w90  h20 Disabled, % GetIniValue(ProjectFile, "ProjectFiles", "e_ProjectFile")
Gui, 10:Add, Text, x20 y54  w92  h20 , Library File:
Gui, 10:Add, Edit, x85 	y51  w90  h20 Disabled , Library.ini
Gui, 10:Add, Button, x205  y27 w50  h20 g10GuiChangeBasicFile, %ae%ndern
; OCR Konfiguration
Gui, 10:Add, Groupbox, x10 y85 w260 h125 cNavy, OCR Konfiguration
;;; Position fn Start
Gui, 10:Add, Text, x70 y108  w80  h20 cNavy %BasicSettingsDis%, fn
Gui, 10:Add, Text, x85 y108  w40  h20  %BasicSettingsDis%, Start
	;; Start X 
	Gui, 10:Add, Text, x115 y108  w20  h20 %BasicSettingsDis%, X:
	Gui, 10:Add, Edit, x130 y105  w50  h20 %BasicSettingsDis% Center 
	Gui, 10:Add, UpDown,  Range0-400  ve_fnStartPosX , % e_fnStartPosX
	;; Start Y
	Gui, 10:Add, Text, x190 y108  w20  h20 %BasicSettingsDis%, Y:
	Gui, 10:Add, Edit, x205 y105  w50  h20 %BasicSettingsDis%  Center
	Gui, 10:Add, UpDown,  Range0-400  ve_fnStartPosY , % e_fnStartPosY
; Position fn END 
Gui, 10:Add, Text, x70 y130  w80  h20 cNavy %PositionsDis%, fn
Gui, 10:Add, Text, x85 y130  w40  h20 %PositionsDis%, End
	;; End X
	Gui, 10:Add, Text, x115 y130  w20  h20  %PositionsDis%, X:
	Gui, 10:Add, Edit, x130 y127  w50  h20 %PositionsDis%  Center 
	Gui, 10:Add, UpDown,  Range0-400  ve_fnEndPosX, % e_fnEndPosX
	;; End Y
	Gui, 10:Add, Text, x190 y130  w20  h20 %PositionsDis%, Y:
	Gui, 10:Add, Edit, x205 y127  w50  h20 %PositionsDis%  Center 
	Gui, 10:Add, UpDown,  Range0-400 ve_fnEndPosY, % e_fnEndPosY
; Dependent/Scale
Gui, 10:Add, CheckBox, x190 y153  w65  h20 Checked%c_dependent% %BasicSettingsDis% vc_dependent g10Guidependent, abh%ae%ngig
Gui, 10:Add, Text, x85 y155  w50  h20 %PositionsDis%, Scale:
Gui, 10:Add, Edit, x130 y153  w34  h20 %BasicSettingsDis% Center ve_scale, % e_scale 
; Buttons Test/Show/Hilfe
Gui, 10:Add, Button, x205 y180 w50 h20 g10GuiTestOCR, Test
Gui, 10:Add, Button, x20 y180 w60 h20 g10GuiHelp, Hilfe
Gui, 10:Add, Button, x130 y180 w50 h20 g10GuiShowWindow, Show
; Eingabe des Geburtsdatum
Gui, 10:Add, Groupbox, x10 y215 w260 h148 cNavy, Geburtsdatum/Geschlecht
Gui, 10:Add, Text, x20 y240  w60  h20 , Reihenfolge:
Gui, 10:Add, Edit, x100 y237  w50  h20 Center %PRELoadsDis% ve_Input1, % e_Input1
Gui, 10:Add, Edit, x153 y237  w50  h20 Center %PRELoadsDis% ve_Input2, % e_Input2
Gui, 10:Add, Edit, x206 y237  w50  h20 Center %PRELoadsDis% ve_Input3, % e_Input3
Gui, 10:Add, Text, x58 y265  w90  h20 , Tag:
Gui, 10:Add, Text, x49 y288  w90  h20 , Monat:
Gui, 10:Add, Text, x58 y312  w90  h20 , Jahr:
Gui, 10:Add, Edit, x100 y263  w103  h20 Center %PRELoadsDis% ve_BirthDay, % e_BirthDay
Gui, 10:Add, Edit, x100 y286  w103  h20 Center %PRELoadsDis% ve_BirthMonth, % e_BirthMonth
Gui, 10:Add, Edit, x100 y310  w103  h20 Center %PRELoadsDis% ve_BirthYear, % e_BirthYear
Gui, 10:Add, Text, x26 y335  w90  h20 , Geschlecht:
Gui, 10:Add, Edit, x100 y333  w103  h20 Center %PRELoadsDis% ve_sex, % e_sex
; Buttons
Gui, 10:Add, Button,   x10  y370 w55  h25 g10GuiResetControls, Reset
Gui, 10:Add, Button,   x70  y370 w70  h25 g10GuiChangeButton , % ChangeButtonName 
Gui, 10:Add, Button,   x190 y370 w80 h25 Default g10Go %GoButtonDis%, OK
Gui, 10:Show, x850 y480 Autosize Center, %GuiF10%
Return

10GuiClose:
10GuiEscape:
10Go:
if (ChangeButtonName = "Speichern")
	{
	MsgBox, 4132, Speichern?, Angaben Speichern?
	IfMsgBox, Yes
		GoSub 10GuiSaveInput
	}
Gui 10:Destroy
Gui 11:Destroy
Gui 1:Destroy
ListLines On
return 

10GuiResetControls:
MsgBox, 4132, Reset? , %GuiF10% zur%ue%cksetzen? (Setzt Koordinaten auf 0)
IfMsgBox, YES
	{
	Gui 10:Destroy
	10GuiReset := true
	Goto 10GuiSetControls
	}
return 

10Guidependent:
Gui, 10:Submit, NoHide
if (c_dependent = 1)
	{
	Msgbox, 4132, Sicher?, Sollen die Angaben von 'fn End' und 'Button Start' auf Basis `nvon 'fn Start' neu berechnet werden?
	IfMsgBox, NO
		Exit
	}
GoSub 10GuiSaveInput
Gui 10:Destroy
GoSub 10GuiSetControls
return 

10GuiHelp:
ShowHelpWindow(GuiF10)
return 

10GuiTestOCR:
Gui 1:Destroy
CheckCapture2TextIsRunning()
CheckWorkWindow()
SaveScaleFactor()
Gui, 10:Submit, NoHide
if (c_dependent = 1)
	{
	Gosub CalculatePositions
	; Adapt e_fnEnd X/Y
	e_fnEndPosX := e_fnStartPosX + x_ADDToStartfnX
	e_fnEndPosY := e_fnStartPosY + x_ADDToStartfnY
	GuiControl,, Edit5 , %e_fnEndPosX%
	GuiControl,, Edit6 , %e_fnEndPosY%
	}
WinActivate, %WorkWindow%
WinWaitActive, %WorkWindow%
TestOCR := OCR("Test", 1)
Sleep, 500
WinActivate %GuiF10%
WinWaitActive, %GuiF10%
WinGetPos , XPOS, YPOS, Width ,  Height , %GuiF10%
MouseMove, Width / 2, Height / 2, 0
if (TestOCR != "")
	MsgBox, 4096, Test OCR, %TestOCR%
else
	MsgBox, 4096, Test OCR, OCR Failed.
return	

10GuiChangeBasicFile:
Gosub 10GuiSaveInput
GoSub F11Routine
return 

10GuiChangeButton:
if (A_GuiControl = ae . "ndern")
	10GuiChange := true
if (A_GuiControl = "Speichern")
	{
	10GuiChange := false
	PermanentSave := GetKeyState("Shift") 
	Gosub 10GuiSaveInput
	}
Gui 10:Destroy
Goto 10GuiSetControls
return 

10GuiSaveInput:
Gui, 10:Submit, NoHide
CompleteArray := []
; Check Input Tag, Monat, Jahr 
loop 3 {
Inputvar := "e_Input" . A_Index
if !(%Inputvar% = "Tag" or %Inputvar% = "Monat" or %Inputvar% = "Jahr")
	{
	Msgbox,4096, Ups!, Eingabe nicht "Tag", "Monat" oder "Jahr"!
	Exit
	}
CompleteArray[%Inputvar%] := A_Index
}
if (CompleteArray.Count() != 3)
	{
	Msgbox,4096, Ups!, In der Reihenfolge fehlt "Tag", "Monat" oder "Jahr"!
	Exit
	}
	
; Save Input
for i, control in 10GuiControlArray
	{
	If (%control% = GetIniValue(BasicFile, BasicSettingsMenu, control))
		DeleteIniValue(ProjectFile, BasicSettingsMenu, control)
	else
		SaveIniValue(ProjectFile, BasicSettingsMenu, control, %control%)
	}
;10GuiOCRPositions := ["e_fnStartPosX", "e_fnStartPosY", "e_fnEndPosX", "e_fnEndPosY"]
for i, control in 10GuiOCRPositions
	{
	If (%control% = 0)
		DeleteIniValue(ProjectFile, BasicSettingsMenu, control)
	else
		SaveIniValue(ProjectFile, BasicSettingsMenu, control, %control%)
	}
if (c_dependent = 0)
	SaveLengthForwardCapture()
SaveScaleFactor()

; Permanent Speichern
if (PermanentSave = 1)
	{
	Msgbox, 4132, Dauerhaft Speichern?, Soll die aktuelle OCR-Konfiguration dauerhaft gespeichert werden? 
	IfMsgBox, Yes
		{
		;10GuiOCRPositions := ["e_fnStartPosX", "e_fnStartPosY", "e_fnEndPosX", "e_fnEndPosY"]
		for i, control in 10GuiOCRPositions
			{
			SaveIniValue(BasicFile, BasicSettingsMenu, control, %control%)
			}
		SaveIniValue(BasicFile, BasicSettingsMenu, "c_dependent", c_dependent)
		SaveIniValue(BasicFile, BasicSettingsMenu, "e_scale", e_scale)
		}
	PermanentSave := 0
	}
return

; save Forward Text Line Capture
SaveLengthForwardCapture(){
local
global Capture2TextIniFileAppDataPath
global e_fnEndPosX, e_fnStartPosX
ForwardLength := e_fnEndPosX - e_fnStartPosX
IniWrite, %ForwardLength%, %Capture2TextIniFileAppDataPath%, ForwardTextLineCapture, Length
}

; save e_scale
SaveScaleFactor(){
local
global Capture2TextIniFileAppDataPath, e_scale
ListLines, OFF
if (e_scale < 0.71 Or e_scale > 5.0)
	{
	MsgBox, 4096, Scale Angabe korrigieren, Die Wert muss zwischen 0.71 und 5 liegen! (Default: 3.5)
	ListLines, ON
	Exit
	}
else
	{
	e_scale := StrReplace(e_scale, ",", ".")
	IniWrite, %e_scale%, %Capture2TextIniFileAppDataPath%, OCR, ScaleFactor
	}
ListLines, ON
}

; CACLCULATE POSITIONS
CalculatePositions:
e_fnEndPosX := e_fnStartPosX + x_ADDToStartfnX
e_fnEndPosY := e_fnStartPosY + x_ADDToStartfnY
return

10GuiShowWindow:
ListLines, OFF
Gui, 10:Submit, NoHide
CheckWorkWindow()
CoordMode, Pixel, Client
SysGet, CaptionHeight, 4
TestPosX := e_fnStartPosX
TestPosY := e_fnStartPosY + CaptionHeight
if (c_dependent = 1)
	{
	TestWidth := x_ADDToStartfnX
	TestHeight := x_ADDToStartfnY
	e_fnEndPosX := e_fnStartPosX + x_ADDToStartfnX
	e_fnEndPosY := e_fnStartPosY + x_ADDToStartfnY
	; Adapt e_fnEnd X/Y
	GuiControl,, Edit5 , %e_fnEndPosX%
	GuiControl,, Edit6 , %e_fnEndPosY%
	}
else
	{
	TestWidth := e_fnEndPosX - e_fnStartPosX
	TestHeight := e_fnEndPosY - e_fnStartPosY
	}

;check Input e_fnStartPos/ e_fnEndPos
WrongInput := ""
if (e_fnStartPosX >= e_fnEndPosX)
	WrongInput := "X"
if (e_fnStartPosY >= e_fnEndPosY)
	WrongInput := "Y"
if (WrongInput != "")
	{
	MsgBox, 4096, Angaben korrigieren!, Der Wert von fn Start %WrongInput% muss kleiner sein als der Wert von fn End %WrongInput%!
	return
	}

;NoTitle := ""
Gui  1:Destroy
Gui, 1: -Caption +AlwaysOnTop +LastFound +Border 
Gui, 1: Color, 60CFF7
Gui, 1:show,x%TestPosX% y%TestPosY% w%TestWidth% h%TestHeight%, A_Space
WinSet, Transparent, 120, A
ListLines, ON
return 

return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;   (F11) Choose INI FILE   ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F11Routine:
F11MenuName := "Projektdatei ausw" . ae . "hlen..."
	
if WinExist(F11MenuName)
	{
	WinActivate, %F11MenuName%
	Exit
	}

FileList := ""
ExcludeIniFileArray := ["Capture2Text", "BasicSettings", "Library", "_Temp", "PreloadDetails"]
LastUsedFile := GetIniValue(BasicFile, "BasicSettingsMenu", "x_lastProjectFile")
IniLoop:
Loop, Files, *.ini, R
	{
	for i, IniFile in ExcludeIniFileArray
		{
		if instr(A_LoopFileName, IniFile)
			Continue IniLoop
		}
	; Priorisiere LastUsedFile, falls vorhanden
	if (LastUsedFile = A_LoopFileName)
		FileList .= A_LoopFileName . "||"
	else
		FileList .= A_LoopFileName . "|"
	}

if WinExist(GuiF10)
	NoActionButton := "Back"
else
	NoActionButton := "Exit"

Gui, 11:+AlwaysOnTop -SysMenu
Gui, 11:Add, Groupbox, x10 y5 w180 h100 cNavy, Ini-Projectdateien
gui, 11:add, listbox, x20 y28 w150 h60 vIniFileInList sort, % FileList
gui, 11:add, button, x10 y110 w50 g11GuiCancel, % NoActionButton
gui, 11:add, button, x65 y110 w50 g11GuiNewProjectFile, Neu
gui, 11:add, button, x135 y110 w55 Default g11GuiIniDecision, OK
gui, 11:show, Center Autosize, %F11MenuName%
return

11GuiCancel:
11GuiClose:
11GuiEscape:
Gui 11:Destroy
if (NoActionButton = "Exit")
	{
	if (Capture2TextStarted = false)
		ExitApp
	else
		{
		CloseCapture2Text(Captur2TextPID)
		ExitApp
		}
	}
else 
	Exit
return

11GuiIniDecision:
; Close Menus
If WinExist(GuiF10)
	{
	Gui 2:Destroy
	Gui 3:Destroy
	Gui 4:Destroy
	Gui 8:Destroy
	}
Gui, 11:Submit, NoHide
if (IniFileInList != "")
	{
	ProjectFileName := IniFileInList
	SettingUpFiles(ProjectFileName)
	SaveIniValue(BasicFile, "BasicSettingsMenu", "x_lastProjectFile", ProjectFileName)
	SettingUpCapture2Text()
	Gui 10:Destroy
	Send {F10}
	}
else
	Msgbox, 4096, Ups!, Kein File ausgew%ae%hlt!
return

11GuiNewProjectFile:
Gui +LastFound +OwnDialogs +AlwaysOnTop
InputBox, ProjectName, Projektname , Bitte einen Projektnamen vergeben (z.B. "B152"),, 250, 150
if (ErrorLevel)
	{
	; Inputbox geschlossen/cancel:
	Gui 11:Destroy
	Goto F11Routine
	}
else
	{
	ProjectFileName := ProjectName . ".ini"
	if Instr(FileList, ProjectName . "|")
		{
		Msgbox, 4096, Ups!, %ProjectFileName%.ini bereits vorhanden!
		Gui 11:Destroy
		GoTo 11GuiNewProjectFile
		}
	else
		{
		SettingUpFiles(ProjectFileName)
		SettingUpCapture2Text()
		Gui 10:Destroy
		Send {F10}
		}
	}
return 

SettingUpFiles(ProjectFileName){
local
; Project
global PreloadList
global ProjectName := StrReplace(ProjectFileName, ".ini")
ListLines Off
ProjectFolder := ProjectName 
if !FileExist(ProjectFolder)
	FileCreateDir, %ProjectFolder%
global ProjectFile := ProjectFolder . "\" . ProjectFileName
; verschieben wenn in Workdir
if FileExist(ProjectFileName)
	{
	if !FileExist(ProjectFile)
		FileMove, ProjectFileName, ProjectFolder
	}

; TempFile
global TempFileName := ProjectName . "_Temp.ini"
global TempFile := ProjectFolder . "\" . TempFileName

; HistoryFile
global HistoryFileName := ProjectName . "_History" . A_YYYY .  A_MM . A_DD
global HistoryFile := ProjectFolder  . "\" . HistoryFileName . ".txt"

; PreloadListName
global PreloadListName := ProjectName . "_PreloadList.txt"
global PreloadListPath := ProjectFolder . "\" . PreloadListName
; Load PreloadList
if !FileExist(PreloadListPath)
	PreloadList := ""
else
	FileRead, PreloadList , %PreloadListPath%

; Save to TempFile
SaveIniValue(ProjectFile, "ProjectFiles", "e_TempFile", TempFileName)
SaveIniValue(ProjectFile, "ProjectFiles", "e_ProjectFile", ProjectFileName)

; Save To History
if (A_IsCompiled = 1)
	{
	SaveToHistory("Project File: ", ProjectFileName)
	SaveToHistory("Temp File: ", TempFileName)
	SaveToHistory("History File: ", HistoryFileName)
	}

; CurrentLFD 
global CurrentLFD := GetIniValue(ProjectFile, "ProjectFiles", "CurrentLFD", A_Space)
DeleteIniValue(ProjectFile, "ProjectFiles", "CurrentLFD")

Gui 11:Destroy
ListLines On
}	
