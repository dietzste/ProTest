#Warn
#NoEnv
SetWorkingDir %A_ScriptDir%

SetTitleMatchMode, 2
; 1 = wintitle muss mit Titel beginnen
; 2 = wintitle muss Titel irgendwo enthalten
; 3 = exakte bereinstimmung

; FileManagement
ConfigFolder := A_ScriptDir . "\Config"
BasicFile := ConfigFolder . "\BasicSettings.ini"
UpdateLogFile := "UpdateLog_" . A_YYYY .  A_MM . A_DD . ".txt"
UpdateTimeStemp :=  A_DD . "." . A_MM . "." . A_YYYY

;;; UPDATE CONTROL ;;;

OverwriteKeysAnywayArray := { 1: "Version"
, 2: "TimeOutMsgLFDMatch"
, 3: "TimeOutMsgSkippedIntro"
, 4: "TimeOutRemoteTest"
, 5: "290102"
, 6: "SleepAfterEnter"}

OverwriteValuesArray := { 1: "IntroGetSex"
, 2: "IntroSexReversed"
, 3: "IntroGetDateOfBirth"
, 4: "p73170yPRE"
, 5: "name_apPRE"}

;;; Ende AutoSection ;;;

; (E1) Error Handling - Checking File Location
if (A_IsCompiled = 1) 
	ProTestProgram := "ProTest_v2.0.exe"
else
	{
	ProTestProgram := "ProTest__v2_Local.ahk"
	if !FileExist(ProTestProgram)
		ProTestProgram := "ProTest_v2.0.exe"
	}
if !FileExist(ProTestProgram)
	{
	SaveToUpdateLog("ABBRUCH: " . ProTestProgram . "nicht vorhanden")
	MsgBox, 4096, Update Error, Die Datei %ProTestProgram% befindet sich nicht im Verzeichnis!
	ExitApp
	}

; (E2) Error Handling - Exit ProTestProgramm
ProTestWasRunning := ExitProTestProgramm(ProTestProgram)

; (1) Checking Latest Version
CurrentVersion := GetIniValue(BasicFile, "ProTestVersion", "Version")
LatestVersion := GetCurrentVersion()
ForceUpdate := GetIniValue(BasicFile, "ProTestVersion", "ForceUpdate")
if (ForceUpdate = "true")
	{
	DeleteIniValue(BasicFile, "ProTestVersion", "ForceUpdate")
	Goto UpdateProcedure
	}
if (CurrentVersion = "ERROR")
	{
	SaveToUpdateLog("Vorhandene Version: < v2.05 ")
	Goto UpdateProcedure
	}
else
	{
	if (CurrentVersion = LatestVersion)
		{
		; 1. AbbruchKriterium 
		Msgbox, 4096, Update , ProTest ist auf dem neusten Stand! (Version: %CurrentVersion%)
		;SaveToUpdateLog("ProTest ist auf dem neusten Stand (" . LatestVersion . ")")
		RunProTest(ProTestProgram)
		ExitApp
		}
	else
		{
		SaveToUpdateLog("Neuste Version: " . LatestVersion)
		SaveToUpdateLog("Vorhandene Version: " . CurrentVersion)
		Goto UpdateProcedure
		}
	}
return 

; (2) Update Procedure
UpdateProcedure:
if (ForceUpdate = "true")
	{
	Hard := 1
	Soft := 0
	Title := "Force Update to " . LatestVersion
	}
else
	{
	Hard := 0
	Soft := 1
	Title := "Update to " . LatestVersion
	}
	
; Menu
Gui, 21: +AlwaysOnTop ToolWindow
Gui, 21:Add, Radio, x12 y10 w160 h20 Checked%Hard% vr_UpdateHard, alle Dateien überschreiben
Gui, 21:Add, Radio, x12 y35 w170 h20 Checked%Soft% vr_UpdateSoft, nur Neuerungen übernehmen
Gui, 21:Add, Button, x60 y65 w60 h25 Default gGui21Update, Update
Gui, 21:Show, Autosize Center, %Title%
return

21GuiClose:
21GuiEscape:
Gui 21:Destroy
Msgbox, 4132, Abbruch?, Update abbrechen?
IfMsgBox, YES
	{
	; 2. AbbruchKriterium 
	SaveToUpdateLog("Update abgebrochen")
	RunProTest(ProTestProgram)
	ExitApp
	}
