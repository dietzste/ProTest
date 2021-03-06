#Warn
#NoEnv
SetWorkingDir %A_ScriptDir%

SetTitleMatchMode, 2
; 1 = WinTitle muss mit Titel beginnen
; 2 = WinTitle muss Titel irgendwo enthalten
; 3 = exakte �bereinstimmung

; FileManagement
ConfigFolder := A_ScriptDir . "\Config"
BasicFile := ConfigFolder . "\BasicSettings.ini"
UpdateLogFile := "UpdateLog_" . A_YYYY .  A_MM . A_DD . ".txt"
UpdateTimeStemp :=  A_DD . "." . A_MM . "." . A_YYYY

;;; UPDATE CONTROL ;;;
OverwriteSectionArray := { 1: "P41599PRE"
, 2: "P41598PRE"}

OverwriteKeysAnywayArray := { 1: "Version"
, 2: "TimeOutMsgLFDMatch"
, 3: "TimeOutMsgSkippedIntro"
, 4: "TimeOutRemoteTest"
, 5: "SleepAfterEnter"
, 6: "r_Main1"
, 7: "r_Main2"
, 8: "r_AdvancedON"
, 9: "r_AdvancedOFF"
, 10: "0100082"
, 11: "27104"
, 12: "28403"
, 13: "VerboseHistory"
, 14: "e_Next" }

OverwriteValuesArray := { 1: "IntroGetSex"
, 2: "IntroSexReversed"
, 3: "IntroGetDateOfBirth"
, 4: "p73170yPRE"
, 5: "name_apPRE"}

;;; Ende AutoSection ;;;

; (E1) Error Handling - Checking File Location
if !FileExist(ConfigFolder)
	{
	SaveToUpdateLog("ABBRUCH: Config-Ordner nicht vorhanden")
	MsgBox, 4096, Update Error, Die Ordner Config befindet sich nicht im Verzeichnis!
	ExitApp
	}

; (E2) Error Handling - Exit ProTestProgramm
ProTestWasRunning := ExitProTestProgramm()

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
		RunProTest()
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
Gui, 21:Add, Radio, x12 y10 w160 h20 Checked%Hard% vr_UpdateHard, alle Dateien �berschreiben
Gui, 21:Add, Radio, x12 y35 w170 h20 Checked%Soft% vr_UpdateSoft, nur Neuerungen �bernehmen
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
	RunProTest()
	ExitApp
	}
else
	Goto UpdateProcedure
return

Gui21Update:
Gui 21:Submit, NoHide
if (r_UpdateHard = 1)
	{
	UpdateClaim := "und dabei alle Dateien �berschreiben"
	UpdateModus := "Hard"
	}
if (r_UpdateSoft = 1)
	{
	UpdateClaim := "und Neuerungen �bernehmen"
	UpdateModus := "Soft"
	}
Sleep, 550
MsgBox, 4132, Update to %LatestVersion%?, Update von ProTest jetzt durchf�hren %UpdateClaim%?
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
		RunProTest()
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
SoftUpdate:
; (4.1) Compare Files
CompareIniFilesArray := []
IniFilestoCompareCount := CompareIniFiles()
SaveToUpdateLog(IniFilestoCompareCount . " ini-Datei(en) unterschiedlich")
; (4.2) Update Changes
WaitingProcessWindow(LatestVersion, "Vergleiche ini-Dateien")
For Index, Filename in CompareIniFilesArray
	{
	OldFile := ConfigFolder . "\" . Filename
	Newfile := UpdateFolderPath . "\Config\" . Filename
	if (Filename = "Capture2Text.ini")
		{
		FileCopy, %Newfile%, %OldFile%, 1
		Continue
		}
	SaveToUpdateLog( Index . "/" . IniFilestoCompareCount .  " ### Update " . Filename . " ###")
	CompareIniSections(OldFile, NewFile)
	}
; Integrate Old Library
IntegratedLibraryFile := ConfigFolder . "\Library_old.ini"
if !FileExist(IntegratedLibraryFile)
	{
	WaitingProcessWindow(LatestVersion, "Integriere alte Library")
	OldLibraryFile := ConfigFolder . "\Library.ini"
	CleanOldLibrary(OldLibraryFile)
	IntegrateOldLibrary(OldLibraryFile)
	}
; �berschreibe Exe-Dateien
WaitingProcessWindow(LatestVersion, "�berschreibe exe-Dateien")
OverwriteExeFiles()
WaitingProcessWindow(LatestVersion, "Entferne Update-Ordner")
SaveToUpdateLog("Update auf Version " . LatestVersion . " abgeschlossen!")
FileRemoveDir, %UpdateFolderPath% , 1
Gosub 15GuiClose
MsgBox, 4096, Update erfolgreich!, Update auf Version %LatestVersion% abgeschlossen!
RunProTest()
ExitApp
return 

