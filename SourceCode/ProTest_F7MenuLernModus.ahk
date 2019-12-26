#if (AddOns = true)
F7::
GuiF7 := "LernModus - AddtoLibrary"
If WinExist(GuiF7)
	WinActivate, %GuiF7%
else
	Goto F7Routine
return

F7Routine:
CheckCapture2TextIsRunning()
e_fnLearn := OCR("Learn", 1)

7GuiSetControls:
IniRead, dd_Section, %TempFile%, LernModus, dd_Section
IniRead, cb_action, %TempFile%, LernModus, cb_action, %A_Space%
if (dd_Section = "fnIntro" OR dd_Section = "ERROR")
	{
	ActionList := cb_action . "||IntroGetSex|IntroSexReversed|IntroGetDateOfBirth"
	SectionList := "fnIntro||fnNag"
	}
else if (dd_Section = "fnNag")
	{
	
	Actionlist := cb_action . "||Stop|Ende|{Enter}"
	SectionList := "fnIntro|fnNag||"
	}
IniRead, e_comment, %TempFile%, LernModus, e_comment, %A_Space%

Gui, 7: +AlwaysOnTop ToolWindow
Gui, 7:Add, Groupbox, x10 y10 w200 h115 cnavy, Lernmodus
Gui, 7:Add, Text, x20 y34 w50 h20, OCR-fn:
Gui, 7:Add, Edit, x83 y32 w120 h20 ve_fnLearn,	%e_fnLearn%
Gui, 7:Add, Text, x20 y56 w50 h20, Aktion:
Gui, 7:Add, Combobox, x83 y54 w120  h80 vcb_action, % ActionList
Gui, 7:Add, Text, x20 y79 w74 h20, Kommentar:
Gui, 7:Add, Edit, x83 y77 w120 h20 ve_comment, % e_comment
Gui, 7:Add, Text, x20 y103 w74 h20, Section:
Gui, 7:Add, DropDownList, x83 y101 w120  h80 vdd_Section g7GuiChangeSection, % SectionList
Gui, 7:Add, Button, x150 y130 w60 h25 g7GuiNext, N%ae%chste
Gui, 7:Show, Autosize Center, % GuiF7
return 

7GuiClose:
7GuiEscape:
Gui 7:Destroy
DeleteIniSection(TempFile, "LernModus")
return 

;7GuiIntroValues:
;Msgbox, 4096 , fnIntro ,  % GetIniSectionClean(LibraryFile, "fnIntro")
;return

;7GuifnNag:
;ShowfnNag()
;return  

7GuiChangeSection:
Gui 7:Submit, NoHide
SaveIniValue(TempFile, "LernModus", "cb_action" , cb_action)
SaveIniValue(TempFile, "LernModus", "e_comment" , e_comment)
SaveIniValue(TempFile, "LernModus", "dd_Section" , dd_Section)
Gui 7:Destroy
Goto 7GuiSetControls
return 

7GuiNext:
Gui 7:Submit, NoHide
if (dd_Section = "fnIntro")
	{
	if (cb_action = "Stop" OR cb_action = "Ende" OR Instr(cb_action, "Preload(") OR cb_action = "")
		{
		Msgbox, 4096 , Ung%ue%ltige Eingabe! , M%oe%gliche Eingaben sind: `nZahlen`nIntroGetSex`nIntroSexReversed`nIntroGetDateOfBirth
		Exit
		}
	else
		SaveIniValue(LibraryFile, "fnIntro", e_fnLearn, cb_action . A_Tab . ";" . e_comment)
	}
else if (dd_Section = "fnNag")
	{
	if (cb_action = "IntroGetSex" OR cb_action = "IntroSexReversed" OR cb_action = "IntroGetDateOfBirth" OR cb_action = "")
		{
		Msgbox, 4096 , Ung%ue%ltige Eingabe! , M%oe%gliche Eingaben sind: `nZahlen`nStop`nEnde`nPreload(X)
		Exit
		}
	else
		SaveIniValue(LibraryFile, "fnNag", e_fnLearn, cb_action . A_Tab . ";" . A_Space . e_comment)
	}
