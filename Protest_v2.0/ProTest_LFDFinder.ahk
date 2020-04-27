;;;;;;;;;;;;;;;;;;;;;;;;
;; LFD Finder Routine ;;
;;;;;;;;;;;;;;;;;;;;;;;;

LFDFinderRoutine(){
local
global ae
global LFDFinderMenu
global ProjectFile
global HopelessLFDArray := {}
global DefinedPreloadsArray := {}

; (1) Process F3Menu Input; Create Arrays - Request/Exclude-Array
global DefinedPreloads := ProcessingF3MenuInput()
if (DefinedPreloads != 0)
	{
	SaveToHistory("STARTE LFD-Suche")
	SaveToHistory("Es wurden " . DefinedPreloads . " Preload(s) definiert")
	for Preload, DefinedValue in DefinedPreloadsArray
		{
		SaveToHistory(Preload " = " DefinedValue)
		}
	}
else
	{
	Msgbox, 4096, Ups! , Keine Preloads definiert! LFD-Suche wird beendet!
	Exit
	}

; (2) Get Search Criteria (F3 Menu)
global e_CheckAgain := GetIniValue(ProjectFile, LFDFinderMenu, "e_CheckAgain", 10)
global e_AbortSearch := GetIniValue(ProjectFile, LFDFinderMenu, "e_AbortSearch", 20)
global c_CheckAgain := GetIniValue(ProjectFile, LFDFinderMenu, "c_CheckAgain", 1)
global c_AbortSearch := GetIniValue(ProjectFile, LFDFinderMenu, "c_AbortSearch", 1)
global CurrentLFD := GetIniValue(ProjectFile, LFDFinderMenu, "cb_StartLFD")

; (3) Pre-Check existing LFDs in TempFile
global c_CheckTempFileFirst := GetIniValue(ProjectFile, "LFDFinderMenu", "c_CheckTempFileFirst", 1)
if (c_CheckTempFileFirst = 1)
	{
	CreateLFDsInTempFileArray()
	LFDFound := CheckExistingLFDPreloads()
	if (LFDFound = true)
		{
		SaveToHistory("Passende LFD im TempFile: " . CurrentLFD)
		ShowMatchLFDMessage()
		EnterLFD(CurrentLFD)
		L_WaitUntilPreloadsLoaded()
		return
		}
	else
		{
		HopelessLFDString := ""
		if (HopelessLFDArray.Count() != 0)
			{
			; Send HopelessLFDs to RemoteClient!
			For HopelessLFD, i in HopelessLFDArray
				{
				if (A_Index = 1)
					HopelessLFDString .= HopelessLFD
				else
					HopelessLFDString .= "|" . HopelessLFD
				}
			L_ExcludeHopelessLFDs(HopelessLFDString)
			}
		else
			L_ExcludeHopelessLFDs("")
		} ; ende else
	} ; ende if
else
	L_ExcludeHopelessLFDs("")


; Start LFD Search Loop
LFDSearchLoop()
} ; Ende LFDFinderRoutine
	
LFDSearchLoop(){
local
global HopelessLFDArray
global LFDCount := 1
global CurrentLFD

loop {

; (1) Enter Start LFD
if (A_Index = 1)
	LFDProcessing("Start")

; (2) Current LFD already tested?
if (HopelessLFDArray[CurrentLFD] != true)
	{
	LFDFound := CompareRoutine()
	if (LFDFound = true)
		{
		LFDProcessing("Finish")
		return 
		}
	}
	
LFDProcessing("NeedNextLFD")
Continue
} ; ende loop
} ; ende function LFDSearchLoop


LFDProcessing(Command){
local
global ae
global CurrentLFD
global LFDCount

; LFDStatus
; 1 - LFD Choice Page
; 2 - LFD Choice Page + Enter
; 3 - LFD Infos Retrieved 

if (Command = "Start")
	{
	static LFDStatus := 1
	Send, %CurrentLFD%{Enter}
	LFDStatus := 2
	return
	}
else if (Command = "NeedNextLFD")
	{
	SaveToHistory("VERBOSE:", "Hole n" . ae . "chste LFD")
	if (LFDStatus = 2)
		NextLFD := L_GetNextLFD(1)
	if (LFDStatus = 3)
		NextLFD := L_GetNextLFD(2)
	SaveToHistory("N" . ae . "chste LFD: " . NextLFD . " LFD #" . LFDCount)
	CurrentLFD := NextLFD
	LFDStatus := 2
	return
	}
else if (Command = "NeedPreloads")
	{
	++LFDCount
	if (LFDStatus = 2)
		{
		SaveToHistory("VERBOSE:", "Enter LFD" . CurrentLFD)
		Send, {Enter}
		L_WaitUntilPreloadsLoaded()
		LFDStatus = 3
		}
	global PreloadString 
	L_ReadMultiplePreloads(CurrentLFD, PreloadString, true)
	return 
	}
else if (Command = "Finish")
	{
	ShowMatchLFDMessage()
	SaveToHistory("ENDE LFD-Suche - Match mit " . CurrentLFD)
	if (LFDStatus = 2)
		{
		Send, {Enter}
		L_WaitUntilPreloadsLoaded()
		}
	return
	}
} ; ende function LFDProcessing

