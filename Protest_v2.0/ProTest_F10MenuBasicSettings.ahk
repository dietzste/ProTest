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
OCRFailedCount := 0
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

e_scaleBasic 	:= GetIniValue(BasicFile, BasicSettingsMenu, "e_scale")
e_scale 		:= GetIniValue(ProjectFile, BasicSettingsMenu, "e_scale", e_scaleBasic)
CreateHistory := GetIniValue(BasicFile, BasicSettingsMenu, "c_History")

10GuiOCRPositions := ["e_fnStartPosX", "e_fnStartPosY", "e_width", "e_height"]
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
	ChangeButtonName := "�ndern"
	GoButtonDis	:= DisOFF
	}
else
	{
	BasicSettingsDis := DisOFF
	ChangeButtonName := "Speichern"
	GoButtonDis	:= DisON
	}

; CACLCULATE POSITIONS
AdjustPositions()

Gui, 10:+AlwaysOnTop
; INI Files
Gui, 10:Add, Groupbox, x10 y10 w260 h73 cNavy, Ini Files
Gui, 10:Add, Text, x20 y32  w92  h20 , Project File:
Gui, 10:Add, Edit, x85 	y29  w90  h20 Disabled, % GetIniValue(ProjectFile, "ProjectFiles", "e_ProjectFile")
Gui, 10:Add, Text, x20 y54  w92  h20 , Library File:
Gui, 10:Add, Edit, x85 	y51  w90  h20 Disabled , Library.ini
Gui, 10:Add, Button, x205  y27 w50  h20 g10GuiChangeBasicFile, �ndern
; OCR Konfiguration
Gui, 10:Add, Groupbox, x10 y85 w260 h125 cNavy, OCR Konfiguration
;;; Position fn Start
	;; Start X 
	Gui, 10:Add, Text, x45 y108  w35  h20 %BasicSettingsDis%, Pos X:
	Gui, 10:Add, Edit, x85 y105  w50  h20 %BasicSettingsDis% Center 
	Gui, 10:Add, UpDown,  Range0-400  ve_fnStartPosX , % e_fnStartPosX
	;; Start Y
	Gui, 10:Add, Text, x45 y130  w50  h20 %BasicSettingsDis%, Pos Y:
	Gui, 10:Add, Edit, x85 y127  w50  h20 %BasicSettingsDis% Center 
	Gui, 10:Add, UpDown,  Range0-400  ve_fnStartPosY, % e_fnStartPosY
; Position L�nge/Breite 
	;; End L�nge
	Gui, 10:Add, Text, x165 y108  w30  h20 %BasicSettingsDis%, L�nge:
	Gui, 10:Add, Edit, x205 y105  w50  h20 %BasicSettingsDis%  Center
	Gui, 10:Add, UpDown,  Range0-400  ve_width, % e_width
	;; End Breite
	Gui, 10:Add, Text, x165 y130  w30  h20 %BasicSettingsDis%, Breite:
	Gui, 10:Add, Edit, x205 y127  w50  h20 %BasicSettingsDis%  Center 
	Gui, 10:Add, UpDown,  Range0-400 ve_height, % e_height
; Scale factor
Gui, 10:Add, Text, x20 y155  w60  h20 %BasicSettingsDis%, Scale factor:
Gui, 10:Add, Edit, x85 y153  w34  h20 %BasicSettingsDis% Center ve_scale, % e_scale 
; Buttons Test/Show/Hilfe
Gui, 10:Add, Button, x20 y180 w50 h20 g10GuiTestOCR, Test
Gui, 10:Add, Button, x75 y180 w50 h20 %BasicSettingsDis% g10GuiShowWindow, Show
Gui, 10:Add, Button, x195 y180 w60 h20 g10GuiHelp, Hilfe
; History
Gui, 10:Add, Groupbox, x10 y215 w260 h55 cNavy, History Einstellungen
Gui, 10:Add, CheckBox, x20 y238 w130 h20 Checked%CreateHistory% %BasicSettingsDis% vCreateHistory, History erzeugen
; Buttons
Gui, 10:Add, Button,   x10  y280 w55  h25 g10GuiResetControls, Reset
Gui, 10:Add, Button,   x70  y280 w70  h25 g10GuiChangeButton , % ChangeButtonName 
Gui, 10:Add, Button,   x190 y280 w80 h25 Default g10Go %GoButtonDis%, OK
Gui, 10:Show, x850 y480 Autosize Center, %GuiF10%
Return

10GuiClose:
10GuiEscape:
10Go:
Gui 1:Destroy
if (ChangeButtonName = "Speichern")
	{
	MsgBox, 4132, Speichern?, Angaben Speichern?
	IfMsgBox, Yes
		GoSub 10GuiSaveInput
	}
