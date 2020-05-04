;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; ALLGEMEINES  ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Warn
#NoEnv
#SingleInstance Ignore
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

ListLines Off

SetTitleMatchMode, 2
; 1 = wintitle muss mit Titel beginnen
; 2 = wintitle muss Titel irgendwo enthalten
; 3 = exakte Übereinstimmung

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Folder/File Management ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Setting Up ProTest ;;;
ConfigFolder := A_ScriptDir . "\Config"
BasicFile := ConfigFolder . "\BasicSettings.ini"
PreloadDetailsFile := ConfigFolder . "\PreloadDetails.ini"
HeartPicture := ConfigFolder . "\Heart.png"
LibraryFile := ConfigFolder . "\Library.ini"

; Version
ProTestVersion := GetIniValue(BasicFile, "ProTestVersion", "Version")
if (ProTestVersion = "ERROR")
	{
	; get Version from FileName
	VersionStart := Instr(A_ScriptName, "_v") + 2
	ProTestVersion := Substr(A_ScriptName,VersionStart, 3)
	}

if !FileExist(ConfigFolder)
	{
	Msgbox,4096, Ups!, %ConfigFolder% existiert nicht!
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

;;; GLOBALE VARIABLEN DEFINIEREN ;;;

; Name Menüs
GuiF1  := "Überblick Hotkeys"
GuiF2  := "Quick Setup Menu"
GuiF3  := "LFD Finder Menu"
GuiF4  := "Erweiterte Optionen"
GuiF7  := "Lernmodus"
GuiF8  := "Preload Reader"
GuiF9  := "Remote Feedback Test"
GuiF10 := "Einstellungen"
GuiF12 := "Protest beenden?"

; ini section names
QuickSetupMenu := "QuickSetupMenu"
LFDFinderMenu := "LFDFinderMenu"
AdvancedSearchMenu := "AdvancedSearchMenu"
PreloadReaderMenu := "PreloadReaderMenu"
BasicSettingsMenu := "BasicSettingsMenu"

; special Menu Settings
DisON := "Disabled1"
DisOFF := "Disabled0"

;Sonderzeichen Workaround
ue := "ü"
ae := "ä"
oe := "ö"
sz := "ß"

; Work Variables
WorkWindow := "ahk_class TV_CClientWindowClass"
CurrentLFD 	:= ""
ultrafast := 30
fast := 100
med := 130
NewEntryF7fnIntro := false
NewEntryF7fnNag := false
Capture2TextStarted := false

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

; OCR Settings
RawOCRTestOutput	:= GetIniValue(BasicFile, "OCR",  "RawOCRTestOutput")
AllowAlphas			:= GetIniValue(BasicFile, "OCR",  "AllowAlphas")
SleepWhileOCREmpty	:= GetIniValue(BasicFile, "OCR",  "SleepWhileOCREmpty")

; Monitor Vars
SysGet, MonitorCoord, MonitorWorkArea
ScreenWidth := MonitorCoordRight
ScreenHeight := MonitorCoordBottom
StandardWidth := 1920
StandardHeight := 1080
x_ADDToStartfnX 	:= GetIniValue(BasicFile, "PositionParameterF10", "x_ADDToStartfnX")
x_ADDToStartfnY 	:= GetIniValue(BasicFile, "PositionParameterF10", "x_ADDToStartfnY")
ListLines On

; Tray Menu
Menu, Tray, Insert
Menu, Tray, Add , About ProTest, AboutMessage
Menu, Tray, Add , Update, UpdateProTest

if (A_IsCompiled = 1)
	{
	Goto F11Routine
	}
if (A_IsCompiled != 1)
	{
	Capture2TextStarted := false
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
	SettingUpFiles(LastProjectFile)
	SettingUpCapture2Text()
	Send, {F10}
	WinWaitActive, %GuiF10%
	WinClose, %GuiF10%
	}

SettingUpCapture2Text(){
local
global ConfigFolder
global Capture2TextWorkDir :=  A_ScriptDir . "\Capture2Text"
global Capture2TextAppDataFolder := A_AppData . "\Capture2Text"
global Capture2TextIniFileAppDataPath := Capture2TextAppDataFolder . "\Capture2Text.ini"
global Capture2TextStarted

if !FileExist(Capture2TextWorkDir)
	{
	Msgbox,4096, Ups!, %Capture2TextWorkDir% existiert nicht!
	ExitApp
	}

; Setting up AppData Folder
if !FileExist(Capture2TextAppDataFolder)
	FileCreateDir, %Capture2TextAppDataFolder%
; Setting up Ini-File
if !FileExist(Capture2TextIniFileAppDataPath)
	FileCopy, %ConfigFolder%\Capture2Text.ini, %Capture2TextIniFileAppDataPath%

Process, Exist , Capture2Text.exe
if (ErrorLevel = 0) ; Capture2Text not running
	{
	Run, Capture2Text.exe , %Capture2TextWorkDir% ,, PID
	global Captur2TextPID := PID
	Capture2TextStarted := true
	}
else
	{
	; Captur2Text is running, ErrorLevel enthält PID
	global Captur2TextPID := ErrorLevel
	}
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

;;;;;;;;;;;;;;;;;;;;;;;;
;; LFD Finder Routine ;;
;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_LFDFinder.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;  INTERAKTIONS-MENÜS  ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_F2MenuQuickSetup.ahk
#Include Protest_F3MenuLFDFinder.ahk
#Include Protest_F4MenuAdvancedSearch.ahk
#Include Protest_F7MenuLernModus.ahk
#Include Protest_F8MenuPreloadReader.ahk
#Include Protest_F10MenuBasicSettings.ahk
#Include ProTest_AutoEdit.ahk
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;     Hilfe-Texte Menüs      ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_HelpMenus.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;       Update Script        ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include UpdateScript.ahk
