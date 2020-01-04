;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;   REMOTE CONNECTION    ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
Onclipboardchange("ClipChanged", 0)
return

ClipChanged(Type){
local
global CurrentDetection := ""
global RemoteBuffer, RemoteFeed
global RemoteFeed := false
If (Type = 1)
	{
	if InStr(Clipboard, "<")
		{
		ListLines Off
		Detection := Clipboard
		SaveToHistory("VERBOSE:", "RemoteFeedBack: " . Detection)
		Onclipboardchange("ClipChanged", 0)
		CurrentDetection := Detection
		ListLines On
		Pause
		}
	}
}

WaitForRemoteFeedback(SendValue){
local
global RemoteBuffer, TempFile
Clipboard = 
Clipboard := SendValue
ClipWait, 1
Sleep, RemoteBuffer
SaveToHistory("VERBOSE:", "SendValue: " . SendValue, "Clipboard: " .  Clipboard)
CheckWorkWindow()
SendInput, {Pause}
Onclipboardchange("ClipChanged", 1)
Pause
}

RemoteExtraction(SendValue, Detection){
local
ResultPosition := 2
SendValueLength := Strlen(SendValue) + ResultPosition
ExtractedValue := SubStr(Detection, SendValueLength)
return ExtractedValue
}

;; RemoteFeedBackTest ;;

L_RemoteFeedbackTest(){
local
global fast 
global TempFile, TimeOutTest, RemoteBuffer
global RemoteFeed := false
static Detection
static StartTime
StartTime := A_TickCount
ListLines Off
SendValue := ">Test"
SaveToHistory(SendValue)
CheckWorkWindow()
Clipboard := SendValue
ClipWait, 1
SendInput, {Pause}
TimeRemoteSend := A_TickCount
;;;;; WAITING ;;;;
TestFeedback:
Sleep, RemoteBuffer
Detection := Clipboard
WaitingForRemote := A_TickCount - TimeRemoteSend
if (WaitingForRemote < TimeOutTest)
	{
	if Instr(Detection, "<")
		RemoteFeed := true
	else
		{
		Sleep, fast 
		Goto TestFeedback
		}
	}
else if (WaitingForRemote > TimeOutTest)
	RemoteFeed := false
	
;;;;;  WAITING OVER  ;;;;;;;;;

CheckWorkWindow()
ListLines On
if (RemoteFeed = true)
	{
	if (Detection = "<Test")
		{
		SaveToHistory(Detection)
		ElapsedTime := A_TickCount - StartTime
		Msgbox, 4096, Positive Feedback! , Remote feedback active :)! (Delay: %ElapsedTime% ms)
		return
		}
	}
