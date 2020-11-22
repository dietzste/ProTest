;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; ALLGEMEINES  ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;#Warn
#NoEnv
#SingleInstance Ignore
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
ListLines Off

SetTitleMatchMode, 2
; 1 = wintitle muss mit Titel beginnen
; 2 = wintitle muss Titel irgendwo enthalten
; 3 = exakte �bereinstimmung

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Folder/File Management ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Setting Up ProTest ;;;
ConfigFolder := A_ScriptDir . "\Config"
BasicFile := ConfigFolder . "\BasicSettings.ini"
PreloadDetailsFile := ConfigFolder . "\PreloadDetails.ini"
HeartPicture := ConfigFolder . "\Heart.png"
LibraryFile := ConfigFolder . "\Fragenbibliothek.ini"

if !FileExist(ConfigFolder)
	{
	Msgbox,4096, Ups!, %ConfigFolder% existiert nicht. ProTest wird beendet!
	ExitApp
	}
	
;;;;;;;;;;;;;;;;;;;;;;;
;;; Elevated Rights ;;;
;;;;;;;;;;;;;;;;;;;;;;;

StartAsAdmin := GetIniValue(BasicFile, "AdvancedSettings", "StartAsAdmin")
if (StartAsAdmin = "true")
	{
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
		{
		try
			{
			if A_IsCompiled
				Run *RunAs "%A_ScriptFullPath%" /restart
			else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
			}
		ExitApp
		}
	;MsgBox A_IsAdmin: %A_IsAdmin%`nCommand line: %full_command_line%
	}
else
	{
	global PIDTeamViewer := GetPID("TeamViewer.exe")
	if (PIDTeamViewer != 0)
		{
		; TeamViewer is running
		if (ProcessIsElevated(PIDTeamViewer) = 1)
			{
			; TeamViewer has elevated rights
			; Set StartAsAdmin to true and restart
			SaveIniValue(BasicFile, "AdvancedSettings", "StartAsAdmin", "true")
			try
				{
				if A_IsCompiled
					Run *RunAs "%A_ScriptFullPath%" /restart
				else
					Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
				}
			ExitApp
			} ; ende if
		} ; ende if
	} ; ende else

ProcessIsElevated(vPID)
{
;PROCESS_QUERY_LIMITED_INFORMATION := 0x1000
if !(hProc := DllCall("kernel32\OpenProcess", "UInt",0x1000, "Int",0, "UInt",vPID, "Ptr"))
	return -1
;TOKEN_QUERY := 0x8
hToken := 0
if !(DllCall("advapi32\OpenProcessToken", "Ptr",hProc, "UInt",0x8, "Ptr*",hToken))
{
	DllCall("kernel32\CloseHandle", "Ptr",hProc)
	return -1
}
;TokenElevation := 20
vIsElevated := vSize := 0
vRet := (DllCall("advapi32\GetTokenInformation", "Ptr",hToken, "Int",20, "UInt*",vIsElevated, "UInt",4, "UInt*",vSize))
DllCall("kernel32\CloseHandle", "Ptr",hToken)
DllCall("kernel32\CloseHandle", "Ptr",hProc)
return vRet ? vIsElevated : -1
}

;;; GLOBALE VARIABLEN DEFINIEREN ;;;

; Name Men�s
GuiF2  := " (F2) Hauptmen� "
GuiF3  := " (F3) Passende LFDs finden"
GuiF4  := " (F4) Erweiterte Optionen"
GuiF7  := " (F7) Antworten f�r Fragenummern definieren"
GuiF8  := " (F8) Preload-Werte abrufen"
GuiF10 := " (F10) ProTest Einstellungen "
GuiF12 := " (F12) Protest beenden"

; ini section names
QuickSetupMenu := "QuickSetupMenu"
LFDFinderMenu := "LFDFinderMenu"
AdvancedSearchMenu := "AdvancedSearchMenu"
PreloadReaderMenu := "PreloadReaderMenu"
BasicSettingsMenu := "BasicSettingsMenu"
fnBib := "Fragenbibliothek"

; special Menu Settings
DisON := "Disabled1"
DisOFF := "Disabled0"

; Work Variables
WorkWindow := "ahk_class TV_CClientWindowClass"
CurrentLFD 	:= ""
ultrafast := 30
fast := 100
med := 130
TabVar := ""
NewEntryF7 := true
global Captur2TextPID := GetPID("Capture2Text.exe")

GetPID(ProgramName){
Process, Exist , %ProgramName%
return PID := ErrorLevel
}

; Version
ProTestVersion := GetIniValue(BasicFile, "ProTestVersion", "Version", "v2")

; Changable Settings
SleepAfterEnter			:= GetIniValue(BasicFile, "ChangableSettings",  "SleepAfterEnter")
TimeOutMsgLFDMatch		:= GetIniValue(BasicFile, "ChangableSettings",  "TimeOutMsgLFDMatch")
TimeOutMsgSkippedIntro	:= GetIniValue(BasicFile, "ChangableSettings",  "TimeOutMsgSkippedIntro")/1000

; Advanced Settings
DefaultSleep		:= GetIniValue(BasicFile, "AdvancedSettings",  "DefaultSleep")
LFDLimit			:= GetIniValue(BasicFile, "AdvancedSettings",  "LFDLimit")
fnLimit				:= GetIniValue(BasicFile, "AdvancedSettings",  "fnLimit")
TimeOutRemoteTest	:= GetIniValue(BasicFile, "AdvancedSettings",  "TimeOutRemoteTest")
RemoteBuffer		:= GetIniValue(BasicFile, "AdvancedSettings",  "RemoteBuffer")
WaitForXModulSec	:= GetIniValue(BasicFile, "AdvancedSettings",  "WaitForXModulSec")
VerboseHistory		:= GetIniValue(BasicFile, "AdvancedSettings",  "VerboseHistory")
MaxSkips			:= GetIniValue(BasicFile, "AdvancedSettings",  "MaxSkips")
SkipIfPreloadZero	:= GetIniValue(BasicFile, "AdvancedSettings",  "SkipIfPreloadZero")
MaxLengthfnValue	:= GetIniValue(BasicFile, "AdvancedSettings",  "MaxLengthfnValue")
IgnoreLFDConflict	:= GetIniValue(BasicFile, "AdvancedSettings",  "IgnoreLFDConflict")
ToolTipDisplayTime	:= GetIniValue(BasicFile, "AdvancedSettings",  "ToolTipDisplayTime")*(-1)

; OCR Settings
RawOCRTestOutput	:= GetIniValue(BasicFile, "OCR",  "RawOCRTestOutput")
AllowAlphas			:= GetIniValue(BasicFile, "OCR",  "AllowAlphas")
SleepWhileOCREmpty	:= GetIniValue(BasicFile, "OCR",  "SleepWhileOCREmpty")
RemoveLastAlpha		:= GetIniValue(BasicFile, "OCR",  "RemoveLastAlpha", "true")
ReplaceLast6witha	:= GetIniValue(BasicFile, "OCR",  "ReplaceLast6witha", "true")

; Logbuch
CreateHistory := GetIniValue(BasicFile, BasicSettingsMenu, "c_History")

; Monitor Vars
SysGet, MonitorCoord, MonitorWorkArea
ScreenWidth := MonitorCoordRight
ScreenHeight := MonitorCoordBottom
StandardWidth := 1920
StandardHeight := 1080
ListLines On

; Tray Menu
Menu, Tray, Insert
Menu, Tray, Add , About ProTest, AboutMessage
Menu, Tray, Add , Update, UpdateProTest

if (A_IsCompiled = 1)
	{
	Goto ChooseProjectFile
	}
if (A_IsCompiled != 1)
	{
	; Test Section
	WorkWindow := GetIniValue("TestModus.ini", "TestModus", "WorkWindow", "TeamViewer")
	LastProjectFile := GetIniValue("TestModus.ini", "TestModus", "LastProjectFile")
	if (LastProjectFile = "Error")
		{
		InputBox, EnteredIniFile, Enter Ini-File,,,150,120
		if (ErrorLevel = 1)
			ExitApp
		else
			{
			LastProjectFile := EnteredIniFile . ".ini"
			SaveIniValue("TestModus.ini", "TestModus", "LastProjectFile", LastProjectFile)
			}
		}
	SettingUpProTest(LastProjectFile, "TestModus")
	}
return

;______ENDE AUTO EXECUTE SECTION ______

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;  HOTKEYS    ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ProTest_Hotkeys.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;   REMOTE CONNECTION    ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ProTest_RemoteConnection.ahk

;;;;;;;;;;;;;;;;;;;;
;;;;;   OCR   ;;;;;;
;;;;;;;;;;;;;;;;;;;;

#Include Protest_OCR.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;      INI FUNCTIONS      ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_IniFunctions.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; PROTEST MAIN FUNCTIONS ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_EnterValues.ahk
#Include Protest_FnSearch.ahk
#Include Protest_WorkFunctions.ahk
#Include ProTest_MenuFunctions.ahk

;;;;;;;;;;;;;;;;;;;;;;;;
;; LFD Finder Routine ;;
;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_LFDFinder.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;  INTERAKTIONS-MEN�S  ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_F2MenuQuickSetup.ahk
#Include Protest_F3MenuLFDFinder.ahk
#Include Protest_F4MenuAdvancedSearch.ahk
#Include Protest_F7MenuLernModus.ahk
#Include Protest_F8MenuPreloadReader.ahk
#Include Protest_F10MenuBasicSettings.ahk
#Include ProTest_AutoEdit.ahk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;     Hilfe-Texte Men�s      ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_HelpMenus.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;       Update Script        ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include UpdateScript.ahk
