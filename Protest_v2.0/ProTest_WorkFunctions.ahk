;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  ProtestMain  ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

ProtestMainFunction(){
local
global fast, med, CurrentLFD
global WorkWindow, HistoryFileName, ProjectFile
global DefaultSleep, SleepAfterEnter
global TimeOutMsgSkippedIntro
global r_Main1, r_Main2, r_Main3
global r_LFD1, r_LFD2, cb_UseLFD
global c_Beginning, e_Beginning, c_SendDate, c_SkipLastPart
global e_Day, e_Month, e_Year
global c_Next, e_Next
global r_AdvancedON
global StudyWithLFDs := GetIniValue(ProjectFile, "QuickSetupMenu", "c_StudyWithLFDs",1)
global AdvancedSearchMenu
global LastFn := ""
CheckWorkWindow()
SaveToHistory("####  F2  ####")
WinKill, %HistoryFileName%
If (r_Main1 = 1) OR (r_Main3 = 1)
	{
	;;; INTRO
	SetKeyDelay, fast 
	if (c_Beginning = 1)
		{
		Sleep, fast
		Send, %e_Beginning%
		SaveToHistory("Starten mit: " . e_Beginning)
		sleep, med
		}
	if (c_SendDate = 1)
		{
		;SendDate()
		SetKeyDelay, med
		Send, %e_Day%{Enter}%e_Month%{Enter}%e_Year%{Enter}
		SetKeyDelay, fast
		SaveToHistory("Datum eingeben: " . e_Day . "." . e_Month . "." . e_Year)
		}
	if (c_Next = 1)
		{
		;Weiter mit
		SetKeyDelay, med
		Send, %e_Next%
		SetKeyDelay, fast
		SaveToHistory("Weiter mit: " . e_Next)
		}
	if (r_LFD1 = 1)
		{
		Sleep, DefaultSleep
		EnterLFD(cb_UseLFD)
		CurrentLFD := cb_UseLFD
		SaveToHistory("LFD Eingabe: " . CurrentLFD)
		L_WaitUntilPreloadsLoaded()
		Sleep, DefaultSleep
		}
	if (r_LFD2 = 1)
		{
		cb_StartLFD := GetIniValue(ProjectFile, "LFDFinderMenu", "cb_StartLFD")
		if (cb_StartLFD = "ERROR")
			{
			MsgBox, 4096, Ende , Keine Start-LFD eingegeben. LFD-Suche wird beendet!
			Exit
			}
		LFDFinderRoutine()
		}
	if (c_SkipLastPart = 1)
		{
		ListLines On
		Sleep, DefaultSleep
		if (CurrentLFD = "" and StudyWithLFDs = 1)
			CurrentLFD := InputBoxLFD()
		global IntroIsOver := false
		Index := 0
		loop {
		fnOCR := OCR("Intro", Index)
		if (fnOCR = "")
			{
			if (Index = 0)
				{
				++Index
				Continue
				}
			Result := OCRIsEmpty()
			if (Result = "Exit")
				Exit
			else if (Result = "Pause")
				Pause
			}
		else
			SkipIntro(fnOCR)
		++Index
		if (fnOCR != "")
			LastFn := fnOCR
		} Until (IntroIsOver = true)
		if (TimeOutMsgSkippedIntro > 0)
			MsgBox, 4096, Intro übersprungen! , Intro übersprungen! (No match for fn: "%fnOCR%"), %TimeOutMsgSkippedIntro%
		SaveToHistory("### ENDE Eingangsfragen ###")
		}
	}
If (r_Main2 = 1 OR r_Main3 = 1)
	{
	SaveToHistory("### Zu einer Fragenummer springen ###")
	Sleep, DefaultSleep
	CheckWorkWindow()
	AlarmIfCapture2TextIsNotRunning()
	global TriedXModulSkip := false 
	PrepareTargetfn()
	if (r_AdvancedON = 1)
		PrepareUpComingFn()
	SaveToHistory("######")
	global fnSearchIsOver := false
	loop {
	fnOCR := OCR("fn-Suche", A_Index-1)
	fnSearch(fnOCR, A_Index-1)
	if (fnOCR != "")
		LastFn := fnOCR
	} Until (fnSearchIsOver = true)
	}
}