else
	Goto UpdateProcedure
return

Gui21Update:
Gui 21:Submit, NoHide
if (r_UpdateHard = 1)
	{
	UpdateClaim := "und dabei alle Dateien überschreiben"
	UpdateModus := "Hard"
	}
if (r_UpdateSoft = 1)
	{
	UpdateClaim := "und Neuerungen übernehmen"
	UpdateModus := "Soft"
	}
MsgBox, 4132, Update to %LatestVersion%?, Update von ProTest jetzt durchführen %UpdateClaim%?
IfMsgBox, YES
	{
	; (3) DOWNLOAD LATEST Version
	Gui 21:Destroy
	SaveToUpdateLog("Download Latest Version (" . LatestVersion . ")")
	SaveToUpdateLog("UpdateModus: " . UpdateModus)
	WaitingProcessWindow(LatestVersion, "Lade neuste Version")
	DownloadLatestVersion(LatestVersion)
	WaitingProcessWindow(LatestVersion, "zip-Datei entpacken")
	UnzipFile(UpdateModus)
	if (UpdateModus = "Soft")
		Goto SoftUpdate
	if (UpdateModus = "Hard")
		{
		SaveToUpdateLog("Alle Dateien ersetzt")
		SaveToUpdateLog("Update auf Version " . LatestVersion . " abgeschlossen!")
		Gosub 15GuiClose
		MsgBox, 4096, Update erfolgreich!, Update auf Version %LatestVersion% abgeschlossen!
		RunProTest(ProTestProgram)
		ExitApp
		}
	} ; Ende MsgBox
else
	{
	return 
	}
return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

; (4) Soft Update
Softupdate:
; (4.1) Compare Files
FilestoCompareCount := CompareFiles()
SaveToUpdateLog(FilestoCompareCount . " ini-Datei(en) unterschiedlich")
; (4.2) Update Changes
WaitingProcessWindow(LatestVersion, "Vergleiche ini-Dateien")
For Index, Filename in CompareFilesArray
	{
	OldFile := ConfigFolder . "\" . Filename
	Newfile := UpdateFolderPath . "\Config\" . Filename
	SaveToUpdateLog( Index . "/" . FilestoCompareCount .  " ### Update " . Filename . " ###")
	if (Filename = "Capture2Text.ini")
		{
		FileCopy, %Newfile%, %OldFile%, 1
		Continue
		}
	CompareIniSections(OldFile, NewFile)
	}
SaveToUpdateLog("Update auf Version " . LatestVersion . " abgeschlossen!")
WaitingProcessWindow(LatestVersion, "Überschreibe exe-Dateien")
OverwriteExeFiles()
WaitingProcessWindow(LatestVersion, "Entferne Update-Ordner")
FileRemoveDir, %UpdateFolderPath% , 1
Gosub 15GuiClose
MsgBox, 4096, Update erfolgreich!, Update auf Version %LatestVersion% abgeschlossen!
RunProTest(ProTestProgram)
ExitApp
return 

;;;;;; SOFT UPDATE FUNCTIONS ;;;;;;;;;;

CompareFiles(){
local
global ConfigFolder
global UpdateFolderPath
global CompareFilesArray := []
FilesCount := 0
Loop, Files, %UpdateFolderPath%\Config\*.ini
	{
	UpdateFile := UpdateFolderPath . "\Config\" . A_LoopFileName
	OldFile := ConfigFolder . "\" . A_LoopFileName
	if Instr(OldFile, "BasicSettings")
		{
		DeleteOldSettings()
		CompareFilesArray[++FilesCount] := A_LoopFileName
		Continue
		}
	DeleteOldIniSections(OldFile)
	FileGetSize, UpdateSize , %UpdateFile%
	FileGetSize, InstalledSize, %OldFile%
	if (UpdateSize != InstalledSize)
		{
		CompareFilesArray[++FilesCount] := A_LoopFileName
		if (InstalledSize = "")
			{
			FileCopy, %UpdateFile%, %OldFile%
			SaveToUpdateLog("Neue Datei: " . A_LoopFileName)
			}
		}
	} ; ende Loop
return CompareFilesArray.Count()
}

