;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;   (F10) BASIC SETTINGS    ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F10::
ListLines Off
SetTitleMatchMode, 3
If WinExist(GuiF10)
	WinActivate, %GuiF10%
else
	Goto F10Routine
return

F10Routine:
SetTitleMatchMode, 2
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

; Change Button
if (10GuiChange = false)
	{
	BasicSettingsDis := DisON
	ChangeButtonName := "anpassen"
	GoButtonDis	:= DisOFF
	}
else
	{
	BasicSettingsDis := DisOFF
	ChangeButtonName := "Speichern"
	GoButtonDis	:= DisON
	}

; CACLCULATE POSITIONS
Gosub SetOCRPositions
AdjustPositions()

Gui, 10:+AlwaysOnTop Toolwindow
; INI Files
Gui, 10:Add, Groupbox, x10 y10 w260 h49 cNavy, Aktuelles Projekt
Gui, 10:Add, Text, x20 y32  w92  h20 , Projekt:
Gui, 10:Add, Edit, x65 	y29  w90  h20 Disabled, % StrReplace((GetIniValue(ProjectFile, "ProjectFiles", "e_ProjectFile")), ".ini")
;Gui, 10:Add, Text, x20 y54  w92  h20 , Fragenbibliothek:
;Gui, 10:Add, Edit, x105 	y51  w90  h20 Disabled , Library.ini
Gui, 10:Add, Button, x175  y27 w80  h20 g10GuiChangeBasicFile, ändern
; OCR Konfiguration
Gui, 10:Add, Groupbox, x10 y65 w260 h125 cNavy, Texterkennung konfigurieren
;;; Position fn Start
	;; Start X 
	Gui, 10:Add, Text, x45 y88  w35  h20 %BasicSettingsDis%, Pos X:
	Gui, 10:Add, Edit, x85 y85  w50  h20 %BasicSettingsDis% Center 
	Gui, 10:Add, UpDown,  Range0-400  ve_fnStartPosX , % e_fnStartPosX
	;; Start Y
	Gui, 10:Add, Text, x45 y110  w50  h20 %BasicSettingsDis%, Pos Y:
	Gui, 10:Add, Edit, x85 y107  w50  h20 %BasicSettingsDis% Center 
	Gui, 10:Add, UpDown,  Range0-400  ve_fnStartPosY, % e_fnStartPosY
; Position Länge/Breite 
	;; End Länge
	Gui, 10:Add, Text, x165 y88  w30  h20 %BasicSettingsDis%, Länge:
	Gui, 10:Add, Edit, x205 y85  w50  h20 %BasicSettingsDis%  Center
	Gui, 10:Add, UpDown,  Range0-400  ve_width, % e_width
	;; End Breite
	Gui, 10:Add, Text, x165 y110  w30  h20 %BasicSettingsDis%, Breite:
	Gui, 10:Add, Edit, x205 y107  w50  h20 %BasicSettingsDis%  Center 
	Gui, 10:Add, UpDown,  Range0-400 ve_height, % e_height
; Scale factor
Gui, 10:Add, Text, x20 y135  w60  h20 %BasicSettingsDis%, Scale factor:
Gui, 10:Add, Edit, x85 y133  w34  h20 %BasicSettingsDis% Center ve_scale, % e_scale 
; Buttons Test/Show/Hilfe
Gui, 10:Add, Button, x20 y160 w50 h20 g10GuiTestOCR, Test
Gui, 10:Add, Button, x75 y160 w50 h20 %BasicSettingsDis% g10GuiShowWindow, Show
Gui, 10:Add, Button, x195 y160 w60 h20 g10GuiHelp, Hilfe
; History
Gui, 10:Add, Groupbox, x10 y195 w260 h55 %PrivacyDis% cNavy, Logbuch Einstellungen
Gui, 10:Add, CheckBox, x20 y218 w130 h20 %PrivacyDis% Checked%CreateHistory% vCreateHistory, Logbuch erstellen
; Buttons
Gui, 10:Add, Button,   x10  y260 w55  h25 g10GuiResetControls, Reset
Gui, 10:Add, Button,   x70  y260 w70  h25 g10GuiChangeButton , % ChangeButtonName 
Gui, 10:Add, Button,   x190 y260 w80 h25 Default g10Go %GoButtonDis%, OK
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
if (A_GuiControl = "anpassen")
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
MsgBox, 4132, Reset? , %GuiF10% zurücksetzen? (Setzt Koordinaten auf Standardeinstellung)
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
if (GetKeyState("Shift") = 1)
	Goto ScaleFactorScan