PrepareTargetfn(){
local
global e_Targetfn1, e_Targetfn2, e_Targetfn3
global TargetFnArray := {}
TargetFnControlArray := [e_Targetfn1, e_Targetfn2, e_Targetfn3]
TargetFnString := ""
for i, TargetFn in TargetFnControlArray
	{
	if (TargetFn != "")
		{
		TargetFnArray[A_Index] := TargetFn
		if (TargetFnString = "")
			TargetFnString := TargetFn
		else
			TargetFnString .= ", " TargetFn
		}
	}
if (TargetFnString != "")
	SaveToHistory("Ziel-Fn: " . TargetFnString )
}

PrepareUpComingFn(){
local
global ProjectFile
global UpcomingFnIndex := 0
global UpcomingFnArray := {}
loop, 5 {
UpcomingFnName := GetIniValue(ProjectFile, "AdvancedSearchMenu", "e_fnN" . A_Index)
if (UpcomingFnName != "ERROR")
	{
	UpcomingFnValue := GetIniValue(ProjectFile,"AdvancedSearchMenu", "e_fnV" . A_Index)
	UpcomingFnArray[UpcomingFnName] := UpcomingFnValue 
	++UpcomingFnIndex
	SaveToHistory(UpcomingFnName, "= " . UpcomingFnValue,"F4")
	}
} ; ende loop
} ; ende function

SkipIntro(fnOCR){
local
global LibraryFile
global IntroIsOver
; Check in LibraryFile
fnIntroValue := GetIniValue(LibraryFile, fnIntro, fnOCR)
If (fnIntroValue = "ERROR")
	{
	CorrectedfnOCR := AutoCorrection(fnOCR, fnIntro, fnIntroValue)
	if (CorrectedfnOCR = fnOCR) 
		{
		IntroIsOver := true
		return
		}
	else
		fnOCR := CorrectedfnOCR
	}
; Eingaben abrufen
EnterfnValue(fnOCR, fnIntroValue, "Eingangsfrage") 
} ; ende SkipIntro function

EnterLFD(LFD){
local
global fast, med
CheckWorkWindow()
SetKeyDelay, med
Send, %LFD%{Enter}
sleep, fast 
Send, {Enter}
SetKeyDelay, fast
}

MsgWindow(params*){
local
if (params.MaxIndex() != "")
	{
	MsgWindowText := params[1]
	Gui, 15: -Caption +AlwaysOnTop -SysMenu
	Gui, 15:Font, s14, Verdana
	Gui, 15:Add, Text,, %MsgWindowText%
	Gui, 15:Show, Autosize Center, PleaseWaitWindow
	}
else
	Gui 15:Destroy
}


OCRIsEmpty(){
local 
Gui, 99:+AlwaysOnTop +ToolWindow
gui, 99:add, Text, x10 y10 w200 Center, Jetzt manuelle Eingabe tätigen?
gui, 99:add, button, x10 y30 w50 g99GuiYes, Ja
gui, 99:add, button, x65 y30 w50 g99GuiCancel, nein 
gui, 99:add, button, x130 y30 w80 Default g99GuiRetryOCR, Retry OCR
gui, 99:show, Center Autosize, Keine fn gefunden!
WinWaitActive, Keine fn gefunden!
WinWaitClose, Keine fn gefunden!
return Result

99GuiEscape:
99GuiCancel:
99GuiClose:
SaveToHistory("Keine fn gefunden. Eigene Aktion durchführen? Nein")
Result := "Exit"
Gui 99:Destroy
return 

99GuiRetryOCR:
SaveToHistory("Keine fn gefunden. Eigene Aktion durchführen? Retry OCR")
Result := "Retry"
Gui 99:Destroy
return 

99GuiYes:
SaveToHistory("Keine fn gefunden. Eigene Aktion durchführen? Ja")
Msgbox, 4096, Skript pausiert!, Skript ist pausiert. Eingabe tätigen, dann mit F6 fortfahren!
Result := "Pause"
Gui 99:Destroy
return 
}

