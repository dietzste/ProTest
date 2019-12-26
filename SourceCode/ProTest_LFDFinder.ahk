;;;;;;;;;;;;;;;;;;;;;;;;
;; LFD Finder Routine ;;
;;;;;;;;;;;;;;;;;;;;;;;;

LFDFinderRoutine(){
local
global ProjectFile
global LFDFound := false
global CurrentLFD
global ae, med
static NeedRemotePreloads
static LFDWasEntered
GetSearchCriteria()
CreateLFDArrays()
LFDFound := CheckExistingLFDs()
if (LFDFound = true)
	return 
CurrentLFD := GetIniValue(ProjectFile, "LFDFinderMenu", "cb_StartLFD")
NeedRemotePreloads := false
LFDWasEntered := false
SaveToHistory("START LFD-Suche LFD: " . CurrentLFD)
loop {
SaveToHistory("LFD-Suche Loop: " . A_Index)
CreateMultiplePreloadArray("LFDSearch")
CheckingLFDValues(NMissingPreloads)
if (NMissingPreloads = 0)
	{
	NeedRemotePreloads := false
	LFDFound := ComparePreloadArrays(A_Index, CurrentLFD)
	}
else
	{
	NeedRemotePreloads := true
	LFDFound := false
	}
	
if (LFDFound = true)
	{
	SaveToHistory("VERBOSE:", "Passende LFD gefunden")
	if (A_Index = 1)
		EnterLFD(CurrentLFD, "LFDSearch")
	else
		{
		if (LFDWasEntered = true)
			{
			ShowMatchLFDMessage(2000)
			return
			}
		else
			{
			ShowMatchLFDMessage(2000)
			Send, {Enter}
			}
		}
	L_WaitUntilPreloadsLoaded()
	SaveToHistory("ENDE LFD-Suche - Match mit " . CurrentLFD)
	ShowMatchLFDMessage("No")
	return
	}
else
	{
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
		}
	else if (NeedRemotePreloads = true)
		{
		if (LFDWasEntered = false)
			{
			SaveToHistory("VERBOSE:", "Enter n" . ae . "chste LFD")
			Send, %CurrentLFD%{Enter}{Enter}
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
		Continue
		}
	} ; ende else
} ; ende Loop
} ; Ende LFDFinderRoutine

ShowMatchLFDMessage(SleepTime){
local
global CurrentLFD
global MatchWindowName := "Match mit " . CurrentLFD 
Gosub LFDMatchWindow
if (SleepTime != "No")
	{
	Sleep, SleepTime
	Gui 33:Destroy
	WinWaitClose, %MatchWindowName%
	}
else
	{
	WinWaitActive, %MatchWindowName%
	WinWaitClose, %MatchWindowName%
	}
}

CreateLFDArrays(){
local 
global LFDFinderMenu, PreloadList
global ProjectFile, ue
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

CreateMultiplePreloadArray(Mode, params*){
local
global TempFile, CurrentLFD
global MultiplePreloadArray := {}
ListLines, OFF
if (Mode = "GetDateOfBirth")
	{
	loop, 3 {
	Preload := params[A_Index]
	PreloadValue := GetIniValue(TempFile, "LFD_" . CurrentLFD , Preload, "Missing")
	MultiplePreloadArray[Preload] := PreloadValue
	} ; ende loop
	} ; ende if 
else if (Mode = "LFDSearch")
	{
	global LFDRequestArray
	for Preload, v in LFDRequestArray
		{
		PreloadValue := GetIniValue(TempFile, "LFD_" . CurrentLFD , Preload, "Missing")
		MultiplePreloadArray[Preload] := PreloadValue
		}
	}
NMissingPreloads := MultiplePreloadArray.Count()
SaveToHistory("VERBOSE:", "MultiplePreloadArray erstellt n=" . NMissingPreloads, CurrentLFD)
ListLines, ON
}

EnterLFD(LFD, Mode){
local
global fast, med, 
CheckWorkWindow()
SetKeyDelay, med
if (Mode = "LFDSearch")
	Send, %LFD%{Enter}
else
	{
	Send, %LFD%{Enter}
	sleep, fast 
	Send, {Enter}
	}
SetKeyDelay, fast
}

ComparePreloadArrays(LFDCount, CurrentLFD){
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
		LFDWithNoMatch(LFDCount, CurrentLFD)
		return false
		}
	else
		SaveToHistory(CurrentLFD . ": Match for " . Preload, "Wunschwert: " . RequestedPreloadValue, "Gefunden:" . PreloadValue)
	; Exclude Array 
	ExcludedPreloadValue  := LFDExcludeArray[Preload]
	If (PreloadValue = ExcludedPreloadValue)
		{
		SaveToHistory(CurrentLFD . ": Bad Match for " . Preload, "PreloadValue=" . ExcludedPreloadValue)
		LFDWithNoMatch(LFDCount, CurrentLFD)
		return false
		}
	} ; ende for-loop
return true  
}

LFDWithNoMatch(LFDCount, CurrentLFD){
local
global e_AbortSearch, e_CheckAgain
global AbortSearch, CheckAgain
global ue, GuiF3, ProjectFile
Index := LFDCount - 1
if (CheckAgain = true AND Index = e_CheckAgain)
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
if (AbortSearch = true AND Index = e_AbortSearch)
	{
	Msgbox, 4096 , %GuiF3% , Es wurden %e_AbortSearch% LFD's durchsucht. Suche wird beendet!
	SaveToHistory("LFD-Suche beendet n=" . e_AbortSearch)
	Exit
	}
SaveToHistory("VERBOSE:", CurrentLFD . " erf" . ue . "llt nicht Kriterien", "Loop: " . LFDCount)
}

GetSearchCriteria(){
local
global ProjectFile
global CheckAgain := false
global AbortSearch := false
c_CheckAgain := GetIniValue(ProjectFile, "LFDFinderMenu", "c_CheckAgain", 1)
c_AbortSearch := GetIniValue(ProjectFile, "LFDFinderMenu", "c_AbortSearch", 1)
if (c_CheckAgain = 1)
	{
	global e_CheckAgain := GetIniValue(ProjectFile, "LFDFinderMenu", "e_CheckAgain", 10)
	global CheckAgain := true
	}
if (c_AbortSearch = 1)
	{
	global e_AbortSearch := GetIniValue(ProjectFile, "LFDFinderMenu", "e_AbortSearch", 20)
	global AbortSearch := true
	}
}

CheckExistingLFDs(){
local
global TempFile
global MultiplePreloadArray := {}
global CurrentLFD
global LFDRequestArray
SaveToHistory("Durchsuche existierende LFDs")
LFDListTempFile := GetIniSectionNames(TempFile)
Loop, Parse, LFDListTempFile, "`n"
	{
	MultiplePreloadArray := {}
	if Instr(A_LoopField, "LFD_")
		{
		LFD := Substr(A_LoopField, 5)
		SaveToHistory("VERBOSE:", "Durchsuche " . LFD)
		for Preload, v in LFDRequestArray
			{
			PreloadValue := GetIniValue(TempFile, "LFD_" . LFD , Preload, "Missing")
			MultiplePreloadArray[Preload] := PreloadValue
			}
		LFDFound := ComparePreloadArrays(1, LFD)
		if (LFDFound = true)
			{
			CurrentLFD := LFD
			SaveToHistory("Passende LFD gefunden: " . CurrentLFD)
			ShowMatchLFDMessage(2000)
			EnterLFD(CurrentLFD, "LFDCheck")
			L_WaitUntilPreloadsLoaded()
			return true
			}
		} ; ende if
	} ; ende outer loop
return false
} ; ende function

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