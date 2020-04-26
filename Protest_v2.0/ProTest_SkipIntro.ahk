SkipIntro(fnOCR){
local
global BasicFile, ProjectFile, LibraryFile
global fast, IntroIsOver
global SleepAfterEnter
global BasicSettingsMenu
SetKeyDelay, fast
; Check in LibraryFile
fnIntroValue := GetIniValue(LibraryFile, "fnIntro", fnOCR)
If (fnIntroValue = "ERROR")
	{
	c_fnOCR := AutoCorrection(fnOCR, "fnIntro", fnIntroValue)
	if (c_fnOCR = fnOCR) 
		{
		IntroIsOver := true
		return
		}
	else
		{
		fnOCR := c_fnOCR
		}
	}
else
	SaveToHistory(fnOCR,  "= " . fnIntroValue, "Intro")
	
;;; Eingaben abrufen ;;

if fnIntroValue is digit
	{
	Send, %fnIntroValue%{Enter}
	Sleep, SleepAfterEnter
	return 
	}
else if !Instr(fnIntroValue, "(")
	{
	; enter Preloads literally
	Send, %fnIntroValue%{Enter}
	Sleep, SleepAfterEnter
	return
	}
else
	{
	PreloadString := GetValueBetweenBrackets(fnIntroValue)
	if Instr(fnIntroValue, "Get")
		{
		if Instr(PreloadString, "/")
			EnterMultiplePreloadValues(fnOCR, PreloadString)
		else
			EnterPreloadValue(fnOCR, PreloadString)
		return
		}
	else if Instr(fnIntroValue, "Reverse")
		{
		ReverseValue(fnOCR, PreloadString)
		return
		}
	}
} ; ende SkipIntro function

GetValueBetweenBrackets(String){
ClosedBracketPos := InStr(String, ")")
return Substr(String, 5, ClosedBracketPos - 5)
}

ReverseValue(fnOCR, Preload){
local
global CurrentLFD, TempFile
global SleepAfterEnter
ReverseTarget := L_ReadPreload(Preload)
If (ReverseTarget = 1)
	InputValue := 2
else
	InputValue := 1		
Send, %InputValue%{Enter}
Sleep, SleepAfterEnter
}

EnterPreloadValue(fnOCR, Preload){
local
global SleepAfterEnter
SaveToHistory("VERBOSE:","Get Preload", fnOCR . "=" . Preload)
PreloadValue := L_ReadPreload(Preload)
Send, %PreloadValue%{Enter}
Sleep, SleepAfterEnter
return
}

EnterMultiplePreloadValues(fnOCR, PreloadString){
local 
global TempFile
global fast, med, ue, ae, DefaultSleep
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
		Msgbox, 4096, Ups! , Preloadangabe unvollst%ae%ndig! Wert f%ue%r %Preload% ist Null! Durchlauf wird beendet!
		SaveToHistory("VERBOSE:", fnOCR . " Preload-Angabe für ungültig! " . Preload . "=0")
		Exit
		}
	SetKeyDelay, med
	Send, %PreloadValue%{Enter}
	}
SetKeyDelay, fast
Sleep, DefaultSleep
}