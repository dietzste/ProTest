;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;    fnSearch    ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

fnSearch(byref fnOCR, Index){
local
global fast, fnSearchIsOver
global UpcomingFnIndex
global TriedXModulSkip
global SleepWhileOCREmpty
global LastFn
global MaxSkips 
global GuiF7
SetKeyDelay, fast

; fnOCR empty?
if (fnOCR = "")
	{
	; Try Click verweigert Anyway
	MsgWindow("Bitte warten...")
	SaveToHistory("VERBOSE:", "Try Anyway Skip")
	ClickSkippButton(fnOCR)
	CheckWorkWindow()
	CheckfnOCR := OCR("TryAnywaySkip", Index)
	MsgWindow()
	if (CheckfnOCR != "")
		{
		SleepWhileOCREmpty := SleepWhileOCREmpty-50
		return fnSearchIsOver := false
		}
	else
		{
		; Pr�fmodul �berspringen?
		SleepWhileOCREmpty := SleepWhileOCREmpty-50
		global ProjectFile, r_AdvancedON
		if (r_AdvancedON = 1 AND GetIniValue(ProjectFile, "AdvancedSearchMenu", "c_XModul", 1) = 1)
			{
			if (TriedXModulSkip = false)
				{
				MsgWindow("Bitte warten...")
				XModulSkipped := TrySkipXModul()
				TriedXModulSkip := true
				MsgWindow()
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
Static SameFnCount := 0
if (fnOCR = LastFn and fnOCR != "")
	{
	++SameFnCount
	if (SameFnCount >= MaxSkips)
		{
		; wenn gleiche fn MaxSkips-mal...
		Msgbox, 4132, Kein verweigert-Button vorhanden (fn: %fnOCR%)!, Soll f�r die aktuelle Fragenummer ein Wert definiert werden? 
		IfMsgBox, Yes
			{
			SaveToHistory("Kein verweigert-Button vorhanden. Eingabe f�r Fragenummer definieren? Ja")
			Send, {F7}
			WinWaitActive, %GuiF7%
			WinWaitClose, %GuiF7%
			return fnSearchIsOver := false
			}
		else
			{
			RealIndex := Index - SameFnCount
			Msgbox, 4096, Das �berspringen von Fragenummern wurde beendet!, F�r die aktuelle Fragenummer ist keine Eingabe definiert. Um das �berspringen fortzuf�hren, bitte eine manuelle Eingabe t�tigen und �ber die F2-Taste das �berspringen erneut starten. `n`nEs wurden %RealIndex% Fragen �bersprungen. 
			SaveToHistory("Kein verweigert-Button vorhanden. Eingabe f�r Fragenummer definieren? Nein")
			Exit
			}
		}
	}
else
	SameFnCount := 0

TriedAnywaySkip := false
; MATCH with Target Fn?
Result := CheckTargetFn(fnOCR, Index)
if (Result = true)
	return fnSearchIsOver := true

; MATCH with Upcoming Fn?
if (r_AdvancedON = 1 AND UpcomingFnIndex != 0)
	{
	MatchUpcomingFn := CheckUpcomingFn(fnOCR, Index)
	if (MatchUpcomingFn = true)
		return fnSearchIsOver := false
	}
	
; MATCH with fnBib?
MatchfnBib := CheckfnBib(fnOCR, Index)
if (MatchfnBib = true)
	return fnSearchIsOver := false

SaveToHistory("VERBOSE:", fnOCR . " KEINE Ziel-fn, Upcoming-fn, Bib-fn")

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

CheckTargetFn(fnOCR, Index){
local
global TargetFnArray
for i, TargetFn in TargetFnArray
	{
	TargetfnLength := StrLen(TargetFn)
	CompareFn := SubStr(fnOCR, 1 , TargetfnLength)
	if (CompareFn = TargetFn)
		{
		Msgbox, 4096, Durchlauf beendet!, Ziel-fn "%TargetFn%" erreicht! Es wurden %Index% Fragen �bersprungen.
		SaveToHistory(fnOCR, " MATCH mit Ziel-fn: " . TargetFn, Index " Frage(n) �bersprungen")
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

CheckfnBib(byref fnOCR, Index){
local
global LibraryFile, fnBib
fnSkipValue := GetIniValue(LibraryFile, fnBib, fnOCR)
If (fnSkipValue = "ERROR")
	{
	; AutoCorrection
	CorrectedfnOCR := AutoCorrection(fnOCR, fnSkipValue)
	if (CorrectedfnOCR = fnOCR)
		return false
	else
		{
		fnOCR := CorrectedfnOCR
		EnterfnValue(CorrectedfnOCR, fnSkipValue, fnBib, Index)
		}
	}
else
	EnterfnValue(fnOCR, fnSkipValue, fnBib, Index)
return true
}

TrySkipXModul(){
local
; keine fn/ verweigert Button vorhanden 
; Test ob P�fmodul X (hat kein clear-Button)
Result := L_TryClickingButton("&Clear", 1)
if (Result = "false")
	{
	SaveToHistory("VERBOSE:", "Xmodul: Kein Clear-Button vorhanden (=XModul?)")
	Msgbox, 4132, XModul, Soll versucht werden, jetzt das X-Modul zu �berspringen?
	IfMsgBox, Yes
		{
		SaveToHistory("XModul �berspringen?", "Ja")
		; kein Clear-Button vorhanden, wahrscheinlich Xmodul
		if (L_SkipXModul() = "true")
			{
			SaveToHistory("# XPr�fmodul �bersprungen #")
			return true
			}
		else
			Msgbox, 4096, Ups!, Versuch XModul zu �bersprungen ist gescheitert!
		}
	else
		SaveToHistory("XModul �berspringen?", "Nein")
	}
else
	SaveToHistory("VERBOSE:", "Xmodul: Clear-Button vorhanden (= Nicht XModul)")
return false
}