SaveToHistory(Info, params*){
local
global HistoryFile
global CreateHistory, VerboseHistory
ListLines Off
TimeStemp := A_DDD . A_Space . A_DD . "." A_MMM . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec 
if (Strlen(Info) <= 4)
	Spacing := A_Tab
else
	Spacing := A_Space

BasicHistory := TimeStemp . A_Space . Info
SendHistory := BasicHistory
if (params.MaxIndex() = 1)
	SendHistory := BasicHistory . Spacing . params[1]
else if (params.MaxIndex() = 2)
	SendHistory := BasicHistory . Spacing . params[1] . A_Space . "(" . params[2] . ")"
else if (params.MaxIndex() = 3)	
	SendHistory := BasicHistory . Spacing . params[1] . A_Space . "(" . params[2] . " - " . params[3] . ")"

ListLines On
if (CreateHistory = 1) ; true
	{
	; Verbose-Kommentare (nicht) mit speichern
	if (VerboseHistory = "true")
		FileAppend, %SendHistory%`n, %HistoryFile%
	else if (Info != "VERBOSE:")
		FileAppend, %SendHistory%`n, %HistoryFile%
	}
;ListLines On
}

CheckWorkWindow(){
global WorkWindow
ListLines Off
if !WinExist(WorkWindow)
	{
	Msgbox, 4096, Ups!, TeamViewer-Fenster nicht vorhanden!
	ListLines On
	Exit
	}
else
	{
	if !WinActive(WorkWindow)
		{
		WinActivate, %WorkWindow%
		WinWaitActive, %WorkWindow%
		}
	}
ListLines On
}

AlarmIfCapture2TextIsNotRunning(){
global Captur2TextPID
If (Captur2TextPID = 0) ; is not running
	{
	Msgbox, 4096, Ups!, Capture2Text.exe is not running!
	Exit 
	}
}

SendDate(){
global fast, med
SetKeyDelay, med
Send, %A_DD%{Enter}%A_MM%{Enter}%A_YYYY%{Enter}
SetKeyDelay, fast 
}

ShowfnSkip(){
global LibraryFile
Msgbox, 4096 , %fnSkip% ,  % GetIniSectionClean(LibraryFile, fnSkip)
}

CheckPreloadInPreloadList(Preload){
local
global PreloadList
if (PreloadList != "")
	{ 
	PreloadExact := Preload . "`r"
	If !InStr(PreloadList, PreloadExact)
		{
		Msgbox, 4096, Ups! , %Preload% nicht in Preload-Liste!
		Exit
		}
	}
}

;;;;;;;;;;;;;;;;;;;;;;
;;;; LFD BUISNESS ;;;;
;;;;;;;;;;;;;;;;;;;;;;

CreateLFDList(Menu){
local
global ProjectFile, TempFile
LFDListTempFile := GetIniSectionNames(TempFile)
cb_UseLFD := GetIniValue(ProjectFile, "QuickSetupMenu", "cb_UseLFD", A_Space)
cb_StartLFD := GetIniValue(ProjectFile, "LFDFinderMenu", "cb_StartLFD", A_Space) 
if (Menu = "F2")
	{
	FirstEntry := cb_UseLFD
	if (FirstEntry = "")
		LFDList := cb_StartLFD . "||"
	else
		LFDList := FirstEntry . "||"
	}
else if (Menu = "F3")
	{
	FirstEntry := cb_StartLFD
	if (FirstEntry = "")
		LFDList := cb_UseLFD . "||"
	else
		LFDList := FirstEntry . "||"
	}

Loop, Parse, LFDListTempFile, "`n"
	{
	if Instr(A_LoopField, "LFD_")
		{
		if (Substr(A_LoopField, 5) != FirstEntry) and !Instr(LFDList, Substr(A_LoopField, 5)) 
			LFDList .= Substr(A_LoopField, 5) . "|"
		}
	}
return LFDList
}

