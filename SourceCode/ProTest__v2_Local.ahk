;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; ALLGEMEINES  ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Warn
#NoEnv
SetBatchLines -1
ListLines Off

SetTitleMatchMode, 2
; 1 = wintitle muss mit Titel beginnen
; 2 = wintitle muss Titel irgendwo enthalten
; 3 = exakte �bereinstimmung

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Folder/File Management ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Setting Up ProTest ;;;
ConfigFolder := A_Workingdir . "\Config"
BasicFile := ConfigFolder . "\BasicSettings.ini"
HeartPicture := ConfigFolder . "\Heart.png"
LibraryFile := ConfigFolder . "\Library.ini"

if !FileExist(ConfigFolder)
	{
	Msgbox,4096, Ups!, %ConfigFolder% existiert nicht!
	ExitApp
	}

;;; GLOBALE VARIABLEN DEFINIEREN ;;;

; Name Men�s
GuiF1  := "�berblick Hotkeys"
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
ue := "�"
ae := "�" 
oe := "�"
sz := "�"

; Work Variables
WorkWindow := "TeamViewer"
Verbose := false
CurrentLFD 	:= ""
ultrafast := 30
fast := 100
med := 130

; Variables Advanced Settings
LFDLimit		:= GetIniValue(BasicFile, "BasicSettings",  "LFDLimit")
fnLimit			:= GetIniValue(BasicFile, "BasicSettings",  "fnLimit")
DefaultSleep	:= GetIniValue(BasicFile, "BasicSettings",  "DefaultSleep")
TimeOutTest		:= GetIniValue(BasicFile, "BasicSettings",  "TimeOutTest")
SleepAfterEnter := GetIniValue(BasicFile, "BasicSettings",  "SleepAfterEnter")
RemoteBuffer 	:= GetIniValue(BasicFile, "BasicSettings",  "RemoteBuffer")
WaitForXModulSec := := GetIniValue(BasicFile, "BasicSettings",  "WaitForXModulSec")

; Monitor Vars
SysGet, MonitorCoord, MonitorWorkArea
ScreenWidth := MonitorCoordRight
ScreenHeight := MonitorCoordBottom
StandardWidth := 1920
StandardHeight := 1080
x_ADDToStartfnX 	:= GetIniValue(BasicFile, "PositionParameterF10", "x_ADDToStartfnX") 
x_ADDToStartfnY 	:= GetIniValue(BasicFile, "PositionParameterF10", "x_ADDToStartfnY")
ListLines On

if (A_IsCompiled = 1)
	{
	AddOns := false
	Goto F11Routine
	}
if (A_IsCompiled != 1)
	{
	AddOns := false
	SettingUpFiles("B142.ini")
	SettingUpCapture2Text()
	}

SettingUpCapture2Text(){
local
global ConfigFolder
global Capture2TextIniFileAppDataPath
global Capture2TextWorkDir :=  A_Workingdir . "\Capture2Text"
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
if !FileExist(Capture2TextIniFileAppDataPath)
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
}

; To-DO
/*
*/


;______ENDE AUTO EXECUTE SECTION ______

;;;;; TEST Section ;;;;
#if WinExist("Notepad++")
^t::
return 
#if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;   Basic WORK HOTKEYS   ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


#if WinExist("Notepad++")
F5::
if (A_IsCompiled != 1)
	{
	Send, ^S
	SaveToHistory("RELOAD")
	Reload
	}
return
#if  

+F5::
	SaveToHistory("RELOAD")
	Reload
return

F6::
	PAUSE
	SaveToHistory("PAUSE")
Return

+ESC:: 
	Suspend
Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;    ADVANCED HOTKEYS    ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_AdvancedHotkeys.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;   REMOTE CONNECTION    ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_RemoteConnection.ahk

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

#Include Protest_SkipIntro.ahk
#Include Protest_fnSearch.ahk
#Include Protest_InputBoxes.ahk
#Include Protest_WorkFunctions.ahk

;;;;;;;;;;;;;;;;;;;;;;;;
;; LFD Finder Routine ;;
;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_LFDFinder.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; INTERAKTIONS-MEN�S ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_F2MenuQuickSetup.ahk
#Include Protest_F3MenuLFDFinder.ahk
#Include Protest_F4MenuAdvancedSearch.ahk
#Include Protest_F8MenuPreloadReader.ahk
#Include Protest_F10MenuBasicSettings.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;    ADDONS    ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;#Include Protest_AddOns.ahk
;#Include Protest_F7MenuLernModus.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;     Hilfe-Texte Men�s      ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include Protest_HelpMenus.ahk