else if (RemoteFeed = false)
	{
	Msgbox, 4096, No Feedback!, No Remote feedback :(!
	SaveToHistory("TIMEOUT", "No Remote Feedback")
	return 
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

L_WaitUntilPreloadsLoaded(){
local
global CurrentDetection
SendValue := ">LoadingPreloads"
SaveToHistory(SendValue)
WaitForRemoteFeedback(SendValue)
CheckWorkWindow()
Detection := CurrentDetection
SaveToHistory(Detection)
if (Detection = "<LoadingComplete")
	return true
}

L_ReadPreload(Preload){
local
global TempFile, CurrentLFD, ProjectFile
global RemoteFeed, CurrentDetection

CheckFileFirst := true
; Load Preloads from File
if (A_ThisLabel = "8GuiPreloads")
	{
	c_LoadSavedValues := GetIniValue(ProjectFile, "PreloadReaderMenu", "c_LoadSavedValues")
	if (c_LoadSavedValues = 1)
		CheckFileFirst := true
	else
		CheckFileFirst := false
	}
if (CheckFileFirst = true)
	{
	PreloadValue := GetIniValue(TempFile, "LFD_" . CurrentLFD , Preload)
	if (PreloadValue != "ERROR" AND PreloadValue != "")
		{
		SaveToHistory("LOADED", Preload . "=" . PreloadValue, "from " .  TempFile)
		return PreloadValue
		}
	}

SendValue := ">RPL(" . Preload . ")"
SaveToHistory(SendValue)
WaitForRemoteFeedback(SendValue)
Detection := CurrentDetection
SaveToHistory(Detection)
PreloadValue := RemoteExtraction(SendValue, Detection)
SaveIniValue(TempFile, "LFD_" . CurrentLFD , Preload, PreloadValue)
SaveToHistory("VERBOSE:", Preload . "=" .  PreloadValue, "Result L_ReadPreload")
; Preloadvalue or "false"
return PreloadValue
}

L_UpdatePreload(Preload, ChangeTo){
local
global TempFile, CurrentLFD 
global CurrentDetection
SendValue := ">UPL(" . Preload . ")(" . ChangeTo . ")"
SaveToHistory(SendValue)
WaitForRemoteFeedback(SendValue)
Detection := CurrentDetection
SaveToHistory(Detection)
PreloadValue := RemoteExtraction(SendValue, Detection)
return PreloadValue
}

L_LoadPreloadList(){
local
global PreloadList, PreloadListPath
global CurrentDetection
SendValue := ">PreloadList"
SaveToHistory(SendValue)
WaitForRemoteFeedback(SendValue)
Detection := CurrentDetection
SaveToHistory("<PreloadList")
PreloadList := RemoteExtraction(SendValue, Detection)
FileAppend , %PreloadList%, %PreloadListPath%
return
}

L_SkipXModul(){
local
global CurrentDetection
global WaitForXModulSec
SendValue := ">SkipXModul," . WaitForXModulSec
SaveToHistory(SendValue)
WaitForRemoteFeedback(SendValue)
CheckWorkWindow()
Detection := CurrentDetection
SaveToHistory(Detection)
Result := RemoteExtraction(SendValue, Detection)
; Result:
; 0 = false
; 1 = true
return Result
}

L_EnterNextLFD(){
local
global CurrentDetection
SendValue := ">EnterNextLFD"
SaveToHistory(SendValue)
WaitForRemoteFeedback(SendValue)
CheckWorkWindow()
Detection := CurrentDetection
SaveToHistory(Detection)
EnteredLFD := RemoteExtraction(SendValue, Detection)
if (EnteredLFD != "Error")
	return EnteredLFD
else
	{
	Msgbox, 4096, Ups!, Das Auslesen der LFD schlug fehl. LFD-Suche wird beendet.
	Exit
	}
}

L_GetNextLFD(NClickBackButton){
local
global CurrentDetection
SendValue := ">GetNextLFD." . NClickBackButton
SendValueClean := StrReplace(SendValue, "." . NClickBackButton)
SaveToHistory(SendValueClean)
WaitForRemoteFeedback(SendValue)
CheckWorkWindow()
Detection := CurrentDetection
DetectionClean := StrReplace(Detection, "." . NClickBackButton)
SaveToHistory(DetectionClean)
NextLFD := RemoteExtraction(SendValue, Detection)
if (NextLFD != "Error")
	return NextLFD
else
	{
	Msgbox, 4096, Ups!, Das Auslesen der LFD schlug fehl. LFD-Suche wird beendet.
	Exit
	}
}

L_TryClickingButton(Button, Count){
local
global CurrentDetection
SendValue := ">ClickButton=" . Count . "," . Button
SaveToHistory(SendValue)
WaitForRemoteFeedback(SendValue)
CheckWorkWindow()
Detection := CurrentDetection
SaveToHistory(Detection)
Result := RemoteExtraction(SendValue, Detection)
; Result:
; "false"
; "true"
return Result
}

L_ReadMultiplePreloads(params*){
local
global TempFile, CurrentLFD
global CurrentDetection
global MultiplePreloadArray

; Checking Existing LFD-Values
MultiplePreloads := CheckingLFDValues(NMissingPreloads)
if (MultiplePreloads = "")
	return	
	
; Sending MultiplePreloads / Waiting / Return 
SendValue := ">MPL(" . MultiplePreloads . ")"
SaveToHistory(SendValue)
WaitForRemoteFeedback(SendValue)
Detection := CurrentDetection
SaveToHistory(Detection)
MultiplePreloadValues := RemoteExtraction(SendValue, Detection)
; Beispiel: 18|9|1990
Loop, Parse, MultiplePreloads, "|"
	{
	PreloadIndex := A_Index
	Preload := A_LoopField
	Loop, Parse, MultiplePreloadValues, "|"
		{
		if (A_Index = PreloadIndex)
			{
			PreloadValue := A_LoopField
			if (PreloadValue != "false")
				{
				MultiplePreloadArray[Preload] := PreloadValue
				SaveIniValue(TempFile, "LFD_" . CurrentLFD, Preload, PreloadValue) 
				}
			else
				{
				Msgbox, 4096, Ups!, Preload "%Preload%" war nicht vorhanden. LFD-Suche wird beendet.
				SaveToHistory("VERBOSE:", "Preload " . Preload . " gab es nicht!")
				Exit
				}
			}
		} ; ende inner loop
	} ; end outer loop
}

CheckingLFDValues(Byref NMissingPreloads){
local
global TempFile, CurrentLFD
global MultiplePreloadArray
MultiplePreloads := ""
NMissingPreloads := 0
for Preload, PreloadValue in MultiplePreloadArray
	{
	if (PreloadValue = "Missing")
		{
		++NMissingPreloads
		if (NMissingPreloads = 1)
			MultiplePreloads .= Preload
		else
			MultiplePreloads .= "|" . Preload 
		}
	else
		SaveToHistory("VERBOSE:", Preload . " bereits vorhanden", "Wert: " . PreloadValue)
	} ; ende for loop
if (NMissingPreloads = 0)
	SaveToHistory("VERBOSE:", "Alle Preloads in TempFile")
else
	SaveToHistory("VERBOSE:", "fehlende Preloadwerte in TempFile:" . NMissingPreloads)
return MultiplePreloads
}