EnterfnValue(fnOCR, fnValue, Mode, params*){
local
global SleepAfterEnter
global MaxLengthfnValue
global LastFn
ShowIndex := false
MsgboxZusatz := ""

; emergency shutdown
if StrLen(fnValue) > MaxLengthfnValue
	{
	Msgbox, 4096, Fehler!, Beim Auslesen der Fragenummer scheint ein Fehler passiert zu sein. Der Durchlauf wird beendet!
	SaveToHistory("Schwerer Fehler (OCR = " . fnOCR . ")")
	Exit
	}
	
SaveToHistory("VERBOSE:", fnOCR . " fnValue: " fnValue)

; Check Index
if (params.MaxIndex() = 1)
	{
	Index := params[1]
	MsgboxZusatz := "Es wurden " . Index . " Fragen �bersprungen."
	}

if (LastFn = fnOCR)
	{
	Msgbox, 4096, Gleiche Fragenummer erkannt!, Die Fragenummer %fnOCR% war im letzten Durchgang bereits vorhanden. Der Durchlauf wird vorsichtshalber gestoppt! `n`n%MsgboxZusatz%
	SaveToHistory("Gleiche Fragenummer erkannt! Durchlauf abgebrochen.")
	Exit
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Beginn Procedure  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

if fnValue is digit
	{
	; Zahlen 
	Send, %fnValue%{Enter}
	Sleep, SleepAfterEnter
	SaveToHistory(fnOCR, "= " . fnValue, Mode)
	return
	}
else if fnValue is alpha
	{
	; W�rter
	if (fnValue = "Ende")
		{
		Msgbox, 4096, Durchlauf beendet!, Ende des Interviews (fn: %fnOCR%)! %MsgboxZusatz%
		SaveToHistory(fnOCR, "= " . fnValue, Mode)
		Exit
		}
	else if (fnValue = "Stop")
		{
		Msgbox, 4096, Durchlauf gestoppt!,Durchlauf wurde gestoppt (fn: %fnOCR%)! %MsgboxZusatz%
		SaveToHistory(fnOCR, "= " . fnValue, Mode)
		Exit
		}
	else
		{
		; reine Spracheingaben
		Send, %fnValue%{Enter}
		Sleep, SleepAfterEnter
		SaveToHistory(fnOCR, "= " . fnValue, Mode)
		return 
		}
	}
else if Instr(fnValue, "{Enter}")
	{
	; enter Preloads literally
	Send, %fnValue%{Enter}
	Sleep, SleepAfterEnter
	SaveToHistory(fnOCR, "= " . fnValue, Mode)
	return
	}
else if (InStr(fnValue, "["))
	{
	ButtonName := GetValueBetweenSquareBrackets(fnValue)
	if (ButtonName = "verweigert")
		{
		Send, {PgUp}
		Sleep, SleepAfterEnter
		}
	else
		{
		Result := L_TryClickingButton(ButtonName, 1)
		If (Result != "true")
			{
			Msgbox, 4096, Durchlauf beendet..., ...da der f�r fn "%fnOCR%" vorgesehene Button ("%ButtonName%") nicht vorhanden ist!
			Exit
			}
		}
	SaveToHistory(fnOCR, "= [" . ButtonName . "]", Mode)
	return
	}
else
	{
	PreloadString := GetValueBetweenRoundBrackets(fnValue)
	if Instr(fnValue, "Get")
		{
		if Instr(PreloadString, "/")
			EnterMultiplePreloadValues(fnOCR, PreloadString)
		else
			{
			PreloadValue := L_ReadPreload(PreloadString)
			Send, %PreloadValue%{Enter}
			Sleep, SleepAfterEnter
			SaveToHistory(fnOCR, "= " . PreloadValue, PreloadString, Mode)
			}
		}
	else if Instr(fnValue, "Reverse")
		{
		ReversedValue := ReverseValue(e_fnLearn, PreloadString)
		Send, %ReversedValue%{Enter}
		Sleep, SleepAfterEnter
		SaveToHistory(fnOCR, "= " . ReversedValue, Mode)
		}
	else if Instr(fnValue, "EnterDate")
		EnterDate(fnOCR, PreloadString)
	return
	}
}

;;;; associated functions ;;;;

GetValueBetweenSquareBrackets(String){
OpenBracketPos := InStr(String, "[") + 1
ClosedBracketPos := InStr(String, "]")
StringLength := ClosedBracketPos - OpenBracketPos
return Substr(String, OpenBracketPos, StringLength)
}

GetValueBetweenRoundBrackets(String){
OpenBracketPos := InStr(String, "(") + 1
ClosedBracketPos := InStr(String, ")")
StringLength := ClosedBracketPos - OpenBracketPos
return Substr(String, OpenBracketPos, StringLength)
}

ReverseValue(fnOCR, Preload){
ReverseTarget := L_ReadPreload(Preload)
If (ReverseTarget = 1)
	InputValue := 2
else
	InputValue := 1
return InputValue
}

EnterMultiplePreloadValues(fnOCR, PreloadString){
local 
global LFDSpeicherPfad
global LibraryFile, fnBib
global fast, med, DefaultSleep
global SkipIfPreloadZero
global CurrentLFD

;(1) Pre-Processing
RealPreloadString := CleanPreloadString(PreloadString)
StrReplace(RealPreloadString, "|", "|", Count)
PreloadCount := Count + 1

;(2) Remote Preloads needed?
PreloadNotExisting := L_ReadMultiplePreloads(CurrentLFD, RealPreloadString, PreTested := false)
if (PreloadNotExisting != "")
	{
	PreloadIsMissing := true
	; Duplicate Value defined?
	DuplicateValue := GetIniValue(LibraryFile, "Duplicates", fnOCR)
	if (DuplicateValue != "ERROR")
		{
		PreloadIsMissing := false
		DuplicatePreloadString := GetValueBetweenRoundBrackets(DuplicateValue)
		RealPreloadString := CleanPreloadString(DuplicatePreloadString)
		PreloadNotExisting := L_ReadMultiplePreloads(CurrentLFD, RealPreloadString, PreTested := false)
		if (PreloadNotExisting != "")
			PreloadIsMissing := true
		}
	if (PreloadIsMissing = true)
		{
		Msgbox, 4096, Ups!, Preload "%PreloadNotExisting%" war nicht vorhanden. LFD-Suche wird beendet.
		SaveToHistory("Preload " . PreloadNotExisting . " gab es nicht!")
		Exit
		}
	}
;(3) Enter Preloads
EnterTheseValues := ""
Loop, Parse, RealPreloadString, "|"
	{
	Preload := A_LoopField
	if Preload is digit
		{
		; Zahlen 
		fnValue := Preload
		Send, %fnValue%{Enter}
		Sleep, SleepAfterEnter
		if (A_Index = PreloadCount)
			EnterTheseValues .= fnValue
		else
			EnterTheseValues .= fnValue . "/"
		Continue
		}
	PreloadValue := GetIniValue(LFDSpeicherPfad, "LFD_" . CurrentLFD , Preload)
	if (CurrentLFD = "")
		DeleteIniValue(LFDSpeicherPfad, "LFD_" . CurrentLFD, Preload)
	if (PreloadValue = 0) and (Preload = "gebtPRE" or Preload = "gebmPRE" or Preload = "gebjPRE")
		{
		SaveToHistory("VERBOSE:", fnOCR . " Preload-Angabe ung�ltig! " . Preload . "=0")
		if (SkipIfPreloadZero = "false")
			{
			Msgbox, 4096, Ups! , Preloadangabe unvollst�ndig! Wert f�r %Preload% ist Null! Durchlauf wird beendet.
			Exit
			}
		else
			{
			Send, {PgUp}
			sleep, med
			if (A_Index = PreloadCount)
				EnterTheseValues .= "verweigert"
			else
				EnterTheseValues .= "verweigert/"
			Continue
			}
		}
	SetKeyDelay, med
	Send, %PreloadValue%{Enter}
	if (A_Index = PreloadCount)
		EnterTheseValues .= PreloadValue
	else
		EnterTheseValues .= PreloadValue . "/"
	}
SetKeyDelay, fast
SaveToHistory(fnOCR, "= " . EnterTheseValues, PreloadString)
Sleep, DefaultSleep
}

CleanPreloadString(PreloadString){
RealPreloadString := StrReplace(PreloadString, "\" , "|")
RealPreloadString := StrReplace(RealPreloadString, "/" , "|")
return RealPreloadString
}

EnterDate(fnOCR, String){
local
global SleepAfterEnter, DefaultSleep
PreloadString := CleanPreloadString(String)
StrReplace(PreloadString, "|", "|", Count)
PreloadCount := Count + 1
EnterTheseValues := ""
Loop, Parse, PreloadString , "|"
	{
	Value := A_LoopField
	if A_LoopField is digit
		Send, %A_LoopField%{Enter}
	if (A_LoopField = "Tag")
		{
		Value := A_DD
		Send, %A_DD%{Enter}
		}
	if (A_LoopField = "Monat")
		{
		Value := A_MM
		Send, %A_MM%{Enter}
		}
	if (A_LoopField = "Jahr")
		{
		Value := A_YYYY
		Send, %A_YYYY%{Enter}
		}
	if (A_LoopField = "Confirm")
		{
		Value := "{Enter}"
		Sleep, DefaultSleep
		Send, {Enter}
		}
	Sleep, SleepAfterEnter
	; Save Input
	if (A_Index = PreloadCount)
		EnterTheseValues .= Value
	else
		EnterTheseValues .= Value . "/"
	}
Sleep, SleepAfterEnter
SaveToHistory(fnOCR, "= " . EnterTheseValues, PreloadString)
}