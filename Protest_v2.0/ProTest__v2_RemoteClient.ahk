;;;;;;;;;;; REMOTE ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; ALLGEMEINES  ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Warn
#NoEnv

SetTitleMatchMode, 2
; 1 = wintitle muss mit Titel beginnen
; 2 = wintitle muss Titel irgendwo enthalten
; 3 = exakte Übereinstimmung

; Tray Menu
Menu, Tray, Add , About ProTest, AboutMessage

;;; GLOBALE VARIABLEN DEFINIEREN ;;;
NipoFenster := "NIPO Interview System"
fast := 100
med := 150
SleepBufferCount := 0

; Working Variables
PreloadList := ""
RemoteSimulation := false

; History
RemoteHistoryOutput := false
DeleteHistory := true
VerboseHistory := false
RemoteHistoryFile := "RemoteHistory.txt"

if (RemoteSimulation = false)
	ChangeWindowSettings()

; ___ ENDE Auto_Excecution Section _______ 

Pause::
DetectionMode:
Detection := Clipboard
sleep, fast
SaveRemoteHistory("VERBOSE:", Detection)
if InStr(Detection, ">")
	{
	SaveRemoteHistory(Detection)
	Sighting(Detection)
	}
else
	{
	if (SleepBufferCount <= 2)
		{
		SaveRemoteHistory("VERBOSE:", Detection . "(Loop: " .  SleepBufferCount . ")")
		++SleepBufferCount
		Sleep, 1000
		Goto DetectionMode
		}
	}
return 
return 

Sighting(Detection){
local
global NipoFenster, MaxDetection
SleepBufferCount := 0
SaveRemoteHistory("VERBOSE:", "Function Sighting: " . Detection)
SendingBack := FindProcedure(Detection)
Clipboard := SendingBack
ClipWait, 1
if Instr(SendingBack, "<CloseRemoteProTest")
	ExitApp
if !Instr(SendingBack, "<PreloadList")
	{
	SaveRemoteHistory(SendingBack)
	SaveRemoteHistory("VERBOSE:" , SendingBack . "(Remote SendBack)")
	}
WinActivate, %NipoFenster%
}

FindProcedure(Detection){
local
global RemoteSimulation
DetectionBack := StrReplace(Detection, ">" , "<")
if InStr(Detection, ">Test")
	return DetectionBack
else if Instr(Detection, ">CloseRemoteProTest")
	return DetectionBack
else if  InStr(Detection, ">LoadingPreloads")
	return R_WaitUntilPreloadsLoaded()
else if InStr(Detection, ">SkipXModul")
	Result := R_SkipXModul(Detection)
else if InStr(Detection, ">PreloadList")
	Result := R_LoadPreloadList()
else if InStr(Detection, ">ClickButton")
	Result := R_TryClickingButton(Detection)
else if InStr(Detection, ">RPL(")
	Result := R_ReadPreload(Detection)
else If InStr(Detection, ">UPL(")
	Result := R_UpdatePreload(Detection)
else if InStr(Detection, ">MPL(")
	Result := R_ReadMuliplePreloads(Detection)
else if InStr(Detection, ">EnterNextLFD")
	Result := R_EnterNextLFD()
else if InStr(Detection, ">GetNextLFD")
	Result := R_GetNextLFD(Detection)
return DetectionBack . "=" . Result
}

R_EnterNextLFD(){
local
global med, NipoFenster
global RemoteSimulation
SaveRemoteHistory("VERBOSE:", "Function EnterNextLFD")
; Clicking 2x Back 
If (RemoteSimulation = true)
	return EnteredLFD := 1234
else
	{
	SaveRemoteHistory("VERBOSE:", "Back Button 2 Times")
	Loop, 2 {
	ButtonIsVisible := IsButtonVisible("&Back")
	if (ButtonIsVisible = true)
		{
		ControlClick, &Back, %NipoFenster%,,,, NA
		Sleep, med
		}
	else
		return "Error"
	}
	EnteredLFD := ReadingNextLFD()
	Send {Enter}{Enter}
	return EnteredLFD
	}
}

R_GetNextLFD(Detection){
local
global fast, med, NipoFenster
global RemoteSimulation
SaveRemoteHistory("VERBOSE:", "Function GetNextLFD")
; Clicking Back
NPressBackButton := Substr(Detection, 13)
If (RemoteSimulation = true)
	NextLFD := 1234
else
	{
	SaveRemoteHistory("VERBOSE:", "Back Button " . NPressBackButton . " Times")
	Loop, %NPressBackButton%  {
	ButtonIsVisible := IsButtonVisible("&Back")
	if (ButtonIsVisible = true)
		{
		ControlClick, &Back, %NipoFenster%,,,, NA
		Sleep, med
		}
	else
		return "Error"
	}
	NextLFD := ReadingNextLFD()
	return NextLFD
	} ; ende if
}