Gui 7:Destroy
DeleteIniSection(TempFile, "LernModus")
If cb_action is digit
	{
	Send %cb_action%{Enter}
	Sleep, SleepAfterEnter
	}
else if (cb_action = "IntroGetSex")
	{
	cb_action := L_ReadPreload(e_sex)
	Send %cb_action%{Enter}
	Sleep, SleepAfterEnter
	}
else if (cb_action = "IntroSexReversed")
	{
	ReverseSexValue(e_fnLearn)
	}
else if (cb_action = "IntroGetDateOfBirth")
	{
	EnterDateOfBirth(e_fnLearn)
	}
Goto 7GuiSetControls
return 
#if 

#if (AddOns = true)
^l::

; Search Through Library
Library:
; Fenster richtig darstellen
if WinExist(GuiF7)
	{
	WinGetPos,MenuPosX, MenuPosY, MenuWidth, MenuHeight, %GuiF7%
	FineTuneX := Ceil((ScreenWidth * 5)/StandardWidth)
	AutoEditX := MenuPosX + MenuWidth + FineTuneX
	AutoEditY := MenuPosY
	77GuiCenter := ""
	}
else
	{
	77GuiCenter := "Center"
	AutoEditX := 0
	AutoEditY := 0
	}
LibraryContent := "fn"

; Setting up Library
SettingUpLibraryContent:
IniRead, SectionfnIntro, %LibraryFile%, fnIntro
IniRead, SectionfnNag, %LibraryFile%, fnNag
LibraryList := ""
e_SearchResult := ""
DuplicateComments := 0

SectionArray := ["SectionfnIntro", "SectionfnNag"]
for i, Section in SectionArray
	{
	Loop, Parse, %Section%, "`n"
		{
		if (LibraryContent = "fn")
			{
			EqualSign := Instr(A_LoopField, "=")
			Preload := StrReplace(Substr(A_LoopField, 1, (EqualSign-1)), "")
			LibraryList .= Preload . "|"
			DuplicateMessage := ""
			SortList := ""
			}
		else
			{
			PreloadComment := Substr(A_LoopField, (Instr(A_LoopField, ";") + 2))
			; sonderzeichen ersetzen
			PreloadComment := StrReplace(PreloadComment, "ö", oe)
			PreloadComment := StrReplace(PreloadComment, "ä", ae)			
			PreloadComment := StrReplace(PreloadComment, "ü", ue)
			if !Instr(LibraryList, PreloadComment, true)
				LibraryList .=  PreloadComment . "|"
			else
				++DuplicateComments 
			DuplicateMessage := "(Duplikate: " . DuplicateComments . ")"
			SortList := "Sort"			
			}
		}
	}

; Checkbox 
if (LibraryContent = "fn")
	dd_Source := 1
else
	dd_Source := 4
	
	
Gui, 77:+AlwaysOnTop ToolWindow
Gui, 77:Add, Groupbox, x9 y10 w400 h185 cNavy, Library.ini
; Suche
Gui, 77:Add, Text, x200 y32 w35 h20, Suche:
Gui, 77:Add, Edit, x245 y28 w120 h20 ve_SearchField g77GuiSearchLibrary, % e_SearchResult
Gui, 77:Add, Listbox, x16 y30 w170 h150 %SortList% vLibrarySearchResult , % LibraryList
Gui, 77:Add, Button, x371 y28 w30 h20 g77GuiGetInfo, OK
; Section/fn/Aktion/Kommentar
Gui, 77:Add, Text, x200 y70 w55 h20, [Section]:
Gui, 77:Add, DropDownList, x265 y68 w70 h60 AltSubmit Center vdd_Section, fnIntro|fnNag
Gui, 77:Add, Text, x200 y95 w55 h20, fn:
Gui, 77:Add, Edit, x265 y92 w120 h20 ve_fn, 
Gui, 77:Add, Text, x200 y117 w55 h20, Aktion:
Gui, 77:Add, Edit, x265 y114 w120 h20 ve_fnAction, 
Gui, 77:Add, Text, x200 y139 w60 h20, Kommentar:
Gui, 77:Add, Edit, x265 y136 w120 h20 ve_fnComment,
Gui, 77:Add, Text, x200 y160 w55 h20, Anzeige:
Gui, 77:Add, DropDownList, x265 y158 w120 h80 AltSubmit Center Choose%dd_Source% vdd_Source g77GuiChangeList, fnIntro&fnNag||fnIntro|fnNag|Kommentare
; Checkbox Comment / Speichern
Gui, 77:Add, Text, x16 y198 w300  h20, %DuplicateMessage%
Gui, 77:Add, Button, x344 y198 w65 h20 , Speichern
Gui, 77:Add, Button, x275 y198 w65 h20 , l%oe%schen
Gui, 77:Show, x%AutoEditX% y%AutoEditY% %77GuiCenter% Autosize, Library durchsuchen
return 