Gui 1:Destroy
AlarmIfCapture2TextIsNotRunning()
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
		MsgBox, 4096, Testergebnis, %TestOCR% `n`nTipp: Die Fläche darf auch größer sein.
	else
		MsgBox, 4096, Testergebnis, %TestOCR%
	}
else
	{
	++OCRFailedCount
	if (OCRFailedCount = 1)
		MsgBox, 4096, Testergebnis , Texterkennung fehlgeschlagen.
	else
		MsgBox, 4096, Testergebnis, Texterkennung fehlgeschlagen. `n`nTipp: Bitte TeamViewer-Einstellungen überprüfen.
	}
return

ScaleFactorScan:
AlarmIfCapture2TextIsNotRunning()
CheckWorkWindow()
e_scaleStatus := e_scale
TestMessage := "Ergebnisse der Texterkennung (ohne Korrektur) `n`n"
e_scale := 3.5
Loop, 16 {
sleep, SleepAfterEnter
SaveIniValue(Capture2TextIniFileAppDataPath, "OCR", "ScaleFactor", e_scale)
TestOCR := OCR("ScaleFactorTest", 0)
TestMessage .= e_scale . ": " . TestOCR . "`n"
e_scale := e_scale + 0.1
e_scale := Round(e_scale, 1)
}
TestMessage .= "`n`n Die Texterkennungssoftware wird jetzt neu gestartet..."
MsgBox, 4096, Ergebnis Scale Factor Scan, % TestMessage
e_scale := e_scaleStatus
SaveIniValue(Capture2TextIniFileAppDataPath, "OCR", "ScaleFactor", e_scale)
CloseCapture2Text(Capture2TextPID)
WinSet, AlwaysOnTop, Off, %GuiF10%
SettingUpCapture2Text()
WinSet, AlwaysOnTop, On, %GuiF10%
return

; Save Input
10GuiSaveInput:
Gui, 10:Submit, NoHide
SaveScaleFactor()
if (PermanentSave = 1)
	{
	Msgbox, 4132, Dauerhaft Speichern?, Soll die aktuelle Konfiguration der Texterkennung dauerhaft gespeichert werden? 
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
	MsgBox, 4096, Scale Angabe korrigieren, Die Wert des Scale-Faktors muss zwischen 0.71 und 5 liegen! (Default: 3.5)
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
CTRL & LButton::
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

SetOCRPositions:
10GuiOCRPositions := ["e_fnStartPosX", "e_fnStartPosY", "e_width", "e_height"]
for i, control in 10GuiOCRPositions
	{
	%control% := GetIniValue(ProjectFile, BasicSettingsMenu, control)
	If (%control% = "ERROR")
		%control% := GetIniValue(BasicFile, BasicSettingsMenu, control, 0)
	}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;    Choose Project File    ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ChooseProjectFile:
ChooseProjectFileMenuName := " ProTest " . ProTestVersion
	
if WinExist(ChooseProjectFileMenuName)
	{
	WinActivate, %ChooseProjectFileMenuName%
	Exit
	}

FileList := CreateProjectFilesList()

if WinExist(GuiF10)
	NoActionButton := "Zurück"
else
	NoActionButton := "ProTest beenden"

Gui, 11:+AlwaysOnTop -SysMenu +MinimizeBox
Gui, 11:Add, Groupbox, x10 y5 w335 h115 cNavy, Projekt auswählen
gui, 11:add, listbox, x20 y28 w150 h85 vIniFileInList sort, % FileList
gui, 11:add, button, x185 y28 w150 g11GuiNewProjectFile, Neues Projekt erstellen
gui, 11:add, button, x185 y53 w150 Default g11GuiIniDecision, Auswahl bestätigen
gui, 11:add, button, x10 y128 w140 g11GuiNewProjectFile g11CheckforUpdates, Auf Updates prüfen
gui, 11:add, button, x205 y128 w140 g11GuiCancel, % NoActionButton
gui, 11:show, Center Autosize, %ChooseProjectFileMenuName%
return

11GuiClose:
11GuiEscape:
11GuiCancel:
Gui 11:Destroy
if (NoActionButton = "ProTest beenden")
	{
	Msgbox, 4096,ProTest, ProTest wird beendet!
	CloseCapture2Text(Capture2TextPID)
	ExitApp
	}
else 
	Exit
return

11CheckforUpdates:
Gosub UpdateProTest
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
	ProjectName := IniFileInList
	ProjectIniFileName := ProjectName . ".ini"
	SettingUpProTest(ProjectIniFileName, "Select")
	}