;;;;;; SOFT UPDATE FUNCTIONS ;;;;;;;;;;

CompareIniFiles(){
local
global ConfigFolder
global UpdateFolderPath
global CompareIniFilesArray
FilesCount := 0
Loop, Files, %UpdateFolderPath%\Config\*.ini
	{
	UpdateFile := UpdateFolderPath . "\Config\" . A_LoopFileName
	OldFile := ConfigFolder . "\" . A_LoopFileName
	if Instr(OldFile, "BasicSettings.ini")
		{
		DeleteOldKeys(OldFile)
		DeleteOldIniSections(OldFile)
		CompareIniFilesArray[++FilesCount] := A_LoopFileName
		Continue
		}
	FileGetSize, UpdateSize , %UpdateFile%
	FileGetSize, InstalledSize, %OldFile%
	if (UpdateSize != InstalledSize)
		{
		if (InstalledSize = "")
			{
			; File noch nicht vorhanden
			FileCopy, %UpdateFile%, %OldFile%
			SaveToUpdateLog("Neue Datei: " . A_LoopFileName)
			}
		else
			CompareIniFilesArray[++FilesCount] := A_LoopFileName
		}
	} ; ende Loop
return CompareIniFilesArray.Count()
}

OverwriteExeFiles(){
local
global UpdateFolderPath

; Did RemoteClient change?
NewRemoteClientPath := UpdateFolderPath . "\ProTest_RemoteClient.exe"
OldRemoteClientPath := A_ScriptDir . "\ProTest_RemoteClient.exe"
RemoteClientPathArray := [NewRemoteClientPath, OldRemoteClientPath]

For Index, RemoteClientPath in RemoteClientPathArray
	{
   ; r = read File, "cp0" - system default ANSI code page
   file := FileOpen(RemoteClientPath, "r", "cp0")
   ; read binary data
   file.RawRead(buff%A_Index%,  len%A_Index% := file.Length)
   file.Close()
	}
if (len1 = len2 and !DllCall("msvcrt\memcmp", "Ptr", &buff1, "Ptr", &buff2, "Ptr", len1) )
	SaveToUpdateLog("RemoteClient: unver�ndert")
else
	SaveToUpdateLog("RemoteClient: ge�ndert")

ProTestExeFiles := ["ProTest.exe", "ProTest_RemoteClient.exe"]
For i, ExeFile in ProTestExeFiles
	{
	NewFile := UpdateFolderPath . "\" . ExeFile
	FileCopy, %NewFile%, %ExeFile%, 1
	}
DeleteOldExeFiles()
}

CompareIniSections(OldFile, NewFile){
local
; Get Ini-Section-List
global OverwriteSectionArray
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
		IniRead, NewSectionKeys, %NewFile%, %CurrentSection%
		IniRead, OldSectionKeys, %OldFile%, %CurrentSection%
		; Abschnitte gleich?
		if (NewSectionKeys = OldSectionKeys)
			{
			; gleiche Abschnitte
			Continue
			}
		if (NewSectionKeys != OldSectionKeys)
			{
			; unterschiedliche Abschnitte
			CurrentSectionWasOverwritten := false
			For Index, SectionName in OverwriteSectionArray
				{
				if (CurrentSection = SectionName)
					{
					DeleteIniSection(Oldfile, CurrentSection)
					CopySection(OldFile, NewFile, CurrentSection)
					CurrentSectionWasOverwritten := true
					Break
					}
				}
			if (CurrentSectionWasOverwritten = false)
				{
				CompareIniKeys(OldFile, NewFile, CurrentSection, NewSectionKeys, OldSectionKeys, "Update")
				}
			}
		}
	} ; ende loop
} ; ende function

CompareIniKeys(OldFile, NewFile, CurrentSection, NewSectionKeys, OldSectionKeys, Mode){
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
				; ersten neuen Eintrag mit Abstand einf�gen
				SaveIniValue(OldFile, CurrentSection, "`n;;; " . Mode . " " . UpdateTimeStemp . "`nUpdate", "Update")
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
			ChangeKeyEntry(OldFile, NewFile, CurrentSection, CurrentNewKey, OldCompleteValue, NewCompleteValue, "Update")
			} ; ende else
		} ; ende if
	} ; ende loop
} ; ende 
; Ver�nderter Eingabewert