77GuiClose:
77GuiEscape:
Gui 77:Destroy
return

77GuiChangeList:
gui 77:Submit, Nohide
if (dd_Source = 1)
	LibraryContent := "fn"
if (dd_Source = 2)
	LibraryContent := "fnIntro"
if (dd_Source = 3)
	LibraryContent := "fnNag"
if (dd_Source = 4)
	LibraryContent := "Comment"
Gui 77:Destroy
Goto SettingUpLibraryContent
return

77GuiGetInfo:
gui 77:Submit, Nohide
GuiControl, ChooseString, LibrarySearchResult, %LibrarySearchResult%
GuiControl,, e_SearchField , %LibrarySearchResult%
if (LibraryContent = "Comment")
	GoSub SetUpLibrary
return 

77GuiSearchLibrary:
gui 77:Submit, Nohide
GuiControl, ChooseString, LibrarySearchResult, % e_SearchField
if (LibraryContent = "fn")
	GoSub SetUpLibrary
return 

SetUpLibrary:
; get e_fn, dd_Section, (e_fnComment)
if (LibraryContent = "fn")
	{
	e_fn := LibrarySearchResult
	; Section
	SectionPart := GetIniValue(LibraryFile, "fnNag", e_fn)
	if (SectionPart = "Error")
		dd_Section := 1 ; fnIntro
	else
		dd_Section := 2 ; fnNag
	}
else if (LibraryContent = "Comment")
	{
	e_fnComment := LibrarySearchResult
	e_fn := GetPreloadFromComment(e_fnComment, dd_Section)
	}

; fnAction
if (dd_Section = 1)
	{
	e_fnAction := GetIniValue(LibraryFile, "fnIntro", e_fn)
	IniRead, PreloadInfo, %LibraryFile%, fnIntro, %e_fn%
	}
else
	{
	e_fnAction := GetIniValue(LibraryFile, "fnNag", e_fn)
	IniRead, PreloadInfo, %LibraryFile%, fnNag, %e_fn%
	}
if (LibraryContent = "fn")
	{
	e_fnComment := Substr(PreloadInfo, (Instr(PreloadInfo, ";") + 2))
	}

; Changing Control
GuiControl,, e_fn , %e_fn%
GuiControl,, e_fnComment , %e_fnComment%
GuiControl,, e_fnAction , %e_fnAction%
GuiControl, Choose, dd_Section, %dd_Section%
return 

GetPreloadFromComment(e_fnComment, Byref dd_Section){
local
global oe, ae, ue, LibraryFile
global SectionfnIntro, SectionfnNag
MatchCount := 0
AllMatches := ""
SectionArray := ["SectionfnIntro", "SectionfnNag"]
for i, Section in SectionArray
	{
	Loop, Parse, %Section%, "`n"
		{
		CleanLoopField := StrReplace(A_LoopField, "ö", oe)
		CleanLoopField := StrReplace(CleanLoopField, "ä", ae)			
		CleanLoopField := StrReplace(CleanLoopField, "ü", ue)
		if Instr(CleanLoopField, e_fnComment, true)
			{
			++MatchCount
			EqualSign := Instr(CleanLoopField, "=")
			Preload := StrReplace(Substr(CleanLoopField, 1, (EqualSign-1)), "")
			AllMatches .= Preload . "`n"
			}
		}
	}
	
if (MatchCount > 1)
	Msgbox, 4096 , %MatchCount% Matches!, %  AllMatches 
if (GetIniValue(LibraryFile, "fnNag", Preload) = "Error")
	dd_Section := 1
else
	dd_Section := 2
return 	Preload
}

#if 