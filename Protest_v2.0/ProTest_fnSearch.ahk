;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;    fnSearch    ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

fnSearch(fnOCR, Index){
local
global fast, fnSearchIsOver
global UpcomingFnIndex
global TriedXModulSkip
global SleepWhileOCREmpty
global LastFn
global MaxSkips 
SetKeyDelay, fast

; fnOCR empty?
if (fnOCR = "")
	{
	; Try Click verweigert Anyway
	PleasWaitWindow("On")
	SaveToHistory("VERBOSE:", "Try Anyway Skip")
	ClickSkippButton(fnOCR)
	CheckfnOCR := OCR("TryAnywaySkip", Index)
	PleasWaitWindow("Off")
	if (CheckfnOCR != "")
		{
		SleepWhileOCREmpty := SleepWhileOCREmpty-50
		return fnSearchIsOver := false
		}
	else
		{
		; Prüfmodul überspringen?
		SleepWhileOCREmpty := SleepWhileOCREmpty-50
		global ProjectFile, r_AdvancedON
		if (r_AdvancedON = 1 AND GetIniValue(ProjectFile, "AdvancedSearchMenu", "c_XModul", 1) = 1)
			{
			if (TriedXModulSkip = false)
				{
				PleasWaitWindow("On")
				XModulSkipped := TrySkipXModul()
				TriedXModulSkip := true
				PleasWaitWindow("Off")
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
		} ; ende else
	Result := OCRIsEmpty()
	if (Result = "Exit")
		Exit
	else if (Result = "Pause")
		Pause
	}

; Check - Doppelte Schleife?
Static SameFn := 0
if (fnOCR = LastFn)
	{
	++SameFn
	if (SameFn = MaxSkips)
		{
		; wenn mindestens 2 mal die gleiche
		Msgbox, 4132, Kein verweigert Button vorhanden (fn: %fnOCR%)!, Jetzt manuelle Eingabe tätigen? (Danach und mit 'F6' fortfahren)
		IfMsgBox, Yes
			{
			SaveToHistory("Kein verweigert-Button vorhanden. Eigene Aktion durchführen? JA")
			Send, {F6}
			return fnSearchIsOver := false
			}
		else
			{
			SaveToHistory("Kein verweigert-Button vorhanden. Eigene Aktion durchführen? Nein")
			Exit
			}
		}
	}
else
	SameFn := 0

TriedAnywaySkip := false
; MATCH with Stop Fn?
Result := CheckStopFn(fnOCR, Index)
if (Result = true)
	return fnSearchIsOver := true

; MATCH with Upcoming Fn?
if (r_AdvancedON = 1 AND UpcomingFnIndex != 0)
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
return fnSearchIsOver := false

} ; ende function fnSearch

ClickSkippButton(fnOCR){
local
global dd_SkipButton
global SleepAfterEnter
if (dd_SkipButton = 1)
	{
	Send, {PgUp}
	if (fnOCR != "")
		SaveToHistory(fnOCR, "verweigert")
	}
else
	{
	Send, {PgDn}
	SaveToHistory(fnOCR, "Clear&Back")
	}
Sleep, SleepAfterEnter
}

CheckStopFn(fnOCR, Index){
local
global StopFnArray
for i, StopFn in StopFnArray
	{
	StopfnLength := StrLen(StopFn)
	CompareFn := SubStr(fnOCR, 1 , StopfnLength)
	if (CompareFn = StopFn)
		{
		Msgbox, 4096, Durchlauf beendet!, Stop-fn "%StopFn%" erreicht! Es wurden %Index% Fragen übersprungen.
		SaveToHistory(fnOCR, " MATCH mit Stop fn: " . StopFn, Index " Frage(n) übersprungen")
		return true
		}
	}
return false
}

CheckUpcomingFn(fnOCR, Index){
local
global ProjectFile
global UpcomingFnArray
For UpcomingFnName, UpcomingFnValue in UpcomingFnArray
	{
	if (UpcomingFnName = fnOCR)
		{
		EnterfnValue(fnOCR, UpcomingFnValue, "F4 Menu", Index)
		return true
		}
	else
		{
		fnOCRLastAlphaRemoved := fnCorrectionRemoveLastAlpha(fnOCR)
		if (fnOCRLastAlphaRemoved != fnOCR and UpcomingFnName = fnOCRLastAlphaRemoved)
			{
			EnterfnValue(fnOCRLastAlphaRemoved, UpcomingFnValue, "F4 Menu", Index)
			return true
			}
		fnOCR6a := fnCorrectionReplaceLast6witha(fnOCR)
		if (fnOCR6a != fnOCR and UpcomingFnName = fnOCR6a)
			{
			EnterfnValue(fnOCR6a, UpcomingFnValue, "F4 Menu", Index)
			return true
			}
		}
	} ; ende foor-loop
return false
} ; ende function	

CheckNagFn(fnOCR, Index){
local
global LibraryFile
fnNagValue := GetIniValue(LibraryFile, "fnNag", fnOCR)
If (fnNagValue = "ERROR")
	{
	; AutoCorrection
	CorrectedfnOCR := AutoCorrection(fnOCR, "fnNag", fnNagValue)
	if (CorrectedfnOCR = fnOCR)
		return false
	else
		EnterfnValue(CorrectedfnOCR, fnNagValue, "fnNag", Index)
	}
else
	EnterfnValue(fnOCR, fnNagValue, "fnNag", Index)
return true
}

TrySkipXModul(){
local
; keine fn/ verweigert Button vorhanden 
; Test ob Püfmodul X (hat kein clear-Button)
Result := L_TryClickingButton("&Clear", 1)
if (Result = "false")
	{
	SaveToHistory("VERBOSE:", "Xmodul: Kein Clear-Button vorhanden (=XModul?)")
	Msgbox, 4132, XModul, Soll versucht werden jetzt das Xmodul zu überspringen?
	IfMsgBox, Yes
		{
		SaveToHistory("XModul überspringen?", "Ja")
		; kein Clear-Button vorhanden, wahrscheinlich Xmodul
		if (L_SkipXModul() = "true")
			{
			SaveToHistory("# XPrüfmodul übersprungen #")
			return true
			}
		else
			Msgbox, 4096, Ups!, Versuch XModul zu übersprungen ist gescheitert!
		}
	else
		SaveToHistory("XModul überspringen?", "Nein")
	}
else
	SaveToHistory("VERBOSE:", "Xmodul: Clear-Button vorhanden (= Nicht XModul)")
return false
}