GetPreloadDetails(Preload){
local
global PreloadDetailsFile 
IniRead, PreloadSectionDetails, %PreloadDetailsFile%, %Preload%
if (PreloadSectionDetails != "")
	{
	PreloadDetails := ""
	Loop, parse, PreloadSectionDetails, `n, `r
		{
		; remove "we1="
		ThisLine := RegExReplace(A_LoopField,"we\d=")
		ThisLine := RegExReplace(ThisLine,"=",": ")
		; add "--" infront word characters
		ThisLine := RegExReplace(ThisLine,"^\D","--$0")
		PreloadDetails .= ThisLine . "`n"
		}
	return PreloadDetails
	}
else
	return "Keine Preload-Infos hinterlegt"
}

ShowSelectedLFDValues(LFDComboBoxField){
local
global TempFile 
GuiControlGet, ShowLFD ,, % LFDComboBoxField
if (ShowLFD != "")
	{ 
	LFDSection := "LFD_" . ShowLFD
	ShowLFDValues := GetIniSection(TempFile, LFDSection)
	if (ShowLFDValues != "")
		MsgBox, 4096, %ShowLFD% , %ShowLFDValues%
	else
		MsgBox, 4096, %ShowLFD% , Für "%ShowLFD%" sind noch keine Werte vorhanden!
	}
else
	MsgBox, 4096, ShowLFD, Eingabe ist leer!
}

