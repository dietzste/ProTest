;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;    fnSearch    ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

fnSearch(fnOCR, Index){
local
global Addons
global ae, oe, ue, fast, fnSearchIsOver
global ProjectFile, TempFile
global r_AdvancedON
global SleepAfterEnter
global SameFnCount, TriedAnywaySkip, TriedXModulSkip
static LastfnOCR
SetKeyDelay, fast

; fnOCR empty?
if (fnOCR = "")
	{
	; Second try
	fnOCR := OCR("(2)!", 2)
	if (fnOCR = "")
		{
		; Try Click verweigert Anyway
		if (TriedAnywaySkip = false)
			{
			SaveToHistory("VERBOSE:", "Try Anyway Skip")
			ClickSkippButton(fnOCR)
			TriedAnywaySkip := true
			return fnSearchIsOver := false
			}
		if (r_AdvancedON = 1 And Addons = true AND GetIniValue(ProjectFile, "AdvancedSearchMenu", "c_XModul", 1) = 1)
			{
			SaveToHistory("Clear-Button vorhanden? (Hinweis XModul)")
			if (TriedXModulSkip = false)
				{
				XModulSkipped := TrySkipXModul()
				TriedXModulSkip := true
				if (XModulSkipped = false)
					{
					Result := OCRIsEmpty()
					if (Result = "Exit")
						Exit
					else if (Result = "Pause")
						Pause
					}
				else
					return fnSearchIsOver := false
				}
			}
		else
			{
			Result := OCRIsEmpty()
			if (Result = "Exit")
				Exit
			else if (Result = "Pause")
				Pause
			}
		TriedAnywaySkip := false
		return fnSearchIsOver := false
		}
	}

; Check - Doppelte Schleife?
if (Index >= 1)
	{
	if (fnOCR = LastfnOCR)
		{
		++SameFnCount
		if (SameFnCount >= 5)
			{
			Msgbox, 4132, Kein verweigert Button vorhanden (fn: %fnOCR%)!, Jetzt manuelle Eingabe t%ae%tigen? (Danach und mit 'F6' fortfahren)
			IfMsgBox, Yes
				{
				SaveToHistory("Kein verweigert-Button vorhanden. Eigene Aktion durchf" . ue . "hren? JA")
				Send, {F6}
				}
			else
				{
				SaveToHistory("Kein verweigert-Button vorhanden. Eigene Aktion durchf" . ue . "hren? Nein")
				Exit
				}
			}
		}
	else
		SameFnCount := 0
	}

TriedAnywaySkip := false
LastfnOCR := fnOCR
; MATCH with Stop Fn?
CheckStopFn(fnOCR, Index)

; MATCH with Upcoming Fn?
if (r_AdvancedON = 1)
	{
	MatchUpcomingFn := CheckUpcomingFn(fnOCR, Index)
	if (MatchUpcomingFn = true)
		return fnSearchIsOver := false
	}
	
; MATCH with NagFn?
MatchNagFn := CheckNagFn(fnOCR, Index)
if (MatchNagFn = true)
	return fnSearchIsOver := false

SaveToHistory("VERBOSE:", fnOCR . " KEINE Stop-fn, Upcoming-fn, Nag-fn")

; Clicking Buttons
ClickSkippButton(fnOCR)
Sleep, SleepAfterEnter
return fnSearchIsOver := false

} ; ende function fnSearch

ClickSkippButton(fnOCR){
local
global dd_SkipButton
if (dd_SkipButton = 1)
	{
	Send, {PgUp}
	if (fnOCR != "")
		SaveToHistory(fnOCR, "Klicke verweigert")
	}
else
	{
	Send, {PgDn}
	SaveToHistory(fnOCR, "Klicke Clear&Back")
	}
}


CheckStopFn(fnOCR, Index){
local
global ue, e_Stopfn1, e_Stopfn2, e_Stopfn3
StopFnArray := [e_Stopfn1, e_Stopfn2, e_Stopfn3]
for i, StopFn in StopFnArray
	{
	if (StopFn != "")
		{
		StopfnLength := StrLen(StopFn)
		CompareFn := SubStr(fnOCR, 1 , StopfnLength)
		if (CompareFn = StopFn)
			{
			Msgbox, 4096, Durchlauf beendet!, Stop-fn "%StopFn%" erreicht! Es wurden %Index% Fragen %ue%bersprungen.
			SaveToHistory(fnOCR . "MATCH mit Stop fn: " . StopFn)
			Exit
			}
		}
	}
return
}