ChangeKeyEntry(OldFile, NewFile, CurrentSection, CurrentNewKey, OldCompleteValue, NewCompleteValue, Mode){
local
global OverwriteKeysAnywayArray
global OverwriteValuesArray
global UpdateTimeStemp
ValueOverwritten := false
; Ver�nderter Eingabewert
NewValue := GetIniValue(NewFile, CurrentSection, CurrentNewKey)
OldValue := GetIniValue(OldFile, CurrentSection, CurrentNewKey)
if (OldValue = NewValue)
	return 
else
	{
	; Eingabewerte sind nicht gleich, Eingabewerte �ndern/l�schen falls...
	; a) Key in OverwriteKeysAnywayArray
	For i, ChangeKey in OverwriteKeysAnywayArray
		{
		if (ChangeKey = CurrentNewKey)
			{
			;Change Key Value
			NewCompleteValue := NewCompleteValue . " `; (" . Mode . " " . UpdateTimeStemp . ")" 
			IniWrite, %NewCompleteValue%, %OldFile%, %CurrentSection%, %CurrentNewKey%
			SaveToUpdateLog("Ge�ndert: [" . CurrentSection . "] " . CurrentNewKey . " = " . NewCompleteValue)
			ValueOverwritten := true
			}
		}
	; b) ge�nderte Eingabewerte
	For i, ChangeValue in OverwriteValuesArray  
		{
		if (ChangeValue = OldValue)
			{
			NewCompleteValue := A_Space . StrReplace(OldCompleteValue, OldValue , NewValue)
			IniWrite, %NewCompleteValue%, %OldFile%, %CurrentSection%, %CurrentNewKey%
			SaveToUpdateLog("Ge�ndert: [" . CurrentSection . "] " . CurrentNewKey . " = " . NewValue . " (vorher: " . OldValue . ")")
			ValueOverwritten := true
			}
		} ; ende for loop
	if Instr(OldValue, "�")
			{
			; bei Kodierungs-Fehlern �berschreiben
			IniWrite, %NewCompleteValue%, %OldFile%, %CurrentSection%, %CurrentNewKey%
			ValueOverwritten := true
			}
	if (ValueOverwritten = false)
		SaveToUpdateLog("Eigene Eintragung: [" . CurrentSection . "] " . CurrentNewKey . " = " . OldValue . " (urspr�nglich: " . NewValue . ")")
	} ; ende else
} ; ende function