CheckLFDSectionNames(CurrentLFD){
local
global TempFile, TempFileName, IgnoreLFDConflict
If (IgnoreLFDConflict = "true")
	return
else
	{
	LFDListTempFile := GetIniSectionNames(TempFile)
	Loop, parse, LFDListTempFile, `n, `r
			{
			if (Instr(A_LoopField, "LFD_"))
				{
				LFDCheck := StrReplace(A_LoopField, "LFD_")
				CurrentTempFileDigits := SubStr(LFDCheck, 1 , 2)
				CurrentLFDDigits := SubStr(CurrentLFD, 1 , 2)
				if (CurrentTempFileDigits != CurrentLFDDigits)
					{
					LFDConflictText = 
					( LTrim Join
					Im TempFile (%TempFileName%) beginnen die LFDs mit %CurrentTempFileDigits% (z.B. %LFDCheck%), die
					%A_Space%aktuelle LFD ist jedoch %CurrentLFD%. Wahrscheinlich passt die aktuelle Projektdatei nicht
					%A_Space%zur aktuellen Studie. Der aktuelle Durchlauf wird deshalb beendet. Bitte Projektdatei über das F10 Menü ändern!
					)
					MsgBox, 4096, LFD Konflikt!, % LFDConflictText
					Exit
					}
				}
			}
	} ; ende else IgnoreLFDConflict
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;     INPUT-BOXES      ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InputBoxLFD(){
local
global ProjectFile, QuickSetupMenu
global LFDLimit

; Setting Up InPut Box
InputBoxText := "Bitte eine LFD eingeben!"
InputBoxTitle := "LFD-Angabe fehlt!" 
InputBoxDefault := GetIniValue(ProjectFile, QuickSetupMenu, "cb_UseLFD", A_Space)

; Show Input Box
InputboxDialog:
InputBox, EnteredLFD , %InputBoxTitle% , %InputBoxText%,, 250, 150,,,,,%InputBoxDefault% 
if (ErrorLevel = 1 OR EnteredLFD = "") ; Cancel or Closed, no LFD
	{
	MsgBox, 4096, Ende , Durchlauf beendet!
	Exit
	}
else if (StrLen(EnteredLFD) != LFDLimit)
	{
	MsgBox, 4096, Ende , LFD hat zu wenig oder zu viele Stellen!
	InputBoxDefault := EnteredLFD
	Goto InputboxDialog
	}
else
	{
	return EnteredLFD
	}
}

;;;;;;;;;;;;;;;;;;;;;;
;;;;  Tray AREA   ;;;;
;;;;;;;;;;;;;;;;;;;;;;
AboutMessage:

Gui, 20:+AlwaysOnTop +ToolWindow
Gui, 20:add, Text, x10 y10 w150 Center, ProTest - Version %ProTestVersion%
Gui, 20:add, Text, x10 y30 w150 Center, dietzste@hu-berlin.de
Gui, 20:show, Center Autosize, About ProTest
WinWaitActive, About ProTest
WinWaitClose, About ProTest
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  TEMP FILE Cleaning   ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CleanTempFile(TempFile){
local
FalseEntry := GetIniSection(TempFile, "LFD_")
if (FalseEntry != "ERROR")
	DeleteIniSection(TempFile, "LFD_")
LFDSections := GetIniSectionNames(TempFile)
LFDDigitsArray := {}
LFDList := ""
If (LFDSections != "ERROR")
	{
	Loop, parse, LFDSections, `n, `r
		{
		if Instr(A_LoopField, "LFD_")
			{
			ThisLine := StrReplace(A_LoopField, "LFD_")
			LFDList .= ThisLine . "`n"
			FirstTwoDigits := Substr(ThisLine, 1, 2)
			Value := LFDDigitsArray[FirstTwoDigits]
			If (Value = "")
				LFDDigitsArray[FirstTwoDigits] := 1
			else
				LFDDigitsArray[FirstTwoDigits] := ++Value
			}
		} ; ende loop
	LFDDigitsCount := LFDDigitsArray.Count()
	If (LFDDigitsCount > 1)
		{
		; start CleanUpLoop
		CleanupLoopCount := LFDDigitsCount-1
		Loop, %CleanupLoopCount% {
		LFDTypeList := ""
		InputBoxDefault := 0
		For LFDType, n in LFDDigitsArray
			{
			LFDTypeList .= LFDType . "... (n = " . n . ")`n"
			If (A_Index = 1)
				{
				SmallestCount := n
				InputBoxDefault := LFDType
				}
			else if (n < SmallestCount)
				{
				SmallestCount := n
				InputBoxDefault := LFDType
				}
			}
		; InputBox, OutputVar , Title, Prompt, HIDE, Width, Height, X, Y, Locale, Timeout, Default
		InputBoxTitle := "LFD Konflikt erkannt!"
		InputBoxText := "Im TempFile starten LFDs mit unterschiedlichen Zahlen:`n" . LFDTypeList . "`nMit welchen zwei Zahlen beginnen die LFDs, die gelöscht werden sollen? (Schleife " . A_Index . "/" . LFDDigitsCount-1 . ")"
		ShowThisInputBox:
		InputBox, CleanupDigit , %InputBoxTitle% , %InputBoxText%,, 250, 300,,,,,%InputBoxDefault%
		if (ErrorLevel = 1) or (ErrorLevel = 0 And CleanupDigit = "")
			{
			AbbruchText =
			( LTrim Join
			Die Bereinigung des TempFiles wurde abgebrochen! 
			%A_Space%Um die Bereinigung zu wiederholen, bitte die aktuelle Projektdatei über das F10-Menü erneut auswählen.
			%A_Space%Das TempFile enthält weiterhin fehlerhafte Eintragungen.
			)
			MsgBox, 4096, Bereinigung abgebrochen!, %AbbruchText%
			Break
			}
		else if (ErrorLevel = 0 and StrLen(CleanupDigit) != 2)
			{
			MsgBox, 4096, Fehlerhafte Eingabe!, Bitte nur zwei Zahlen eingeben!
			Goto ShowThisInputBox
			}
		else
			{
			; Bereinigung TempFile
			DeletedLFDs := CleanUpTempFile(TempFile, LFDList, CleanupDigit)
			MsgBox, 4096, Bereinigung durchgeführt!, TempFile erfolgreich bereinigt! Gelöschte LFDs:`n%DeletedLFDs%
			LFDDigitsArray.Delete(CleanupDigit)
			}
		} ; CleanupLoop 
		} ; if LFDTypes Count
	} ; ende if LFDSections
} ; ende function

CleanUpTempFile(TempFile, LFDList , CleanupDigit){
local
DeletedLFDs := ""
Loop, parse, LFDList , `n, `r
	{
	if Instr(A_LoopField, CleanupDigit)
		{
		ThisLFD := "LFD_" . A_LoopField
		DeletedLFDs .= A_LoopField . "`n"
		DeleteIniSection(TempFile, ThisLFD)
		}
	} ; ende loop
return DeletedLFDs
}