;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  ProtestMain  ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

ProtestMainFunction(){
local
global ue, fast, med, CurrentLFD
global WorkWindow, HistoryFileName, ProjectFile
global DefaultSleep, SleepAfterEnter
global TimeOutMsgSkippedIntro
global r_Main1, r_Main2, r_Main3
global r_LFD1, r_LFD2, cb_UseLFD
global c_Beginning, e_Beginning, c_SendDate, c_SkipLastPart
global e_Day, e_Month, e_Year
global r_AdvancedON
global StudyWithLFDs := GetIniValue(ProjectFile, "QuickSetupMenu", "c_StudyWithLFDs",1)
static XModulSkipped
CheckWorkWindow()
ListLines Off
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
		CheckCapture2TextIsRunning()
		if (CurrentLFD = "" and StudyWithLFDs = 1)
			CurrentLFD := InputBoxLFD()
		global IntroIsOver := false
		loop {
		fnOCR := OCR("Intro", A_Index)
		if (fnOCR != "")
			SkipIntro(fnOCR)
		else
			{
			Result := OCRIsEmpty()
			if (Result = "Exit")
				Exit
			else if (Result = "Pause")
				Pause
			}
			
		Sleep, SleepAfterEnter
		} Until (IntroIsOver = true)
		if (TimeOutMsgSkippedIntro > 0)
			MsgBox, 4096, Intro %ue%bersprungen! , Intro %ue%bersprungen! (No match for fn: "%fnOCR%"), %TimeOutMsgSkippedIntro%
		SaveToHistory("INTRO OVER")
		}
	}
If (r_Main2 = 1 OR r_Main3 = 1)
	{
	ListLines On
	Sleep, DefaultSleep
	CheckCapture2TextIsRunning()
	global SameFnCount := 0
	global TriedAnywaySkip := false
	global TriedXModulSkip := false 
	global fnSearchIsOver := false
	XModulSkipped := false
	; detect Number of Entries F4 Menu
	global UpcomingFnIndex := 0
	if (r_AdvancedON = 1)
		{
		loop, 5 {
		UpcomingFnName := GetIniValue(ProjectFile,"AdvancedSearchMenu", "e_fnN" . A_Index)
		if (UpcomingFnName != "ERROR")
			UpcomingFnIndex := A_Index
		} ; ende loop
		} ; ende if
	loop {
	fnOCR := OCR("fn-Suche", A_Index)
	Index := A_Index - 1
	fnSearch(fnOCR, Index)
	} Until (fnSearchIsOver = true)
	}
}

SkipIntro(fnOCR){
local
global LibraryFile
global fast, IntroIsOver
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
		fnOCR := c_fnOCR
	}
; Eingaben abrufen
EnterfnValue(fnOCR, fnIntroValue, "Intro") 
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

OCRIsEmpty(){
local 
Gui, 99:+AlwaysOnTop +ToolWindow
gui, 99:add, Text, x10 y10 w200 Center, Jetzt manuelle Eingabe t�tigen?
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
SaveToHistory("Keine fn gefunden. Eigene Aktion durchf�hren? Nein")
Result := "Exit"
Gui 99:Destroy
return 

99GuiRetryOCR:
SaveToHistory("Keine fn gefunden. Eigene Aktion durchf�hren? Retry OCR")
Result := "Retry"
Gui 99:Destroy
return 

99GuiYes:
SaveToHistory("Keine fn gefunden. Eigene Aktion durchf�hren? Ja")
Msgbox, 4096, Skript pausiert!, Skript ist pausiert. Eingabe t�tigen, dann mit F6 fortfahren!
Result := "Pause"
Gui 99:Destroy
return 
}

SaveToHistory(Info, params*){
local
global HistoryFile, AOx
global CreateHistory, VerboseHistory
;ListLines Off
TimeStemp := A_DDD . A_Space . A_DD . "." A_MMM . A_Space . A_Hour . ":" . A_Min . ":" . A_Sec 
if (Strlen(Info) <= 4)
	Spacing := A_Tab
else
	Spacing := A_Space
if (params.MaxIndex() = "")
	SendHistory := TimeStemp . A_Space . Info
else if (params.MaxIndex() = 1)
	SendHistory := TimeStemp . A_Space . Info . Spacing . params[1]
else if (params.MaxIndex() = 2)
	{
	if (params[2] = "")
		SendHistory := TimeStemp . A_Space . Info . Spacing . params[1]
	else
		SendHistory := TimeStemp . A_Space . Info . Spacing . params[1] . A_Space . "(" . params[2] . ")"
	}
else if (params.MaxIndex() = 3)	
	SendHistory := TimeStemp . A_Space . Info . Spacing . params[1] . A_Space . "(" . params[2] . " - " . params[3] . ")"

if (AOx = true AND %CreateHistory% = true)
	{
	; Verbose-Kommentare (nicht) mit speichern
	if (%VerboseHistory% = true)
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
	Msgbox, 4096, Ups!, %WorkWindow%-Fenster nicht vorhanden!
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

CheckCapture2TextIsRunning(){
Process, Exist, Capture2Text.exe
If (ErrorLevel = 0) ; If it is not running
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

ShowfnNag(){
global LibraryFile
Msgbox, 4096 , fnNag ,  % GetIniSectionClean(LibraryFile, "fnNag")
}

CheckPreloadInPreloadList(Preload){
local
global PreloadList
if (PreloadList != "")
	{ 
	PreloadExact := Preload . "`r"
	If !InStr(PreloadList, PreloadExact)
		{
		Msgbox, 4096, Ups! , %Preload% nicht in Liste!
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
		MsgBox, 4096, %ShowLFD% , F�r "%ShowLFD%" sind noch keine Werte vorhanden!
	}
else
	MsgBox, 4096, ShowLFD, Eingabe ist leer!
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
InptBoxTitle := "LFD-Angabe fehlt!" 
InputBoxDefault := GetIniValue(ProjectFile, QuickSetupMenu, "cb_UseLFD", A_Space)

; Show Input Box
InputboxDialog:
InputBox, EnteredLFD , %InptBoxTitle% , %InputBoxText%,, 250, 150,,,,,%InputBoxDefault% 
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