OverwriteExeFiles(){
local
global UpdateFolderPath
ProTestExeFiles := ["ProTest_v2.0.exe", "ProTest_v2.0_RemoteClient.exe"]
For i, ExeFile in ProTestExeFiles
	{
	NewFile := UpdateFolderPath . "\" . ExeFile
	FileCopy, %NewFile%, %ExeFile%, 1
	}
}

CompareIniSections(OldFile, NewFile){
local
; Get Ini-Section-List
OldSectionList := GetIniSectionNames(Oldfile)
NewSectionList := GetIniSectionNames(Newfile)
Loop, Parse, NewSectionList , "`n"
	{
	; Compare Sections
	CurrentSection := A_LoopField
	; Abschnitt vorhanden?
	if !Instr(OldSectionList, CurrentSection)
		{
		; Neuer Abschnitt
		CopySection(OldFile, NewFile, CurrentSection)
		}
	else
		{
		; Abschnitt bereits vorhanden
		; Load Sections
		NewSectionKeys := GetIniSection(NewFile, CurrentSection)
		OldSectionKeys := GetIniSection(OldFile, CurrentSection)
		; Abschnitte gleich?
		if (NewSectionKeys = OldSectionKeys)
			{
			; gleiche Abschnitte
			Continue
			}
		if (NewSectionKeys != OldSectionKeys)
			{
			; unterschiedliche Abschnitte
			CompareIniKeys(OldFile, NewFile, CurrentSection, NewSectionKeys, OldSectionKeys)
			}
		}
	} ; ende loop
} ; ende function

CompareIniKeys(OldFile, NewFile, CurrentSection, NewSectionKeys, OldSectionKeys){
local
global UpdateTimeStemp
NewKeyEntry := false
; Zeilen des Abschnitts untersuchen
Loop, Parse, NewSectionKeys , "`n"
	{
	CurrentLine := A_LoopField
	if Instr(OldSectionKeys, CurrentLine)
		{
		; identische Eintragung
		Continue
		}
	if !Instr(OldSectionKeys, CurrentLine)
		{
		; Unterschiedliche Eintragung
		CurrentNewKey := GetCleanKey(CurrentLine)
		IniRead, OldCompleteValue, %OldFile%, %CurrentSection%, %CurrentNewKey%
		IniRead, NewCompleteValue, %NewFile%, %CurrentSection%, %CurrentNewKey%
		; Vergleich mit altem File
		if (OldCompleteValue = "ERROR")
			{
			; Neuer Key
			if (NewKeyEntry = false)
				{
				; ersten neuen Eintrag mit Abstand einfügen
				SaveIniValue(OldFile, CurrentSection, "`n;;; Update " . UpdateTimeStemp . "`nUpdate", "Update")
				NewKeyEntry := true 
				}
			; (weiterer) neuer Key
			IniWrite, %NewCompleteValue%, %OldFile%, %CurrentSection%, %CurrentNewKey%
			SaveToUpdateLog("NEU: [" . CurrentSection . "] " . CurrentNewKey . " = " . NewCompleteValue)
			if (NewKeyEntry = true)
				DeleteIniValue(OldFile, CurrentSection, "Update")
			}
		else
			{
			; andere Eintragung vorhanden
			ChangeKeyEntry(OldFile, NewFile, CurrentSection, CurrentNewKey, OldCompleteValue, NewCompleteValue)
			} ; ende else
		} ; ende if
	} ; ende loop
} ; ende 
; Veränderter Eingabewert

ChangeKeyEntry(OldFile, NewFile, CurrentSection, CurrentNewKey, OldCompleteValue, NewCompleteValue){
local
global OverwriteKeysAnywayArray
global OverwriteValuesArray
global UpdateTimeStemp
ValueOverwritten := false
; Veränderter Eingabewert
NewValue := GetIniValue(NewFile, CurrentSection, CurrentNewKey)
OldValue := GetIniValue(OldFile, CurrentSection, CurrentNewKey)
if (OldValue = NewValue)
	return 
else
	{
	; Eingabewerte sind nicht gleich, Eingabewerte ändern/löschen falls...
	; a) Key in OverwriteKeysAnywayArray
	For i, ChangeKey in OverwriteKeysAnywayArray
		{
		if (ChangeKey = CurrentNewKey)
			{
			;Change Key Value
			NewCompleteValue := NewCompleteValue . " `; (Update " . UpdateTimeStemp . ")" 
			IniWrite, %NewCompleteValue%, %OldFile%, %CurrentSection%, %CurrentNewKey%
			SaveToUpdateLog("Geändert: [" . CurrentSection . "] " . CurrentNewKey . " = " . NewCompleteValue)
			ValueOverwritten := true
			}
		}
	; b) geänderte Eingabewerte
	For i, ChangeValue in OverwriteValuesArray  
		{
		if (ChangeValue = OldValue)
			{
			NewCompleteValue := A_Space . StrReplace(OldCompleteValue, OldValue , NewValue)
			IniWrite, %NewCompleteValue%, %OldFile%, %CurrentSection%, %CurrentNewKey%
			SaveToUpdateLog("Geändert: [" . CurrentSection . "] " . CurrentNewKey . " = " . NewValue . " (vorher: " . OldValue . ")")
			ValueOverwritten := true
			}
		} ; ende for loop
	if (ValueOverwritten = false)
		SaveToUpdateLog("Eigene Eintragung: [" . CurrentSection . "] " . CurrentNewKey . " = " . OldValue . " (ursprünglich: " . NewValue . ")")
	} ; ende else
} ; ende function

