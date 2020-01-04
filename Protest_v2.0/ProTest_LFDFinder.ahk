;;;;;;;;;;;;;;;;;;;;;;;;
;; LFD Finder Routine ;;
;;;;;;;;;;;;;;;;;;;;;;;;

LFDFinderRoutine(){
local
global ae
global ProjectFile

; (1) Create Arrays - Request/Exclude-Array
CreateLFDArrays()

; (2) Check existing LFDs in TempFile
LFDFound := CheckExistingLFDs()
if (LFDFound = true)
	return 

; (3) Get Search Criteria (F3 Menu)
global e_CheckAgain := GetIniValue(ProjectFile, "LFDFinderMenu", "e_CheckAgain", 10)
global e_AbortSearch := GetIniValue(ProjectFile, "LFDFinderMenu", "e_AbortSearch", 20)
global c_CheckAgain := GetIniValue(ProjectFile, "LFDFinderMenu", "c_CheckAgain", 1)
global c_AbortSearch := GetIniValue(ProjectFile, "LFDFinderMenu", "c_AbortSearch", 1)
global CurrentLFD := GetIniValue(ProjectFile, "LFDFinderMenu", "cb_StartLFD")
static NeedRemotePreloads := false
static LFDWasEntered := false

; (4) Start Loop
SaveToHistory("START LFD-Suche LFD: " . CurrentLFD)
loop {
; Current State
global LFDCount := A_Index - 1
SaveToHistory("LFD-Suche Loop: " . A_Index)

; (4a) Create Array for Current LFD
CreateMultiplePreloadArray(CurrentLFD)

; (4b) Check Missing Preloads
MultiplePreloads := CheckingLFDValues(CurrentLFD)
if (MultiplePreloads = "")
	NeedRemotePreloads := false
else
	NeedRemotePreloads := true

; No Missing Preloads in TempFile (+ Already Checked Existing LFD's)
if (NeedRemotePreloads = false)
	{
	SaveToHistory("VERBOSE:", "Hole n" . ae . "chste LFD")
	if (A_Index = 1)
		Send, %CurrentLFD%{Enter}
	if (LFDWasEntered = true)
		NextLFD := L_GetNextLFD(2)
	else
		NextLFD := L_GetNextLFD(1)
	LFDWasEntered := false
	SaveToHistory("N" . ae . "chste LFD: " . NextLFD)
	CurrentLFD := NextLFD
	Continue
	} ; ende if
	
; Missing Preloads in TempFile 
if (NeedRemotePreloads = true)
	{
	if (LFDWasEntered = false)
		{
		EnterLFD(CurrentLFD)
		SaveToHistory("VERBOSE:", "Enter LFD" . CurrentLFD)
		}
	else
		{
		EnteredLFD := L_EnterNextLFD()
		SaveToHistory("N" . ae . "chste LFD: " . EnteredLFD)
		CurrentLFD := EnteredLFD
		}
	LFDWasEntered := true
	L_WaitUntilPreloadsLoaded()
	L_ReadMultiplePreloads()
	} ; ende if
	
; Checking LFD Values
CreateMultiplePreloadArray(CurrentLFD)
LFDFound := ComparePreloadArrays(CurrentLFD)

if (LFDFound = true)
	{
	ShowMatchLFDMessage()
	SaveToHistory("ENDE LFD-Suche - Match mit " . CurrentLFD)
	return 
	}
else
	Continue
} ; ende Loop
} ; Ende LFDFinderRoutine

;;; LFD MATCH WINDOW ;;;  

LFDMatchWindow:
Gui, 33:+AlwaysOnTop ToolWindow 
Gui, 33:Add, Picture, Center x50 y10 w40 h-1, % HeartPicture
Gui, 33:Add, Text, x10 y55 w130 h20, Passende LFD gefunden!
Gui, 33:Add, Button, x50 y80 w50 h20 Default g33GuiOK, OK
Gui, 33:Show, Center Autosize, %MatchWindowName%!
return

33GuiClose:
33GuiEscape:
33GuiOK:
Gui 33:Destroy
return 

ShowMatchLFDMessage(){
local
global CurrentLFD
global MsgDurationLFDMatch
global MatchWindowName := "Match mit " . CurrentLFD 
Gosub LFDMatchWindow
if (MsgDurationLFDMatch > 0)
	{
	Sleep, MsgDurationLFDMatch
	Gui 33:Destroy
	WinWaitClose, %MatchWindowName%
	}
else
	{
	WinWaitActive, %MatchWindowName%
	WinWaitClose, %MatchWindowName%
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CreateLFDArrays(){
local 
global ProjectFile, ue
global LFDFinderMenu
global LFDRequestArray := {}
global LFDExcludeArray := {}
ListLines, OFF
SaveToHistory("VERBOSE:", "Erstelle LFDRequest/LFDExclude-Array")
Loop, 8 {
Preload := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLN" . A_Index)
if (Preload != "ERROR")
	{
	; Preload in PreloadList?
	CheckPreloadInPreloadList(Preload)
	; Add to Arrays
	PreloadRequest := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLR" . A_Index, "-")
	PreloadExclude := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLE" . A_Index, "-")
	if (PreloadRequest != PreloadExclude)
		{
		LFDRequestArray[Preload] := PreloadRequest
		LFDExcludeArray[Preload] := PreloadExclude
		}
	else
		{
		if (PreloadRequest != "ERROR")
			{
			Msgbox, 4096, Ups! , Identische Werte f%ue%r %Preload% (Werte = %PreloadRequest%)!
			SaveToHistory("VERBOSE:", "Identische Werte - LFD-Suche wird abgebrochen")
			ListLines, ON
			Exit
			}
		}
	}
} ; ende loop
NPreloads := LFDRequestArray.Count()
SaveToHistory("Es wurden " . NPreloads . " Preload(s) definiert")
ListLines, ON
if (NPreloads = 0)
	{
	Msgbox, 4096, Ups! , Keine Preloads definiert! LFD-Suche wird beendet!
	ListLines, ON
	Exit
	}
return
} ; ende function CreateLFDArrays

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CreateMultiplePreloadArray(CurrentLFD){
local
global TempFile
global LFDRequestArray
global MultiplePreloadArray := {}
ListLines, OFF
for Preload, v in LFDRequestArray
	{
	PreloadValue := GetIniValue(TempFile, "LFD_" . CurrentLFD , Preload, "Missing")
	MultiplePreloadArray[Preload] := PreloadValue
	}
NPreloads := MultiplePreloadArray.Count()
SaveToHistory("VERBOSE:", "MultiplePreloadArray erstellt n=" . NPreloads, CurrentLFD)
ListLines, ON
}


ComparePreloadArrays(CurrentLFD){
local 
global LFDRequestArray, LFDExcludeArray 
global MultiplePreloadArray
SaveToHistory("VERBOSE:", "Compare PreloadArrays")
for Preload, PreloadValue in MultiplePreloadArray
	{
	; Request Array 
	RequestedPreloadValue := LFDRequestArray[Preload]
	if (PreloadValue != RequestedPreloadValue)
		{
		SaveToHistory(CurrentLFD . ": No Match for " . Preload, "Wunschwert: " . RequestedPreloadValue, "Gefunden:" . PreloadValue)
		LFDWithNoMatch(CurrentLFD)
		return false
		}
	else
		SaveToHistory(CurrentLFD . ": Match for " . Preload, "Wunschwert: " . RequestedPreloadValue, "Gefunden:" . PreloadValue)
	; Exclude Array 
	ExcludedPreloadValue  := LFDExcludeArray[Preload]
	If (PreloadValue = ExcludedPreloadValue)
		{
		SaveToHistory(CurrentLFD . ": Bad Match for " . Preload, "PreloadValue=" . ExcludedPreloadValue)
		LFDWithNoMatch(CurrentLFD)
		return false
		}
	} ; ende for-loop
return true  
}

LFDWithNoMatch(CurrentLFD){
local
global e_CheckAgain, e_AbortSearch
global c_CheckAgain, c_AbortSearch
global ue, GuiF3
global LFDCount
if (c_CheckAgain = 1 AND LFDCount = e_CheckAgain)
	{
	Msgbox,4132, Fortfahren?, Es wurden %e_CheckAgain% LFD's durchsucht. Fortfahren?
	IfMsgBox YES
		{
		SaveToHistory("LFD-Suche fortsetzen? - Ja")
		return
		}
	else
		{
		SaveToHistory("LFD-Suche fortsetzen? - Nein")
		Exit
		}
	}
if (c_AbortSearch = 1 AND LFDCount = e_AbortSearch)
	{
	Msgbox, 4096 , %GuiF3% , Es wurden %e_AbortSearch% LFD's durchsucht. Suche wird beendet!
	SaveToHistory("LFD-Suche beendet n=" . e_AbortSearch)
	Exit
	}
SaveToHistory("VERBOSE:", CurrentLFD . " erf" . ue . "llt nicht Kriterien", "Loop: " . LFDCount)
}

;;; CHECK Existing LFD's 

CheckExistingLFDs(){
local
global TempFile
global LFDsInTempFileArray
; Create Array: LFDs in TempFile
LFDListTempFile := GetIniSectionNames(TempFile)
Loop, Parse, LFDListTempFile, "`n"
	{
	if Instr(A_LoopField, "LFD_")
		{
		; Bsp. LFD_71100001 / Push LFD to Array
		LFD := Substr(A_LoopField, 5)
		LFDsInTempFileArray[A_Index] := LFD
		}
	} ; ende loop

; Check LFD's
if (LFDsInTempFileArray.Count() != 0)
	SaveToHistory("Durchsuche existierende LFDs")
for i, LFD in LFDsInTempFileArray
	{
	CreateMultiplePreloadArray(LFD)
	LFDFound := ComparePreloadArrays(LFD)
	if (LFDFound = true)
		{
		global CurrentLFD := LFD
		EnterLFD(CurrentLFD)
		L_WaitUntilPreloadsLoaded()
		ShowMatchLFDMessage()
		SaveToHistory("Passende LFD im TempFile: " . CurrentLFD)
		return true
		} ; ende if
	} ; ende for loop
return false
} ; ende function