CompareRoutine(){
local
global DefinedPreloads
global CurrentLFD
Loop, 2 {
;(1) Create Array for Current LFD
MissingPreloads := CreateLFDPreloadArray(CurrentLFD)
if (MissingPreloads = 0)
	{
	; alle Preloads vorhanden
	LFDFound := ComparePreloadArrays(CurrentLFD, true)
	return LFDFound
	}
else if (MissingPreloads < DefinedPreloads)
	{
	; einige Preloads vorhanden - PreCompare
	LFDFound := ComparePreloadArrays(CurrentLFD, true)
	if (LFDFound = false)
		return LFDFound
	; else: NeedPreloads
	}
SaveToHistory(CurrentLFD ": Preloads fehlend: " MissingPreloads)
LFDProcessing("NeedPreloads")
Continue
} ; ende loop
} ; ende function 

;;; LFD MATCH WINDOW ;;;  

ShowMatchLFDMessage(){
local
global CurrentLFD
global TimeOutMsgLFDMatch
global MatchWindowName := "Match mit " . CurrentLFD 
Gosub LFDMatchWindow
if (TimeOutMsgLFDMatch > 0)
	{
	SleepMatchWindow(TimeOutMsgLFDMatch)
	GoSub TimeOut
	WinWaitClose, %MatchWindowName%
	}
else
	{
	Msgbox Hello 2!
	WinWaitActive, %MatchWindowName%
	WinWaitClose, %MatchWindowName%
	}
}

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
BreakFlag := true
return

TimeOut:
Gui 33:Destroy
return 