CopySection(OldFile, NewFile, Section){
local
global OverwriteSectionArray
IniRead, NewSectionKeys, %NewFile%, %Section%
OverwriteThisSection := false
For Index, SectionName in OverwriteSectionArray
	{
	if (Section = SectionName)
		{
		OverwriteThisSection := true
		break
		}
	}
if (OverwriteThisSection = false)
	SaveToUpdateLog("Neuer Abschnitt: [" . Section . "]")
Loop, Parse, NewSectionKeys , "`n"
	{
	CurrentLine := A_LoopField
	CurrentNewKey := Substr(CurrentLine, 1, Instr(CurrentLine, "=")-1)
	IniRead, CurrentNewCompleteValue, %NewFile%, %Section%, %CurrentNewKey%
	IniWrite, %CurrentNewCompleteValue%, %OldFile%, %Section%, %CurrentNewKey% 
	if (OverwriteThisSection = false)
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

;;;;;;;;;;;;;;;;;;;
;;;;  CleanUp  ;;;;
;;;;;;;;;;;;;;;;;;;

; Delete old Keys
DeleteOldKeys(OldFile){
DeleteIniValue(OldFile, "ChangableSettings", "MsgDurationLFDMatch")
DeleteIniValue(OldFile, "ChangableSettings", "MsgDurationSkippedIntro")
DeleteIniValue(OldFile, "ChangableSettings", "CreateHistory")
DeleteIniValue(OldFile, "AdvancedSettings", "CreatHistory")
DeleteIniValue(OldFile, "BasicSettingsMenu", "e_Input1")
DeleteIniValue(OldFile, "BasicSettingsMenu", "e_Input2")
DeleteIniValue(OldFile, "BasicSettingsMenu", "e_Input3")
DeleteIniValue(OldFile, "BasicSettingsMenu", "e_BirthDay")
DeleteIniValue(OldFile, "BasicSettingsMenu", "e_BirthMonth")
DeleteIniValue(OldFile, "BasicSettingsMenu", "e_BirthYear")
DeleteIniValue(OldFile, "BasicSettingsMenu", "e_sex")
DeleteIniValue(OldFile, "BasicSettingsMenu", "c_dependent")
DeleteIniValue(OldFile, "QuickSetupMenu", "e_Stopfn1")
DeleteIniValue(OldFile, "QuickSetupMenu", "e_Stopfn2")
DeleteIniValue(OldFile, "QuickSetupMenu", "e_Stopfn3")
}

; Delete old Sections
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

CleanOldLibrary(OldLibraryFile){

; Delete Old Entrys
DeleteOldIniSections(OldLibraryFile)

; Load Data of ini-File
FileRead, OldLibraryData, %OldLibraryFile%

; Delete the following lines
CleanLibraryData := StrReplace(OldLibraryData, ";;;;;;;;;;;;;;;;;;;;;")
CleanLibraryData := StrReplace(CleanLibraryData, "`n;;;    fnIntro   " . ";;;;")
CleanLibraryData := StrReplace(CleanLibraryData, "`n;;;;    fnNAG    " . ";;;;")
CleanLibraryData := StrReplace(CleanLibraryData, "`n;;;     (F2)     " . ";;;;")
CleanLibraryData := StrReplace(CleanLibraryData, "`n;;;;    (F2)     " . ";;;;")
CleanLibraryData := StrReplace(CleanLibraryData, "`n;;; CHANGE INTRO VALUES HERE " . ";;;")
CleanLibraryData := StrReplace(CleanLibraryData, "`n;;; ADD NAG FNs HERE " . ";;;")
CleanLibraryData := StrReplace(CleanLibraryData, "`n; kein Kommentar notwendig, aber bitte mit "";" . """ abtrennen")

; Clear all Whitespaces
OccurrenceCount := 0
Loop {
CleanLibraryData := StrReplace(CleanLibraryData, "`r[fn", "[fn", OccurrenceCount1)
CleanLibraryData := StrReplace(CleanLibraryData, "`n[fn", "[fn", OccurrenceCount2)
OccurrenceCount := OccurrenceCount1 +  OccurrenceCount2
} Until (OccurrenceCount = 0) or (A_Index = 15)

; Delete Old Section Names
OldSectionList := GetIniSectionNames(OldLibraryFile)
Loop, Parse, OldSectionList, "`n"
	{
	ThisSection := "[" . A_LoopField . "]"
	CleanLibraryData := StrReplace(CleanLibraryData, ThisSection)
	}
	
; alten Inhalt mit FileDelete + FileAppend �berschreiben
CleanLibraryData := "[Fragenbibliothek]`n" . CleanLibraryData
FileDelete, %OldLibraryFile%
FileAppend, %CleanLibraryData%, %OldLibraryFile%

; Delete Keys
DeleteIniValue(OldLibraryFile, "Fragenbibliothek", "20401b")
DeleteIniValue(OldLibraryFile, "Fragenbibliothek", "20401c")
DeleteIniValue(OldLibraryFile, "Fragenbibliothek", "204016")
DeleteIniValue(OldLibraryFile, "Fragenbibliothek", "01103")

SaveToUpdateLog("Library.ini bereinigt")
}

DeleteOldExeFiles(){
if FileExist("ProTest_v2.0.exe")
	FileDelete, ProTest_v2.0.exe
if FileExist("ProTest_v2.0_RemoteClient.exe")
	FileDelete, ProTest_v2.0_RemoteClient.exe
}

IntegrateOldLibrary(OldLibraryFile){
local 
global ConfigFolder
NewLibraryFile := ConfigFolder . "\Fragenbibliothek.ini"

; Load Sections
IniRead, OldLibraryKeys, %OldLibraryFile%, OldLibrary
IniRead, FragenbibliothekKeys, %NewLibraryFile%, Fragenbibliothek

; Compare Sections
;CompareIniSections(OldFile, NewFile)
CompareIniSections(NewLibraryFile, OldLibraryFile)

; Rename Old Library
IntegratedLibraryFile := ConfigFolder . "\Library_old.ini"
FileMove, %OldLibraryFile%, %IntegratedLibraryFile%, 1
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

RunProTest(){
global ProTestWasRunning
if (ProTestWasRunning = true)
	{
	Process, Exist , ProTest.exe
	if (ErrorLevel = 0) ; ProTest not running
		Run, ProTest.exe
	}
}

WaitingProcessWindow(LatestVersion, Status){
local
Gui 15:Destroy
Gui, 15: -Caption +AlwaysOnTop -SysMenu +Border
Gui, 15:Font, s15, Verdana
Gui, 15:Add, Text,Center, Update wird durchgef�hrt
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

ExitProTestProgramm(){
local
ProTestProgramArray := ["ProTest_v2.0.exe", "ProTest.exe"]
For i, ExeFile in ProTestProgramArray
	{
	; checking which exe-File is running 
	Process, Exist , %ExeFile%
	if (ErrorLevel != 0) ; ProTest running
		{
		Process, Close, %ExeFile%
		if (ErrorLevel = 0)
			{
			MsgBox, 4096, Update Error, Kann %ExeFile% nicht schlie�en!
			Exit 
			}
		global ProTestProgram := ExeFile
		return ProTestWasRunning := true
		}
	}
global ProTestProgram := ""
return ProTestWasRunning := false
} ; ende function 