CopySection(OldFile, NewFile, Section){
local
NewSectionKeys := GetIniSection(NewFile, Section)
SaveToUpdateLog("Neuer Abschnitt: [" . Section . "]")
Loop, Parse, NewSectionKeys , "`n"
	{
	CurrentLine := A_LoopField
	CurrentNewKey := Substr(CurrentLine, 1, Instr(CurrentLine, "=")-1)
	IniRead, CurrentNewCompleteValue, %NewFile%, %Section%, %CurrentNewKey%
	IniWrite, %CurrentNewCompleteValue%, %OldFile%, %Section%, %CurrentNewKey% 
	SaveToUpdateLog("NEU: [" . Section . "] " . CurrentNewKey . " = " . CurrentNewCompleteValue)
	} ; ende loop
} ; ende function

GetCleanKey(CurrentLine){
local
CurrentKey := Substr(CurrentLine, 1, Instr(CurrentLine, "=")-1)
if Instr(CurrentKey, A_Space)
	CurrentKey := StrReplace(CurrentKey, A_Space)
if Instr(CurrentKey, A_Tab)
	CurrentKey := StrReplace(CurrentKey, A_Tab)
return CurrentKey
}


DeleteOldIniSections(FilePath){
local 
if Instr(FilePath, "Library.ini")
	{
	DeleteIniSection(FilePath, "Converter")
	DeleteIniSection(FilePath, "h_S3SHP")
	DeleteIniSection(FilePath, "P41599PRE")
	DeleteIniSection(FilePath, "P41598PRE")
	DeleteIniSection(FilePath, "h_Erstbefragte")
	DeleteIniSection(FilePath, "P41037PRE")
	DeleteIniSection(FilePath, "P41601PRE")
	DeleteIniSection(FilePath, "h_eingeschult")
	DeleteIniSection(FilePath, "h_Anzahl_Geschwister_HH")
	}
if Instr(FilePath, "BasicSettings.ini")
	DeleteIniSection(FilePath, "PositionParameterF10")
}

; (0) Deleting Old Sections/Keys
DeleteOldSettings(){
global BasicFile
DeleteIniValue(BasicFile, "ChangableSettings", "MsgDurationLFDMatch")
DeleteIniValue(BasicFile, "ChangableSettings", "MsgDurationSkippedIntro")
DeleteIniValue(BasicFile, "ChangableSettings", "CreateHistory")
DeleteIniValue(BasicFile, "AdvancedSettings", "CreatHistory")
DeleteIniValue(BasicFile, "BasicSettingsMenu", "e_Input1")
DeleteIniValue(BasicFile, "BasicSettingsMenu", "e_Input2")
DeleteIniValue(BasicFile, "BasicSettingsMenu", "e_Input3")
DeleteIniValue(BasicFile, "BasicSettingsMenu", "e_BirthDay")
DeleteIniValue(BasicFile, "BasicSettingsMenu", "e_BirthMonth")
DeleteIniValue(BasicFile, "BasicSettingsMenu", "e_BirthYear")
DeleteIniValue(BasicFile, "BasicSettingsMenu", "e_sex")
DeleteIniValue(BasicFile, "BasicSettingsMenu", "c_dependent")
}

;;;;;;;;;;;;;;;;;;;
;;;; UpdateLog ;;;;
;;;;;;;;;;;;;;;;;;;