else
	Msgbox, 4096, Ups!, Kein Projekt ausgewählt!
return

11GuiNewProjectFile:
Gui +LastFound +OwnDialogs +AlwaysOnTop
InputBox, ProjectName, Projektname , Bitte einen Projektnamen vergeben (z.B. "B152"),, 250, 150
if (ErrorLevel)
	Exit
else
	{
	ProjectIniFileName := ProjectName . ".ini"
	if Instr(FileList, ProjectName, CaseSensitive := true)
		{
		Msgbox, 4096, Ups!, %ProjectName% bereits vorhanden!
		GoTo 11GuiNewProjectFile
		}
	else
		SettingUpProTest(ProjectIniFileName, "Create")
	}
return 

SettingUpFiles(ProjectIniFileName, Modus){
local
global BasicFile
global ProjectName := StrReplace(ProjectIniFileName, ".ini")
global IniParentFolderArray
global Privacy
ListLines Off

if (Modus = "Select")
	ProjectFolderPath := IniParentFolderArray[ProjectIniFileName]
else
	ProjectFolderPath := ProjectName
global ProjectFile := ProjectFolderPath . "\" . ProjectIniFileName

; Erstelle Projektordner
if !FileExist(ProjectFolderPath)
	FileCreateDir, %ProjectFolderPath%

; verschieben wenn in WorkingDir
if FileExist(ProjectIniFileName)
	{
	NewProjectFolderPath := ProjectFolderPath . "\" . ProjectName
	if !FileExist(NewProjectFolderPath)
		{
		MsgBox, 4132, Projekt integrieren?, Für das Projekt "%ProjectName%" existiert noch kein Projektordner. Soll für dieses Projekt ein der Projektordner "%ProjectName%" angelegt werden?
		IfMsgBox, Yes
			{
			FileCreateDir, %NewProjectFolderPath%
			FileMove, %ProjectIniFileName%, %NewProjectFolderPath%
			ProjectFolderPath := NewProjectFolderPath
			global ProjectFile := ProjectFolderPath . "\" . ProjectIniFileName
			}
		} ; ende if
	} ; ende if

; LFDSpeicher erstellen
global LFDSpeicherName := "LFDSpeicher_" . ProjectName . ".ini"
global LFDSpeicherPfad := ProjectFolderPath . "\" . LFDSpeicherName

; CleanUp
OldTempFilePath := ProjectFolderPath . "\" .ProjectName . "_Temp.ini"
if FileExist(OldTempFilePath)
	FileMove, %OldTempFilePath%, %LFDSpeicherPfad% 
CleanLFDSpeicher(LFDSpeicherPfad)

; HistoryFile
global HistoryFileName := "Logbuch_" . ProjectName . "_" . A_YYYY . "_" . A_MM . "_" . A_DD
if (Privacy = true)
	HistoryFileName := " kein LogBuch verfügbar"
global HistoryFile := ProjectFolderPath  . "\" . HistoryFileName . ".txt"

; PreloadList
global PreloadList
global PreloadListName := ProjectName . "_PreloadList.txt"
global PreloadListPath := ProjectFolderPath . "\" . PreloadListName
; Load PreloadList
if !FileExist(PreloadListPath)
	PreloadList := ""
else
	FileRead, PreloadList , %PreloadListPath%

; Save to ProjectFile
SaveIniValue(ProjectFile, "ProjectFiles", "e_LFDSpeicher", LFDSpeicherName)
SaveIniValue(ProjectFile, "ProjectFiles", "e_ProjectFile", ProjectIniFileName)

; Save To History
global CreateHistory := GetIniValue(BasicFile, "BasicSettingsMenu",  "c_History")
if (Privacy = true)
	global CreateHistory := 0
if (A_IsCompiled = 1)
	SaveToHistory("### Projekt: " . ProjectName . " ###")

; CurrentLFD
global LastUsedFile
global CurrentLFD := GetIniValue(ProjectFile, "ProjectFiles", "CurrentLFD")
if (CurrentLFD = "ERROR")
	CurrentLFD := ""
else
	{
	if (LastUsedFile = ProjectIniFileName)
		{
		MsgBox, 4132, LFD beibehalten?, ProTest wurde neu gestartet. Die letzte verwendete LFD war %CurrentLFD%. Ist dies auch die aktuelle LFD?
		IfMsgBox, Yes
			CurrentLFD := CurrentLFD
		else
			{
			CurrentLFD := ""
			DeleteIniValue(ProjectFile, "ProjectFiles", "CurrentLFD")
			}
		} ; ende if
	else
		DeleteIniValue(ProjectFile, "ProjectFiles", "CurrentLFD")
	}

; Set OCR Positions
Gosub SetOCRPositions
AdjustPositions()
ListLines On
}