CheckUpcomingFn(fnOCR, Index){
local
global r_AdvancedON
global AdvancedSearchMenu
global ProjectFile
loop, 5 {  
UpcomingFnName := GetIniValue(ProjectFile,AdvancedSearchMenu, "e_fnN" . A_Index)
If (UpcomingFnName = fnOCR)
	{
	UpcomingFnValue := GetIniValue(ProjectFile, AdvancedSearchMenu, "e_fnV" . A_Index)
	if (UpcomingFnValue != "" AND %UpcomingFnValue% != "ERROR" )
		{
		SaveToHistory(fnOCR, "MATCH mit Upcoming-fn, Value = " . UpcomingFnValue)
		EnterfnValue(fnOCR, UpcomingFnValue, Index)
		return true
		}
	}	
} ; ende loop  
return false
} ; ende function	

CheckNagFn(fnOCR, Index){
local
global LibraryFile
fnNagValue := GetIniValue(LibraryFile, "fnNag", fnOCR)
If (fnNagValue != "ERROR")
	{ 
	SaveToHistory(fnOCR, "MATCH mit NagFn, Value=" . fnNagValue)
	EnterfnValue(fnOCR, fnNagValue, Index)
	return true
	}
else
	return false
}

EnterfnValue(fnOCR, fnValue, Index){
local
global ue, SleepAfterEnter
SaveToHistory("VERBOSE:", fnOCR . " EnterfnValue: " fnValue)
if fnValue is digit
	{
	Send, %fnValue%{Enter}
	Sleep, SleepAfterEnter
	SaveToHistory(fnOCR, "= " . fnValue)
	return
	}
else
	{
	if (fnValue = "Ende")
		{
		Msgbox, 4096, Durchlauf beendet!, Ende des Interviews (fn: %fnOCR%)! Es wurden %Index% Fragen %ue%bersprungen.
		Exit
		}
	if (fnValue = "Stop")
		{
		Msgbox, 4096, Durchlauf gestoppt!,Durchlauf wurde gestoppt (fn: %fnOCR%)! Es wurden %Index% Fragen %ue%bersprungen.
		Exit
		}
	else if (fnValue = "{Enter}")
		{
		Send, {Enter}
		Sleep, SleepAfterEnter
		return
		}
	else if (InStr(fnValue, "["))
		{
		ButtonName := ExtractButtonName(fnValue)
		Result := L_TryClickingButton(ButtonName, 1)
		If (Result = true) 
			return
		else
			{
			Msgbox, 4096, Durchlauf beendet..., ...da der f%ue%r fn "%fnOCR%" vorgesehene Button ("%ButtonName%") nicht vorhanden ist!
			Exit
			}
		}
	else
		{
		; Get PreloadValue and Enter
		EnterPreloadValue(fnOCR, fnValue)
		return 
		}
	} ; ende else (no digit)
}

ExtractButtonName(fnValue){
local
StringGetPos, ClosedBracket, fnValue, ]
ButtonNameLength := ClosedBracket - 1
return SubStr(fnValue, 2 , ButtonNameLength)
}

TrySkipXModul(){
local
global ue, ProjectFile
global fnSearchIsOver
; keine fn/ verweigert Button vorhanden 
; Test ob Prüfmodul X (hat kein clear-Button)
Result := L_TryClickingButton("&Clear", 1)
if (Result = "false")
	{
	SaveToHistory("VERBOSE:", "Xmodul: Kein Clear-Button vorhanden (=XModul?)")
	Msgbox, 4132, XModul, Soll versucht werden jetzt das Xmodul zu %ue%berspringen?
	IfMsgBox, Yes
		{
		SaveToHistory("XModul " . ue . "berspringen?", "Ja")
		; kein Clear-Button vorhanden, wahrscheinlich Xmodul
		SaveToHistory("VERBOSE:", "Xmodul: Kein Clear-Button vorhanden (=XModul?)")
		if (L_SkipXModul() = true)
			{
			SaveToHistory("VERBOSE:", "Xmodul: XModul übersprungen: true")
			return true
			}
		else
			{
			SaveToHistory("VERBOSE:", "Xmodul: XModul übersprungen: false")
			Msgbox, 4096, Ups!, Versuch XModul zu %ue%bersprungen ist gescheitert!
			return false
			}
		}
	else
		{
		SaveToHistory("XModul " . ue . "berspringen?", "Nein")
		Exit
		}
	}
else
	{
	SaveToHistory("VERBOSE:", "Xmodul: Clear-Button vorhanden (= Nicht XModul)")
	return false
	}
}