SaveToUpdateLog(Info){
local
UpdateLogFile := "UpdateLog_" . A_YYYY .  A_MM . A_DD . ".txt"
TimeStemp := A_DDD . A_Space . A_DD . "." A_MMM . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec 
UpdateLog := TimeStemp . A_Space . Info
FileAppend, %UpdateLog%`n, %UpdateLogFile%
}

;;;;;;;;;;;;;;;;;;;;;;;;
;;      HotKeys       ;;
;;;;;;;;;;;;;;;;;;;;;;;;

; HotKeys
#if WinExist("Notepad++")
F5::
Send, ^S
Reload
return
#if

^!u::
SaveIniValue(Basicfile, "ProTestVersion", "ForceUpdate", "true")
Reload
return

RunProTest(ProTestProgram){
global ProTestWasRunning
if (ProTestWasRunning = true)
	{
	Process, Exist , %ProTestProgram%
	if (ErrorLevel = 0) ; ProTest not running
		Run, %ProTestProgram%
	}
}

WaitingProcessWindow(LatestVersion, Status){
local
Gui 15:Destroy
Gui, 15: -Caption +AlwaysOnTop -SysMenu +Border
Gui, 15:Font, s15, Verdana
Gui, 15:Add, Text,Center, Update wird durchgeführt
Gui, 15:Font, s9 Italic, Verdana
Gui, 15:Add, Text, w250 Center, %Status%...
Gui, 15:Show, Autosize Center, Update to %LatestVersion%
return
}

15GuiClose:
15GuiEscape:
Gui 15:Destroy
return 

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Internet Functions ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

GetCurrentVersion(){
local
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", "https://github.com/dietzste/ProTest/releases/latest", true)
whr.Send()
; Using 'true' above and the call below allows the script to remain responsive.
whr.WaitForResponse()
htmlText := whr.ResponseText
StartPosString := "https://github.com/dietzste/ProTest/commits/"
EndPosString := ".atom"
StartPos := Instr(htmlText, StartPosString) + Strlen(StartPosString)
EndPos := Instr(htmlText, EndPosString)
StrLength := EndPos - StartPos
Version := Substr(htmlText, StartPos, StrLength) 
return Version
}

DownloadLatestVersion(LatestVersion){
local
; Download ZipFile
global UpdateFolderName := "ProtestUpdate_" . LatestVersion 
global ZipFile := A_WorkingDir . "\" . UpdateFolderName . ".zip"
URL :=  "https://github.com/dietzste/ProTest/releases/download/" . LatestVersion . "/ProTest_" . LatestVersion . ".zip"
UrlDownloadToFile, %URL%, %ZipFile%
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Include Functions

#Include Protest_IniFunctions.ahk

;;; Other Functions

UnzipFile(UpdateModus){
local
global ZipFile
global UpdateFolderName
; Unzip (depending on UpdateModus)
if (UpdateModus = "Hard")
	global UpdateFolderPath := A_WorkingDir
if (UpdateModus = "Soft")
	{
	global UpdateFolderPath := A_WorkingDir . "\" . UpdateFolderName
	FileCreateDir, %UpdateFolderPath%
	}
shell := ComObjCreate("Shell.Application")
Folder := shell.NameSpace(ZipFile)
NewFolder := shell.NameSpace(UpdateFolderPath)
NewFolder.CopyHere(Folder.items, 4|16)

; Delete ZipFile
FileDelete, %ZipFile%
} ; Ende UnzipFile


ExitProTestProgramm(ProTestProgram){
local 
if (ProTestProgram = "ProTest_v2.0.exe")
	{
	Process, Exist , %ProTestProgram%
	if (ErrorLevel != 0) ; ProTest running
		{
		Process, Close, %ProTestProgram%
		if (ErrorLevel = 0)
			{
			MsgBox, 4096, Update Error, Kann %ProTestProgram% nicht schließen!
			Exit 
			}
		return ProTestWasRunning := true
		}
	}	
else
	{
	if WinExist(ProTestProgram)
		{
		WinWaitClose %ProTestProgram%
		if (ErrorLevel = 0)
			{
			MsgBox, 4096, Update Error, Kann %ProTestProgram% nicht schließen!
			Exit 
			}
		return ProTestWasRunning := true
		}
	}
return ProTestWasRunning := false
} ; ende function 