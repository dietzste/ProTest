SkipIntro(fnOCR){
local
global BasicFile, ProjectFile, TempFile, LibraryFile
global fast, IntroIsOver, CurrentLFD
global SleepAfterEnter
global BasicSettingsMenu
global IntroIsOver 
global Verbose
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
	return 
	}
else if (fnIntroValue = "IntroGetSex") 
	{
	PreloadName := GetIniValue(ProjectFile, BasicSettingsMenu, "e_sex")
	if (PreloadName = "ERROR")
		PreloadName := GetIniValue(BasicFile, BasicSettingsMenu, "e_sex")
	EnterPreloadValue(PreloadName)
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
	InputBoxProtest(fnOCR, GeschlechtZP)
If (GeschlechtZP = 1)
	GeschlechtZPReverse := 2
else
	GeschlechtZPReverse := 1		
Send, %GeschlechtZPReverse%{Enter}
}

EnterDateOfBirth(fnOCR){
local 
global fast, med, ue, ae, DefaultSleep
global e_BirthDay, e_BirthMonth, e_BirthYear
global e_Input1, e_Input2, e_Input3
global CurrentLFD
global MultiplePreloadArray
CreateMultiplePreloadArray("GetDateOfBirth", e_BirthDay, e_BirthMonth, e_BirthYear)
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
SetKeyDelay, fast
Sleep, DefaultSleep
}