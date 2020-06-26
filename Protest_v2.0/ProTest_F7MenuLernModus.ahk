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
CheckCapture2TextIsRunning()
CheckWorkWindow()
e_fnLearn := ""
e_fnLearn := OCR("Learn", 0)
if (F7MousePosX != "")
	MouseMove, F7MousePosX, F7MousePosY

fnValue := ""
dd_Section := ""

; Eintrag vorhanden?
SectionArray := ["fnIntro", "fnNag"]
For i, Section in SectionArray
	{
	if (e_fnLearn = "")
		break
	dd_Section := Section
	fnValue := GetIniValue(LibraryFile, Section, e_fnLearn)
	if (fnValue = "ERROR")
		{
		CorrectedfnOCR := AutoCorrection(e_fnLearn, Section, fnValue)
		if (CorrectedfnOCR != e_fnLearn)
			{
			e_fnLearn := CorrectedfnOCR
			break
			}
		}
	else
		break
	}
; Eintrag noch nicht vorhanden
if (fnValue = "ERROR")
	{
	dd_Section := GetIniValue(TempFile, "LernModus", "LastSection", "fnIntro")
	SectionList := "fnIntro||fnNag"
	fnValue := ""
	}
else
	{
	if (dd_Section = "fnIntro")
		SectionList := "fnIntro||fnNag"
	else
		SectionList := "fnIntro|fnNag||"
	}
ActionList := fnValue . "||Get(sexPRE)|Get(gebtPRE/gebmPRE/gebjPRE)|Get()|Reverse(sexPRE)|Reverse()|Stop|Ende|{Enter}"
if (fnValue != "")
	fnComment := ExtractfnComment(e_fnLearn, dd_Section)
else
	fnComment := ""

Gui, 7: +AlwaysOnTop ToolWindow
Gui, 7:Add, Groupbox, x10 y10 w220 h140 cnavy, Lernmodus
Gui, 7:Add, Text, x20 y34 w50 h20, OCR-fn:
Gui, 7:Add, Edit, x103 y32 w120 h20 ve_fnLearn,	%e_fnLearn%
Gui, 7:Add, Text, x20 y56 w70 h20, Eingabewert:
Gui, 7:Add, Combobox, x103 y54 w120  h80 vfnValue, % ActionList
Gui, 7:Add, Text, x20 y79 w74 h20, Kommentar:
Gui, 7:Add, Edit, x103 y77 w120 h20 vfnComment, % fnComment
Gui, 7:Add, Text, x20 y103 w74 h20, Abschnitt:
Gui, 7:Add, DropDownList, x103 y101 w120  h80 vdd_Section, % SectionList
Gui, 7:Add, Checkbox, x20 y128 w140 h20 Checked%EnterWhileSaving% vEnterWhileSaving, beim Speichern ausführen
Gui, 7:Add, Button, x10 y155 w75 h25 g7GuiSave, Speichern
Gui, 7:Add, Button, x155 y155 w75 h25 Default g7GuiEnter, Ausführen
Gui, 7:Show, Autosize Center, % GuiF7
return 

7GuiClose:
7GuiEscape:
Gui 7:Submit, NoHide
SaveIniValue(ProjectFile, "LernModus", "EnterWhileSaving", EnterWhileSaving)
Gui 7:Destroy
DeleteIniSection(TempFile, "LernModus")
return  

7GuiSave:
WinActivate, %WorkWindow%
MouseGetPos, F7MousePosX, F7MousePosY
Gui 7:Submit, NoHide
; check if fnValue/Comment exists
if (fnValue = "" or fnComment = "")
	{
	Msgbox, 4096, Fehlende Angaben, Eintragungen für Eingabewert oder Kommentar fehlen!
	return
	}
if Instr(fnComment, ";")
	{
	Msgbox, 4096, Korrektur erforderlich, Bitte kein Semikolon ";" im Kommentar verwenden! 
	return
	}
ExistingFnValue := GetIniValue(LibraryFile, dd_Section, e_fnLearn)
if (ExistingFnValue != "ERROR")
	{
	; ja - Eintrag bereits vorhanden
	IniRead, ExistingFnValue, %LibraryFile%, %dd_Section%, %e_fnLearn%
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
		Im Abschnitt %dd_Section% ist bereits folgender Eintrag vorhanden: 
		`n%OldEntry%
		`nSoll der Eintrag wie folgt überschrieben werden?
		`n%NewEntry%
		)
		MsgBox, 4132, Eintrag für %e_fnLearn% bereits vorhanden!, %MsgBoxText%
		IfMsgBox, YES
			{
			; Eintrag überschrieben
			SaveIniValue(LibraryFile, dd_Section, e_fnLearn, fnValue . A_Tab . ";" . A_Space . fnComment)
			SaveToHistory("Neuer Eintrag:", NewEntry, "überschrieben")
			}
		else
			return
		}
	}
else
	{
	; Neuer Eintrag
	if (dd_Section = "fnIntro" and NewEntryF7fnIntro = false) or (dd_Section = "fnNag" and NewEntryF7fnNag = false)
		{
		; Ersten neuen Eintrag mit Abstand + Zeitstempel einfügen
		TimeStemp :=  A_DD . "." . A_MM . "." . A_YYYY
		SaveIniValue(LibraryFile, dd_Section, "`n; " . ProjectName . " Neuer Eintrag " . TimeStemp . "`nNeuerEintrag", "Blank")
		if (dd_Section = "fnIntro")
			NewEntryF7fnIntro := true
		else
			NewEntryF7fnNag := true
			
		}
	SaveIniValue(LibraryFile, dd_Section, e_fnLearn, fnValue . A_Tab . ";" . A_Space . fnComment)
	SaveIniValue(TempFile, "LernModus", "LastSection" , dd_Section)
	NewEntry := e_fnLearn . " = " . fnValue . A_Tab . ";" . A_Space . fnComment
	SaveToHistory("Neuer Eintrag: " . NewEntry)
	DeleteIniValue(LibraryFile, dd_Section, "NeuerEintrag")
	}
Gui 7:Destroy
if (EnterWhileSaving = 1)
	{
	LastFn := ""
	EnterfnValue(e_fnLearn, fnValue, "LernModus")
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
	EnterfnValue(e_fnLearn, fnValue, "LernModus")
	}
else
	{
	Msgbox, 4096, Fehlende Angaben, Eintragungen für OCR-fn oder fnEingabewert fehlen!
	return
	}
SaveIniValue(ProjectFile, "LernModus", "EnterWhileSaving", EnterWhileSaving)
Goto 7GuiSetControls
return 

ExtractfnComment(fn, Section){
local
global LibraryFile
IniRead, Comment, %LibraryFile%, %Section%, %fn%
if (Comment = "ERROR")
	fnComment := ""
else
	fnComment := Substr(Comment, (Instr(Comment, ";") + 2))
return fnComment
}