SleepMatchWindow(TimeOutMsgLFDMatch){
global BreakFlag := false
TimeLoops := Round(TimeOutMsgLFDMatch/100) 
Loop, %TimeLoops% {
Sleep, 200
if (BreakFlag = true)
	break
}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ProcessingF3MenuInput(){
local 
global ProjectFile
global LFDFinderMenu
global LFDRequestArray := {}
global LFDExcludeArray := {}
global PreloadOrderArray := {}
global DefinedPreloadsArray
; (1) Create LFDRequest/LFDExclude-Array 
SaveToHistory("VERBOSE:", "Erstelle LFDRequest/LFDExclude-Array")
Loop, 8 {
Preload := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLN" . A_Index)
if (Preload != "ERROR")
	{
	; (1) Preload in PreloadList?
	CheckPreloadInPreloadList(Preload)
	; (2) Add to Arrays
	PreloadRequest := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLR" . A_Index, "-")
	PreloadExclude := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLE" . A_Index, "-")
	if (PreloadRequest != PreloadExclude)
		{
		LFDRequestArray[Preload] := PreloadRequest
		LFDExcludeArray[Preload] := PreloadExclude
		PreloadOrderArray[A_Index] := Preload
		if (LFDRequestArray[Preload] != "-")
			DefinedPreloadsArray[Preload] := PreloadRequest
		else
			DefinedPreloadsArray[Preload] := "Nicht" . PreloadExclude
		}
	else
		{
		if (PreloadRequest != "ERROR")
			{
			Msgbox, 4096, Ups! , Identische Werte f%ue%r %Preload% (Werte = %PreloadRequest%)!
			SaveToHistory("Identische Werte - LFD-Suche wird abgebrochen")
			Exit
			}
		}
	}
} ; ende loop
return DefinedPreloads := LFDRequestArray.Count()
} ; ende function ProcessF3MenuInput

ComparePreloadArrays(CurrentLFD, WriteToHistory:=true){
local 
global LFDRequestArray, LFDExcludeArray 
global LFDPreloadArray
global PreloadOrderArray
global HopelessLFDArray

SaveToHistory("VERBOSE:", CurrentLFD ": Checking Preload(s)")
for Index, Preload in PreloadOrderArray
	{
	ActualPreloadValue := LFDPreloadArray[Preload]
	;SaveToHistory("VERBOSE:", "ActualPreloadValue = " . ActualPreloadValue)
	If (ActualPreloadValue = "Missing")
		{
		SaveToHistory("VERBOSE:",  CurrentLFD . ": " . Preload . " is missing.")
		Continue
		}		
	; (1) Request Array
	RequestedPreloadValue := LFDRequestArray[Preload]
	;SaveToHistory("VERBOSE:", "RequestedPreloadValue = " . RequestedPreloadValue)
	if (RequestedPreloadValue != "-")
		{
		if (ActualPreloadValue != RequestedPreloadValue)
			{
			if (WriteToHistory = true)
				{
				SaveToHistory(CurrentLFD . ": No Match for " . Preload, "Wunschwert: " . RequestedPreloadValue, "Gefunden:" . ActualPreloadValue)
				LFDWithNoMatch(CurrentLFD)
				}
			HopelessLFDArray[CurrentLFD] := true
			return false
			}
		else
			{
			if (WriteToHistory = true)
				SaveToHistory(CurrentLFD . ": Match for " . Preload, "Wunschwert: " . RequestedPreloadValue, "Gefunden:" . ActualPreloadValue)
			Continue
			}
		}
	; (2) Exclude Array 
	ExcludedPreloadValue  := LFDExcludeArray[Preload]
	;SaveToHistory("VERBOSE:", "ExcludedPreloadValue = " . ExcludedPreloadValue)
	if (ExcludedPreloadValue != "-")
		{
		If (ActualPreloadValue = ExcludedPreloadValue)
			{
			if (WriteToHistory = true)
				{
				SaveToHistory(CurrentLFD . ": Bad Match!", Preload . " = " . ExcludedPreloadValue . " (Ausschlusswert)")
				LFDWithNoMatch(CurrentLFD)
				}
			HopelessLFDArray[CurrentLFD] := true
			return false
			}
		else
			{
			if (WriteToHistory = true)
				SaveToHistory(CurrentLFD . ": Good Match!", Preload . " = " . ExcludedPreloadValue . " (Nicht Ausschlusswert)")
			Continue
			}
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
	Msgbox, 4096 , Abbruch , Es wurden %e_AbortSearch% LFD's durchsucht. Suche wird beendet!
	SaveToHistory("LFD-Suche beendet n=" . e_AbortSearch)
	Exit
	}
SaveToHistory("VERBOSE:", CurrentLFD . ": Kriterien nicht  erf" . ue . "llt", "Loop: " . LFDCount)
}

;;; Pre-Checking Existing LFD's 

; (1) CreateLFDsInTempFileArray
CreateLFDsInTempFileArray(){
local
global TempFile
global LFDsInTempFileArray := {}
LFDListTempFile := GetIniSectionNames(TempFile)
Loop, Parse, LFDListTempFile, "`n"
	{
	if Instr(A_LoopField, "LFD_")
		{
		; Bsp. LFD_71100001
		LFD := Substr(A_LoopField, 5)
		LFDsInTempFileArray[LFD] := A_Index	
		}
	} ; ende loop
LFDsInTempFile := LFDsInTempFileArray.Count()
SaveToHistory("VERBOSE:", LFDsInTempFile . " LFDs im TempFile")
} ; ende function

; (2) CheckExistingLFDPreloads
CheckExistingLFDPreloads(){
local 
global LFDsInTempFileArray
SaveToHistory("Durchsuche existierende LFDs")
for LFD, i in LFDsInTempFileArray
	{
	MissingPreloads := CreateLFDPreloadArray(LFD)
	global LFDCount := 0
	LFDFound := ComparePreloadArrays(LFD, false)
	if (LFDFound = true and MissingPreloads = 0)
		{
		global CurrentLFD := LFD
		return true
		}
	} ; ende for-loop
} ; ende function

; (2.1) CreateLFDPreloadArray
CreateLFDPreloadArray(CurrentLFD){
local
global TempFile
global PreloadOrderArray
global LFDPreloadArray := {}
global MissingPreloads := 0
global PreloadString := ""
for Index, Preload in PreloadOrderArray
	{
	PreloadValue := GetIniValue(TempFile, "LFD_" . CurrentLFD , Preload, "Missing")
	LFDPreloadArray[Preload] := PreloadValue
	if (PreloadValue = "Missing")
		{
		++MissingPreloads
		if (MissingPreloads = 1)
			PreloadString .= Preload
		else
			PreloadString .= "|" . Preload 
		}
	}
return MissingPreloads
}