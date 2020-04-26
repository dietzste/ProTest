#Warn
#NoEnv
SetWorkingDir %A_ScriptDir%

SetTitleMatchMode, 2
; 1 = wintitle muss mit Titel beginnen
; 2 = wintitle muss Titel irgendwo enthalten
; 3 = exakte Übereinstimmung

;Sonderzeichen Workaround
ue := "ü"
ae := "ä"
oe := "ö"
sz := "ß"

OverwriteKeysAnywayArray := { 1: "Version"
, 2: "x_ADDToStartfnX"
, 3: "x_ADDToStartfnY"
, 4: "TimeOutMsgLFDMatch"
, 5: "TimeOutMsgSkippedIntro"
, 6: "TimeOutRemoteTest"
, 7: "290102"}

OverwriteValuesArray  := { 1: "IntroGetSex"
, 2: "IntroSexReversed"
, 3: "IntroGetDateOfBirth"
, 4: "p73170yPRE"
, 5: "name_apPRE"}


; FileManagement
ConfigFolder := A_ScriptDir . "\Config"
BasicFile := ConfigFolder . "\BasicSettings.ini"
UpdateLogFile := "UpdateLog_" . A_YYYY .  A_MM . A_DD . ".txt"
UpdateTimeStemp :=  A_DD . "." . A_MM . "." . A_YYYY

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

; (0) Deleting Old Sections/Keys
DeleteIniValue(BasicFile, "ChangableSettings", "MsgDurationLFDMatch")
DeleteIniValue(BasicFile, "ChangableSettings", "MsgDurationSkippedIntro")
DeleteIniValue(BasicFile, "AdvancedSettings", "CreatHistory")

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
Gui, 21:Add, Radio, x12 y10 w160 h20 Checked%Hard% vr_UpdateHard, alle Dateien %ue%berschreiben
Gui, 21:Add, Radio, x12 y35 w170 h20 Checked%Soft% Disabled%Hard% vr_UpdateSoft, nur Neuerungen %ue%bernehmen
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
	UpdateClaim := "und dabei alle Dateien " . ue . "berschreiben"
	UpdateModus := "Hard"
	}
if (r_UpdateSoft = 1)
	{
	UpdateClaim := "und Neuerungen " . ue . "bernehmen"
	UpdateModus := "Soft"
	}
if (ForceUpdate = "true")
	{
	UpdateModus := "Force"
	}
