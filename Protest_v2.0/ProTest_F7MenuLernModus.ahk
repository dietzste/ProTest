F7::
SetTitleMatchMode, 3
If WinExist(GuiF7)
	WinActivate, %GuiF7%
else
	Goto F7Routine
return

F7Routine:
SetTitleMatchMode, 2
; MouseMoves
F7MousePosX := ""
F7MousePosY := ""
EnterWhileSaving := GetIniValue(ProjectFile, "LernModus", "EnterWhileSaving", 1)

7GuiSetControls:
AlarmIfCapture2TextIsNotRunning()
CheckWorkWindow()
e_fnLearn := ""
e_fnLearn := OCR("Learn", 0)
if (F7MousePosX != "")
	MouseMove, F7MousePosX, F7MousePosY

fnValue := ""
; Eintrag vorhanden?
if (e_fnLearn != "")
	{
	fnValue := GetIniValue(LibraryFile, fnBib, e_fnLearn)
	if (fnValue = "ERROR")
		{
		CorrectedfnOCR := AutoCorrection(e_fnLearn, fnValue)
		if (CorrectedfnOCR != e_fnLearn)
			e_fnLearn := CorrectedfnOCR
		}
	}
; Eintrag noch nicht vorhanden
if (fnValue = "ERROR")
	fnValue := ""

ActionList := fnValue . "||Get(sexPRE)|Get(gebtPRE/gebmPRE/gebjPRE)|Get()|Reverse(sexPRE)|Reverse()|Stop|Ende|{Enter}"
if (fnValue != "")
	fnComment := ExtractfnComment(e_fnLearn)
else
	fnComment := ""

Gui, 7: +AlwaysOnTop ToolWindow
Gui, 7:Add, Groupbox, x10 y10 w260 h115 cnavy, Antworten definieren
Gui, 7:Add, Text, x20 y34 w70 h20, Fragenummer:
Gui, 7:Add, Edit, x103 y32 w160 h20 ve_fnLearn,	%e_fnLearn%
Gui, 7:Add, Text, x20 y56 w70 h20, Eingabewert:
Gui, 7:Add, Combobox, x103 y54 w160 h80 vfnValue, % ActionList
Gui, 7:Add, Text, x20 y79 w74 h20, Kommentar:
Gui, 7:Add, Edit, x103 y77 w160 h20 vfnComment, % fnComment
Gui, 7:Add, Checkbox, x20 y103 w140 h20 Checked%EnterWhileSaving% vEnterWhileSaving, beim Speichern ausführen
Gui, 7:Add, Button, x10 y130 w75 h25 g7GuiSave, Speichern
Gui, 7:Add, Button, x90 y130 w75 h25 g7GuiDelete, Löschen
Gui, 7:Add, Button, x195 y130 w75 h25 Default g7GuiEnter, Ausführen
Gui, 7:Show, Autosize Center, % GuiF7
return 

7GuiClose:
7GuiEscape:
Gui 7:Submit, NoHide
SaveIniValue(ProjectFile, "LernModus", "EnterWhileSaving", EnterWhileSaving)
Gui 7:Destroy
return

7GuiDelete:
Gui 7:Submit, NoHide
if (e_fnLearn != "")
	{
	fnValue := GetIniValue(LibraryFile, fnBib, e_fnLearn)
	if (fnValue != "ERROR")
		{
		fnComment := ExtractfnComment(e_fnLearn)
		fntoDeleteText := "fn: " . e_fnLearn . "`nEingabewert: " . fnValue . "`nKommentar: " . fnComment
		MsgBox, 4132, Eintrag löschen?, Soll folgender Eintrag gelöscht werden? `n`n%fntoDeleteText%
		IfMsgBox, YES
			{
			DeleteIniValue(LibraryFile, fnBib, e_fnLearn)
			Msgbox, 4096, Eintrag gelöscht!, Eintrag für %e_fnLearn% erfolgreich gelöscht!
			Gui 7:Destroy
			Goto 7GuiSetControls
			}
		}
	else
		Msgbox, 4096, Eintrag nicht vorhanden!, Für die fn %e_fnLearn% ist kein Eintrag in der %fnBib% vorhanden!
	}
else
	Msgbox, 4096, Fehlende Angaben!, Das Feld "Fragenummer" ist leer!
return

7GuiSave:
WinActivate, %WorkWindow%
MouseGetPos, F7MousePosX, F7MousePosY
Gui 7:Submit, NoHide
; check if fnValue/Comment exists
; keine leeren Eingaben
if (fnValue = "" or fnComment = "")
	{
	Msgbox, 4096, Fehlende Angaben, Eintragungen für Eingabewert oder Kommentar fehlen!
	return
	}
