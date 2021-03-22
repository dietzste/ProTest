;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;   REMOTE CONNECTION    ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
Onclipboardchange("ClipChanged", 0)
return

ClipChanged(Type){
local
global CurrentDetection := ""
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
global RemoteBuffer
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
global TimeOutRemoteTest, RemoteBuffer
global RemoteFeed := false
static Detection
static StartTime
StartTime := A_TickCount
ListLines Off
SendValue := ">Test"
SaveToHistory("VERBOSE:", SendValue)
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
if (WaitingForRemote < TimeOutRemoteTest)
	{
	if Instr(Detection, "<")
		RemoteFeed := true
	else
		{
		Sleep, fast 
		Goto TestFeedback
		}
	}
else if (WaitingForRemote > TimeOutRemoteTest)
	RemoteFeed := false
	
;;;;;  WAITING OVER  ;;;;;;;;;

CheckWorkWindow()
ListLines On
if (RemoteFeed = true)
	{
	if (Detection = "<Test")
		{
		SaveToHistory("VERBOSE:", Detection)
		ElapsedTime := A_TickCount - StartTime
		Msgbox, 4096, RemoteClient aktiv!, Synchronisation der Zwischenablage aktiv! (Delay: %ElapsedTime% ms)
		SaveToHistory("F9: RemoteClient aktiv (Delay: " . ElapsedTime . " ms)")
		return
		}
	}
else if (RemoteFeed = false)
	{
	Msgbox, 4096, Ups!, Keine Verbindung zum RemoteClient!
	SaveToHistory("F9: RemoteClient nicht aktiv (Timeout)")
	return 
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SendWait(SendValue, CheckWorkWindow){
local
global CurrentDetection
SaveToHistory("VERBOSE:", SendValue)
WaitForRemoteFeedback(SendValue)
if (CheckWorkWindow = true)
	CheckWorkWindow()
Detection := CurrentDetection
SaveToHistory("VERBOSE:", Detection)
return Detection
}

L_RestartQ(){
local
SendWait(">Restart", true)
}

L_WaitUntilPreloadsLoaded(){
local
MsgWindow("Lade Preload-Informationen...")
SendWait(">LoadingPreloads", true)
MsgWindow()
}

L_ReadPreload(Preload){
local
global CurrentLFD
global Privacy
global LFDSpeicherPfad, ProjectFile
SaveToHistory("VERBOSE:","Get Preload", Preload)
CheckFileFirst := true

; Load Preloads from File? (F8)
if (A_ThisLabel = "8GuiPreloads")
	CheckFileFirst := false

; Load Preloads from File
if (CheckFileFirst = true and CurrentLFD != "")
	{
	PreloadValue := GetIniValue(LFDSpeicherPfad, "LFD_" . CurrentLFD , Preload)
	if (PreloadValue != "ERROR" AND PreloadValue != "")
		return PreloadValue
	}
SendValue := ">RPL(" . Preload . ")"
Detection := SendWait(SendValue, false)
PreloadValue := RemoteExtraction(SendValue, Detection)
if (PreloadValue = "false")
	{
	Msgbox, 4096 ,%Preload%, "%Preload%" nicht vorhanden.
	Exit
	}
if (CurrentLFD != "")
	{
	CheckLFDSectionNames(CurrentLFD)
	if (Privacy = false)
		SaveIniValue(LFDSpeicherPfad, "LFD_" . CurrentLFD , Preload, PreloadValue)
	}
return PreloadValue
}

L_UpdatePreload(Preload, ChangeTo){
local
SendValue := ">UPL(" . Preload . ")(" . ChangeTo . ")"
Detection := SendWait(SendValue, false)
PreloadOriginal := RemoteExtraction(SendValue, Detection)
if (PreloadOriginal = "false")
	{
	Msgbox, 4096 ,%Preload%, "%Preload%" nicht vorhanden.
	Exit
	}
return PreloadOriginal
}

L_LoadPreloadList(){
local
global PreloadList, PreloadListPath
SendValue := ">PreloadList"
Detection := SendWait(SendValue, false)
PreloadList := RemoteExtraction(SendValue, Detection)
if (Privacy = false)
	FileAppend , %PreloadList%, %PreloadListPath%
}

L_SkipXModul(){
local
global WaitForXModulSec
SendValue := ">SkipXModul," . WaitForXModulSec
Sleep, 1050 ; Due to OCR Overload
Detection:= SendWait(SendValue, true)
Result := RemoteExtraction(SendValue, Detection)
return Result ; Result: "false" / "true"
}

L_GetNextLFD(){
local
SendValue := ">GetNextLFD"
Detection := SendWait(SendValue, true)
NextLFD := RemoteExtraction(SendValue, Detection)
if (NextLFD != "Error")
	return NextLFD
else
	{
	Msgbox, 4096, Ups!, Das Auslesen der LFD schlug fehl. LFD-Suche wird beendet.
	Exit
	}
}

L_ExcludeHopelessLFDs(HopelessLFDString){
local
if (HopelessLFDString = "")
	SendValue := ">ExcludeHopelessLFDs"
else
	SendValue := ">ExcludeHopelessLFDs=" . HopelessLFDString
Detection := SendWait(SendValue, true)
}

L_TryClickingButton(Button, Count){
local
SendValue := ">ClickButton=" . Count . "," . Button
Detection := SendWait(SendValue, true)
Result := RemoteExtraction(SendValue, Detection)
return Result ; Result: "false" / "true"
}

L_ReadMultiplePreloads(CurrentLFD, PreloadString, PreTested := true){
local
global LFDSpeicherPfad
global MissingPreloadString := ""
global Privacy

; (1) PreTested?
if (PreTested = true)
	MissingPreloadString := PreloadString
else
	{
	MissingPreloadString := CheckingLFDValues(CurrentLFD, PreloadString)
	if (MissingPreloadString = "")
		return
	}
	
; Sending MissingPreloadString / Waiting / Return 
SendValue := ">MPL(" . MissingPreloadString . ")"
Detection := SendWait(SendValue, false)
MultiplePreloadValues := RemoteExtraction(SendValue, Detection)
; Beispiel: 18|9|1990
Loop, Parse, MissingPreloadString, "|"
	{
	PreloadIndex := A_Index
	Preload := A_LoopField
	Loop, Parse, MultiplePreloadValues, "|"
		{
		if (A_Index = PreloadIndex)
			{
			PreloadValue := A_LoopField
			if (PreloadValue = "false")
				return PreloadNotExisting := Preload
			else
				{
				if (CurrentLFD != "")
					CheckLFDSectionNames(CurrentLFD)
				if (Privacy = false)
					SaveIniValue(LFDSpeicherPfad, "LFD_" . CurrentLFD, Preload, PreloadValue)
				}
			}
		} ; ende inner loop
	} ; end outer loop
}

CheckingLFDValues(CurrentLFD, PreloadString){
local
global LFDSpeicherPfad
global MultiplePreloadArray
NMissingPreloads := 0
MissingPreloadString := ""

Loop, Parse, PreloadString , "|"
	{
	Preload := A_Loopfield
	if Preload is digit
		Continue
	PreloadValue := GetIniValue(LFDSpeicherPfad, "LFD_" . CurrentLFD , Preload, "Missing")
	if (PreloadValue = "Missing")
		{
		++NMissingPreloads
		if (NMissingPreloads = 1)
			MissingPreloadString .= Preload
		else
			MissingPreloadString .= "|" . Preload
		}
	else
		SaveToHistory("VERBOSE:", Preload . " bereits vorhanden", "Wert: " . PreloadValue)
	} ; ende for loop
if (NMissingPreloads = 0)
	SaveToHistory("VERBOSE:", "Alle Preloads im LFDSpeicher")
else
	SaveToHistory("VERBOSE:", "fehlende Preloadwerte im LFDSpeicher:" . NMissingPreloads)
return MissingPreloadString
}