Gui 10:Destroy
Gui 11:Destroy
ListLines On
return

10GuiChangeButton:
Gui 1:Destroy
if (A_GuiControl = "�ndern")
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

10GuiChangeBasicFile:
Gosub 10GuiSaveInput
GoSub ChooseProjectFile
return 

10GuiResetControls:
MsgBox, 4132, Reset? , %GuiF10% zur�cksetzen? (Setzt Koordinaten auf Standardeinstellung)
IfMsgBox, YES
	{
	Gui 10:Destroy
	10GuiReset := true
	Goto 10GuiSetControls
	}
return 

10GuiHelp:
ShowHelpWindow(GuiF10)
return 

10GuiTestOCR:
Gui 1:Destroy
CheckCapture2TextIsRunning()
CheckWorkWindow()
Gui, 10:Submit, NoHide
AdjustPositions()
SaveScaleFactor()
TestOCR := OCR("Test", 0)
Sleep, 500
WinGetPos , XPOS, YPOS, Width ,  Height , %GuiF10%
MouseMove, Width / 2, Height / 2, 0
if (TestOCR != "")
	{
	; Calculate Show area
	ShowArea := e_width*e_height
	if (ShowArea < 400)
		MsgBox, 4096, Test OCR, %TestOCR% `n`nTipp: Die Fl�che darf auch gr��er sein.
	else
		MsgBox, 4096, Test OCR, %TestOCR%
	}
else
	{
	++OCRFailedCount
	if (OCRFailedCount = 1)
		MsgBox, 4096, Test OCR, OCR Failed.
	else
		MsgBox, 4096, Test OCR, OCR Failed. `n`nTipp: �berpr�fe die TeamViewer-Einstellungen
	}
return


; Save Input
10GuiSaveInput:
Gui, 10:Submit, NoHide
SaveScaleFactor()
if (PermanentSave = 1)
	{
	Msgbox, 4132, Dauerhaft Speichern?, Soll die aktuelle OCR-Konfiguration dauerhaft gespeichert werden? 
	IfMsgBox, YES
		PermanentSave = 1
	else
		PermanentSave = 0
	}

SaveIniValue(ProjectFile, BasicSettingsMenu, "e_scale", e_scale)
SaveIniValue(BasicFile, BasicSettingsMenu, "c_History", CreateHistory)
if (PermanentSave = 1)
	SaveIniValue(BasicFile, BasicSettingsMenu, "e_scale", e_scale)

for i, control in 10GuiOCRPositions
	{
	SaveIniValue(ProjectFile, BasicSettingsMenu, control, %control%)
	if (PermanentSave = 1)
		SaveIniValue(BasicFile, BasicSettingsMenu, control, %control%)
	}
return

; save e_scale
SaveScaleFactor(){
local
global Capture2TextIniFileAppDataPath, e_scale
if (e_scale < 0.71 Or e_scale > 5.0)
	{
	MsgBox, 4096, Scale Angabe korrigieren, Die Wert muss zwischen 0.71 und 5 liegen! (Default: 3.5)
	Exit
	}
else
	{
	e_scale := StrReplace(e_scale, ",", ".")
	SaveIniValue(Capture2TextIniFileAppDataPath, "OCR", "ScaleFactor", e_scale)
	}
}

10GuiShowWindow:
Gui, 10:Submit, NoHide
CheckWorkWindow()
AdjustPositions()
WinGetPos , XPOS, YPOS,,, %WorkWindow%
TestPosX	:= e_fnStartPosX + XPOS
TestPosY	:= e_fnStartPosY + YPOS
TestWidth	:= 0.75 * e_width
TestHeight	:= 0.75 * e_height
ShowWindowName := "ShowOCRWindow"
Gui  1:Destroy
; LastFound -> for WinSet
Gui, 1: -Caption +AlwaysOnTop +LastFound -Border +Owner ; kein Effekt: -SysMenu
Gui, 1: Color, 60CFF7
Gui, 1:show,x%TestPosX% y%TestPosY% w%TestWidth% h%TestHeight%, % ShowWindowName
WinSet, Transparent, 120, %ShowWindowName%
WinActivate, %WorkWindow%
return

#if WinExist("ShowOCRWindow")
~x::
WinActivate, %WorkWindow%
CoordMode, Mouse , Window
MouseGetPos , MousePosX, MousePosY
Gui  1:Destroy
Gui, 10:Default
GuiControl,, e_fnStartPosX , %MousePosX%
GuiControl,, e_fnStartPosY , %MousePosY%
Goto 10GuiShowWindow
return

~Escape::
Gui  1:Destroy
return 

~Left::
Gui  1:Destroy
Gui, 10:Default
GuiControl,, e_width , % e_width-10
Goto 10GuiShowWindow
return