ReadingNextLFD(){
local  
global fast, med, NipoFenster
; Getting LFD / Enter LFD
SetKeyDelay, med
Send, {BS}{Down}{Enter} 
ControlClick, &Back, %NipoFenster%,,,, NA
Sleep, med
ControlGetText, LFDinEditField, Edit1, %NipoFenster%,,,,NA
Sleep, med
Send {Enter}
SetKeyDelay, fast
return LFDinEditField
}

R_WaitUntilPreloadsLoaded(){
local
global RemoteSimulation
SaveRemoteHistory("VERBOSE:", "Function WaitUntilPreloadsLoaded")
if (RemoteSimulation = false)
	L_WaitUntilPreloadsLoaded()
return "<LoadingComplete"
}

R_SkipXModul(Detection){
local
global RemoteSimulation
SaveRemoteHistory("VERBOSE:", "Function SkipXModul")
WaitForXModulSec := Substr(Detection, 13) 
if (RemoteSimulation = false)
	return Result := SkipXModul(WaitForXModulSec)
else
	return Result := "Simulation"
}

R_LoadPreloadList(){
local
global RemoteSimulation
SaveRemoteHistory("VERBOSE:", "Function LoadPreloadList")
if (RemoteSimulation = false)
	PreloadList := GetPreloadListAutoEdit()
else
	Preloadlist := "Test1`rTest2`rTest3`rTest4`rTest5"
return Preloadlist
}

R_TryClickingButton(Detection){
local
global RemoteSimulation, NipoFenster
SaveRemoteHistory("VERBOSE:", "Function TryClickingButton")
; ">ClickButton=" . Count . "," . Button
Count 	:= SubStr(Detection, 14, 1)
Button 	:= SubStr(Detection, 16)
loop, %Count% {
if (RemoteSimulation = false)
	{
	ButtonIsVisible := IsButtonVisible(Button)
	if (ButtonIsVisible = true)
		{
		ControlClick, %Button%, %NipoFenster%,,,, NA
		Result := "true"
		}
	else
		Result := "false"
	}
else
	Result := "Simulation"
} ; ende loop
return Result
}

R_ReadPreload(Detection){
local
global RemoteSimulation
SaveRemoteHistory("VERBOSE:", "Function ReadPreload")
Preload := ExtractPreload("Preload", Detection)
if (RemoteSimulation = false)
	PreloadValue := Readpreload(Preload)
else
	PreloadValue :=  -1
return PreloadValue
}

R_UpdatePreload(Detection){
local
global RemoteSimulation
SaveRemoteHistory("VERBOSE:", "Function UpdatePreload")
Preload := ExtractPreload("Preload", Detection)
ChangeTo := ExtractPreload("ChangeTo", Detection) 
if (RemoteSimulation = false)
	PreloadValue := UpdatePreload(Preload, ChangeTo)
else
	PreloadValue :=  -1
return PreloadValue 
}

R_ReadMuliplePreloads(Detection){
local
global RemoteSimulation
SaveRemoteHistory("VERBOSE:", "Function ReadMuliplePreloads")
MultiplePreloads := ExtractPreload("Preload", Detection)
if (RemoteSimulation = false)
	MultiplePreloadValues := ReadMultiplePreloads(MultiplePreloads)
else
	{
	NPreloads := CountMultiplePreloads(MultiplePreloads)
	MultiplePreloadValues := ""
	Loop, %NPreloads% {
	PreloadValue := -1
	if (A_Index = NPreloads)
		MultiplePreloadValues .= PreloadValue
	else
		MultiplePreloadValues .= PreloadValue . "|"
	} ; ende loop
	}
return MultiplePreloadValues
}

