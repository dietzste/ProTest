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
	if (Strlen(fnOCR) = 6)
		{
		fnOCR := (SubStr(fnOCR, 1, 5))
		SaveToHistory("VERBOSE:", "Probiere " . fnOCR)
		fnIntroValue := GetIniValue(LibraryFile, "fnIntro", fnOCR)
		If (fnIntroValue = "ERROR")
			{
			IntroIsOver := true
			return
			}
		else
			SaveToHistory(fnOCR, "=" . fnIntroValue, "Intro")
		}
	else
		{
		IntroIsOver := true
		return
		}
	}
else
	SaveToHistory(fnOCR,  "=" . fnIntroValue, "Intro")
	
; Eingaben abrufen
if fnIntroValue is digit
	{
	Send, %fnIntroValue%{Enter}
	Sleep, SleepAfterEnter
	return 
	}
else if (fnIntroValue = "IntroGetSex") 
	{
	PreloadName := GetIniValue(ProjectFile, BasicSettingsMenu, "e_sex")
	if (PreloadName = "ERROR")
		PreloadName := GetIniValue(BasicFile, BasicSettingsMenu, "e_sex")
	EnterPreloadValue(fnOCR, PreloadName)
	return 
	}
else if (fnIntroValue = "IntroGetDateOfBirth")
	{
	EnterDateOfBirth(fnOCR)
	return
	}
else if (fnIntroValue = "IntroSexReversed")
	{
	ReverseSexValue(fnOCR)
	return 
	}
else 
	{
	EnterPreloadValue(fnOCR, fnIntroValue)
	return
	}
} ; ende SkipIntro function

EnterPreloadValue(fnOCR, Preload){
local
global SleepAfterEnter
SaveToHistory("VERBOSE:","Get Preload", fnOCR . "=" . Preload)
PreloadValue := L_ReadPreload(Preload)
if (PreloadValue = "false")
	{
	Msgbox, 4096 ,%Preload%, "%Preload%" gibt es nicht.
	Exit
	}
else
	{
	Send, %PreloadValue%{Enter}
	Sleep, SleepAfterEnter
	return
	}
}

ReverseSexValue(fnOCR){
local
global ProjectFile, TempFile, BasicFile
global CurrentLFD 
PreloadName := GetIniValue(ProjectFile, "BasicSettingsMenu", "e_sex")
if (PreloadName = "ERROR")
	PreloadName := GetIniValue(BasicFile, BasicSettingsMenu, "e_sex")
GeschlechtZP := GetIniValue(TempFile, "LFD_" . CurrentLFD , PreloadName)
if (GeschlechtZP = "ERROR")
	GeschlechtZP := InputBoxGeschlecht(fnOCR)
If (GeschlechtZP = 1)
	GeschlechtZPReverse := 2
else
	GeschlechtZPReverse := 1		
Send, %GeschlechtZPReverse%{Enter}
}

EnterDateOfBirth(fnOCR){
local 
global TempFile
global fast, med, ue, ae, DefaultSleep
global e_BirthDay, e_BirthMonth, e_BirthYear
global e_Input1, e_Input2, e_Input3
global CurrentLFD
global MultiplePreloadArray

; Create BirthdayArray
MultiplePreloadArray := []
MultiplePreloadArray[e_BirthDay]   := GetIniValue(TempFile, "LFD_" . CurrentLFD , e_BirthDay, "Missing")
MultiplePreloadArray[e_BirthMonth] := GetIniValue(TempFile, "LFD_" . CurrentLFD , e_BirthMonth, "Missing")
MultiplePreloadArray[e_BirthYear]  := GetIniValue(TempFile, "LFD_" . CurrentLFD , e_BirthYear, "Missing")

; Get PreloadValues
L_ReadMultiplePreloads(e_BirthDay, e_BirthMonth, e_BirthYear)
for Preload, PreloadValue in MultiplePreloadArray
	{
	if (Preload = e_BirthDay)
		BirthDay := PreloadValue
	else if (Preload = e_BirthMonth)
		BirthMonth := PreloadValue
	else if (Preload = e_BirthYear)
		BirthYear := PreloadValue
	}
; set order
OrderArray := ["e_Input1", "e_Input2", "e_Input3"]
for i, Order in OrderArray
	{
	OrderValue := %Order%
	if (OrderValue = "Tag")
		Order%i% := BirthDay
	if (OrderValue = "Monat")
		Order%i% := BirthMonth
	if (OrderValue = "Jahr")
		Order%i% := BirthYear
	}
if (BirthDay = 0 OR BirthMonth = 0 or BirthYear = 0)
	{
	DateOfBirthArray := ["BirthDay", "BirthMonth", "BirthYear"]
	for i, Stelle in DateOfBirthArray
		{
		if (%Stelle% = 0)
			MissingDate := Stelle
		}
	Msgbox, 4096, Ups! , Preloadangabe unvollst%ae%ndig! Wert f%ue%r %MissingDate% ist Null! Durchlauf wird beendet!
	SaveToHistory("VERBOSE:", fnOCR . " Preload-Angabe für ungültig! " . MissingDate . "=0")
	Exit
	}
SetKeyDelay, med
Send, %Order1%{Enter}%Order2%{Enter}%Order3%{Enter}
SaveToHistory(fnOCR,  " = " . Order1 . "/" . Order2 . "/" . Order3 , "Intro")
SetKeyDelay, fast
Sleep, DefaultSleep
}

;;; INPUTBOX 

InputBoxGeschlecht(fnOCR){
local
global ue, oe, ae

; Setting Up InPut Box
InputBoxText := "Geschlechtsangabe f" . ue . "r fn """ . fnOCR . """ ben" . oe . "tigt!`n`n1: m" . ae . "nnlich `n2: weiblich"
InptBoxTitle := "Geschlechtsangabe fehlt!"
InputBoxDefault := 2

InputBox, GeschlechtEntered , %InptBoxTitle% , %InputBoxText%,, 300, 200,,,,,%InputBoxDefault%
if (ErrorLevel = 1) ;Cancel or Closed
	{
	MsgBox, 4096, Ende , Durchlauf wurde beendet!
	Exit
	}
else
	return GeschlechtEntered
}