~Right::
Gui  1:Destroy
Gui, 10:Default
GuiControl,, e_width , % e_width+10
Goto 10GuiShowWindow
return

~Up::
Gui  1:Destroy
Gui, 10:Default
GuiControl,, e_height , % e_height-10
Goto 10GuiShowWindow
return

~Down::
Gui  1:Destroy
Gui, 10:Default
GuiControl,, e_height , % e_height+10
Goto 10GuiShowWindow
return
#if 


; CACLCULATE POSITIONS
AdjustPositions(){
global e_width, e_height
global e_fnStartPosX, e_fnStartPosY
global e_fnEndPosX := e_fnStartPosX + e_width
global e_fnEndPosY := e_fnStartPosY + e_height
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;    Choose Project File    ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ChooseProjectFile:
ChooseProjectFileMenuName := "Projektdatei ausw�hlen..."
	
if WinExist(ChooseProjectFileMenuName)
	{
	WinActivate, %ChooseProjectFileMenuName%
	Exit
	}

FileList := CreateProjectFilesList()

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
gui, 11:show, Center Autosize, %ChooseProjectFileMenuName%
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
	if (A_UserName != "Mensch")
		SaveIniValue(BasicFile, "BasicSettingsMenu", "x_lastProjectFile", ProjectFileName)
	SettingUpProTest(ProjectFileName)
	}
else
	Msgbox, 4096, Ups!, Kein File ausgew�hlt!
return

11GuiNewProjectFile:
Gui +LastFound +OwnDialogs +AlwaysOnTop
InputBox, ProjectName, Projektname , Bitte einen Projektnamen vergeben (z.B. "B152"),, 250, 150
if (ErrorLevel)
	Exit
else
	{
	ProjectFileName := ProjectName . ".ini"
	if Instr(FileList, ProjectFileName)
		{
		Msgbox, 4096, Ups!, %ProjectFileName% bereits vorhanden!
		GoTo 11GuiNewProjectFile
		}
	else
		{
		SettingUpProTest(ProjectFileName)
		}
	}
return 

SettingUpFiles(ProjectFileName){
local
global BasicFile
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

; PreloadList
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
global CreateHistory := GetIniValue(BasicFile, "BasicSettingsMenu",  "c_History")
if (A_IsCompiled = 1)
	SaveToHistory("### Project File: ", ProjectFileName . " ###")

; CurrentLFD 
global CurrentLFD := GetIniValue(ProjectFile, "ProjectFiles", "CurrentLFD", A_Space)
DeleteIniValue(ProjectFile, "ProjectFiles", "CurrentLFD")

ListLines On
}

CreateProjectFilesList(){
local
global BasicFile
global LastUsedFile := GetIniValue(BasicFile, "BasicSettingsMenu", "x_lastProjectFile")
FileList := ""
ExcludeIniFileArray := ["Capture2Text", "BasicSettings", "Library", "_Temp", "PreloadDetails"]
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
return FileList
}

;;; SETTING UP PROTEST ;;;

SettingUpProTest(ProjectFileName){
local
SettingUpFiles(ProjectFileName)
Gui 11:Destroy
SettingUpCapture2Text()
Gui 10:Destroy
Send {F10}
}

SettingUpCapture2Text(){
local
global ConfigFolder
global Capture2TextWorkDir :=  A_ScriptDir . "\Capture2Text"
global Capture2TextAppDataFolder := A_AppData . "\Capture2Text"
global Capture2TextIniFileAppDataPath := Capture2TextAppDataFolder . "\Capture2Text.ini"
global Capture2TextStarted := false

if !FileExist(Capture2TextWorkDir)
	{
	Msgbox,4096, Ups!, %Capture2TextWorkDir% existiert nicht!
	ExitApp
	}

; Setting up AppData Folder
if !FileExist(Capture2TextAppDataFolder)
	FileCreateDir, %Capture2TextAppDataFolder%
; Setting up Ini-File
if FileExist(Capture2TextIniFileAppDataPath)
	{
	; �berschreibe wichtige Einstellungen
	SaveIniValue(Capture2TextIniFileAppDataPath, "Output", "OutputClipboard", "true")
	SaveIniValue(Capture2TextIniFileAppDataPath, "Output", "OutputPopup", "false")
	}
else
	FileCopy, %ConfigFolder%\Capture2Text.ini, %Capture2TextIniFileAppDataPath%

Process, Exist , Capture2Text.exe
if (ErrorLevel = 0) ; Capture2Text not running
	{
	Run, Capture2Text.exe , %Capture2TextWorkDir% ,, PID
	global Captur2TextPID := PID
	}
else
	{
	; Captur2Text is running, ErrorLevel enth�lt PID
	global Captur2TextPID := ErrorLevel
	}
Capture2TextStarted := true
}