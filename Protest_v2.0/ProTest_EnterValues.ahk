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
	SaveToHistory("Schwerer Fehler (OCR = " . fnOCR . ")")
	Exit
	}
	
SaveToHistory("VERBOSE:", fnOCR . " fnValue: " fnValue)

if (LastFn = fnOCR)
	{
	static SameFn := false
	if (SameFn = true)
		{
		Msgbox, 4096, Gleiche Fn erkannt!, Die Fn %fnOCR% war im letzten Durchgang bereits vorhanden. Der Durchlauf wird vorsichtshalber gestoppt! (SleepAfterEnter: %SleepAfterEnter% ms)
		SaveToHistory("Gleiche Fn erkannt! Durchlauf abgebrochen.")
		Exit
		}
	SameFn := true
	Sleep, SleepAfterEnter
	return 
	}

; Check Index
if (params.MaxIndex() = 1)
	{
	Index := params[1]
	MsgboxZusatz := "Es wurden " . Index . " Fragen übersprungen."
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
	; Wörter
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
			Msgbox, 4096, Durchlauf beendet..., ...da der für fn "%fnOCR%" vorgesehene Button ("%ButtonName%") nicht vorhanden ist!
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
global TempFile
global fast, med, DefaultSleep
global SkipIfPreloadZero
global CurrentLFD

;(1) Pre-Processing
RealPreloadString := StrReplace(PreloadString, "/" , "|")

;(2) Remote Preloads needed?
L_ReadMultiplePreloads(CurrentLFD, RealPreloadString, false)

;(3) Enter Preloads
Loop, Parse, RealPreloadString, "|"
	{
	Preload := A_LoopField
	PreloadValue := GetIniValue(TempFile, "LFD_" . CurrentLFD , Preload)
	if (PreloadValue = 0) and (Preload = "gebtPRE" or Preload = "gebmPRE" or Preload = "gebjPRE")
		{
		SaveToHistory("VERBOSE:", fnOCR . " Preload-Angabe ungültig! " . Preload . "=0")
		if (SkipIfPreloadZero = "false")
			{
			Msgbox, 4096, Ups! , Preloadangabe unvollständig! Wert für %Preload% ist Null! Durchlauf wird beendet.
			Exit
			}
		else
			{
			Send, {PgUp}
			sleep, med
			Continue
			}
		}
	SetKeyDelay, med
	Send, %PreloadValue%{Enter}
	}
SetKeyDelay, fast
Sleep, DefaultSleep
}