MsgBox, 4132, Update to %LatestVersion%?, Update von ProTest jetzt durchf%ue%hren %UpdateClaim%?
IfMsgBox, YES
	{
	; (3) DOWNLOAD LATEST Version
	Gui 21:Destroy
	GoSub WaitingProcessWindow
	SaveToUpdateLog("Download Latest Version (" . LatestVersion . ")")
	SaveToUpdateLog("UpdateModus: " . UpdateModus)
	DownloadLatestVersion(LatestVersion, UpdateModus)
	if (UpdateModus = "Soft")
		Goto SoftUpdate
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
FilestoCompare := CompareUpdateFiles()
SaveToUpdateLog(FilestoCompare . " ini-Datei(en) unterschiedlich")
; (4.2) Update Changes
For Index, Filename in CompareUpdateFilesArray
	{
	OldFile := ConfigFolder . "\" . Filename
	Newfile := UpdateFolder . "\Config\" . Filename
	SaveToUpdateLog( Index . "/" . FilestoCompare .  " ### Update " . Filename . " ###")
	if (Filename = "Capture2Text.ini")
		{
		FileCopy, %Newfile%, %OldFile%, 1
		Continue
		}
	CompareIniSections(OldFile, NewFile)
	if (Filename = "Library.ini")
		DeleteOldLibrarySections(OldFile)
	}
SaveToUpdateLog("Update auf Version " . LatestVersion . " abgeschlossen!")
UpdateExeFiles()
FileRemoveDir, %UpdateFolder% , 1
Gosub 15GuiClose
MsgBox, 4096, Update erfolgreich!, Update auf Version %LatestVersion% abgeschlossen!
RunProTest(ProTestProgram)
ExitApp
return 

;;;;;; SOFT UPDATE FUNCTIONS ;;;;;;;;;;

DeleteOldLibrarySections(FilePath){
local 
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

CompareUpdateFiles(){
local
global ConfigFolder
global UpdateFolder
global CompareUpdateFilesArray := []
FilesCount := 0
Loop, Files, %UpdateFolder%\Config\*.ini
	{
	UpdateFile := UpdateFolder . "\Config\" . A_LoopFileName
	FileGetSize, UpdateSize , %UpdateFile%
	InstalledFile := ConfigFolder . "\" . A_LoopFileName
	FileGetSize, InstalledSize, %InstalledFile%
	if (UpdateSize != InstalledSize)
		{
		CompareUpdateFilesArray[++FilesCount] := A_LoopFileName
		if (InstalledSize = "")
			{
			FileCopy, %UpdateFile%, %InstalledFile%
			SaveToUpdateLog("Neue Datei: " . A_LoopFileName)
			}
		}
	; Force BasicFile.ini to be compared
	if (A_LoopFileName = "BasicSettings.ini")
		{
		if (FilesCount = 0)
			CompareUpdateFilesArray[++FilesCount] := A_LoopFileName
		else
			CompareUpdateFilesArray[FilesCount] := A_LoopFileName
		}
	} ; ende Loop
return CompareUpdateFilesArray.Count()
}

UpdateExeFiles(){
local
global UpdateFolder
ProTestExeFiles := ["ProTest_v2.0.exe", "ProTest_v2.0_RemoteClient.exe"]
For i, ExeFile in ProTestExeFiles
	{
	NewFile := UpdateFolder . "\" . ExeFile
	FileCopy, %NewFile%, %ExeFile%, 1
	}
}

CompareIniSections(OldFile, NewFile){
local
global UpdateTimeStemp
global ChangedSectionArray
global OverwriteKeysAnywayArray
global OverwriteValuesArray 
OldSectionList := GetIniSectionNames(Oldfile)
NewSectionList := GetIniSectionNames(Newfile)
ChangedSectionArray := []
; Get Ini-Section-Names
Loop, Parse, NewSectionList , "`n"
	{
	; Compare Sections
	CurrentSection := A_LoopField
	NewKeyEntry := false
	; Abschnitt vorhanden?
	if !Instr(OldSectionList, CurrentSection)
		{
		CurrentNewSection := CurrentSection
		; Nein -> Neuer Abschnitt
		; Neuen Abschnitt und Keys Einfügen
		CopySection(OldFile, NewFile, CurrentNewSection)
		}
	else
		{
		; Ja - Prüfe Änderungen
		; Load Sections
		NewSectionKeys := GetIniSection(NewFile, CurrentSection)
		OldSectionKeys := GetIniSection(OldFile, CurrentSection)
		SectionIndex := A_Index
		; Abschnitte gleich?
		if (NewSectionKeys = OldSectionKeys)
			{
			; ja - Abschnitte identisch
			Continue
			}
		if (NewSectionKeys != OldSectionKeys)
			{
			; nein - geänderter Abschnitt
			Loop, Parse, NewSectionKeys , "`n"
				{
				CurrentLine := A_LoopField
				if !Instr(OldSectionKeys, CurrentLine)
					{
					; Unterschiedliche Eintragungen
					CurrentNewKey := Substr(CurrentLine, 1, Instr(CurrentLine, "=")-1)
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
							ChangedSectionArray[SectionIndex] := CurrentSection
							NewKeyEntry := true 
							}
						; weiterer neuer Key
						IniWrite, %NewCompleteValue%, %OldFile%, %CurrentSection%, %CurrentNewKey%
						SaveToUpdateLog("NEU: [" . CurrentSection . "] " . CurrentNewKey . " = " . NewCompleteValue)
						}
					else
						{
						; Veränderter Eingabewert
						NewValue := GetIniValue(NewFile, CurrentSection, CurrentNewKey)
						OldValue := GetIniValue(OldFile, CurrentSection, CurrentNewKey)
						if (OldValue = NewValue)
							{
							; Eingabewerte sind prinzipiell gleich
							CleanOldCompleteValue  := RegExReplace(OldCompleteValue , "\s")
							CleanNewCompleteValue  := RegExReplace(NewCompleteValue , "\s")
							; Kommentare (bis auf Leerzeichen) gleich? Falls ja, Neuen Wert einfügen
							if (CleanOldCompleteValue = CleanNewCompleteValue)
								IniWrite, %NewCompleteValue%, %OldFile%, %CurrentSection%, %CurrentNewKey%
							Continue
							}
						else
							{
							; Eingabewerte sind nicht gleich, Eingabewerte ändern falls...
							; a) Key in OverwriteKeysAnywayArray
							For i, ChangeKey in OverwriteKeysAnywayArray
								{
								if (ChangeKey = CurrentNewKey)
									{
									;Change Key Value
									NewCompleteValue := NewCompleteValue . " `; (Update " . UpdateTimeStemp . ")" 
									IniWrite, %NewCompleteValue%, %OldFile%, %CurrentSection%, %CurrentNewKey%
									SaveToUpdateLog("Geändert: [" . CurrentSection . "] " . CurrentNewKey . " = " . NewCompleteValue)
									}
								}
							; b) geänderte Eingabewerte
							For i, ChangeValue in OverwriteValuesArray  
								{
								if (OldValue = ChangeValue)
									{
									NewCompleteValue := A_Space . StrReplace(OldCompleteValue, OldValue , NewValue) ; . " `; (Update " . UpdateTimeStemp . ")" 
									IniWrite, %NewCompleteValue%, %OldFile%, %CurrentSection%, %CurrentNewKey%
									SaveToUpdateLog("Geändert: [" . CurrentSection . "] " . CurrentNewKey . " = " . NewValue . " (vorher: " . OldValue . ")")
									}
								} ; ende for loop
							} ; ende else
						} ; ende else
					} ; ende if
				} ; ende loop
			} ; ende if
		} ; ende else
	} ; ende loop