CreateProjectFilesList(){
local
global BasicFile
global LastUsedFile := GetIniValue(BasicFile, "BasicSettingsMenu", "x_lastProjectFile")
global IniParentFolderArray := {}
FileList := ""
ExcludeIniFileArray := ["Capture2Text", "BasicSettings", "Fragenbibliothek", "LFDSpeicher", "Library", "_Temp", "PreloadDetails"]
IniLoop:
Loop, Files, *.ini, R
	{
	for i, IniFile in ExcludeIniFileArray
		{
		if instr(A_LoopFileName, IniFile)
			Continue IniLoop
		}
	; Priorisiere LastUsedFile, falls vorhanden
	IniFileName := StrReplace(A_LoopFileName, ".ini")
	if (LastUsedFile = A_LoopFileName)
		FileList .= IniFileName . "||"
	else
		FileList .= IniFileName . "|"
	; Add to IniParentFolderArray
	IniParentFolder := StrReplace(A_LoopFileLongPath, "\" . A_LoopFileName)
	IniParentFolderArray[A_LoopFileName] := IniParentFolder
	}
return FileList
}

;;; SETTING UP PROTEST ;;;

SettingUpProTest(ProjectIniFileName, Modus){
local
SettingUpFiles(ProjectIniFileName, Modus)
global BasicFile
global ProjectName
global WorkModus
Gui 11:Destroy
if (Modus = "Select")
	Msgbox, 4096, Projekt ausgewählt, Das Projekt %ProjectName% wurde erfolgreich ausgewählt.
else if (Modus = "Create")
	Msgbox, 4096, Projekt erstellt, Neues Projekt erstellt: %ProjectName%.
SettingUpCapture2Text()
if (WorkModus != "TestModus")
	SaveIniValue(BasicFile, "BasicSettingsMenu", "x_lastProjectFile", ProjectIniFileName)
}

SettingUpCapture2Text(){
local
global ConfigFolder
global Capture2TextWorkDir :=  A_ScriptDir . "\Capture2Text"
global Capture2TextAppDataFolder := A_AppData . "\Capture2Text"
global Capture2TextIniFileAppDataPath := Capture2TextAppDataFolder . "\Capture2Text.ini"

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
	; überschreibe wichtige Einstellungen
	SaveIniValue(Capture2TextIniFileAppDataPath, "Output", "OutputClipboard", "true")
	SaveIniValue(Capture2TextIniFileAppDataPath, "Output", "OutputPopup", "false")
	SaveIniValue(Capture2TextIniFileAppDataPath, "OCR", "Language", "German")
	SaveIniValue(Capture2TextIniFileAppDataPath, "OCR", "Whitelist", "")
	
	; deactivate other hotKeys
	SaveIniValue(Capture2TextIniFileAppDataPath, "HotKey", "BubbleCapture", "Win+<Unmapped>")
	SaveIniValue(Capture2TextIniFileAppDataPath, "HotKey", "ForwardTextLineCapture", "Win+<Unmapped>")
	SaveIniValue(Capture2TextIniFileAppDataPath, "HotKey", "Lang1", "Win+<Unmapped>")
	SaveIniValue(Capture2TextIniFileAppDataPath, "HotKey", "Lang2", "Win+<Unmapped>")
	SaveIniValue(Capture2TextIniFileAppDataPath, "HotKey", "Lang3", "Win+<Unmapped>")
	SaveIniValue(Capture2TextIniFileAppDataPath, "HotKey", "TextLineCapture", "Win+<Unmapped>")
	SaveIniValue(Capture2TextIniFileAppDataPath, "HotKey", "TextOrientation", "Win+<Unmapped>")
	}
else
	FileCopy, %ConfigFolder%\Capture2Text.ini, %Capture2TextIniFileAppDataPath%

; Start Capture2Text if not running
global Capture2TextPID
if (Capture2TextPID = 0) ; Capture2Text not running
	{
	Run, Capture2Text.exe , %Capture2TextWorkDir% ,, PID
	global Capture2TextPID := PID
	}
}