ExtractPreload(Mode, Detection){
local
; ">RPL(" . Preload . ")"
; ">MPL(" . MuliplePreloads . ")"
; ">UPL(" . Preload . ")(" . ChangeTo . ")"
if (Mode = "Preload")
	{
	StartPosition := 6
	ClosedBracketPos := Instr(Detection, ")",, StartPosition)
	PreloadLength := ClosedBracketPos - StartPosition
	Preload := SubStr(Detection, StartPosition , PreloadLength)
	return Preload
	}
else if (Mode = "ChangeTo")
	{
	SecondOpenBracketPos := Instr(Detection, "(",,, 2)
	SecondClosedBracketPos := Instr(Detection, ")",,, 2)
	ChangeToLength := SecondClosedBracketPos - SecondOpenBracketPos - 1
	ChangeTo := Substr(Detection, (SecondOpenBracketPos+1), ChangeToLength)
	return ChangeTo
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;   Basic WORK HOTKEYS   ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

+F5::
	Send, ^S
	SaveRemoteHistory("RELOAD")
	Reload
return

F12::
	SaveRemoteHistory("EXIT APP")
	if (DeleteHistory = true)
		FileDelete, %RemoteHistoryFile%
	ExitApp
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;    ADVANCED HOTKEYS    ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

+F10::
Gui 1:Destroy
;; Set Controls
1GuiControlArray := ["RemoteSimulation", "DeleteHistory", "RemoteHistoryOutput", "VerboseHistory"]
for i, control in 1GuiControlArray
	{
	ControlName := "c_" . control
	if (%control% = false)
		%ControlName% := 0
	else
		%ControlName% := 1
	}

Gui, 1: +AlwaysOnTop ToolWindow
Gui, 1:Add, CheckBox, x10 y10 w150  h20 Checked%c_RemoteSimulation% vc_RemoteSimulation, Remote Simulation 
Gui, 1:Add, CheckBox, x10 y32 w150  h20 Checked%c_RemoteHistoryOutput% 	vc_RemoteHistoryOutput, Remote History Output
Gui, 1:Add, CheckBox, x10 y54 w150  h20 Checked%c_VerboseHistory% 	vc_VerboseHistory, Verbose History
Gui, 1:Add, CheckBox, x10 y76 w150  h20 Checked%c_DeleteHistory% 	vc_DeleteHistory, Delete RemoteHistory
Gui, 1:Add, Button,   x50 y99 w50 h20 g1GuiSave, Save
Gui, 1:Show, Autosize Center, Remote Setup
return 

1GuiClose:
1GuiEscape:
Gui 1:Destroy
return 

1GuiSave:
Gui 1:Submit
1GuiControlArray := ["RemoteSimulation", "DeleteHistory", "RemoteHistoryOutput", "VerboseHistory"]
for i, control in 1GuiControlArray
	{
	ControlName := "c_" . control
	if (%ControlName% = 0)
		%control% := false
	else
		%control% := true
	}
SaveRemoteHistory("RemoteSimulation", RemoteSimulation)
SaveRemoteHistory("RemoteHistoryOutput", RemoteHistoryOutput)
SaveRemoteHistory("DeleteHistory", DeleteHistory)
SaveRemoteHistory("VerboseHistory", VerboseHistory)
Gui 1:Destroy
return 

;#Include ProTest_RemoteAddon.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;  Basic WORK FUNCTIONS  ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;  TEST AREA ;;;;;;;

^r::
return 

SaveRemoteHistory(params*){
local 
global RemoteHistoryFile, RemoteSimulation, VerboseHistory
global RemoteHistoryOutput
ListLines, OFF
TimeStemp := A_DDD . A_Space . A_DD . "." A_MMM . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec 
if (params.MaxIndex() = 1)
	SendHistory := TimeStemp . ": " . params[1]
else if (params.MaxIndex() = 2)
	SendHistory := TimeStemp . ": " . params[1] . A_Space .  "(" . params[2] . ")"

if (RemoteHistoryOutput = true)
	{
	if (VerboseHistory = true)
		FileAppend, %SendHistory%`n, %RemoteHistoryFile%
	else if (VerboseHistory = false AND params[1] != "VERBOSE:")
		FileAppend, %SendHistory%`n, %RemoteHistoryFile%
	}
ListLines, ON
}

CheckNipoWindow(){
global NipoFenster
ListLines, OFF
if !WinActive(NipoFenster)
	{
	WinActivate, %NipoFenster%
	WinWaitActive, %NipoFenster%
	}
ListLines, ON
}

ChangeWindowSettings(){
global NipoFenster
WinWaitActive, %NipoFenster%
if ErrorLevel
	return
WinGet, ExStyle, ExStyle, NipoFenster
if !(ExStyle & 0x8)
	{
	Winset, AlwaysOnTop, Off, %NipoFenster%
	WinActivate, %NipoFenster%
	}
}

;;; Tray Icon
AboutMessage:

; get Version from FileName
VersionStart := Instr(A_ScriptName, "_v") + 2
Version := Substr(A_ScriptName,VersionStart, 3)

Gui, 20:+AlwaysOnTop +ToolWindow
Gui, 20:add, Text, x10 y10 w150 Center, ProTest - Version %Version%
Gui, 20:add, Text, x10 y30 w150 Center, dietzste@hu-berlin.de
Gui, 20:show, Center Autosize, About ProTest
WinWaitActive, About ProTest
WinWaitClose, About ProTest
return
 

;CheckErrorWindow(){
;if WinExist("ahk_class #32770") AND WinExist("ahk.exe OdQeso.exe")
;}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;     PRELOAD FUNCTION      ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OpenPreloadMenu(){
global NipoFenster, ultrafast
if WinExist(NipoFenster)
	{
	if WinExist("Currently known variables")
		{
		if !WinActive("Currently known variables")
			WinActivate, Currently known variables
		return
		}
	else
		{
		if !WinActive(NipoFenster)
			WinActivate, %NipoFenster% 
		WinMenuSelectItem, %NipoFenster%, , View, View variables...
		WinWaitActive, Currently known variables
		return
		}
	}
else
	return
}

ClosePreloadMenu(){
if WinExist("Currently known variables")
	{
	if !WinActive("Currently known variables")
		WinActivate, Currently known variables
	ControlClick, &Close, Currently known variables,,,,NA
	}
}

GetPreloadListAutoEdit(){
local 
global PreloadList, NipoFenster
OpenPreloadMenu()
Control, Uncheck ,, &Show system variables, Currently known variables
Sleep, 1000 
ControlGet, PreloadList, List,, Listbox1, Currently known variables
Sleep, 600
ClosePreloadMenu()
return PreloadList
}

GetPreloadList(){
local 
global PreloadList, NipoFenster
if (WinActive("Currently known variables") AND PreloadList = "")
	{
	ControlGet, PreloadsInListe, List,, Listbox1, Currently known variables
	global PreloadList := PreloadsInListe
	}
}

ReadPreload(Preload){
local
global fast, PreloadList
OpenPreloadMenu()
GetPreloadList()
Sleep, fast
Send, %Preload%
Sleep, fast
PreloadExact := Preload . "`n"
If InStr(PreloadList, PreloadExact) 	; Preload found!
	{
	ControlClick, Edit1, Currently known variables,,,,NA
	ControlGetText, PreloadOriginal, Edit1, Currently known variables,,,,NA
	ControlClick, &Close, Currently known variables,,,,NA
	return PreloadOriginal
	}
else
	return "false"
}

CountMultiplePreloads(MultiplePreloads){
Loop, Parse, MultiplePreloads , "|"
	Count := A_Index
if (Count = 0)
	return 1
else
	return Count
}

ReadMultiplePreloads(MultiplePreloads){
local
global fast, PreloadList
OpenPreloadMenu()
GetPreloadList()
Sleep, fast
; Expract Preloads
; sexPRE|sexPRE|sexPRE
NPreloads := CountMultiplePreloads(MultiplePreloads)
MultiplePreloadValues := ""
Loop, Parse, MultiplePreloads , "|"
	{
	if (A_Index > 1)
		ControlClick, Listbox1, Currently known variables,,,, NA
	SaveRemoteHistory("VERBOSE:" , "Enter Preload " . A_LoopField)
	Sleep, fast
	SetKeyDelay, fast
	Send, %A_LoopField%
	Sleep, fast
	PreloadExact := A_LoopField . "`n"
	If InStr(PreloadList, PreloadExact) 	; Preload found!
		{
		ControlClick, Edit1, Currently known variables,,,,NA
		ControlGetText, PreloadOriginal, Edit1, Currently known variables,,,,NA
		}
	else
		{
		PreloadOriginal := "false"
		}
	SaveRemoteHistory("Preload: " . A_LoopField , "Value: " . PreloadOriginal)
	if (NPreloads = A_Index)
		{
		MultiplePreloadValues .= PreloadOriginal
		ControlClick, &Close, Currently known variables,,,,NA
		SaveRemoteHistory("MultiplePreloadValues: ", MultiplePreloadValues)
		return MultiplePreloadValues
		}
	else
		{
		MultiplePreloadValues .= PreloadOriginal . "|"
		}
	}	
}

UpdatePreload(Preload, ChangeTo){
local
global PreloadList, fast 
OpenPreloadMenu()
GetPreloadList()
Sleep, fast
Send, %Preload%
Sleep, fast
PreloadExact := Preload . "`n"
If InStr(PreloadList, PreloadExact)
	{
	ControlClick, Edit1, Currently known variables,,,,NA
	ControlGetText, PreloadOriginal, Edit1, Currently known variables,,,,NA
	PreloadOriginalLength := StrLen(PreloadOriginal)
	if (PreloadOriginalLength > 0)
		Send, {BS %PreloadOriginalLength%}%ChangeTo%
	else
		Send, %ChangeTo%
	ControlClick, &Update, Currently known variables,,,,NA
	ControlClick, &Close, Currently known variables,,,,NA
	return PreloadOriginal
	}
else 
	return "false"
}

L_WaitUntilPreloadsLoaded(){
local 
static StartTime := ""
StartTime := A_TickCount
SetTimer, PreloadsLoaded, 1000
PreloadsLoaded:
Loaded := IsButtonVisible("Button6")
ElapsedTime := A_TickCount - StartTime
if (ElapsedTime > 18000)
	{
	SetTimer, PreloadsLoaded, Off
	return 
	}
if (Loaded = true)
	{
	SetTimer, PreloadsLoaded, Off
	return
	}
else
	Goto PreloadsLoaded
return ; ! Label
}

SkipXModul(WaitForXModulSec){
local
global fast
SetTitleMatchMode, 2
XModulWindow := "X-Modul"
Send {Enter}
WinWaitActive, %XModulWindow%,, WaitForXModulSec
if ErrorLevel
    return false
else
	{
	Sleep, fast
	ControlClick, Ende, %XModulWindow%,,,, NA
	Sleep, fast
	XModulWindowFrage := "Frage"
	WinWaitActive, %XModulWindowFrage%,, 2
	if ErrorLevel
		return false
	else 
		ControlClick, Abbruch, %XModulWindowFrage%,,,, NA
	Sleep, fast
	XModulWindowNachFrage := "Nachfrage"
	WinWaitActive, %XModulWindowNachFrage%,, 2
	if ErrorLevel
		return false
	else 
		ControlClick, Abbrechen, %XModulWindowNachFrage%,,,, NA
	Sleep, fast
	XModulWindowBestätigung := "Bestätigung"
	WinWaitActive, %XModulWindowBestätigung%,, 2
	if ErrorLevel
		return false
	else 
		ControlClick, Ja, %XModulWindowBestätigung%,,,, NA
	Sleep, fast
	WinWaitActive, %XModulWindowNachFrage%,, 2
	if ErrorLevel
		return false
	else
		ControlClick, Ja, %XModulWindowNachFrage%,,,, NA
	L_WaitUntilPreloadsLoaded()
	return true
	}
}

IsButtonVisible(Button){
global NipoFenster
CheckNipoWindow()
ControlGet, ButtonVisible, Visible,, %Button%, %NipoFenster%
If (ErrorLevel = 1 OR ButtonVisible = 0)
	return false
else
	return true
}

;;;;;;;;; KlickeClearundBack ;;;;;;;;;; 
 
PgDn::
	KlickeClearundBack()
return

PgUp::
	KlickeVerweigert()
return

KlickeClearundBack(){
global NipoFenster
Sleep, 50
if (IsButtonVisible("&Back") = true)
	{
	ControlClick, &Clear, %NipoFenster%,,,, NA
	ControlClick, &Back, %NipoFenster%,,,, NA
	}
}

KlickeVerweigert(){
local
global NipoFenster
sleep, 50
if (IsButtonVisible("verweigert") = true)
	ControlClick, verweigert, %NipoFenster%,,,, NA
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


#PERSISTENT
Winset, AlwaysOnTop, Off, %NipoFenster%

;;;;;;;;;;;;;;;;;;;;
;;;;  INTERNA   ;;;;
;;;;;;;;;;;;;;;;;;;;

/*
Button1 OK
Button2 Start
Button3 &Nonresp &Dial Dial &2 &Clear &Back &Volume...
Button9 &Help
Button10 &Dont know
Button11 &Menu
Button12 &Next 
Button13 &Prev
Button14 verweigert
Button14 ZP verweigert Antwort auf diese Frage
Button14 Spiele nicht durchführen
Button14 bisher keine Betreuung in Anspruch genommen
Button14 hat keine Freunde
Button15 weiß nicht
Button16 Verhältnis lässt sich keiner der Kategorien zuordnen
Button16 gleich häufig Deutsch und Herkunftssprache
Button16 Ort nicht in Liste
Button17 wechselnde Orte
Button24 &Close
*/