; Delete Update Keys
For Index, Section in ChangedSectionArray
	{
	;Msgbox, 4096, Delete...,  Delete Update in %Section% 
	DeleteIniValue(OldFile, Section, "Update")
	}
} ; ende function

CopySection(OldFile, NewFile, Section){
local
NewSectionKeys := GetIniSection(NewFile, Section)
Loop, Parse, NewSectionKeys , "`n"
	{
	CurrentLine := A_LoopField
	CurrentNewKey := Substr(CurrentLine, 1, Instr(CurrentLine, "=")-1)
	IniRead, CurrentNewCompleteValue, %NewFile%, %Section%, %CurrentNewKey%
	IniWrite, %CurrentNewCompleteValue%, %OldFile%, %Section%, %CurrentNewKey% 
	SaveToUpdateLog("Neuer Abschnitt: [" . Section . "] " . CurrentNewKey . " = " . CurrentNewCompleteValue)
	} ; ende loop
} ; ende function

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

WaitingProcessWindow:
Gui, 15: -Caption +AlwaysOnTop -SysMenu
Gui, 15:Font, s16, Verdana
Gui, 15:Add, Text,, Update wird durchgeführt... 
Gui, 15:Show, Autosize Center, Update to %LatestVersion%
return

15GuiClose:
15GuiEscape:
Gui 15:Destroy
return 

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

DownloadLatestVersion(LatestVersion, UpdateModus){
local
global ProTestProgram
; Download ZipFile
FolderName := "ProtestUpdate_" . LatestVersion 
ZipFile := A_WorkingDir . "\" . FolderName . ".zip"
URL :=  "https://github.com/dietzste/ProTest/releases/download/" . LatestVersion . "/ProTest_" . LatestVersion . ".zip"
UrlDownloadToFile, %URL%, %ZipFile%

; Unzip (depending on UpdateModus)
if (UpdateModus = "Hard" or UpdateModus = "Force")
	global UpdateFolder := A_WorkingDir
if (UpdateModus = "Soft")
	{
	global UpdateFolder := A_WorkingDir . "\" . FolderName
	FileCreateDir, %UpdateFolder%
	}
shell := ComObjCreate("Shell.Application")
Folder := shell.NameSpace(ZipFile)
NewFolder := shell.NameSpace(UpdateFolder)
NewFolder.CopyHere(Folder.items, 4|16)

; Delete ZipFile
FileDelete, %ZipFile%

if (UpdateModus = "Hard" or UpdateModus = "Force")
	{
	SaveToUpdateLog("Alle Dateien ersetzt")
	SaveToUpdateLog("Update auf Version " . LatestVersion . " abgeschlossen!")
	Gosub 15GuiClose
	MsgBox, 4096, Update erfolgreich!, Update auf Version %LatestVersion% abgeschlossen!
	RunProTest(ProTestProgram)
	ExitApp
	}

} ; Ende Function Download

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Include Functions

#Include Protest_IniFunctions.ahk

;;; Other Functions

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