; kein Semikolon
if Instr(fnComment, ";")
	{
	Msgbox, 4096, Korrektur erforderlich, Bitte kein Semikolon ";" im Kommentar verwenden! 
	return
	}
; keine doppelten Klammern
ActionCount := 0
StrReplace(fnValue, "(", "(", Count)
ActionCount += Count
StrReplace(fnValue, ")", ")", Count)
ActionCount += Count
if (ActionCount = 1 or ActionCount > 2) 
	{
	Msgbox, 4096, Korrektur erforderlich, Der Eingabewert "%fnValue%" enthält zu viele Klammern!
	return
	}
else if (ActionCount = 2 or ActionCount = 1)
	{
	if (Instr(fnValue, "{") or Instr(fnValue, "}"))
		{
		Msgbox, 4096, Korrektur erforderlich, Der Eingabewert "%fnValue%" ist ungültig. Es dürfen nur runde ODER eckige Klammern verwendet werden!
		return
		}
	}
ExistingFnValue := GetIniValue(LibraryFile, fnBib, e_fnLearn)
if (ExistingFnValue != "ERROR")
	{
	; ja - Eintrag bereits vorhanden
	IniRead, ExistingFnValue, %LibraryFile%, %fnBib%, %e_fnLearn%
	OldEntry := e_fnLearn . " = " . ExistingFnValue
	NewEntry := e_fnLearn . " = " . fnValue . A_Tab . ";" . A_Space . fnComment
	; Vergleich ohne Tabs
	CleanOldEntry := StrReplace(OldEntry, A_Tab)
	CleanNewEntry := StrReplace(NewEntry, A_Tab)
	if (CleanOldEntry != CleanNewEntry)
		{
		; Neuer Eintrag hat sich geändert
		MsgBoxText = 
		(
		Es ist bereits folgender Eintrag vorhanden: 
		`n%OldEntry%
		`nSoll der Eintrag wie folgt überschrieben werden?
		`n%NewEntry%
		)
		MsgBox, 4132, Eintrag für %e_fnLearn% bereits vorhanden!, %MsgBoxText%
		IfMsgBox, YES
			{
			; Eintrag überschrieben
			SaveIniValue(LibraryFile, fnBib, e_fnLearn, fnValue . A_Tab . ";" . A_Space . fnComment)
			SaveToHistory("Neuer Eintrag:", NewEntry, "überschrieben")
			}
		else
			return
		}
	}
else
	{
	; Neuer Eintrag
	if (NewEntryF7 = true)
		{
		; Ersten neuen Eintrag mit Abstand + Zeitstempel einfügen
		TimeStemp :=  A_DD . "." . A_MM . "." . A_YYYY
		SaveIniValue(LibraryFile, fnBib, "`n; " . ProjectName . " Neuer Eintrag " . TimeStemp . "`nNeuerEintrag", "Blank")
		NewEntryF7 := false
		}
	SaveIniValue(LibraryFile, fnBib, e_fnLearn, fnValue . A_Tab . ";" . A_Space . fnComment)
	NewEntry := e_fnLearn . " = " . fnValue . A_Tab . ";" . A_Space . fnComment
	SaveToHistory("Neuer Eintrag: " . NewEntry)
	DeleteIniValue(LibraryFile, fnBib, "NeuerEintrag")
	}
Gui 7:Destroy
if (EnterWhileSaving = 1)
	{
	LastFn := ""
	EnterfnValue(e_fnLearn, fnValue, "F7 - Eingabe speichern und ausführen")
	}
SaveIniValue(ProjectFile, "LernModus", "EnterWhileSaving", EnterWhileSaving)
Goto 7GuiSetControls
return

7GuiEnter:
Gui 7:Submit, NoHide
WinActivate, %WorkWindow%
MouseGetPos, F7MousePosX, F7MousePosY
if (e_fnLearn != "" and fnValue != "")
	{
	Gui 7:Destroy
	LastFn := ""
	EnterfnValue(e_fnLearn, fnValue, "F7 - Eingabe ausführen")
	}
else
	{
	Msgbox, 4096, Fehlende Angaben, Eintragungen der Fragenummer oder Eingabewert fehlen!
	return
	}
SaveIniValue(ProjectFile, "LernModus", "EnterWhileSaving", EnterWhileSaving)
Goto 7GuiSetControls
return 

ExtractfnComment(fn){
local
global LibraryFile, fnBib
IniRead, Comment, %LibraryFile%, %fnBib%, %fn%
if (Comment = "ERROR")
	fnComment := ""
else
	fnComment := Substr(Comment, (Instr(Comment, ";") + 2))
return fnComment
}